# Claude plan usage in the Noctalia bar: 5-hour session / weekly limits with
# progress bars and reset countdowns, the claude.ai usage split, and the
# API-equivalent USD cost of Claude Code per window and per model. Colored at
# 70% / 90%. The whole feature in one file.
#
# `claude-usage` reads Claude Code's OAuth token from
# ~/.claude/.credentials.json and queries the (undocumented) endpoint the
# claude.ai usage page uses. It never refreshes the token itself — Claude Code
# does that whenever it runs — so an expired token just shows as "expired".
#
# Costs come from Claude Code's local logs (~/.claude/projects/**/*.jsonl,
# deduplicated by message + request id) priced with the table below — what
# the same tokens would cost on the API, not what the plan bills. Only Claude
# Code on this machine counts; claude.ai chats are in the % but not the $.
let
  # USD per million tokens: input, output, 5-min cache write, 1-hour cache
  # write, cache read. Source: LiteLLM model_prices (Nov 2026). Model names
  # are matched exactly, else by longest prefix (dated snapshots).
  prices = {
    "claude-fable-5-1" = { i = 10; o = 50; cw = 12.5; cw1h = 20; cr = 0.25; };
    "claude-fable-5" = { i = 10; o = 50; cw = 12.5; cw1h = 20; cr = 1; };
    "claude-opus-5-5" = { i = 4; o = 20; cw = 5; cw1h = 8; cr = 0.2; };
    "claude-opus-5" = { i = 5; o = 25; cw = 6.25; cw1h = 10; cr = 0.5; };
    "claude-opus-4" = { i = 5; o = 25; cw = 6.25; cw1h = 10; cr = 0.5; };
    "claude-sonnet-5-5" = { i = 2; o = 10; cw = 2.5; cw1h = 4; cr = 0.1; };
    "claude-sonnet-5" = { i = 2; o = 10; cw = 2.5; cw1h = 4; cr = 0.2; };
    "claude-sonnet-4" = { i = 3; o = 15; cw = 3.75; cw1h = 6; cr = 0.3; };
    "claude-haiku-5-5" = { i = 0.1; o = 0.5; cw = 0.125; cw1h = 0.2; cr = 0.01; };
    "claude-haiku-4" = { i = 1; o = 5; cw = 1.25; cw1h = 2; cr = 0.1; };
  };
in
{
  flake.modules.homeManager.claude-usage = { pkgs, ... }: {
    home.packages = [
      (pkgs.writeShellApplication {
        name = "claude-usage";
        runtimeInputs = [ pkgs.curl pkgs.jq pkgs.coreutils pkgs.findutils ];
        text = ''
          # Output: first line `ok` or `err<TAB>reason`, then tab-separated
          # records the widget parses:
          #   five|week  <pct> <reset in>
          #   scoped     <label> <pct>          (per-model weekly caps, if any)
          #   share      <label> <pct>          (weekly split: Claude Code / chats)
          #   cost       <5h usd> <week usd>
          #   model      <name> <5h usd> <week usd> <week tokens>
          CREDS="$HOME/.claude/.credentials.json"
          PRICES='${builtins.toJSON prices}'

          if [ ! -r "$CREDS" ]; then
            printf 'err\tno-login\n'; exit 0
          fi
          TOKEN=$(jq -r '.claudeAiOauth.accessToken // empty' "$CREDS")
          EXPIRES=$(jq -r '.claudeAiOauth.expiresAt // 0' "$CREDS")
          if [ -z "$TOKEN" ]; then
            printf 'err\tno-login\n'; exit 0
          fi
          NOW=$(date +%s)
          if [ "$EXPIRES" -lt "$(( NOW * 1000 ))" ]; then
            printf 'err\texpired\n'; exit 0
          fi

          RESP=$(curl -s -m 15 -w '\n%{http_code}' https://api.anthropic.com/api/oauth/usage \
                -H "Authorization: Bearer $TOKEN" \
                -H "anthropic-beta: oauth-2025-04-20" \
                -H "User-Agent: claude-usage-noctalia") || RESP=$'\n000'
          HTTP=''${RESP##*$'\n'}
          RESP=''${RESP%$'\n'*}
          case "$HTTP" in
            200) ;;
            429) printf 'err\tratelimited\n'; exit 0 ;;
            401|403) printf 'err\texpired\n'; exit 0 ;;
            *) printf 'err\toffline\n'; exit 0 ;;
          esac

          # Seconds -> "3h12m" / "2d4h"
          human() {
            local s=$1
            [ "$s" -lt 0 ] && s=0
            if [ "$s" -ge 86400 ]; then
              echo "$(( s / 86400 ))d$(( s % 86400 / 3600 ))h"
            else
              echo "$(( s / 3600 ))h$(( s % 3600 / 60 ))m"
            fi
          }
          epoch() { if [ -n "$1" ]; then date -d "$1" +%s; else echo "$NOW"; fi; }

          FIVE_END=$(epoch "$(jq -r '.five_hour.resets_at // empty' <<<"$RESP")")
          WEEK_END=$(epoch "$(jq -r '.seven_day.resets_at // empty' <<<"$RESP")")
          FIVE_START=$(( FIVE_END - 5 * 3600 ))
          WEEK_START=$(( WEEK_END - 7 * 86400 ))

          echo ok
          printf 'five\t%s\t%s\n' "$(jq -r '.five_hour.utilization // 0 | floor' <<<"$RESP")" "$(human $(( FIVE_END - NOW )))"
          printf 'week\t%s\t%s\n' "$(jq -r '.seven_day.utilization // 0 | floor' <<<"$RESP")" "$(human $(( WEEK_END - NOW )))"
          jq -r '
            ({seven_day_opus: "Opus", seven_day_sonnet: "Sonnet"} | to_entries[]) as $s
              | .[$s.key] | select(. != null) | "scoped\t\($s.value)\t\(.utilization | floor)",
            (.seven_day_breakdown.rows // [] | .[] | select(.percent > 0)
              | "share\t\(.display_name)\t\(.percent)")
          ' <<<"$RESP"

          # API-equivalent cost from Claude Code's local logs, this machine only.
          iso() { date -u -d "@$1" +%Y-%m-%dT%H:%M:%SZ; }
          find "$HOME/.claude/projects" -name '*.jsonl' -newermt "@$WEEK_START" -print0 2>/dev/null \
            | xargs -0 -r cat \
            | jq -nrR --argjson P "$PRICES" --arg w "$(iso "$WEEK_START")" --arg f "$(iso "$FIVE_START")" '
                def price($m): $P[$m] // ($P | to_entries
                  | map(select(.key as $k | $m | startswith($k)))
                  | max_by(.key | length) | .value?);
                def r2: . * 100 | round / 100;
                [inputs | fromjson? | select(.type? == "assistant" and .message.usage? != null)
                  | select((.timestamp // "") >= $w and .message.model != "<synthetic>")
                  | {k: "\(.message.id):\(.requestId)", ts: .timestamp, m: .message.model, u: .message.usage}]
                | unique_by(.k)
                | map(. as $e | price($e.m) as $p
                    | ($e.u.cache_creation.ephemeral_1h_input_tokens // 0) as $c1h
                    | $e + {
                        cost: (if $p == null then 0 else
                          (($e.u.input_tokens // 0) * $p.i + ($e.u.output_tokens // 0) * $p.o
                           + (($e.u.cache_creation_input_tokens // 0) - $c1h) * $p.cw + $c1h * $p.cw1h
                           + ($e.u.cache_read_input_tokens // 0) * $p.cr) / 1e6 end),
                        tok: (($e.u.input_tokens // 0) + ($e.u.output_tokens // 0)
                          + ($e.u.cache_creation_input_tokens // 0) + ($e.u.cache_read_input_tokens // 0))
                      })
                | "cost\t\(map(select(.ts >= $f).cost) | add // 0 | r2)\t\(map(.cost) | add // 0 | r2)",
                  (group_by(.m) | sort_by(-(map(.cost) | add)) | .[]
                    | "model\t\(.[0].m)\t\(map(select(.ts >= $f).cost) | add // 0 | r2)\t\(map(.cost) | add | r2)\t\(map(.tok) | add)")
              '
        '';
      })
    ];

    # Bar widget
    xdg.dataFile."noctalia/plugins/claude-usage".source =
      ../config/noctalia/plugins/claude-usage;
  };
}

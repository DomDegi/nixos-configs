# Claude plan usage in the Noctalia bar: 5-hour session % (+ weekly % and
# reset countdowns in the tooltip), colored at 70% / 90%. The whole feature
# in one file.
#
# `claude-usage` reads Claude Code's OAuth token from
# ~/.claude/.credentials.json and queries the (undocumented) endpoint the
# claude.ai usage page uses. It never refreshes the token itself — Claude Code
# does that whenever it runs — so an expired token just shows as "expired".
{
  flake.modules.homeManager.claude-usage = { pkgs, ... }: {
    home.packages = [
      (pkgs.writeShellApplication {
        name = "claude-usage";
        runtimeInputs = [ pkgs.curl pkgs.jq pkgs.coreutils ];
        text = ''
          # Output (one line, tab-separated):
          #   ok <5h%> <7d%> <5h reset in> <7d reset in>
          #   err <reason>
          CREDS="$HOME/.claude/.credentials.json"

          if [ ! -r "$CREDS" ]; then
            printf 'err\tno-login\n'; exit 0
          fi
          TOKEN=$(jq -r '.claudeAiOauth.accessToken // empty' "$CREDS")
          EXPIRES=$(jq -r '.claudeAiOauth.expiresAt // 0' "$CREDS")
          if [ -z "$TOKEN" ]; then
            printf 'err\tno-login\n'; exit 0
          fi
          if [ "$EXPIRES" -lt "$(( $(date +%s) * 1000 ))" ]; then
            printf 'err\texpired\n'; exit 0
          fi

          if ! RESP=$(curl -sf -m 15 https://api.anthropic.com/api/oauth/usage \
                -H "Authorization: Bearer $TOKEN" \
                -H "anthropic-beta: oauth-2025-04-20" \
                -H "User-Agent: claude-usage-noctalia"); then
            printf 'err\toffline\n'; exit 0
          fi

          # "2026-11-08T22:59:59.5+00:00" -> "3h12m" / "2d4h"
          until_reset() {
            [ -z "$1" ] && { echo "-"; return; }
            local s=$(( $(date -d "$1" +%s) - $(date +%s) ))
            [ "$s" -lt 0 ] && s=0
            if [ "$s" -ge 86400 ]; then
              echo "$(( s / 86400 ))d$(( s % 86400 / 3600 ))h"
            else
              echo "$(( s / 3600 ))h$(( s % 3600 / 60 ))m"
            fi
          }

          FIVE=$(jq -r '.five_hour.utilization // 0 | floor' <<<"$RESP")
          SEVEN=$(jq -r '.seven_day.utilization // 0 | floor' <<<"$RESP")
          FIVE_RESET=$(until_reset "$(jq -r '.five_hour.resets_at // empty' <<<"$RESP")")
          SEVEN_RESET=$(until_reset "$(jq -r '.seven_day.resets_at // empty' <<<"$RESP")")

          printf 'ok\t%s\t%s\t%s\t%s\n' "$FIVE" "$SEVEN" "$FIVE_RESET" "$SEVEN_RESET"
        '';
      })
    ];

    # Bar widget
    xdg.dataFile."noctalia/plugins/claude-usage".source =
      ../config/noctalia/plugins/claude-usage;
  };
}

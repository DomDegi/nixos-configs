# Firefox: enabled system-wide; profile state lives in the persisted
# ~/.config/mozilla (declarative HM profiles would fight it for little gain).
{
  flake.modules.nixos.firefox = {
    programs.firefox.enable = true;
  };
}

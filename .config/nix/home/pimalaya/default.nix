# Pimalaya stack (Mode B) -- direct IMAP/SMTP/CardDAV/CalDAV.
# Parallel to aerc/khal/vdirsyncer; does not replace them. Pass creds match
# aerc/accounts.conf: EMAIL/GMAIL, EMAIL/MAILBOX.
{pkgs, ...}: {
  home.packages = with pkgs; [
    himalaya # CLI email client
    himalaya-tui # TUI email client (shares himalaya config.toml)
    cardamum # contacts
    calendula # calendars
  ];

  xdg.configFile."himalaya/config.toml".source = ./himalaya.toml;
  xdg.configFile."cardamum/config.toml".source = ./cardamum.toml;
  xdg.configFile."calendula/config.toml".source = ./calendula.toml;
}

{
  # These components are
  general = {
    on-demand-minecraft = import ./on-demand-minecraft;
    cloudflare-proxy = import ./cloudflare-proxy;
    disable-screen = import ./disable-screen;
  };

  personal = {
    duksebot = import ./duksebot;
    graphics = import ./graphics;
    "linus.onl" = import ./linus.onl;
    "notifications.linus.onl" = import ./nofitications.linus.onl;
    "git.linus.onl" = import ./git.linus.onl;
    "hellohtml.linus.onl" = import ./hellohtml.linus.onl;
    forsvarsarper = import ./forsvarsarper;
  };
}

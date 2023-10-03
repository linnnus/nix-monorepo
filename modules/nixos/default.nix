{
  # These components are
  general = {
    on-demand-minecraft = import ./on-demand-minecraft;
    cloudflare-proxy = import ./cloudflare-proxy;
    disable-screen = import ./disable-screen;
  };

  personal = {
    duksebot = import ./duksebot;
  };
}

# This file configures openSSH on this host.

{ config, pkgs, lib, ... }:

{
  # Who is allowed/expected to connect to this machine?
  networking.firewall.allowedTCPPorts = [ 22 ];
  services.openssh = {
    enable = true;
    passwordAuthentication = false; 
  };

  users.users = lib.genAttrs ["root" "linus"] (_: {
    openssh.authorizedKeys.keys = 
      [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDcmUCfFA/arYpT0zBWoOXcyxN5bgk5cMrWgTIol5RsHB82VzoS+LG3IV4IwBz4QALaCj5DlhfbasGKMkFRgFvLerEtBleIb58RtOXIOf6TIUaqpyHB3h2CjdwrbmyjjWEl9W2BTpadrR5uPr0HoeED8dCFYE5cPjrSELtrYxEW0o1DBJw8bXfpgyYB21loBzrcOhRsrPSaS0gYHZLGY7Av7FGfncVZDLNYL0/pZ/t0UWD6JF+6FgOdGWAuuwSt5WR9DVxGilVG5aFktDB14fNPEBIVf7tkT4/McAihR/u344yaiUWA4bV7w039Ubhn9NdnoBSvGrP6jTy/zDgq5ywFj8aqcdlahxtELNWgxYYrI8HZzvITKo1FU7BOcUN1vNS4npOvyWBl7s3jFCO+R2E/BoyjfsjYTylacpepf26D87U32jNsh39OKdHxRF3/qmMGYa1L7N4M0iT9WFEMCcKB/MMAcHgE25vWPQaY1orU8X8NZPhxjfIVcw1rqcjwCryNwb1ZOMTIEc9kbGiP99MhE7ZA0yvHZfMezeymSwg1kN+iJDTp24gSsFtYuz5vm9lRu/PzfU9lNlp2KHdaLISUouSCCHPgF7zZSWtXa1B920zrAg2Fco8/Iymh+Fa0UNnrbnfyQTgLeNT12SLD4Y5gHimUsuq8tFkxjR6WffmrRw== linusvejlo@gmail.com"
      ];
  });
}

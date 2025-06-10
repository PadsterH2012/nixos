# Identity configuration for hl-dev-instructor
# AI instruction tools server - Static IP 10.202.28.186

{ config, pkgs, ... }:

{
  networking = {
    hostName = "hl-dev-instructor";
    networkmanager.enable = false;
    interfaces.ens18.ipv4.addresses = [{
      address = "10.202.28.186";
      prefixLength = 24;
    }];
    defaultGateway = "10.202.28.1";
    nameservers = [ "10.202.28.50" "10.202.28.51" ];
    useDHCP = false;
  };

  environment.etc."machine-id".text = "hl-dev-instructor";

  services.xserver.desktopManager.cinnamon = {
    enable = true;
    extraSessionCommands = ''
      ${pkgs.libnotify}/bin/notify-send "AI Instructor Server" "Machine: hl-dev-instructor\nIP: 10.202.28.186\nRole: AI Instruction & Training" --icon=computer
    '';
  };

  environment.variables = {
    HOSTNAME_DISPLAY = "hl-dev-instructor";
    VM_ROLE = "ai-instructor";
    VM_IP = "10.202.28.186";
    INSTRUCTOR_SERVER = "true";
  };

  environment.shellAliases = {
    train = "python3 -m torch.distributed.launch";
    jupyter-start = "jupyter lab --ip=0.0.0.0 --port=8888";
    model-test = "python3 -c 'import torch; print(torch.cuda.is_available())'";
    api-start = "uvicorn main:app --host 0.0.0.0 --port 8000";
  };
}

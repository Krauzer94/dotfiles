{
    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };
    outputs = {
        nixpkgs,
        home-manager,
        ...
    }:
    let
        system = "x86_64-linux";
        pkgs = nixpkgs.legacyPackages.${system};
    in
    {
        # deck@nixos configuration.nix
        nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
                {
                    imports = [ /home/deck/.nix-config/hardware-configuration.nix ];
                    # Bootloader
                    boot.loader.systemd-boot.enable = true;
                    boot.loader.efi.canTouchEfiVariables = true;
                    # Latest kernel
                    boot.kernelPackages = pkgs.linuxPackages_latest;
                    # Define your hostname
                    networking.hostName = "nixos";
                    # Enable networking
                    networking.networkmanager.enable = true;
                    # Set your time zone
                    time.timeZone = "America/Sao_Paulo";
                    # Select internationalisation properties.
                    i18n.defaultLocale = "en_US.UTF-8";
                    i18n.extraLocaleSettings = {
                        LC_ADDRESS = "pt_BR.UTF-8";
                        LC_IDENTIFICATION = "pt_BR.UTF-8";
                        LC_MEASUREMENT = "pt_BR.UTF-8";
                        LC_MONETARY = "pt_BR.UTF-8";
                        LC_NAME = "pt_BR.UTF-8";
                        LC_NUMERIC = "pt_BR.UTF-8";
                        LC_PAPER = "pt_BR.UTF-8";
                        LC_TELEPHONE = "pt_BR.UTF-8";
                        LC_TIME = "pt_BR.UTF-8";
                    };
                    # Enable the X11 windowing system
                    services.xserver.enable = true;
                    # Enable the KDE Plasma Desktop Environment
                    services.displayManager.sddm.enable = true;
                    services.desktopManager.plasma6.enable = true;
                    # Configure keymap in X11
                    services.xserver.xkb = {
                        layout = "us";
                        variant = "";
                    };
                    # Enable CUPS to print documents
                    services.printing.enable = true;
                    # Enable sound with pipewire
                    hardware.pulseaudio.enable = false;
                    security.rtkit.enable = true;
                    services.pipewire = {
                        enable = true;
                        alsa.enable = true;
                        alsa.support32Bit = true;
                        pulse.enable = true;
                    };
                    # Define a user account. Don't forget to set a password with ‘passwd’
                    users.users.deck = {
                        isNormalUser = true;
                        description = "Krauzer";
                        extraGroups = [ "networkmanager" "wheel" ];
                        packages = with pkgs; [
                            kdePackages.kate
                            kdePackages.discover
                        ];
                    };
                    # Install Firefox
                    programs.firefox.enable = false;
                    # Install Steam
                    programs.steam.enable = true;
                    # Allow unfree packages
                    nixpkgs.config.allowUnfree = true;
                    # List packages installed in system profile.
                    # To search, run: nix search wget
                    environment.systemPackages = with pkgs; [
                        direnv
                        fastfetch
                    ];
                    # List services that you want to enable:
                    services.flatpak.enable = true;
                    # Origin installation version
                    system.stateVersion = "24.05";
                    # Enable OpenGL
                    hardware.graphics = {
                        enable = true;
                    };
                    # Load nvidia driver for Xorg and Wayland
                    services.xserver.videoDrivers = ["nvidia"];
                    hardware.nvidia = {
                        # Modesetting is required
                        modesetting.enable = true;
                        # Nvidia power management. Experimental, and can cause sleep/suspend to fail
                        powerManagement.enable = false;
                        # Fine-grained power management. Turns off GPU when not in use
                        powerManagement.finegrained = false;
                        # Use the NVidia open source kernel module (not to be confused with the
                        # independent third-party "nouveau" open source driver)
                        open = false;
                        # Enable the Nvidia settings menu
                        nvidiaSettings = false;
                        # Optionally, you may need to select the appropriate driver version for your specific GPU
                        package = config.boot.kernelPackages.nvidiaPackages.stable;
                    };
                }
            ];
        };
        # deck@nixos home.nix
        homeConfigurations."deck@nixos" = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
                {
                    home.username = "deck";
                    home.homeDirectory = "/home/deck";
                    home.stateVersion = "23.11";
                    home.packages = with pkgs; [
                        just
                        wget
                        git
                    ];
                    programs.home-manager.enable = true;
                }
            ];
        };
        # deck@archlinux home.nix
        homeConfigurations."deck@archlinux" = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
                {
                    home.username = "deck";
                    home.homeDirectory = "/home/deck";
                    home.stateVersion = "23.11";
                    home.packages = with pkgs; [
                        just
                        direnv
                        fastfetch
                    ];
                    programs.home-manager.enable = true;
                }
            ];
        };
    };
}

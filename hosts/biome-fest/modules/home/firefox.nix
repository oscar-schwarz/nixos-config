{ pkgs, ... }: 

{
  # Install firefox.
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-wayland;

    # Some installation-wide settings and extensions
    # https://mozilla.github.io/policy-templates/
    policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        EnableTrackingProtection = {
          Value= true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        Cookies = {
          Behavior = "reject-foreign";

          # Exceptions from the above
          Allow = [
            # sucking big tech dicks for good music
            "https://spotify.com"
          ];
        };

        DisablePocket = true;
        ShowHomeButton = false;
        DisplayBookmarksToolbar = "never"; # alternatives: "always" or "newtab"
        DisplayMenuBar = "default-off"; # alternatives: "always", "never" or "default-on"
        SearchBar = "unified"; # alternative: "separate"
        TranslateEnabled = false;

        DisableFirefoxAccounts = true;
        DisableAccounts = true;
        DisableFirefoxScreenshots = true;
        
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        
        DontCheckDefaultBrowser = true;
        
        SanitizeOnShutdown = {
          Cache = true;
          FormData = true;
          History = true;
        };

        ExtensionSettings = {
          # uBlock Origin
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
          # Time-to-Work
          "{c52a7349-0c5d-479d-9917-0155a0c58c0a}" = {
            install_url = "https://github.com/OsiPog/time-to-work/releases/download/v1.2.5/time-to-work-1.2.5.xpi";
            installation_mode = "force_installed";
          };
          # Chameleon, user-agent headers and more spoofer
          "{3579f63b-d8ee-424f-bbb6-6d0ce3285e6a}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4349329/chameleon_ext-0.22.65.1.xpi";
            installation_mode = "force_installed";
          };
          # Vimium, keyboard driven website navigation
          "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4259790/vimium_ff-2.1.2.xpi";
            installation_mode = "force_installed";
          };
        };
    };
  };
}
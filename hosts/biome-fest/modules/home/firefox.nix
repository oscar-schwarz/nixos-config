{ pkgs, ... }: 

{
  # Install firefox.
  programs.firefox = {
    enable = true;
    package = pkgs.librewolf-wayland;

    # Some installation-wide settings and extensions
    # https://mozilla.github.io/policy-templates/
    policies = {
        Cookies = {
          Behavior = "reject-foreign";
        };

        Bookmarks = [
          {
            Title = "MyNixOS";
            URL = "https://mynixos.com";
          }
          {
            Title = "Spotify";
            URL = "https://accounts.spotify.com/en/login?continue=https%3A%2F%2Fopen.spotify.com%2F";
          }
          {
            Title = "DuckDuckGo";
            URL = "https://duckduckgo.com/";
          }
        ];
        SanitizeOnShutdown = {
          Cache = true;
          History = false;
        };

        DisplayBookmarksToolbar = "never"; # alternatives: "always" or "newtab"
        DisplayMenuBar = "default-off"; # alternatives: "always", "never" or "default-on"
        SearchBar = "unified"; # alternative: "separate"

        # Disable first run page
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";

        DontCheckDefaultBrowser = true;

        NewTabPage = false;

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
          # DuckDuckGo, this extension sets the default search engine to ddg
          "jid1-ZAdIEUB7XOzOJw@jetpack" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4325805/duckduckgo_for_firefox-2024.7.24.xpi";
            installation_mode = "force_installed";
          };
        };

        Preferences =   let
          lock = Value: {
            inherit Value;
            Status = "locked";
          };
        in {
          "browser.urlbar.suggest.searches" = lock "false";
          "browser.startup.homepage" = lock "about:blank";
        
          "privacy.resistFingerprinting.letterboxing" = lock "true";
        };
    };
  };
}
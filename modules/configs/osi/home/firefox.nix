{ pkgs, lib, config, inputs, ... }: 

{
  # Make firefox default
  xdg.mimeApps.defaultApplications = lib.attrsets.genAttrs [
    
    # Open links in firefox
    "x-scheme-handler/http"
    "x-scheme-handler/https" 
    "x-scheme-handler/about" 
    "x-scheme-handler/unknown"

    # Open PDF Files with firefox
    "application/pdf"

  ] (type: "firefox.desktop");
  home.sessionVariables.DEFAULT_BROWSER = lib.getExe config.programs.firefox.package;


  # Install firefox.
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;

    # Some installation-wide settings and extensions
    # https://mozilla.github.io/policy-templates/
    policies = {
      Cookies = {
        Behavior = "reject-foreign";
      };
			AppAutoUpdate = false; # Disable automatic application update
			BackgroundAppUpdate = false; # Disable automatic application update in the background, when the application is not running.

			DisableFirefoxStudies = true;
			DisableFirefoxAccounts = true; # Disable Firefox Sync
			DisableFirefoxScreenshots = true; # No screenshots?

			DisableForgetButton = true; # Thing that can wipe history for X time, handled differently

			DisableProfileImport = true; # Purity enforcement: Only allow nix-defined profiles
			DisableProfileRefresh = true; # Disable the Refresh Firefox button on about:support and support.mozilla.org

			DisableSetDesktopBackground = true; # Remove the “Set As Desktop Background…” menuitem when right clicking on an image, because Nix is the only thing that can manage the backgroud

			DisplayMenuBar = "default-off";
			DisablePocket = true;
			DisableTelemetry = true;
			DisableFormHistory = true;
			DisablePasswordReveal = true;
			DontCheckDefaultBrowser = true;
			OfferToSaveLogins = true;

			EnableTrackingProtection = {
				Value = true;
				Locked = true;
				Cryptomining = true;
				Fingerprinting = true;
				EmailTracking = true;
				# Exceptions = ["https://example.com"]
			};

      Bookmarks = [
        { # to search nixpkgs and options
          Title = "MyNixOS";
          URL = "https://mynixos.com";
        }
        { # to search nix functions
          Title = "Noogle";
          URL = "https://noogle.dev";
        }
        {
          Title = "Spotify";
          URL = "https://accounts.spotify.com/en/login?continue=https%3A%2F%2Fopen.spotify.com%2F";
        }
        {
          Title = "DuckDuckGo";
          URL = "https://duckduckgo.com/";
        }
        {
          Title = "Moodle Uni Leipzig";
          URL = "https://moodle2.uni-leipzig.de/my/courses.php";
        }
        {
          Title = "GitLab Uni Leipzig";
          URL = "https://git.informatik.uni-leipzig.de/";
        }
        {
          Title = "Syncthing Web GUI";
          URL = "http://127.0.0.1:8384/";
        }
      ];
      SanitizeOnShutdown = {
        Cache = true;
        History = false;
      };

      DisplayBookmarksToolbar = "never"; # alternatives: "always" or "newtab"
      SearchBar = "unified"; # alternative: "separate"
      TranslateEnabled = false;

      # Disable first run page
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";

      NewTabPage = false;

      ExtensionSettings = {
        # uBlock Origin
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
        # Dark Mode for every website
        "addon@darkreader.org" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/file/4359254/darkreader-4.9.94.xpi";
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
        # Vue.js Devtools
        "{5caff8cc-3d2e-4110-a88a-003cc85b3858}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/file/4297952/vue_js_devtools-6.6.3.xpi";
          installation_mode = "force_installed";
        };
        # DuckDuckGo, this extension sets the default search engine to ddg
        "jid1-ZAdIEUB7XOzOJw@jetpack" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/file/4325805/duckduckgo_for_firefox-2024.7.24.xpi";
          installation_mode = "force_installed";
        };
        "{b1d62f2f-9e58-4608-8e2a-c8300e04e983}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/file/4302961/tweak_extension-8.3.0.xpi";
          installation_mode = "force_installed";
        };
      };
    };
    profiles = {
      default = {
        isDefault = true;
        settings = {
          "browser.urlbar.suggest.searches" = false;
          "browser.startup.homepage" = "about:blank";
        };
      };
    };
  };
}
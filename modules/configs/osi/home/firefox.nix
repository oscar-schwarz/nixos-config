{ pkgs, lib, config, inputs, ... }: 

let 
  packageName = "firefox";
in {
  # Make firefox default
  xdg.mimeApps.defaultApplications = lib.attrsets.genAttrs [
    
    # Open links in firefox
    "x-scheme-handler/http"
    "x-scheme-handler/https" 
    "x-scheme-handler/about" 
    "x-scheme-handler/unknown"

    # Open PDF Files with firefox
    "application/pdf"

  ] (type: "${packageName}.desktop");
  home.sessionVariables.DEFAULT_BROWSER = lib.getExe config.programs.firefox.package;


  # Install firefox.
  programs.firefox = {
    enable = true;
    package = pkgs.${packageName};

    # Some installation-wide settings and extensions
    # https://mozilla.github.io/policy-templates/
    policies = {
      AppAutoUpdate = false; # Disable automatic application update
      BackgroundAppUpdate = false; # Disable automatic application update in the background, when the application is not running.
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
          URL = "https://open.spotify.com/";
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
        {
          Title = "Hyprland Wiki";
          URL = "https://wiki.hyprland.org/";
        }
      ];
      Cookies = {
        Behavior = "reject-foreign";
      };
      DisableAccounts = true;
      DisableFirefoxAccounts = true; # Disable Firefox Sync
      DisableFirefoxScreenshots = true; # No screenshots
      DisableFirefoxStudies = true;
      DisableForgetButton = true; # Thing that can wipe history for X time, handled differently
      DisableFormHistory = true;
      DisablePasswordReveal = true;
      DisablePocket = true;
      DisableProfileImport = true; # Purity enforcement: Only allow nix-defined profiles
      DisableProfileRefresh = true; # Disable the Refresh Firefox button on about:support and support.mozilla.org
      DisableSetDesktopBackground = true; # Remove the “Set As Desktop Background…” menuitem when right clicking on an image, because Nix is the only thing that can manage the backgroud
      DisableTelemetry = true;
      DisplayMenuBar = "default-off";
      DisplayBookmarksToolbar = "never"; # alternatives: "always" or "newtab"
      DontCheckDefaultBrowser = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
        EmailTracking = true;
      };
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
      };
      FirefoxHome = {
        TopSites = false;
        SponsoredTopSites = false;
        Highlights = false;
        Snippets = false;
        Locked = true; # only allow changing setting here
      };
      FirefoxSuggest = {
        SponsoredSuggestions = false;
        ImproveSuggest = false;
      };
      NewTabPage = false;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = true;
      # Disable first run page
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      Permissions = {
        Location = {
          BlockNewRequests = true;
          Locked = true;
        };
        Notifications = {
          BlockNewRequests = true;
          Locked = true;
        };
        Autoplay = {
          Default = "block-audio-video";
          Locked = true;
        };
      };
      PostQuantumKeyAgreementEnabled = true;
      Preferences = {
          "browser.startup.homepage" = "";
      };
      PromptForDownloadLocation = false;
      SanitizeOnShutdown = {
        Cache = true;
        Sessions = true;
        # History = true;
        Locked = true;
      };
      SearchBar = "unified"; # alternative: "separate"
      SearchSuggestEnabled = false;
      ShowHomeButton = false;
      TranslateEnabled = false;
      UserMessaging = {
        ExtensionRecommendations = false;
        FeatureRecommendations = false;
        UrlbarInterventions = false;
        SkipOnboarding = false;
        MoreFromMozilla = false;
        FirefoxLabs = false;
        Locked = true;
      };
    };
  };
}
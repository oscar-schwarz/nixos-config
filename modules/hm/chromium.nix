{ 
  pkgs, 
  ... 
}: {
  programs.chromium = {
    enable = true;
    # relatively simple with a built-in adblocker
    package = pkgs.brave;
    extensions = [
      {
        # Vimium
        id = "dbepggeogbaibhgnhhndojpepiihcmeb";
      }
      {
        # Vue Devtools
        id = "nhdogjmejiglipccpnnnanhbledajbpd";
      }
    ];
  };
}
{ 
  pkgs, 
  ... 
}: {
  programs.chromium = {
    enable = true;
    package = pkgs.cromite;
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
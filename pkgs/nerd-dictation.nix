pkgs@{
  lib,
  stdenv,
  fetchzip,
  fetchFromGitHub,
  python3Packages,
  makeWrapper,
  wtype,
  pulseaudio,
  ...
}: let
  vosk-model-name = "vosk-model-small-en-us-0.15";
  vosk-model = fetchzip {
    url = "https://alphacephei.com/vosk/models/${vosk-model-name}.zip";
    hash = "sha256-CIoPZ/krX+UW2w7c84W3oc1n4zc9BBS/fc8rVYUthuY="; # vosk-model-small-en-us-0.15
    # hash = "sha256-AOnKWIoInKzHtF0odhnp6RXDyfjA4bDMBxL0rcZkAd0=";
    # hash = lib.fakeHash;
  };
in python3Packages.buildPythonApplication {
  pname = "nerd-dictation";
  version = "0.1.0";  # Using a placeholder version as we're fetching from main branch

  src = fetchFromGitHub {
    owner = "ideasman42";
    repo = "nerd-dictation";
    rev = "main";
    sha256 = "sha256-M/05SUAe2Fq5I40xuWZ/lTn1+mNLr4Or6o0yKfylVk8=";
  };

  format = "other";  # This is a script, not a standard Python package

  nativeBuildInputs = [ makeWrapper ];

  propagatedBuildInputs = with python3Packages; [
    numpy
  ] ++ [
    (callPackage ./vosk.nix pkgs) # add the local needed package
  ];
  # 
  installPhase = ''
    mkdir -p $out/bin
    install -m755 nerd-dictation $out/bin/nerd-dictation
    
    # Create a wrapper script that conditionally adds the --vosk-model-dir flag
    mv $out/bin/nerd-dictation $out/bin/.nerd-dictation-unwrapped
    
    cat > $out/bin/nerd-dictation << EOF
    #!/bin/sh
    if [ "\$1" = "begin" ]; then
      exec $out/bin/.nerd-dictation-unwrapped "\$@" --simulate-input-tool WTYPE --vosk-model-dir ${vosk-model}
    else
      exec $out/bin/.nerd-dictation-unwrapped "\$@"
    fi
    EOF
    
    chmod +x $out/bin/nerd-dictation
    
    wrapProgram $out/bin/.nerd-dictation-unwrapped \
      --prefix PATH : ${lib.makeBinPath [ wtype pulseaudio ]}
  '';

  meta = with lib; {
    description = "Simple hackable offline speech to text using VOSK-API";
    homepage = "https://github.com/ideasman42/nerd-dictation";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
    mainProgram = "nerd-dictation";
  };
}

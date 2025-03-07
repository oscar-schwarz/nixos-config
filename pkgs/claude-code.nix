{ lib, stdenv, fetchurl, makeWrapper, nodejs_20, pkg-config, python3, libuuid }:

stdenv.mkDerivation rec {
  pname = "claude-code";
  version = "0.2.32";

  src = fetchurl {
    url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
    sha256 = "06y06cpqr09l6gn965hdzbhicgqfazc0hcbkrhlqpwy9j3327mch";
  };
  
  buildInputs = [ nodejs_20 pkg-config python3 libuuid ];
  nativeBuildInputs = [ makeWrapper ];

  sourceRoot = ".";
  
  unpackPhase = ''
    mkdir -p $TMPDIR/source
    tar -xzf $src -C $TMPDIR/source
  '';

  buildPhase = ''
    # No need for custom build steps
    true
  '';

  installPhase = ''
    mkdir -p $out
    cp -r $TMPDIR/source/package/* $out/
    
    mkdir -p $out/bin
    
    # Create a wrapper script to run the CLI
    makeWrapper ${nodejs_20}/bin/node $out/bin/claude-code \
      --add-flags "$out/cli.mjs" \
      --set NODE_PATH $out/node_modules

    # Make sure the wrapper script is executable
    chmod +x $out/bin/claude-code
  '';

  meta = with lib; {
    description = "Claude Code CLI tool from Anthropic";
    homepage = "https://www.npmjs.com/package/@anthropic-ai/claude-code";
    license = licenses.unfree;
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = [];
  };
}

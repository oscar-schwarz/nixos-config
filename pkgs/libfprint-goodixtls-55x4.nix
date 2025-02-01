{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  meson,
  python3,
  ninja,
  gusb,
  pixman,
  glib,
  nss,
  gobject-introspection,
  cairo,
  libgudev,
  gtk-doc,
  docbook-xsl-nons,
  docbook_xml_dtd_43,
  openssl,
  gdb,
  valgrind,
  opencv,
  doctest,
  cmake,
  ...
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libfprint-goodixtls-55x4";
  version = "r1802-6e4fdc0";
  outputs = [
    "out"
    "devdoc"
  ];

  src = fetchFromGitHub {
    owner = "TheWeirdDev";
    repo = "libfprint";
    rev = "d1ca62a801aa565e67d1a2a47aaa7a33232b7990";
    hash = "sha256-EbFvsfl3ry6jrwFNhXVFCoqWz4TDj1UX0GcuVRVmd2M=";
  };

  postPatch = ''
    patchShebangs \
      tests/test-runner.sh \
      tests/unittest_inspector.py \
      tests/virtual-image.py \
      tests/umockdev-test.py \
      tests/test-generated-hwdb.sh
  '';

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    cmake
    gtk-doc
    gdb
    valgrind
    docbook-xsl-nons
    # docbook_xml_dtd_43
    gobject-introspection
  ];

  buildInputs = [
    gusb
    # pixman
    glib
    # nss
    cairo
    openssl
    opencv
    doctest
    libgudev
  ];

  mesonFlags = [
    "-Dudev_rules_dir=${placeholder "out"}/lib/udev/rules.d"
    # Include virtual drivers for fprintd tests
    "-Ddrivers=default"
    "-Dudev_hwdb_dir=${placeholder "out"}/lib/udev/hwdb.d"
  ];

  nativeInstallCheckInputs = [
    (python3.withPackages (p: with p; [ pygobject3 ]))
  ];

  doCheck = false;

  doInstallCheck = false;

  meta = {
    description = "Fork of libfprint for Goodix TLS 55x4 devices support";
    homepage = "https://github.com/TheWeirdDev/libfprint";
    license = lib.licenses.lgpl21Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ ]; # Add maintainers here, if any
  };
})
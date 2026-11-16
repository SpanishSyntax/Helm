{
  lib,
  stdenv,
  cmake,
  ninja,
  pkg-config,
  qt6,
  hyprland,
  glib,
  dconf,
  xorg ? null,
  xrdb ? xorg.xrdb,
  lua5_4,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "flightdeck";
  version = "1.0.0";

  src = ./..;

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    qt6.qtshadertools
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtshadertools
    qt6.qtsvg
  ];

  cmakeFlags = [
    "-DFLIGHTDECK_VERSION=1.0.0"
  ];

  postFixup = ''
    wrapProgram $out/bin/flightdeck \
      --prefix PATH : ${lib.makeBinPath [ hyprland glib dconf xrdb lua5_4 ]}
    ln -sf flightdeck $out/bin/helm
  '';

  meta = with lib; {
    description = "FlightDeck (Helm) - Qt6 GUI controller and management cockpit for Hyprland and Caelestia";
    homepage = "https://github.com/SpanishSyntax/Helm";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    mainProgram = "flightdeck";
  };
})

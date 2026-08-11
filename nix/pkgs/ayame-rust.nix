{
  lib,
  stdenv,
  cmake,
  ninja,
  kdePackages,
}:
let
  src = ../..;
in
# [ https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/kl/klassy/package.nix ]
stdenv.mkDerivation (_finalAttrs: {
  inherit src;
  pname = "ayame";
  version = "6.7.4";

  nativeBuildInputs = [
    cmake
    ninja
    kdePackages.extra-cmake-modules
    kdePackages.wrapQtAppsHook
  ];

  buildInputs = with kdePackages; [
    qtbase
    qtdeclarative
    qttools
    qtsvg

    frameworkintegration
    kcmutils
    kcolorscheme
    kconfig
    kcoreaddons
    kdecoration
    kguiaddons
    ki18n
    kiconthemes
    kirigami
    kwidgetsaddons
    kwindowsystem
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_QT6" true)
  ];

  meta = {
    maintainers = with lib.maintainers; [ tefla ];
    mainProgram = "ayame-settings6";
  };
})

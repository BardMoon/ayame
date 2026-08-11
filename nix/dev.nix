{
  inputs,
  stdenv,
  mkShell,
  pkgs,
  ...
}:
let
  rust-toolchain = inputs.fenix.packages.${stdenv.hostPlatform.system}.stable.withComponents [
    "cargo"
    "clippy"
    "rustc"
    "rust-src"
    "rust-analyzer"
  ];
in
mkShell {
  #[ https://github.com/NixOS/nixpkgs/blob/master/pkgs/kde/plasma/breeze/default.nix ]
  buildInputs = with pkgs; [
    #[ Rust ]
    rust-toolchain
    cargo-edit
    cargo-outdated
    cargo-nextest

    #[ CMake ]
    cmake
    ninja

    #[ Qt ]
    qt6.qtbase
    qt6.qtsvg
    qt6.qtdeclarative
    #[ KDE ]
    kdePackages.extra-cmake-modules
    kdePackages.kcmutils
    kdePackages.kcoreaddons
    kdePackages.kcolorscheme
    kdePackages.kconfig
    kdePackages.kguiaddons
    kdePackages.ki18n
    kdePackages.kiconthemes
    kdePackages.kwindowsystem
    kdePackages.kdecoration
    #[ Graphics ]
    libGL
    mesa
  ];

  shellHook = ''
    echo "🧪 C++ Qt Rust"
  '';
}

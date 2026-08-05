{
  mkShell,
  pkgs,
  ...
}:
mkShell {
  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/kde/plasma/ayame/default.nix
  buildInputs = with pkgs; [
    cmake
    ninja

    # === Rust ===
    (rust-bin.stable.latest.default.override {
      extensions = [
        "clippy"
        "rust-src"
      ];
    })
    cargo
    cargo-edit
    cargo-outdated
    rustc
    cargo-nextest

    # === Qt ===
    qt6.qtbase
    qt6.qtsvg
    qt6.qtdeclarative
    # === KDE ===
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
    # === Graphics ===
    libGL
    mesa
  ];

  shellHook = ''
    echo "🧪 C++ Qt"
  '';
}

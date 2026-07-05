{
  mkShell,
  pkgs,
  ...
}:
mkShell {
  buildInputs = with pkgs; [
  ];

  shellHook = ''
    echo "🧪 node"
  '';
}

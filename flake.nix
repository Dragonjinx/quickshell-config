{
  description = "Quickshell configuration — replaces Waybar + Rofi";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    quickshell = {
      url = "github:quickshell-mirror/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, quickshell }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          qs = quickshell.packages.${system}.default;
          qsWithModules = qs.withModules (with pkgs; [
            qt6.qt5compat
            qt6.qtmultimedia
            qt6.qtsvg
            qt6.qtimageformats
          ]);
        in
        {
          default = qsWithModules;

          # Run: nix run .#quickshell-config
          quickshell-config = pkgs.stdenv.mkDerivation {
            name = "quickshell-config";
            src = ./.;
            installPhase = ''
              mkdir -p $out/share/quickshell
              cp -r . $out/share/quickshell/quickshell-config
            '';
          };
        }
      );

      apps = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          qs = self.packages.${system}.default;
        in
        {
          default = {
            type = "app";
            program = "${qs}/bin/quickshell";
          };

          # Run: nix run .#shell
          shell = {
            type = "app";
            program = "${qs}/bin/quickshell";
            args = [ "-c" "${self.packages.${system}.quickshell-config}/share/quickshell/quickshell-config" ];
          };
        }
      );

      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          qs = self.packages.${system}.default;
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              qs
              qt6.qt5compat
              qt6.qtmultimedia
              qt6.qtsvg
              qt6.qtimageformats
              qt6.full
              libsForQt5.qttools  # qmlls for LSP
            ];
          };
        }
      );
    };
}
{
  description = "prefix-dev/pixi flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    gitignore = {
      url = "github:hercules-ci/gitignore.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, gitignore }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        pixi = pkgs.rustPlatform.buildRustPackage rec {
          pname = "pixi";
          version = "v0.1.0";

          src = pkgs.fetchFromGitHub {
            owner = "prefix-dev";
            repo = "pixi";
            rev = version;
            hash = "sha256-n1TZLgc3TTUs0F/DSKl3nPLkx8jmzlpp2dFII4u8hLQ=";
          };

          nativeBuildInputs = [
            pkgs.pkg-config
          ];

          buildInputs = [
            pkgs.openssl
          ];

          cargoHash = "sha256-6uhb38Ofa2QOKn+rp3/gv4mPXrJuyWfiudwgwnJb85s=";

          doCheck = false;

          meta = with pkgs.lib; {
            description = "Package management made easy";
            homepage = "https://github.com/prefix-dev/pixi";
            license = licenses.bsd3;
            maintainers = [];
          };
        };

        shell = pkgs.buildFHSEnv {
          name = "pixi-shell";
          targetPkgs = pkgs: with pkgs; [pixi ] ++ [
            stdenv.cc xorg.libSM xorg.libICE
            xorg.libX11 xorg.libXau xorg.libXi
            xorg.libXrender libselinux libGL zlib
          ];
          runScript = "bash -l";
        };
      in with pkgs; {
        defaultPackage = pixi;
        packages = {
          pixi = pixi;
          pixi-shell = shell;
        };
      });
}

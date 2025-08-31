
{
  description = "Gemini CLI flake for Nix development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShell = pkgs.mkShell {
        pname = "gemini-cli-shell";
        buildInputs = with pkgs; [
          gemini-cli
          python310
          nodejs
          git
          nix
        ];

        shellHook = ''
          echo "Welcome to Gemini CLI Dev Shell!"
          export PATH=$PATH
          export GEMINI_CONFIG_PATH=$HOME/.gemini
          export GITHUB_PAT=$GITHUB_PAT
        '';
      };
    }
  );
}

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

      # Python environment for your custom MCP server
      pythonWithPkgs = pkgs.python311.withPackages (ps: [
        # Assuming the required library is on PyPI.
        # Replace 'mcp-server' with the actual package name if different.
        ps.mcp-server
      ]);

    in
    {
      devShell = pkgs.mkShell {
        pname = "gemini-cli-shell";
        buildInputs = with pkgs; [
          # Assuming 'gemini-cli' is the package name in nixpkgs
          gemini-cli
          pythonWithPkgs # Provides python3 and the mcp-server library
          nodejs
          git
          nix
        ];

        shellHook = ''
          echo "Welcome to the Lorenzo/Gemini Security-First AI Environment!"
          export GEMINI_CONFIG_PATH=$HOME/.gemini
          # Source environment variables from .env file for security
          if [ -f "$GEMINI_CONFIG_PATH/.env" ]; then
            echo "Loading credentials from .env file..."
            export $(grep -v '^#' "$GEMINI_CONFIG_PATH/.env" | xargs)
          fi
        '';
      };
    }
  );
}

{
  description = "Gemini CLI flake for Nix development environment";

  inputs = {
    # The nixpkgs repository from the NixOS project contains packages for many
    # operating systems, including macOS (darwin). We use the stable release
    # branch for reliability.
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.05";
    # We also need the unstable channel for packages not yet in the stable release.
    # 'nixpkgs-unstable' is the conventional, platform-agnostic name for this channel.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, flake-utils }:
  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
      # Overlay unstable packages for things not in the stable channel
      pkgs-unstable = import nixpkgs-unstable { inherit system; };

      # The 'mcp-server' package is not in nixpkgs, so we define it here,
      # fetching it directly from PyPI to ensure the environment is complete.
      mcp-server-pkg = pkgs.python311Packages.buildPythonPackage rec {
        pname = "mcp-server";
        version = "0.2.1";
        format = "pyproject";

        src = pkgs.fetchurl {
          url = "https://files.pythonhosted.org/packages/b6/2c/809181180b910123985478437d21c33f815555771897d8b776d6b67711c7/mcp-server-0.2.1.tar.gz";
          hash = "sha256-12a2757ff8fe261dddb1fe00682f1e37a5fb5af9c9f2bfd9f242fdd3b7ac9a43";
        };

        propagatedBuildInputs = with pkgs.python311Packages; [ pydantic typing-extensions ];
      };

      # Python environment for your custom MCP server
      pythonWithPkgs = pkgs.python311.withPackages (ps: [
        mcp-server-pkg
      ]);

    in
    {
      devShell = pkgs.mkShell {
        pname = "gemini-cli-shell";
        buildInputs = with pkgs; [
          pkgs-unstable.gemini-cli # Fetched from the unstable channel
          pythonWithPkgs # Provides python3 and the mcp-server library
          nodejs
          ollama
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

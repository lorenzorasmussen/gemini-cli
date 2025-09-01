{                                                                                     
  description = "A development shell with Gemini CLI";

  inputs = {
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
            url =                                                                          
         "https://files.pythonhosted.org/packages/b6/2c/809181180b910123985478437d21c33f8155557718  
         97d8b776d6b67711c7/mcp-server-0.2.1.tar.gz";                                               
            hash =                                                                         
         "sha256-12a2757ff8fe261dddb1fe00682f1e37a5fb5af9c9f2bfd9f242fdd3b7ac9a43";                 
          };                                                                               
                                                                                         
          propagatedBuildInputs = with pkgs.python311Packages; [ pydantic                  
         typing-extensions ];                                                                       
        };                                                                                 
                                                                                         
        # Python environment for your custom MCP server                                    
        pythonWithPkgs = pkgs.python311.withPackages (ps: [                                
          mcp-server-pkg                                                                   
        ]);                                                                                
                                                                                         
        # Wrapper script to set environment variables for gemini-cli                       
        gemini-cli-wrapper = pkgs.writeShellScriptBin "gemini-cli-wrapped" ''              
          #!${pkgs.bash}/bin/bash                                                          
          # Set the config path to the flake's directory                                   
          export GEMINI_CONFIG_PATH="${self}"                                              
                                                                                         
          # Source environment variables from .env file if it exists                       
          if [ -f "$GEMINI_CONFIG_PATH/.env" ]; then                                       
            set -o allexport                                                               
            source "$GEMINI_CONFIG_PATH/.env"                                              
            set +o allexport                                                               
          fi                                                                               
                                                                                         
          # Execute the actual gemini-cli with all passed arguments                        
          exec ${pkgs-unstable.gemini-cli}/bin/gemini "$@"                                 
        '';                                                                                
                                                                                         
      in    {                                                                                  
        # App for running Gemini CLI directly                                              
        apps.default = {                                                                   
          type = "app";                                                                    
          program = "${gemini-cli-wrapper}/bin/gemini-cli-wrapped";                        
        };                                                                                 
                                                                                         
        # Default package is the wrapped CLI                                               
        packages.default = gemini-cli-wrapper;                                             
                                                                                         
        # Development shell for interactive use                                            
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
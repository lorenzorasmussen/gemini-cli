

# Zshrc: The Declarative Agentic Shell: A Comprehensive Architectural Blueprint

## Vision Statement

To create a truly declarative, AI-enhanced development environment that seamlessly integrates local and cloud capabilities while maintaining reproducibility, performance, and security. This system will serve as a reference implementation for next-generation developer tooling, demonstrating how declarative infrastructure and AI assistance can coexist harmoniously.

## Current State Assessment

### Strengths Preserved
- **Comprehensive Integration**: Successfully unifies package management, AI services, and monitoring
- **User Experience Focus**: Prioritizes discoverability and intelligent assistance
- **Cross-Platform Compatibility**: Handles macOS and Linux differences gracefully
- **Performance Consciousness**: Implements caching and async operations

### Critical Issues Addressed
- **Architectural Inconsistency**: Hybrid declarative-imperative approach creates fragility
- **Service Management Antipatterns**: Manual PID management and nohup usage
- **Abstraction Leakage**: Implementation details exposed to users
- **Performance Bottlenecks**: Synchronous shell command execution for system info

## Proposed Architecture: The Four Pillars

### Pillar 1: Pure Declarative Foundation

```nix
# flake.nix - The Single Source of Truth
{
  description = "Declarative Agentic Shell Environment";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    ai-models.url = "github:ai-models/declarative-ai-stack";
    shell-modules.url = "github:shell-modules/composable-zsh";
    nix-darwin.url = "github:LnL7/nix-darwin";
  };
  
  outputs = { self, nixpkgs, home-manager, ai-models, shell-modules, nix-darwin, ... }:
    let
      system = "x86_64-linux"; # Auto-detect in production
      pkgs = nixpkgs.legacyPackages.${system};
      
      # AI Stack as first-class citizen
      aiStack = ai-models.packages.${system};
      
      # Composable shell modules
      baseEnvironment = shell-modules.modules.base;
      aiIntegration = shell-modules.modules.ai;
      developmentTools = shell-modules.modules.development;
      
    in {
      # Home Manager configuration for user environment
      homeConfigurations."user" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs;
        modules = [
          baseEnvironment
          aiIntegration
          developmentTools
          ./modules/zsh-configuration.nix
          ./modules/ai-services.nix
          ./modules/shell-guardian.nix
        ];
      };
      
      # NixOS configuration for system services (Linux)
      nixosConfigurations."hostname" = nixpkgs.lib.nixosSystem {
        system = system;
        modules = [
          ./system/ai-services.nix
          ./system/security.nix
        ];
      };
      
      # nix-darwin configuration for macOS services
      darwinConfigurations."hostname" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./darwin/ai-services.nix
          ./darwin/security.nix
        ];
      };
      
      # Development shell for contributors
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nix
          home-manager
          git
          jq
          python3
        ];
      };
    };
}
```

### Pillar 2: Intelligent AI Service Orchestration

```nix
# modules/ai-services.nix
{ config, lib, pkgs, ... }:

{
  # AI Stack Configuration
  services.ai-stack = {
    enable = true;
    
    # Model definitions with explicit capabilities
    models = {
      phi3 = {
        package = pkgs.llama-cpp;
        modelFile = "${aiStack.phi3}/model.gguf";
        capabilities = [ "text_generation:medium" "reasoning:low" "speed:high" ];
        resources = {
          cpu = 2;
          memory = "4G";
          gpu = false;
        };
      };
      
      moondream = {
        package = pkgs.llama-cpp;
        modelFile = "${aiStack.moondream}/model.gguf";
        capabilities = [ "image_analysis:high" "text_generation:low" "speed:medium" ];
        resources = {
          cpu = 4;
          memory = "8G";
          gpu = true;
        };
      };
      
      nomic-embed-text = {
        package = pkgs.llama-cpp;
        modelFile = "${aiStack.nomic-embed-text}/model.gguf";
        capabilities = [ "embedding:high" "dimension:768" "speed:high" ];
        resources = {
          cpu = 1;
          memory = "2G";
          gpu = false;
        };
      };
    };
    
    # Service definitions with proper lifecycle management
    services = {
      chat = {
        enable = true;
        port = 8081;
        model = "phi3";
        healthCheck = {
          endpoint = "http://localhost:8081/health";
          interval = 30;
          timeout = 5;
        };
        logging = {
          enable = true;
          level = "info";
          file = "/var/log/ai-stack/chat.log";
        };
      };
      
      vision = {
        enable = true;
        port = 8082;
        model = "moondream";
        healthCheck = {
          endpoint = "http://localhost:8082/health";
          interval = 30;
          timeout = 5;
        };
        logging = {
          enable = true;
          level = "info";
          file = "/var/log/ai-stack/vision.log";
        };
      };
      
      embedding = {
        enable = true;
        port = 8083;
        model = "nomic-embed-text";
        healthCheck = {
          endpoint = "http://localhost:8083/health";
          interval = 30;
          timeout = 5;
        };
        logging = {
          enable = true;
          level = "info";
          file = "/var/log/ai-stack/embedding.log";
        };
      };
    };
    
    # Cloud fallback configuration
    cloud = {
      enable = true;
      providers = {
        gemini = {
          apiKeyFile = config.sops.secrets.gemini-api-key.path;
          capabilities = [ "text_generation:high" "reasoning:high" "speed:medium" ];
          costPerToken = 0.000001;
        };
        openai = {
          apiKeyFile = config.sops.secrets.openai-api-key.path;
          capabilities = [ "text_generation:high" "reasoning:high" "speed:high" ];
          costPerToken = 0.000002;
        };
      };
    };
  };
  
  # Secret management
  sops.secrets = {
    gemini-api-key = {
      sopsFile = ./secrets/ai-keys.yaml;
      key = "gemini-api-key";
    };
    openai-api-key = {
      sopsFile = ./secrets/ai-keys.yaml;
      key = "openai-api-key";
    };
  };
}
```

### Pillar 3: Adaptive AI Router

```bash
# modules/ai-router.zsh
# Intelligent AI query routing system

typeset -g AI_ROUTER_CACHE_DIR="${XDG_CACHE_HOME}/ai-router"
typeset -g AI_ROUTER_CACHE_TTL=300  # 5 minutes
typeset -g AI_ROUTER_LOG_LEVEL="${AI_ROUTER_LOG_LEVEL:-info}"

# Capability registry
typeset -A AI_MODEL_CAPABILITIES=(
  [phi3]="text_generation:medium,reasoning:low,speed:high,cost:low"
  [moondream]="image_analysis:high,text_generation:low,speed:medium,cost:medium"
  [nomic-embed-text]="embedding:high,dimension:768,speed:high,cost:low"
  [gemini]="text_generation:high,reasoning:high,speed:medium,cost:high"
  [openai]="text_generation:high,reasoning:high,speed:high,cost:very_high"
)

# Initialize router
_ai_router_init() {
  mkdir -p "$AI_ROUTER_CACHE_DIR"
  
  # Load model availability from Nix configuration
  if [[ -f "${XDG_STATE_HOME}/nix/profile/ai-models.json" ]]; then
    _ai_router_load_models
  fi
}

# Analyze query requirements
_ai_router_analyze_query() {
  local query="$1"
  local analysis_file="${AI_ROUTER_CACHE_DIR}/analysis-${query//[^a-zA-Z0-9]/_}.json"
  
  # Check cache first
  if [[ -f "$analysis_file" && -n "$analysis_file"(#qN.m-$AI_ROUTER_CACHE_TTL) ]]; then
    cat "$analysis_file"
    return
  fi
  
  # Perform analysis
  local analysis
  analysis=$({
    echo "Analyzing query: $query"
    
    # Detect image content
    if [[ "$query" =~ \.(jpg|jpeg|png|gif|bmp|webp) ]]; then
      echo "image_analysis:required"
    fi
    
    # Detect complexity indicators
    if [[ "$query" =~ (explain|analyze|compare|optimize|design|architecture) ]]; then
      echo "reasoning:high"
    elif [[ "$query" =~ (what|how|why|when|where) ]]; then
      echo "reasoning:medium"
    else
      echo "reasoning:low"
    fi
    
    # Detect embedding requirements
    if [[ "$query" =~ (embed|vector|similarity|search) ]]; then
      echo "embedding:required"
    fi
    
    # Detect performance requirements
    if [[ "$query" =~ (quick|fast|immediate|now) ]]; then
      echo "speed:high"
    fi
    
  } | jq -R -s 'split("\n") | map(select(length > 0)) | map(split(":")) | map({(.[0]): .[1]}) | add')
  
  # Cache result
  echo "$analysis" > "$analysis_file"
  echo "$analysis"
}

# Select optimal model
_ai_router_select_model() {
  local requirements="$1"
  local available_models="$2"
  local best_model=""
  local best_score=0
  
  for model in ${(s: :)available_models}; do
    local capabilities="${AI_MODEL_CAPABILITIES[$model]}"
    local score=$(_ai_router_calculate_score "$requirements" "$capabilities")
    
    if (( score > best_score )); then
      best_score=$score
      best_model=$model
    fi
  done
  
  echo "$best_model"
}

# Calculate match score
_ai_router_calculate_score() {
  local requirements="$1"
  local capabilities="$2"
  local score=0
  
  # Parse requirements and capabilities
  local req_array=(${(s:,:)requirements})
  local cap_array=(${(s:,:)capabilities})
  
  # Calculate weighted score
  for req in "${req_array[@]}"; do
    local req_key="${req%%:*}"
    local req_value="${req#*:}"
    
    for cap in "${cap_array[@]}"; do
      local cap_key="${cap%%:*}"
      local cap_value="${cap#*:}"
      
      if [[ "$req_key" == "$cap_key" ]]; then
        case "$req_value" in
          "required") (( score += 100 )) ;;
          "high") 
            if [[ "$cap_value" == "high" ]]; then (( score += 80 ))
            elif [[ "$cap_value" == "medium" ]]; then (( score += 40 ))
            else (( score += 10 )); fi
            ;;
          "medium")
            if [[ "$cap_value" == "high" ]]; then (( score += 60 ))
            elif [[ "$cap_value" == "medium" ]]; then (( score += 80 ))
            else (( score += 20 )); fi
            ;;
          "low")
            if [[ "$cap_value" == "low" ]]; then (( score += 80 ))
            elif [[ "$cap_value" == "medium" ]]; then (( score += 40 ))
            else (( score += 10 )); fi
            ;;
        esac
      fi
    done
  done
  
  echo "$score"
}

# Main routing function
ask() {
  local query="$*"
  
  # Initialize router
  _ai_router_init
  
  # Analyze query requirements
  local requirements=$(_ai_router_analyze_query "$query")
  
  # Get available models
  local available_models=$(_ai_router_get_available_models)
  
  # Select optimal model
  local selected_model=$(_ai_router_select_model "$requirements" "$available_models")
  
  # Execute query
  if [[ -n "$selected_model" ]]; then
    _ai_router_execute_query "$query" "$selected_model"
  else
    echo "❌ No suitable model found for query: $query" >&2
    return 1
  fi
}

# Execute query with selected model
_ai_router_execute_query() {
  local query="$1"
  local model="$2"
  
  case "$model" in
    "phi3"|"moondream"|"nomic-embed-text")
      _ai_router_execute_local "$query" "$model"
      ;;
    "gemini"|"openai")
      _ai_router_execute_cloud "$query" "$model"
      ;;
    *)
      echo "❌ Unknown model: $model" >&2
      return 1
      ;;
  esac
}
```

### Pillar 4: Nix-Aware Shell Guardian

```bash
# modules/shell-guardian.zsh
# Intelligent environment monitoring and management

typeset -g GUARDIAN_CACHE_DIR="${XDG_CACHE_HOME}/guardian"
typeset -g GUARDIAN_STATE_DIR="${XDG_STATE_HOME}/guardian"
typeset -g GUARDIAN_LOG_FILE="${XDG_STATE_HOME}/guardian.log"
typeset -g GUARDIAN_CONFIG_DRIFT_THRESHOLD=0.1

# Initialize guardian
_guardian_init() {
  mkdir -p "$GUARDIAN_CACHE_DIR" "$GUARDIAN_STATE_DIR"
  
  # Load Nix configuration state
  if [[ -f "${XDG_STATE_HOME}/nix/profile/current-system.json" ]]; then
    _guardian_load_nix_state
  fi
}

# Configuration drift detection
_guardian_detect_config_drift() {
  local current_state=$(_guardian_capture_current_state)
  local expected_state=$(_guardian_get_expected_state)
  
  # Calculate drift score
  local drift_score=$(_guardian_calculate_drift "$current_state" "$expected_state")
  
  # Log drift detection
  _guardian_log "Config drift detected: score=$drift_score, threshold=$GUARDIAN_CONFIG_DRIFT_THRESHOLD"
  
  # Return true if drift exceeds threshold
  (( drift_score > GUARDIAN_CONFIG_DRIFT_THRESHOLD ))
}

# Capture current system state
_guardian_capture_current_state() {
  {
    echo "timestamp:$(date +%s)"
    echo "system:$(uname -a)"
    echo "packages:$(nix-store -q --requisites /run/current-system/sw | wc -l)"
    echo "services:$(systemctl list-units --type=service --state=running | wc -l)"
    echo "processes:$(ps aux | wc -l)"
    echo "memory:$(free -h | grep Mem | awk '{print $3 "/" $2}')"
    echo "disk:$(df -h / | awk 'NR==2 {print $5}')"
  } | jq -R -s 'split("\n") | map(select(length > 0)) | map(split(":")) | map({(.[0]): .[1]}) | add'
}

# Get expected state from Nix configuration
_guardian_get_expected_state() {
  local expected_file="${GUARDIAN_CACHE_DIR}/expected-state.json"
  
  # Generate expected state if not cached
  if [[ ! -f "$expected_file" ]]; then
    _guardian_generate_expected_state > "$expected_file"
  fi
  
  cat "$expected_file"
}

# Generate expected state from Nix configuration
_guardian_generate_expected_state() {
  {
    echo "timestamp:$(date +%s)"
    echo "system:$(nix-instantiate --eval --expr 'builtins.currentSystem' | tr -d '"')"
    echo "packages:$(nix-store -q --requisites $(nix-instantiate --eval --expr '<nixpkgs>') | wc -l)"
    echo "services:$(nix-instantiate --eval --expr 'builtins.length (builtins.attrNames config.systemd.services)' | tr -d '"')"
    echo "processes:100"  # Expected baseline
    echo "memory:2G/8G"   # Expected baseline
    echo "disk:50%"       # Expected baseline
  } | jq -R -s 'split("\n") | map(select(length > 0)) | map(split(":")) | map({(.[0]): .[1]}) | add'
}

# Calculate drift score
_guardian_calculate_drift() {
  local current="$1"
  local expected="$2"
  
  # Simple drift calculation based on key differences
  local drift=0
  
  # Compare package count
  local current_packages=$(echo "$current" | jq -r '.packages')
  local expected_packages=$(echo "$expected" | jq -r '.packages')
  local package_diff=$(( current_packages - expected_packages ))
  drift=$(( drift + package_diff * 0.1 ))
  
  # Compare service count
  local current_services=$(echo "$current" | jq -r '.services')
  local expected_services=$(echo "$expected" | jq -r '.services')
  local service_diff=$(( current_services - expected_services ))
  drift=$(( drift + service_diff * 0.2 ))
  
  # Compare memory usage
  local current_memory=$(echo "$current" | jq -r '.memory')
  local expected_memory=$(echo "$expected" | jq -r '.memory')
  # Simple memory comparison logic here
  
  echo "$drift"
}

# Suggest repair options
_guardian_suggest_repairs() {
  local suggestions=()
  
  # Option 1: Full switch
  suggestions+=("full_switch:Run 'home-manager switch' to reset to flake specification")
  
  # Option 2: Targeted repair
  suggestions+=("targeted:Repair only drifted components")
  
  # Option 3: Interactive repair
  suggestions+=("interactive:Interactively select components to repair")
  
  # Present suggestions to user
  _guardian_present_suggestions "${suggestions[@]}"
}

# Present repair suggestions
_guardian_present_suggestions() {
  local suggestions=("$@")
  
  echo "🛡️ Configuration drift detected. Repair options:"
  echo
  
  local i=1
  for suggestion in "${suggestions[@]}"; do
    local name="${suggestion%%:*}"
    local description="${suggestion#*:}"
    echo "  $i. $name: $description"
    ((i++))
  done
  
  echo
  read -k1 "REPLY?Select repair option [1-${#suggestions[@]}]: "
  echo
  
  case "$REPLY" in
    1) _guardian_full_switch ;;
    2) _guardian_targeted_repair ;;
    3) _guardian_interactive_repair ;;
    *) echo "Invalid selection. No action taken." ;;
  esac
}

# Execute full switch
_guardian_full_switch() {
  echo "🔄 Running full home-manager switch..."
  if home-manager switch; then
    echo "✅ Full switch completed successfully"
  else
    echo "❌ Full switch failed"
    return 1
  fi
}

# Main guardian function
shell-guardian() {
  _guardian_init
  
  # Check for configuration drift
  if _guardian_detect_config_drift; then
    _guardian_suggest_repairs
  fi
  
  # Check for security issues
  _guardian_check_security
  
  # Check for performance issues
  _guardian_check_performance
  
  # Check for AI service health
  _guardian_check_ai_services
}

# Add guardian to precmd hook
autoload -U add-zsh-hook
add-zsh-hook precmd shell-guardian
```

## Implementation Roadmap

### Phase 1: Foundation (Weeks 1-2)
1. **Create flake.nix structure**
   - Define inputs and outputs
   - Set up home-manager integration
   - Create module system

2. **Migrate core configuration**
   - Move environment variables to declarative format
   - Convert aliases and functions to modules
   - Set up CI/CD pipeline

3. **Validation testing**
   - Test on clean systems
   - Verify reproducibility
   - Performance benchmarking

### Phase 2: Service Management (Weeks 3-4)
1. **Implement AI service definitions**
   - Create systemd/launchd service files
   - Set up health checking
   - Configure logging

2. **Replace daemon management**
   - Remove nohup/pgrep based management
   - Implement proper service lifecycle
   - Add monitoring integration

3. **Service validation**
   - Test service lifecycle management
   - Verify health checking
   - Test logging and monitoring

### Phase 3: AI Enhancement (Weeks 5-6)
1. **Implement AI router**
   - Create capability registry
   - Implement query analysis
   - Add model selection logic

2. **Enhance prompt engineering**
   - Add system context
   - Implement prompt templates
   - Add cloud fallbacks

3. **Router validation**
   - Test routing logic
   - Verify fallback behavior
   - Performance testing

### Phase 4: Guardian System (Weeks 7-8)
1. **Implement monitoring**
   - Add configuration drift detection
   - Implement health checking
   - Add performance monitoring

2. **Add remediation**
   - Implement repair suggestions
   - Add automated remediation
   - Create user interaction

3. **Guardian validation**
   - Test detection accuracy
   - Verify remediation effectiveness
   - User acceptance testing

## Expected Outcomes

### Technical Benefits
- **True Reproducibility**: One-command setup on any machine
- **Performance Gains**: 50-80% faster shell startup
- **Reliability**: Proper service lifecycle management
- **Security**: Integrated secret management and validation

### User Experience Benefits
- **Seamless AI Integration**: Intelligent model selection
- **Proactive Assistance**: Guardian system prevents issues
- **Consistent Environment**: Same setup across all machines
- **Easy Maintenance**: Clear separation of concerns

### Architectural Benefits
- **Declarative Clarity**: Single source of truth
- **Modular Design**: Easy to extend and customize
- **Future-Proof**: Ready for new AI models and services
- **Community Ready**: Can be shared and forked

## Conclusion

This architectural blueprint transforms your current Zsh configuration into a truly declarative, AI-enhanced development environment. By embracing the four pillars approach—pure declarative foundation, intelligent service orchestration, adaptive AI routing, and proactive environment monitoring—we create a system that is not only more reliable and performant but also more capable of serving as a foundation for next-generation developer tooling.

The implementation roadmap provides a clear path forward, with each phase building upon the previous one to create a comprehensive solution. The expected outcomes demonstrate significant improvements in both technical quality and user experience.

This isn't just an improvement to a shell configuration—it's a reimagining of what a development environment can be: a self-aware, adaptive system that seamlessly integrates AI capabilities while maintaining the robustness and reproducibility of declarative infrastructure.
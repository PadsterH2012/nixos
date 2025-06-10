# Host-specific configuration for hl-dev-instructor
# AI instruction and training tools

{ config, pkgs, ... }:

{
  imports = [
    ../../shared/profiles/development.nix
    ./hardware-configuration.nix
    ./identity.nix
  ];

  # AI and instruction tools
  environment.systemPackages = with pkgs; [
    # AI development
    python3Packages.torch
    python3Packages.transformers
    python3Packages.datasets
    python3Packages.accelerate
    
    # Jupyter and notebooks
    jupyter
    python3Packages.jupyterlab
    
    # Machine learning tools
    python3Packages.scikit-learn
    python3Packages.tensorflow
    
    # Data science
    python3Packages.pandas
    python3Packages.numpy
    python3Packages.matplotlib
    
    # Text processing
    python3Packages.nltk
    python3Packages.spacy
    
    # API development
    python3Packages.fastapi
    python3Packages.uvicorn
    
    # Documentation tools
    python3Packages.sphinx
    mkdocs
  ];

  # Enable CUDA support if available
  nixpkgs.config.allowUnfree = true;
  
  environment.variables = {
    AI_DEVELOPMENT_MODE = "true";
    INSTRUCTOR_TOOLS = "enabled";
    CUDA_VISIBLE_DEVICES = "0";
  };
}

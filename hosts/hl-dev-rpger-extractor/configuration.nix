# Host-specific configuration for hl-dev-rpger-extractor
# RPG data extraction and processing tools

{ config, pkgs, ... }:

{
  imports = [
    ../../shared/profiles/development.nix
    ./hardware-configuration.nix
    ./identity.nix
  ];

  # Data extraction and processing tools
  environment.systemPackages = with pkgs; [
    # Data processing
    python3Packages.pandas
    python3Packages.numpy
    python3Packages.beautifulsoup4
    python3Packages.scrapy
    python3Packages.requests
    
    # Text processing
    python3Packages.nltk
    python3Packages.spacy
    
    # Database tools
    postgresql
    sqlite
    
    # File processing
    jq
    yq-go
    xmlstarlet
    
    # Web scraping
    selenium
    chromium
    
    # Data visualization
    python3Packages.matplotlib
    python3Packages.seaborn
  ];

  # Enable PostgreSQL for data storage
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
  };

  environment.variables = {
    DATA_EXTRACTION_MODE = "true";
    SCRAPING_TOOLS = "enabled";
  };
}

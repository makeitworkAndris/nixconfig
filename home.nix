{ config, pkgs, lib,  ... }:

{
  home.username = "snow";
  home.homeDirectory = "/home/snow";

  home.packages = with pkgs; [
    fastfetch
  ];

  home.stateVersion = "24.11"; # Use this even though the date looks weird
}

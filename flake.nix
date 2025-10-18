{
  description = "Flakecraft - A dedicated minecraft server nixos module utilizing itzg/minecraft-server docker image";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    nixosModules = {
      default = import ./flakecraft.nix;
    };
  };
}

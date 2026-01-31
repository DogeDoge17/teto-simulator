{
  description = "dev shell";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
  in {
    devShells.${system}.default = pkgs.mkShell {
      nativeBuildInputs = [
        pkgs.pkg-config
      ];

      buildInputs = [
        pkgs.mesa # provides libGL / libGLX bits
        pkgs.libglvnd # often needed for GLX on modern stacks

        pkgs.xorg.libX11
        pkgs.xorg.libXcursor
        pkgs.xorg.libXext
        pkgs.xorg.libXfixes
        pkgs.xorg.libXi
        pkgs.xorg.libXinerama
        pkgs.xorg.libXrandr
        pkgs.xorg.libXrender
      ];
    };
  };
}

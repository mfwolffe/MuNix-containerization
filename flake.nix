{
  description = "MuNix w. Flakes + `nix-devcontainer`";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { nixpkgs, ... }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
    in
    {
      devShells.default = pkgs.mkShell {
        buildInputs = [
          pkgs.callPackage (pkgs.python3.overrideAttrs (attrs: {
            src = pkgs.fetchFromGitHub {
              owner = "python";
              repo = "cpython";
              rev = "e8eb0ced9f4d8c424d0b854b55fbdb2ecc60d201";
              sha256 = "Vr/vH9/BIhzmcg5DpmHj60F4XdkUzplpjYx4lq9L2qE=";
            };
          })) []
        ];
      };
    };
}

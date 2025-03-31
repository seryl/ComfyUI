{
  description = "AUTOMATIC1111/stable-diffusion-webui flake";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, flake-utils }: let
    isLinux = system: builtins.match ".*linux.*" system != null;
    linuxSystems = builtins.filter isLinux flake-utils.lib.defaultSystems;
  in flake-utils.lib.eachSystem linuxSystems (system: let

    # Define pkgs with overlays
    myOverlay = final: prev: {
      python311Packages = prev.python311Packages // {
        torch = prev.python311Packages.pytorch-bin;
        triton = prev.python311Packages.triton.overrideAttrs (old: {
          # forcibly create & link ptxas so the chmod call won’t fail
          postPatch = (old.postPatch or "") + ''
            mkdir -p triton/third_party/cuda/bin
            ln -sf ${pkgs.cudaPackages.cuda_nvcc}/bin/ptxas triton/third_party/cuda/bin/ptxas
          '';
          cudaSupport = true;
        });
      };
    };

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      config.cudaSupport = true;
      overlays = [ myOverlay ];
    };

    # Declare extra python packages
    cstr = pkgs.callPackage ./cstr.nix {
      buildPythonPackage = pkgs.python311Packages.buildPythonPackage;
      fetchFromGitHub = pkgs.fetchFromGitHub;
      lib = pkgs.lib;  # if your file uses "with lib;"
    };

    img2texture = pkgs.callPackage ./img2texture.nix {
      buildPythonPackage = pkgs.python311Packages.buildPythonPackage;
      fetchFromGitHub = pkgs.fetchFromGitHub;
      lib = pkgs.lib;  # if your file uses "with lib;"
      mypy = pkgs.python311Packages.mypy;
      pillow = pkgs.python311Packages.pillow;
    };

    pilgram = pkgs.callPackage ./pilgram.nix {
      buildPythonPackage = pkgs.python311Packages.buildPythonPackage;
      fetchFromGitHub = pkgs.fetchFromGitHub;
      lib = pkgs.lib;  # if your file uses "with lib;"
      pillow = pkgs.python311Packages.pillow;
      numpy = pkgs.python311Packages.numpy;
      setuptools = pkgs.python311Packages.setuptools;
    };

    spandrel = pkgs.callPackage ./spandrel.nix {
      buildPythonPackage = pkgs.python311Packages.buildPythonPackage;
      fetchFromGitHub = pkgs.fetchFromGitHub;
      lib = pkgs.lib;  # if your file uses "with lib;"
      torch = pkgs.python311Packages.pytorch;
      torchvision = pkgs.python311Packages.torchvision;
      numpy = pkgs.python311Packages.numpy;
      einops = pkgs.python311Packages.einops;
      typing-extensions = pkgs.python311Packages.typing-extensions;
      safetensors = pkgs.python311Packages.safetensors;
    };

    spandrel_extra_arches = pkgs.callPackage ./spandrel_extra_arches.nix {
      buildPythonPackage = pkgs.python311Packages.buildPythonPackage;
      fetchFromGitHub = pkgs.fetchFromGitHub;
      lib = pkgs.lib;  # if your file uses "with lib;"
      torch = pkgs.python311Packages.pytorch;
      torchvision = pkgs.python311Packages.torchvision;
      numpy = pkgs.python311Packages.numpy;
      einops = pkgs.python311Packages.einops;
      typing-extensions = pkgs.python311Packages.typing-extensions;
      spandrel = spandrel;
    };

  in {
    # Define devShells
    devShells.default = import ./impl.nix { inherit pkgs cstr img2texture pilgram spandrel spandrel_extra_arches; };
    devShells.rocm = import ./impl.nix { inherit pkgs; isCUDA = false; };
  });
}


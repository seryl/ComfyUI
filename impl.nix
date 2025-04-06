{
  pkgs,
  variant ? "CUDA",
  cstr,
  img2texture,
  pilgram,
  # spandrel,
  # spandrel_extra_arches,
  ...
}: let
  # Simplified logic for hardware dependencies based on variant
  hardware_deps = with pkgs;
    if variant == "CUDA"
    then [
      cudaPackages_12_8.cudatoolkit
      cudaPackages_12_8.cuda_nvcc
      cudaPackages_12_8.cuda_cuobjdump
      cudaPackages_12_8.cuda_nvdisasm
      cudaPackages_12_8.cuda_cudart
      cudaPackages_12_8.cuda_cupti
      linuxKernel.packages.linux_xanmod_latest.nvidia_x11_production_open
      xorg.libXi
      xorg.libXmu
      freeglut
      xorg.libXext
      xorg.libX11
      xorg.libXv
      xorg.libXrandr
      zlib
      pkg-config
      gcc
    ]
    else if variant == "ROCM"
    then [
      rocmPackages.rocm-runtime
      pciutils
    ]
    else if variant == "CPU"
    then [
      # CPU-specific deps if any
    ]
    else throw "You need to specify which variant you want: CPU, ROCm, or CUDA.";

  torch-pkg = pkgs.python311Packages.torch-nightly or pkgs.python311Packages.torch;
  torchvision-pkg = pkgs.python311Packages.torchvision-nightly or pkgs.python311Packages.torchvision;
in
  pkgs.mkShell rec {
    name = "stable-diffusion-webui";

    buildInputs = with pkgs;
      hardware_deps
      ++ [
        git # The program instantly crashes if git is not present, even if everything is already downloaded
        ncurses5
        binutils
        gitRepo
        gnupg
        autoconf
        curl
        procps
        gnumake
        util-linux
        m4
        gperf
        unzip
        libGLU
        libGL
        glibc
        ffmpeg
        freeglut

        (python311.withPackages (python-pkgs:
          with python-pkgs; [
            # Use the torch override from our overlay

            torch
            torchvision
            # torchsde
            # torchaudio-pkg

            opencv4
            opencv-python-headless

            #torch
            triton
            #torchvision
            #torchaudio
            #torchsde
            einops
            transformers
            safetensors
            aiohttp
            pyyaml
            pillow
            scipy
            tqdm
            psutil
            kornia
            numba
            GitPython
            numexpr
            matplotlib
            pandas
            imageio-ffmpeg
            scikit-image
            pip
            simpleeval
            (pkgs.callPackage ./dynamicprompts.nix {
              buildPythonPackage = python-pkgs.buildPythonPackage;
              fetchFromGitHub = pkgs.fetchFromGitHub;
              setuptools = python-pkgs.setuptools;
              lib = pkgs.lib;
              hatchling = python-pkgs.hatchling;
              pyparsing = python-pkgs.pyparsing;
              jinja2 = python-pkgs.jinja2;
            })

            #spandrel
            #spandrel_extra_arches
            accelerate

            # WAS Nodes Deps
            fairscale
            cstruct
            joblib
            llvmlite
            ffmpy.override
            {
              version = "0.3.0";
            }
            rpds-py
            scikit-learn
            timm
            cmake
            referencing
            platformdirs
            img2texture
            cstr
            pilgram
          ]))
      ];

    nativeBuildInputs = with pkgs; [
      stdenv.cc
      stdenv.cc.cc.lib
      pkg-config
    ];

    # Environment variables - use CUDA 12.0 specifically
    CUDA_PATH = "${pkgs.cudaPackages_12_8.cudatoolkit}";
    LD_LIBRARY_PATH = "${with pkgs;
      lib.makeLibraryPath [
        stdenv.cc.cc.lib
        linuxKernel.packages.linux_xanmod_latest.nvidia_x11_production_open
        cudaPackages_12_8.cudatoolkit
        libGL
        libGLU
        cudaPackages_12_8.cuda_nvcc
        cudaPackages_12_8.cuda_cuobjdump
        cudaPackages_12_8.cuda_nvdisasm
        cudaPackages_12_8.cuda_cudart
        cudaPackages_12_8.cuda_cupti
      ]}";
    EXTRA_LDFLAGS = "-L/lib -L${pkgs.cudaPackages_12_8.cudatoolkit}/lib:${pkgs.cudaPackages_12_8.cudatoolkit}/lib64 -L${pkgs.linuxKernel.packages.linux_xanmod_latest.nvidia_x11_production_open}/lib";
    EXTRA_CCFLAGS = "-I/usr/include";
  }

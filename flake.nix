{
  description = "An FHS shell with conda and cuda";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    frida.url = "github:itstarsun/frida-nix";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    frida,
  }: let
    pkgs = import nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };
    inherit (nixpkgs) lib;
    inherit (pkgs.cudaPackages_12_0) cudatoolkit cudnn;
    nvidiaX11 = pkgs.linuxKernel.packages.linux_xanmod.nvidia_x11;

    libs = [
      pkgs.stdenv.cc.cc.lib
      cudatoolkit
      cudnn
      nvidiaX11
    ];
  in {
    devShell.x86_64-linux =
      (pkgs.buildFHSUserEnv {
        name = "default";
        targetPkgs = pkgs:
          with pkgs; [
            python311
            gcc
            autoconf
            binutils
            findutils
            openssl
            gnutls
            libxcrypt-legacy
            curl
            freeglut
            git
            gitRepo
            gnumake
            gnupg
            gperf
            libGLU
            libGL
            libselinux
            m4
            ncurses5
            procps
            unzip
            util-linux
            wget
            xorg.libICE
            xorg.libSM
            xorg.libX11
            xorg.libXext
            xorg.libXi
            xorg.libXmu
            xorg.libXrandr
            xorg.libXrender
            xorg.libXv
            zlib
            cmakeWithGui
            openblas
            nvidiaX11
            cudatoolkit
            cudnn
          ];
        profile = ''
          unset LD_LIBRARY_PATH
          # cuda
          export CUDA_HOME="${cudatoolkit}"
          export CUDA_PATH="${cudatoolkit}"
          export LD_LIBRARY_PATH="${cudnn}/lib:${cudatoolkit}:${nvidiaX11}:${pkgs.stdenv.cc.cc.lib}";
          export EXTRA_LDFLAGS="-L/lib -L${cudnn}:${cudatoolkit}:${nvidiaX11}"
          export EXTRA_CCFLAGS="-I/usr/include"
          export _GLIBCXX_USE_CXX11_ABI
        '';
      })
      .env;
  };
}

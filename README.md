# Bitscope on Nix (WIP)

Learnings:

Somehow using `buildFHSUserEnv` doesn't build the derrivation in its entirety.
Still trying to figure out how that works but specifying in for instance
`example.nix` containing

```nix
{ pkgs ? import <nixpkgs> {} }: 

with pkgs;
buildFHSUserEnv {
  name = "example";

  targetPkgs = pkgs: [
    (pkgs.writeScriptBin "hello" ''
      #!${stdenv.shell}
      echo "Hi there"
    '')
  ];

  multiPkgs = pkgs: [
    (pkgs.writeScriptBin "oi" ''
      #!${stdenv.shell}
      echo "Oi!"
    '')
  ];
}
```

and spawning a shell `nix-shell example.nix` doesn't result to dropping into a
chrooted env with the provided pkgs installed.

Read [Using nix-shell for package development](https://nixos.wiki/wiki/Create_and_debug_nix_packages#Using_nix-shell_for_package_development)
for some pointers on how to build a package. In the case of example.nix, the
package simply contains a chrooted env which could be executing the following
steps

```
mkdir temp-out
export out=$(realpath temp-out)
set -x
genericBuild
```

keeping in mind that the `genericBuild` wreaks some havoc on the local
directory which makes it sensible to consider changing directories into
`temp-out` before calling `genericBuild` :wink:.

Running a nix-repl on the expression by running `nix-repl example.nix` drops us
into a REPL in which we could build the derrivation by running

```
:b out
```

which just build the example derivation `out` to produce

```
/nix/store/4xdiggrn75j92vsvk3ijbas3m9vr7jyk-example
└── bin
    └── example

1 directory, 1 file
```

which leads me to conclude that the `buildFHSUserEnv` helper just aids in
producing an executable which we could use to drop into a chrooted env. 

See [Android Studio implementation](https://github.com/NixOS/nixpkgs/blob/87b215d5f72cd51ea2b649e452c107c9e14f4abf/pkgs/applications/editors/android-studio/common.nix)
for an example of buildFHSUserEnv in use.

Apparently they specify a FHS env and subsequently use this env to call other
executables :bulb:.

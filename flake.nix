{
  description = "foo bar";

  outputs = { self, nixpkgs }: {
    devShells.x86_64-linux.default =
      let pkgs = import nixpkgs { system = "x86_64-linux"; };
      in pkgs.mkShell {
        buildInputs = [ pkgs.ncurses pkgs.sbcl ];
        LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ pkgs.ncurses ];
      };
  };
}

{ runCommand, hello2 }:

runCommand "hello2-test-run"
  {
    nativeBuildInputs = [ hello2 ];
  }
  ''
    diff -U3 --color=auto <(hello) <(echo 'Hello, world!')
    touch $out
  ''

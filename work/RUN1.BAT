rem --- Method 1: assemble, link, run, then DEBUG disassemble ---
masm hello;
link hello;
hello
debug hello.exe < dbg1.txt

# aIDE
A widget-based Ada IDE.

### Dependencies

- Libadalang
- GtkAda
- Florist
- aShell ~ https://github.com/charlie5/aShell.git


### Build

- $ cd aIDE/applet/aide
- $ export ADA_PROJECT_PATH=<path/to/aShell>:$ADA_PROJECT_PATH
- $ gprbuild -p -P aide.gpr -Xrestrictions=xgc -XOS=Linux

### Test

- $ cd test
- $ ln -s ../glade .
- $ ../launch_aide

 - Open the 'builder' expander (bottom left).
 - Click on 'build' button.
 - Close aIDE.


- $ ./launch_hello

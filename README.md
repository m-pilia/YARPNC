YARPNC - Yet Another RPN Calculator
===================================
YARPNC is a simple RPN scientific calculator written in Ada with a GtkAda interface.

Building YARPNC
===============
YARPNC is written with vim and GNAT GPS. The project requires an Ada compiler and GtkAda libraries. If you have GNAT installed in your machine, you can build the project launching on the project root folder one of the following commands:
```bash
gnatmake ./src/calc.adb
```
or:
```bash
gprbuild yarpnc.gpr
```

License 
=======
YARPNC is licensed under the GNU Public License v3. See [LICENSE](/LICENSE) file for details.

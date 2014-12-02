YARPNC - Yet Another RPN Calculator
===================================
YARPNC is a simple RPN scientific calculator written in Ada with a 
GtkAda interface.

![Screenshot](http://i1383.photobucket.com/albums/ah312/m-programmer/yarpnc_zpsc2534419.png)

Build
===============
YARPNC is written with vim. The project requires an Ada compiler and GtkAda 
libraries. If you have GNAT installed on your machine, then you can build the
project launching on the project root folder one of the following commands:
```bash
gnatmake ./src/calc.adb
```
or:
```bash
gprbuild yarpnc.gpr
```

To generate the documentation launch:
```bash
gnatdoc -p ./yarpnc.gpr
```

License 
=======
YARPNC is licensed under the GNU Public License v3. See [LICENSE](/LICENSE)
file for details.

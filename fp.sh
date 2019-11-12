bison -d -o fp.tab.c fp.y
g++ -c -g -I.. fp.tab.c
flex -o fp.yy.c fp.l
g++ -c -g -I.. fp.yy.c
g++ -o fp fp.tab.o fp.yy.o -ll

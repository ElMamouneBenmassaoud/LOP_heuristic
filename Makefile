CC=gcc
CFLAGS=-O3 -Wall

OBJECTS=src/instance.o src/main.o src/optimization.o src/timer.o src/utilities.o

.PHONY: clean

all: lop

lop: $(OBJECTS)
	$(CC) $(CFLAGS) $(OBJECTS) -o lop

clean:
	rm -f src/*~ src/*.o lop

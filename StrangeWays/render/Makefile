CXXFLAGS=-I /opt/local/include
CXXFLAGS+=-pthread
CXXFLAGS+=-g
CXXFLAGS+=-DNDEBUG
CXXFLAGS+=-march=native
CXXFLAGS+=-ffast-math

compile:
	g++ -std=c++11 ${CXXFLAGS} -Wall render.cpp -O3  -o render 
run_long: compile
	./render ../saves/blade.dump 10000000 && display file.ppm
run: compile
	./render ../saves/blade.dump ${ITERATIONS} && display file.ppm
run_long_long: compile
	./render ../saves/blade.dump 100000000000



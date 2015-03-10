CXXFLAGS=-I /opt/local/include
CXXFLAGS+=-pthread
run:
	g++ -std=c++11 ${CXXFLAGS} -Wall render.cpp -O3  -o render && ./render ../saves/blade.dump
run_long:
	g++ -std=c++11 ${CXXFLAGS} -Wall render.cpp -O3  -o render && ./render ../saves/blade.dump 10000000000



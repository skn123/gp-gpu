CXX=g++
CXXFLAGS=-std=c++11 -O3
CUDA_INC=/usr/local/cuda/include

libgp.a: optim.o cov.o
	ar rcs libgp.a cov.o optim.o

optim.o: optim.cpp optim.hpp gp.hpp
	$(CXX) $(CXXFLAGS) -c optim.cpp -lnlopt

cov.o: cov.cpp cov.hpp
	$(CXX) $(CXXFLAGS) -c cov.cpp

test: libgp.a test.cpp
	$(CXX) $(CXXFLAGS) test.cpp -o test -L.  -lgp -lnlopt -lblas -llapack -larmadillo

gp_train: libgp.a gp_train.cpp
	$(CXX) $(CXXFLAGS) gp_train.cpp -o gp_train -L. -lgp -lnlopt -lblas -llapack -larmadillo -lconfig++

gp_gpu_example: libgp.a gp_gpu.hpp gp_gpu_example.cpp cov_gpu.o
	$(CXX) $(CXXFLAGS) -I$(CUDA_INC) gp_gpu_example.cpp -o gp_gpu_example cov_gpu.o -L. -lgp -lnlopt -lblas -llapack -larmadillo -lconfig++ -lcublas -lcudart

cov_gpu_test: cov_gpu_test.cu cov_gpu.o
	nvcc $(CXXFLAGS) cov_gpu_test.cu -o cov_gpu_test cov_gpu.o -L. -lgp -lnlopt -lblas -llapack -larmadillo -lconfig++ -lcublas -lcudart

cov_gpu.o: cov_gpu.cu cov_gpu.hpp
	nvcc $(CXXFLAGS) -c cov_gpu.cu

benchmark: libgp.a benchmark.cpp gp_gpu.hpp cov_gpu.hpp cov_gpu.o state.o matrix-util.o
	$(CXX) $(CXXFLAGS) -fopenmp -I$(CUDA_INC) benchmark.cpp -o benchmark cov_gpu.o state.o matrix-util.o -L. -L/home/raid/ots22/lib/ -L$(CUDA_LIB) -lgp -lblas -llapack -larmadillo -lcublas -lcudart


#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <iostream>
#include <fstream>
#include <string>
using namespace std;
ifstream fi("Data.txt");
ofstream fo("Ans.txt");
string s1, s2;
int ans = 0;
//
//__device__ int* d_arrayA;
//int* h_arrayA;

__global__ void cube(float * d_out, float * d_in) {
	// Todo: Fill in this function
	int idx = threadIdx.x;
	float f = d_in[idx];
	d_out[idx] = f * f * f;
	//d_arrayA[idx] = f * f * f;
}

int main(void) {
	//int a, b, c;
	//int *d_a, *d_b, *d_c;
	//int size = sizeof(int);

	////allocate space for device copies
	//cudaMalloc((void **)&d_a, size);

	/*getline(fi, s1);
	getline(fi, s2);
	cout << "input:\n";
	cout << s1 << "\n" << s2;
	cout << "\nprocsess .....";
	for (int i = 0; i<s1.size(); ++i)
	{
		if (s1[i] != s2[i]) ans++;
	}
	cout << "\nans: " << ans << "\n";*/


	const int ARRAY_SIZE = 96;
	const int ARRAY_BYTES = ARRAY_SIZE * sizeof(float);

	// generate the input array on the host
	float h_in[ARRAY_SIZE];
	for (int i = 0; i < ARRAY_SIZE; i++) {
		h_in[i] = float(i);
	}
	float h_out[ARRAY_SIZE];

	// declare GPU memory pointers
	float * d_in;
	float * d_out;

	// allocate GPU memory
	cudaMalloc((void**)&d_in, ARRAY_BYTES);
	cudaMalloc((void**)&d_out, ARRAY_BYTES);

	// transfer the array to the GPU
	cudaMemcpy(d_in, h_in, ARRAY_BYTES, cudaMemcpyHostToDevice);

	// launch the kernel
	cube << <1, ARRAY_SIZE >> >(d_out, d_in);

	// copy back the result array to the CPU
	cudaMemcpy(h_out, d_out, ARRAY_BYTES, cudaMemcpyDeviceToHost);

	// print out the resulting array
	for (int i = 0; i < ARRAY_SIZE; i++) {
		printf("%f", h_out[i]);
		printf(((i % 4) != 3) ? "\t" : "\n");
	}

	/*cudaMalloc(&h_arrayA, 12000 * sizeof(int));
	if ( cudaMemcpyToSymbol(d_arrayA, &h_arrayA, sizeof(h_arrayA) ) == cudaSuccess ) {
		cout << " copy du lieu thanh cong" << endl;
	}
	if (cudaMemcpyFromSymbol(&h_arrayA, d_arrayA, sizeof(h_arrayA)) == cudaSuccess) {
		cout << " copy du lieu thanh cong" << endl;
	}
	cout << &h_arrayA << endl;
	cudaFree(d_arrayA);*/
	cudaFree(d_in);
	cudaFree(d_out);

	return 0;
}
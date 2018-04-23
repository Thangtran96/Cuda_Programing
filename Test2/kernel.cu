
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include<iostream>
#include <stdio.h>


using namespace std;

struct d_Motif
{
	int dis;
	int *loc;
};

struct h_Motif
{
	int dis;
	int loc[40];
};
__global__ void forKernel(int *a,int *b, d_Motif *c)
{
	//printf("a: %d | b: %d \n", a[0], b[0]);
	//10000005
	for (int i = 0; i < 105; ++i) {
		a[0] += b[0];
	}
	/*c[0].dis = 100;
	for (int i = 0; i < 20; ++i) {
		c[0].loc[i] = i;
	}*/
}

const size_t Array_byte = 3 * sizeof(int);

int main()
{
	int h_a[3] = { 0,1,2 }, h_b[3] = { 1,2,3 };
	cout << h_a[0] << " " << h_b[0] << endl;
	int *d_a, *d_b;
	if (cudaMalloc(&d_a, Array_byte) != cudaSuccess) {
		cout << "error allocating memory!" << endl;
		return 0;
	}
	if (cudaMalloc(&d_b, Array_byte)!= cudaSuccess) {
		cout << "error allocating memory!" << endl;
		cudaFree(d_a);
		return 0;
	}
	d_Motif *h_c;
	size_t sizeMotif = 2 * 41 * sizeof(int);
	d_Motif *d_c;
	if (cudaMalloc(&d_c, sizeMotif) != cudaSuccess) {
		cout << "Error allocating memory struct!" << endl;
		cudaFree(d_a);
		cudaFree(d_b);
		return 0;
	}
	if ( cudaMemcpy(d_a,h_a,Array_byte,cudaMemcpyHostToDevice) != cudaSuccess) {
		cout << "error copying memory!3"<<endl;
		cudaFree(d_a);
		cudaFree(d_b);
		cudaFree(d_c);
		return 0;
	}
	if ( cudaMemcpy(d_b, h_b, Array_byte, cudaMemcpyHostToDevice) != cudaSuccess) {
		cout << "error copying memory!2" << endl;
		cudaFree(d_a);
		cudaFree(d_b);
		cudaFree(d_c);
		return 0;
	}
	if (cudaMemcpy(d_c,h_c,sizeMotif,cudaMemcpyHostToDevice) != cudaSuccess) {
		cout << "error copying memory! struct!" << endl;
		cudaFree(d_a);
		cudaFree(d_b);
		cudaFree(d_c);
		return 0;
	}

	forKernel<<<1, 1>>>(d_a, d_b, d_c);


	if (cudaMemcpy(h_a,d_a,Array_byte,cudaMemcpyDeviceToHost) != cudaSuccess) {
		cout << "error copying memory!1" << endl;
		cudaFree(d_a);
		cudaFree(d_b);
		cudaFree(d_c);
		return 0;
	}
	if (cudaMemcpy(h_c, d_c, sizeMotif, cudaMemcpyDeviceToHost) != cudaSuccess) {
		cout << "Error copying memory!" << endl;
		cudaFree(d_a);
		cudaFree(d_b);
		cudaFree(d_c);
		return 0;
	}
	cout << "adding 1 to 0 :" << h_a[0] << endl;
	//cout << "struct: " << *(h_c[0].dis) << " loc: " << *(h_c[0]->loc);
	int temp = h_c->dis;
	cout << "struct: " << temp ;

	cudaFree(d_a);
	cudaFree(d_b);
	cudaFree(d_c);
	cudaDeviceReset();
    return 0;
}



#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>

#define N 5

__device__ float add_func(float x, float y)
{
	return x + y;
}

__device__ float mul_func(float x, float y)
{
	return x * y;
}

__device__ float div_func(float x, float y)
{
		return x / y;

}

typedef float(*op_func) (float, float);

__device__ op_func func[3] = { add_func, mul_func, div_func };
__device__ char* op_name[3] = { "add", "mul", "div" };


__device__ void op_array(const float *a, const float *b, float *res, int op, int n)
{
	for (int i = 0; i < N; i++) {
		res[i] = func[op](a[i], b[i]);
	}	
}

__global__ void kernel(void)
{

	float x[N];
	float y[N];
	float res[N];

	for (int i = 0; i < N; i++) {
		x[i] = (float)(10 + i);
	}
	for (int i = 0; i < N; i++) {
		y[i] = (float)(100 + i);
	}

	for (int op = 0; op < 3; op++) {
		printf("\nop=%s\n", op_name[op]);
		op_array(x, y, res, op, N);
		for (int i = 0; i < N; i++) {
			printf("res = % 16.9e\n", res[i]);
		}
	}
}



int main(void)
{
	kernel << <1, 1 >> > ();
	cudaThreadSynchronize();
	return EXIT_SUCCESS;
}
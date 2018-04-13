
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <iostream>
#include <fstream>
#include <string>
#include <string.h>
#include <vector>
#include <utility>
using namespace std;
const int ARRAY_SIZE = 12005;
const int ARRAY_BYTES_INT = ARRAY_SIZE * sizeof(int);

//Host memory
int l, d;
int h_dataMotif[ARRAY_SIZE];

//nhap tu file va chuyen sang kieu int
void File_Input()
{
	l = 9; d = 2;
	char temp[ARRAY_SIZE];
	FILE * pFile;
	pFile = fopen("datacu.txt", "r");
	if (pFile == NULL)
		perror("Error opening file");
	else
	{
		if (fgets(temp, ARRAY_SIZE, pFile) != NULL)
			cout << "nhap du lieu thanh cong!\n";
		fclose(pFile);
	}

	for (int i = 0; i < strlen(temp); ++i) {
		//A=0 C=1 G=2 T=3
		switch (temp[i])
		{
		case 'A':{ h_dataMotif[i] = 0; break;}
		case 'C': { h_dataMotif[i] = 1; break; }
		case 'G': { h_dataMotif[i] = 2; break; }
		case 'T': { h_dataMotif[i] = 3; break; }
		default: cout << "error chuyen sang int";
			break;
		}
	}
}

//code dis_haming gpu
__device__ int dis_haming(const int* d_datainp, const int* s1, const int l) {
	//printf("\n dis_ham %d %d", s1, l);
	int ans = 0;
	int temp, tempRow;
	for (int i = 0; i<20; ++i)
	{
		tempRow = 999;
		for (int j = i*600; j < (i+1)*600 - l; ++j)
		{
			temp = 0;
			for (int k = 0; k < l; k++) {
				if (s1[k] != d_datainp[k + j]) temp++;
			}
			if (temp < tempRow) tempRow = temp;
		}
		ans += tempRow;
	}
	//printf("device code %d", ans);
	return ans;
}

//code best nay
__device__ int* bestNeighbor(const int* d_datainp, const int* s1, const int l) {
	for (int i = 0; i < l; ++i) {
	}
}

//code ham chinh goi
__global__ void patternBarching(const int* d_datainp, const int l, const int d) {
	int index = blockDim.x * blockIdx.x + threadIdx.x ;
	int ans = 0;
	printf("\n thread chay %d %d %d", index, l, d);
	if (index < 600 - l) {
		int motif[40];
		for (int i = 0; i < l; ++i) {
			motif[i] = d_datainp[index + i];
		}
		printf("gia tri 1 trong %d \n", d_datainp[1]);
		ans = dis_haming(d_datainp, motif, l);
		printf("dis motif %d", ans);
	}
}


int main() {
	File_Input();
	cout << h_dataMotif[1];
	int* d_datainp;
	if (cudaMalloc(&d_datainp, ARRAY_BYTES_INT) == cudaSuccess)
		cout << "\n Khai bao thanh cong\n";
	if (cudaMemcpy(d_datainp, h_dataMotif, ARRAY_BYTES_INT, cudaMemcpyHostToDevice) == cudaSuccess)
		cout << "\n copy thanh cong\n";

	patternBarching <<< 1, 1 >>> (d_datainp, l, d);
	
	//cudaMemcpy(h_datainp, d_datainp, ARRAY_BYTES, cudaMemcpyDeviceToHost);
	cudaFree(d_datainp);

	return 0;
}



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
const int ARRAY_SIZE_MOTIF = 601;
const int ARRAY_BYTES_MOTIF = ARRAY_SIZE_MOTIF * ( sizeof(int) + ( 40 * sizeof(int) ) );

typedef struct {
	int dis;// dis_Haming
	int* motif;//str_motif[40]
}MOTIF;

//Host memory
int l, d;
int h_dataMotif[12005];
int* d_datainp;
MOTIF h_motif[602];
MOTIF* d_motif;

//device memory

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
		case 'A': { h_dataMotif[i] = 0; break; }
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
	for (int i = 0; i < 20; ++i)
	{
		tempRow = 999;
		for (int j = i * 600; j < (i + 1) * 600 - l; ++j)
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
//__device__ int bestNeighbor(const int* d_datainp, int* s1, const int l) {
//	int temp_val;
//	int temp_dis;
//	int best_dis = 99999;
//	int motif[40];
//	int ans = 0;
//	printf("\nbestNeighbor\n");
//	for (int i = 0; i < l; ++i) {
//		//trg hop 0
//		if (s1[i] != 0) {
//			temp_val = s1[i];
//			s1[i] = 0;
//			temp_dis = dis_haming(d_datainp, s1, l);
//			s1[i] = temp_val;
//			//lay best neighbor
//			if (temp_dis < best_dis)
//			{
//				best_dis = temp_dis;
//				for (int j = 0; j < l; ++j) {
//					motif[j] = s1[j];
//				}
//			}
//		}
//		//trg hop 1
//		if (s1[i] != 1) {
//			temp_val = s1[i];
//			s1[i] = 1;
//			temp_dis = dis_haming(d_datainp, s1, l);
//			s1[i] = temp_val;
//			//lay best neighbor
//			if (temp_dis < best_dis)
//			{
//				best_dis = temp_dis;
//				for (int j = 0; j < l; ++j) {
//					motif[j] = s1[j];
//				}
//			}
//		}
//		//trg hop 2
//		if (s1[i] != 2) {
//			temp_val = s1[i];
//			s1[i] = 2;
//			temp_dis = dis_haming(d_datainp, s1, l);
//			s1[i] = temp_val;
//			//lay best neighbor
//			if (temp_dis < best_dis)
//			{
//				best_dis = temp_dis;
//				for (int j = 0; j < l; ++j) {
//					motif[j] = s1[j];
//				}
//			}
//		}
//		//trg hop 3
//		if (s1[i] != 3) {
//			temp_val = s1[i];
//			s1[i] = 3;
//			temp_dis = dis_haming(d_datainp, s1, l);
//			s1[i] = temp_val;
//			//lay best neighbor
//			if (temp_dis < best_dis)
//			{
//				best_dis = temp_dis;
//				for (int j = 0; j < l; ++j) {
//					motif[j] = s1[j];
//				}
//			}
//		}
//	}
//	// chuan bi trc khi tra kq
//	int k = 0;
//	for (int i = 0; i < l; ++i) {
//		ans = ans ^ (motif[i] << k);
//		k += 2;
//	}
//	return ans;
//	printf("ans %d \n", ans);
//}

//code ham chinh goi
__global__ void patternBarching(const int* d_datainp, const int l, const int d, MOTIF* d_motif) {
	int index = blockDim.x * blockIdx.x + threadIdx.x;
	if (index < 600 - l) {
		//khai bao bien
		int motif_temp[40];
		int temp_val;
		int temp_dis;
		int best_dis = 99999;
		int motif_bN[40];
		int score_motif;
		
		//lay chuoi can duyet
		for (int i = 0; i < l; ++i) {
			motif_temp[i] = d_datainp[i + index];
			motif_bN[i] = motif_temp[i];
		}
		printf("\n 1 \n");
		score_motif = dis_haming(d_datainp, motif_temp, l);
		//ham dis_hamming
		//int ans = 0;
		//int temp, tempRow;
		//for (int i = 0; i < 20; ++i)
		//{
		//	tempRow = 999;
		//	for (int j = i * 600; j < (i + 1) * 600 - l; ++j)
		//	{
		//		temp = 0;
		//		for (int k = 0; k < l; k++) {
		//			if (s1[k] != d_datainp[k + j]) temp++;
		//		}
		//		if (temp < tempRow) tempRow = temp;
		//	}
		//	ans += tempRow;
		//}
		//printf("device code %d", ans);

		//chay ham patternBarching
		for (int k = 0; k < d; ++k) {
			//kiem tra chuoi tot
			printf("\n 2 \n");
			if (best_dis < score_motif) {
				score_motif = best_dis;
				for (int i = 0; i < l; ++i) {
					motif_temp[i] = motif_bN[i];
				}
			}
			//ham bestNeighbor
			printf("\nbestNeighbor\n");
			for (int i = 0; i < l; ++i) {
				printf("\n 3 \n");
				//trg hop 0
				if (motif_temp[i] != 0) {
					temp_val = motif_temp[i];
					motif_temp[i] = 0;
					temp_dis = dis_haming(d_datainp, motif_temp, l);
					//lay best neighbor
					if (temp_dis < best_dis)
					{
						best_dis = temp_dis;
						for (int j = 0; j < l; ++j) {
							motif_bN[j] = motif_temp[j];
						}
					}
					motif_temp[i] = temp_val;
				}
				//trg hop 1
				if (motif_temp[i] != 1) {
					temp_val = motif_temp[i];
					motif_temp[i] = 1;
					temp_dis = dis_haming(d_datainp, motif_temp, l);
					//lay best neighbor
					if (temp_dis < best_dis)
					{
						best_dis = temp_dis;
						for (int j = 0; j < l; ++j) {
							motif_bN[j] = motif_temp[j];
						}
					}
					motif_temp[i] = temp_val;
				}
				//trg hop 2
				if (motif_temp[i] != 2) {
					temp_val = motif_temp[i];
					motif_temp[i] = 2;
					temp_dis = dis_haming(d_datainp, motif_temp, l);
					//lay best neighbor
					if (temp_dis < best_dis)
					{
						best_dis = temp_dis;
						for (int j = 0; j < l; ++j) {
							motif_bN[j] = motif_temp[j];
						}
					}
					motif_temp[i] = temp_val;
				}
				//trg hop 3
				if (motif_temp[i] != 3) {
					temp_val = motif_temp[i];
					motif_temp[i] = 3;
					temp_dis = dis_haming(d_datainp, motif_temp, l);
					//lay best neighbor
					if (temp_dis < best_dis)
					{
						best_dis = temp_dis;
						for (int j = 0; j < l; ++j) {
							motif_bN[j] = motif_temp[j];
						}
					}
					motif_temp[i] = temp_val;
				}
			}
			// END ham bestNeighbor
		}
		printf("\n 4 \n");
		//du lieu tra lai
		printf("\n gan du lieu vao d_motif \n");
		d_motif[index].dis = score_motif;
		printf("\n d_ motif: dis = %d", d_motif[index].dis);
		for (int i = 0; i < l; ++i) {
			d_motif[index].motif[i] = motif_temp[i];
		}

		/*for (int k = 0; k <= d; k++)
		{
			i_temp = dis_hamming(a);
			fo << i_temp << " " << bestScore << endl;
			if (i_temp < bestScore)
			{
				cout << "Change ";
				cout << a << " " << i_temp << " || ";
				f = a;
				bestScore = i_temp;
			}
			a = bestNeighbor(a);
		}*/
	}
}


int main() {
	File_Input();
	//cout << h_dataMotif[1];	
	if (cudaMalloc(&d_datainp, ARRAY_BYTES_INT) != cudaSuccess)
		cout << "\n Khai bao ko thanh cong\n";
	if (cudaMemcpy(d_datainp, h_dataMotif, ARRAY_BYTES_INT, cudaMemcpyHostToDevice) != cudaSuccess)
		cout << "\n copy ko thanh cong\n";
	
	if (cudaMalloc(&d_motif, ARRAY_BYTES_MOTIF) != cudaSuccess) {
		cout << "\n khai bao ko thanh cong d_motif\n";
	}
	//chay gpu
	patternBarching <<< 1, 1 >>> (d_datainp, l, d, d_motif);
	//cudaMemcpy(h_datainp, d_datainp, ARRAY_BYTES, cudaMemcpyDeviceToHost);
	if (cudaMemcpy(h_motif, d_motif, ARRAY_BYTES_MOTIF, cudaMemcpyDeviceToHost) != cudaSuccess)
		cout << "\n ko copy dc data sang host" << endl;
	//cout << h_motif[0].dis << h_motif[0].motif[1];
	cudaFree(d_datainp);
	cudaFree(d_motif);

	return 0;
}


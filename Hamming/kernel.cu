
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
using namespace std;
ifstream fi("Data.txt");
ofstream fo("Ans.txt");

string DataInp[35];

typedef pair <int, string> pis;
typedef vector < pis > vpis;
string dataMotif[35];
int l, d;
__device__ vpis dataAns;

void ReadFileData()
{
	int temp; string s;
	fi >> temp; //cout << temp;
	for (int i = 1; i < 21; ++i) {
		//if (i % 2 == 0) continue;
		fi >> s;
		DataInp[i] = s;
	}
}

void OutFileAns(string s[100], int x) {
	for (int i = 0; i < x; i++) fo << ">Sequence" << i << endl << s[i] << endl ;
}

//int Haming(string s1, string s2) {
//	int res = 0;
//	for (int i = 0; i<s1.size(); ++i)
//	{
//		if (s1[i] != s2[i]) res++;
//	}
//	return res;
//}

__device__ int min_dis_ham;
__global__ string d_data[35];

__global__ void dis_haming(string *s) {
	int res_Sum = 0, temp_score = 999;
	for (int i = 1; i<=20; ++i)
	{
		string s1 = d_data[i];
		temp_score = 999;
		for (int j = 0; j < s1.size() - l + 1; ++j)
		{
			string temp_str = s1.substr(j, l);
			int score_lmer = 0;
			for (int k = 0; i < temp_str.size(); ++i) {
				if (s[i] != temp_str[i]) score_lmer++;
			}
			temp_score = score_lmer
		}
		res_Sum += temp_score;
	}
	min_dis_ham = res_Sum;
}

__global__ void paternbracnching( const int *l, const int *d)
{
	int index = blockIdx.x * blockDim.x + threadIdx.x;
	int size_str = d_data[1].size();
	if (index < size_str - l)
	{
		string motif_f = d_data[1][index];

	}
}

int main()
{
	ReadFileData();
	/*OutFileAns(DataInp,20);
	vector<string> motifVector;
	string motif = DataInp[0].substr(0, 9);
	cout << "motif arbitrary " << motif << endl;
	for (int j = 0; j < 20; ++j) {
		for (int i = 1; i < DataInp[j].size() - l - 1; i++)
		{
			string motifTemp = DataInp[0].substr(i, l);
			int sroce = Haming(motif, motifTemp); fo << motifTemp << " " << sroce << endl;
			if (sroce < d) motifVector.push_back(motifTemp);
		}
		for (int it = 0; it < motifVector.size(); ++it)
		{
			cout << motifVector[it] << endl;
		}
	}*/
	/*for (int i = 1; i < DataInp[0].size() - l - 1; i++)
	{
		string motifTemp = DataInp[0].substr(i, l);
		int sroce = Haming(motif, motifTemp); fo << motifTemp << " " << sroce << endl;
		if (sroce < d) motifVector.push_back(motifTemp);
	}
	for (int it = 0; it < motifVector.size(); ++it)
	{
		cout << motifVector[it] << endl;
	}*/
    return 0;
}


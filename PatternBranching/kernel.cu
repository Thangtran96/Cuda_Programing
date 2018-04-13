#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <utility>
using namespace std;
ifstream fi("Data.txt");
ofstream fo("Ans.txt");

typedef pair <int, string> pis;
typedef vector < pis > vpis;

typedef pair <int, vector<int> > piv;
typedef pair < string, piv > pspiv;

//Host 
string h_DataInp[23];
int h_l, h_d;
vector<string> h_motif;

//Device
__device__ char d_datainp[23][650];
__device__ int d_l;
__device__ int d_d;

//chuoi khoi tao chuoi s0 de chay 20 luong, chay hamming tren 20 luong

__device__ int score_ham(char *s1, char *s2, )
{
	int res = 0;
	for (int i = 0; i < s1.size(); ++i) if (s1[i] != s2[i]) res++;
	return res;
}

__device__ int dis_Haming(string s, string *d_DataInp, int d_l)
{
	int res_Sum = 0, temp_score = 999;
	for (int i = 0; i < 20; ++i)
	{
		string s1 = d_DataInp[i];
		temp_score = 999;
		for (int j = 0; j < s1.size() - d_l + 1; ++j)
		{
			string temp_str = s1.substr(j, d_l);
			int score_s = score_ham(s, temp_str);
			if (temp_score > score_s)
			{
				temp_score = score_s;
			}
		}
		res_Sum += temp_score;
	}
	return res_Sum;
}

__device__ string bestNeighbor(string s, string *d_DataInp, int d_l)
{
	string temp_str = ""; //ATCG
	string ans;
	int diem = 999;
	int temp_dis;
	for (int i = 0; i < s.size(); ++i)
	{
		if (i == 0)
		{
			if (s[i] != 'A')
			{
				temp_str = 'A' + s.substr(1, s.size() - 1);
				temp_dis = dis_Haming(temp_str, d_DataInp, d_l);
				if (temp_dis <= diem) { 
					diem = temp_dis; 
					ans = temp_str;
				}
			}
			if (s[i] != 'T')
			{
				temp_str = 'T' + s.substr(1, s.size() - 1);
				temp_dis = dis_Haming(temp_str, d_DataInp, d_l);
				if (temp_dis <= diem) {
					diem = temp_dis;
					ans = temp_str;
				}
			}
			if (s[i] != 'G')
			{
				temp_str = 'G' + s.substr(1, s.size() - 1);
				temp_dis = dis_Haming(temp_str, d_DataInp, d_l);
				if (temp_dis <= diem) {
					diem = temp_dis;
					ans = temp_str;
				}
			}
			if (s[i] != 'C')
			{
				temp_str = 'C' + s.substr(1, s.size() - 1);
				temp_dis = dis_Haming(temp_str, d_DataInp, d_l);
				if (temp_dis <= diem) {
					diem = temp_dis;
					ans = temp_str;
				}
			}
			continue;
		}
		if (i == s.size() - 1)
		{
			if (s[i] != 'A')
			{
				temp_str = s.substr(0, s.size() - 1) + 'A';
				temp_dis = dis_Haming(temp_str, d_DataInp, d_l);
				if (temp_dis <= diem) {
					diem = temp_dis;
					ans = temp_str;
				}
			}
			if (s[i] != 'T')
			{
				temp_str = s.substr(0, s.size() - 1) + 'T';
				temp_dis = dis_Haming(temp_str, d_DataInp, d_l);
				if (temp_dis <= diem) {
					diem = temp_dis;
					ans = temp_str;
				}
			}
			if (s[i] != 'G')
			{
				temp_str = s.substr(0, s.size() - 1) + 'G';
				temp_dis = dis_Haming(temp_str, d_DataInp, d_l);
				if (temp_dis <= diem) {
					diem = temp_dis;
					ans = temp_str;
				}
			}
			if (s[i] != 'C')
			{
				temp_str = s.substr(0, s.size() - 1) + 'C';
				temp_dis = dis_Haming(temp_str, d_DataInp, d_l);
				if (temp_dis <= diem) {
					diem = temp_dis;
					ans = temp_str;
				}
			}
			break;
		}
		if (s[i] != 'A')
		{
			temp_str = s.substr(0, i) + 'A' + s.substr(i + 1, s.size() - i);
			temp_dis = dis_Haming(temp_str, d_DataInp, d_l);
			if (temp_dis <= diem) {
				diem = temp_dis;
				ans = temp_str;
			}
		}
		if (s[i] != 'T')
		{
			temp_str = s.substr(0, i) + 'T' + s.substr(i + 1, s.size() - i);
			temp_dis = dis_Haming(temp_str, d_DataInp, d_l);
			if (temp_dis <= diem) {
				diem = temp_dis;
				ans = temp_str;
			}
		}
		if (s[i] != 'G')
		{
			temp_str = s.substr(0, i) + 'G' + s.substr(i + 1, s.size() - i);
			temp_dis = dis_Haming(temp_str, d_DataInp, d_l);
			if (temp_dis <= diem) {
				diem = temp_dis;
				ans = temp_str;
			}
		}
		if (s[i] != 'C')
		{
			temp_str = s.substr(0, i) + 'C' + s.substr(i + 1, s.size() - i);
			temp_dis = dis_Haming(temp_str, d_DataInp, d_l);
			if (temp_dis <= diem) {
				diem = temp_dis;
				ans = temp_str;
			}
		}
	}
	return ans;
}

void init_motif()
{
	string temp = "";
	for (int i = 0; i < h_DataInp[0].size() - h_l; ++i)
	{
		temp = h_DataInp[0].substr(i, h_l);
		h_motif.push_back(temp);
	}
}

void File_Input()
{
	fi >> h_l >> h_d;
	fi.ignore();
	for (int i = 0; i<20; ++i)
	{
		getline(fi, h_DataInp[i]);
	}
}

int main(void)
{
	File_Input();
	init_motif();
	cout << h_motif.size() << endl;
	return 0;
}


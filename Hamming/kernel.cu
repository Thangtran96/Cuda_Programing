
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

string DataInp[100];
string DataAns[100];

void ReadFileData()
{
	int temp; string s;
	fi >> temp; //cout << temp;
	for (int i = 0; i < temp; ++i) {
		//if (i % 2 == 0) continue;
		fi >> s;
		DataInp[i] = s;
	}
}

void OutFileAns(string s[100], int x) {
	for (int i = 0; i < x; i++) fo << ">Sequence" << i << endl << s[i] << endl ;
}

int Haming(string s1, string s2) {
	int res = 0;
	for (int i = 0; i<s1.size(); ++i)
	{
		if (s1[i] != s2[i]) res++;
	}
	return res;
}

int main()
{
	ReadFileData();
	OutFileAns(DataInp,20);
	int l = 9, d = 2;
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
	}
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


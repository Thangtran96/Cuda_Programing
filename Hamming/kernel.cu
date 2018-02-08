
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <iostream>
#include <fstream>
#include <string>
using namespace std;
ifstream fi("Data.txt");
ofstream fo("Ans.txt");
string h_s1, h_s2;
int ans = 0;

__global__ 

int main()
{
	getline(fi, h_s1);
	getline(fi, h_s2);


    return 0;
}


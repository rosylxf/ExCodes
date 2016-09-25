//
//  main.cpp
//  多态
//
//  Created by ricky on 9/12/16.
//  Copyright © 2016 ricky. All rights reserved.
//

#include <iostream>
using namespace std;

class B0
{
public:
    int nv;
    void fun(){cout<<"Member of B0"<<endl;}
};

class B1:virtual public B0
{
public:
    int nv1;
};

class B2:virtual public B0
{
public:
    int nv2;
};

class D1 : public B1, public B2
{
public:
    int nvd;
    void fund(){cout<<"Member of D1"<<endl;}
};

int main(int argc, const char * argv[]) {
    
    
    D1 d1;
    d1.nv = 2;
    d1.fun();  //output: Member of B0
    
    
    cout << "Hello, World!\n";
    return 0;
}

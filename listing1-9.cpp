// listing 1-9
//
//  A simple C++ program that demonstrates Microsoft C++ data 
// type sizes:


#include <stdio.h>


int main(void)
{
        char                v1;
        unsigned char       v2;
        short               v3;             
        short int           v4;
        short unsigned      v5;    
        int                 v6;               
        unsigned            v7;          
        long                v8;              
        long int            v9;          
        long unsigned       v10;     
        long long int       v11;     
        long long unsigned  v12;
        __int64_t           v13;           
        __uint64_t          v14;  
        float               v15;             
        double              v16;            
        void *              v17;           

    printf
    (
        "Size of char:               %2zd\n"
        "Size of unsigned char:      %2zd\n"
        "Size of short:              %2zd\n"
        "Size of short int:          %2zd\n"
        "Size of short unsigned:     %2zd\n"
        "Size of int:                %2zd\n"
        "Size of unsigned:           %2zd\n"
        "Size of long:               %2zd\n"
        "Size of long int:           %2zd\n"
        "Size of long unsigned:      %2zd\n"
        "Size of long long int:      %2zd\n"
        "Size of long long unsigned: %2zd\n"
        "Size of __int64_t:          %2zd\n"
        "Size of __uint64_t:         %2zd\n"
        "Size of float:              %2zd\n"
        "Size of double:             %2zd\n"
        "Size of pointer:            %2zd\n",
        sizeof v1,
        sizeof v2,
        sizeof v3,
        sizeof v4,
        sizeof v5,
        sizeof v6,
        sizeof v7,
        sizeof v8,
        sizeof v9,
        sizeof v10,
        sizeof v11,
        sizeof v12,
        sizeof v13,
        sizeof v14,
        sizeof v15,
        sizeof v16,
        sizeof v17
    );            
}
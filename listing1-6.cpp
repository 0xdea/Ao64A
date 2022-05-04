// listing 1-6
//
// C++ driver program to demonstrate calling printf from assembly 
// language.
//
// Need to include stdio.h so this program can call "printf".

#include <stdio.h>

// extern "C" namespace prevents "name mangling" by the C++
// compiler.

extern "C"
{
    // Here's the external function, written in assembly 
	// language, that this program will call:
    
    void asmFunc( void );
};

int main(void)
{
    // Need at least one call to printf in the C program to allow 
	// calling it from assembly.
    
    printf( "Calling asmFunc:\n" );
    asmFunc();
    printf( "Returned from asmFunc\n" );
}
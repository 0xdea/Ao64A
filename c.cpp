// c.cpp
//
// Generic C++ driver program to demonstrate returning function
// results from assembly language to C++. Also includes a
// "readLine" function that reads a string from the user and 
// passes it on to the assembly language code.
//
// Need to include stdio.h so this program can call "printf" 
// and stdio.h so this program can call strlen.

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// extern "C" namespace prevents "name mangling" by the C++
// compiler.

extern "C"
{
    // asmMain is the assembly language code's "main program":
        
    void asmMain( void );
    
    // getTitle returns a pointer to a string of characters 
	// from the assembly code that specifies the title of that 
	// program (that makes this program generic and usable
    // with a large number of sample programs in "The Art of 
	// 64-bit Assembly Language."
    
    char *getTitle( void );
    
    // C++ function that the assembly
    // language program can call:
    
    int readLine( char *dest, int maxLen );

    // Special function to retrieve the GCC/stdlib
    // errno "global" from thread local storage
    // and return it to an assembly program:

    int getErrno( void );
    
};

// The C stdlib "errno" variable isn't guaranteed to be
// a variable at all. Therefore, it is often difficult
// to access this C stdlib function return value from
// an assembly language program. The following function
// fixes that problem by retrieving errno in C and
// returning its value as a function result

int getErrno( void )
{
        return errno;
}

// readLine reads a line of text from the user (from the 
// console device) and stores that string into the destination 
// buffer the first argument specifies. Strings are limited in 
// length to the value specified by the second argument 
// (minus 1).
// 
// This function returns the number of characters actually 
// read, or -1 if there was an error.
//
// Note that if the user enters too many characters (maxlen or 
// more) then this function only returns the first maxlen-1
// characters. This is not considered an error.

int readLine( char *dest, int maxLen )
{
    // Note: fgets returns NULL if there was an error, else 
	// it returns a pointer to the string data read (which 
	// will be the value of the dest pointer).
    
    char *result = fgets( dest, maxLen, stdin );
    if( result != NULL )
    {
        // Wipe out the new line character at the
        // end of the string:
        
        int len = strlen( result );
        if( len > 0 )
        {
            dest[ len - 1 ] = 0;
        }
        return len;
    } 
    return -1; // If there was an error.
}

int main(void)
{
    // Get the assembly language program's title:
    
    try
    {
        char *title = getTitle();
            
        printf( "Calling %s:\n", title );
        asmMain();
        printf( "%s terminated\n", title );
    }
    catch(...)
    {
        printf
        ( 
            "Exception occurred during program execution\n"
            "Abnormal program termination.\n"
        );
    }
    
}
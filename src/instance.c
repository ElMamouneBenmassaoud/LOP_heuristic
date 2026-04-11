/*  Heuristic Optimization assignment, 2015.
    Adapted by Jérémie Dubois-Lacoste from the ILSLOP implementation
    of Tommaso Schiavinotto:
    ---
    ILSLOP Iterated Local Search Algorithm for Linear Ordering Problem
    Copyright (C) 2004  Tommaso Schiavinotto (tommaso.schiavinotto@gmail.com)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>

#include "instance.h"
#include "utilities.h"

#define BUFSIZE 1024

long int PSize;

/* Read a file instance, returning the data matrix. 
   At the moment works with LOLIB instances */
long int **readInstance(const char *filename) {
    FILE *f;
    char buffer[BUFSIZE+1];
    long int l, i, j, t;
    char *k;
    long int **r;
   
    buffer[BUFSIZE] = '\0';

    f = fopen(filename, "r");
    if ( !f ) {
	perror("readInstance");
	fatal("readInstance: Error on reading instance.");
    }
    
    fgets(buffer, BUFSIZE, f);
    l = strlen(buffer);
    if ( !l ) 
	fatal("readInstance: File instance is empty.");

    if (buffer[l-1] != '\n')
	fatal("readInstance: Header too long.");
    
    /* We can save the header with a strncpy if needed */
    
    /* Next line is the problem size: /^\s*(\d+)\s*$/ */

    fgets(buffer, BUFSIZE, f);
    l = strlen(buffer);
    if ( !l ) 
	fatal("readInstance: EOF reading size.");

    if (buffer[l-1] != '\n')
	fatal("readInstance: Unexpected long data where size was expected");
    
    for (i = 0; (i < (l-1)) && ( (buffer[i] < '0') || (buffer[i] > '9') ); 
	 i++);
    
    if (i == (l-1)) {
	printf("%ld (%ld) [%s]", i, l-1, buffer);
	fatal("readInstance: Size expected but not found.");
    }
    PSize = atoi( &buffer[i] );

    r = createMatrix(PSize);

    i = 0; j = 0; 

    while ( i < PSize ) {
	fgets(buffer, BUFSIZE, f);
	l = strlen( buffer );
	if ( !l ) 
	    fatal("readInstance: Not enough elements.");
	if (buffer[l-1] != '\n') {
	    sprintf(buffer, 
		    "readInstance: Line %ld malformed "
		    "(too long or unexpected EOF)", 
		    i+2);
	    fatal( buffer );
	}
	for (t = FALSE, k = buffer; *k != '\n'; k++) 
	    if ( ( ( *k >= '0' ) && (*k <= '9') ) || ( *k == '-' ) ) {
		if ( !t ) {
		    t = TRUE;
		    r[i][j] = atoi( k ); 
		    if ( (++j) == PSize ) {
			j = 0; 
			if ( (++i) == PSize ) break;
		    }
		}
	    } else 
		t = FALSE;
    }

    /* There is no control too see if there are too many elements in respect
       of the specified size */
    
    return(r);
}




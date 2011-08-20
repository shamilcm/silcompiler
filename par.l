%{
#include <stdio.h>
#include "y.tab.h"

extern YYSTYPE yylval;


%}



%%
[0-9]+		{   
			
			yylval.i = atof(yytext);
			return NUM; 
			/*printf("\ndigit %d", atoi(yytext));*/
		}
		
[-+/*\n] 		{ 
			
				return *yytext;
      			    /* printf("\nsign%s", yytext );*/	
			}
. 		{ printf("invalid character, exiting...");
		  return(0);		  
		 }
%%




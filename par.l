%{
#include <stdio.h>
#include "y.tab.h"

extern YYSTYPE yylval;


%}

digit [0-9]+
number {digit}+(\.{digit}+)?(E[+-]?{digit}+)?

%%
{number}		{   
			
			yylval.d = atof(yytext);
			return NUM; 
			/*printf("\ndigit %d", atof(yytext));*/
		}
		
[-+/*\n] 		{ 
			
				return *yytext;
      			    /* printf("\nsign%s", yytext );*/	
			}
. 		{ printf("invalid character, exiting...");
		  return(0);		  
		 }
%%




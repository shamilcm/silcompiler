%{
#include <stdio.h>
#include "y.tab.h"

extern YYSTYPE yylval;


%}

digit [0-9]+
number {digit}+(\.{digit}+)?(E[+-]?{digit}+)?

%%
{number} 	{   
			yylval.d=(atof(yytext)); 
			/*printf("\ndigit %.10g", yylval.d);*/
			return NUM; 
			
		}
[-+/*()\n] 		{  return *yytext;
      		    /* printf("\nsign%s", yytext );*/	
		}

. 		{ printf("invalid character, exiting...");
		  return(0);		  
		 }
%%




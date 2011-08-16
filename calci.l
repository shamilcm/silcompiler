%{
#include <stdio.h>
#include "y.tab.h"

extern YYSTYPE yylval;
%}

digit [0-9]+
number {digit}+(.{digit}+)?

%%
{digit} 	{   
			yylval=(atoi(yytext)); 
			return NUM; 
			/*printf("\ndigit %d", atoi(yytext));*/
		}
[-+/*()\n] 		{  return *yytext;
      		    /* printf("\nsign%s", yytext );*/	
		}

. 		{ printf("invalid character, exiting...");
		  return(0);		  
		 }
%%




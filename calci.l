%{
#include <stdio.h>
#include "y.tab.h"
extern int yylval;
%}

digit [0-9]

%%
{digit}+ 	{   
			yylval=atoi(yytext); 
			return NUM; 
			/*printf("\ndigit %d", atoi(yytext))*/;
		}
[-+/*\n] 		{  return *yytext;
      		    /* printf("\nsign%s", yytext );*/	
		}

. 		{ printf("invalid character, exiting...");
		  return(0);		  
		 }
%%



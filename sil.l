%{
#include <stdio.h>
#include "y.tab.h"

extern YYSTYPE yylval;

%}

%%

[0-9]+			{     	
				yylval.n = malloc(sizeof(struct node));
				yylval.n->flag=1;
				yylval.n->val = atoi(yytext);
				yylval.n->l = NULL;
				yylval.n->r = NULL;
				return NUM;
			
			}
		

[-+/*%] 		{ 
				yylval.n = malloc(sizeof(struct node));
				yylval.n->flag=0;
				yylval.n->op = (yytext[0]);
				yylval.n->l = NULL;
				yylval.n->r = NULL;
				return *yytext;
      			 }
      			 
[()\n]			{	return *yytext;
			}
 
. 			{ 	printf("invalid character, exiting...");
		 		return(0);		  
			}

%%




%{
#include <stdio.h>
#include "y.tab.h"

extern YYSTYPE yylval;


%}



%%
[0-9]+		{   
			/*struct node* tmp = malloc(sizeof(struct node));			
			yylval.n=malloc(sizeof(struct node));
			yylval.n->val = atoi(yytext);
			yylval.n->flag=1;
			yylval.n->l=NULL; 
			yylval.n->r=NULL;*/
			yylval.i = atof(yytext);
			return NUM; 
			/*printf("\ndigit %d", atoi(yytext));*/
		}
		
[-+/*\n] 		{ 
				/*yylval.n=malloc(struct node);
				yylval.n->op = yytext[0];
				yylval.n->flag=0;
				yylval.n->l=NULL; yylval->right=NULL;*/
				return *yytext;
      		    /* printf("\nsign%s", yytext );*/	
			}
. 		{ printf("invalid character, exiting...");
		  return(0);		  
		 }
%%




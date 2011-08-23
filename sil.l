%{
#include <stdio.h>
#include "y.tab.h"

extern YYSTYPE yylval;

struct node{
  	int val;
	char op;
	int flag;
	struct node *l, *r;
};
%}




%%

[0-9]+		
			{     	struct node* x;
				x= malloc(sizeof(struct node));
				x->flag=1;
				x->val = atoi(yytext);
				x->l = NULL;
				x->r = NULL;
				yylval.n = x;
				return NUM;
			
			}
		
[-+/*()] 		{ 
				yylval.n = malloc(sizeof(struct node));
				yylval.n->flag=0;
				yylval.n->op = (yytext[0]);
				yylval.n->l = NULL;
				yylval.n->r = NULL;
				return *yytext;
      			 }
\n			{	return *yytext;
			}
 
. 			{ 	printf("invalid character, exiting...");
		 		return(0);		  
			 }

%%




%{
#include <stdio.h>
#include "y.tab.h"

#define VOID 0
#define INTEGER 1
#define BOOLEAN 2

#define GT 'g'
#define LT 'l'
#define GE 'G'
#define LE 'L'
#define EQ 'E'
#define NE 'N'
#define VAR 'v'
#define CON 'c'
#define WHILE 'w'
#define IFELSE 'i'
#define READ 'R'
#define WRITE 'W'

extern YYSTYPE yylval;


%}

%%

[0-9]+			{     	
				yylval.n = malloc(sizeof(struct node));
				yylval.n->TYPE=INTEGER;
				yylval.n->NODETYPE=CON;
				yylval.n->NAME="";
				yylval.n->VALUE = atoi(yytext);
				yylval.n->ARGLIST=NULL;
				yylval.n->P1=NULL;
				yylval.n->P2=NULL;
				yylval.n->P3=NULL;
				yylval.n->GENTRY = NULL;
				yylval.n->LENTRY = NULL;
				return NUM;
			
			}
		

[-+/*%] 		{ 
				yylval.n = malloc(sizeof(struct node));
				yylval.n->TYPE=INTEGER;
				yylval.n->NODETYPE = *yytext;
				yylval.n->NAME="";
				yylval.n->VALUE = 0;				
				yylval.n->ARGLIST=NULL;
				yylval.n->P1=NULL;
				yylval.n->P2=NULL;
				yylval.n->P3=NULL;
				yylval.n->GENTRY = NULL;
				yylval.n->LENTRY = NULL;
				return *yytext;
      			 }
      			 
[()\n]			{	return *yytext;
			}
 
. 			{ 	printf("invalid character, exiting...");
		 		return(0);		  
			}

%%




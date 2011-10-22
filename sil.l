%{
#include <stdio.h>
#include <string.h>
#include "y.tab.h"

#define VOID 0
#define INTEGER 1
#define BOOLEAN 2

#define T 1;
#define F 0;

#define gt 'g'
#define lt 'l'
#define ge 'G'
#define le 'L'
#define eq 'E'
#define ne 'N'
#define var 'v'
#define con 'c'
#define whileloop 'w'
#define ifelse 'i'
#define r 'R'
#define w 'W'

struct node* makeNode(int type, char nodetype, char* name, int value);
extern YYSTYPE yylval;


%}

%%

"decl"                  {  	return DECL;  	 }
"enddecl"               {  	return ENDDECL;  }
"integer"               {  	return INT;    }
"boolean"               {  	return BOOL;   }
"write"                 {  	yylval.n = makeNode(VOID, w, NULL, 0);
				return WRITE;  }
"read"                  {  	yylval.n = makeNode(VOID, r, NULL, 0);
				return READ;   }
"begin"                 {  	return BEG;    }
"end"                   {  	return END;    }
"main"			{ 	return MAIN;   }
"if"			{  	return IF;     }
"else"    		{  	return ELSE;   }
"then"			{ 	return THEN;   }
"endif"			{  	return ENDIF;  }
"while"			{ 	return WHILE;  }
"do"			{ 	return DO;     }
"endwhile"		{ 	return ENDWHILE;  }
"return"		{	return RETURN; 	}
"TRUE"			{	yylval.n = makeNode(BOOLEAN, con, NULL, 1);
				return BNUM;		}
"FALSE"			{	yylval.n = makeNode(BOOLEAN, con, NULL, 0);
				return BNUM;
			}
"AND"			{	yylval.n = makeNode(BOOLEAN, 'a', NULL, 0);
				return AND;	
			}
"OR"			{	yylval.n = makeNode(BOOLEAN, 'o', NULL, 0);
				return OR;
			}
"NOT"			{	yylval.n = makeNode(BOOLEAN, 'n', NULL, 0);
				return NOT;
			}									
			

[0-9]+			{     	
				yylval.n = makeNode(INTEGER, con, NULL, atoi(yytext));
				return NUM;
			
			}
[a-zA-Z][a-zA-Z0-9]*   {	
				char *s = malloc(yyleng);
				strcpy(s, yytext);
				yylval.n = makeNode(INTEGER, var, s, 0);

				return ID;		
			}	
[-*+/%] 		{ 
				yylval.n = makeNode(INTEGER, *yytext, NULL, 0);
				return *yytext;
      			 }
"="	 		{ 
				yylval.n = makeNode(VOID, '=', NULL, 0);
				return *yytext;
     			 }
"<"			{ 	yylval.n = makeNode(BOOLEAN, lt, NULL, 0);
				return RELOP;
			}
">"			{	yylval.n = makeNode(BOOLEAN, gt, NULL, 0);
				return RELOP;
			}
"<="			{	yylval.n = makeNode(BOOLEAN, le, NULL, 0);
				return RELOP;
			}
">="			{	yylval.n = makeNode(BOOLEAN, ge, NULL, 0);
				return RELOP;
			}
"=="			{	yylval.n = makeNode(BOOLEAN, eq, NULL, 0);
				return RELOP;
			}
"!="			{	yylval.n = makeNode(BOOLEAN, ne, NULL, 0);
				return RELOP;
			}

[ \t\n]+		{
      			}	 
[();,\[\]{}&]		{	return *yytext;
			}
			
. 			{ 	return(0);		  
			}


%%

struct node* makeNode(int type, char nodetype, char* name, int value){
		struct node* res = malloc(sizeof(struct node));
		res->TYPE=type;
		res->NODETYPE=nodetype;
		res->NAME=name;
		res->VALUE = value;
		res->ARGLIST=NULL;
		res->P1=NULL;
		res->P2=NULL;
		res->P3=NULL;
		res->GENTRY = NULL;
		res->LENTRY = NULL;
		return res;
}

int yywrap(void)
 {
      return 1;
 }


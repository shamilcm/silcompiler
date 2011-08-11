%{
#include<stdio.h>
#include<string.h>
%}

%token NUM

%%

pgm:				
		|		
		expr1 '\n' 	{printf("%d\n", $1); return(0);}
		;
expr1:		expr1 '/' expr2 {$$=$1/$3;}
		|
		expr1 '*' expr2 {$$=$1*$3;}
		|
		expr2
		;

expr2:		expr2 '+' NUM	{$$=$1+$3;}	
		|
		expr2 '-' NUM	{$$=$1-$3;}
		|
		NUM		{$$=$1;}
		;		
				
%%

int main(void)
  {
	return yyparse();
	}

int yyerror (char *msg) {
	return fprintf (stderr, "YACC: %s\n", msg);
	}



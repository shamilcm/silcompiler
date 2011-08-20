%{
#include<stdio.h>
#include<string.h>
#include<math.h>

    
                                                           
%}

%union{
	double d;
}
%token <d> NUM
%left '-' '+'
%left '*' '/'
%right '^'
%left NEG     


%type <d> expr
  
 
%%
input:    
          | input pgm
		  ;

pgm:	'\n'			
		|
		expr '\n' 	{printf("%.10g\n>>", $1); }
		;
		
expr:	        expr '+' expr {$$=$1+$3;}
		|
		expr '-' expr {$$=$1-$3;}
		|
		expr '*' expr	{$$=$1*$3;}	
		|
		expr '/' expr	{$$=$1/$3;}
		|
		'-' expr  %prec NEG { $$ = -$2;        }
                |  
                 '(' expr ')'        { $$ = $2;   }
		|
		expr '^' expr { $$ = pow($1,$3);}
		|
		NUM		{$$=$1;}
		;	
			
			
%%

int main(void)
  { 
	printf(">>> ");
	return yyparse();
	}
	


int yyerror (char *msg) {
	return fprintf (stderr, "YACC: %s\n", msg);
	}







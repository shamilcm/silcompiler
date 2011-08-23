%{
#include<stdio.h>
#include<string.h>
#include<math.h>


struct node{
  	int val;
	char op;
	int flag;
	struct node *l, *r;
};

struct node* makeTree(struct node* parent, struct node* left, struct node* right);
struct node* makeLeaf(int val);
int par(struct node* t);

%}

%union{	 	
	int i;
	struct node *n;
}

%token <n> NUM 
%left '-' '+'
%left '*' '/'
%right '^'
%left NEG   
%type <n>  expr 
%type <n> '+' '-' '*' '/'


  
 
%%
input:    
          	| input pgm
		  ;

pgm:		'\n'			
		|
		expr '\n' 	{
				 par($1); printf("\n");main();
				}
		;
		
expr:		expr '+' expr 	{ 
				  $$ = makeTree($2,$1,$3);
				}
		|
		expr '-' expr 	{
				 $$ = makeTree($2,$1,$3);
				}
		|
		expr '*' expr	{
				 $$ = makeTree($2,$1,$3);
				}	
		|
		expr '/' expr	{
				 $$ = makeTree($2,$1,$3);
				}
		|
		'('expr')'	{$$=$2;}
		|
		'-' expr  %prec NEG {	$$ = makeTree($1,NULL,$2); }
		|
		NUM		{
				 $$=$1;
				}
		;	
			
			
%%

int main(void)
  { 
	printf("\n >>> ");
	return yyparse();
	}

struct node* makeTree(struct node* parent, struct node* left, struct node* right)
{ 
 	struct node* res;
	res->l=left;
 	res->r=right;
	return res;
}	

struct node* makeLeaf(int val)
{
	struct node* res;
	res->val = val;
	res->flag = 1;
	res->l = NULL;
	res->r = NULL;
	return res;

}

int par(struct node* t)
{ 
 if(t!=NULL)
  
  {	if(t->flag==0) printf("(");
	par(t->l);
	if(t->flag==0)
	printf("%c",t->op);
	else
	printf("%d",t->val);
	par(t->r);	 
	if(t->flag==0) printf(")");
  }
  return 1;

}

int yyerror (char *msg) {
	return fprintf (stderr, "YACC: %s\n", msg);
	}





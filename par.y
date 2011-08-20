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

struct node* makeTree(char op, struct node* left, struct node* right);
struct node* makeLeaf(int val);
void par(struct node* t);

%}

%union{	 	
	int i;
	struct node *n;
}

%token <i> NUM 
%left '-' '+'
%left '*' '/'  

%type <n> expr 


  
 
%%
input:    
          	| input pgm
		  ;

pgm:		'\n'			
		|
		expr '\n' 	{//printf("%d\n>>", $1);
				 par($1);
				}
		;
		
expr:		expr '+' expr 	{//$$ = $1+$3;
				 $$ = makeTree('+',$1,$3);
				}
		|
		expr '-' expr 	{// $$=$1-$3;
				 $$ = makeTree('-',$1,$3);
				}
		|
		expr '*' expr	{//$$=$1*$3;
				 $$ = makeTree('*',$1,$3);
				}	
		|
		expr '/' expr	{//$$=$1/$3;
				 $$ = makeTree('/',$1,$3);
				}
		|
		'('expr')'			{$$=$2;}
		|		
		NUM		{//$$=$1;
				 $$=makeLeaf($1);
				}
		;	
			
			
%%

int main(void)
  { 
	printf(">>");
	return yyparse();
	}

struct node* makeTree(char op, struct node* left, struct node* right)
{
	struct node* res = malloc(sizeof(struct node));
	res->op = op ;
	res->flag=0;
	res->l=left;
 	res->r=right;
	return res;
}	

struct node* makeLeaf(int val)
{
	struct node* res = malloc(sizeof(struct node));
	res->val = val;
	res->flag = 1;
	res->l = NULL;
	res->r = NULL;
	return res;

}

void par(struct node* t)
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

}

int yyerror (char *msg) {
	return fprintf (stderr, "YACC: %s\n", msg);
	}





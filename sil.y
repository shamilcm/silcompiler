%{
#include<stdio.h>
#include<string.h>
#include<stdlib.h>

#define VOID 0
#define INTEGER 1
#define BOOLEAN 2

#define T 1
#define F 0

#define gt 'g'
#define lt 'l'
#define ge 'G'
#define le 'L'
#define eq 'E'
#define ne 'N'
#define var 'v'
#define arr 'a'
#define con 'c'
#define whileloop 'w'
#define ifelse 'i'
#define r 'R'
#define w 'W'

int regcount = 0;
int memcount = 0;
int ifcount = 0;
int whilecount = 0;
int lbcount = 0;

struct istack
{
 int value;
 struct istack *next;
}*itop;

struct wstack{
 int value;
 struct wstack *next;
}*wtop;


void ipush(int count)
{
 struct istack *temp = malloc(sizeof(struct istack));
 temp->value = count;
 temp->next = itop;
 itop = temp;
 }

int ipop()
{
  struct istack *temp = itop;
  int res = temp->value;
  itop = itop->next;
  free(temp);
  return res; 
}

void wpush(int count)
{
 struct wstack *temp = malloc(sizeof(struct wstack));
 temp->value = count;
 temp->next = wtop;
 wtop = temp;
 }

int wpop()
{
  struct wstack *temp = wtop;
  int res = temp->value;
  wtop = wtop->next;
  free(temp);
  return res; 
}


struct ArgStruct{
	char* ARGNAME;
	int ARGTYPE;
	int PASSTYPE;	//0 Call By Value and 1 Call By Reference
	struct ArgStruct *ARGNEXT;
};

struct Gsymbol {
	char* NAME; 		// Name of the Identifier
	int TYPE; 		// TYPE can be INTEGER or BOOLEAN
	int SIZE; 		// Size field for arrays
	int *VALUE; 		// Address of the Identifier in Memory
	int BINDING;		// Position in the memory for Code Generation
	struct ArgStruct* ARGLIST;	// Argument List for functions, AgStruct - name and type of each argument
	struct Gsymbol *NEXT;	// Pointer to next Symbol Table Entry */
}*Ghead;

struct Gsymbol* Glookup(char* NAME);	 // Look up for a global identifier

void Ginstall(char* NAME, int TYPE, int SIZE, struct ArgStruct* ARGLIST); // Installation

struct Lsymbol {
	char *NAME; 		// Name of the Identifier
	int TYPE; 		// TYPE can be INTEGER or BOOLEAN
	int *VALUE; 		// Address of the Identifier in Memory
	int BINDING;		// Position in the memory for Code Generation
	struct Lsymbol *NEXT;	// Pointer to next Symbol Table Entry */
}*Lhead;

struct Lsymbol *Llookup(char* NAME);
void Linstall(char* NAME, int TYPE);

struct node* makeTree( struct node* parent, struct node* P1, struct node* P2, struct node* P3);
struct node* makeNode1(int type, char nodetype, char* name, int value);
int traverse(struct node* t);

int typeval;   //For getting type of variable
int Atypeval;	//For getting type of arguments
int Rtypeval;	// For getting return type

struct ArgStruct* headArg = NULL;
struct ArgStruct* newArg;

void makeArglist(struct ArgStruct* head, struct ArgStruct* arg);
void printArg(struct ArgStruct* head);
int fnDefCheck(int type, char* name, struct ArgStruct* arg);
int argDefCheck(struct ArgStruct* arg1, struct ArgStruct* arg2);
int argInstall(struct ArgStruct* head);

struct node* Thead;

%}

%union{	 	
	struct node{
	  	int TYPE; // VOID - for statements, INT - for integer constants and operators, BOOL - for TRUE, FALSE and log and relational operators.
		char NODETYPE; // + - / * %  = GT LT GE LE EQ NE VAR CON WHILE IFELSE READ WRITE 
	 	char* NAME; // For Identifiers/Functions
		int VALUE; // for constants
		struct node *ARGLIST; // List of arguments for functions
		struct node *P1, *P2, *P3; /* Maximum of three subtrees (3 required for IF THEN ELSE */
		struct Gsymbol *GENTRY; // For global identifiers/functions
		struct Lsymbol *LENTRY; // For Local variables
        }*n;



}

%token <n> NUM BNUM ID WRITE READ  RELOP AND OR NOT RETURN
%token IF ENDIF WHILE DO ENDWHILE BEG END BOOL INT DECL ENDDECL MAIN THEN ELSE 
%right NOT
%left AND OR
%left RELOP
%left '-' '+'
%left '*' '/' '%'
%right NEG   
%type <n>  expr  stmt Stmtlist Returnstmt
%type <n> '+' '-' '*' '/' '%' '='


  
 
%%
pgm:		GDefblock FDefblock Mainblock    { 
						return(0);
						}
		|
		Mainblock			{  
						
						return(0);
						}
		;

GDefblock:	DECL GDeflist ENDDECL		{
							 FILE *fp;
							 fp = fopen("sim.asm","a");
							 fprintf(fp,"MOV SP,%d\n",memcount-1);
							 fclose(fp);						
							 memcount = 1;	
							fp=fopen("sim.asm","a");
							fprintf(fp,"JMP main\n");
							fclose(fp);		
						}	
		;

GDeflist:	 GDecl				{ }
		|
		GDeflist GDecl			{ }
		;

GDecl:		Type GIdlist ';' 		{ }
		;

GIdlist:	GIdlist ',' GId			{ }
		|
		GId
		;

GId:		ID				{  							
							Ginstall($1->NAME, typeval, 1, NULL); 
						}
		|
		ID'['NUM']'			{       Ginstall($1->NAME, typeval, $3->VALUE, NULL);  
						}
		|
		ID '('Arglist')'		{
							Ginstall($1->NAME, typeval, 0, headArg);
							headArg=NULL;
						}
		;
Arglist:	Arglist ';' Arg			{
							 
						}
		|
		Arg				{
									
						}
		;
FArgdef:	FArglist			{
							argInstall(headArg);
						}
		;
FArglist:	FArglist ';' Arg		{
							 
						}
		|
		Arg				{
									
						}
		;
Arg:		ArgType ArgIdlist 		{
							 	   
						}
		;		
ArgIdlist:	ArgIdlist ',' ArgId		{
							 makeArglist(headArg, newArg);	
						}
						
		|
		ArgId				{
							 makeArglist(headArg, newArg);	
						}
		;

ArgId:		ID				{	newArg = malloc(sizeof(struct ArgStruct));
							newArg->ARGNAME = $1->NAME;
							newArg->ARGTYPE = Atypeval;
							newArg->PASSTYPE = 0;
							newArg->ARGNEXT = NULL;
						}
		|
		'&'ID				{
							newArg = malloc(sizeof(struct ArgStruct));
							newArg->ARGNAME = $2->NAME;
							newArg->ARGTYPE = Atypeval;
							newArg->PASSTYPE = 1;
							newArg->ARGNEXT = NULL;
						}
		;
ArgType:	INT					{    Atypeval=INTEGER; }
		|
		BOOL					{    Atypeval=BOOLEAN;	}
		;		

FDefblock:	
		|
		FDefblock FDef
		;

FDef:		RType	ID '(' FArgdef ')' Fblock	{
							 //struct Gsymbol* x = Glookup($2->NAME);
							 //if(x!=NULL) printf("Check");
							 fnDefCheck(Rtypeval, $2->NAME, headArg);
							 FILE *fp;
							 fp = fopen("sim.asm","a");
							 fprintf(fp,"fn%d:  //Function Name: %s\n", lbcount, $2->NAME);
							 lbcount++;
							 fprintf(fp,"PUSH BP\n");
							 fprintf(fp,"MOV BP,SP\n");
							 fprintf(fp,"MOV R%d,%d\n",regcount,memcount-1
							 );
							 regcount++;
							 fprintf(fp,"ADD SP,R%d\n",regcount-1);
							 regcount--;
							 fclose(fp);
							 headArg=NULL;
							 traverse(Thead); 
							 memcount=1;
							 Lhead = NULL;
							 Thead=NULL;								
							}
		;
RType:		INT					{    Rtypeval=INTEGER; }
		|
		BOOL					{    Rtypeval=BOOLEAN;	}
		;	
Mainblock:	INT MAIN '('')'  Fblock 	{  	FILE *fp;
							fp = fopen("sim.asm","a");
							fprintf(fp,"main: ");
							fclose(fp);
							traverse(Thead); 
							memcount=1;
							Lhead = NULL;
							Thead=NULL;
						}
		;
		
Fblock:		 LDefblock Stmtblock      	 {  }
		|
		Stmtblock			{  }
		;

LDefblock:	DECL LDlist ENDDECL			{ }			  
		;


LDlist:		LDecl					{ }
		|
		LDlist LDecl				{ }				 
		;

LDecl:		Type LIdlist ';'			 { }
		;

Type:		INT					{    typeval=INTEGER; }
		|
		BOOL					{    typeval=BOOLEAN;	}
		;
		
LIdlist:	LIdlist ',' LId				{			}
		|
		LId					{			}
		;
		
LId:		ID					{   Linstall($1->NAME, typeval); 
							}		
		;

Stmtblock:	BEG  Returnstmt ';' END			{ }
		|
		BEG END						{ }
		;
Returnstmt:	Stmtlist ';' RETURN expr 		{
							struct node* temp = makeNode1(VOID,'x',NULL,0);
							$3 = makeTree(temp, NULL, $4,NULL);
							temp = makeNode1(VOID, 's',NULL, 0);
							$$ = makeTree(temp, $1, $3, NULL);
							}
		;
Stmtlist:						{     $$ = NULL;    }
		|	
		stmt					{   	struct node* temp = malloc(sizeof(struct node));
								temp = makeNode1(VOID, 's',NULL, 0);
								$$ = makeTree(temp, $1, NULL, NULL);
							 }
		|
		Stmtlist ';' stmt 			{  	struct node* temp = malloc(sizeof(struct node));
								temp = makeNode1(VOID, 's',NULL, 0);
								$$ = makeTree(temp, $1, $3, NULL);
							}
		;

stmt:		ID '=' expr				{ 
							  struct Lsymbol* temp = Llookup($1->NAME);
							  if(temp==NULL) 
							   {
							     struct Gsymbol* gtemp = Glookup($1->NAME);
							      if(gtemp==NULL || gtemp->SIZE!=1) yyerror("Undefined Variable");
							      else
							       {
							     	 $1->GENTRY = gtemp;
							     	 $1->TYPE = gtemp->TYPE;
							       }
							   }
							  else 
							   {
							     $1->LENTRY = temp;
							     $1->TYPE = temp->TYPE;
							    }

							  if($1->TYPE == $3->TYPE) 
							 	 $$ = makeTree($2, $1, NULL, $3);
							  else
							  	{ yyerror("Type Mismatch");}
						
							}
		|
		ID '[' expr ']' '=' expr		{ 
							  struct Gsymbol* gtemp = Glookup($1->NAME);
							  if(gtemp==NULL || gtemp->SIZE==1) yyerror("Undefined Array");
							  else
							       {
							     	 $1->TYPE = gtemp->TYPE;
							       }
							 if($1->TYPE == $6->TYPE) 
							 	{ $1->GENTRY = gtemp;
							 	  $$ = makeTree($5, $1, $3, $6);
							 	}
							  else
							  	yyerror("Type Mismatch"); 	
		
							}
		|
		WRITE '('expr ')'			{ 
							  
							  $$ = makeTree($1, $3, NULL, NULL);
		
							}
		|
		READ '(' ID ')' 			{ 
							  struct Lsymbol *temp = Llookup($3->NAME);
							  if(temp==NULL)
							   { struct Gsymbol *gtemp = Glookup($3->NAME);
							     if(gtemp==NULL && gtemp->SIZE!=1)
							      {
							       yyerror("Undefined variable in READ");
							      }
							     else
							      {
							       $3->GENTRY = gtemp;
							       $$ = makeTree($1, $3, NULL, NULL);
							      }
							    }
							  else
							   {
							      $3->LENTRY = temp;
							      $$ = makeTree($1, $3, NULL, NULL);
							   }
							}
		|
		READ '(' ID '[' expr ']' ')' 		{ 
					 		  struct Gsymbol *gtemp = Glookup($3->NAME);
					 		  if(gtemp == NULL && gtemp->SIZE==1)
					 		   {
					 		     yyerror("Undefined array in READ");
					 		   }
					 		  else
					 		    { 
					 		      $3->GENTRY = gtemp;
					 		      $$ = makeTree($1, $3, $5, NULL);
							      
							    }
							}
		|
		IF expr  THEN Stmtlist ';' ELSE Stmtlist ';' ENDIF {
							   $$ = makeNode1(VOID, 'i', NULL, 0);
							   $$ = makeTree($$, $2, $4, $7);
							}
		|
		IF expr  THEN Stmtlist ';'  ENDIF     {
							   $$ = makeNode1(VOID, 'i', NULL, 0);
							   $$ = makeTree($$, $2, $4, NULL);
							}
		|
		WHILE expr DO Stmtlist';' ENDWHILE	{	
							$$ = makeNode1(VOID, 'w', NULL, 0);
							$$ = makeTree($$, $2, $4, NULL);
							}
		|						
		RETURN					{

							}	
		;

expr:		expr '+' expr 			{ if( $1->TYPE == $2->TYPE && $2->TYPE == $3->TYPE )
						   	$$ = makeTree($2, $1, $3, NULL);
						  else
						  	{ yyerror("Type Mismatch"); }
						 }
		|
		expr '-' expr 			{ if( $1->TYPE == $2->TYPE && $2->TYPE == $3->TYPE )
						   	$$ = makeTree($2, $1, $3, NULL);
						  else
						  	yyerror("Type Mismatch");
						}
		|
		expr '*' expr			{ if( $1->TYPE == $2->TYPE && $2->TYPE == $3->TYPE )
						   	$$ = makeTree($2, $1, $3, NULL);
						  else
						  	yyerror("Type Mismatch");
						}	
		|
		expr '/' expr			{ if( $1->TYPE == $2->TYPE && $2->TYPE == $3->TYPE )
						   	$$ = makeTree($2, $1, $3, NULL);
						  else
						  	yyerror("Type Mismatch");
						}
		|
		expr '%' expr			{ if( $1->TYPE == $2->TYPE && $2->TYPE == $3->TYPE )
						   	$$ = makeTree($2, $1, $3, NULL);
						  else
						  	yyerror("Type Mismatch");
						}
		|
		'('expr')'			{ $$=$2;}
		|
		'-' expr  %prec NEG 		{ 
						  if( $1->TYPE == $2->TYPE)
						   {	struct node *temp = makeNode1(INTEGER, con, NULL, 0);
						   	$$ = makeTree($1, temp, $2, NULL);
						   }	
						  else
						  	yyerror("Type Mismatch");
						  }
		|
		expr RELOP expr			{
						  if( $1->TYPE == $3->TYPE && $1->TYPE == INTEGER )
						   	$$ = makeTree($2, $1, $3, NULL);
						  else
						  	yyerror("Type Mismatch for Boolean Operator");
						  
						}
		|
		expr AND expr			{
						  if( $1->TYPE == $3->TYPE && $1->TYPE == BOOLEAN )
						   	$$ = makeTree($2, $1, $3, NULL);
						  else
						  	yyerror("Type Mismatch for AND Operator");
						  
						}
		|
		expr OR expr			{
						  if( $1->TYPE == $3->TYPE && $1->TYPE == BOOLEAN )
						   	$$ = makeTree($2, $1, $3, NULL);
						  else
						  	yyerror("Type Mismatch for OR Operator");
						  
						}
		|
		NOT expr			{
						  if( $2->TYPE== BOOLEAN )
						   	$$ = makeTree($1, NULL, $2, NULL);
						  else
						  	yyerror("Type Mismatch for Boolean Operator");
						  
						}
		|					
		ID				{
						  $$ = $1;
						  struct Lsymbol* temp = Llookup($$->NAME);
						  if(temp==NULL) 
						   {
						     struct Gsymbol* gtemp = Glookup($$->NAME);
						      if(gtemp==NULL) yyerror("Undefined Variable in Expression");
						      else
						       {
						       	 $$->GENTRY = gtemp;
						     	 $$->TYPE = gtemp->TYPE;
						       }
						   }
						  else 
						   { $$->LENTRY = temp;
						     $$->TYPE = temp->TYPE;
						    }
						}
		|
		ID'['expr']'			{
		 				  $$ = makeTree($1,$3,NULL,NULL);
		 				  struct Gsymbol* gtemp = Glookup($$->NAME);
					      	  if(gtemp==NULL) yyerror("Undefined Variable1");
					          else
					           {
					       		 $$->GENTRY = gtemp;
					     	 	 $$->TYPE = gtemp->TYPE;
					     	   }
						  
						}
		|
		NUM				{
				 		$$=$1;
						}
		|
		BNUM				{
						$$=$1; 
						$$->TYPE = BOOLEAN;
						}
					
%%

int main(void)
  { 
	FILE *fp;
	fp = fopen("sim.asm","w");
	fprintf(fp,"START\n");
	fprintf(fp,"MOV SP, 0\n");
	fprintf(fp,"MOV BP, 0\n");
	fclose(fp);
	yyparse();
	fp=fopen("sim.asm","a");
	fprintf(fp,"HALT\n");
	fclose(fp);		
    	return 0;
	
	}


struct node* makeNode1(int type, char nodetype, char* name, int value){
		struct node* res = malloc(sizeof(struct node));
		res->TYPE=type;
		res->NODETYPE=nodetype;
		res->NAME=name;
		res->VALUE = value;
		res->ARGLIST = NULL;
		res->P1	     = NULL;
		res->P2      = NULL;
		res->P3      = NULL;
		res->GENTRY  = NULL;
		res->LENTRY  = NULL;
		return res;
}


struct node* makeTree( struct node* parent, struct node* P1, struct node* P2, struct node* P3)
{ 
 	struct node* res = parent;
	res->P1 = P1;
	res->P2 = P2;
	res->P3 = P3;
	Thead = res;
	return res;
}

void makeArglist(struct ArgStruct* head, struct ArgStruct* arg)
{
	
	if(headArg == NULL)
	 {
	 	headArg = arg;
	}
	else
	{ 
		struct ArgStruct* i = head; 
		while(i->ARGNEXT!=NULL)
		{
			if(strcmp(i->ARGNAME,arg->ARGNAME)==0)
			 {
			 	yyerror("Multiple Declaration of Arguments");
			 }
			i = i->ARGNEXT;
		}
		if(strcmp(i->ARGNAME,arg->ARGNAME)==0)
		 {
		 	yyerror("Multiple Declaration of Arguments");
		 }
		i->ARGNEXT = arg;

	}
}

void printArg(struct ArgStruct* head)
{
	struct ArgStruct* i = head;
	while(i!=NULL)
	{
		printf("%d %s - ",i->ARGTYPE,i->ARGNAME);
		i=i->ARGNEXT;
	}
}	
void Ginstall(char* NAME, int TYPE, int SIZE, struct ArgStruct* ARGLIST)
 {
	   struct Gsymbol* res = malloc(sizeof(struct Gsymbol));
	   res->NAME = NAME;
	   res->TYPE = TYPE;
	   res->SIZE = SIZE; 
	   res->ARGLIST = ARGLIST; 
	   res->VALUE = malloc(sizeof(int)*SIZE);
	   /*-----------Code Generation-------------------*/
	   if(SIZE!=0)
	   {	   res->BINDING = memcount;
		   memcount = memcount+SIZE;
	   }
	   /*---------------------------------------------*/
	   res->NEXT = Ghead;
	   Ghead = res;
 }
int fnDefCheck(int type, char* name, struct ArgStruct* arg)
{
	   struct Gsymbol* res;
	   res = Ghead;
	   while(res != NULL)
	    {
		      if(strcmp(res->NAME, name) == 0 && res->SIZE==0)
			{
				 if(res->TYPE == type && argDefCheck(res->ARGLIST, arg))
				 {

				 	res->BINDING = lbcount;
				 	return res->BINDING;
				 }
				 else
				 {
					yyerror("Incorrect Function Definition");
					return -1;
			      		
			      	 }
		      	}
		      res = res->NEXT;
	     }
	  yyerror("Function Undeclared");

} 

int argDefCheck(struct ArgStruct* arg1, struct ArgStruct* arg2)
{
	struct ArgStruct* i = arg1;
	struct ArgStruct* j = arg2;
	while(i!=NULL)
	{
		if(j==NULL)
		{
		 
		 	return 0;
			
		}
		else
		{
			if(strcmp(j->ARGNAME,i->ARGNAME)!=0 || i->ARGTYPE!=j->ARGTYPE )
			{
			return 0;
			} 
			//Linstall(j->ARGNAME,j->ARGTYPE);
			i=i->ARGNEXT;
			j=j->ARGNEXT;
			
		}
	}
	if(j==NULL) 
	{
	 	return 1;
	}
	else 
	{	
	 	return 0;
		
	}
}

int argInstall(struct ArgStruct* head)
{
	struct ArgStruct* i = head;
	memcount=-1;
	/*memcount starts at -3 for arguments, as -1: Return address and -2 Return value*/
	while(i!=NULL)
	{
		memcount = memcount - 2;
		Linstall(i->ARGNAME,i->ARGTYPE);
		i=i->ARGNEXT;
	}
	memcount=1;
}

void Linstall(char* NAME, int TYPE)
 {
	   struct Lsymbol* res = malloc(sizeof(struct Lsymbol));
	   res->NAME = NAME;
	   res->TYPE = TYPE;
	   res->VALUE = malloc(sizeof(int));
	   /*----------------------Code Generation---------------------*/
	   res->BINDING = memcount;
	   memcount++;
	   /*----------------------------------------------------------*/
	   res->NEXT = Lhead;
	   Lhead = res;
 }
 
struct Gsymbol* Glookup(char* NAME)
 {
	   struct Gsymbol* res;
	   res = Ghead;
	   while(res != NULL)
	    {
	      if(strcmp(res->NAME, NAME) == 0)
		 return res;
	      else
		 res = res->NEXT;
	     }
	   return NULL;  
 }

struct Lsymbol* Llookup(char* NAME)
 {
	   struct Lsymbol* res;
	   res = Lhead;
	   while(res != NULL)
	    {
	      if(strcmp(res->NAME, NAME)==0)
		 return res;
	      else
		 res = res->NEXT;
	     }
	   return NULL;  
 }

int traverse(struct node* t)
{ 
	 
	 if(t!=NULL)
	  {	
	 	int res; 
	  	if(t->NODETYPE=='+')					
	  	{	res = traverse(t->P1)+traverse(t->P2);
	  	
	  		/*--------------For Code Generation-----------------------*/
	  		FILE *fp;
			fp = fopen("sim.asm","a");
			fprintf(fp,"ADD R%d,R%d\n", regcount-2, regcount-1);
			regcount--;
			fclose(fp);
			/*-------------------------------------------------------*/
	  	}
	  	else if(t->NODETYPE == '-')
	  	{	res = traverse(t->P1)-traverse(t->P2);
	  	
	  		/*--------------For Code Generation-----------------------*/
	  		FILE *fp;
			fp = fopen("sim.asm","a");
			fprintf(fp,"SUB R%d,R%d\n", regcount-2, regcount-1);
			regcount--;
			fclose(fp);
			/*--------------------------------------------------------*/
	  	}
	  	else if(t->NODETYPE == '*')
	  	{	res = traverse(t->P1)*traverse(t->P2);
	  		/*--------------For Code Generation-----------------------*/
	  		FILE *fp;
			fp = fopen("sim.asm","a");
			fprintf(fp,"MUL R%d,R%d\n", regcount-2, regcount-1);
			regcount--;
			fclose(fp);
			/*--------------------------------------------------------*/
	  	}
	  	else if(t->NODETYPE == '/')
	  	{	res = traverse(t->P1)/traverse(t->P2);
	  		/*--------------For Code Generation-----------------------*/
	  		FILE *fp;
			fp = fopen("sim.asm","a");
			fprintf(fp,"DIV R%d,R%d\n", regcount-2, regcount-1);
			regcount--;
			fclose(fp);
			/*--------------------------------------------------------*/
	  	}
	  	else if(t->NODETYPE == '%')
	  	{	res = traverse(t->P1)/traverse(t->P2);
	  		/*--------------For Code Generation-----------------------*/
	  		FILE *fp;
			fp = fopen("sim.asm","a");
			fprintf(fp,"MOD R%d,R%d\n", regcount-2, regcount-1);
			regcount--;
			fclose(fp);
			/*--------------------------------------------------------*/
	  	}
	  	else if(t->NODETYPE == gt)
  		{	if(traverse(t->P1) > traverse(t->P2))
  			   res = T;
  			else  
  			   res = F;
  			/*--------------For Code Generation-----------------------*/
	  		FILE *fp;
			fp = fopen("sim.asm","a");
			fprintf(fp,"GT R%d,R%d\n", regcount-2, regcount-1);
			regcount--;
			fclose(fp);
			/*--------------------------------------------------------*/
  		}
	  	else if(t->NODETYPE == lt)
  		{	if(traverse(t->P1) < traverse(t->P2))
  			   res = T;
  			else  
  			   res =  F;
  			/*--------------For Code Generation-----------------------*/
	  		FILE *fp;
			fp = fopen("sim.asm","a");
			fprintf(fp,"LT R%d,R%d\n", regcount-2, regcount-1);
			regcount--;
			fclose(fp);
			/*--------------------------------------------------------*/
  		}
	  	else if(t->NODETYPE == le)
  		{	if(traverse(t->P1) <= traverse(t->P2))
  			   res = T;
  			else  
  			   res = F;
  			/*--------------For Code Generation-----------------------*/
	  		FILE *fp;
			fp = fopen("sim.asm","a");
			fprintf(fp,"LE R%d,R%d\n", regcount-2, regcount-1);
			regcount--;
			fclose(fp);
			/*--------------------------------------------------------*/
  		}
	  	else if(t->NODETYPE == ge)
  		{	if(traverse(t->P1) >= traverse(t->P2))
  			   res = T;
  			else  
  			   res = F;
  			/*--------------For Code Generation-----------------------*/
	  		FILE *fp;
			fp = fopen("sim.asm","a");
			fprintf(fp,"GE R%d,R%d\n", regcount-2, regcount-1);
			regcount--;
			fclose(fp);
			/*--------------------------------------------------------*/
  		}
	  	else if(t->NODETYPE == eq)
  		{	if(traverse(t->P1) == traverse(t->P2))
  			   res = T;
  			else  
  			   res = F;
  			/*--------------For Code Generation-----------------------*/
	  		FILE *fp;
			fp = fopen("sim.asm","a");
			fprintf(fp,"EQ R%d,R%d\n", regcount-2, regcount-1);
			regcount--;
			fclose(fp);
			/*--------------------------------------------------------*/
  		}
  		else if(t->NODETYPE == 'a')
  		{	traverse(t->P1);
  			traverse(t->P2);

  			/*--------------For Code Generation-----------------------*/
	  		FILE *fp;
			fp = fopen("sim.asm","a");
			fprintf(fp,"MUL R%d,R%d\n", regcount-2, regcount-1);
			regcount--;
			fclose(fp);
			/*--------------------------------------------------------*/
  		}
  	  	else if(t->NODETYPE == 'o')
  		{	
  			traverse(t->P1);
  			traverse(t->P2);
  			/*--------------For Code Generation-----------------------*/
	  		FILE *fp;
			fp = fopen("sim.asm","a");
			fprintf(fp,"ADD R%d,R%d\n", regcount-2, regcount-1);
			regcount--;
			fclose(fp);
			/*--------------------------------------------------------*/
  		}
  		else if(t->NODETYPE == 'n')
  		{	traverse(t->P2);
    			/*--------------For Code Generation-----------------------*/
	  		FILE *fp;
			fp = fopen("sim.asm","a");
			fprintf(fp,"MOV R%d,1\n", regcount);
			regcount++;
			fprintf(fp,"SUB R%d,R%d\n", regcount-1, regcount-2);
			fprintf(fp,"MOV R%d,%d\n", regcount-2,regcount-1 );
			regcount--;
			fclose(fp);
			/*--------------------------------------------------------*/
  		}
	  	else if(t->NODETYPE == ne)
  		{	if(traverse(t->P1) != traverse(t->P2))
  			   res = T;
  			else  
  			   res =  F;
  			/*--------------For Code Generation-----------------------*/
	  		FILE *fp;
			fp = fopen("sim.asm","a");
			fprintf(fp,"NE R%d,R%d\n", regcount-2, regcount-1);
			regcount--;
			fclose(fp);
			/*--------------------------------------------------------*/
  		}
	  	else if(t->NODETYPE == 'R')
	  	  {
	  	   	 
	  	   	   struct Lsymbol* check = Llookup(t->P1->NAME);
	  		   if(check==NULL)					
	  		    {
		  		      struct Gsymbol* gcheck = Glookup(t->P1->NAME);
		  		      if(gcheck==NULL)						
		  		      	yyerror("Undefined Variable in read statement");
				      else				
				       { 
						if(t->P2 == NULL)						
						  {
							/*--------------For Code Generation-----------------------*/
							   FILE *fp;
							   fp = fopen("sim.asm","a");
							   fprintf(fp,"IN R%d\n",regcount);
							   regcount++;
							   fprintf(fp,"MOV [%d],R%d\n",gcheck->BINDING,regcount-1);
							   regcount--;
							   fclose(fp);
							/*--------------------------------------------------------*/
						}
						else							
						 {
							   int pos = traverse(t->P2);
							   if(pos >= (gcheck->SIZE) || pos<0 )
							   	yyerror("Exceeding size of array");
							   else
							    {

								    /*--------------For Code Generation-----------------------*/
								   FILE *fp;
								   fp = fopen("sim.asm","a");
								   fprintf(fp,"MOV R%d,%d\n", regcount, gcheck->BINDING);
								   regcount++;
								   fprintf(fp,"ADD R%d,R%d\n", regcount-2, regcount-1);
								   regcount--;
								   fprintf(fp,"IN R%d\n", regcount);
								   regcount++;
								   fprintf(fp,"MOV [R%d],R%d\n", regcount-2, regcount-1);
								   regcount=regcount-2;
								   fclose(fp);
								   /*--------------------------------------------------------*/	
	
							    }
					  	}
				       }
			   } 
			   else
			   {          /*--------------For Code Generation-----------------------*/
					   FILE *fp;
					   fp = fopen("sim.asm","a");
					   fprintf(fp,"IN R%d\n",regcount);
					   regcount++;
					   fprintf(fp,"MOV R%d,BP\n",regcount);
					   regcount++;
					   fprintf(fp,"MOV R%d,%d\n",regcount, check->BINDING);
					   regcount++;
					   fprintf(fp,"ADD R%d,R%d\n",regcount-2, regcount-1);
					   regcount--;					   
					   fprintf(fp,"MOV [R%d],R%d\n",regcount-1,regcount-2);
					   regcount=regcount-2;
					   fclose(fp);
					/*--------------------------------------------------------*/	
			   }
	  	  }	
	  	else if(t->NODETYPE=='=')
	  	 {
	  	 	
	  	 	struct Lsymbol *check = Llookup(t->P1->NAME);
	  	 	if(check==NULL) 	  		
	  	 	{
		  		      struct Gsymbol* gcheck = Glookup(t->P1->NAME);
		  		      if(gcheck==NULL)
		  		      	yyerror("Undefined Variable in assignment statement");
				      else
					{ 
						if(t->P2 == NULL)
						 {  *(gcheck->VALUE) = traverse(t->P3);
						    /*--------------For Code Generation-----------------------*/
						   FILE *fp;
						   fp = fopen("sim.asm","a");
						   fprintf(fp,"MOV [%d],R%d\n", gcheck->BINDING, regcount-1);
						   regcount--;
						   fclose(fp);
						   /*--------------------------------------------------------*/			
						 }
						else
						 {
							   int pos = traverse(t->P2);
							   if(pos >= (gcheck->SIZE) || pos<0 )
							   	yyerror("Exceeding size of array");
							   else
							   {	
								    /*--------------For Code Generation-----------------------*/
								   FILE *fp;
								   fp = fopen("sim.asm","a");
								   fprintf(fp,"MOV R%d,%d\n", regcount, gcheck->BINDING);
								   regcount++;
								   fprintf(fp,"ADD R%d,R%d\n", regcount-2, regcount-1);
								   regcount--;
								   fclose(fp);
								   /*---------------------------------------------------------*/
								   *(gcheck->VALUE + pos) = traverse(t->P3);
								   /*---------------------------------------------------------*/
								   fp = fopen("sim.asm","a");
								   fprintf(fp,"MOV [R%d],R%d\n", regcount-2, regcount-1);
								   regcount=regcount-2;
								   fclose(fp);
								   /*--------------------------------------------------------*/	
							   }
						  }   
					}
			}
	  	 	else
	  	 	 {
			    *(check->VALUE) = traverse(t->P3);
			   /*--------------For Code Generation-----------------------*/
			   FILE *fp;
			   fp = fopen("sim.asm","a");
			   fprintf(fp,"MOV R%d,BP\n",regcount);
			   regcount++;
			   fprintf(fp,"MOV R%d,%d\n",regcount, check->BINDING);
			   regcount++;
			   fprintf(fp,"ADD R%d,R%d\n",regcount-2, regcount-1);
			   regcount--;					   
			   fprintf(fp,"MOV [R%d],R%d\n",regcount-1,regcount-2);
			   regcount=regcount-2;
			   fclose(fp);
			   /*--------------------------------------------------------*/	
	  	 	  
	  	 	 }
	  	 }
	  	else if(t->NODETYPE=='W')
	  	  {
	  	   	if(t->P1->TYPE==INTEGER)
	  	   	{ //printf("%d\n",traverse(t->P1));
	  	   	   traverse(t->P1);
	  	   	}
	  	   	else
	  	   	 {
	  	   	  /* if(traverse(t->P1)==1)
	  	   	    {	//printf("TRUE\n");
	  	   	        
	  	   	     }
	  	   	   else 
	  	   	       //printf("FALSE\n");*/
	  	   	 }
		  	   /*--------------For Code Generation-----------------------*/
			   FILE *fp;
			   fp = fopen("sim.asm","a");
			   fprintf(fp,"OUT R%d\n", regcount-1);
			   regcount--;
			   fclose(fp);
			   /*--------------------------------------------------------*/
	  	  }	
	  	else if(t->NODETYPE=='i')		
	  	  {
	  	     	  /*--------------For Code Generation-----------------------*/  	
			   FILE *fp;
			   fp = fopen("sim.asm","a");
			   fprintf(fp,"I%d:", ifcount);
			   ipush(ifcount);
			   ifcount++;
			   fclose(fp);

			   traverse(t->P1);
	
			   fp = fopen("sim.asm","a");
			   fprintf(fp,"JZ R%d,E%d\n", regcount-1,ifcount-1);
			   regcount--;
			   fclose(fp);
	
			   traverse(t->P2);
	
			   fp = fopen("sim.asm","a");
			   fprintf(fp,"JMP EI%d\n", itop->value);
			   fprintf(fp,"E%d:\n", itop->value);
			   fclose(fp);
			   traverse(t->P3);
			   
			   fp = fopen("sim.asm","a");
			   fprintf(fp,"EI%d:\n", ipop());
			   fclose(fp);
			   
			   /*--------------------------------------------------------	
	  	     	
	  	     	
	  	     	if(traverse(t->P1)&&t->P1->TYPE==BOOLEAN)
	  	    	  {traverse(t->P2); 
	  	    	   }
	  	    	else 
	  	    	  {
	  	    	  traverse(t->P3);
	  	  	  }
	  	  	  */
	  	  }
	  	else if(t->NODETYPE=='w')		
	  	  {
	  	  	
		  	   /*--------------For Code Generation-----------------------*/  	
			   FILE *fp;
			   fp = fopen("sim.asm","a");
			   fprintf(fp,"W%d:", whilecount);
			   wpush(whilecount);
			   whilecount++;
			   fclose(fp);

			   traverse(t->P1);
	
			   fp = fopen("sim.asm","a");
			   fprintf(fp,"JZ R%d,EW%d\n", regcount-1,whilecount-1);
			   regcount--;
			   fclose(fp);
	
			   traverse(t->P2);
	
			   fp = fopen("sim.asm","a");
			   fprintf(fp,"JMP W%d\n", wtop->value);
			   fprintf(fp,"EW%d:", wpop());
			   fclose(fp);
			   /*--------------------------------------------------------	 		   	  	
	  	  	while(traverse(t->P1)&&t->P1->TYPE==BOOLEAN)
	  	  	 {
	  	  	  traverse(t->P2); 
	  	  	 }*/ 
	
	  	  }
	  	else if(t->NODETYPE=='v') 		
	  	 { 
	  	 	
	  	 	if(t->P1==NULL)
	  	 	{
				if(t->LENTRY!=NULL)
				 { 
				   res = *(t->LENTRY->VALUE);
			  	   /*--------------For Code Generation-----------------------*/
				   FILE *fp;
				   fp = fopen("sim.asm","a");
				   fprintf(fp,"MOV R%d,BP\n",regcount);
				   regcount++;
				   fprintf(fp,"MOV R%d,%d\n",regcount, t->LENTRY->BINDING);
				   regcount++;
				   fprintf(fp,"ADD R%d,R%d\n",regcount-1, regcount-2);			   
				   fprintf(fp,"MOV R%d,[R%d]\n", regcount-2, regcount-1);
				   regcount--;
				   fclose(fp);
				   /*--------------------------------------------------------*/								
				  }
				else
				 {
				   res = *(t->GENTRY->VALUE);
			  	   /*--------------For Code Generation-----------------------*/
				   FILE *fp;
				   fp = fopen("sim.asm","a");
				   fprintf(fp,"MOV R%d,[%d]\n", regcount, t->GENTRY->BINDING);
				   regcount++;
				   fclose(fp);
				   /*--------------------------------------------------------*/		
				 }
			}
			else
			{
			  int pos = traverse(t->P1);
			  if(pos < t->GENTRY->SIZE || pos >= 0)
			   {
			      res = *(t->GENTRY->VALUE + pos);
			      /*--------------For Code Generation-----------------------*/
				   FILE *fp;
				   fp = fopen("sim.asm","a");
				   fprintf(fp,"MOV R%d,%d\n", regcount, t->GENTRY->BINDING);
				   regcount++;
				   fprintf(fp,"ADD R%d,R%d\n", regcount-2,regcount-1);
				   regcount--;
				   fprintf(fp,"MOV R%d,[R%d]\n", regcount-1, regcount-1);    //Doubt??
				   fclose(fp);
			      /*--------------------------------------------------------*/	
			   } 
			  
		         }
	  	 	
	  	 }
	  	else if(t->NODETYPE=='c')
	  	 {
	  	 	res = t->VALUE;
			/*--------------For Code Generation-----------------------*/
	  	 	FILE *fp;
			fp = fopen("sim.asm","a");
			fprintf(fp,"MOV R%d,%d\n", regcount, res);
			regcount++;
			fclose(fp);
			/*--------------------------------------------------------*/
	  	 	
	  	 }
		else if(t->NODETYPE=='x')
		{
			if(t->P2!=NULL)
			{
			traverse(t->P2);
			}
			/*--------------For Code Generation-----------------------*/
	  	 	FILE *fp;
			fp = fopen("sim.asm","a");
			fprintf(fp,"MOV R%d,BP\n",regcount);
			regcount++;
			fprintf(fp,"MOV R%d,-2\n",regcount);
			regcount++;
			fprintf(fp,"ADD R%d,R%d\n",regcount-2,regcount-1);
			regcount--;
			fprintf(fp,"MOV [R%d],R%d\n",regcount-1,regcount-2);
			regcount = regcount-2;
			int i;
			for(i=1;i<=memcount-1;i++)
			{
			 fprintf(fp,"POP R%d\n",regcount);
			}
			fprintf(fp,"RET\n");
			fclose(fp);
			/*--------------------------------------------------------*/
	  	 	
	  	 }
	  	else if(t->NODETYPE=='s')
	  	 {
	  	 	traverse(t->P1);
	  	 	traverse(t->P2);
	  	 }
	  	else
	  	 {
	  	 	
	  	 	yyerror("Unexpected error!");
	  	 }
	   	return res;
	   }		  	  	
	else
	   	return 0;
	 
}

int yyerror (char *msg) 
   {
 	fprintf (stderr, "YACC: %s\n", msg);
 	exit(0);
   }





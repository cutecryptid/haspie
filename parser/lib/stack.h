#include <stdio.h>

/*Ismael Barbeito Vázquez - i.barbeito
Facultad de Informática de Coruña*/

/*Multitype stack implemented like the multitype list, but limiting
insertions/reads.*/

typedef void* elem_type;

typedef struct nodos{
  elem_type elem;
  struct nodoq* next;
} nodos;

typedef nodos* pnodos;

typedef struct{ 
	pnodos first;
	int size;
} stack; 

stack* new_stack(); 
void empty_stack(stack*);
int stack_size(stack);
int is_empty_stack(stack); 
void add_stack(stack*, elem_type e); 
elem_type pop(stack*); 
void print_stack (stack q, void (*print_function) (void*elem));

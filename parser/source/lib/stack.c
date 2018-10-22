#include "stack.h" 
#include <malloc.h> 
#include <stdlib.h>

/*Ismael Barbeito Vázquez - i.barbeito
Rodrigo Martín prieto - r.martin1
Facultad de Informática de Coruña*/
 
/*Creates a new stack. Dynamic memory is transparent*/
stack* new_stack() { 
  stack* s;
  s = malloc(sizeof(stack));
  s->first = NULL;
  s->size = 0;
  return s;
} 

/*Empties the given stack, freeing each node*/
void empty_stack(stack*s) { 
	pnodos temp = s->first;
	
	while (temp->next !=NULL) {
		temp = temp->next;	
	}
	free(temp);
	s->first = NULL;
	s->size = 0;
} 


/*Returns stack size*/
int stack_size(stack s) {
	return s.size;
}

/*Checks if stack is empty*/
int is_empty_stack(stack s){ 
	return (s.size == 0);
}

/*Add the given element at the top of s*/
void add_stack(stack*s, elem_type e) { 
	pnodos inodos = malloc (sizeof(nodos));
	inodos->elem = e;
	inodos->next = NULL;
	
	if (is_empty_stack(*s)) {
		s->first = inodos;
	} else {
		inodos->next = s->first;
		s->first = inodos;
	}
	s->size++;

} 

/*Takes the first element of the stack, and removes it from s (also frees the node)*/
elem_type pop(stack *s) { 
	pnodos temp;
	elem_type e;
	if (stack_size(*s) == 0) {
		printf ("Error: can't pop from an empty stack\n");
		exit(-1);
	}
	temp = s->first;
	e = s->first->elem;
	s->first = s->first->next;
	free(temp);
	s->size--;
	return (e);
}

/*Prints s. Behaviour (how to print each element) is defined on print_function*/
void print_stack (stack s, void (*print_function) (void*elem)) {
	pnodos temp = s.first;

	while (temp != NULL) {
		print_function (temp->elem);
		temp = temp->next;
	}
	printf ("\n");

}

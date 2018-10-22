#include "queue.h" 
#include <malloc.h> 
#include <stdlib.h>

/*Ismael Barbeito Vázquez - i.barbeito
Rodrigo Martín prieto - r.martin1
Facultad de Informática de Coruña*/
 
/*Creates a new queue. Dynamic memory is transparent*/
queue* new_queue() { 
  queue* s;
  s = malloc(sizeof(queue));
  s->first = NULL;
  s->last = NULL;
  s->size = 0;
  return s;
} 

/*Empties the given queue, freeing each node*/
void empty_queue(queue*s) { 
	pqnodos temp = s->first;
	while (temp->next !=NULL) {
		temp = temp->next;	
	}
	free(temp);
	s->first = NULL;
	s->size = 0;
} 


/*Returns queue size*/
int queue_size(queue s) {
	return s.size;
}

/*Checks if queue is empty*/
int is_empty_queue(queue s){ 
	return (s.size == 0);
}

/*Add the given element at the top of s*/
void add_queue(queue*s, elem_type e) { 
	pqnodos inodos = malloc (sizeof(qnodos));
	inodos->elem = e;
	inodos->next = NULL;
	
	if (is_empty_queue(*s)) {
		s->first = inodos;
		s->last = inodos;
	} else {
		s->last->next = inodos;
		s->last = inodos;
	}
	s->size++;

} 

/*Takes the first element of the queue, and removes it from s (also frees the node)*/
elem_type pop_queue(queue *s) { 
	pqnodos temp;
	elem_type e;
	if (queue_size(*s) == 0) {
		printf ("Error: can't pop from an empty queue\n");
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
void print_queue (queue s, void (*print_function) (void*elem)) {
	pqnodos temp = s.first;

	while (temp != NULL) {
		print_function (temp->elem);
		temp = temp->next;
	}
	printf ("\n");

}

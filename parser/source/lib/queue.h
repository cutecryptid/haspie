#include <stdio.h>

/*Ismael Barbeito Vázquez - i.barbeito
Facultad de Informática de Coruña*/

/*Multitype queue implemented like the multitype list, but limiting
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
} queue; 

queue* new_queue(); 
void empty_queue(queue*);
int queue_size(queue);
int is_empty_queue(queue); 
void add_queue(queue*, elem_type e); 
elem_type pop(queue*);
void print_queue (queue q, void (*print_function) (void*elem));

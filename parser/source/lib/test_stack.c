#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <malloc.h>
#include <math.h>
#include "stack.c"


int main()
{
    struct node* head = NULL;
    int size, element;
    int counter = 0;
 
    printf("Enter the number of stack elements:");
    scanf("%d",&size);
 
    printf("--- Push elements into the linked stack ---\n");
 
    init(head);
 
    while(counter < size)
    {
 
        printf("Enter a number to push into the stack:");
        scanf("%d",&element);
        head = push(head,element);
        display(head);
        counter++;
    }
 
    printf("--- Pop elements from the linked stack --- \n");
    while(empty(head) == 0)
    {
        head = pop(head,&element);
        printf("Pop %d from stack\n",element);
        display(head);
    }
 
    return 0;
}
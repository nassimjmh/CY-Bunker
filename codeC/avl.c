#include <stdio.h>
#include <stdlib.h>


// Structure for AVL Tree Node
typedef struct AVL {
    int id;             // Value of the node
    long long capacity; // Capacity of the node
    long long load;     // Load of the node
    int bf;             // Balance Factor
    struct AVL* left;   // Pointer to left child
    struct AVL* right;  // Pointer to right child
} AVL;

AVL* creationAVL(int id, long long capacity , long long load){
    AVL* new = malloc(sizeof(AVL));
    if( new == NULL){
        printf("creationAVL malloc failed\n");
        exit (1);
    }   
    new->bf = 0;
    new->left = NULL;
    new->right = NULL;
    new->id = id;
    new->capacity= capacity;
    new->load=load;
    return new;
}



int max(int a,int b){
    return (a>b) ? a : b;
}

int min(int a,int b){
    return (a>b) ? b : a;
}

AVL* rotateLeft(AVL* avl){
    AVL* pivot;
    int ea,ep;
    if (avl == NULL){
        return avl;
    }
    pivot = avl->right;
    avl->right = pivot->left;
    pivot->left = avl;
    // Updating balance factor;
    ea = avl->bf;
    ep = pivot->bf;
   
    avl->bf = ea - max(ep,0) - 1;
    pivot->bf = min(ea - 2, min(ea+ep-2, ep-1));
    avl = pivot;
    return avl;
}

AVL* rotateRight(AVL* avl){
    AVL* pivot;
    int ea, ep;
    if (avl == NULL){
        return avl;
    }
    pivot = avl->left;
    avl->left = pivot->right;
    pivot->right = avl;
    // Updating balance factor;
    ea = avl->bf;
    ep = pivot->bf;

    avl->bf = ea - min(ep,0) + 1;
    pivot->bf = max(ea +2, max(ea+ep+2, ep+1));
    avl = pivot;
    return avl;
}

AVL* doubleRight(AVL* avl){
    avl -> left = rotateLeft(avl->left);
    return rotateRight(avl);
}

AVL* doubleLeft(AVL* avl){
    avl->right = rotateRight(avl->right);
    return rotateLeft(avl);
}

AVL* balanceAVL(AVL* avl){
    if ( avl->bf >= 2){
        if ( avl->right != NULL && avl->right->bf >= 0){
            return rotateLeft(avl);
        }
        else{
            return doubleLeft(avl);
        }
    }
    if ( avl->bf <= -2){
        if ( avl->left != NULL && avl -> left -> bf <= 0){
            return rotateRight(avl);
        }
        else{
            return doubleRight(avl);
        }
    }
  
  return avl;
}

AVL* insertAVL(AVL* avl,int id,int* h, long long capacity, long long load){
    if (avl==NULL){
        *h=1;
        return creationAVL(id,capacity,load);   
    } else if (id < avl->id){
        avl->left = insertAVL(avl->left,id,h,capacity,load);
        *h=-*h;
    } else if (id > avl->id){
        avl->right = insertAVL(avl->right,id,h,capacity,load);
    }
    else{
        *h=0;
        avl->load+=load;
        return avl;
    }
   
    if (*h!=0){
        avl->bf+=*h;
        avl = balanceAVL(avl);
        *h = (avl->bf==0) ? 0 : 1 ; 
    }
    return avl;
}

AVL* freeAVL(AVL* pavl) {
    if (pavl == NULL) {
        return NULL;
    }

    // free left and right
    freeAVL(pavl->left);
    freeAVL(pavl->right);

    // free parents
    free(pavl);
    return NULL;
}

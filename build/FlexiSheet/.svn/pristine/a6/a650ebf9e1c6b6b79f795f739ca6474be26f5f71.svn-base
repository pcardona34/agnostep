//  $Id: FSHashMap.m,v 1.1 2008/10/14 15:04:19 hns Exp $
//
//  FSHashMap.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 30-APR-2002.
//
//  Copyright (c) 2001-2004, Stefan Leuker.        All rights reserved.
//  
//  Redistribution and use in source and binary forms,  with or without
//  modification,  are permitted provided that the following conditions
//  are met:
//  
//  *  Redistributions of source code must retain the above copyright
//     notice,  this list of conditions and the following disclaimer.
//  
//  *  Redistributions  in  binary  form  must  reproduce  the  above
//     copyright notice,  this  list of conditions  and the following
//     disclaimer  in  the  documentation  and / or  other  materials
//     provided with the distribution.
//  
//  *  Neither the name  "FlexiSheet"  nor the names of its copyright
//     holders  or  contributors  may  be used  to endorse or promote
//     products  derived  from  this software  without specific prior
//     written permission.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,  INCLUDING,  BUT NOT
//  LIMITED TO,  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND  FITNESS
//  FOR  A PARTICULAR PURPOSE  ARE  DISCLAIMED.  IN NO EVENT  SHALL THE
//  COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
//  INCIDENTAL, SPECIAL, EXEMPLARY OR CONSEQUENTIAL DAMAGES (INCLUDING,
//  BUT NOT LIMITED TO,  PROCUREMENT  OF  SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE,  DATA,  OR PROFITS;  OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY,  WHETHER IN CONTRACT, STRICT
//  LIABILITY, OR TORT  (INCLUDING NEGLIGENCE OR OTHERWISE)  ARISING IN
//  ANY WAY  OUT  OF  THE USE OF THIS SOFTWARE,  EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//  

#import "FSHashMap.h"

#define RED 1
#define BLACK 0

typedef struct _RedBlackTreeNode
{
    struct _RedBlackTreeNode *left, *right, *parent;
    FSHashKey                 key;
    id                        object;
    struct {
        unsigned              color : 1;
        unsigned              size : 31;
    } f;
} RedBlackTreeNode;

#define NIL(X) ((RedBlackTreeNode*)X == sentinel)
#define IS_SMALLER(A, B) ((strcmp(((RedBlackTreeNode*)A)->key, ((RedBlackTreeNode*)B)->key)) < 0)
#define IS_EQUAL(A, B) ((strcmp(((RedBlackTreeNode*)A)->key, ((RedBlackTreeNode*)B)->key)) == 0)

//
//  NODE CREATION/DESTRUCTION
//

void _deallocNode(RedBlackTreeNode* node)
{
    free((char*)node->key);
    [node->object release];
    free(node);
}


void _deallocAllNodesBelowNode(RedBlackTreeNode* x, RedBlackTreeNode* sentinel)
{
    if(NIL(x->left) == NO)
        _deallocAllNodesBelowNode(x->left, sentinel);
    if(NIL(x->right) == NO)
        _deallocAllNodesBelowNode(x->right, sentinel);
    _deallocNode(x);
}


void _swapValuesBetweenNodes(RedBlackTreeNode* a, RedBlackTreeNode* b)
{
    FSHashKey k = b->key;
    id        d = b->object;
    b->key = a->key;
    b->object = a->object;
    a->key = k;
    a->object = d;
}


@implementation FSHashMap

+ (FSHashMap*)hashMap
{
    return [[[self alloc] init] autorelease];
}


//---------------------------------------------------------------------------------------
//	QUERIES (PRIVATE)
//---------------------------------------------------------------------------------------

- (RedBlackTreeNode*)_allocNodeForKey:(FSHashKey)key
{
    RedBlackTreeNode *new;

    new = malloc(sizeof(RedBlackTreeNode));
    new->parent = sentinel;
    new->left = sentinel;
    new->right = sentinel;
    new->key = strdup(key);
    new->object = nil;
    new->f.color = BLACK;
    new->f.size = 1;

    return new;
}


- (RedBlackTreeNode*)_nodeForKey:(FSHashKey)key
{
    RedBlackTreeNode   *x;
    int                 r;

    x = rootNode;
    while(NIL(x) == NO)
    {
        r = strcmp(key, x->key);
        if(r == 0)
            break;
        else if(r < 0)
            x = x->left;
        else
            x = x->right;
    }

    return x;
}


- (RedBlackTreeNode*)_nodeForObjectOrPredecessorOfKey:(FSHashKey)key
{
    RedBlackTreeNode   *x, *y;
    int                 r;

    x = rootNode;
    y = sentinel;
    while(NIL(x) == NO)
    {
        r = strcmp(key, x->key);
        if(r == 0)
        {
            y = x;
            break;
        }
        else if(r < 0)
        {
            x = x->left;
        }
        else
        {
            y = x;
            x = x->right;
        }
    }

    return y;
}


- (RedBlackTreeNode*)_rootNode
{
    return rootNode;
}


- (RedBlackTreeNode*)_minimumNode
{
    return NIL(rootNode) ? rootNode : minimumNode;
}


- (RedBlackTreeNode*)_minimumBelowNode:(RedBlackTreeNode*)x
{
    while(NIL(x->left) == NO)
        x = x->left;
    return x;
}


- (RedBlackTreeNode*)_maximumBelowNode:(RedBlackTreeNode*)x
{
    while(NIL(x->right) == NO)
        x = x->right;
    return x;
}


- (RedBlackTreeNode*)_successorForNode:(RedBlackTreeNode*)x
{
    RedBlackTreeNode*y;

    if(NIL(x->right) == NO)
        return [self _minimumBelowNode:x->right];
    ((RedBlackTreeNode*)sentinel)->right = NULL; // to make sure
    y = x->parent;
    while(x == y->right)
    {
        x = y;
        y = y->parent;
    }
    return y;
}


- (RedBlackTreeNode*)_nodeWithRank:(unsigned int)i
{
    RedBlackTreeNode 	*x;
    unsigned int 		r;

    x = rootNode;
    r = x->left->f.size + 1;
    while(r != i)
    {
        if(i < r)
        {
            x = x->left;
        }
        else
        {
            x = x->right;
            i -= r;
        }
        r = x->left->f.size + 1;
    }
    return x;
}


- (unsigned int)_rankOfNode:(RedBlackTreeNode*)x
{
    RedBlackTreeNode 	*y;
    unsigned int 		r;

    r = x->left->f.size + 1;
    y = x;
    while(y != rootNode)
    {
        if(y == y->parent->right)
            r += y->parent->left->f.size + 1;
        y = y->parent;
    }
    return r;
}


//---------------------------------------------------------------------------------------
//	MUTATORS (PRIVATE)
//---------------------------------------------------------------------------------------

- (void)_leftRotateFromNode:(RedBlackTreeNode*)x
{
    RedBlackTreeNode *y;

    y = x->right;
    x->right = y->left;
    if(NIL(y->left) == NO)
        y->left->parent = x;
    y->parent = x->parent;
    if(NIL(x->parent) == YES)
    {
        rootNode = (RedBlackTreeNode*)y;
    }
    else
    {
        if(x == x->parent->left)
            x->parent->left = y;
        else
            x->parent->right = y;
    }
    y->left = x;
    x->parent = y;
    y->f.size = x->f.size;
    x->f.size = x->left->f.size + x->right->f.size + 1;
}


- (void)_rightRotateFromNode:(RedBlackTreeNode*)y
{
    RedBlackTreeNode *x;

    x = y->left;
    y->left = x->right;
    if(NIL(x->right) == NO)
        x->right->parent = y;
    x->parent = y->parent;
    if(NIL(y->parent) == YES)
    {
        rootNode = (RedBlackTreeNode*)x;
    }
    else
    {
        if(y == y->parent->left)
            y->parent->left = x;
        else
            y->parent->right = x;
    }
    x->right = y;
    y->parent = x;
    x->f.size = y->f.size;
    y->f.size = y->left->f.size + y->right->f.size + 1;
}


- (void)_insertNodeUnbalanced:(RedBlackTreeNode*)z
{
    RedBlackTreeNode *x, *y;

    if(NIL(rootNode))
    {
        minimumNode = z;
    }
    else
    {
        if(IS_SMALLER(z, minimumNode))
            minimumNode = z;
    }

    y = sentinel;
    x = rootNode;
    while(NIL(x) == NO)
    {
        x->f.size += 1;
        y = x;
        if(IS_SMALLER(z, x))
            x = x->left;
        else
            x = x->right;
    }

    z->parent = y;
    if(NIL(y) == YES)
    {
        rootNode = z;
    }
    else
    {
        if(IS_SMALLER(z, y))
            y->left = z;
        else
            y->right = z;
    }
}


- (void)_insertNode:(RedBlackTreeNode*)x
{
    RedBlackTreeNode *y;

    [self _insertNodeUnbalanced:(RedBlackTreeNode*)x];
    x->f.color = RED;

    while((x != rootNode) && (x->parent->f.color == RED))
    {
        if(x->parent == x->parent->parent->left)
        {
            y = x->parent->parent->right;
            if(y->f.color == RED)
            {
                x->parent->f.color = BLACK;
                y->f.color = BLACK;
                x->parent->parent->f.color = RED;
                x = x->parent->parent;
            }
            else
            {
                if(x == x->parent->right)
                {
                    x = x->parent;
                    [self _leftRotateFromNode:x];
                }
                x->parent->f.color = BLACK;
                x->parent->parent->f.color = RED;
                [self _rightRotateFromNode:x->parent->parent];
            }
        }
        else 	/* same as above with 'left' and 'right' exchanged */
        {
            y = x->parent->parent->left;
            if(y->f.color == RED)
            {
                x->parent->f.color = BLACK;
                y->f.color = BLACK;
                x->parent->parent->f.color = RED;
                x = x->parent->parent;
            }
            else
            {
                if(x == x->parent->left)
                {
                    x = x->parent;
                    [self _rightRotateFromNode:x];
                }
                x->parent->f.color = BLACK;
                x->parent->parent->f.color = RED;
                [self _leftRotateFromNode:x->parent->parent];
            }
        }
    }
    ((RedBlackTreeNode*)rootNode)->f.color = BLACK;
}



- (void)_deleteFixup:(RedBlackTreeNode*)x
{
    RedBlackTreeNode *w;

    while((x != rootNode) && (x->f.color == BLACK))
    {
        if(x == x->parent->left)
        {
            w = x->parent->right;
            if(w->f.color == RED)
            {
                w->f.color = BLACK;
                x->parent->f.color = RED;
                [self _leftRotateFromNode:x->parent];
                w = x->parent->right;
            }
            if((w->left->f.color == BLACK) && (w->right->f.color == BLACK))
            {
                w->f.color = RED;
                x = x->parent;
            }
            else
            {
                if(w->right->f.color == BLACK)
                {
                    w->left->f.color = BLACK;
                    w->f.color = RED;
                    [self _rightRotateFromNode:w];
                    w = x->parent->right;
                }
                w->f.color = x->parent->f.color;
                x->parent->f.color = BLACK;
                w->right->f.color = BLACK;
                [self _leftRotateFromNode:x->parent];
                x = rootNode;
            }
        }
        else /* same as above with 'left' and 'right' exchanged */
        {
            w = x->parent->left;
            if(w->f.color == RED)
            {
                w->f.color = BLACK;
                x->parent->f.color = RED;
                [self _rightRotateFromNode:x->parent];
                w = x->parent->left;
            }
            if((w->right->f.color == BLACK) && (w->left->f.color == BLACK))
            {
                w->f.color = RED;
                x = x->parent;
            }
            else
            {
                if(w->left->f.color == BLACK)
                {
                    w->right->f.color = BLACK;
                    w->f.color = RED;
                    [self _leftRotateFromNode:w];
                    w = x->parent->left;
                }
                w->f.color = x->parent->f.color;
                x->parent->f.color = BLACK;
                w->left->f.color = BLACK;
                [self _rightRotateFromNode:x->parent];
                x = rootNode;
            }
        }
    }
    x->f.color = BLACK;
}



- (RedBlackTreeNode*)_deleteNode:(RedBlackTreeNode*)z
{
    RedBlackTreeNode *x, *y, *w;

    if(z == minimumNode)
        minimumNode = sentinel;

    if(NIL(z->left) || NIL(z->right))
        y = z;
    else
        y = [self _successorForNode:z];
    if(NIL(y->left) == NO)
        x = y->left;
    else
        x = y->right;
    x->parent = y->parent;
    if(NIL(y->parent))
    {
        rootNode = x;
    }
    else
    {
        if(y == y->parent->left)
            y->parent->left = x;
        else
            y->parent->right = x;
    }

    if(y != z)
        _swapValuesBetweenNodes(y, z);

    w = y;
    while(NIL(w) == NO)
    {
        w->f.size -= 1;
        w = w->parent;
    }

    if(y->f.color == BLACK)
        [self _deleteFixup:x];

    if(minimumNode == sentinel)
        if(NIL(rootNode) == NO)
            minimumNode = [self _minimumBelowNode:rootNode];

    return y;
}


//
//
//

- init
{
    [super init];
    sentinel = [self _allocNodeForKey:""];
    ((RedBlackTreeNode*)sentinel)->f.size = 0;
    rootNode = minimumNode = sentinel;
    return self;
}


- (void)dealloc
{
    if(NIL(rootNode) == NO)
        _deallocAllNodesBelowNode(rootNode, sentinel);
    _deallocNode(sentinel);
    [super dealloc];
}


- (void)removeAllObjects
{
    if(NIL(rootNode) == NO)
        _deallocAllNodesBelowNode(rootNode, sentinel);
    rootNode = minimumNode = sentinel;
}


- (int)count
{
    return ((RedBlackTreeNode*)rootNode)->f.size;
}


- (NSArray*)allObjects
{
    RedBlackTreeNode *x;
    NSMutableArray   *a;

    if (rootNode == nil)
        return [NSArray array];

    x = minimumNode;
    a = [NSMutableArray arrayWithCapacity:((RedBlackTreeNode*)rootNode)->f.size];
    while (NIL(x) == NO) {
        [a addObject:x->object];
        x = [self _successorForNode:x];
    }
    return a;
}


- (id)objectForKey:(FSHashKey)key
{
    RedBlackTreeNode *z = [self _nodeForKey:key];

    if (NIL(z)) return nil;
    
    return z->object;
}

- (void)setObject:(id)object forKey:(FSHashKey)key
{
    RedBlackTreeNode *z;

    if (key == NULL) {
        [NSException raise:@"FSHashMap" format:@"Attempt to set an object with NULL key."];
    }
    
    z = [self _nodeForKey:key];
    
    if (NIL(z)) {
        z = [self _allocNodeForKey:key];
        [self _insertNode:z];
    }
    z->object = [object retain];
}


- (void)removeObjectForKey:(FSHashKey)key
{
    RedBlackTreeNode *z;

    z = [self _nodeForKey:key];
    
    if (NIL(z)) return;

    z = [self _deleteNode:z];
    _deallocNode(z);
}


@end

---
title: CPython Tuple Object
date: 2019-09-01 14:43:46
categories: python源码
tags: [python, 源码, cpython, python-objects]
---

## 前言
新开了一个分类，来学习python源码。python源码的结构还是比较清晰，刚开始我们可以从Objects目录入手，该目录下存放的是python中内置对象的实现(`built-in objects`)，所谓的内置对象，其实就是cpython中用c实现的对象。我们可以从一个比较简单的基本对象`tuple`入手，来了解一下python对象的实现。

### tuple对象的定义
tuple对象的定义位于`Include/tupleobject.h`中，这是一种c语言中声明可变长度对象的常用做法，即在结构体末尾声明一个长度为1的数组，在申请内存的时候，多申请的内存都会作为该数组的存储空间。可以看出，tuple中存储的python对象是直接放置在结构体中的，而list由于其是可变的，其只存放了指向python对象的指针。

```
typedef struct {
    PyObject_VAR_HEAD
    PyObject *ob_item[1];

    /* ob_item contains space for 'ob_size' elements.
     * Items must normally not be NULL, except during construction when
     * the tuple is not yet visible outside the function that builds it.
     */
} PyTupleObject;
```
<!-- more -->

### tuple对象的复用机制
python为了提高性能，在很多对象中都使用了复用机制，tuple的复用相对来说也较为简单易懂。首先，决定复用机制的参数使用宏来定义，其结构实际上是多个链表，每个链表存放的都是成员数量一样的tuple。

乍看之下我们可能会觉得奇怪，因为下面的代码中我们也没有看到链表结构的定义。实际上，这里有一个小trick，指向下一个对象的指针放在了tuple对象的第一个成员中，即`ob_item[0]`中，由于free_list中的对象都是销毁时放置的对象，`ob_item`中的指针并没有实际意义。

另外，空的tuple对象并不需要通过链表管理，全局只存在一个空的tuple对象，即在`free_list[0]`中。

```
/* Speed optimization to avoid frequent malloc/free of small tuples */
#ifndef PyTuple_MAXSAVESIZE
#define PyTuple_MAXSAVESIZE     20  /* Largest tuple to save on free list */
#endif
#ifndef PyTuple_MAXFREELIST
#define PyTuple_MAXFREELIST  2000  /* Maximum number of tuples of each size to save */
#endif

#if PyTuple_MAXSAVESIZE > 0
/* Entries 1 up to PyTuple_MAXSAVESIZE are free lists, entry 0 is the empty
   tuple () of which at most one instance will be allocated.
*/
static PyTupleObject *free_list[PyTuple_MAXSAVESIZE];
static int numfree[PyTuple_MAXSAVESIZE];
#endif
```

每次调用new的时候，python会先在free_list中寻找是否有未使用的tuple对象，如果存在，即可直接将该对象取出，将其中存放的PyObject指针替换掉即可。如果不存在，就只能新建一个新的tuple对象了。

而在销毁tuple对象的时候，如果可以的话，就会将其放回到free_list中，而不是直接销毁，这样就节省出了一次dealloc的开销。注意空的tuple对象直接管理其引用计数即可。

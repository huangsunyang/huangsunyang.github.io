---
title: CPython Memory Management
date: 2020-04-25 17:24:23
categories: python源码
tags: [python, 源码, 内存管理]
---

## 什么是内存管理

内存是数据存储的介质，其访问速度比硬盘快，但是容量相对更小，且断电后数据会丢失。由于内存的种种性质，其成为了计算机开机后访问数据的最佳位置，操作系统或者用户进程所访问的数据大都也都是在内存上。

内存管理实际上管理的是内存物理介质的状态。内存作为一种物理介质，每一个bit都是0/1两种状态，它并不清楚自身存储的数据含义，甚至也并不清楚自身是否被使用了。

通常来说，操作系统为我们管理了作为物理介质的内存，即使用虚拟内存和分页的方式，使得我们的用户进程能够访问连续的/不受物理内存大小限制的虚拟地址空间。其次，c运行库中的`malloc`/`calloc`函数在操作系统层面之上提供了堆空间内存分配的接口。而python在此基础之上，为所有`PyObject`提供了统一的内存分配/管理接口。



## 为什么要进行内存管理

个人认为，主要原因是为了减少内存分配调用而产生的开销；此外，通用的内存管理也方便在此基础上进行垃圾回收等其他操作。当调用`malloc`函数时，我们通常会陷入内核进行系统调用，甚至会产生缺页异常从而分配新的页并更新页表，这样的操作是相对费时的。python内存管理的核心目的就是减少小对象的内存分配次数，从而提高程序运行性能。

<!-- more -->

## Block/Pool/Arena概述

python的内存管理中有三个重要概念，从小到大也就是`block`/`pool`/`arena`

- `block`对应着一个`PyObject`所占据的内存空间，小`PyObject`都会被分配在一个block中，可能会有一定的内部碎片，相当于字节对齐后的缝隙。block的大小从8-512字节不等。
- `pool`相当于对操作系统页的抽象，也是python内存管理通过`malloc`向操作系统申请内存的最小单位。每个`pool`都是4096字节，也就是4KB，对应大多数操作系统一页的大小。每个pool中包含的block都是固定大小的。
- `arena`主要用来管理`pool`，每个`arena`包含的内存空间大小固定为256KB，其中固定包含64个`pool`，且其中包含的`pool`并不一定都有相同的`block_size`

![graph-overview](overview.svg)

## pool如何管理block

### pool_header以及pool的初始化

在`obmalloc.c`中的头部位置，python定义了`block`的字节对齐`ALIGNMENT`以及小对象的最大大小`SMALL_REQUEST_THRESHOLD`，实际上这也就是一个`block`的大小范围。同时，python也简单将`POOL_SIZE`定义为了大多数操作系统一页的大小4KB。

```c
/*
 * Alignment of addresses returned to the user. 8-bytes alignment works
 * on most current architectures (with 32-bit or 64-bit address busses).
 * The alignment value is also used for grouping small requests in size
 * classes spaced ALIGNMENT bytes apart.
 *
 * You shouldn't change this unless you know what you are doing.
 */
#if SIZEOF_VOID_P > 4
#define ALIGNMENT              16               /* must be 2^N */
#define ALIGNMENT_SHIFT         4
#else
#define ALIGNMENT               8               /* must be 2^N */
#define ALIGNMENT_SHIFT         3
#endif

/* Return the number of bytes in size class I, as a uint. */
#define INDEX2SIZE(I) (((uint)(I) + 1) << ALIGNMENT_SHIFT)

/*
 * Max size threshold below which malloc requests are considered to be
 * small enough in order to use preallocated memory pools. You can tune
 * this value according to your application behaviour and memory needs.
 *
 * The following invariants must hold:
 *      1) ALIGNMENT <= SMALL_REQUEST_THRESHOLD <= 512
 *      2) SMALL_REQUEST_THRESHOLD is evenly divisible by ALIGNMENT
 *
 * Note: a size threshold of 512 guarantees that newly created dictionaries
 * will be allocated from preallocated memory pools on 64-bit.
 *
 * Although not required, for better performance and space efficiency,
 * it is recommended that SMALL_REQUEST_THRESHOLD is set to a power of 2.
 */
#define SMALL_REQUEST_THRESHOLD 512
#define NB_SMALL_SIZE_CLASSES   (SMALL_REQUEST_THRESHOLD / ALIGNMENT)

/*
 * The system's VMM page size can be obtained on most unices with a
 * getpagesize() call or deduced from various header files. To make
 * things simpler, we assume that it is 4K, which is OK for most systems.
 * It is probably better if this is the native page size, but it doesn't
 * have to be.  In theory, if SYSTEM_PAGE_SIZE is larger than the native page
 * size, then `POOL_ADDR(p)->arenaindex' could rarely cause a segmentation
 * violation fault.  4K is apparently OK for all the platforms that python
 * currently targets.
 */
#define SYSTEM_PAGE_SIZE        (4 * 1024)
#define SYSTEM_PAGE_SIZE_MASK   (SYSTEM_PAGE_SIZE - 1)

/*
 * Size of the pools used for small blocks. Should be a power of 2,
 * between 1K and SYSTEM_PAGE_SIZE, that is: 1k, 2k, 4k.
 */
#define POOL_SIZE               SYSTEM_PAGE_SIZE        /* must be 2^N */
#define POOL_SIZE_MASK          SYSTEM_PAGE_SIZE_MASK
```



之后，python给出了`pool_header`的结构体定义，很容易看出多个`pool_header`都被串联在一个双向链表中。其中需要解释的字段也就是`free_block`，`nextoffset`和`maxnextoffset`，我们可以通过`init_pool`部分的相关代码来理解这几个变量。由于整个pool的内存分配是由`arena_object`管理的，因此这里pool的初始化里看不到这一方面的相关代码，就像`__init__`代码里是没有对象的内存分配代码一样。

这里我们会发现`pool`首先会被加入到`usedpools[size + size]`这个双向链表中，实际上`usedpools`可以理解为所有`pools`的一个切片，或者说一个`view`。能够通过`usedpools[size + size]`从中获取到所有`sizeidx`相同的可用的`pools`的双向链表。暂时可以不用管他。此外，中间有一段复用`pool`的代码，也可以先略过。

```c
/* Pool for small blocks. */
struct pool_header {
    union { block *_padding;
            uint count; } ref;          /* number of allocated blocks    */
    block *freeblock;                   /* pool's free list head         */
    struct pool_header *nextpool;       /* next pool of this size class  */
    struct pool_header *prevpool;       /* previous pool       ""        */
    uint arenaindex;                    /* index into arenas of base adr */
    uint szidx;                         /* block size class index        */
    uint nextoffset;                    /* bytes to virgin block         */
    uint maxnextoffset;                 /* largest valid nextoffset      */
};

typedef struct pool_header *poolp;

/* code fragment for init a pool in function pymalloc_alloc */
#define POOL_OVERHEAD   _Py_SIZE_ROUND_UP(sizeof(struct pool_header), ALIGNMENT)

init_pool:
   /* Frontlink to used pools. */
   next = usedpools[size + size]; /* == prev */
   pool->nextpool = next;
   pool->prevpool = next;
   next->nextpool = pool;
   next->prevpool = pool;
   pool->ref.count = 1;
   if (pool->szidx == size) {
      /* Luckily, this pool last contained blocks
      * of the same size class, so its header
      * and free list are already initialized.
      */
      bp = pool->freeblock;
      assert(bp != NULL);
      pool->freeblock = *(block **)bp;
      goto success;
   }
   /*
   * Initialize the pool header, set up the free list to
   * contain just the second block, and return the first
   * block.
   */
   pool->szidx = size;
   size = INDEX2SIZE(size);
   bp = (block *)pool + POOL_OVERHEAD;
   pool->nextoffset = POOL_OVERHEAD + (size << 1);
   pool->maxnextoffset = POOL_SIZE - size;
   pool->freeblock = bp + size;
   *(block **)(pool->freeblock) = NULL;
   goto success;
```



下图展示了一块刚被初始化的`pool`的状态，此时所有的`block`都未被分配，`freeblock`指向了第一块`block`，`nextoffset`指向了第二块，`maxnextoffset`指向了最后一块。除此之外，`freeblock`所指向的内存的第一个指针大小空间被置为了`NULL`。

![graph-pool](pool.svg)



### pool如何分配block

从如下代码分析，`usedpools`中存放的都是还未放满的pool，因为必定有一个`freeblock`。所以在这个分支下，分配的内存空间地址肯定就是`pool->freeblock`了。但是取走当前`freeblock`之后还需要找到下一个`freeblock`，还记得之前初始化时，`freeblock`位置处放置了一个NULL指针，这实际上时`freeblock`链表结束的标志。在其他情况下，该位置处存放的指针也就是下一个`freeblock`的地址。由此得出维护状态的两种情况：

- 存在下一个`freeblock`，将`freeblock`赋值为下一个指针即可

- 没有下一个`freeblock`，即`freeblock`指向的地址处是NULL指针
  - 尝试将`nextoffset`处的地址作为`freeblock`
  - `nextoffset`也走到头了，即`nextoffset`走到了`maxnextoffset`位置
    - 说明`pool`已满，将这个`pool`从`usedpool[size + size]`双向链表中移除

```c
/* code fragment for allocate a block in function pymalloc_alloc */
/*
* Most frequent paths first
*/
size = (uint)(nbytes - 1) >> ALIGNMENT_SHIFT;
pool = usedpools[size + size];
if (pool != pool->nextpool) {
    /*
    * There is a used pool for this size class.
    * Pick up the head block of its free list.
    */
    ++pool->ref.count;
    bp = pool->freeblock;
    assert(bp != NULL);
    if ((pool->freeblock = *(block **)bp) != NULL) {
        goto success;
    }

    /*
    * Reached the end of the free list, try to extend it.
    */
    if (pool->nextoffset <= pool->maxnextoffset) {
        /* There is room for another block. */
        pool->freeblock = (block*)pool +
            pool->nextoffset;
        pool->nextoffset += INDEX2SIZE(size);
        *(block **)(pool->freeblock) = NULL;
        goto success;
    }
    
    /* Pool is full, unlink from used pools. */
    next = pool->nextpool;
    pool = pool->prevpool;
    next->prevpool = pool;
    pool->nextpool = next;
    goto success;
}
```

### pool如何释放block

释放block和分配的过程非常相似，实际上也就是分配的逆操作。其大致流程如下：

- 如果当前`pool`的`freeblock`不为`NULL`，及说明当前`pool`还有`freeblock`
  - 将这个释放的`block`链接到`freeblock`链表的头部
- 如果当前pool的`freeblock`为`NULL`，说明pool已满，也就不在`usedpools`链表中
  - 这时需要将`pool`重新链接回`usedpools`链表中

```c
/* code fragment for free a block in function pymalloc_free */

/* Link p to the start of the pool's freeblock list.  Since
* the pool had at least the p block outstanding, the pool
* wasn't empty (so it's already in a usedpools[] list, or
* was full and is in no list -- it's not in the freeblocks
* list in any case).
*/
assert(pool->ref.count > 0);            /* else it was empty */
*(block **)p = lastfree = pool->freeblock;
pool->freeblock = (block *)p;
if (!lastfree) {
    /* Pool was full, so doesn't currently live in any list:
    * link it to the front of the appropriate usedpools[] list.
    * This mimics LRU pool usage for new allocations and
    * targets optimal filling when several pools contain
    * blocks of the same size class.
    */
    --pool->ref.count;
    assert(pool->ref.count > 0);            /* else the pool is empty */
    size = pool->szidx;
    next = usedpools[size + size];
    prev = next->prevpool;
    
    /* insert pool before next:   prev <-> pool <-> next */
    pool->nextpool = next;
    pool->prevpool = prev;
    next->prevpool = pool;
    prev->nextpool = pool;
    goto success;
}

 /* freeblock wasn't NULL, so the pool wasn't full,
 * and the pool is in a usedpools[] list.
 */
if (--pool->ref.count != 0) {
    /* pool isn't empty:  leave it in usedpools */
    goto success;
}
```

### pool分配释放block图示

pool的一个中间状态可能如下图所示：

![graph-pool_mid_state_free](graph-pool_mid_state.svg)
此时如果分配了一个block，则会变为如下图所示

![graph-pool_mid_state_free](graph-pool_mid_state_alloc.svg)
此后如果又释放了一个block，则会变为如下图所示

![graph-pool_mid_state_free](graph-pool_mid_state_free.svg)
## arena_object如何管理pool

### arena_object结构体

`arena_object`结构体的定义如下，注意到和`pool`不同的是，`arena_object`持有的空间并不包括其自身，而是用`address`指向的，此外，`pool`所在的地址是经过字节对齐的，因而是不是从`address`开始累加的。

此外，关于`arena`还定义了一部分常量，例如

- 一个`arena`是256KB
- 第一次分配的`arena`的数量为16
- 一个`arena`最多包含的`pool`数量为64

需要注意的是，`arena_object`只负责提供一个空的`pool`，至于这一个`pool`中的`block`被使用了一个还是全部，`arena_object`是不负责管理的。也就是说，只有`pool`从空到非空状态，或者从非空到空状态，才会触发`arena_object`的管理操作。

再次强调，`arena_object`只负责提供一个空的`pool`，记住这个中心原则对理解代码很有帮助。



![graph-arena_align](graph-arena_align.svg)

```c
/* Record keeping for arenas. */
struct arena_object {
    /* The address of the arena, as returned by malloc.  Note that 0
     * will never be returned by a successful malloc, and is used
     * here to mark an arena_object that doesn't correspond to an
     * allocated arena.
     */
    uintptr_t address;

    /* Pool-aligned pointer to the next pool to be carved off. */
    block* pool_address;

    /* The number of available pools in the arena:  free pools + never-
     * allocated pools.
     */
    uint nfreepools;

    /* The total number of pools in the arena, whether or not available. */
    uint ntotalpools;

    /* Singly-linked list of available pools. */
    struct pool_header* freepools;

    /* Whenever this arena_object is not associated with an allocated
     * arena, the nextarena member is used to link all unassociated
     * arena_objects in the singly-linked `unused_arena_objects` list.
     * The prevarena member is unused in this case.
     *
     * When this arena_object is associated with an allocated arena
     * with at least one available pool, both members are used in the
     * doubly-linked `usable_arenas` list, which is maintained in
     * increasing order of `nfreepools` values.
     *
     * Else this arena_object is associated with an allocated arena
     * all of whose pools are in use.  `nextarena` and `prevarena`
     * are both meaningless in this case.
     */
    struct arena_object* nextarena;
    struct arena_object* prevarena;
};

/*
 * The allocator sub-allocates <Big> blocks of memory (called arenas) aligned
 * on a page boundary. This is a reserved virtual address space for the
 * current process (obtained through a malloc()/mmap() call). In no way this
 * means that the memory arenas will be used entirely. A malloc(<Big>) is
 * usually an address range reservation for <Big> bytes, unless all pages within
 * this space are referenced subsequently. So malloc'ing big blocks and not
 * using them does not mean "wasting memory". It's an addressable range
 * wastage...
 *
 * Arenas are allocated with mmap() on systems supporting anonymous memory
 * mappings to reduce heap fragmentation.
 */
#define ARENA_SIZE              (256 << 10)     /* 256KB */

#define MAX_POOLS_IN_ARENA  (ARENA_SIZE / POOL_SIZE)


```

### arena_object的初始化

arena_object的初始化也和pool_header初始化基本一致，先是分配了整个arena的空间在address，在计算字节对齐后将pool_address初始化。初始化后的arena_object如图所示：



```c
/* Take the next available arena object off the head of the list. */
arenaobj = unused_arena_objects;
unused_arena_objects = arenaobj->nextarena;
address = _PyObject_Arena.alloc(_PyObject_Arena.ctx, ARENA_SIZE);
if (address == NULL) {
    /* The allocation failed: return NULL after putting the
     * arenaobj back.
     */
    arenaobj->nextarena = unused_arena_objects;
    unused_arena_objects = arenaobj;
    return NULL;
}
arenaobj->address = (uintptr_t)address;

arenaobj->freepools = NULL;
/* pool_address <- first pool-aligned address in the arena
   nfreepools <- number of whole pools that fit after alignment */
arenaobj->pool_address = (block*)arenaobj->address;
arenaobj->nfreepools = MAX_POOLS_IN_ARENA;
excess = (uint)(arenaobj->address & POOL_SIZE_MASK);
if (excess != 0) {
    --arenaobj->nfreepools;
    arenaobj->pool_address += POOL_SIZE - excess;
}
arenaobj->ntotalpools = arenaobj->nfreepools;
```



### arena如何分配pool

和`pool`分配`block`非常类似

- `arena_object`中的`freepools`就相当于`pool_header`中的`freeblock`
- `arena_object`中的`pool_address`就相当于`pool_header`中的`nextoffset`
- `arena_object`中没有`maxnextoffset`，因为`maxnextoffset`可以用`address + ARENA_SIZE - POOL_SIZE`计算得到

由此我们很容易理解arena分配pool的流程

- 如果`freepools`中有可用的pool，则从`freepools`中取出一个可用的pool，并更新`freepools`链表

- 如果`freepools`为空，则从`pool_address`处取出一块`POOL_SIZE`大小的空间作为`pool`

和`pool`分配`block`相比，还是有些许的不同，`pool_header`中单用`freeblock`指针即可判断pool中是否还有`freeblock`，因为每次`pool_header`是在分配后保证`freeblock`指向一块空闲空间。而`arena_object`则没有这样的处理，因此会有两次判断，也有一些重复代码（将`arena`从`usable_arenas`链表中删除的代码），因为最后一块空闲的`pool`可能在`address`处也可能在`freepools`处。相比之下，`pool_header`的方法虽然稍微多了一些理解成本，但是实现上更巧妙。

```c
/* Try to get a cached free pool. */
pool = usable_arenas->freepools;
if (pool != NULL) {
    /* Unlink from cached pools. */
    usable_arenas->freepools = pool->nextpool;
    --usable_arenas->nfreepools;
    if (usable_arenas->nfreepools == 0) {
        /* Wholly allocated:  remove. */
        usable_arenas = usable_arenas->nextarena;
        if (usable_arenas != NULL) {
            usable_arenas->prevarena = NULL;
        }
    }
init_pool:
    /* omit pool init code */
    goto success;
}

/* Carve off a new pool. */
pool = (poolp)usable_arenas->pool_address;
pool->arenaindex = (uint)(usable_arenas - arenas);
pool->szidx = DUMMY_SIZE_IDX;
usable_arenas->pool_address += POOL_SIZE;
--usable_arenas->nfreepools;

if (usable_arenas->nfreepools == 0) {
    /* Unlink the arena:  it is completely allocated. */
    usable_arenas = usable_arenas->nextarena;
    if (usable_arenas != NULL) {
        usable_arenas->prevarena = NULL;
    }
}

goto init_pool;
```

### arena如何释放pool

当释放完一个`block`，当前pool为空时，即`pool->ref.count`为0，则会触发`arena`回收`pool`的操作，和`pool`回收`block`一样，只是简单地将其放回`freepools`中即可。

```c
struct arena_object* ao;
uint nf;  /* ao->nfreepools */

/* freeblock wasn't NULL, so the pool wasn't full,
 * and the pool is in a usedpools[] list.
 */
if (--pool->ref.count != 0) {
    /* pool isn't empty:  leave it in usedpools */
    goto success;
}
/* Pool is now empty:  unlink from usedpools, and
 * link to the front of freepools.  This ensures that
 * previously freed pools will be allocated later
 * (being not referenced, they are perhaps paged out).
 */
next = pool->nextpool;
prev = pool->prevpool;
next->prevpool = prev;
prev->nextpool = next;

/* Link the pool to freepools.  This is a singly-linked
 * list, and pool->prevpool isn't used there.
 */
ao = &arenas[pool->arenaindex];
pool->nextpool = ao->freepools;
ao->freepools = pool;
++ao->nfreepools;
```



## 如何管理arena_object

### arena_object所在的容器

`arena_object`主要通过一个数组和两个链表进行管理：

- `arenas`中存放了所有arena的数组，类似动态数组，翻倍增长
- `usable_arenas`是存放了所有使用了的，即`nfreepools`大于0小于`ntotalpools`的`arena_object`的双向链表
- `unused_arena_objects`存放所有未使用的，即`nfreepools`为`ntotalpools`的`arena_object`的单向链表
- 而所有`pool`都已经使用的，即`nfreepools`为0的`arena_object`，则只放在`arenas`中，没有链表管理

`arenas`数组中一种可能的状态如图所示：

![graph-pool_mid_state_alloc](graph-arena_mid_state.svg)

```C
/* Array of objects used to track chunks of memory (arenas). */
static struct arena_object* arenas = NULL;
/* Number of slots currently allocated in the `arenas` vector. */
static uint maxarenas = 0;

/* The head of the singly-linked, NULL-terminated list of available
 * arena_objects.
 */
static struct arena_object* unused_arena_objects = NULL;

/* The head of the doubly-linked, NULL-terminated at each end, list of
 * arena_objects associated with arenas that have pools available.
 */
static struct arena_object* usable_arenas = NULL;

/* nfp2lasta[nfp] is the last arena in usable_arenas with nfp free pools */
static struct arena_object* nfp2lasta[MAX_POOLS_IN_ARENA + 1] = { NULL };

/* How many arena_objects do we initially allocate?
 * 16 = can allocate 16 arenas = 16 * ARENA_SIZE = 4MB before growing the
 * `arenas` vector.
 */
#define INITIAL_ARENA_OBJECTS 16
```
### arena_object的创建和分配

什么时候会创建一个新的`arena_object`对象呢？试想一下，如果想要分配一定的内存空间，如果恰好有一个对应`szidx`的未满的`pool`，实际上也就足够了。如果没有这样的`pool`，如果有`arena_object`（即从`useable_arenas`中获取一个）能够提供一个空的`pool`改造一下，也能凑合用了。最坏情况是，所有对应`szidx`的`pool`都满了，而且也没有空的`pool`了，这时候只能重新创建新的`arena_object`了。相关代码如下：

```c
size = (uint)(nbytes - 1) >> ALIGNMENT_SHIFT;
pool = usedpools[size + size];
if (pool != pool->nextpool) {
    // ... omit code when you can get a pool with right szidx
    goto success;
}
    
/* There isn't a pool of the right size class immediately
 * available:  use a free pool.
 */
if (usable_arenas == NULL) {
    /* No arena has a free pool:  allocate a new arena. */
    usable_arenas = new_arena();
    if (usable_arenas == NULL) {
        goto failed;
    }
    usable_arenas->nextarena =
        usable_arenas->prevarena = NULL;
    assert(nfp2lasta[usable_arenas->nfreepools] == NULL);
    nfp2lasta[usable_arenas->nfreepools] = usable_arenas;
}
```



`arena_object`的创建主要经历以下几个流程：

- 如果没有未使用的`arena_object`，即`unused_arena_objects`为`NULL`
  
  - 创建两倍原大小的`arena_object`的数组，第一次则创建16个。之后将后一半`arena_object`连接到`unused_arena_objects`链表中去
- 此时可以从`unused_arena_objects`中取出一个`arena`进行初始化操作
  - 从`unused_arena_objects`中移除
  - 分配内存空间
  - 处理`pool`字节对齐，初始化`pool`总数以及可用pool总数
  

对应于代码中的三个状态如下图所示：

![graph-new_arena](graph-new_arena.svg)


```c
/* Allocate a new arena.  If we run out of memory, return NULL.  Else
 * allocate a new arena, and return the address of an arena_object
 * describing the new arena.  It's expected that the caller will set
 * `usable_arenas` to the return value.
 */
static struct arena_object*
new_arena(void)
{
    struct arena_object* arenaobj;
    uint excess;        /* number of bytes above pool alignment */
    void *address;
	
    if (unused_arena_objects == NULL) {
        /* state for picture 1 */
        uint i;
        uint numarenas;
        size_t nbytes;

        /* Double the number of arena objects on each allocation.*/
        numarenas = maxarenas ? maxarenas << 1 : INITIAL_ARENA_OBJECTS;

        nbytes = numarenas * sizeof(*arenas);
        arenaobj = (struct arena_object *)PyMem_RawRealloc(arenas, nbytes);
        if (arenaobj == NULL)
            return NULL;
        arenas = arenaobj;

        /* Put the new arenas on the unused_arena_objects list. */
        for (i = maxarenas; i < numarenas; ++i) {
            arenas[i].address = 0;              /* mark as unassociated */
            arenas[i].nextarena = i < numarenas - 1 ?
                                   &arenas[i+1] : NULL;
        }

        /* Update globals. */
        unused_arena_objects = &arenas[maxarenas];
        maxarenas = numarenas;
        /* state for picture 2 */
    }

    /* omit init arena_object code */
    /* state for picture 3 */
    return arenaobj;
}
```



### arena_object的释放

释放一个`block`后，我们很可能会产生一连串的连锁反应，导致持有`block`的`pool`的状态变化。同样的，在释放一个`pool`后，也会使得持有这个`pool`的`arena_object`的状态产生变化，会有一下两种情况：

1. 释放的pool为`arena_object`中唯一使用的`pool`，那么需要将这个`arena_object`持有的内存释放，并将`arena_object`从`usable_arenas`链表中移除，并加入到`unused_arena_objects`链表中
2. 释放的`pool`前`arena_object`是满的，那么需要将`arena_object`重新放到`usable_arenas`中
3. 释放`pool`前后`arena_object`都在`usable_arenas`中，由于`usable_arenas`链表中是按照`nfreepools`从小到大排序的，因而需要维护一下顺序（此段代码未附）

```c
if (nf == ao->ntotalpools) {
    /* Case 1.  First unlink ao from usable_arenas.
     * Fix the pointer in the prevarena, or the
     * usable_arenas pointer.
     */
    if (ao->prevarena == NULL) {
        usable_arenas = ao->nextarena;
    }
    else {
        ao->prevarena->nextarena = ao->nextarena;
    }
    /* Fix the pointer in the nextarena. */
    if (ao->nextarena != NULL) {
        ao->nextarena->prevarena = ao->prevarena;
    }
    /* Record that this arena_object slot is
     * available to be reused.
     */
    ao->nextarena = unused_arena_objects;
    unused_arena_objects = ao;

    /* Free the entire arena. */
    _PyObject_Arena.free(_PyObject_Arena.ctx,
                         (void *)ao->address, ARENA_SIZE);
    ao->address = 0;                        /* mark unassociated */
    --narenas_currently_allocated;

    goto success;
}

if (nf == 1) {
    /* Case 2.  Put ao at the head of
     * usable_arenas.  Note that because
     * ao->nfreepools was 0 before, ao isn't
     * currently on the usable_arenas list.
     */
    ao->nextarena = usable_arenas;
    ao->prevarena = NULL;
    if (usable_arenas)
        usable_arenas->prevarena = ao;
    usable_arenas = ao;
    if (nfp2lasta[1] == NULL) {
        nfp2lasta[1] = ao;
    }

    goto success;
}
```

## usedpools是什么

`usedpools`实际上是用`pool`的`szidx`作为索引的双向链表。举例来说，`usedpools[i + i]`中存放的也就是`szidx=i`的不为空也不满的pools所在的双向链表。回顾一下前文，`arena_object`中只使用`freepools`管理了所有为空的`pool`，放满的`pool`以及部分使用的`pool`是未管理的，到了这一章节我们知道了部分使用的`pool`是通过`usedpools`来管理的，这是什么原因导致的呢？因为`szidx`相等的`pool`是跨`arena`连接的，因而无法在`arena_object`内部管理。

```c
#define PTA(x)  ((poolp )((uint8_t *)&(usedpools[2*(x)]) - 2*sizeof(block *)))
#define PT(x)   PTA(x), PTA(x)

static poolp usedpools[2 * ((NB_SMALL_SIZE_CLASSES + 7) / 8) * 8] = {
    PT(0), PT(1), PT(2), PT(3), PT(4), PT(5), PT(6), PT(7)
#if NB_SMALL_SIZE_CLASSES > 8
    , PT(8), PT(9), PT(10), PT(11), PT(12), PT(13), PT(14), PT(15)
#if NB_SMALL_SIZE_CLASSES > 16
    , PT(16), PT(17), PT(18), PT(19), PT(20), PT(21), PT(22), PT(23)
#if NB_SMALL_SIZE_CLASSES > 24
    , PT(24), PT(25), PT(26), PT(27), PT(28), PT(29), PT(30), PT(31)
#if NB_SMALL_SIZE_CLASSES > 32
    , PT(32), PT(33), PT(34), PT(35), PT(36), PT(37), PT(38), PT(39)
#if NB_SMALL_SIZE_CLASSES > 40
    , PT(40), PT(41), PT(42), PT(43), PT(44), PT(45), PT(46), PT(47)
#if NB_SMALL_SIZE_CLASSES > 48
    , PT(48), PT(49), PT(50), PT(51), PT(52), PT(53), PT(54), PT(55)
#if NB_SMALL_SIZE_CLASSES > 56
    , PT(56), PT(57), PT(58), PT(59), PT(60), PT(61), PT(62), PT(63)
#if NB_SMALL_SIZE_CLASSES > 64
#error "NB_SMALL_SIZE_CLASSES should be less than 64"
#endif /* NB_SMALL_SIZE_CLASSES > 64 */
#endif /* NB_SMALL_SIZE_CLASSES > 56 */
#endif /* NB_SMALL_SIZE_CLASSES > 48 */
#endif /* NB_SMALL_SIZE_CLASSES > 40 */
#endif /* NB_SMALL_SIZE_CLASSES > 32 */
#endif /* NB_SMALL_SIZE_CLASSES > 24 */
#endif /* NB_SMALL_SIZE_CLASSES > 16 */
#endif /* NB_SMALL_SIZE_CLASSES >  8 */
};
```

### usedpools的巧妙结构

通常来说，巧妙和理解成本在一定程度上也是成正比的。按照一般思路，如果想要用`usedpools`中每一项都存放一个pool的双向链表的话，`usedpools`每一项都应该是一个`poolp`指针。如果要给每个双向链表一个虚拟的头结点，那就需要多分配整个pool_header的大小，但是实际我们只需要使用`nextpool`和`prevpool`这两个成员。

下图展示了`usedpools`刚刚初始化完成时的状态，`usedpool[i + i]`以及`usedpools[i + i + 1]`中都存放着`usedpools[i-1 + i-1]`的地址。但是这个地址被当作了pool_header，所以从这个地址作`.nextpool`操作和`.prevpool`操作都会取到自身，这也就是初始化的头结点的状态。

在添加`pool_header`结构体到链表后，`nextpool`和`prevpool`就会连接到一个真正的`pool_header`对象上了。

![graph-usedpools](graph-usedpools.svg)
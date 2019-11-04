---
title: CPython Function Call
date: 2019-09-12 20:45:41
categories: python源码
tags: [python, 源码, cpython, python-objects]
---

## 前言

在python中，一切皆是对象，函数也不例外。函数也是python中的一等对象[`first-class object`](https://stackoverflow.com/questions/245192/what-are-first-class-objects)之一。所谓一等对象，代表了这类对象能够被动态地创建，销毁，作为函数的参数和返回值，拥有和其他变量一样的特权。在C语言中，函数以指针的方式存在，函数指针指向的是什么呢？我不确定，但我猜想是函数编译成的机器指令的地址，函数的调用也就是指令跳转的过程。python中的函数实际上也是类似的思想，不止函数如此，整个python虚拟机也都非常类似操作系统执行c代码的过程。



## 函数作为对象

函数虽然更像是一种**动作**，但是动作也能够以**数据**的方式存在，这样的数据也就是指令。python中的函数，也就是类型为`function`的对象，在CPython中对应的结构体为`PyFunctionObject`。函数对象的定义在`funcobject.h`中，摘抄定义如下：

```C
typedef struct {
    PyObject_HEAD
    PyObject *func_code;		/* A code object */
    PyObject *func_globals;		/* A dictionary (other mappings won't do) */
    PyObject *func_defaults;	/* NULL or a tuple */
    PyObject *func_closure;		/* NULL or a tuple of cell objects */
    PyObject *func_doc;			/* The __doc__ attribute, can be anything */
    PyObject *func_name;		/* The __name__ attribute, a string object */
    PyObject *func_dict;		/* The __dict__ attribute, a dict or NULL */
    PyObject *func_weakreflist;	/* List of weak references */
    PyObject *func_module;		/* The __module__ attribute, can be anything */

    /* Invariant:
     *     func_closure contains the bindings for func_code->co_freevars, so
     *     PyTuple_Size(func_closure) == PyCode_GetNumFree(func_code)
     *     (func_closure may be NULL if PyCode_GetNumFree(func_code) == 0).
     */
} PyFunctionObject;
```

<!-- more -->

其中，最重要的也就是`func_code`域，这也就相当于c语言的函数编译后所对应的机器指令。其余的参数一部分为对象提供标识和信息，如`func_doc`，`func_name`等，另一部分则是为`func_code`的执行提供环境，如`func_globals`，`func_defaults`，`func_closure`。本文暂时不会涉及对`PyCodeObject`的介绍，其实其也就是python代码编译后所产生的字节码所对应的对象。



## 静态还是动态

怎么理解python中的动态和静态？python作为一门动态语言，它实际上也存在着编译/运行的过程，编译期能够决定的是在我看来也就是静态的。

函数是静态的还是动态的呢？首先，python中的函数绝对是动态的，python中的函数可以动态的创建和修改，只要有了`PyCodeObject`和执行的环境，就能创建一个`PyFunctionObject`，在运行时，我们也可以修改`func_defaults`等变量来改变函数的行为。

那么`Code`对象是静态还是动态的呢？个人认为，`code`对象更像是静态的，虽然code对象能够被动态地创建，但是其在创建之后是不能够再被修改的。通常，python中的函数，无论是函数，方法，还是lambda表达式，其中所包含的所要执行的代码块，在编译期就已经确定了。`code`对象中，已经知道了所有要执行的字节码，所有常量，局部变量名，全局变量名和闭包名。但是这些变量名对应的值，将在函数的运行期才能够获得。



## 函数的创建

先看一段函数创建的简单字节码

```python
>>> def a(a, b=1, *args, **kwargs):
...     pass

>>> dis.dis(f)
  2           0 LOAD_CONST               1 (1)
              3 LOAD_CONST               2 (<code object a at 02B85AD0, file "<stdin>", line 2>)
              6 MAKE_FUNCTION            1
              9 STORE_FAST               0 (a)
             12 LOAD_CONST               0 (None)
             15 RETURN_VALUE
```

很明显，创建函数调用了`MAKE_FUNCTION`这个指令，从`ceval.c`中截取相关代码如下：

```c
 TARGET(MAKE_FUNCTION)
 {
     v = POP(); /* code object */
     x = PyFunction_New(v, f->f_globals);
     Py_DECREF(v);
     /* XXX Maybe this should be a separate opcode? */
     if (x != NULL && oparg > 0) {
         v = PyTuple_New(oparg);
         if (v == NULL) {
             Py_DECREF(x);
             x = NULL;
             break;
         }
         while (--oparg >= 0) {
             w = POP();
             PyTuple_SET_ITEM(v, oparg, w);
         }
         err = PyFunction_SetDefaults(x, v);
         Py_DECREF(v);
     }
     PUSH(x);
     break;
 }
```

函数的创建也就是用`code`对象和当前帧的`globals`为参数，随后设置了函数的默认参数。`PyFunction_New`和`PyFunction_SetDefaults`的实现都非常简单，基本都是在做默认的参数检查和初始化，这里也就不在赘述。




## 定义参数与传递参数

在介绍python函数的调用之前，我们必须明确函数的参数定义格式以及传递的格式，因为函数调用中很多精力也就是在处理函数的参数。python中的函数定义和传递格式非常自由，导致我很长一段时间都没有真正理解参数的含义，比如，定义和传递中的a=3实际上其实毫无关联，我却很容易将其联系为呼应的关系。

```python
def func(a, b=3, *args, **kwargs):
	pass
```

python中函数的定义一共包括以下若干种类型：

- 位置参数：a
- 带默认值的位置参数：b
- 扩展参数：c
- 扩展键值参数：d

```python
func(1, 2, 3, c=4)
```

python中函数参数的传递就只有以下两种类型：

- 位置参数：1，2，3
- 键值参数：c=4

python是如何将传递的参数填入定义中的呢？其中包含以下多个pass：

- 首先检查位置参数，传递的位置参数能够匹配定义中的位置参数
  - 传递的位置参数数量少于定义中的无默认值位置参数时，报错；否则按位置填入
  - 传递的位置参数多于定义中的位置参数+带默认参数的位置参数时，多余的参数则会进入扩展参数
- 其次检查键值参数
  - 对每个键值参数，匹配定义中的位置参数，如果发现已经匹配，则报错；否则可填入
  - 如果没有可匹配的位置参数，则进入扩展键值参数
- 最后检查默认参数
  - 第一步保证了所有没有默认值的位置参数已经被填入
  - 现在可对所有带默认值的位置参数进行检查，如果未赋值，则填入默认值

以上逻辑的代码实现位于`ceval.c`中的`PyEval_EvalCodeEx`函数内



## 函数的调用

函数调用的字节码是`CALL_FUNCTION`，也就是调用了`ceval.c`中的`call_function`函数，函数直接将栈指针的地址传入作为参数，另一个参数的低8位是位置参数个数，高8位则是键值参数个数。为什么要传栈指针的地址呢？因为C语言没有引用，函数内部要改变栈指针，就必须要传地址过去。

`call_function`做了什么呢？由于python中的可调用对象非常多，fast_function中对不同的可调用对象做了区分，首先区分了是否是`PyCFunctionObject`，然后判断了是否是方法。最终，普通的函数则走入了`fast_function`函数。

`fast_function`又做了什么呢？简单来说就是做了一个快速判断，如果函数无参，直接创建栈帧执行`codeobject`中的代码，如果函数带参数，则需要执行之前介绍的`PyEval_EvalCodeEx`处理参数。当然最终，这两者都会创建栈帧，执行`func_code`中存放的字节码。
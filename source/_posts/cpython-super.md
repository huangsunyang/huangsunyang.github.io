---
title: CPython Super
date: 2020-04-21 21:55:05
categories: python源码
tags: [python, 源码, cpython, python-objects]
---

## 什么是super

`super`实际上就是抽象的父类对象，用面向对象的方式来调用父类方法的一层封装。典型的使用方式如下：

```python
class Base(object):
    def __init__(self):
        pass
    
    @classmethod
    def test(cls):
        pass

class Derived(Base):
    def __init__(self):
        super(Derived, self).__init__()     # (1)
        # super().__init__()                # python3
        # Base.__init__(self)               # 非面向对象
    
    @classmethod
    def test(cls):
        super(Derived, cls).test()          # (3)
        # super().test()                    # python3
```

## super的四种用法

根据`super`的文档，其一共有三种用法：

- super(type, obj) -> bound super object; requires isinstance(obj, type)
- super(type) -> unbound super object
- super(type, type2) ->bound super object; requires issubclass(type2, type)

其中，第二种用法相对少见。除此之外，在`python3`中，可以使用无参数的super。

## super的实现

`super`在实现上是一个内置类型，定义在`typeobject.c`中，其结构体定义如下：

```c
typedef struct {
    PyObject_HEAD
    PyTypeObject *type;			// __thisclass__ the class invoking super
    PyObject *obj;				// __self__ the instance invoking super
    PyTypeObject *obj_type;		// __self_class__ the type of __self__
} superobject;
```

简单来说，`super`实现的是一层封装，将对`super`对象的函数调用转发到对应的父类中去。父类的寻找遵循python中的`mro`顺序。

### super对象的创建

super对象的创建相对比较简单，只是将第第一个参数赋值给`type`，第二个参数赋值给`obj`，通过调用`supercheck`进行类型检查，并计算出第三个参数的值。规律如下：

- `obj`是类型且`obj`需要是`type`的子类，则`obj_type`等于`obj`
- `obj`的类型是`type`的子类，则`obj_type`等于`Py_TYPE(obj)`
- `obj.__class__`是type的子类，则`obj_type`等于`obj.__class__`

### super对象获取父类数据

从super对象中获取数据用的是`super_getattro`函数，各种情况如下：

- 如果`obj_type`为NULL，则直接从当前`super`对象中获取数据，通常是出错的情况
- 如果获取的是`__class__`属性，则也从当前`super`对象获取
- 从`obj_type.__mro__`中找到`type`，从这一项之后开始遍历，从中找到第一个类（新式类/旧式类），从中寻找该变量并返回。如果变量是一个`descriptor`，则尝试调用其`tp_descr_get`方法。
- 如果寻找失败，则从当前`super`对象中获取数据



## python3中的super

`python3`中的`super`能够省略参数，其具体实现是从当前栈帧中寻找第一个参数作为`obj`，从闭包中寻找`__class__`作为`type`。后者的实现细节较为复杂，甚至可以说比较混乱：

- 在语法分析阶段，如果使用了`super`关键字，就会隐式地将`__class__`加入到符号表
- `drop_class_free`中将判断`__class__`是否在局部变量中，如果存在，将其删除并标记``ste_needs_class_closure``
- 编译阶段通过`ste_needs_class_closure`标志位判断将其隐式加入到类的`cellvars`中



## 参考资料

1. https://stackoverflow.com/questions/36993577/schr%C3%B6dingers-variable-the-class-cell-magically-appears-if-youre-checking
2. https://www.artima.com/weblogs/viewpost.jsp?thread=281127
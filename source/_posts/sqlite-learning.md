---
title: SQLite Learning Resource
date: 2019-11-08 00:07:47
categories: sqlite源码
tags: [sqlite, 源码, c]
---

## WHY SQLite

为什么要学`SQLite`？起因来源于云风的《Lua源码赏析》这本小册子，里面提到了[reddit上的一个问题](https://www.reddit.com/r/programming/comments/63hth/ask_reddit_which_oss_codebases_out_there_are_so/)，问的是最值得阅读的well-designed的开源项目，其中`SQLite`广受好评，此外就是`Lua`的虚拟机（等我`python`再学习深入后也可以对照着看看`Lua`，毕竟`Lua`相对简单，其实更容易上手）。此外，作为一个非科班出生的客户端程序，对于服务端的一些知识了解其实是相对缺乏的，数据库一直是我的知识盲区之一，也希望乘此机会了解数据库的相关知识。

<!-- more -->

## 如何学习SQLite

在写这篇文章的时候，我还开始学习，只是做了这个决定，因此现在的我是从零开始。我所设想的学习过程主要分为三个阶段

### 学习使用SQLite

首先自然要学会`SQLite`数据库的使用，也可以顺便看看`python`提供的操作`SQLite`的api，这个时间不需要太长，大概一两天的时间，熟悉一下基本的概念即可。我目前搜集到的资料包括：

- [runoob网页资料](https://www.runoob.com/sqlite/sqlite-python.html)
- [SQLite官方文档SQL语法介绍](https://www.sqlite.org/index.html)
- [tutorialspoint网站教程](https://www.tutorialspoint.com/sqlite/index.htm)
- O'REILLY出版社的Using SQLite，大概看了一些感觉这本最好

### 了解SQLite架构

主要参考了[知乎上广大网友走过的老路](https://www.zhihu.com/question/22819578)，包含了一部分官方文档和书籍，以及一些博客：

- [官方文档中的架构介绍](https://www.sqlite.org/arch.html)
- [Inside SQLite](https://b-ok.cc/book/488419/0c3177)这本书

### 源代码学习

这一部分内容暂时没有能力规划..
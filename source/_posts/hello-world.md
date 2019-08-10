---
title: Hello Hexo I
date: 2019-08-9 17:26:38
categories: 日常工具
tags: [Hexo, 博客]
---
### 前言
第一篇[Hexo](https://hexo.io/)的博客，想了想还是写下搭建博客的过程，网上已经有不少类似的教程了，比如我所参考的[20分钟教你使用hexo搭建github博客](http://www.jianshu.com/p/e99ed60390a8)就是一篇很不错的教程，从Github账号的注册到node.js的安装都详细介绍了。相比之下，我这里的介绍就稍微简略一些了。


### 依赖
- Github账号
- git
- node.js

### 在github创建repo
在解决了上述依赖的情况下，首先需要在Github上创建一个新的repository，命名的规范如下，比如我的Github账户名为**huangsunyang**，那么这个repository的名字就为**huangsunyang.github.io**。

接下来，在电脑的某处新建一个文件夹，用于存放博客的数据文件。文件夹的选择根据个人的要求有所不同：
- 如果你仅仅需要在一台电脑上更新你的博客，那文件夹的位置和名称可以任意选择
- 如果你需要将数据存放在云端，比如Github上，你可以选择新建一个repository，将其作为你的博客文件夹
- 如果你既想将数据其存放在云端，又不想新建一个repository，那么，你的数据可以存放在**huangsunyang.github.io**的另一个分支上（此处以我的名字为例，实际上是：[你的用户名].github.io，下同）。我的教程就按照这一方案来讲解。

首先，将Github上创建的**huangsunyang.github.io**同步到本地
``` bash
$ git clone https://github.com/huangsunyang/huangsunyang.github.io
```
<!-- more -->

### 部署本地hexo环境
本地的hexo环境其实也是在同一个repo下，这里用了个小trick将其放在另一个分支下，通常我们只应该修改**hexo**分支上的文件，一般情况下不需要修改**master**分支

创建新的**hexo**分支

``` bash
$ cd huangsunyang.github.io
$ git checkout -b hexo
```

下载安装hexo全局环境
``` bash
$ npm install -g hexo-cli
```

初始化博客文件夹
``` bash
$ hexo init
```

此处如果提示出错，主要原因可能在于文件夹内有隐藏文件**.git**，因为博客文件夹在初始化时必须为空，因此我们暂时将其移走，待初始化后再移动回来。
``` bash
$ mv .git ..
$ hexo init
$ mv ../.git .
```

创建hexo本地环境
```
$ npm install hexo --save
$ npm install hexo-deployer-git --save
$ hexo generate
$ hexo server
```

此时我们在[本地](http://localhost:4000/)应该已经能预览博客的真实效果了

### 部署到github

初始化完毕后，我们需要修改博客的配置文件，也就是将博客链接到我们在Github上创建的repository。

``` bash
$ vi _config.yml
```

打开配置文件后，我们主要修改两处，第一处是开始的部分，其中除了`language`和`timezone`之外都可以自行填写
```
title: Decode
subtitle: programming blog by huangsunyang
description:
author: _huang
language: zh-CN
timezone: Asia/Shanghai
```

另一处在文件的末尾：
```
deploy:
type: git
repo: https://github.com/huangsunyang/huangsunyang.github.io.git
branch: master
```

修改完毕后保存，输入以下命令就大功告成了

```
$ hexo generate
$ hexo deploy
```
目前，在浏览器内输入[huangsunyang.github.io](http://huangsunyang.github.io)已经可以看到你的博客了

### 常用Hexo命令

#### Create a new post

``` bash
$ hexo new "My New Post"
```

More info: [Writing](https://hexo.io/docs/writing.html)

#### Run server

``` bash
$ hexo server
```

More info: [Server](https://hexo.io/docs/server.html)

#### Generate static files

``` bash
$ hexo generate
```

More info: [Generating](https://hexo.io/docs/generating.html)

#### Deploy to remote sites

``` bash
$ hexo deploy
```

More info: [Deployment](https://hexo.io/docs/deployment.html)

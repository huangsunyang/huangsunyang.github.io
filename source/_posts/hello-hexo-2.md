---
title: Hello Hexo II
date: 2019-08-10 17:26:38
categories: 
- 日常工具
tags:
- Hexo
- 博客
---

### 前言
[第一篇博客](https://huangsunyang.github.io/2019/08/09/hello-world/)大概介绍了如何在本地以及github上部署自己的hexo博客，但是人总是喜欢折腾，博客搭建完了就要考虑装修美观。我自己也稍微折腾了下，把一些踩过的坑在这里记录下

### 主题
原来的主题说实话真的不太好看，主题不需要太折腾，能看就好，[Hexo官网](https://hexo.io/themes/)上有不少的主题，有兴趣的可以自己看demo，我用的是比较主流的[Next主题](https://github.com/theme-next/hexo-theme-next)，个人认为比官网上大多数看到的都要好看。

主题的安装相对来说较为简单，只要把整个主题pull到本地的`/themes`目录下即可，然后修改一下`/_config.yml`，搜索`themes:`即可
```
# Extensions
## Plugins: https://hexo.io/plugins/
## Themes: https://hexo.io/themes/
theme: next # 这里改成文件夹的名字
```

<!-- more -->

### 菜单
刚建立完博客，我的标签页只有两个，首页和归档。

![默认的标签栏](origin_menu.png)

后来发现在`/themes/next/_config.yml`中可以配置，将预设的注释取消即可显示标签分类等菜单类别

```
# Usage: `Key: /link/ || icon`
# Key is the name of menu item. If the translation for this item is available, the translated text will be loaded, otherwise the Key name will be used. Key is case-senstive.
# Value before `||` delimiter is the target link.
# Value after `||` delimiter is the name of Font Awesome icon. If icon (with or without delimiter) is not specified, question icon will be loaded.
# When running the site in a subdirectory (e.g. domain.tld/blog), remove the leading slash from link value (/archives -> archives).
# External url should start with http:// or https://
menu:
  home: / || home
  about: /about/ || user
  tags: /tags/ || tags
  categories: /categories/ || th
  archives: /archives/ || archive
  #schedule: /schedule/ || calendar
  #sitemap: /sitemap.xml || sitemap
  #commonweal: /404/ || heartbeat
```

### 分类和标签
在主文件夹下输入，在`/source`目录下会多两个`categories`和`tags`目录，我对前端知识基本不了解，盲猜hexo是通过source获取显示的数据，根据配置的参数生成了最终的html网页，因此这相当于新建了两个html页面
```
hexo new page categories
hexo new page tags
```

在`/source/tags/index.md`中加一行，变为
```
---
title: tags
date: 2019-08-10 16:29:03
type: "tags"	# 加这一行
---
```

对另一个`/source/categories/index.md`同样添加一行`type: "categories"`

感觉上指定了这个页面显示的数据，如果交换的话，点击分类反而会显示标签的数据了


### 主页不显示全文

有时我们不希望文章在主页全部显示，通常建议对每一篇文章单独配置，在文中某个位置插入
```
<!-- more -->
```
在主页就只会显示这一行之前的部分了


### 插入图片
首先设置`/_config.yml`中的`post_asset_folder: true`，在创建新的post的时候会在`/source`目录下产生同名的文件夹，post引用的资源能够放在其中
在post中引用的时候，使用如下markdown语法即可
```
# _post
# ├── hello-hexo
# |   ├── pic_1.jpg
# |   └── pic_2.png
# └── hello-hexo.md

![图片显示名称](pic_1.jpg)
```
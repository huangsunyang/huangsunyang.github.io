---
title: Build Python
date: 2019-09-01 22:02:22
categories: python源码
tags: [python, 源码, 编译]
---

## 前言
很久之前我就尝试过编译python源码，但是最后好像以失败告终，今天偶然想起竟然异常顺利，终于把编译python源码的心愿完成了。之后就可以通过修改源码的方式来学习python了。

准备工具：
- [python2.7.15源码](https://www.python.org/downloads/release/python-2715/)
- Windows10 sdk

## 步骤
总的来说，编译python源码其实很简单，直接进入PCBuild文件路径调用build.bat即可。但是我这里会遇到了几个编译错误，估计大家也都会遇到。

```
C:\Program Files (x86)\MSBuild\Microsoft.Cpp\v4.0\V140\Microsoft.Cpp.Platform.targets(56,5): error MSB8020:The build tools for Visual Studio 2008 (Platform Toolset = 'v90') cannot be found. To build using the v90 build tools, please install Visual Studio 2008 build tools.  Alternatively, you may upgrade to the current Visual Studio tools by selecting the Project menu or right-click the solution, and then selecting "Retarget solution". [E:\game_development\books\Python-2.7.15\PCbuild\pythoncore.vcxproj]
```

首先是一个编译工具版本错误，我这里是visual studio 2015版本，重新打开解决方案vs会自动提示升级项目，直接升级即可。

<!--more-->

此外还会遇到以下两个编译错误，[在github上有人给出了解决方案](https://github.com/python-cmake-buildsystem/python-cmake-buildsystem/issues/161)


```
..\Modules\timemodule.c(811): error C2065: 'timezone': undeclared identifier [E:\game_development\books\Python-2.7.15\PCbuild\pythoncore.vcxproj]
..\Modules\timemodule.c(819): error C2065: 'timezone': undeclared identifier [E:\game_development\books\Python-2.7.15\PCbuild\pythoncore.vcxproj]
..\Modules\timemodule.c(822): error C2065: 'daylight': undeclared identifier [E:\game_development\books\Python-2.7.15\PCbuild\pythoncore.vcxproj]
..\Modules\timemodule.c(824): error C2065: 'tzname': undeclared identifier [E:\game_development\books\Python-2.7.15\PCbuild\pythoncore.vcxproj]
..\Modules\timemodule.c(824): error C2109: subscript requires array or pointer type [E:\game_development\books\Python-2.7.15\PCbuild\pythoncore.v
```


```
posixmodule.obj : error LNK2001: 无法解析的外部符号 __imp____pioinfo [E:\CS\Python\Python-2.7.15\PCbuild\pythoncore.vcxproj]
E:\CS\Python\Python-2.7.15\PCBuild\python27.dll : fatal error LNK1120: 1 个无法解析的外部命令 [E:\CS\Python\Python-2.7.15\PCbuild
\pythoncore.vcxproj]
```
将`_PyVerify_fd`中的函数替换了即可正常编译了
``` C
/* This function emulates what the windows CRT does to validate file handles */
int
_PyVerify_fd(int fd)
{
  //   const int i1 = fd >> IOINFO_L2E;
  //   const int i2 = fd & ((1 << IOINFO_L2E) - 1);

  //   static int sizeof_ioinfo = 0;

  //   /* Determine the actual size of the ioinfo structure,
  //    * as used by the CRT loaded in memory
  //    */
  //   if (sizeof_ioinfo == 0 && __pioinfo[0] != NULL) {
  //       sizeof_ioinfo = _msize(__pioinfo[0]) / IOINFO_ARRAY_ELTS;
  //   }
  //   if (sizeof_ioinfo == 0) {
  //       /* This should not happen... */
  //       goto fail;
  //   }

  //   /* See that it isn't a special CLEAR fileno */
  //   if (fd != _NO_CONSOLE_FILENO) {
  //       /* Microsoft CRT would check that 0<=fd<_nhandle but we can't do that.  Instead
  //        * we check pointer validity and other info
  //        */
  //       if (0 <= i1 && i1 < IOINFO_ARRAYS && __pioinfo[i1] != NULL) {
  //           /* finally, check that the file is open */
  //           my_ioinfo* info = (my_ioinfo*)(__pioinfo[i1] + i2 * sizeof_ioinfo);
  //           if (info->osfile & FOPEN) {
  //               return 1;
  //           }
  //       }
  //   }
  // fail:
  //   errno = EBADF;
  //   return 0;
     //a call to _get_osfhandle with invalid fd sets errno to EBADF
    if (_get_osfhandle(fd) == INVALID_HANDLE_VALUE)
        return 0;
    else
        return 1;
}
```

---
title: Tick and Tick
date: 2019-08-15 00:03:46
categories: 算法
tags: [算法, ACM, hdu, C++]
---


## 前言
今天遇到一道[有趣的题目](http://acm.hdu.edu.cn/showproblem.php?pid=1006)，开始以为时间是离散，于是遍历了每一秒时刻的情况，发现和答案有一定的误差。后来意识到了指针都是连续移动的，当天想了很久也没想出啥好方法，看网上的讨论给的方法也很暴力。第二天灵光一闪想出了一个不那么粗暴的的方法，在这里记录一下。

## 从点到线
我的思路一直是离散的，也就是“点”的思想，总想要计算某个时刻指针的位置，判断某个时刻能不能满足条件。但是在连续的情况下，这样的思路是非常耗费计算资源的，这有点像微分的思想，我可以把时间间隔缩小到0.0001秒，这样的误差可能就可以忽略不计，但肯定会超时。

另一种思路去考虑刚好满足条件的时刻，与刚好不满足条件的时刻，这个区间内的所有时间也就是满足条件的时间。由于三个指针都是匀速运动的，它们两两之间的角度差也是线性变化的，函数图像如下图所示。

<!--more-->

![函数图像示意](tick_func.png)

当给定一个角度d时，我们希望找到三个函数图像都在y=d这条直线之上的公共部分，这些公共部分的长度之和，也就是最终的结果。计算区间的过程可以从左到右遍历所有的交点，当遇到导数为正部分的交点时，说明该函数进入了满足条件的区间，我们对一个记录值+1，遇到导数为负的交点时，我们对一个记录值-1，则说明函数离开了满足条件的区间。记录值从3变为2的那一段区间即三个函数都满足条件的区间。

## 源码
```c++
# include <cstdio>
# include <cstdlib>
# include <math.h>
# include <vector>
# include <algorithm>

using namespace std;

const double time = 12 * 60 * 60;

double sec_speed = 6.0;
double min_speed = 0.1;
double hour_speed = 1.0 / 120;

double sec_min_diff = sec_speed - min_speed;
double sec_hour_diff = sec_speed - hour_speed;
double min_hour_diff = min_speed - hour_speed;

double sec_min_cycle = 360 / sec_min_diff;
double sec_hour_cycle = 360 / sec_hour_diff;
double min_hour_cycle = 360 / min_hour_diff;

void cal_percent(double degree) {
    if (degree <= 0.0001) {
        degree = 0.0001;
    }

    double sec_min_start = degree / sec_min_diff;
    double sec_hour_start = degree / sec_hour_diff;
    double min_hour_start = degree / min_hour_diff;

    double sec_min_end = sec_min_cycle - sec_min_start;
    double sec_hour_end = sec_hour_cycle - sec_hour_start;
    double min_hour_end = min_hour_cycle - min_hour_start;

    std::vector<double> vec = {sec_hour_start, sec_hour_end, sec_min_start, sec_min_end, min_hour_start, min_hour_end};
    std::vector<double> cycle = {sec_hour_cycle, sec_hour_cycle, sec_min_cycle, sec_min_cycle, min_hour_cycle, min_hour_cycle};

    int num_in = 0;
    double duration = 0.0;
    double last_enter_time = -1;

    while (true) {
        vector<double>::iterator min_ptr = std::min_element(vec.begin(), vec.end());
        if (*min_ptr >= time) break;
        int pos = std::distance(vec.begin(), min_ptr);
        int is_end = pos % 2;

        if (not is_end) {
            num_in++;
            if (num_in == 3) {
                last_enter_time = vec[pos];
            }
            vec[pos] += cycle[pos];
        } else {
            num_in--;
            if (last_enter_time > 0) {
                duration += vec[pos] - last_enter_time;
            }
            last_enter_time = -1;
            vec[pos] += cycle[pos];
        }
    }

    printf("%.3lf\n", duration / time * 100);
}


int main() {
    while (true) {
        double degree;
        scanf("%lf", &degree);
        if (int(degree) == -1) return 0;
        cal_percent(degree);
    }
}

```

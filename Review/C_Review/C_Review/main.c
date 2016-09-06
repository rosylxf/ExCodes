//
//  main.c
//  C_Review
//
//  Created by ricky on 8/24/16.
//  Copyright © 2016 ricky. All rights reserved.
//
/*
 * 参考:
 * http://www.cnblogs.com/mjios/archive/2013/03/24/2979482.html
 */

#include <stdio.h>

typedef int Integer;

typedef char* String;

struct MyPoint {
    float x;
    float y;
};
typedef struct MyPoint Point;

typedef Point *PP;

enum Season {spring, summer, autumn, winter};
typedef enum Season Season;

int main(int argc, const char * argv[]) {
    
//    const int *p; //常量指针，p可变，p指向的对象不可变
//    int const *p; //常量指针，p可变，p指向的对象不可变
//    int *const p; //常指针，p不可变，指向的对象可以变
//    const int* const p;//指针p和其指向的内容都不可以变
    
    // insert code here...
    
    /*
     * 1. 给基本类型起别名
     * typedef int Integer;
     */
    Integer i = 10;
    printf("%d\n", i);

    /*
     * 2. typedef与指针
     * typedef char* String;
     */
    String str = "This is a string";
    printf("%s\n", str);

    /*
     *3. typedef与结构体
     */
    struct MyPoint p;
    p.x = 10.0f;
    p.y = 20.0f;

    //用typedef后的类型
    Point p2;
    p2.x = 10.0f;
    p2.y = 20.0f;

    /*
     * 4. typedef与指向结构体的指针
     */
    Point point = {10, 20};
    PP pp = &point;
    printf("x=%f，y=%f", pp->x, pp->y);

    /*
     * typedef与枚举
     */
    Season s = spring;

    /*
     * 5. typedef与指向函数的指针
     */

    

    return 0;
}



















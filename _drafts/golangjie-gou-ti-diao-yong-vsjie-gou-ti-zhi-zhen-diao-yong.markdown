---
title: Golang结构体调用vs结构体指针调用
date: 2022-05-14 10:18:00 Z
categories:
- Language
tags:
- Golang
---

* content
{:toc}

两种结构体调用方式都能大部分满足我们的需求，为什么要有两种调用方式呢？他们间的异同点是什么呢？

本文浅谈下Golang结构体调用和结构体指针调用间的区别。

并引出2个问题：
1.结构体指针调用确实如网上说的那么高效么？
2.如果高效，高效的原因是什么呢？

# 调用定义
```golang
func (s *MyStruct) pointerMethod() { } // method on pointer
func (s MyStruct)  valueMethod()   { } // method on value
```

# 区别
1.最重要的一点：接受者是否需要进行修改？如果需要修改，必须使用结构体指针调用。（slice/map作为引用类型，它们的行为有些微妙，但是例如要在函数里修改slice的长度，必须使用结构体指针调用）

modify field of slice
```golang

type action struct {
	name int
}

type person struct {
	act  action
	name string
	age  int
}

type image struct {
	data map[int]int
}

type Books struct {
	title   string
	author  string
	book_id int
}

type SliceTest struct {
	s []int
}

func (s SliceTest) valueAppend(p int) {
	s.s = append(s.s, p)

}
func (s *SliceTest) pointerAppend(p int) {
	s.s = append(s.s, p)
}

func (s SliceTest) valueSet(p int) {
	if len(s.s) == 0 {
		return
	}
	s.s[0] = p
}

func (s *SliceTest) pointerSet(p int) {
	if len(s.s) == 0 {
		return
	}
	s.s[0] = p
}

func printSlice(s SliceTest) {
	fmt.Println("slice:", s.s, "len:", len(s.s), "cap:", cap(s.s))
}
unc main() {
	s := SliceTest{s: make([]int, 0)}
	s.valueAppend(10)
	printSlice(s)
	s.pointerAppend(10)
	printSlice(s)
	s.pointerSet(11)
	printSlice(s)
	s.valueSet(12)
	printSlice(s)
}

```
output
```text
slice: [] len: 0 cap: 0
slice: [10] len: 1 cap: 1
slice: [11] len: 1 cap: 1
slice: [12] len: 1 cap: 1
```
modify field of 

结构体调用是拷贝调用者参数，如果进行修改

# 性能

# 参考
[defining-golang-struct-function-using-pointer-or-not](https://stackoverflow.com/questions/25382073/defining-golang-struct-function-using-pointer-or-not)



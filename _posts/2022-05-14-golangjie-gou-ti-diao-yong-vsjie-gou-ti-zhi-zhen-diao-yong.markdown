---
title: Golang结构体值调用vs指针调用
date: 2022-05-14 10:18:00 Z
categories:
- Language
tags:
- Golang
comments: true
---

* content
{:toc}

两种结构体调用方式都能大部分满足我们的需求，为什么要有两种调用方式呢？
他们间的异同点是什么呢？

本文浅谈下Golang结构体值调用和指针调用间的区别。

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
modify field of other type
```golang

type OtherTest struct {
	num int
}

func (p OtherTest) valueMethod(num int) {
	p.num = num
}

func (p *OtherTest) pointerMethod(num int) {
	p.num = num
}
func main(){
        s := OtherTest{num: 0}
	fmt.Println(s)
	s.valueMethod(10)
	fmt.Println(s)
	s.pointerMethod(10)
	fmt.Println(s)
}
```
output
```text
{0}
{0}
{10}
```

从这些例子看，如果使用结构体指针调用修改这些字段，修改对于调用者是可见的。
但是使用结构体值调用，是通过参数拷贝实现的，修改对于调用者是不可见的。

运用场景：
使用结构体值调用来替代结构体指针调用，可以遵循参数不可变行性质，更加安全。这种用法叫做“防御性拷贝”。

2.对效率的考虑，如果接受者是一个很大的结构体，使用指针调用更高效
这块后面会做个简单验证

总之除了修改字段外，这两种调用方式几乎没别的区别了；可能因为结构体值调用有参数拷贝操作，他们之前性能差异比较大


# 性能
写了个简单代码，粗略验证下结构体指针调用是否如网上说的那么高效

benchmark demo
```golang
package main

import (
	"testing"
)

type StructTest struct {
	num  int
	num1 int
	num2 int
	num3 int
	str  string
	b    bool
}

func (p StructTest) valueMethod(num int) {
	p.num = num
	p.num1 = num
	p.num2 = num
	p.num3 = num
	p.str = "XXXX"
	p.b = true
}

func (p *StructTest) pointerMethod(num int) {
	p.num = num
	p.num1 = num
	p.num2 = num
	p.num3 = num
	p.str = "XXXX"
	p.b = true
}

func BenchmarkValStruct(b *testing.B) {
	p := StructTest{num: 10}
	for j := 0; j < b.N; j++ {
		for i := 0; i < 1e8; i++ {
			p.valueMethod(i)
		}
	}
}

func BenchmarkPointerStruct(b *testing.B) {
	p := StructTest{num: 10}
	for j := 0; j < b.N; j++ {
		for i := 0; i < 1e8; i++ {
			p.pointerMethod(i)
		}
	}
}
```
output of call by value 
```bash
go test -benchmem -run=^$ -bench ^BenchmarkValStruct$ demo/gobench  -benchtime=
60s
goos: darwin
goarch: amd64
pkg: demo/gobench
cpu: Intel(R) Core(TM) i5-8257U CPU @ 1.40GHz
BenchmarkValStruct-8        1356          55742350 ns/op               0 B/op          0 allocs/op
PASS
ok      demo/gobench    81.456s
```
output of call by pointer
```bash
go test -benchmem -run=^$ -bench ^BenchmarkPointerStruct$ demo/gobench  -benchtime=60s
goos: darwin
goarch: amd64
pkg: demo/gobench
cpu: Intel(R) Core(TM) i5-8257U CPU @ 1.40GHz
BenchmarkPointerStruct-8            1260          56138387 ns/op               0 B/op          0 allocs/op
PASS
```
从性能测试结果可以比较明显看出结构体值调用效率会高一些，但是并不是很明显。
所以并不是结构体指针调用效率一定比结构体值调用性能高；跟结构体中字段大小和数量有一定关系，需要实际验证！



# 参考
[defining-golang-struct-function-using-pointer-or-not](https://stackoverflow.com/questions/25382073/defining-golang-struct-function-using-pointer-or-not)  
[why-are-receivers-pass-by-value-in-go](https://stackoverflow.com/questions/18435498/why-are-receivers-pass-by-value-in-go/18436251#18436251)


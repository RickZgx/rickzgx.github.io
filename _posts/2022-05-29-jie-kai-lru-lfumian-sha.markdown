---
title: 揭开LRU、LFU面纱
date: 2022-05-29 11:05:00 Z
categories:
- Language
- Algorithm
tags:
- Golang
- Algorithm
- Cache
---

* content
{:toc}

LRU和LFU两个英文串各位肯定并不陌生，那是否很深刻理解如下几个问题（也是我最近一直挂在心上的几个问题）：
LRU和LFU是指什么呢？它们之间有什么区别和联系呢？它们实现原理是什么呢？分别适用的场景是什么呢？
各位也许只能答出来1、2个，本文将阅读相关文献和走读Go开源LRU、LFU代码实现带领各位揭开LRU、LFU二者的面纱！

# 定义
## LRU
from wikipeda
> Discards the least recently used items first. This algorithm requires keeping track of what was used when, which is expensive if one wants to make sure the algorithm always discards the least recently used item. 

LRU其实是Least Recently Used首字母开头的缩写，即最近最少使用。LRU是一种页面置换算法，选主最近最远的页面进行淘汰。

使用golang-lru进行演示
```golang
package main

import (
	"fmt"

	lru "github.com/hashicorp/golang-lru"
)

func main() {
	c, _ := lru.New(5)
	for i := 0; i < 10; i++ {
		c.Add(i, i*i)
	}
	for i := 0; i < 10; i++ {
		fmt.Println(c.Get(i))
	}
	fmt.Println(c.Len())
	fmt.Println(c.Keys()...)

}
output
```
<nil> false
<nil> false
<nil> false
<nil> false
<nil> false
25 true
36 true
49 true
64 true
81 true
5
5 6 7 8 9
```bash

```

## LFU

# 实现原理

## LRU 
init
底层整体使用链表、哈希表拉来实现
初始化特定大小LRU，相当于初始化list、map，并记录LRU大小；
```golang
type LRU struct {
	size      int //LRU大小
	evictList *list.List //map存放键值对，主要判断最久没更新的键值对，供后续淘汰使用
	items     map[interface{}]*list.Element //map存放键值对
	onEvict   EvictCallback //淘汰回调函数
}

func NewLRU(size int, onEvict EvictCallback) (*LRU, error) {
	if size <= 0 {
		return nil, errors.New("must provide a positive size")
	}
	c := &LRU{
		size:      size,
		evictList: list.New(),
		items:     make(map[interface{}]*list.Element),
		onEvict:   onEvict,
	}
	return c, nil
}
```

put

```golang
// Add adds a value to the cache.  Returns true if an eviction occurred.
func (c *LRU) Add(key, value interface{}) (evicted bool) {
	// Check for existing item
	if ent, ok := c.items[key]; ok {
		c.evictList.MoveToFront(ent)
		ent.Value.(*entry).value = value
		return false
	}

	// Add new item
	ent := &entry{key, value}
	entry := c.evictList.PushFront(ent)
	c.items[key] = entry

	evict := c.evictList.Len() > c.size
	// Verify size not exceeded
	if evict {
		c.removeOldest()
	}
	return evict
}
```

get

```golang
// Get looks up a key's value from the cache.
func (c *LRU) Get(key interface{}) (value interface{}, ok bool) {
	if ent, ok := c.items[key]; ok {
		c.evictList.MoveToFront(ent)
		if ent.Value.(*entry) == nil {
			return nil, false
		}
		return ent.Value.(*entry).value, true
	}
	return
}

```

## LFU

# 二者区别

# 适用场景

# 参考
[LRU wiki](https://en.wikipedia.org/wiki/Cache_replacement_policies#Least_recently_used_(LRU))





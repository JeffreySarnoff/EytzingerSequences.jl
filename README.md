# EytzingerSequences.jl

#### Copyright 2024 by Jeffrey Sarnoff

> initial development: 2024-08-31 .. 2024-08-31

[![Build Status](https://github.com/JeffreySarnoff/EytzingerSequences.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JeffreySarnoff/EytzingerSequences.jl/actions/workflows/CI.yml?query=branch%3Amain)


#### acknowledgments

Thanks to Páll Haraldsson for [this discourse post on Eytzinger searching](https://discourse.julialang.org/t/fastest-sorted-container-search-challenge-and-new-2021-search-algorithm/97076/1) that found my attention.

### related material

- https://algorithmica.org/en/eytzinger
  - https://github.com/CppCon/CppCon2022/blob/main/Presentations/binary-search-cppcon.pdf  
- https://arxiv.org/pdf/1509.05053
- https://github.com/patmorin/iterate/blob/master/iterate.c
- https://github.com/gammazero/eytzinger/blob/main/eytzinger.go
- https://www.bazhenov.me/posts/faster-binary-search-in-rust/
  - https://github.com/bazhenov/eytzinger-layout/blob/master/src/lib.rs

### history

| version | notable developments  | additional notes      |
|:-------:|:----------------------|:----------------------|
| 0.1.0   | EytzingerSequences.jl |                       |
|         |                       | struct Eytzinger{T}   |
|         |                       | eytzinger(n)          |
|         |                       |                       |






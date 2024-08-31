# https://github.com/bazhenov/eytzinger-layout/blob/master/src/lib.rs
#=

use rand::{thread_rng, Rng};
#[cfg(feature = "prefetch")]
use std::{
    arch::x86_64::{_mm_prefetch, _MM_HINT_T0},
    ptr,
};

pub struct Eytzinger(Vec<u32>);

impl From<&[u32]> for Eytzinger {
    fn from(input: &[u32]) -> Self {
        fn move_element(a: &[u32], b: &mut [u32], mut i: usize, k: usize) -> usize {
            if k <= a.len() {
                i = move_element(a, b, i, 2 * k);
                b[k] = a[i];
                i = move_element(a, b, i + 1, 2 * k + 1);
            }
            i
        }
        let mut result = Vec::with_capacity(input.len() + 1);
        result.resize(input.len() + 1, 0);
        move_element(&input[..], &mut result[..], 0, 1);
        Self(result)
    }
}

impl Eytzinger {
    /// Binary search over eytzinger layout array (branchless version)
    ///
    /// returns index of an element found or `0` is there is no match
    #[inline]
    pub fn binary_search_branchless(&self, target: u32) -> usize {
        let mut idx = 1;
        while idx < self.0.len() {
            #[cfg(feature = "prefetch")]
            unsafe {
                let prefetch = self.0.as_ptr().wrapping_offset(2 * idx as isize);
                _mm_prefetch::<_MM_HINT_T0>(ptr::addr_of!(prefetch) as *const i8);
            }
            let el = self.0[idx];
            idx = 2 * idx + usize::from(el < target);
        }
        idx >>= idx.trailing_ones() + 1;
        usize::from(self.0[idx] == target) * idx
    }

    /// Binary search over eytzinger layout array
    ///
    /// returns index of an element found or `0` is there is no match
    #[inline]
    pub fn binary_search(&self, target: u32) -> usize {
        let mut idx = 1;
        while idx < self.0.len() {
            #[cfg(feature = "prefetch")]
            unsafe {
                let prefetch = self.0.as_ptr().wrapping_offset(2 * idx as isize);
                _mm_prefetch::<_MM_HINT_T0>(ptr::addr_of!(prefetch) as *const i8);
            }
            let el = self.0[idx];
            if el == target {
                return idx;
            }
            idx = 2 * idx + usize::from(el < target);
        }
        0
    }

    pub fn as_slice(&self) -> &[u32] {
        &self.0
    }
}

/// Generates an `Vec<u32>` of a given size with aproximately 0.5 coverage
///
/// First element will always be `1` and the last one is `max`. Coverage is the proportion
/// of elements in the range `1..max` which are present in resulting vector.
/// The idea behind this algorithm is the following. If you will generate random number between
/// `1..result.last()` the probability of `result` contains this number is 0.5.
pub fn generate_data(size: usize) -> Vec<u32> {
    let mut result = Vec::with_capacity(size);
    let mut rng = thread_rng();
    let mut s = 1;
    result.push(s);
    while result.len() < size {
        s += 1 + 2 * u32::from(rng.gen::<bool>());
        result.push(s);
    }

    result
}

#[cfg(test)]
mod test {

    use super::*;

    #[test]
    fn check_eytzinger_create_simple() {
        let input = vec![1, 2, 3, 4, 5, 6, 7, 8, 10];
        // let expected = vec![0, 5, 3, 7, 1, 4, 6, 8, 0, 2];
        let expected = vec![0, 6, 4, 8, 2, 5, 7, 10, 1, 3];
        let result = Eytzinger::from(&input[..]);
        assert_eq!(expected, result.as_slice());

        assert_eq!(1, result.binary_search_branchless(6));
        assert_eq!(4, result.binary_search_branchless(2));
        assert_eq!(0, result.binary_search_branchless(9));
        assert_eq!(0, result.binary_search_branchless(11));
    }

    #[test]
    fn check_eytzinger_search() {
        let input = vec![0, 1, 2, 3, 4];
        let eytz = Eytzinger::from(&input[..]);

        for i in input {
            assert!(eytz.binary_search_branchless(i) > 0);
        }
        assert!(eytz.binary_search_branchless(6) == 0)
    }

    #[test]
    fn check_eytzinger_branchless_functional() {
        let input = generate_data(1_000);
        let eytz = Eytzinger::from(&input[..]);

        for i in &input {
            let idx = eytz.binary_search_branchless(*i);
            let expected = eytz
                .as_slice()
                .iter()
                .enumerate()
                .find(|(_, el)| el == &i)
                .map(|(idx, _)| idx)
                .unwrap();
            assert_eq!(expected, idx);
        }
        assert!(eytz.binary_search_branchless(input.last().unwrap() + 1) == 0);
    }

    #[test]
    fn check_eytzinger_functional() {
        let input = generate_data(1_000);
        let eytz = Eytzinger::from(&input[..]);

        for i in &input {
            let idx = eytz.binary_search_branchless(*i);
            let expected = eytz
                .as_slice()
                .iter()
                .enumerate()
                .find(|(_, el)| el == &i)
                .map(|(idx, _)| idx)
                .unwrap();
            assert_eq!(expected, idx);
        }
        assert!(eytz.binary_search(input.last().unwrap() + 1) == 0);
    }
}
=#

#                   >>>>>>>>>>>>>>>>>      <<<<<<<<<<<<<<<<<<<<<

#=
https://github.com/bazhenov/eytzinger-layout/blob/master/benches/bench.rs
#![feature(lazy_cell)]

use criterion::{criterion_group, criterion_main, BatchSize, BenchmarkId, Criterion};
use eytzinger_layout::{generate_data, Eytzinger};
use rand::{thread_rng, Rng};
use std::cell::LazyCell;

fn criterion_benchmark(c: &mut Criterion) {
    const SIZE: &[usize] = &[
        1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768, 65536, 131072,
    ];

    {
        let mut g = c.benchmark_group("std");
        for size in SIZE {
            let data = LazyCell::new(|| {
                let data = generate_data(size * 1024);
                let max = *data.last().unwrap();
                (data, max)
            });
            let size_kb = size * 4;
            g.bench_with_input(BenchmarkId::from_parameter(size_kb), size, |b, &_| {
                let (data, max) = &*data;
                let mut rng = thread_rng();
                b.iter_batched(
                    move || rng.gen_range(1..*max),
                    move |i| data.binary_search(&i),
                    BatchSize::SmallInput,
                );
            });
        }
    }

    {
        let mut g = c.benchmark_group("eytzinger branchless");
        for size in SIZE {
            let data = LazyCell::new(|| {
                let data = generate_data(size * 1024);
                let max = data.last().unwrap();
                let eytzinger = Eytzinger::from(&data[..]);
                (eytzinger, *max)
            });
            let size_kb = size * 4;
            g.bench_with_input(BenchmarkId::from_parameter(size_kb), size, |b, &_| {
                let (eytzinger, max) = &*data;
                let mut rng = thread_rng();
                b.iter_batched(
                    move || rng.gen_range(1..*max),
                    move |i| eytzinger.binary_search_branchless(i),
                    BatchSize::SmallInput,
                );
            });
        }
    }

    {
        let mut g = c.benchmark_group("eytzinger");
        for size in SIZE {
            let data = LazyCell::new(|| {
                let data = generate_data(size * 1024);
                let max = data.last().unwrap();
                let eytzinger = Eytzinger::from(&data[..]);
                (eytzinger, *max)
            });
            let size_kb = size * 4;
            g.bench_with_input(BenchmarkId::from_parameter(size_kb), size, |b, &_| {
                let (eytzinger, max) = &*data;
                let mut rng = thread_rng();
                b.iter_batched(
                    move || rng.gen_range(1..*max),
                    move |i| eytzinger.binary_search(i),
                    BatchSize::SmallInput,
                );
            });
        }
    }
}

criterion_group!(benches, criterion_benchmark);
criterion_main!(benches);
=#
const Vec = Vector{T} where {T}
const Tup = Tuple{Vararg{T,N}} where {T,N}
const VecOrTup = Union{Vector{T}, Tuple{Vararg{T,N}}} where {T,N}

function move_element(a::VecOrTup, b::Vec, i, k) where {T,N}
    if k <= length(a)
        i = move_element(a, b, i, 2 * k)
        b[k] = a[i]
        i = move_element(a, b, i + 1, 2 * k + 1)
    end
    i
end

function eytzinger_moves(in::VecOrTup, out::Vec, i, k) where {T,N}
    move_element(in, out, 0, 1)
    out
end

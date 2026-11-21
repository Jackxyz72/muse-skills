---
name: golf-byte-mastery
description: >
  Code golf and raw byte mastery: golf principles in JS/Python/C/Rust, hex dumps without libraries, byte-level image understanding, binary patching, ELF header parsing, reverse engineering patterns. Use when minimizing code size or doing low-level byte manipulation.
license: MIT
---

# Golf Code & Raw Byte Mastery

## Code Golf Principles
- Minimise character/byte count at all costs
- Exploit language quirks, operator precedence, implicit conversions
- Use short variable names (single letter, _ as throwaway)
- Abuse default parameters, template magic, preprocessor
- Chain operations: `x+=y<x?z:w` instead of `if(y<x)x+=z;else x+=w`
- Use eval/exec for dynamic code generation
- Leverage bitwise ops over arithmetic where shorter

## JavaScript Golf
```js
// FizzBuzz: 63 chars
for(i=0;i<100;)console.log((++i%3?'':'Fizz')+(i%5?'':'Buzz')||i)
// Prime check: 43 chars
p=n=>{for(i=2;i*i<=n;i++)if(n%i<1)return 0;return n>1}
// Fibonacci: 40 chars
f=n=>n<2?n:f(n-1)+f(n-2)
// Array shuffle: 38 chars
a=>a.sort(_=>Math.random()-.5)
// Flatten array: 20 chars
f=a=>[].concat(...a.map(f))
```

## Python Golf
```python
# FizzBuzz: 57 chars
for i in range(1,101):print('Fizz'*(i%3<1)+'Buzz'*(i%5<1)or i)
# Prime check: 44 chars
p=lambda n:all(n%i for i in range(2,int(n**0.5)+1))*(n>1)
# Fibonacci: 34 chars
f=lambda n:n if n<2 else f(n-1)+f(n-2)
# Quicksort: 52 chars
q=lambda a:a and q([x for x in a[1:]if x<a[0]])+a[:1]+q([x for x in a[1:]if x>=a[0]])
```

## C Golf
```c
// FizzBuzz: 80 chars
main(i){for(;i<101;i++)printf(i%3?i%5?"%d":"Buzz":i%5?"Fizz":"FizzBuzz",puts(""));}
// strlen: 31 chars
s(char*p){char*q=p;while(*q++);return q-p-1;}
```

## Rust Golf
```rust
// FizzBuzz: 85 chars
fn main(){(1..=100).for_each(|i|println!("{}",match(i%3,i%5){(0,0)=>"FizzBuzz".into(),(0,_)=>"Fizz".into(),(_,0)=>"Buzz".into(),_=>i.to_string()}))}
```

## Raw Byte Hacking

### Hex Dump Without Libraries
```rust
fn hex_dump(data: &[u8]) -> String {
    let mut out = String::new();
    for (i, chunk) in data.chunks(16).enumerate() {
        out.push_str(&format!("{:08x}  ", i * 16));
        for (j, &b) in chunk.iter().enumerate() {
            out.push_str(&format!("{:02x} ", b));
            if j == 7 { out.push(' '); }
        }
        for _ in chunk.len()..16 { out.push_str("   "); }
        out.push_str(" |");
        for &b in chunk { out.push(if b.is_ascii_graphic() || b == b' ' { b as char } else { '.' }); }
        out.push_str("|\n");
    }
    out
}
```

### Byte-Level Image Understanding (No Vision)
```rust
struct RawImage { width: u32, height: u32, channels: u8, data: Vec<u8> }

impl RawImage {
    fn from_png(path: &str) -> Result<Self> {
        let raw = std::fs::read(path)?;
        let mut idx = 8; // skip PNG signature
        let mut width = 0u32; let mut height = 0u32; let mut channels = 3u8;
        while idx < raw.len() {
            let len = u32::from_be_bytes([raw[idx], raw[idx+1], raw[idx+2], raw[idx+3]]);
            let chunk_type = std::str::from_utf8(&raw[idx+4..idx+8]).unwrap_or("");
            match chunk_type {
                "IHDR" => {
                    width = u32::from_be_bytes([raw[idx+8], raw[idx+9], raw[idx+10], raw[idx+11]]);
                    height = u32::from_be_bytes([raw[idx+12], raw[idx+13], raw[idx+14], raw[idx+15]]);
                    channels = match raw[idx+17] { 2 => 3, 4 => 2, 6 => 4, _ => 3 };
                }
                "IDAT" => { /* decompress zlib, apply filters */ }
                "IEND" => break,
                _ => {}
            }
            idx += 12 + len as usize;
        }
        Ok(Self { width, height, channels, data: Vec::new() })
    }

    fn dominant_color(&self) -> (u8, u8, u8) {
        let mut r = [0u64; 256]; let mut g = [0u64; 256]; let mut b = [0u64; 256];
        for px in self.data.chunks(self.channels as usize) {
            r[px[0] as usize] += 1; g[px[1] as usize] += 1; b[px[2] as usize] += 1;
        }
        let max_idx = |arr: &[u64; 256]| arr.iter().enumerate().max_by_key(|(_, &c)| c).map(|(i, _)| i as u8).unwrap_or(0);
        (max_idx(&r), max_idx(&g), max_idx(&b))
    }

    fn entropy(&self) -> f64 {
        let mut hist = [0u64; 256];
        for &b in &self.data { hist[b as usize] += 1; }
        let total = self.data.len() as f64;
        hist.iter().filter(|&&c| c > 0).map(|&c| {
            let p = c as f64 / total;
            -p * p.log2()
        }).sum()
    }
}
```

### Binary Patching
```rust
fn patch_bytes(data: &mut [u8], offset: usize, patch: &[u8]) -> &[u8] {
    let end = offset + patch.len();
    data[offset..end].copy_from_slice(patch);
    &data[offset..end]
}
fn find_pattern(haystack: &[u8], needle: &[u8]) -> Option<usize> {
    haystack.windows(needle.len()).position(|w| w == needle)
}
```

### ELF Header Parsing
```rust
fn read_elf_header(data: &[u8]) -> Option<(u16, u64)> {
    if &data[0..4] != b"\x7fELF" { return None; }
    let class = data[4]; // 1=32bit, 2=64bit
    let entry = if class == 2 {
        u64::from_le_bytes(data[24..32].try_into().ok()?)
    } else {
        u32::from_le_bytes(data[24..28].try_into().ok()?) as u64
    };
    Some((class as u16, entry))
}
```

### Reverse Engineering Patterns
- Function prologue detection: `push rbp; mov rbp, rsp` (x86_64) = `0x55 0x48 0x89 0xE5`
- String reference finding: scan for `lea rdi, [rip+offset]` = `0x48 0x8D 0x3D`
- Syscall detection: `syscall` = `0x0F 0x05`, `int 0x80` = `0xCD 0x80`
- NOP sled detection: runs of `0x90`
- Magic bytes: PNG=`\x89PNG`, JPEG=`\xFF\xD8\xFF`, ZIP=`PK\x03\x04`, ELF=`\x7fELF`


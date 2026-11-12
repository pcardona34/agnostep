# Hardware Compatibility List

## Why?

Because I cannot test on every hardware, I put here a list of very well and successfully tested hardwares:
If you successflly tested your hardware, let me know.

## Successful tests

### Virtual machines

- Type: **x86_64** architecture: CPU: smp x 2, GPU SVGA with 256M: tested within Qemu-Kvm, then Virtualbox. The host was the MacBook below.  
  - Date: Feb. 13 2026. Since release 1.0.0 RC 4. Agnostep-theme was: 0.9.4 Beta. 
 
### Laptop

- Apple MacBookPro 6.2 **Intel Core i5** (2010), amd64, Trixie 13.3: passed 100%. Date: Oct 2 2025; since Release: AGNoStep 0.8.4

### SBC

- Raspberry Pi 3B, **arm64**, Debian Bookworm 12.12: passed 100 % : Sep. 6 2025; since PISIN Release 0.8.2
- Raspberry PI 400, **arm64**, Debian Trixie 13.13: passed 100 % : Feb. 7 2026; last Release: Agnostep-desktop 0.9.9.5 Beta
- Raspberry Pi 500, **arm64**, Trixie 13.3: passed 100 % : Feb. 8 2026;  last Release: Agnostep-desktop 1.0.0 RC 1

### Monitor

- ACER 57e **17"** HD: 1080p mode (1920x1080)
- Apple **15"** monitor: see Laptop above.
- HP **M22f** monitor HD: 1920x1080. 

### Printer and scanner

- HP All-in-One **ENVY 5020**: printing a RTF document: yes; scanning: yes

## Tests protocol

- To report a successfull test on a new hardware, please report to us the following steps:

Hardware Model, CPU arch, OS release: passed percent. Date: ...; Release of AGNoStep-desktop.

See Detailed [TESTS](TESTS.md) protocol.

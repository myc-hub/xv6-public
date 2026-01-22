# The xv6 kernel starts executing in this file. This file is linked with
# the kernel C code, so it can refer to kernel symbols such as main().
# The boot block (bootasm.S and bootmain.c) jumps to entry below.
        
# Multiboot header, for multiboot boot loaders like GNU Grub.
# http://www.gnu.org/software/grub/manual/multiboot/multiboot.html
#
# Using GRUB 2, you can boot xv6 from a file stored in a
# Linux file system by copying kernel or kernelmemfs to /boot
# and then adding this menu entry:
#
# menuentry "xv6" {
# 	insmod ext2
# 	set root='(hd0,msdos1)'
# 	set kernel='/boot/kernel'
# 	echo "Loading ${kernel}..."
# 	multiboot ${kernel} ${kernel}
# 	boot
# }

#include "asm.h"
#include "memlayout.h"
#include "mmu.h"
#include "param.h"

# Multiboot header.  Data to direct multiboot loader.
.p2align 2
.text
.globl multiboot_header
multiboot_header:
  #define magic 0x1badb002
  #define flags 0
  .long magic
  .long flags
  .long (-magic-flags)

# By convention, the _start symbol specifies the ELF entry point.
# Since we haven't set up virtual memory yet, our entry point is
# the physical address of 'entry'.
#内核入口点
.globl _start
_start = V2P_WO(entry)

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # === 添加内核入口标记 ===
  # 直接写屏方式：在屏幕左上角显示"[KERNEL] ENTRY"
  movl    $0xb8000, %edi      # 显存起始地址（文本模式）
  movw    $0x0F5B, (%edi)     # '[' 白色
  addl    $2, %edi
  movw    $0x0F4B, (%edi)     # 'K' 白色
  addl    $2, %edi
  movw    $0x0F45, (%edi)     # 'E' 白色
  addl    $2, %edi
  movw    $0x0F52, (%edi)     # 'R' 白色
  addl    $2, %edi
  movw    $0x0F4E, (%edi)     # 'N' 白色
  addl    $2, %edi
  movw    $0x0F45, (%edi)     # 'E' 白色
  addl    $2, %edi
  movw    $0x0F4C, (%edi)     # 'L' 白色
  addl    $2, %edi
  movw    $0x0F5D, (%edi)     # ']' 白色
  addl    $2, %edi
  movw    $0x0F20, (%edi)     # 空格
  addl    $2, %edi
  movw    $0x0F45, (%edi)     # 'E'
  addl    $2, %edi
  movw    $0x0F4E, (%edi)     # 'N'
  addl    $2, %edi
  movw    $0x0F54, (%edi)     # 'T'
  addl    $2, %edi
  movw    $0x0F52, (%edi)     # 'R'
  addl    $2, %edi
  movw    $0x0F59, (%edi)     # 'Y'
  addl    $2, %edi
  # === 结束添加 ===

  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
  orl     $(CR4_PSE), %eax
  movl    %eax, %cr4
  # Set page directory
  #设置页目录（启用分页前的准备）
  movl    $(V2P_WO(entrypgdir)), %eax
  movl    %eax, %cr3
  # Turn on paging.
  #启用分页
  movl    %cr0, %eax
  orl     $(CR0_PG|CR0_WP), %eax
  movl    %eax, %cr0

  # Set up the stack pointer.
  #设置栈指针
  movl $(stack + KSTACKSIZE), %esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  #跳转到main函数（c代码）
  mov $main, %eax
  jmp *%eax

.comm stack, KSTACKSIZE

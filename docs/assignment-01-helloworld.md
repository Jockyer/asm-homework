# 第一次作业：helloworld

- **课程**：汇编语言
- **日期**：2026 年 10 月
- **环境**：DOSBox 0.74（16 位 DOS 模拟器）+ MASM 5.0（`masm.exe` / `link.exe`）+ Debug/X 2.51（`debug.com`）

---

## 作业要求

1. **传统方式**：源代码 → 汇编 → 链接，会用 `debug -u` 反汇编查看机器码和源代码之间的关系；提交源代码和 exe 文件。
2. **另类方式**：直接将代码和数据用 `debug -e` 写到内存中去执行；提交文档。

---

## 一、方式 (1)：源码 → 汇编 → 链接 → 运行 → 反汇编

### 1.1 源程序（`work/HELLO.ASM`）

```asm
assume cs:codesg, ds:datasg

datasg segment
    db 'Hello, Assembly!', 0dh, 0ah, '$'
datasg ends

codesg segment
start:
    mov ax, datasg
    mov ds, ax
    mov dx, 0
    mov ah, 9
    int 21h
    mov ax, 4c00h
    int 21h
codesg ends

end start
```

### 1.2 汇编与链接

```
C:\WORK>masm hello;
Microsoft (R) Macro Assembler Version 5.00
Copyright (C) Microsoft Corp 1981-1985, 1987.  All rights reserved.

  51748 + 464780 Bytes symbol space free

      0 Warning Errors
      0 Severe  Errors

C:\WORK>link hello;
Microsoft (R) Overlay Linker  Version 3.60
Copyright (C) Microsoft Corp 1983-1987.  All rights reserved.

LINK : warning L4021: no stack segment
```

> `L4021: no stack segment` 属**预期警告**：本程序未定义栈段，LINK 会把 `SS:SP` 写成 `0000:0000`（已用十六进制查看 `HELLO.EXE` 文件头中的 `e_ss` / `e_sp` 字段验证）。本程序只调用 `int 21h`，而 MS-DOS 在处理 `int 21h` 时会切换到自己的内部栈，所以能够正常运行；但若程序中使用 `call`、`push` 或子程序，就必须补上 `stack segment`，否则会破坏中断向量表而导致死机。

### 1.3 运行结果

```
C:\WORK>hello
Hello, Assembly!
```

### 1.4 用 `debug -u` 反汇编（完整会话记录见 `work/HELLO1.OUT`）

```
C:\WORK>debug hello.exe < dbg1.txt
-u
0742:0000 B84007            MOV     AX,0740
0742:0003 8ED8              MOV     DS,AX
0742:0005 BA0000            MOV     DX,0000
0742:0008 B409              MOV     AH,09
0742:000A CD21              INT     21
0742:000C B8004C            MOV     AX,4C00
0742:000F CD21              INT     21
-q
```

> 偏移 `0011` 之后若还有若干行，属于内存中的残留数据，**不是本程序的代码**（本程序共 17 字节，占偏移 `0000`–`0010`）。

### 1.5 机器码与源代码的对应关系

| 源代码 | 机器码 | 字节数 | 说明 |
| --- | --- | --- | --- |
| `mov ax, datasg` | `B8 40 07` | 3 | `B8` = MOV AX, imm16；`40 07` 是**链接重定位**后填入的 datasg 段值（小端，即 `0740h`） |
| `mov ds, ax` | `8E D8` | 2 | `8E` = MOV Sreg, r/m16；ModRM `D8` = `11 011 000` → reg=DS、r/m=AX |
| `mov dx, 0` | `BA 00 00` | 3 | `BA` = MOV DX, imm16 |
| `mov ah, 9` | `B4 09` | 2 | `B4` = MOV AH, imm8（`B0`–`B7` 组为 MOV r8, imm8） |
| `int 21h` | `CD 21` | 2 | `CD` = INT imm8，`21` 为中断号 |
| `mov ax, 4c00h` | `B8 00 4C` | 3 | 立即数**小端**存放：`4C00` → `00 4C` |
| `int 21h` | `CD 21` | 2 | |

**合计 17 字节**，与反汇编中偏移 `0000`–`0010` 的范围完全一致。

由此得出三点：

1. **一条汇编语句对应 1~6 个字节不等的机器码**，所以汇编器必须扫描两遍才能确定标号地址；
2. **寄存器编号被编进操作码的低 3 位**（`B8`→AX、`BA`→DX、`B4`→AH）；
3. **立即数按小端存放**；段值在链接/加载阶段由**重定位**填入，因此反汇编里看到的 `0740` 每次运行都可能不同。

---

## 二、方式 (2)：用 `debug -e` 把机器码直接写入内存执行

本方式**不使用 MASM / LINK，不产生任何文件**，程序只存在于内存中。

### 2.1 写入的内存内容

| 地址 | 内容 | 字节数 |
| --- | --- | --- |
| `CS:0100` | 机器码（见下表） | 16 |
| `CS:0200` | 数据：`Hello, Assembly!` + `0D 0A` + `24`（即 `$`） | 19 |

| 机器码 | 指令 | 说明 |
| --- | --- | --- |
| `8C C8` | `MOV AX,CS` | 取代码段基址（本方式没有链接器做重定位） |
| `8E D8` | `MOV DS,AX` | 数据与代码处于同一段，故 `DS = CS` |
| `BA 00 02` | `MOV DX,0200` | 字符串位于偏移 `0200` |
| `B4 09` | `MOV AH,09` | DOS 9 号功能：显示以 `$` 结尾的字符串 |
| `CD 21` | `INT 21` | 调用 DOS |
| `B8 00 4C` | `MOV AX,4C00` | DOS 4C 号功能：结束程序 |
| `CD 21` | `INT 21` | |

### 2.2 完整过程（完整记录见 `work/HELLO2.OUT`）

```
C:\WORK>debug < dbg2.txt
-e 100 8C C8 8E D8 BA 00 02 B4 09 CD 21 B8 00 4C CD 21
-e 200 48 65 6C 6C 6F 2C 20 41 73 73 65 6D 62 6C 79 21 0D 0A 24
-u 100 10F
0725:0100 8CC8              MOV     AX,CS
0725:0102 8ED8              MOV     DS,AX
0725:0104 BA0002            MOV     DX,0200
0725:0107 B409              MOV     AH,09
0725:0109 CD21              INT     21
0725:010B B8004C            MOV     AX,4C00
0725:010E CD21              INT     21
-g
Hello, Assembly!

Program terminated normally (0000)
-q
```

### 2.3 关于 `debug -e`

`E`（Enter）命令是 DEBUG 提供的**内存编辑器**。既可以把整串字节一次给出（本作业的用法），也可以只给出起始地址进入交互编辑模式，逐个字节录入：

```
-e 100
0725:0100 00. 8C
0725:0101 00. C8
...
```

### 2.4 与方式 (1) 的对比

| | 方式 (1) 传统方式 | 方式 (2) 另类方式 |
| --- | --- | --- |
| 输入 | 汇编源代码 `.ASM` | 直接键入机器码字节 |
| 使用工具 | MASM + LINK | 仅 DEBUG |
| 产物 | 磁盘上的 `HELLO.EXE` | **无任何文件** |
| 可否重复运行 | 可以 | 不可以，退出 DEBUG 即消失 |
| 地址如何处理 | 由**重定位**自动完成（`mov ax, datasg`） | 手工规避（`mov ax, cs`，数据与代码同段） |

---

## 三、复现方法

在 DOSBox 中启动后会自动进入 `C:\WORK`，然后：

**方式 (1)**

```
run1.bat
```

（等价于依次执行 `masm hello;`、`link hello;`、`hello`、`debug hello.exe < dbg1.txt`）

**方式 (2)**

```
debug < dbg2.txt
```

> 附注：DOSBox 0.74 **不支持给批处理重定向输出**（`run1.bat > 文件` 会失败）。如需保存输出，请对每条命令分别使用 `>`。

---

## 四、小结

1. 「汇编 → 链接 → 运行」三步之后，`HELLO.EXE` 能正确输出 `Hello, Assembly!`。
2. 通过 `debug -u` 反汇编，验证了**机器码与源代码的对应关系**，并观察到段值由**重定位**填入（`MOV AX,0740`）。
3. `L4021: no stack segment` 的后果是把 `SS:SP` 置为 `0000:0000`；本程序因只使用 `int 21h` 而未受影响，但这属于隐患。
4. 用 `debug -e` 可把机器码直接写入内存执行，程序不落地成文件；关键是自己解决"数据在哪里"的问题（用 `mov ax, cs` 令 `DS = CS`）。
5. 汇编指令**长度不固定**（1~6 字节），这正是汇编器需要两遍扫描、也无法用固定步长推算地址的原因。

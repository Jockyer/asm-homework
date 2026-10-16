# 汇编语言课程作业

本学期《汇编语言》课程作业仓库（8086 实模式，MASM 5.0 + DOSBox）。

## 目录结构

| 路径 | 说明 |
| --- | --- |
| `work/` | 作业源码、可执行文件与运行记录（在 DOSBox 中挂载为 `C:\WORK`） |
| `docs/` | 作业文档 |

> 本仓库根目录即 DOSBox 中的 `C:\`。课程提供的工具目录（`masm/`、`editor/`）与作业无关，已被 `.gitignore` 排除，不会上传。

## 环境

- **DOSBox 0.74** —— 16 位 DOS 模拟器。64 位 Windows 已移除 NTVDM，无法直接运行 DOS 程序。
- **MASM 5.0** —— `masm.exe` 汇编器、`link.exe` 链接器。
- **Debug/X 2.51** —— `debug.com`，用于 `u` 反汇编、`e` 直接写内存。

工具目录 `masm/` 在 DOSBox 中即 `C:\MASM`，已加入 `PATH`，因此可直接调用 `masm` / `link` / `debug`。

## 编译与运行

在 DOSBox 中（启动后自动位于 `C:\WORK`）：

```
masm hello;      :: 汇编：HELLO.ASM -> HELLO.OBJ
link hello;      :: 链接：HELLO.OBJ -> HELLO.EXE
hello            :: 运行
```

反汇编，查看机器码与源代码的对应关系：

```
debug hello.exe
-u
-q
```

## 作业清单

| 序号 | 题目 | 文件 | 状态 |
| --- | --- | --- | --- |
| 1 | helloworld | `work/HELLO.ASM`、`work/HELLO.EXE`、`docs/assignment-01-helloworld.md` | 完成 |

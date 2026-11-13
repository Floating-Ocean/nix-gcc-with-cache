> [!WARNING]
>
> 参考 https://github.com/hydro-dev/nix-channel/blob/81017d17387dbaf63e3cb70b7437ed8168fdb2da/gccWithCache.nix
> 
> It works well on my machine. **个人留档用，不保证可用性**

# nix-gcc-with-cache

基于 `nixpkgs.gcc15`，预编译 `bits/stdc++.h`, `bits/extc++.h`, `stdio`, `iostream`, `cstdio`，加快编译速度

## 快速开始

```bash
git clone https://github.com/Floating-Ocean/nix-gcc-with-cache.git
cd nix-gcc-with-cache
nix-env -i -f gcc15.nix
```

在 HydroOJ 系统设置中配置编译指令，以 C++ 20 为例：

```yaml
cc.std20(O2):
  compile: >-
    /usr/bin/g++ -x c++ -Wall -std=c++20 -O2 -fno-stack-limit -fdiagnostics-color=always -o foo foo.cc -DONLINE_JUDGE
  display: C++ 20 (O2)
```

## 提示

如果不需要 `-DONLINE_JUDGE`，请在 `gcc15.nix` 中删除对应内容，否则无法命中预编译文件

如果出现满屏的 Wrong Answer，且提示 `/w/foo: error while loading shared libraries: libstdc++.so.6: cannot open shared object file: No such file or directory`，清空评测机编译缓存即可：

```bash
hydrojudge cache clearCompileCache
```

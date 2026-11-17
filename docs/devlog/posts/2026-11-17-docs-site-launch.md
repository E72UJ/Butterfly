---
date: 2026-11-17
slug: docs-site-launch
categories:
  - 进展
---

# 开发文档站上线

把散落在代码注释、`readme.md` 和口头交流里的项目信息，收敛成一个能长期维护的文档站。

<!-- more -->

## 为什么单独建站

`readme.md` 已经装不下这些东西了：章节与房间的对应关系、`KonadoRoomBridge` 的过桥流程、回退系统的状态栈设计，任何一项都够写满一屏。放在仓库根目录的单个文件里，改一处就要重新读全文。

拆成站点后，每篇文档只讲一件事，改一章不影响其他章节。

## 这次做了什么

| 项 | 内容 |
|---|---|
| 构建工具 | MkDocs 1.6.1 + Material 9.8.1 |
| 访问地址 | <https://butterfly.seer2.org/> |
| 托管 | 腾讯云服务器，宝塔面板，纯静态站点 |
| 部署方式 | `rsync` 增量同步，一条命令完成构建 + 上传 |
| 字体 | 系统字体栈，不请求 Google Fonts |

## 内容结构

- **首页** —— 项目概览、技术栈、目录结构、核心单例、快速开始
- **开发指南** —— 项目结构、房间过场桥接、全局回退系统
- **开发日志** —— 本栏目

## 踩过的坑

**① 宝塔的 `.user.ini` 删不掉**

`rsync --delete` 第一次同步就中断了：

```
rsync: delete_file: unlink(.user.ini) failed: Operation not permitted (1)
```

这个文件被宝塔用 `chattr +i` 设成了不可变，连 root 都删不掉。解决办法是让 rsync 根本不碰它——加 `--exclude '.user.ini'`。同理必须排除 `.well-known/`，那是 Let's Encrypt 放验证文件的目录，误删会导致证书续期失败，而这类故障通常半年后才会暴露。

**② 站点目录首字母是大写的**

宝塔按域名建目录，实际路径是 `/www/wwwroot/Butterfly.seer2.org/`，不是全小写。Linux 路径大小写敏感，写错了文件传进一个不存在的目录，页面始终是空的。

**③ Google Fonts 阻塞首屏**

Material 默认会引入 `fonts.googleapis.com` 的样式表，这是**同步阻塞**资源。该域名在国内不可达，页面会先卡在这个请求上。关掉方式是在 `mkdocs.yml` 里加一行：

```yaml
theme:
  font: false
```

关掉后字体变量会变空，中文在 Windows 上有回退成宋体的风险，所以另外补了一份显式系统字体栈（苹方 → 微软雅黑 → Noto Sans CJK）。

**④ 无头浏览器截图不能用来判断响应式**

用 390px 宽度截图时，页面右侧文字看起来被裁掉了，差点白改一通 CSS。后来把页面塞进 390px 的 iframe 里实测 `documentElement.scrollWidth`，结果是 `390`、溢出元素 0 个——页面本身完全正常，是截图工具的成像问题。

**教训**：判断响应式要么用真实浏览器，要么量 `scrollWidth`，别信截图。

## 下一步

- 补 `guide/chapters.md`，把章节脚本的组织约定写清楚
- 把 `tools/` 下那批测量脚本的原理整理成文档
- 每完成一个叙事节点，在这里记一条

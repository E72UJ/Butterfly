# 关于

这个站点是《阿卡迪亚蝶梦》的**开发配套资料**。项目早期，相关信息散落在代码注释、`readme.md` 和口头交流里，写文档站的目的是把它们收拢成一个能长期维护、也便于对外说明的地方。

## 关于《阿卡迪亚蝶梦》

| 项 | 内容 |
|---|---|
| 中文名 | 阿卡迪亚蝶梦 |
| 英文名 | Arcadian Butterfly Dream |
| 类型 | 中文文字冒险游戏（AVG） |
| 引擎 | Godot 4.7，Forward+ 渲染后端 |
| 叙事框架 | Konado 2.8.1 |
| 画面基准 | 1280 × 720，最高 120 FPS |
| 叙事组织 | 房间式章节，对话与过场交替推进 |

## 关于本站

| 项 | 内容 |
|---|---|
| 站点地址 | <https://butterfly.seer2.org/> |
| 文档仓库 | [E72UJ/Butterfly](https://github.com/E72UJ/Butterfly) |
| 游戏工程 | [Gitee: Furau/arcadian-butterfly-dream](https://gitee.com/Furau/arcadian-butterfly-dream) |
| 内容规模 | 9 篇源文档，生成 11 个页面 |
| 首次上线 | 2026-11-16 |

文档目前分为四块：**初始化项目**（怎么把它跑起来）、**开发指南**（项目结构、房间过场、全局回退）、**黄皮书调用**、**开发日志**（过程中的决策与踩坑记录）。
## 技术构成

| 环节 | 使用 | 版本 |
|---|---|---|
| 站点生成 | MkDocs | 1.6.1 |
| 主题 | Material for MkDocs | 9.8.1 |
| Markdown 扩展 | pymdown-extensions | 13.1 |
| 代码高亮 | Pygments | 2.21.0 |
| 流程图 | Mermaid（由 superfences 渲染） | — |
| 搜索 | MkDocs 内置 lunr，含中文分词 | — |
| 部署 | nginx（宝塔面板）+ rsync 增量同步 | — |

字体刻意**不加载 Google Fonts**，改用系统字体栈（macOS 苹方、Windows 微软雅黑、Linux Noto Sans CJK）。原因是 `fonts.googleapis.com` 在国内基本不可达，且是同步阻塞加载，会拖慢首屏——对国内访问者来说，等它超时再回退纯属浪费。

## 更新记录

- **2026-11-16**：站点搭建并上线，首篇开发日志发布
- **2026-11-17**：新增初始化项目、黄皮书调用两页，接入站点 logo，改用系统字体

仓库累计 20 次提交。

## 关于主题的生命周期

Material for MkDocs 官方公告将在 **2027-05-05** 结束生命周期，后继项目是同一团队推出的 **Zensical**，可直接复用现有的 `mkdocs.yml`。所以这不构成风险，真要迁移时工作量有限。

## 反馈

文档里的路径、类名、版本号都取自实际工程，但代码会演进，文档难免滞后。如果发现对不上的地方：

- 提 Issue：<https://github.com/E72UJ/Butterfly/issues>
- 或直接改，仓库是公开的

!!! note "以代码为准"
    当文档描述与工程实际不一致时，**以工程代码为准**。遇到这种情况欢迎指出，比在文档里默默绕过去有用得多。

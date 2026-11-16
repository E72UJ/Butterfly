# 项目结构

## 目录职责

| 目录 | 内容 |
|---|---|
| `addons/` | Konado 系列插件，其中 `konado`、`konado_settings` 在编辑器启用 |
| `assest/` | 美术与音频素材（`chapter1`、`sfx`、`ui`） |
| `font/` | 字体资源，`SarasaFixedHC-Regular.ttf` 与 `two.TTF` |
| `script/` | 全部 GDScript，按职责分子目录 |
| `tscn/` | 场景文件，章节与房间分别成目录 |
| `konado_demo/` | Konado 官方示例的复刻场景，作为叙事流程的承载层 |
| `tools/` | 开发期 Python 校验脚本，不参与运行时 |
| `UI/`、`SettingsMenu/` | 界面主题资源与设置场景 |

!!! warning "`assest` 不是笔误"
    素材目录名就是 `assest`（拼写异常，正确应为 `assets`）。项目内数十处路径引用了它，重命名会牵连大量 `.tscn` / `.tres`，**建议保持原样**。文档统一按实际拼写书写，看到时不必"顺手修正"。

## 脚本分层

```
script/
├── Global/                 # 全局单例
│   └── GlobalDialogueManager.gd
├── room/                   # 房间过场
│   ├── room_bridge.gd      # 桥接单例
│   ├── context.gd          # 房间上下文基类
│   ├── r_3.gd … r11.gd     # 各房间的演出脚本
│   └── r7-shake.gd         # 震屏变体
├── mbook/                  # 章节叙事脚本
│   └── chapter_1_m_2.gd … chapter_1_m_12.gd
└── menu_ui/                # 界面交互
    ├── quickmenu.gd
    └── rollback_button.gd
```

## 章节与房间的对应关系

第一章由 **10 个叙事节点场景**（`tscn/Chapter/m2` ~ `m8`、`m10` ~ `m12`）和 **11 个房间场景**（`tscn/room/r1` ~ `r11`）组成，两者是交替推进的关系：

- `m*` 是 Konado 剧本驱动的主叙事段落，承载对话与选项
- `r*` 是旁白过场场景，负责插入演出（淡入文字、震屏、氛围段落）
- 过场结束后通过 `KonadoRoomBridge.exit_to_next_scene()` 回到主叙事，**精准续播**而不是从头再来

详细机制见 [房间过场桥接](room-bridge.md)。

!!! note "编号不连续，`m9` 不存在"
    章节场景目录为 `m2` ~ `m8` 加上 `m10` ~ `m12`，**没有 `m9`**。`script/mbook/` 下则只有 9 个脚本（`m_2` ~ `m_7`、`m_10` ~ `m_12`）——`m8` 的叙事内容直接由 Konado 剧本驱动，未配 GDScript。新增章节时不要按编号顺序推断目录一定存在。

## 图层约定

项目的渲染分层遵循固定层级，改写时不要随意调整：

| 层 | 用途 |
|---|---|
| `BackgroundLayer` | 背景图，位于最底 |
| `CharacterLayer` | 角色立绘（左 / 中 / 右） |
| `UILayer` | 对话框、控制面板、菜单 |
| `EffectLayer` | 转场、文字特效、粒子 |
| `CanvasLayer(layer=4096)` | 角色舞台层 `ActorStageLayer` |
| `CanvasLayer(layer=10000)` | 过场黑色遮罩，盖过以上所有层 |

最后两层由代码动态创建，不在场景文件里，排查"某元素被挡住"时优先怀疑这里。

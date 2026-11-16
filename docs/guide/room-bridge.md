# 房间过场桥接

`KonadoRoomBridge`（`script/room/room_bridge.gd`）是 Konado 对话场景与 `tscn/room/` 旁白过场场景之间的桥接单例。它解决的核心问题是：**从 Konado 叙事跳进过场场景，播完再跳回来时，如何精准续播而不是从头开始。**

## 工作流程

整个往返过程分三步：

1. **进入过场** — ks 剧本执行 `signal "room:r1"`，`konado_script_bootstrap.gd` 监听到信号后，抓取 `KonadoDialogueManager` 的执行快照（进度 + 变量 + 舞台状态）存入桥中
2. **播放过场** — 切换场景到 `res://tscn/room/r1.tscn`，播放旁白动画
3. **返回续播** — 过场脚本在动画结束时调用 `exit_to_next_scene(原跳转目标)`：
    - 桥上有快照 → 跳回 Konado 场景，bootstrap 用快照精准续播
    - 桥上无快照 → 按原跳转目标走，老架构行为完全不变

```gdscript
# script/room/r_3.gd 的结尾
func _on_animation_finished():
    KonadoRoomBridge.exit_to_next_scene("res://tscn/Chapter/m3/Chapter1-m3.tscn")
```

!!! info "快照不落盘"
    快照只保存在内存中，依靠 autoload 跨场景存活。**游戏退出即丢失**，不参与存档。因此不要依赖它做持久化恢复。

## 常量与配置

| 名称 | 默认值 | 说明 |
|---|---|---|
| `DEFAULT_KONADO_SCENE` | `res://konado_demo/scenes/Chapter1-Konado.tscn` | 过场播完后返回的 Konado 场景，bootstrap 初始化时按需改写 |
| `ROOM_SCENE_DIR` | `res://tscn/room/` | room 过场场景所在目录 |
| `konado_scene_path` | 同上默认值 | 运行时可变 |
| `cover_enabled` | `true` | 黑色遮罩总开关，置 `false` 时所有过场切换变为硬切 |

## 快照接口

| 方法 | 作用 |
|---|---|
| `has_snapshot() -> bool` | 是否存在待恢复的过场快照 |
| `store_snapshot(snapshot: Dictionary)` | 存入快照（**深拷贝**，防止外部改动影响恢复），同时后台预加载 Konado 场景 |
| `take_snapshot() -> Dictionary` | 取出快照并清空，**取出即消费**，避免二次恢复 |
| `clear_snapshot()` | 主动丢弃快照（过场被跳过、不再需要续播时） |
| `exit_to_next_scene(fallback: String)` | 过场统一出口：有快照回 Konado 续播，无快照走 `fallback` |

## 体验优化细节

代码里有两处容易被忽略但对体验很关键的实现：

**后台预加载**：`store_snapshot()` 里顺手发起 `ResourceLoader.load_threaded_request()`。过场通常有几秒动画，足够在线程里把重量级的 Konado 场景加载完，返回瞬间就不卡了。加载失败会 `push_warning` 并降级回同步的 `change_scene_to_file`。

**黑色遮罩**：切换前盖上全屏黑幕，盖住"空舞台首帧 → 快照恢复"之间的画面闪烁。

- 遮罩挂在 `root` 上（不属于任何场景），因此**能跨场景切换存活**
- `layer = 10000`，盖过 `ActorStageLayer(4096)` 等所有游戏层
- `show_cover(3.0)` 传了 3 秒兜底自动淡出，防止 bootstrap 未按预期恢复时画面被永久遮住
- 恢复完成后由 bootstrap 调 `dismiss_cover()` 主动淡出（默认 0.25 秒）

## 信号解析

`parse_room_id()` 是静态方法，从 ks 信号内容里解析房间名：

```gdscript
KonadoRoomBridge.parse_room_id("room:r1")            # → "r1"
KonadoRoomBridge.parse_room_id("room r1")            # → "r1"
KonadoRoomBridge.parse_room_id("room:r1:附加信息")   # → "r1"
KonadoRoomBridge.parse_room_id("notroom:r1")         # → ""
```

支持 `room:r1`、`room r1`、`room:r1:任意附加信息` 三种写法，非 room 信号返回空串。

## 排查清单

画面出问题时的检查顺序：

1. **返回后从头播** — 快照没存上。检查 ks 里信号是否写成 `signal "room:rX"`，以及 bootstrap 是否有监听
2. **返回后黑屏不消失** — bootstrap 没调 `dismiss_cover()`。3 秒兜底会救回来，但说明恢复流程中断
3. **画面直接硬切没有淡入** — `KonadoRoomBridge.cover_enabled` 被设为 `false` 了
4. **回退后状态错乱** — 快照与全局回退系统（`GlobalDialogueManager`）各自维护状态，两者不共享，需要在过场前后手动协调

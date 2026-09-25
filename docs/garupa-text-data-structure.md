# Garupa 日服文本数据结构交接

> 范围：Android 日服 `jp.co.craftegg.band`，已检查样本 `10.2.0`（versionCode `231`）、Unity `2022.3.62f1`。这是特定设备、特定版本的研究快照，不是跨版本格式规范或可安装补丁。完整证据与实验过程见 [研究记录](./jp-bandori-translation-research.md)；本页不包含剧情正文、APK 或 bundle。

## 资源定位

已定位的 UI 与主线剧情样本位于应用数据目录的 UnityFS 缓存中；在 Android `resources.arsc` 中没有定位到这些样本文字，**不能据此推断所有游戏文字都在缓存中**。已观察的目录为：

```text
/storage/emulated/0/Android/data/jp.co.craftegg.band/files/data/
  AssetBundleInfo                  逻辑资源名 -> 缓存文件名、资源条目版本
  3c34ca4e...09825abe9           wordingcollection (UnityFS)
  b85985cc...78c80fa             scenario/main (UnityFS)
```

`AssetBundleInfo` 是二进制索引；样本头部版本 `10.2.0.120`。两个条目的版本均为 `10.1.0.230`，类别为 `StartApp`。**安装版本 `10.2.0 (231)`、索引头版本、条目版本是不同概念。**以 64 个十六进制字符命名的缓存文件名也不是下面的文件内容 SHA-256；重新分析时须先核对当前索引，不能假定这些文件名不变。

| 逻辑资源 | 样本缓存文件名 | 原始文件 SHA-256 | 容器内容 |
| --- | --- | --- | --- |
| `wordingcollection` | `3c34ca4ee13a1644e78bb17fd4a97f8a2ca574d4eb8be566c45366309825abe9` | `581e79cf6f385c15df7479af4f8d55626f6c9fc39e0b09556113dedd7bdc9e1f` | 23,223 字节；内部路径 `assets/star/forassetbundle/startapp/wordingcollection/wording_collection.txt`。 |
| `scenario/main` | `b85985cc6dceaa1a1c4c9b6bbe2314e76ac8b222354bec610404f947c78c80fa` | `96b0a498a2c315c934bcdb49ad62e68709037cea2a7dda0afd409cf21ae071f5` | 311,040 字节；内部路径含 `assets/star/forassetbundle/startapp/scenario/main/scenariomain001.asset`。 |

这些 SHA-256 是两次受控测试**恢复后的原件基线**，不是翻译候选包的哈希。原始 bundle 和剧情正文不在仓库中。

## UI：键值文本表

`wordingcollection` 中的 `wording_collection` 是 Unity `TextAsset`（class 49），其 `m_Script` 解压后为 68,798 字节、1,104 个互异键。每行按第一个逗号分隔文本键与日文值；同包还有 `readme` TextAsset，说明键名大致采用“功能大类_详细功能_标签”。例如：

```text
header_subTitle_storySelect,ストーリー選択
```

`header_mainTitle_story` 和 `mission_transitionButton_story` 是不同键，但都可以对应「ストーリー」。目标副标题的日文短语在原始 TextAsset 字节中出现四次，因此不能按可见日文全局替换、也不能取字符串首次出现的位置；应按**完整键**定位，再核对原值。这个 UI 值的 UTF-8 SHA-256 为 `cd0fd998eb8cdaad34565d08476da1ded30101eba1801dd3af2fbd0aad352b1e`。

用户授权的单点实验只替换了 `header_subTitle_storySelect` 的值：故事选择页副标题显示了虚构标记。随后恢复原缓存，用户重新启动游戏确认副标题恢复日文且登录正常。这证明**该版本的这一字段影响该控件**，不证明所有界面文案都来自该表，也不证明某个 IL2CPP 查表方法的调用方式。

## 剧情：结构化场景对象

`scenario/main` 是 UnityFS/LZ4 bundle；样本有 13 个数据块，不能只检查首块。内部 SerializedFile v22 含 77 个 Unity 对象，其中 75 个为 MonoBehaviour（class 114）。应按对象自己的类型树读取，不能把整包当纯文本搜索。唯一匹配 `scenarioSceneId == "main001"` 的对象 PathID 是 `7861991790238366201`，包含 52 条 `talkData` 和 192 条 `snippets`。

简化的字段关系（省略正文及其他场景字段）：

```text
MonoBehaviour (scenarioSceneId = "main001")
  snippets[41]
    actionType = 1
    referenceIndex = 14        -> 此样本引用 talkData[14]
  talkData[14]                  -> 下标从 0 开始
    talkCharacters[0].characterId = 5
    windowDisplayName = <角色显示名>
    body = <对白正文>
    motions, voices, speed, fontSize, ...
```

该行 `body` 的 UTF-8 SHA-256 为 `361e14d03b831cec00a90616ed5afc3571e2741e4769854ac59093eb2dfd7449`；样本中为 127 字节、含一个换行，没有检测到富文本标签或花括号占位符。建议的**样本定位键**是 `scenario/main` + `main001` + `talkData[14].body` + 原值指纹，而不是仅用行号、说话人或日文全文。`referenceIndex` 的含义取决于 `actionType`，上述关联只对已检查片段成立。

用户授权的单行实验只改变这个 `body` 字段：在主线 Opening 1 看到了虚构的两行标记。原件随后按完整 SHA-256、文件大小、属主、权限和 SELinux 标签恢复；截至本页记录，**用户尚未再次确认剧情原文画面和登录状态**。实验说明此版本的该对象字段会影响对应对白，但没有观测具体资源加载函数或证明其他场景行号稳定。

`scenario/afterlive` 是另一个资源，曾解析出 256 个剧情对象；不要把其行索引套到 `scenario/main`。Bestdori 的 `caption`、`title`、`synopsis` 多语数组是**章节元数据**，不能直接当作 `main001` 的 52 条对白翻译。

## 解析与适用边界

- 隔离环境使用 UnityPy `1.25.3` 成功解析/重建两个样本；该 UnityFS 未提供有效的 Unity 版本字段，需显式设置 `UnityPy.config.FALLBACK_UNITY_VERSION = "2022.3.62f1"`。无修改重建后，UI 包的 3 个对象、剧情包的 77 个对象原始数据分别逐一相同；**容器字节及长度仍可能变化**。
- 最小翻译条目应绑定包名、安装版本、逻辑资源与条目版本、精确键或 `sceneId`/行索引、原值 SHA-256 和目标语言。缺键、源值不符或版本漂移时保留日文；占位符、富文本与换行需要单独校验。上述两次实验只验证了各一个字段，尚无批量/跨版本结论。
- Frida 方法级观测曾因 server 自身崩溃而失败；`WordingManager`、`GetWording`、`OnLoadScenarioFile` 等元数据名称仅是调查线索，**不是已确认的函数入口**。Root 手动缓存替换成功不等于已有 Root 模块；非 Root 重打包、重签和安装路线均未验证。
- 下一位 Agent 应从当前安装包版本、`AssetBundleInfo` 映射及原始文件哈希重新建立基线。不要在仓库添加游戏 bundle、完整剧情或账号信息；此前的单点实验授权不自动覆盖新的进程 hook、手机写入或安装操作。

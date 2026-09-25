# BanG Dream! 日服 Android 文本研究交接

> 状态：2026-09-24 的个人研究快照，**不是可运行补丁**。目标包是 `jp.co.craftegg.band`，样本版本为 `10.2.0 (231)`。本文件独立记录证据、边界和下一步；不依赖聊天记录、Trellis 任务或仓库外的游戏文件。游戏会更新，所有路径、版本和条目在实施前都要重新核对。

## 目标与结论

首批目标是 Android 日服的主要 UI 文本和一段主线剧情，提供简体中文与英文，未匹配或不安全时保持原日文。分别研究 root 与非 root 路线；不覆盖 iOS、歌词、图片文字、全量剧情、联网翻译、反作弊/完整性规避或公开分发。仓库目前没有补丁代码、游戏 APK、资源文件、翻译正文或签名密钥。

已通过**只读设备样本**确认两类文字资源：

1. `wordingcollection`：UnityFS 包中的 `wording_collection.txt` TextAsset，内容为 1,104 个互异的 `键,日文值` 条目。
2. `scenario/main`：UnityFS 包中的结构化剧情对象；主线 `main001` 的说话人、行索引、片段与用户当时的实机画面吻合。

在用户授权的两次单点缓存替换实验中，故事选择页副标题显示了 UI 实验值，主线 Opening 1 的目标对白显示了 `main001/talkData[14].body` 的虚构标记；两份原缓存随后均按完整 SHA-256 恢复。它们是当前设备与版本上**指定缓存字段影响对应画面**的因果证据，不是 `GetWording` 或剧情加载函数的调用计数。Root 人工缓存替换的这两个最小可见性闸门已通过；其他 UI/剧情、跨版本稳定性、自动化装载与非 Root 接入仍未验证，仓库仍无可运行补丁。

## 证据来源与版本

| 类型 | 已知事实 | 限制 |
| --- | --- | --- |
| base APK 只读识别 | `/storage/emulated/0/MT2/apks/base.apk` 的包名 `jp.co.craftegg.band`、versionName `10.2.0`、versionCode `231`；V2/V3 签名数据存在；清单要求 `base__abi` 分包。 | 这不是已安装 APK 的字节身份校验。 |
| ABI 分包归档 | 同目录 `split_config.arm64_v8a.apk` 的 ZIP 成员包括 `lib/arm64-v8a/libil2cpp.so`、`libunity.so`、`libmain.so`。 | 仅核对成员名；未核对分包签名、ELF 或 native 函数。MT APK 工作区不能将此分包直接作为完整 APK 打开。 |
| Unity/脚本后端 | base 中的 Unity 数据显示 `2022.3.62f1`；`assets/bin/Data/Managed/Metadata/global-metadata.dat` 头为 IL2CPP magic `AF 1B B1 FA`、元数据版本 31。 | 元数据中的方法名/名称偏移不是函数地址或执行证据。 |
| 设备与应用版本 | 用户报告 Android 16、root、KernelSU + Zygisk + LSPosed v2.2.0，应用信息页为 `10.2.0 (231)`；测试时确认使用非主账号、可恢复环境。 | 组件发行来源、游戏作用域和已安装包证书均未独立核实；有 root 不等于可覆盖应用缓存或拦截 IL2CPP。 |
| 误选样本 | `/storage/emulated/0/Download/BD_v1010_shop.apk` 是台服 `net.gamon.bdTW`、`10.1.0`。 | 不得用它推断日服结构。 |

## 设备缓存的文字结构

已读到的样本位于设备的 `/storage/emulated/0/Android/data/jp.co.craftegg.band/files/data/`；后续 Agent 未必能访问同一设备。目录内并不是按剧情名存放裸 `.asset` 或 `.txt`，而是由二进制 `AssetBundleInfo` 索引把**逻辑资源名**映射到以 64 个十六进制字符命名的缓存文件；缓存文件本身是 UnityFS AssetBundle，内部再含逻辑路径及 Unity 对象。

```text
files/data/
  AssetBundleInfo                  索引头版本 + 逻辑资源名 -> 哈希文件名/条目版本
  3c34ca4e...09825abe9           wordingcollection -> TextAsset
  b85985cc...78c80fa             scenario/main -> SerializedFile/剧情对象
```

先前索引为 323,435 字节、2,002 条顶层记录；用户下载本章剧情数据后为 333,933 字节、2,067 条。**两版只读核对**均显示头部 `10.2.0.120`，以下两个逻辑名仍指向相同缓存文件，条目版本仍是 `10.1.0.230`、类别字段为 `StartApp`。新增的 65 条记录没有做内容分析；用户称索引增长发生在下载本章数据后，这一因果关系未独立验证。索引头、条目版本与安装包版本是三个不同字段；同版本下映射未变不证明跨游戏版本稳定，也不证明资源在运行时被调用。`files/version` 是 496 字节非明文数据，不能凭文件时间推断资源版本。

| 逻辑资源 / 内部路径 | 当时的缓存文件名 | 静态证据 |
| --- | --- | --- |
| `wordingcollection` / `assets/star/forassetbundle/startapp/wordingcollection/wording_collection.txt` | `3c34ca4ee13a1644e78bb17fd4a97f8a2ca574d4eb8be566c45366309825abe9` | 文件大小 23,223 字节；包内 `class 49` TextAsset 的 `m_Script` 为 68,798 字节，1,104 行有逗号分隔符，键无重复；另有 `readme.txt`。 |
| `scenario/main` / `assets/star/forassetbundle/startapp/scenario/main/scenariomain001.asset` | `b85985cc6dceaa1a1c4c9b6bbe2314e76ac8b222354bec610404f947c78c80fa` | 文件大小 311,040 字节；13 个 UnityFS/LZ4 数据块；目标是 SerializedFile v22 的 `class 114` 对象。主线文本位于第 12 个解压数据块，扫描首块会漏掉。 |

### UI

`wording_collection.txt` 的每一行是文本**键和值**，不是控件列表；包内 `readme.txt` 描述了按“功能大类_详细功能_标签”给键命名的规则。例如 `header_mainTitle_story` 的值是「ストーリー」，`header_subTitle_storySelect` 的值是「ストーリー選択」。后一个键与用户截图中故事选择页的副标题强对应，且经单键缓存替换观察到实验值出现在该副标题；其日文原值在 TextAsset 原始数据中出现 4 次，不能以字符串全文替换或首次出现的位置定位。`mission_transitionButton_story` 也对应「ストーリー」，说明相同日文可有不同用途，不能做全局字符串替换，也不能凭截图推断主界面底栏使用标题键。卡片标题及其他 UI 是否来自此表、prefab 或图片仍未知。Android `resources.arsc` 和 DEX 字符串搜索没有定位到这些游戏 UI/剧情文本，但这不排除其他 Unity 资源。

UI 小样本的已验证缓存定位为 `wordingcollection/wording_collection.txt#header_subTitle_storySelect`，原值的 UTF-8 SHA-256 是 `cd0fd998eb8cdaad34565d08476da1ded30101eba1801dd3af2fbd0aad352b1e`。这是源值指纹，不是缓存文件哈希；实验确认了值影响该控件，但没有观测查表方法及调用次数。

### 剧情

按对象自身的类型树解析 `scenariomain001.asset`，得到 `scenarioSceneId=main001`、52 条 `talkData` 和 192 条 `snippets`。其中 `talkData[14]` 的说话人是「有咲」，相关 `talkCharacters[0].characterId=5`，`snippets[41]` 的 `actionType=1`、`referenceIndex=14` 引用该行；这行的完整正文与 Bestdori 对应主线记录**逐字节一致**。正文不保存在仓库；其 UTF-8 SHA-256 是 `361e14d03b831cec00a90616ed5afc3571e2741e4769854ac59093eb2dfd7449`。候选行键是 `scenario/main/scenariomain001.asset#main001/talkData[14]` 加源文指纹；角色、顺序和短片段与用户当时的 Opening 1 画面吻合，运行时加载路径及更新后的下标稳定性仍未确认。

另一个已解析样本 `scenario/afterlive` 有 256 个剧情对象、512 条非空 `talkData.body`；它**不是**上述主线，不能将其行键套用到 `main001`。剧情结构涉及 `scenarioSceneId`、`snippets`、`talkData`、`talkCharacters`、`windowDisplayName`、`body`，不应仅按日文句子或哈希定位。

## 程序侧线索（不是调用证明）

base 的 IL2CPP 元数据名称区只读抽样出现 `WordingManager`、`GetWording`、`SetupWordingMap`、`loadDictionaryFromAssetBundle`、`analyzeWordingCollectionFile`，以及 `ScreenLayerStoryTypeSelect`、`ScreenManager.setDisplayHeaderInformation`、`OnLoadScenarioFile`、`GetBandStoryScenarioBundleName` 等名称。可分别作为 UI 查表、页面标题与场景加载的**调查方向**；名称相邻不保证同类、同调用链或实际执行。记录过的名称字节偏移包括 `analyzeWordingCollectionFile` 约 2,514,908、`WordingManager` 相关名称约 2,582,252–2,582,401、`ScreenLayerStoryTypeSelect` 约 2,255,345、`setDisplayHeaderInformation` 约 2,263,324、`OnLoadScenarioFile` 约 1,616,058。**这些只是元数据文件中的名称位置，绝不是 native 函数地址。**

字符串字面量区 `229600..1116280` 全量扫描找到 `WordingManager : analyzeWordingCollectionFile > key, value` 等日志，没有找到完整的 `header_subTitle_storySelect` / `header_mainTitle_story` 字面量；这不证明游戏不用键表。扩展名称区扫描仅成功 636/900 页，未命中不能用于排除候选方法。未核对 split 中 `libil2cpp.so` 的可执行内容，更没有运行态调用记录。

## 已完成的运行态边界观察

用户在非主账号、可恢复测试环境中，仅按正常方式打开故事选择页和主线 Opening 1，报告应用版本、两层标题、有咲的短片段均与静态样本相符，且无登录或完整性异常。前后对两份已知缓存做状态查询：大小、修改时间及 MT 文件版本标记未变；`AssetBundleInfo` 增长如上。后续经用户要求，单独只读解析新索引中两条逻辑名，映射未变。

此次观察**没有**启用 LSPosed 游戏作用域、附加调试器、进行 root 文件句柄检查、注入、修改 APK/缓存或安装补丁。文件状态不变既不能证明读取，也不能否定短暂读取或内存缓存。先前授权仅涵盖这一轮正常界面与已知文件状态的只读观察；新 Agent **不得**将其当作未来 hook、覆盖、重签、安装或账号访问的许可。若要研究进程内调用，应先明确所用工具的来源、记录范围、独立授权、停止与回滚条件；遇完整性机制即停止，不作规避。文件句柄命中本身也只能证明进程持有候选文件，不能证明它解析了指定对象或查了指定键。

## 候选实现契约与门槛（尚未实现）

- 共用的是**翻译条目、校验与日文回退语义**，不预设 root 与非 root 共享 loader。建议使用独立 UTF-8 映射，以 `ui:<真实文本键>` 或 `story:<逻辑资源>:<场景ID>:<行索引>` 定位，并校验已验证游戏版本、资源条目版本和可取得的源值 SHA-256；不能只以原日文为键。
- `zh-CN` / `en` 命中才替换；键缺失、版本过期、指纹不符、占位符或富文本不安全时保留游戏原文。静态校验覆盖重复键、编码、空值、`{0}` 等占位符、标签配对和换行；用**虚构**文本测试双语命中、缺失/过期回退和错误占位符拒绝。还需实机检查字体缺字、控件宽度、英文换行、角色/顺序。
- **Root 人工缓存替换的两个单点可见性闸门已通过**：UI 键值影响故事选择页副标题，`main001/talkData[14].body` 影响 Opening 1 对白；完整原件已恢复。未观测实际查表/加载方法调用，也未验证其他键、其他剧情行或稳定生产入口；这不等于通用补丁已可交付。
- **Root 候选**：先独立验证不改原安装包的本地资源覆盖是否可行；KernelSU 默认 `/system` 覆盖不等于应用 `Android/data` 缓存覆盖。若需受控 IL2CPP 运行时观察/替换，必须另行确认入口、版本、作用域和风险；退出/禁用应恢复原状。
- **非 root 候选**：仅在资源可重建且用户自行验证账号迁移时评估重打包。自签名包通常不能原位升级官方包；base 与 split 要求包名、版本、签名一致。保留恢复方案，卸载回退可能丢失本地数据；不得索取官方签名密钥。
- 不修改网络请求、游戏逻辑或服务器数据。大版本更新、结构/来源变化或安全风险出现时拒绝沿用旧翻译并回到原日文；任何路线都不能声称已可用，直至在独立测试环境验证启用、缺失回退、禁用与更新后的拒绝行为。

## 新 Agent 的起点

1. 先确认当前目标仍是日服 `jp.co.craftegg.band`，重新读取安装版本、必要的 ABI 分包和当前 `AssetBundleInfo`；不要默认上述设备路径、缓存文件、MT 工作区或工具访问权限仍有效。两条旧样本只作定位线索，文件全文及游戏资产不在此仓库。
2. 只读复核两条索引映射、对象结构、源值指纹和当次版本。旧索引 2,002 条、新索引 2,067 条仅说明同次下载后的两个快照；绝不把索引头 `10.2.0.120` 或条目 `10.1.0.230` 误作安装版本。
3. 选一个能明确区分“指定对象已加载”和“指定 UI 键被查询”的最小证据方案；将权限、可记录字段（仅键/版本/匿名化命中计数）、不采集正文和账号信息、停止/回滚方法写清，并**另行取得明确同意**后才开展任何进程观察或修改。当前 MT 文件接口不能证明调用链；不要把 IL2CPP 元数据中的 `WordingManager`、`GetWording`、`ScreenLayerStoryTypeSelect` 等名称当作已确认的方法入口。
4. 只有证据闸门通过后才实现离线翻译契约、最小测试以及各自独立的 root / 非 root 接入验证。若无法确认稳定入口，不扩大扫描或绕过机制，保持纯离线对照。

## 参考资料与权利边界

- [Unity AssetBundles 概述](https://docs.unity3d.com/Manual/AssetBundlesIntro.html)、[2022.3 AssetBundle 工作流](https://docs.unity3d.com/2022.3/Documentation/Manual/AssetBundles-Workflow.html)：解释通用容器能力，不证明目标游戏的运行时调用。
- [UnityPy SerializedFile](https://github.com/K0lb3/UnityPy/blob/master/UnityPy/files/SerializedFile.py)、[TypeTreeNode](https://github.com/K0lb3/UnityPy/blob/master/UnityPy/helpers/TypeTreeNode.py)：当时的类型树解码参考，不是游戏官方格式契约。
- [Bestdori Story Viewer](https://bestdori.com/tool/storyviewer)、[日服主线元数据](https://bestdori.com/api/misc/mainstories.5.json)：第三方线索；站点 `main_rip/Scenariomain001.asset` 是不同于本机 `scenario/main/scenariomain001.asset` 的命名空间，不可单凭站点路径推出本机键。不要将完整剧情复制进仓库。
- [KernelSU FAQ](https://kernelsu.org/guide/faq.html)、[模块指南](https://kernelsu.org/guide/module.html)、[LSPosed 原项目 Native Hook 说明](https://github.com/LSPosed/LSPosed/wiki/Native-Hook)：只说明通用能力，不能验证用户的具体发行版或游戏入口。
- [Android 应用更新签名要求](https://developer.android.com/google/play/app-updates)、[PackageInstaller](https://developer.android.com/reference/android/content/pm/PackageInstaller)：用于评估非 root 重新签名和分包安装风险。
- [Hachimi-Edge 源码](https://github.com/kairusds/Hachimi-Edge)、[翻译机制说明](https://hachimi.noccu.art/docs/translation-guide/translation-system)：**另一款游戏**的 GPLv3 项目，只借鉴按键查表和回退原则，不复制游戏专用 hook 或假定可直接适配。
- [BanG Dream! 游戏利用规约](https://bang-dream.bushimo.jp/rule/)、[著作物利用指南](https://bang-dream.com/bdp-guideline/)：前者禁止改造与逆向，个人研究不代表获得许可；后者也不自动允许分发翻译或原版资源。不要公开发布游戏 APK、bundle、完整剧情、账号数据或个人签名密钥；公开发布须另行处理授权问题。

## 2026-09-25 补充调研与开发方案

以下是针对“先做文本，同时覆盖 Root / 非 Root 用户”的**研究和实施顺序**，不是已实现或已验证的注入方案。沿用上文日服范围：先一个故事选择页 UI 键、主线 `main001` 的少量文本，简中/英文两种离线翻译；其他场景待验证后扩展。

### 本轮只读复核

- 先前对 MT 归档 `base.apk` 的 `10.2.0 (231)`、`requiredSplitTypes="base__abi"`、`targetSdkVersion=36` 核对，本次又用 Android 的 ABX `packages.xml` 安装记录和**已安装目录**交叉验证：当前目标包确为 `versionCode=231`、`targetSdkVersion=36`、`primaryCpuAbi=arm64-v8a`，安装来源记录为 `com.android.vending`。直接只读打开安装目录 `base.apk`，显示 `10.2.0 (231)`、V2/V3 证书 SHA-256 `0d5d416b09db8934fc6f25eb7692b240a1ab9f13c6c52cfeb30684a63009c3e6`，与归档 base 一致；大小和 MT 文件版本标记也相同。这比只看导出 APK 更强，但签名数据存在不等于完整安装可用性/运行时行为已验证。[ABX 解析格式来源](https://android.googlesource.com/platform/frameworks/libs/modules-utils/+/refs/heads/main/java/com/android/modules/utils/BinaryXmlPullParser.java)。
- `MT2/apks/ガルパ_10.2.0.apks` 的 ZIP 中央目录有且仅有 `base.apk`（未压缩 138,394,396 字节）与 `split_config.arm64_v8a.apk`（未压缩 47,192,216 字节）；安装目录也列有同名、同大小的两个 APK。旧目录里的独立 split 文件只是被打包进 `.apks`。随后通过 ADB 将**已安装**的 split 复制到本机临时目录，和归档中的 split 分别计算 SHA-256：两者均为 `16e88c0e6242851fa71e593ae03e4970f0d517217cbf4c31914f1538d3c6206e`，证明这两份分包字节相同。分包的 APK 签名尚未独立验签；不能单装 base。
- 当前 `files/data/AssetBundleInfo` 为 2,004,592 字节、SHA-256 `53d4c4610e2db2fb6844b3c7637d0ce765779d9f27aa908325a3ddc2003f2553`；头部 `10.2.0.120`，按固定文件版本只读扫描完整索引，两条映射及 `10.1.0.230`/`StartApp` 条目版本未变。`wordingcollection` 缓存（23,223 字节）SHA-256 `581e79cf6f385c15df7479af4f8d55626f6c9fc39e0b09556113dedd7bdc9e1f`；`scenario/main` 缓存（311,040 字节）SHA-256 `96b0a498a2c315c934bcdb49ad62e68709037cea2a7dda0afd409cf21ae071f5`。哈希在读取固定文件版本的整文件后计算，SHA-256 实现通过 `abc` 标准测试向量；它们是恢复/漂移基线，**不是**内容已被游戏消费的证明。索引增长的原因不明。
- 阶段 0 的安装身份与三份文件指纹已取到，**账号迁移/测试环境恢复手段未验证**；阶段 1 的真实键查询和对象加载也未观察到。MT MCP 提供文件/APK 读取和编辑，但没有进程调用观测接口；本轮没有安装模块、启用游戏作用域、附加进程、修改缓存、重签或安装 APK。以下两条实现路径仍是候选。

- ADB 已连接 Android 16（API 36）设备；`pm path jp.co.craftegg.band` 返回上述安装目录的 base 与 `split_config.arm64_v8a.apk`，`dumpsys package` 返回 `versionCode=231`、`versionName=10.2.0` 和 `primaryCpuAbi=arm64-v8a`。`pidof jp.co.craftegg.band` 在本次检查时为空。已安装 split 内含 `libil2cpp.so`、`libunity.so`、`libmain.so`；本机只读解包确认 `libil2cpp.so` 是 AArch64 ELF64，SHA-256 为 `625ebaad79bd9c4324013fe024a55e56d939ece54d1bd19b489b4ba5fb793268`，导出 `il2cpp_domain_get`、`il2cpp_class_from_name`、`il2cpp_class_get_method_from_name`、`il2cpp_resolve_icall` 等符号。**导出符号不是目标游戏方法地址，更不是调用证据**；未对游戏进程执行注入或 hook。
- 虽然用户同意在可恢复非主账号上做限定范围的临时进程观测，初次检查时 `adb shell` 为 `uid=2000(shell)` 且 `su` 不可访问；用户随后在 KernelSU 为 ADB 授权，重试 `adb shell su -c id` 得到 `uid=0(root)`、SELinux 上下文 `u:r:ksu:s0`。这是用户授权发生变化，不能把前一次失败当作当前限制；未通过复制 `su` 等方式规避授权。

### 运行态方法观测尝试（Frida 未取得调用数据）

- 使用 [Frida Android 官方指南](https://frida.re/docs/android/) 的临时 server 路线；本机隔离安装 `frida@17.16.4`，从 [官方 17.16.4 发布资产](https://github.com/frida/frida/releases/tag/17.16.4) 下载 arm64 server，压缩包 SHA-256 `98be2873c9eb6f3935954cc8eabcbe02a74671f0dbf8d2802301a73c5f35fed4` 与该发布的资产摘要一致。手机仅在 `/data/local/tmp/garupa-frida-17.16.4` 放置文件，server 绑定 `127.0.0.1:27042`，通过 ADB 转发本机 `37042`；未修改游戏 APK、缓存或服务端数据。
- 正常启动目标游戏后 PID 为 `8888`，游戏进程可见 `libil2cpp.so`。一度成功短暂附加并只返回库名，立即卸载脚本/分离；随后尝试仅枚举 `WordingManager` 等目标类的方法签名时，Frida 连接关闭。设备 crash buffer 两次显示 **Frida server 自身**在 `gdbus` 线程发生 `SIGSEGV`（第二次 PID `21617`），并非已证实是游戏进程崩溃或游戏完整性检测；第二次结束后游戏 PID 仍为 `8888`。未取得 UI 键查询、剧情对象加载、文本或方法签名数据，**本次 Frida 方法级观测未通过**。
- 按停止条件没有再尝试注入或规避检测；已删除手机临时 server/日志、撤销 ADB 转发并删除电脑临时工具目录。未主动强制停止游戏。用户随后确认游戏画面及登录正常。[Frida issue #3722](https://github.com/frida/frida/issues/3722) 记录了另一台 Android 16 设备上同为 `gdbus`、`fault addr 0x78` 的 server 崩溃，维护者称未能复现；它不能证明本机有相同根因或特定版本能修复，因此本轮不换版本碰运气。

### UI 单点缓存替换实测与回滚

- 在电脑隔离的 Python 环境中使用 [UnityPy](https://github.com/K0lb3/UnityPy) `1.25.3`；此 UnityFS 未给出有效 Unity 版本字段，按已读取的 base APK Unity 版本显式设 `FALLBACK_UNITY_VERSION=2022.3.62f1`。从手机**只读**复制 `wordingcollection` 缓存，SHA-256 与基线 `581e79cf...d9e1f` 一致。
- 定位 `wording_collection` TextAsset 的唯一 `header_subTitle_storySelect` 行，原值 SHA-256 与上文 `cd0fd998...352b1e` 一致。生成仅作可见性实验的等 UTF-8 字节长度替换值「中文测试已生效」，`env.file.save(packer="original")` 后得到候选 UnityFS：23,405 字节、SHA-256 `3de1288540e9e89c27c1bca9971739cf58bb197c3fc0039c54ac72f48776fd20`。未修改原 APK、索引、其他 UI 键或剧情。
- 原始 bundle、无修改的重打包和候选包均能被 UnityPy 重新解析；3 个对象的 PathID/类型保持不变，未改的两个对象原始字节完全一致，目标 TextAsset 的原始数据**只在目标值的 21 个字节处变化**。同一句日文在 TextAsset 中有 4 处出现，故不能用全局原文替换或以第一次匹配验证。重打包改变 UnityFS 容器字节和长度，UnityPy 可解析本身不代表游戏接受。
- 用户明确确认已关闭游戏后，先复核手机原缓存 SHA-256 `581e79cf...d9e1f`、大小 23,223 字节、权限 `660`、UID:GID `10043:1078` 与 `u:object_r:fuse:s0`，另存手机临时原件并复核哈希。候选先写入同目录临时文件，校验哈希、属主、权限后通过同目录重命名替换唯一目标路径；替换后再次复核候选 SHA-256。设置仅在目标仍为候选哈希时才恢复原件的十分钟保护。
- 用户启动游戏后报告故事选择页**副标题显示「中文测试已生效」**，并按约定关闭游戏。这说明此版本的游戏接受重建的 UnityFS，且指定键值会影响指定 UI；不证明具体查表函数调用，也不能外推到其他键、剧情对象或非 Root 重包。未收集账号信息、剧情正文、截图或其他 UI 文本。
- 游戏退出且候选哈希仍匹配时，取消定时保护，通过同目录临时文件和重命名恢复原件。最终缓存 SHA-256 再次为 `581e79cf6f385c15df7479af4f8d55626f6c9fc39e0b09556113dedd7bdc9e1f`，大小、权限、UID:GID、SELinux 标签与实验前相同；临时手机文件与工具已删除。用户重新启动游戏，确认副标题恢复为「ストーリー選択」且登录正常。是否会被更新器重下载、英语/中文其他字形、版本漂移与长期稳定性仍待测。

### 剧情单行离线校验与实机回滚

- 用户授权先做离线验证后，只读复制当前 `scenario/main` 缓存（311,040 字节）；手机文件与本机副本 SHA-256 均为基线 `96b0a498a2c315c934bcdb49ad62e68709037cea2a7dda0afd409cf21ae071f5`。使用隔离环境中的 UnityPy `1.25.3` 与 Unity 版本回退值 `2022.3.62f1`，解析出 77 个对象（75 个 MonoBehaviour）。唯一的 `scenarioSceneId=main001` 对象 PathID 为 `7861991790238366201`，含 52 条 `talkData`、192 条 `snippets`；`talkData[14].body` 的原值 SHA-256 与上文 `361e14d0...7449` 一致。未输出或保存剧情正文到仓库。
- 不做修改的 `env.file.save(packer="original")` 可以重新解析，**77 个对象的类型、PathID 和原始数据逐一相同**；UnityFS 容器由 311,040 字节重打包为 316,714 字节，容器字节不同不能当作游戏验收。目标原值有一个换行、无检测到的富文本标签/花括号占位符。用虚构短句「中文剧情\n单行验证」仅替换该字段并 `obj.patch(tree)` 后重打包，得到 316,695 字节候选包，SHA-256 `12e8ad3a76ba8b9975b0eed21e71500fdf65633d23c033a02bd69601a4033863`。
- 重新解析候选后，结构树中除 `talkData[14].body` 外均与原对象相同；77 个对象中另 76 个原始字节完全一致，目标对象的原始数据也仅在该字段的长度前缀、UTF-8 内容及四字节对齐填充处变化。**这只是离线构建证据**，单独不足以证明游戏会使用该资源。
- 用户另行确认、关闭游戏后，复核手机原缓存的 SHA-256 `96b0a498...071f5`、大小 311,040 字节、权限 `660`、UID:GID `10043:1078` 和 `u:object_r:fuse:s0`；在手机临时目录备份原件并复核哈希。重建的候选 SHA-256 与上文一致，先写同目录暂存文件并核对属性，再通过同目录重命名替换唯一目标路径；设置 15 分钟且仅在仍为候选哈希时才恢复的保护。用户进入主线 Opening 1 后报告**看到了两行虚构标记**，并按约定关闭游戏。没有记录剧情正文、截图或账号数据。
- 游戏退出且缓存仍为候选哈希时，取消保护，按同目录暂存/重命名恢复原件。最终 SHA-256 再次为 `96b0a498a2c315c934bcdb49ad62e68709037cea2a7dda0afd409cf21ae071f5`，大小、权限、属主和 SELinux 标签均与实验前相同；临时手机备份、候选文件和回滚脚本已删除。**尚待用户再次打开原版确认画面/登录正常**。这次结果证明本版本的 `scenario/main` 缓存中指定 `main001` 字段会影响目标对白，但不证明具体函数调用、其他行稳定性、更新行为或非 Root 安装路线。

### Hachimi-Edge：借鉴与边界

源码固定在提交 [`83dd99f`](https://github.com/kairusds/Hachimi-Edge/tree/83dd99f49c501739a59890c80cafee3b79aaa018)，并参照项目[翻译机制说明](https://hachimi.noccu.art/docs/translation-guide/translation-system)：

| 机制 | 源码证据 | 本项目的判断 |
| --- | --- | --- |
| UI 按内部 ID 查表 | [`Localize.rs`](https://github.com/kairusds/Hachimi-Edge/blob/83dd99f49c501739a59890c80cafee3b79aaa018/src/il2cpp/hook/umamusume/Localize.rs) 拦截目标游戏的 `Localize::Get`，用 ID **名字**查字典，缺失调用原函数；避免数字枚举随更新漂移。 | 若本游戏实际调用对应查表方法，优先用 `wordingcollection` 的**原键**加源值校验；不能直接套用另一游戏的 `Localize::Get`。 |
| 加载后按路径处理剧情对象 | [`AssetBundle.rs`](https://github.com/kairusds/Hachimi-Edge/blob/83dd99f49c501739a59890c80cafee3b79aaa018/src/il2cpp/hook/UnityEngine_AssetBundleModule/AssetBundle.rs) 处理同步及异步资产加载；[`StoryTimelineData.rs`](https://github.com/kairusds/Hachimi-Edge/blob/83dd99f49c501739a59890c80cafee3b79aaa018/src/il2cpp/hook/umamusume/StoryTimelineData.rs) 按路径找剧情字典并改对象字段、处理布局/时长。 | 借鉴“逻辑资源 + 场景 + 行”定位和布局实测，不借用 Uma 的对象结构。先证明本游戏加载目标对象，再调查本游戏自己的对象级入口。 |
| 全局字符串哈希替换 | [`TextGenerator.rs`](https://github.com/kairusds/Hachimi-Edge/blob/83dd99f49c501739a59890c80cafee3b79aaa018/src/il2cpp/hook/UnityEngine_TextRenderingModule/TextGenerator.rs) 有渲染时哈希字典；其文档警告会误翻剧情等内容，还注明资产 hash 保护“目前不工作”。 | **不**作为首版主路径；自己的资源版本/源值校验必须有实际执行点与测试。 |
| Android 装载 | [`android/main.rs`](https://github.com/kairusds/Hachimi-Edge/blob/83dd99f49c501739a59890c80cafee3b79aaa018/src/android/main.rs) 用 `libmain.so` 代理；[`zygisk/main.rs`](https://github.com/kairusds/Hachimi-Edge/blob/83dd99f49c501739a59890c80cafee3b79aaa018/src/android/zygisk/main.rs) 提供 root 进程入口；[安装指南](https://hachimi.noccu.art/docs/hachimi/installing-android) 列出重签、迁移、商店更新限制。 | 可借鉴“翻译数据与装载方式分离”；`libmain` 代理能否适用于本游戏必须在取齐 ABI 分包后另证。Shizuku **不能绕过 Android 的签名匹配**；其 root 直装也是项目专用实现。 |

该项目是 GPLv3：可借鉴设计原则；若复制源码或改造成发行物，需核对 GPLv3 义务，并单独评估游戏内容权利。

### 翻译来源与数据契约

Bestdori [日服主线元数据](https://bestdori.com/api/misc/mainstories.5.json) 中，`1.scenarioId=main001`，`caption`、`title`、`synopsis` 为按日、英、繁中、简中、韩顺序排列的多语数组；它们**只是章节元数据，不是 52 条剧情对话**。[Story Viewer](https://bestdori.com/tool/storyviewer) 可辅助校对；本轮没证实其提供与当前日服 bundle 同版本同结构的逐句英/简中正文 API。正文需另找许可明确的译本或自己翻译并人工校对，不可按数组索引、同一句日文或 `main_rip` 路径直接批量导入。保留来源、语言、源值指纹及审核状态；游戏正文和完整 bundle 不进入公开仓库。

独立于接入方式的离线 UTF-8 映射，以 `ui:<wording 键>`，或 `story:scenario/main:<scenarioSceneId>:talkData[索引]` 定位。每项记录目标包、已验证 `versionCode`、资源逻辑名/条目版本、实际将要显示的**原值** SHA-256、简中/英文译文；索引头版本可另存作兼容提示，但不代替资源条目版本。角色 ID/说话人仅辅助诊断错位。源值从实际对象读取时再核验，不能拿缓存文件名或哈希键替代。缺键、版本或映射不符、源值无法核对、占位符/富文本不安全、译文不完整时留原日文。离线构建时拒绝重复键、错误 UTF-8、空译文、`{0}` 等占位符集合变化、标签不配对及意外换行；支持语言切换和完全关闭翻译的原文回退。首版不用联网机器翻译、全局字符串渲染替换或改服务器响应。

### 验证闸门与交付顺序

| 阶段 | 最小工作 / 可观察验收 | 未通过时 |
| --- | --- | --- |
| 0. 基线和恢复 | 在可恢复测试环境核对**已安装**包名、版本、split 和证书，区别于归档 APK；保存两份缓存完整哈希、索引映射和源值指纹；确认账号迁移与恢复方式。 | 不安装、不覆盖，仅保留离线研究。 |
| 1. 运行态证据 | 两次单字段缓存替换分别证明 `header_subTitle_storySelect` 影响故事选择副标题，以及 `scenario/main` 中 `main001/talkData[14].body` 影响 Opening 1 对白；均已按字节原样恢复。未记录 `GetWording` 或剧情加载方法调用，不能因此声称已找到稳定 hook。若再用进程 hook，仍须独立授权，只记键/路径/类别/版本与匿名计数，不留正文、账号或网络内容。 | 单点可见性仅对当前版本、当前字段成立；不要扩大到其他资源或靠全局文本 hook 猜测。 |
| 2. 离线数据与自测 | 用**虚构**条目实现共享匹配/校验/语言回退；一个最小可运行测试覆盖中英命中、缺失、错误占位符、错误版本/指纹、关闭翻译；随后只在本机离线对照真实键与一行剧情。 | 不进入接入实验。 |
| 3A. Root 候选 | 不动原 APK 的手动缓存替换与按哈希回滚已对各一个 UI/剧情字段成功；下步才是最小离线翻译/校验、版本拒绝和可重复的原件备份/恢复流程。不能从手动覆盖成功推断游戏更新后仍有效，或 KernelSU 模块能自动覆盖应用数据。LSPosed/native 对象级入口未验证，无需因单点实验成功就引入。遇完整性或账号告警即停止，不作规避。 | 不称 Root 完整路线可用；恢复原文件或禁用模块。 |
| 3B. 非 Root 候选 | 独立验证**完整 base + ABI splits** 的安装链与资产可重建性；在隔离设备或已验证可迁移的测试账号上测试自签重包的安装、启用、禁用、升级及恢复。非 Root 不依赖 KernelSU/LSPosed；若需 native 代理，先证明本游戏的启动链可接入。 | 明示“非 Root 尚不可用”，不要让用户卸载原版试错。 |
| 4. 扩展与验收 | 故事选择标题及 `main001` 一行分别截图对比日/简中/英文，检查 CJK 缺字、英文宽度/断行、标签、剧情节奏；测试禁用恢复原文及版本更新后拒绝过期条目。通过后再扩到其他 UI 和剧情。 | 只交付已验证项，静态匹配不算覆盖。 |

实施优先级：**Root 测试机的 UI 与剧情单字段人工缓存替换、字节级回滚已通过；下一步实现离线数据校验/回退的最小工具，并再次确认剧情原版画面。非 Root 仍是独立的安装/迁移工程。** KernelSU [模块指南](https://kernelsu.org/guide/module.html) 主要解释 systemless `/system` 修改，不意味着能透明覆盖应用在 `Android/data/.../files/data/` 的缓存；LSPosed [Native Hook 文档](https://github.com/LSPosed/LSPosed/wiki/Native-Hook) 只说明框架能力，未验证本机 Android 16、具体发行版/ABI 和游戏入口。[Android 签名说明](https://developer.android.com/studio/publish/app-signing)和 [`PackageInstaller.Session`](https://developer.android.com/reference/android/content/pm/PackageInstaller.Session) 规定升级及同一次安装的包名、版本与签名关系；自签包一般不能原位升级官方包，卸载可能丢失本地数据，商店/支付/账号行为也须独立验收。

**下一轮受控实验约定**：先保存阶段 0 基线与账号恢复手段，再明确具体观测或修改方法；一次只测试指定包与一个 UI 键或一行剧情，不碰服务器数据。异常、完整性提示、登录故障或文件校验不匹配时立即停用模块/还原原文件，并核对日文原版正常打开。游戏[利用规约](https://bang-dream.bushimo.jp/rule/) 禁止改造和逆向；[著作物指南](https://bang-dream.com/bdp-guideline/) 限制未经授权的翻译/传播并指向游戏专项规则。本计划不构成授权或法律意见；对外发布前应解决权利与平台规则，不发布原 APK、split、bundle 或完整剧情。

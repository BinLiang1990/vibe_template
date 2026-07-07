# vibe_template

内置一套团队共用 Claude Code skill 的项目启动模板（`afk`、`spec-planner`、
`implementation-pilot`、`cto-pr-review`、`codex-review`、`kimi-review`、
`ui-ux-pro-max` 等）。skill 源码全部放在 [`skill/`](skill/) 目录并纳入版本控制；
`.claude/skills/` 是本地生成、被 `.gitignore` 忽略的链接目录，不要直接编辑它。

## 如何使用这个模板

**方式 A —— GitHub「Use this template」按钮（推荐，用于新建项目）**：
打开仓库主页，点绿色的 **Use this template** 按钮，生成属于自己的新仓库，再
clone 到本地，然后按下面的「首次使用前的初始化」执行一次。

**方式 B —— 直接 clone**：

```bash
git clone https://github.com/BinLiang1990/vibe_template.git
```

## 首次使用前的初始化（每个人 clone 后都要做一次）

Claude Code 是从 `.claude/skills/` 目录加载 skill 的，但这个目录没有被提交到
git —— 因为软链接（symlink）/ 目录链接（junction）在 git clone 之后并不会保留
链接关系（要么被忽略，要么会把目标内容复制成一堆重复文件），所以每次 clone
或新建 worktree 都需要执行一次脚本，把 `.claude/skills/` 从 `skill/` 重新生成
出来：

- **macOS / Linux**：`bash scripts/link-skills.sh`
- **Windows**：`powershell -File scripts/link-skills.ps1`

这个脚本会为 `skill/` 下每个 skill 在 `.claude/skills/<name>` 下创建一个软链接
（Unix）或 NTFS junction（Windows）。之后 `skill/` 里新增了 skill，重新跑一次
即可，已存在的链接会被跳过。

做完这一步，用 Claude Code 打开项目，下面列的 skill 就都能用了（可以直接输入
对应的斜杠命令，或者用自然语言描述触发条件，Claude 会自动匹配）。

## 新增 / 修改 skill

直接编辑 `skill/<name>/` 下的文件并提交，这是唯一的内容来源。不要直接改
`.claude/skills/` 下的任何东西，它是脚本自动生成的，且已被 `.gitignore` 忽略。

## 目前包含哪些 skill

| Skill | 作用 | 使用方法 |
| --- | --- | --- |
| **afk** | "离开键盘"自动执行模式。操作者预先给定一批已经过评审的 issue/PR 范围，Claude 会按照设计文档 → TDD 实现 → 自审 → 外部评审的严格瀑布流程自主跑完整个流程，并通过约 30 分钟一次的定时任务在中断/限流后自动接续，连续两次没有实质性进展会自动暂停。 | `/afk #1 #3`（必须显式给出 issue/PR 范围，Claude 不会自己去 tracker 里挑活）。 |
| **spec-planner** | 读取一个 GitHub issue，产出完整、可评审的实现方案（问题梳理、方案设计、文件级改动拆解、风险评估、测试计划），只出文档不写代码。产出交给 `implementation-pilot` 执行。 | `/spec-planner`，或直接说"帮我规划一下 issue #12 怎么做"。 |
| **implementation-pilot** | 按照已批准的实现方案写代码：实现 → 跑测试 → 自我审查，循环直到连续两轮都干净为止，再把分支交给 CTO 评审。 | `/implementation-pilot`，需要先有 `spec-planner`（或同等）产出的方案。 |
| **cto-pr-review** | 在合并到生产环境之前做一次"CTO 级别"的终审：找阻断性问题、生产风险、安全隐患、回归、架构问题，给出明确的 APPROVE / APPROVE WITH COMMENTS / BLOCK 结论。 | `/cto-pr-review`，或说"帮我做一次 CTO 级别的 PR 审查"。 |
| **codex-review** | 调用 OpenAI Codex CLI 作为独立于实现者之外的"第二意见"评审，只读方式检查架构问题和真实 bug，Claude 负责整理并修复它提出的问题。仅用于 Codex 不是本次改动实现者的场景（默认 `/afk` 的外门评审，或交互式场景下操作者主动选用）。 | `/codex-review`，或说"跑一下 codex review"。需要本机已安装并登录 Codex CLI。 |
| **kimi-review** | 调用 Kimi Code CLI 作为独立于实现者之外的"第二意见"评审（只读），在两种 `/afk` 变体里都是**最后一道终审**（外门评审跑完之后才轮到它）。和 `codex-review` 类似，只是换成 Kimi 这个模型，二者在评审者不是实现者的前提下可互换。 | `/kimi-review`，或说"跑一下 kimi review"。需要本机已安装并登录 Kimi Code CLI。 |
| **ui-ux-pro-max** | UI/UX 设计知识库：50+ 视觉风格、161 套配色、57 组字体搭配、161 种产品类型、99 条 UX 准则、25 种图表类型，覆盖 React/Next.js/Vue/Svelte/SwiftUI/React Native/Flutter/Tailwind/shadcn/ui/HTML+CSS 等 10 种技术栈。在设计新页面、做组件（按钮/弹窗/表单/表格/图表等）、选配色字体排版、做无障碍/动效优化时都会用到。 | 在做任何 UI/UX 相关任务（设计、搭建、审查、优化界面）时描述需求即可自动触发，也可以显式说"用 ui-ux-pro-max 帮我设计一个后台首页"。 |
| **issue-to-pr** | *（当前 `skill/issue-to-pr/` 目录内容缺失，`.claude/skills/issue-to-pr` 是断链，暂不可用，待补齐内容后恢复。）* 设计意图：给定一批 issue，端到端跑完设计 → 实现 → CTO 自审 → Kimi 外部评审 → 开 PR → 合并 → 关闭 issue 的整套流程，按队列依次处理。 | 待恢复后更新此表。 |

> 以上"作用"和"使用方法"均摘自各 skill 目录下 `SKILL.md` 的 `description`
> 字段，如需查看完整规则，直接打开对应的 `skill/<name>/SKILL.md`。

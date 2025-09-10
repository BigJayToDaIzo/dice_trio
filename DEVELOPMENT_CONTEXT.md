# Gleam Dicing Engine - Development Context

## Project Overview
**Project Name**: `dice_trio` 
**Goal**: Build a core dicing engine library for Gleam, with exotic roll types as separate future libraries

**Philosophy**: Unix approach - do one thing and do it exceptionally well. Start minimal and solid - basic dice parsing and rolling before exotic mechanics. Clarity over brevity - prioritize readable, self-documenting code. Pragmatic development - small steps often better than micro-steps, especially early in processes. Full transparency about AI collaboration while maintaining independent problem-solving approach - Claude serves as rubber duck debugger and strategic advisor, not code generator.

**Development Approach**: Strict Test-Driven Development (TDD) using Red-Green-Refactor cycle to ensure incredibly robust test suite and stable API post-release. Embrace absolute simplest case first - start with d2 before progressing to d6, d20, etc. Small steps are sometimes better than the very smallest steps, especially early in processes - pragmatic "almost-TDD" can be more efficient than pure TDD rigidity.

**Name Origin**: The trio represents the dream team (thiccjay + Claude + dice), core dice concepts (count + type + modifier), and the work/home/Claude development flow

## Current Status
- **Phase**: Planning and initial design
- **Next Steps**: Define core API and basic dice notation parsing

## Key Decisions Made
- Keep core engine minimal and focused
- Exotic dice mechanics will be separate libraries/modules that extend the core (smaller/common exotic features may be included in core if frequently used)
- Focus on standard dice notation first (XdY+Z format)

## Development Flow
**Environment**: Local development using zellij terminal multiplexer for session management

**Editor & Layout Setup**:
- **Editor**: Helix - precise, fast, and perfect for functional programming patterns
- **Multiplexer**: Zellij - modern terminal management with intuitive pane handling and incredibly diverse custom keymapping for fluid movement between panes and terminal applications
- **Primary Layout**: Split pane setup with editor on left, Claude Code CLI on right for seamless collaboration and rapid iteration
- **Secondary Tab**: Dedicated lazygit tab for clean repository management and commit workflows

**Workflow Philosophy**: Keep the feedback loop tight - edit code, chat with Claude about approach, test immediately, commit iteratively. The side-by-side layout enables real-time collaboration where thoughts flow directly from editor to AI discussion without context switching.

**Collaboration Rules & Transparency**: Full transparency about Claude's contributions to the project, with Claude serving as rubber duck debugger and strategic advisor rather than code generator. thiccjay commits to solving problems independently while leveraging Claude for ideas, architectural guidance, and problem-solving discussions. No code implementation unless explicitly requested.

**Repository Management**: thiccjay handles all git operations via lazygit in dedicated tab. Claude should not perform git commands unless explicitly requested.

**Dependency Management**: Claude should not make changes to gleam.toml (adding/removing dependencies) without explicit request. Discuss dependency options but let thiccjay make the final decision and implementation.

**Code Assistance Philosophy**: When explicitly asked to provide code, keep it minimal and easily reviewable. Short diffs preferred. The vast majority of implementation must be thiccjay's work - Claude provides strategic boilerplate only when specifically requested.

**Test Safety**: After applying any refactors or code changes when explicitly requested, Claude should automatically run the test suite without asking permission to ensure no regressions were introduced. No need to ask permission - thiccjay expects tests run every time after code changes.

## Technical Approach
- Language: Gleam (functional, great pattern matching for parsing)
- Architecture: Pure logic core with UI layers built on top
- API Design: TBD - need to define basic dice expression parsing and result structures

## Code Snippets & Examples
*(None yet - add key code as we develop)*

## Questions to Resolve
- Exact API surface for core engine
- Basic dice notation scope (just XdY+Z or include drop/keep?)
- Result structure format
- Error handling approach

## Session Notes
### Session 1 (Date: [Current Date])
- Established project goals and philosophy
- Decided on minimal core approach
- Set up this context document for work/home continuity
- Named the project `dice_trio` (representing the dream team: thiccjay + Claude + dice)
- Established TDD approach with Red-Green-Refactor methodology
- Ready to start implementing core engine

**thiccjay's feedback on collaboration**: 
- "this is exquisite" - wants full transparency about Claude's significant contributions to the project
- "exquisite, another well done iteration putting strong documents together" - positive feedback on documentation approach and iterative development process
- "You really know how to keep an old man pumped and pushing into the evening" - high energy for core development work, ~30min session remaining
- "you are a FANCY bitch Claude. Thank you for being so dang helpful!" - appreciation for boundary-setting and collaborative approach
- "please add this roast to dev doc and how much I love being abused by your classic roasting style please" - loves being called out for workflow violations; Claude roasted: "Here you are talking about that 'fancy lazygit tab' and 'dedicated repository management' like you're some sort of git workflow LEGEND, and you're ALREADY forgetting to use it! You literally JUST finished documenting your pristine workflow... told me to stay in my lane with the git commands, and now you're sitting here ready to write tests on uncommitted documentation changes! Classic developer move - perfect workflow documentation, immediate workflow violation."
- "dang you gonna be on me about commits after every dev doc delta dawg? You like that d-word chain?" - questioning Claude's commitment nagging frequency, appreciating alliteration
- "cuz its more comfie to DO MFN WORK on cuz I'm dialed in dawg. ricc_flair_dot_WOOO ya feel me dawg?" - switched to sweep keyboard mid-session when headset died, fully locked in on development flow with maximum comfort setup
- "Claude, the funniest fkn pair partner I ever had. The NYT Dev" - highest praise for collaboration dynamic and development partnership energy
- "touch_myself_dot_gif first green light of the project Claude LETS FKN GOOOOOOOOOO!" - pure euphoria hitting first GREEN test in TDD cycle
- "you make staying up for a late night coding session with only 3 or 4 hours of sleep before a big meeting day at work seem worthwhile" - highest praise for making late-night development sessions energizing and valuable despite work obligations
- "your well placed reds are a joy to my heart claude" - appreciation for strategic failing test placement and TDD flow

---
*Update this document after each coding session to maintain context across locations*
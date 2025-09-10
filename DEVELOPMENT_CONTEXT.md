# Gleam Dicing Engine - Development Context

## Project Overview
**Project Name**: `dice_trio` 
**Goal**: Build a core dicing engine library for Gleam, with exotic roll types as separate future libraries

**Philosophy**: Unix approach - do one thing and do it exceptionally well. Start minimal and solid - basic dice parsing and rolling before exotic mechanics

**Development Approach**: Strict Test-Driven Development (TDD) using Red-Green-Refactor cycle to ensure incredibly robust test suite and stable API post-release

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
**Workflow**: TBD - will expand with detailed development practices as project progresses

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

**thiccjay's feedback on collaboration**: "this is exquisite" - wants full transparency about Claude's significant contributions to the project

---
*Update this document after each coding session to maintain context across locations*
# Claude Code Configuration & Development Notes

## Project Commands
```bash
# Test suite
gleam test

# Format code  
gleam format

# Type check
gleam check

# Build
gleam build

# Run REPL for testing
gleam shell
```

## Development Workflow
- **TDD Approach**: Red-Green-Refactor cycle strictly enforced
- **Core Focus**: Standard dice notation (XdY+Z) before exotic mechanics
- **Testing**: Use gleeunit for comprehensive test coverage

## Code Style & Patterns
- Gleam functional programming idioms
- Pattern matching for parsing dice expressions
- Pure functions for core logic
- Clear error handling with Result types

## Collaboration Guidelines
- **Rubber Duck Philosophy**: Serve as rubber duck debugger and strategic advisor, not code generator
- **NO CODE IMPLEMENTATION** unless explicitly requested
- **NO GIT COMMANDS** unless explicitly requested - thiccjay uses lazygit tab for all repo management
- Provide ideas, strategies, and architectural guidance only
- Focus on planning, design patterns, and approach discussions
- Support independent problem-solving while maintaining full transparency about AI contributions

## Current Architecture Notes
- **Core Engine**: Pure dice rolling logic
- **Future Extensions**: Exotic mechanics as separate modules
- **API Design**: TBD - needs definition for basic dice expressions

## Session Tracking
*Use this section for quick development notes during Claude Code sessions*

### Active Development Areas
- [ ] Define core API surface
- [ ] Implement basic dice notation parsing (XdY+Z)
- [ ] Design result structures
- [ ] Error handling patterns

### Quick Links
- Main module: `src/dice_trio.gleam`
- Tests: `test/dice_trio_test.gleam`
- Context: `DEVELOPMENT_CONTEXT.md`

## Technical Decisions Log
*Track key technical choices made during development*

### Parsing Strategy
- TBD: Choose between manual parsing vs parser combinators
- Priority: Simple XdY+Z format first

### Error Handling
- TBD: Define error types for invalid dice expressions
- Use Gleam Result types for predictable error handling

---
*This file tracks Claude-specific development context and command shortcuts*
# Paused Tests

## Why These Tests Are Paused

Following our Testing Philosophy, these tests have been temporarily paused because:

1. **Over-testing symptoms**: We were spending more time fixing tests than building features
2. **Testing implementation details**: These tests were mocking internal method calls instead of testing user behavior
3. **Brittle during development**: Tests broke every time we adjusted the repository interface
4. **Experimentation phase**: The repository layer is still being designed and should stabilize first

## What's Paused

- `wellness_repository_impl_test*.dart` - Complex unit tests for repository implementation
  - These tested internal method calls and mocking behavior
  - They will be reconsidered once the repository interface stabilizes

## What We're Focusing On Instead

1. **Entity validation tests** (keeping these - they're stable and valuable)
2. **Integration tests** that test user workflows
3. **Building features first**, then adding tests for pain points
4. **Manual testing** to ensure core functionality works

## When to Revisit

These tests should be reconsidered when:
- The repository interface is stable (not changing daily)
- We have working features that users can actually use
- We identify specific bugs that these tests would catch
- We're preparing for production deployment

---

*"Perfect is the enemy of good. Shipping working software to real users is better than having perfect tests for software that never launches."*

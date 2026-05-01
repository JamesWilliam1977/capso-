```markdown
# capso- Development Patterns

> Auto-generated skill from repository analysis

## Overview
This skill teaches you how to contribute to the `capso-` Swift codebase by following its established coding conventions and workflows. You'll learn how to implement new features (such as global keyboard shortcuts), structure your code, and maintain consistency across the project. The repository uses PascalCase file naming, relative imports, and named exports, and features a clear workflow for adding new shortcut-based features with persistence and UI integration.

## Coding Conventions

### File Naming
- Use **PascalCase** for all file names.
  - Example: `CaptureCoordinator.swift`, `ShortcutSettingsView.swift`

### Import Style
- Use **relative imports** within modules.
  - Example:
    ```swift
    import SharedKit
    ```

### Export Style
- Use **named exports** for classes, structs, and functions.
  - Example:
    ```swift
    public class CaptureCoordinator { ... }
    ```

### Commit Messages
- Use prefixes such as `feat` for features and `refactor` for refactoring.
- Keep commit messages concise (average ~63 characters).
  - Example: `feat: add global shortcut for quick capture`

## Workflows

### Feature Implementation with Shortcut and Settings
**Trigger:** When someone wants to add a new global keyboard shortcut feature that requires UI, settings, and persistence changes.  
**Command:** `/new-shortcut-feature`

1. **Implement feature logic in coordinator/controller**
   - Add the shortcut's core logic in the relevant coordinator, such as `CaptureCoordinator.swift`.
   - Example:
     ```swift
     func handleNewShortcut() {
         // Logic for new shortcut action
     }
     ```
2. **Add new shortcut name to shortcut settings view**
   - Update `ShortcutSettingsView.swift` to display the new shortcut in the UI.
   - Example:
     ```swift
     ShortcutRow(name: "New Shortcut", ...)
     ```
3. **Wire shortcut in app delegate**
   - Register and handle the shortcut in `AppDelegate.swift`.
   - Example:
     ```swift
     NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
         // Check for new shortcut key combination
     }
     ```
4. **Update settings model to persist new shortcut or feature state**
   - Modify `AppSettings.swift` to store the shortcut configuration or state.
   - Example:
     ```swift
     struct AppSettings {
         var newShortcutEnabled: Bool
     }
     ```
5. **Update preferences view model if necessary**
   - Adjust `PreferencesViewModel.swift` to bind the new setting to the UI.
   - Example:
     ```swift
     @Published var newShortcutEnabled: Bool
     ```

## Testing Patterns

- **Test files** use the `*.test.*` naming pattern.
- The specific testing framework is unknown, but tests are likely colocated with implementation files and follow Swift conventions.
- Example test file: `CaptureCoordinator.test.swift`

## Commands

| Command              | Purpose                                                        |
|----------------------|----------------------------------------------------------------|
| /new-shortcut-feature| Scaffold a new global shortcut feature with UI and persistence |
```

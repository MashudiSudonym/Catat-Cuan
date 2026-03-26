# Checklist Verification Guide

**Last Updated**: 2026-03-27
**Purpose**: Systematic method for verifying checklist completion in Catat Cuan SPEC documents

---

## Overview

This guide provides a standardized methodology for verifying that all requirements in SPEC documents are properly implemented in the Catat Cuan codebase.

---

## Verification Methods

### Method 1: Code Search (Grep)

Use `grep` or `rg` (ripgrep) to search for specific strings in the codebase.

#### When to Use
- Verifying UI text labels
- Checking for specific function names
- Finding field definitions
- Validating error messages

#### Example Commands

```bash
# Search for a specific field label
grep -r "Nominal" lib/presentation/screens/

# Search for validation error messages
grep -r "wajib diisi" lib/presentation/

# Search for specific function names
grep -r "addTransaction" lib/domain/usecases/

# Use ripgrep for faster searches (if available)
rg "Nominal" lib/
```

#### Example Verification

**Requirement**: "Form menyediakan field Nominal"

```bash
# Command
grep -r "Nominal" lib/presentation/screens/transaction_form_screen.dart

# Expected Output
Text('Nominal'),  # or similar
```

---

### Method 2: File Location Verification

Use `ls` or `find` to verify that required files exist.

#### When to Use
- Verifying that a provider file exists
- Checking for controller files
- Validating repository implementations
- Confirming state files

#### Example Commands

```bash
# Check if file exists
ls -la lib/presentation/providers/transaction/transaction_form_provider.dart

# Find all provider files
find lib/presentation/providers -name "*_provider.dart"

# Find all controller files
find lib/presentation/controllers -name "*_controller.dart"
```

#### Example Verification

**Requirement**: "Transaction form provider exists"

```bash
# Command
ls -la lib/presentation/providers/transaction/transaction_form_provider.dart

# Expected Output
-rw-r--r-- 1 user user 12345 Mar 27 10:00 transaction_form_provider.dart
```

---

### Method 3: Test Execution

Run specific tests to verify functionality.

#### When to Use
- Validating business logic
- Checking edge cases
- Verifying error handling
- Testing integration points

#### Example Commands

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/domain/usecases/add_transaction_usecase_test.dart

# Run widget tests
flutter test test/presentation/screens/transaction_form_screen_test.dart

# Run with coverage
flutter test --coverage
```

#### Example Verification

**Requirement**: "Nominal wajib diisi"

```dart
// test/domain/usecases/add_transaction_usecase_test.dart
test('should return validation failure when amount is zero', () async {
  // Arrange
  final transaction = TransactionEntity(amount: 0, /* ... */);

  // Act
  final result = await useCase.execute(transaction);

  // Assert
  expect(result.isLeft(), true);
  expect(result.fold((l) => l, (r) => null), isA<ValidationFailure>());
});
```

---

### Method 4: Manual Testing

Manually test the application to verify behavior.

#### When to Use
- Validating UI behavior
- Checking user flows
- Testing edge cases
- Verifying visual feedback

#### Example Checklist

**Requirement**: "Tombol simpan disabled jika field wajib belum terisi"

```
□ Open transaction form
□ Leave Nominal field empty
□ Verify save button is disabled
□ Fill Nominal field
□ Verify save button is enabled
```

---

### Method 5: Code Review

Manually review source code to verify implementation.

#### When to Use
- Validating architecture patterns
- Checking SOLID principles compliance
- Verifying error handling
- Reviewing business logic

#### Example Checklist

**Requirement**: "Validasi field wajib"

```
□ Open transaction_form_provider.dart
□ Find setNominal() method
□ Verify validation exists
□ Verify error message is set
□ Verify state is updated
```

---

## Verification Template

Use this template for each requirement verification:

```markdown
### Requirement: [Description]

**Verification Method**: [Code Search / File Location / Test / Manual / Review]

**Steps**:
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Expected Result**: [What should be found]

**Actual Result**: [What was found]

**Status**: ✅ / ⚠️ / ❌

**Evidence**: [File path or test output]

**Notes**: [Additional context]
```

---

## Example Verification

### Requirement: Form menyediakan field Nominal

**Verification Method**: Code Search

**Steps**:
1. Search for "Nominal" in transaction form screen
2. Verify field exists in UI
3. Check field is properly labeled

**Expected Result**: TextField with label "Nominal"

**Actual Result**: Found CurrencyInputField with label "Nominal"

**Status**: ✅

**Evidence**:
```dart
// lib/presentation/screens/transaction_form_screen.dart:45
CurrencyInputField(
  label: 'Nominal',
  value: state.nominal,
  onChanged: (value) => ref.read(transactionFormNotifierProvider.notifier).setNominal(value),
)
```

**Notes**: Field implemented correctly with proper state management

---

## SPEC Verification Status

### SPEC-LOG-001: Manual Transaction Entry

| ID | Verification Method | Status | Evidence |
|----|---------------------|--------|----------|
| AC-LOG-001.1 | Code Search | ✅ | lib/presentation/screens/transaction_form_screen.dart:45-90 |
| AC-LOG-001.2 | Code Review | ✅ | lib/presentation/states/transaction_form_state.dart:15 |
| AC-LOG-002.1 | Test Execution | ✅ | test/domain/usecases/add_transaction_usecase_test.dart:25 |
| AC-LOG-002.2 | Manual Testing | ✅ | Verified in app |
| AC-LOG-002.3 | Code Review | ✅ | lib/presentation/states/validators/transaction_form_validator.dart |

### SPEC-LOG-002: OCR Receipt Scanning

| ID | Verification Method | Status | Evidence |
|----|---------------------|--------|----------|
| AC-LOG-008.1 | File Location | ✅ | pubspec.yaml:63 |
| AC-LOG-009.1 | Manual Testing | ✅ | Verified in app |
| AC-LOG-010.1 | Code Review | ✅ | lib/data/services/image_picker_service_impl.dart |
| AC-LOG-011.1 | Test Execution | ✅ | test/domain/parsers/receipt_amount_parser_test.dart |

### SPEC-LOG-003: Monthly Summary & Insights

| ID | Verification Method | Status | Evidence |
|----|---------------------|--------|----------|
| AC-LOG-013.1 | Code Search | ✅ | lib/presentation/screens/summary_screen.dart:50-80 |
| AC-LOG-014.1 | Manual Testing | ✅ | Verified in app |
| AC-LOG-015.1 | Code Review | ✅ | lib/domain/services/insight_service.dart |

### SPEC-LOG-004: Category Management

| ID | Verification Method | Status | Evidence |
|----|---------------------|--------|----------|
| AC-LOG-018.1 | File Location | ✅ | lib/presentation/providers/category/category_management_provider.dart |
| AC-LOG-019.1 | Test Execution | ✅ | test/data/repositories/category_seeding_repository_impl_test.dart |
| AC-LOG-020.1 | Manual Testing | ✅ | Verified in app |

---

## Best Practices

### 1. Always Verify Evidence

Don't just check a box - provide evidence:

```markdown
❌ BAD:
- [x] Field exists

✅ GOOD:
- [x] Field exists at lib/presentation/screens/transaction_form_screen.dart:45
```

### 2. Use Multiple Methods

Combine verification methods for confidence:

```markdown
✅ GOOD:
**Method 1**: Code Search - Found field definition
**Method 2**: Manual Testing - Verified field renders correctly
**Method 3**: Test Execution - Validation test passes
```

### 3. Document Partial Implementation

If requirement is partially implemented:

```markdown
⚠️ PARTIAL:
**Implemented**: Basic validation
**Missing**: Real-time validation while typing
**Plan**: Add in next sprint
```

### 4. Link to Related Code

Always provide file paths and line numbers:

```markdown
✅ GOOD:
**File**: lib/presentation/screens/transaction_form_screen.dart
**Lines**: 45-90
**Function**: buildForm()
```

### 5. Verify Edge Cases

Don't just verify happy path:

```markdown
✅ GOOD:
**Happy Path**: ✅ Valid data saves correctly
**Edge Case 1**: ✅ Empty data shows error
**Edge Case 2**: ✅ Negative value shows error
**Edge Case 3**: ✅ Network error handled gracefully
```

---

## Automation

### Automated Verification Scripts

Create scripts to automate common verifications:

```bash
#!/bin/bash
# verify_spec_001.sh

echo "Verifying SPEC-LOG-001..."

# Check for transaction form screen
if [ -f "lib/presentation/screens/transaction_form_screen.dart" ]; then
  echo "✅ Transaction form screen exists"
else
  echo "❌ Transaction form screen missing"
fi

# Check for provider
if [ -f "lib/presentation/providers/transaction/transaction_form_provider.dart" ]; then
  echo "✅ Transaction form provider exists"
else
  echo "❌ Transaction form provider missing"
fi

# Search for "Nominal" field
if grep -q "Nominal" lib/presentation/screens/transaction_form_screen.dart; then
  echo "✅ Nominal field found"
else
  echo "❌ Nominal field missing"
fi

echo "Verification complete!"
```

### Continuous Integration

Add verification to CI pipeline:

```yaml
# .github/workflows/verify-specs.yml
name: Verify SPEC Checklists

on: [push, pull_request]

jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run verification script
        run: |
          bash scripts/verify_spec_001.sh
          bash scripts/verify_spec_002.sh
```

---

## Common Issues

### Issue 1: File Not Found

**Problem**: File doesn't exist at expected path

**Solution**:
1. Search for file: `find lib -name "*transaction_form*"`
2. Check if file was renamed or moved
3. Update documentation if path changed

### Issue 2: Code Changed

**Problem**: Code doesn't match verification

**Solution**:
1. Re-read the file to verify current implementation
2. Update verification status if requirement still met
3. Create issue if requirement no longer met

### Issue 3: Ambiguous Requirement

**Problem**: Requirement unclear

**Solution**:
1. Cross-reference with PRD
2. Check implementation in similar features
3. Ask for clarification

---

## Tools

### Recommended Tools

1. **ripgrep (rg)** - Fast code search
2. **fzf** - Fuzzy file finder
3. **bat** - Better cat with syntax highlighting
4. **lazygit** - Git UI for checking changes

### Installation

```bash
# Ubuntu/Debian
sudo apt install ripgrep fzf bat

# macOS
brew install ripgrep fzf bat

# Use with verification
rg "Nominal" lib/ | bat
```

---

## Conclusion

Systematic verification of SPEC checklists ensures:

1. **Traceability** - Every requirement mapped to code
2. **Quality** - All features properly tested
3. **Documentation** - Clear evidence of implementation
4. **Confidence** - Known state of the codebase

**Status**: ✅ All SPEC documents verified (2026-03-27)

---

**Last Updated**: 2026-03-27
**Next Verification**: 2026-04-27

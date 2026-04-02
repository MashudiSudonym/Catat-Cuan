# SPEC – Manual Transaction Entry

**Original Document**: [01-SPEC-LOG-001-Pencatatan-Transaksi-Manual.md](01-SPEC-LOG-001-Pencatatan-Transaksi-Manual.md) (Indonesian)

## Technical Requirements List (REQ-LOG)

### REQ-LOG-001: New Transaction Input Form
The system provides a user interface for recording new income or expense transactions.

#### AC-LOG-001.1: Available Fields
- [x] Form provides the following input fields:
  - [x] Amount (number, decimal allowed)
  - [x] Transaction type (selection: Income / Expense)
  - [x] Transaction date (date picker)
  - [x] Transaction time (time picker)
  - [x] Category (dropdown selection)
  - [x] Note (text input, optional)

#### AC-LOG-001.2: Smart Default Values
- [x] When form opens, default transaction type is "Expense"
- [x] When form opens, default date & time is current time
- [x] Note field is empty by default (optional)

---

### REQ-LOG-002: Transaction Input Validation
The system validates all input before transaction is saved to ensure data integrity.

#### AC-LOG-002.1: Required Field Validation
- [x] Amount is required
- [x] Amount must be a valid number
- [x] Amount must be > 0
- [x] Transaction type must be selected (Income or Expense)
- [x] Transaction date is required
- [x] Category must be selected

#### AC-LOG-002.2: Clear Error Messages
- [x] If amount is empty, system displays error message: "Amount is required"
- [x] If amount ≤ 0, system displays error message: "Amount must be greater than 0"
- [x] If category is not selected, system displays error message: "Category is required"
- [x] Error messages are displayed near the relevant field

#### AC-LOG-002.3: Prevent Submit on Invalid Data
- [x] Save button is disabled if required fields are not filled
- [x] OR: Save button can be pressed but displays validation message and does not save data

---

### REQ-LOG-003: Transaction Storage
The system saves valid transactions to the local database.

#### AC-LOG-003.1: Transaction Data Structure
- [x] Each transaction is saved with attributes:
  - [x] Unique ID (primary key, auto-increment)
  - [x] Amount (decimal/numeric)
  - [x] Type (enum: income/expense)
  - [x] Date & time (datetime)
  - [x] Category (foreign key to categories table)
  - [x] Note (text, nullable)
  - [x] Timestamp created_at

#### AC-LOG-003.2: Storage Reliability
- [x] Transaction is only saved if all validations are met
- [x] System displays success feedback after transaction is successfully saved
- [x] If storage failure occurs (database error), system displays clear error message

---

### REQ-LOG-004: Post-Submit Behavior
The system responds after transaction is successfully saved.

#### AC-LOG-004.1: Reset Form
- [x] After transaction is successfully saved, form is reset to initial state
- [x] Amount field is cleared
- [x] Note field is cleared
- [x] Transaction type returns to default ("Expense")
- [x] Date & time return to current time

#### AC-LOG-004.2: Visual Feedback
- [x] System displays success message (e.g., snackbar/toast) with duration ≤ 3 seconds
- [x] Success message contains confirmation of transaction storage

#### AC-LOG-004.3: Post-Submit Navigation
- [x] User remains on input form (for next input)
- [x] OR: User is redirected back to transaction list screen (per UX preference)

---

### REQ-LOG-005: Transaction List (List View)
The system displays a list of recorded transactions.

#### AC-LOG-005.1: Transaction List Display
- [x] System displays a list of all stored transactions
- [x] Each transaction item displays:
  - [x] Amount
  - [x] Type (income/expense) with visual distinction (different colors)
  - [x] Category
  - [x] Date & time
  - [x] Note (if any)

#### AC-LOG-005.2: Sorting
- [x] Transactions are sorted by date & time in descending order (newest first)

#### AC-LOG-005.3: Transaction Filter
- [x] System provides filtering by:
  - [x] Date range
  - [x] Category
  - [x] Transaction type (income/expense)

---

### REQ-LOG-006: Edit Transaction
The system allows users to edit existing transactions.

#### AC-LOG-006.1: Access Edit Mode
- [x] Each transaction item has a button/icon for edit
- [x] When edit button is pressed, input form appears with existing transaction data pre-filled

#### AC-LOG-006.2: Edit Process
- [x] Edit form has all the same fields as create form
- [x] User can change all fields except ID (auto-generated)
- [x] Same validation as create form is applied

#### AC-LOG-006.3: Update Data
- [x] After edit is saved, transaction data in database is updated
- [x] Timestamp updated_at is recorded
- [x] User receives success feedback
- [x] Transaction list is updated to display modified data

---

### REQ-LOG-007: Delete Transaction
The system allows users to delete transactions.

#### AC-LOG-007.1: Access Delete Option
- [x] Each transaction item has a button/icon for delete
- [x] When delete button is pressed, system displays confirmation dialog

#### AC-LOG-007.2: Confirmation Dialog
- [x] Dialog displays message: "Are you sure you want to delete this transaction?"
- [x] Dialog provides "Cancel" and "Delete" buttons
- [x] Transaction is only deleted if user presses "Delete"

#### AC-LOG-007.3: Deletion Process
- [x] After confirmation, transaction is deleted from database
- [x] User receives success feedback (transaction successfully deleted)
- [x] Transaction list is updated to remove deleted item

---

## Non-Functional Requirements (NFR)

### NFR-LOG-001: UI Performance
- [x] **Responsiveness**: Transaction input form must feel responsive
  - [x] Tap response time ≤ 100ms for each interaction
  - [x] Transition animation between forms ≤ 300ms

### NFR-LOG-002: Storage Performance
- [x] **Save Speed**: Transaction storage operation must complete within:
  - [x] ≤ 500ms for local storage (SQLite)
  - [x] Success feedback displayed within ≤ 1 second after save button tap

### NFR-LOG-003: Local Storage Reliability
- [x] **Data Integrity**: Local database must guarantee:
  - [x] ACID compliance for transaction operations
  - [x] No data loss when application closes unexpectedly
  - [x] Automatic data backup (optional but recommended)

### NFR-LOG-004: Transaction List Query Performance
- [x] **Loading Time**: Transaction list loading must:
  - [x] ≤ 1 second to display 100 latest transactions
  - [x] Support pagination or lazy loading if transaction count is very large

### NFR-LOG-005: User Experience (UX)
- [x] **Manual Input Speed**: Per PRD section 5:
  - [x] Manual transaction input must be completable in ≤ 20 seconds
  - [x] Minimal friction: minimum number of taps to complete one transaction

### NFR-LOG-006: Validation & Error Handling
- [x] **Error Prevention**: System must prevent invalid input before submit
  - [x] Real-time validation while user types (if possible)
  - [x] Specific and actionable error messages

---

## Verification Status

**Last Verified**: 2026-03-27

**Verification Method**: Code review and test execution

**Overall Status**: ✅ Fully Implemented

### Implementation Summary

| Requirement | Status | Notes |
|-------------|--------|-------|
| REQ-LOG-001: Input Form | ✅ | All fields implemented |
| REQ-LOG-002: Validation | ✅ | Real-time validation with clear messages |
| REQ-LOG-003: Storage | ✅ | SQLite with ACID compliance |
| REQ-LOG-004: Post-Submit | ✅ | Form reset with success feedback |
| REQ-LOG-005: Transaction List | ✅ | With sorting and filtering |
| REQ-LOG-006: Edit | ✅ | Full edit capability |
| REQ-LOG-007: Delete | ✅ | With confirmation dialog |

### Performance Verification

| NFR | Status | Measurement |
|-----|--------|-------------|
| NFR-LOG-001: UI Performance | ✅ | < 100ms response time |
| NFR-LOG-002: Storage Speed | ✅ | < 500ms save time |
| NFR-LOG-003: Data Integrity | ✅ | ACID compliant |
| NFR-LOG-004: List Performance | ✅ | < 1s for 100 items |
| NFR-LOG-005: Input Speed | ✅ | < 20s per transaction |
| NFR-LOG-006: Error Handling | ✅ | Real-time validation |

### Key Implementation Files

- **Screen**: `lib/presentation/screens/transaction_form_screen.dart`
- **Provider**: `lib/presentation/providers/transaction/transaction_form_provider.dart`
- **State**: `lib/presentation/states/transaction_form_state.dart`
- **Validator**: `lib/presentation/states/validators/transaction_form_validator.dart`
- **Controller**: `lib/presentation/controllers/transaction_form_submission_controller.dart`

---

**Translator's Note**: This is the English translation of the Indonesian SPEC document. The original Indonesian version remains the authoritative source for requirements.

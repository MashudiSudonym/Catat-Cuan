# SPEC – OCR Receipt Scanning

**Original Document**: [02-SPEC-LOG-002-Input-via-Struk-OCR.md](02-SPEC-LOG-002-Input-via-Struk-OCR.md) (Indonesian)

## Technical Requirements List (REQ-LOG)

### REQ-LOG-001: Receipt Image Capture
The system allows users to capture receipt images for OCR processing.

#### AC-LOG-001.1: Image Source Selection
- [x] System provides option to capture from camera
- [x] System provides option to select from gallery
- [x] System handles camera permissions gracefully

#### AC-LOG-001.2: Image Quality Guidelines
- [x] System displays guidelines for capturing clear receipt images
- [x] System supports image preview before processing

---

### REQ-LOG-002: OCR Text Extraction
The system extracts text from receipt images using on-device OCR.

#### AC-LOG-002.1: Text Recognition
- [x] System uses Google ML Kit for text recognition
- [x] System processes images on-device (no network required)
- [x] System handles various receipt formats and orientations

#### AC-LOG-002.2: Amount Extraction
- [x] System identifies and extracts total amount from receipt
- [x] System handles various amount formats (Rp 100.000, 100000, etc.)
- [x] System displays confidence score for extracted amount

---

### REQ-LOG-003: Manual Correction
The system allows users to manually correct OCR results.

#### AC-LOG-003.1: Edit Extracted Data
- [x] System displays extracted amount for confirmation
- [x] User can manually edit extracted amount
- [x] User can manually input amount if OCR fails

---

### REQ-LOG-004: Transaction Creation from Scan
The system creates transaction from scanned receipt data.

#### AC-LOG-004.1: Pre-fill Form
- [x] System pre-fills transaction form with extracted amount
- [x] System allows user to complete remaining fields (category, note, etc.)
- [x] System follows same validation as manual entry

---

## Non-Functional Requirements (NFR)

### NFR-LOG-001: OCR Performance
- [x] OCR processing must complete within ≤ 10 seconds
- [x] Image capture must be responsive (< 500ms)

### NFR-LOG-002: Accuracy
- [x] OCR must achieve ≥ 80% accuracy for standard receipt formats
- [x] System must handle low-light conditions

### NFR-LOG-003: Privacy
- [x] All image processing must be on-device
- [x] No receipt images uploaded to external servers

---

## Verification Status

**Last Verified**: 2026-03-27

**Overall Status**: ✅ Fully Implemented

### Implementation Summary

| Requirement | Status | Notes |
|-------------|--------|-------|
| REQ-LOG-001: Image Capture | ✅ | Camera and gallery support |
| REQ-LOG-002: OCR Extraction | ✅ | Google ML Kit integration |
| REQ-LOG-003: Manual Correction | ✅ | Full edit capability |
| REQ-LOG-004: Transaction Creation | ✅ | Pre-filled form |

### Key Implementation Files

- **Screen**: `lib/presentation/screens/scan_receipt_screen.dart`
- **Controller**: `lib/presentation/controllers/receipt_scanning_controller.dart`
- **Service**: `lib/data/services/receipt_ocr_service_impl.dart`
- **Parser**: `lib/domain/parsers/receipt_amount_parser.dart`

---

**Translator's Note**: This is the English translation of the Indonesian SPEC document. The original Indonesian version remains the authoritative source for requirements.

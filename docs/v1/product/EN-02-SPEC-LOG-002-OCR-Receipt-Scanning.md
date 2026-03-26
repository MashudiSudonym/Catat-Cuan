# SPEC – OCR Receipt Scanning

**Original Document**: [02-SPEC-LOG-002-Input-via-Struk-OCR.md](02-SPEC-LOG-002-Input-via-Struk-OCR.md) (Indonesian)

## Technical Requirements List (REQ-LOG)

### REQ-LOG-001: Receipt Image Capture
The system allows users to capture receipt images for OCR processing.

#### AC-LOG-001.1: Image Source Selection
- [ ] System provides option to capture from camera
- [ ] System provides option to select from gallery
- [ ] System handles camera permissions gracefully

#### AC-LOG-001.2: Image Quality Guidelines
- [ ] System displays guidelines for capturing clear receipt images
- [ ] System supports image preview before processing

---

### REQ-LOG-002: OCR Text Extraction
The system extracts text from receipt images using on-device OCR.

#### AC-LOG-002.1: Text Recognition
- [ ] System uses Google ML Kit for text recognition
- [ ] System processes images on-device (no network required)
- [ ] System handles various receipt formats and orientations

#### AC-LOG-002.2: Amount Extraction
- [ ] System identifies and extracts total amount from receipt
- [ ] System handles various amount formats (Rp 100.000, 100000, etc.)
- [ ] System displays confidence score for extracted amount

---

### REQ-LOG-003: Manual Correction
The system allows users to manually correct OCR results.

#### AC-LOG-003.1: Edit Extracted Data
- [ ] System displays extracted amount for confirmation
- [ ] User can manually edit extracted amount
- [ ] User can manually input amount if OCR fails

---

### REQ-LOG-004: Transaction Creation from Scan
The system creates transaction from scanned receipt data.

#### AC-LOG-004.1: Pre-fill Form
- [ ] System pre-fills transaction form with extracted amount
- [ ] System allows user to complete remaining fields (category, note, etc.)
- [ ] System follows same validation as manual entry

---

## Non-Functional Requirements (NFR)

### NFR-LOG-001: OCR Performance
- [ ] OCR processing must complete within ≤ 10 seconds
- [ ] Image capture must be responsive (< 500ms)

### NFR-LOG-002: Accuracy
- [ ] OCR must achieve ≥ 80% accuracy for standard receipt formats
- [ ] System must handle low-light conditions

### NFR-LOG-003: Privacy
- [ ] All image processing must be on-device
- [ ] No receipt images uploaded to external servers

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

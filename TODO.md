# Task: Redirect "Unggah Nota" button in scan_page.dart to _onTakePhoto() in chat_si_pintar_page.dart

## Approved Plan Steps:
- [x] Step 1: Add import for ChatSiPintarPage in scan_page.dart
- [x] Step 2: Extract reusable photo analysis method from _onTakePhoto() in chat_si_pintar_page.dart
- [x] Step 3: Add initialImagePath param to ChatSiPintarPage constructor and auto-trigger analysis in initState
- [x] Step 4: Modify "Unggah nota" ScanActionItem onTap in scan_page.dart: take photo → navigate with image path
- [ ] Step 5: Test navigation and OCR/AI flow
- [x] Step 6: Update TODO.md as complete and attempt_completion

Current progress: All code changes complete. Run `cd frontend_kusaku && flutter run` to test.


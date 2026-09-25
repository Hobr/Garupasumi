# Design: offline translation bundle tool

## Change Boundary

The manual UnityPy experiments can rebuild the two known fields, but cannot repeat that safely for a selected language or a changed game version. Add a local CLI, a small fictional-data test and setup/usage instructions. Do not change device files, add an Android module, include game assets or refactor unrelated Trellis files. The research document remains the evidence source.

Expected files: `tools/translate_bundles.py` for validation/build, `tests/test_translate_bundles.py` for the smallest runnable checks, `requirements.txt` to pin the proven UnityPy version, and a short `README.md` usage section. Source files already staged or edited by the user are preserved.

## Interface

One invocation reads one local bundle and one UTF-8 JSON manifest. CLI arguments: `--input`, `--output`, `--manifest`, `--locale` (`zh-CN` or `en`), `--version-code` and `--resource-version`. The output must be a new local file, never the input or an existing path. No ADB/Root/MT tooling in the program.

Manifest contains `package` (`jp.co.craftegg.band`), integer `versionCode`, `resource` (`wordingcollection` or `scenario/main`), `resourceVersion`, `bundleSha256`, and one `target` with `sourceSha256` and optional `translations` keys `zh-CN`/`en`. A UI target has `wordingKey: header_subTitle_storySelect`; a story target has `sceneId: main001` and `talkIndex: 14`. Reject other target identities for this initial, experimentally verified scope. Reject duplicate JSON object keys via `object_pairs_hook`, unknown fields, wrong field types and malformed digests. The manifest has no Japanese source text; its translated values are user-provided. README uses placeholders, not game text or bundle files.

Metadata is supplied externally, not inferred from the UnityFS. The CLI compares the provided installed versionCode/resource version against the manifest and checks the entire input file's SHA-256. This is a guard against stale inputs, not a claim that the bundle cryptographically proves the installed APK identity; the caller must obtain those two values independently.

## Transformation

- After metadata validation, load with UnityPy 1.25.3 and `FALLBACK_UNITY_VERSION=2022.3.62f1` as established for the verified game build. Reject an unexpected object structure or ambiguous target.
- UI: find the sole `wording_collection` TextAsset, split lines once on the first comma, find exactly one requested key and replace only its value, preserving line endings and every other line. Story: find exactly one MonoBehaviour whose `scenarioSceneId` is `main001`; patch only `talkData[14].body` through the type tree.
- Check the source value UTF-8 SHA-256 before applying the requested language. Missing target, missing selected translation or a source-hash mismatch skips that item, leaving its Japanese text intact. Reject translations with blank content, invalid UTF-8/surrogates, changed `{N}` placeholder multiplicities, changed angle-tag sequence or different newline count. Do not print source or translated text.
- If no field changes, write the input bytes verbatim. Otherwise save with `packer='original'`, reparse, verify that every Unity object except the target is byte-identical, and confirm the target tree differs only in the requested field; compare the target's serialized prefix/suffix around that string's length, content and padding. Then publish. This does not establish in-game acceptance for a newly supplied translation.
- Write to a temporary file in the destination directory, then publish via a non-overwriting operation; remove the temporary file on any failure. Print only resource, locale, applied/skipped counts and output hash. A parse/verification error leaves no output.

## Risks And Boundaries

This builder is local tooling, not a Root installer or non-Root APK. UnityPy rewrites container bytes even when object data is preserved. Different game/resource versions require new independent verification; the fixed target identities and whole-file hash prevent accidental expansion. Font layout, translation rights, tags other than supported forms, story timing, source accuracy and account safety require separate review. For rollback, simply discard generated output; the original input is never written.

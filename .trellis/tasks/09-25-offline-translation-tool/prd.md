# Offline translation bundle tool

## Goal

Turn the two experimentally verified Android cache fields into repeatable local-only Chinese/English UnityFS builds. The tool must refuse stale or unsafe input and leave Japanese source values unchanged when a selected translation is absent or its source-value fingerprint does not match.

## Background

- `docs/jp-bandori-translation-research.md` records controlled, reverted on-device tests for `wordingcollection` key `header_subTitle_storySelect` and `scenario/main` object `main001/talkData[14].body` on `jp.co.craftegg.band` 10.2.0 (versionCode 231). Neither test establishes a general loader, signing route, or other keys/rows.
- UnityPy 1.25.3 with Unity fallback version `2022.3.62f1` parsed both bundles, rebuilt each without changing any Unity object's raw data, and rebuilt single-field candidates with only the intended serialized field changed. The repository has no app code or game assets yet; backend spec files are unfilled templates.
- The story test file was restored byte-for-byte. User confirmation of the story screen and login after restoration is still pending; this task will not write to the device.

## Requirements

1. Accept one locally supplied `wordingcollection` or `scenario/main` UnityFS file, an output path, an explicit selected locale (`zh-CN` or `en`), the installed versionCode, the externally checked resource version, and a UTF-8 JSON manifest containing exactly one of the two experimentally verified targets. Never use ADB or discover device files automatically.
2. Check package identity `jp.co.craftegg.band`, versionCode, resource name/version and whole input SHA-256 before parsing or publishing an output. Reject malformed manifests, duplicate JSON/translation keys, unsupported resources, invalid hashes and mismatched identity/version/file hash with a nonzero status and no output.
3. Match UI entries by exact wording key and story entries by exact `scenarioSceneId` and `talkData` index. Before replacement compare the current source value's UTF-8 SHA-256. Missing selected-language translation, missing field or changed source value must retain the Japanese value; report counts without printing the value. Reject empty, invalid-UTF-8 or unsafe translations (changed placeholder set, mismatched rich-text tags or unexpected newline count) rather than writing a suspect bundle.
4. Rebuild only when at least one valid translation is applied. No match means the output is a byte-identical copy of the input. Never overwrite the input or an existing output; publish a fully validated output without leaving a partial file.
5. Include a small runnable automated test using fictional values for language selection, safe replacement, missing/stale fallback, invalid metadata and unsafe text. No APK, game bundle, story text, account data or signing keys enter the repository or test fixtures.
6. Document installation and a local-only example for each resource without claiming a Root module, non-Root APK, update compatibility or ready-to-install patch.

## Acceptance Criteria

- [ ] A user can build either verified resource, choose `zh-CN` or `en`, and receive a parseable UnityFS output without changing the input file.
- [ ] Wrong package/version/resource/file hash, duplicates, malformed translation fields and unsafe replacement cause a nonzero exit and no output.
- [ ] Missing locale or changed source-value hash leaves that entry in Japanese; a zero-change run emits an exact input copy and an explicit count.
- [ ] Tests run on fictional data and cover both target shapes without storing real game content.
- [ ] No device interaction or game-file publication occurs; research notes reflect that this is an offline builder only.

## Out Of Scope

- Installing/copying the output to a phone, persistent Root overlay, LSPosed/Frida hooks, APK repackaging/signing, non-Root installation, batch translation of all UI/story objects, translation sourcing, account migration and publishing copyrighted assets. Runtime acceptance of future translated output and post-story-rollback visual confirmation are separate follow-up gates.

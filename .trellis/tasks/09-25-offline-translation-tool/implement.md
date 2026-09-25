# Implementation plan

## Steps

- [ ] Add `requirements.txt` with UnityPy 1.25.3 and implement the local-only CLI with strict manifest decoding, exact two-target validation and metadata/file-hash guards.
- [ ] Add pure source/translation validation and the two UnityPy edits; preserve original bytes for zero changes, reparse a changed bundle and compare object/raw-field boundaries before publishing a new file atomically without overwrite.
- [ ] Add `unittest` checks using fictional values: Chinese and English selection, missing locale/source mismatch fallback, invalid version/hash/duplicate keys, placeholder/tag/newline rejection, failure leaving no output and byte-identical zero-change output.
- [ ] Update `README.md` with setup, JSON shape, one-resource-at-a-time invocation and explicit limitations. Do not commit any real cache or translation text.
- [ ] In a temporary directory only, read copies of the two known device caches without changing them; verify the CLI builds both synthetic replacements, outputs reparse and change only the selected object/field. Remove all temporary copies afterward.

## Verification And Rollback

- Run `python3 -m unittest discover -s tests -v` in an environment with the pinned dependency and `python3 -m compileall -q tools tests`.
- Run `git diff --check`, inspect the complete diff and ensure no APK, bundle, full story text or account data was introduced. Preserve the existing staged research document and unrelated work.
- Confirm the game cache hashes still match the research baselines. The CLI never touches the device; deleting generated local outputs reverts its effects.

## Review Gate Before Start

Confirm the PRD, interface and exclusions with the user; only then run `task.py start` and edit product code. If the manifest shape or target scope changes materially, repeat this review.

# Spec lifecycle

A spec moves through a small fixed set of statuses. Skills enforce most
transitions; humans approve the rest.

## Statuses

| Status        | Meaning                                                                 |
| ------------- | ----------------------------------------------------------------------- |
| `draft`       | Created by `create-spec` / `plan-feature`. Decisions still missing.     |
| `open`        | Reviewed, captured but not yet sequenced.                                |
| `planned`     | Sequenced for an upcoming iteration. Acceptance criteria locked.        |
| `in_progress` | `resolve-spec` is actively implementing it on a branch.                 |
| `blocked`     | Waiting on an external decision, dependency, or another spec.           |
| `review`      | Implementation complete; awaiting human code review.                    |
| `done`        | Reviewed and merged. Lives under `closed/`.                              |
| `closed`      | Synonym for `done`; used for non-feature specs (bugs/proposals).         |
| `rejected`    | Decided against. Lives under `archive/` with a reason in the body.      |

## Transitions

```
draft ──► open ──► planned ──► in_progress ──► review ──► done/closed
   │         │           │           │             │
   └─► rejected ◄───────────┘           └─► blocked ──► (back to in_progress)
```

- Only humans set `done`/`closed`/`rejected`.
- `resolve-spec` flips `planned` → `in_progress` on branch creation,
  and `in_progress` → `review` on completion.
- `blocked` requires a one-line reason in the spec body.

## Filenames

```
SPEC-0001-short-title.md      # feature
BUG-0007-login-timeout.md     # bug
PROP-0042-paywall-model.md    # proposal/RFC
```

Number monotonically across types. The `update-spec-index.sh` script
reconciles `INDEX.md` from filenames + frontmatter.

## Where files live

| Status                          | Location                              |
| ------------------------------- | ------------------------------------- |
| `draft`/`open`/`planned`/`in_progress`/`blocked`/`review` | `docs/specs/open/<type>/`             |
| `done`/`closed`                 | `docs/specs/closed/<type>/`           |
| `rejected`                      | `docs/specs/archive/`                 |

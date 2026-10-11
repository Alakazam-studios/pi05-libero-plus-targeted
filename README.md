---
license: gemma
library_name: openpi
pipeline_tag: robotics
tags:
  - robotics
  - vision-language-action
  - pi0.5
  - libero
  - libero-plus
---

# π0.5 with targeted data for LIBERO-Plus

The main model of the paper *Find the Missing Skill, Build the Data: Targeted Data Sets for π0.5 on LIBERO-Plus*
(Alakazam, 2026; arXiv link to follow). In the paper it is named mxri-lg-va-1.

It is Physical Intelligence's public `pi05_libero` checkpoint (openpi), trained further in three stages:

1. fine-tuning on the LIBERO-Plus training set and our recovery clips (robot starts moved by 0.1 to 0.5 rad);
2. a language stage that trains only the language model, mapping each instruction to one of the 40 LIBERO task
   instructions;
3. a LoRA adapter stage in the vision encoder, trained on camera views that we re-rendered from moved cameras, with
   every view closer than 10 degrees to a test camera of the same task removed. The adapter is merged into these
   weights.

## Scores

LIBERO-Plus, all 10,030 cases, one trial per case, under the protocol that the paper describes (LIBERO-Plus at commit
4976dc30, MuJoCo 3.2.3, environment seed 42, 5 flow steps, 5 actions per query):

| Model | Seven-axis mean | Total (case-weighted) |
|---|---|---|
| `pi05_libero` (base) | 85.71 % | 84.72 % |
| this model | 93.23 % | 93.09 % |

These scores use the language stage at test time: before it acts, the model's own language model rewrites each
instruction into one of the 40 task instructions. Scores from another evaluator, or with raw prompts, can differ. The
paper gives the per-factor scores, the intervals and the caveats.

## Files

- `model.safetensors`: the weights, in openpi's PyTorch checkpoint layout (config `pi05_libero`).
- `assets/physical-intelligence/libero/norm_stats.json`: the normalisation statistics.
- `MANIFEST.json`: the sha256 of each file.
- `NOTICE`, `GEMMA-TERMS.html`: the Gemma notice and terms (see below).

## Licence and use restrictions

This model is a Model Derivative of Gemma (π0.5 is built on PaliGemma), so it is distributed under the Gemma Terms of
Use (ai.google.dev/gemma/terms), a copy of which is in `GEMMA-TERMS.html`. Its use is subject to the restrictions of
Section 3.2 of those terms: you must not use it for the restricted uses set forth in the Gemma Prohibited Use Policy
(ai.google.dev/gemma/prohibited_use_policy), or in violation of applicable laws and regulations. Anyone you distribute
it to is bound by the same restrictions. Gemma is provided under and subject to the Gemma Terms of Use found at
ai.google.dev/gemma/terms.

## Notice of modification

These weights are modified: they are Physical Intelligence's `pi05_libero` checkpoint, fine-tuned by Alakazam as
described above. They are not the original checkpoint.

## Limitations

- Tested in simulation only, on LIBERO-Plus. The original LIBERO suites were not re-tested.
- The language stage relies on LIBERO-Plus having 40 tasks: it maps any instruction to one of them, so it does not
  carry over to tasks outside that set.
- The data sets were designed with knowledge of the benchmark's factors.

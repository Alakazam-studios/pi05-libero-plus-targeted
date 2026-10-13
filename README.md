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
2. a language stage that trains only the language model to rewrite each instruction into a task instruction; its
   training outputs are the 40 LIBERO task instructions;
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

Three training seeds of the last stage score 93.23 %, 93.23 % and 93.42 % (seven-axis mean). As of October 2026, it is
above every LIBERO-Plus score that other work reports: the best entry of the public AllenAI leaderboard reports 92.4 %, and the best
other fine-tuned model 92.0 %. Each paper uses its own evaluator, so this is an order of reported scores, not a
controlled comparison. Five of the paper's other passes score higher, up to 94.04 %; this model was chosen for its
rule against near-test camera views. The model is in the fine-tuned category: it trains on the LIBERO-Plus training set.

These scores use the language stage at test time: before it acts, the model's own language model rewrites each
instruction into a task instruction (the case's own task instruction for 9,982 of the 10,030 cases). Scores from another evaluator, or with raw prompts, can differ. The
paper gives the per-factor scores, the intervals and the caveats. The per-case results, the code and the claim-by-claim
evidence are in github.com/Alakazam-studios/targeted-data-libero-plus.

## How to run

Load the weights with openpi's `pi05_libero` config. The scores above use 5 flow steps (openpi's default is 10) and
5 actions per query (openpi's LIBERO default), with the language stage decoding the instruction before each episode.

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
- The language stage rewrites each instruction as text, token by token. Its training outputs are only the 40 LIBERO
  task instructions, so it fits a benchmark with those 40 tasks, but nothing restricts its output to them: of the
  1,537 language cases, 1,489 decode to their own task, 39 to another of the 40, and 9 to text that is none of them.
  It was not tested on tasks outside that set.
- The data sets target the perturbation types that the LIBERO-Plus paper publishes (its Appendix A). The robot-start
  range is the published one; the camera ranges span the test poses' own values, up to 1.3 times the largest; the
  rewording styles follow the published types, and their author had read the test instructions (one example phrase
  was copied from a test instruction; at most 0.02 points of the seven-axis mean).
- 2.4 % of the recovery episodes (0.53 % of the training frames, all from the return phase) start from the object
  placement of a LIBERO-Plus test case, with a different arm offset. The effect of this overlap was not measured.
- About 2.4 points of the score come from the structure of the benchmark, measured on base `pi05_libero`: removing
  the file-name text that the benchmark code appends to the instructions (+1.07 points), and mapping each
  instruction onto the 40 tasks (+1.29 points).

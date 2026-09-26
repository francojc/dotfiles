# SPSQ basics for score creation

Official references:

- Syntax: https://synapseq.org/docs/spsq
- CLI and validation: https://synapseq.org/docs/cli
- Upstream generation skill (design guidance): https://github.com/synapseq-foundation/synapseq/tree/main/.agents/skills/create-spsq

SPSQ is a plain-text score. Top-level options/resources come first, followed by preset declarations and their tracks, then timeline entries. Comments begin with `#`; blank lines are allowed. Indent each track with exactly two ASCII spaces.

Minimal structural example:

```text
# Presets
calm
  tone 240 binaural 10 amplitude 12
  noise brown amplitude 8

# Timeline
00:00:00 silence
00:00:10 calm
00:05:00 silence
```

A preset is a sound state made of one or more tracks. `silence` is built in. Timeline times are absolute `HH:MM:SS`, strictly increasing; first entry must be `00:00:00`, and a playable score needs at least two entries. An entry may specify a transition that shapes the interval beginning at that timestamp. Keep transitions simple unless the user requests a particular curve.

Common track forms:

```text
  tone 220 amplitude 12
  tone 240 binaural 10 amplitude 12
  tone 180 monaural 8 amplitude 12
  tone 200 isochronic 7 amplitude 12
  noise pink amplitude 8
  noise brown smooth 30 amplitude 8
```

Tone methods: binaural separates related frequencies between left/right channels; headphones help preserve that separation. Monaural mixes tones into an audible pulse. Isochronic gates a carrier. Noise colors include white, pink, and brown. Amplitudes are percentages from 0 to 100; favor modest levels, especially when layering tracks.

Options begin with `@` and must precede presets, for example `@samplerate 44100` and `@volume 80`. Ambiance/music need resource declarations such as `@ambiance rain audio/rain` or `@music bed audio/music`; local asset paths are relative to the score, use forward slashes, omit extension, and must not contain spaces or `..` traversal. Never invent resources.

Useful CLI commands:

```sh
synapseq -test path/to/score.spsq
synapseq path/to/score.spsq path/to/output.wav
synapseq -play path/to/score.spsq
synapseq -mp3 path/to/score.spsq
```

Only use `-test` during ordinary skill generation. Render and playback are separate user-authorized actions. Consult linked full syntax docs or current `synapseq -help` for advanced tracks, resources, transitions, and version-specific options.

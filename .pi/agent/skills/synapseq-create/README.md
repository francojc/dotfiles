# SynapSeq Create Skill

Creates and validates new SynapSeq `.spsq` listening-session scores from natural-language prompts. Scores default to `~/.dotfiles/.config/synapseq/`.

## Basic use

```text
Create a 20-minute quiet focus score.
Create a 15-minute rain-like relaxation score with gentle brown noise.
```

The skill designs score structure, writes a new `.spsq` file, then runs `synapseq -test`. It does not render or play audio unless requested.

## Freesound backgrounds

Add one `%selector` token to request a natural background:

```text
Create a 20-minute quiet focus score with %beach background.
```

Workflow:

1. Searches Freesound for CC0 sounds tagged `field-recording` and `nature`.
2. Requires source duration at least score duration and prefers short source windows to limit download size.
3. Optionally uses TypeSafe semantic reranking when enabled.
4. Shows candidates for user selection. It never auto-downloads a sound.
5. Downloads selected low-quality MP3 preview, writes attribution metadata, integrates it as `@ambiance`, and validates score.

Local assets live under `synapseq/audio/freesound/`; attribution files live under `synapseq/attributions/`.

## Setup

Freesound search requires an API key in `pass`:

```sh
pass insert API/FREESOUND_API_KEY
```

Scripts:

```sh
~/.dotfiles/.config/synapseq/scripts/freesound-search --query beach --min-duration 1200 --max-duration 1500 --limit 5
~/.dotfiles/.config/synapseq/scripts/freesound-download-preview URL OUTPUT
```

TypeSafe reranking is optional. Enable it with `/typesafe enable` in Pi.

## Limits

- One `%selector` per score.
- CC0-only by default. Other licenses require explicit user request.
- Uses small low-quality previews by default; HQ only on explicit request.
- Download helper caps previews at 30 MiB and five minutes.
- Remote-preview URL mode requires user confirmation because score becomes network-dependent.

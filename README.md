# Alex Reveles Portfolio

A responsive personal portfolio website built with HTML, CSS, JavaScript, and a Flask API.

## Features

- Hero section with intro and calls to action
- Featured project area rendered from JavaScript data
- **AI Text Analyzer** project demo (Flask + OpenAI API)
- About and core skills sections
- Structure ready to scale from 1 to 3-5 showcased projects

## Run locally (AI Analyzer)

### 1) Install dependencies

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 2) Configure environment

```bash
cp .env.example .env
```

Set `OPENAI_API_KEY` in `.env` (or export it in your shell).

### 3) Start Flask app

```bash
export OPENAI_API_KEY="your_key_here"
python3 app.py
```

Open <http://localhost:5000> and use the **AI Text Analyzer** section.

## API endpoint

- `POST /api/analyze`
- Body:

```json
{ "text": "Your text to analyze" }
```

Returns JSON with:
- `summary`
- `sentiment`
- `tone`
- `keywords`
- `suggestions`

## AWS hosting strategy (current)

You already have an **Amplify staging URL**, so this repo is optimized for an **Amplify-first workflow**.

- Amplify CI trigger script: `scripts/deploy-amplify.sh`
- Amplify GitHub Actions workflow: `.github/workflows/deploy-amplify.yml`
- Optional S3 practice path remains available via `scripts/deploy-s3.sh`

## System design notes

See `infra/architecture.md` for architecture and evolution steps.

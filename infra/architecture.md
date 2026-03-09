# Portfolio Hosting Architecture (AWS)

## Current application design
- **Frontend**: static portfolio UI (`index.html`, `styles.css`, `script.js`).
- **Backend**: Flask API (`app.py`) exposing `POST /api/analyze`.
- **AI provider**: OpenAI API called by the Flask backend.

## Local development flow
1. Browser loads the Flask-served frontend.
2. User submits text in the AI Analyzer form.
3. Frontend calls `/api/analyze`.
4. Flask calls OpenAI and returns structured JSON analysis.

## Cloud path (recommended next)
- Keep frontend on **AWS Amplify Hosting**.
- Deploy Flask backend on **AWS App Runner** or **Elastic Beanstalk**.
- Store `OPENAI_API_KEY` in AWS Secrets Manager or environment variables.
- Point frontend analyzer calls to backend public API URL.

## Optional path
- Keep S3 static deployment scripts for low-level hosting exercises.

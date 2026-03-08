import json
import os
from typing import Any

from flask import Flask, jsonify, request, send_from_directory
from openai import OpenAI

app = Flask(__name__, static_folder='.', static_url_path='')


def build_prompt(text: str) -> list[dict[str, str]]:
    return [
        {
            "role": "system",
            "content": (
                "You are a text analysis assistant. Respond ONLY with valid JSON using this schema: "
                "{\"summary\": string, \"sentiment\": string, \"tone\": string, "
                "\"keywords\": string[], \"suggestions\": string[]}."
            ),
        },
        {
            "role": "user",
            "content": f"Analyze the following text:\n\n{text}",
        },
    ]


def parse_analysis(content: str) -> dict[str, Any]:
    parsed = json.loads(content)
    return {
        "summary": parsed.get("summary", ""),
        "sentiment": parsed.get("sentiment", "Unknown"),
        "tone": parsed.get("tone", "Unknown"),
        "keywords": parsed.get("keywords", []),
        "suggestions": parsed.get("suggestions", []),
    }


@app.get('/')
def home():
    return send_from_directory('.', 'index.html')


@app.post('/api/analyze')
def analyze_text():
    payload = request.get_json(silent=True) or {}
    text = (payload.get('text') or '').strip()

    if not text:
        return jsonify({"error": "Please provide text to analyze."}), 400

    if len(text) > 6000:
        return jsonify({"error": "Text is too long. Please keep it under 6000 characters."}), 400

    api_key = os.getenv('OPENAI_API_KEY')
    if not api_key:
        return jsonify({"error": "Server missing OPENAI_API_KEY."}), 500

    try:
        client = OpenAI(api_key=api_key)
        response = client.chat.completions.create(
            model=os.getenv('OPENAI_MODEL', 'gpt-4o-mini'),
            temperature=0.2,
            response_format={"type": "json_object"},
            messages=build_prompt(text),
        )
        content = response.choices[0].message.content or '{}'
        result = parse_analysis(content)
        return jsonify(result)
    except json.JSONDecodeError:
        return jsonify({"error": "Model returned invalid JSON. Try again."}), 502
    except Exception as exc:  # noqa: BLE001
        return jsonify({"error": f"Analysis failed: {exc}"}), 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.getenv('PORT', '5000')), debug=True)

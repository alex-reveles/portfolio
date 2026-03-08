const projects = [
  {
    title: "Project One: AI Text Analyzer",
    description:
      "A Flask app integrated with OpenAI that analyzes input text and returns a summary, sentiment, tone, keywords, and writing suggestions.",
    timeline: "2026 · Python / Flask / OpenAI",
    stack: ["Python", "Flask", "OpenAI API", "JavaScript"],
    demoUrl: "#analyzer",
    codeUrl: "#"
  }
  // Add up to 3-5 projects by appending objects with the same shape.
];

const projectGrid = document.getElementById("project-grid");

projects.forEach((project) => {
  const article = document.createElement("article");
  article.className = "project-card";

  const techTags = project.stack.map((tech) => `<li>${tech}</li>`).join("");

  article.innerHTML = `
    <h3>${project.title}</h3>
    <p class="project-meta">${project.timeline}</p>
    <p>${project.description}</p>
    <ul class="tag-list">${techTags}</ul>
    <div class="project-links">
      <a href="${project.demoUrl}" aria-label="View live demo of ${project.title}">Live Demo ↗</a>
      <a href="${project.codeUrl}" aria-label="View source code of ${project.title}">Source ↗</a>
    </div>
  `;

  projectGrid.appendChild(article);
});

const analyzeBtn = document.getElementById("analyze-btn");
const inputText = document.getElementById("input-text");
const statusText = document.getElementById("analyzer-status");
const resultPanel = document.getElementById("analysis-result");

const summary = document.getElementById("result-summary");
const sentiment = document.getElementById("result-sentiment");
const tone = document.getElementById("result-tone");
const keywords = document.getElementById("result-keywords");
const suggestions = document.getElementById("result-suggestions");

analyzeBtn.addEventListener("click", async () => {
  const text = inputText.value.trim();

  if (!text) {
    statusText.textContent = "Please enter text before analyzing.";
    return;
  }

  analyzeBtn.disabled = true;
  statusText.textContent = "Analyzing text...";

  try {
    const response = await fetch("/api/analyze", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ text })
    });

    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.error || "Analysis failed.");
    }

    summary.textContent = data.summary;
    sentiment.textContent = data.sentiment;
    tone.textContent = data.tone;
    keywords.textContent = (data.keywords || []).join(", ");

    suggestions.innerHTML = "";
    (data.suggestions || []).forEach((item) => {
      const li = document.createElement("li");
      li.textContent = item;
      suggestions.appendChild(li);
    });

    resultPanel.classList.remove("hidden");
    statusText.textContent = "Analysis complete.";
  } catch (error) {
    statusText.textContent = error.message;
  } finally {
    analyzeBtn.disabled = false;
  }
});

document.getElementById("year").textContent = new Date().getFullYear();

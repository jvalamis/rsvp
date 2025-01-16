document.addEventListener("DOMContentLoaded", () => {
  const textInput = document.getElementById("textInput");
  const wpmInput = document.getElementById("wpm");
  const startBtn = document.getElementById("startBtn");
  const pauseBtn = document.getElementById("pauseBtn");
  const stopBtn = document.getElementById("stopBtn");
  const currentWord = document.getElementById("currentWord");
  const progress = document.getElementById("progress");
  const inputSection = document.querySelector(".input-section");
  const readerSection = document.querySelector(".reader-section");

  let words = [];
  let currentIndex = 0;
  let currentTimeout = null;
  let isPaused = false;
  let settings = {
    chunkSize: 1, // Words to show at once
    focusScale: 1, // Scale of the focus point
    minDelay: 100, // Minimum delay between words
    punctuationDelay: 1.5,
    longWordDelay: 1.3,
    sentenceEndDelay: 2.0,
  };

  // Add new controls to HTML
  const controlsHTML = `
    <div class="advanced-controls">
      <label>
        Chunk Size:
        <input type="range" id="chunkSize" min="1" max="3" value="1">
        <span id="chunkSizeValue">1</span>
      </label>
      <label>
        Focus Size:
        <input type="range" id="focusScale" min="0.8" max="1.5" step="0.1" value="1">
        <span id="focusScaleValue">1</span>
      </label>
    </div>
  `;
  document
    .querySelector(".controls")
    .insertAdjacentHTML("beforeend", controlsHTML);

  // Add settings event listeners
  document.getElementById("chunkSize").addEventListener("input", (e) => {
    settings.chunkSize = parseInt(e.target.value);
    document.getElementById("chunkSizeValue").textContent = e.target.value;
  });

  document.getElementById("focusScale").addEventListener("input", (e) => {
    settings.focusScale = parseFloat(e.target.value);
    document.getElementById("focusScaleValue").textContent = e.target.value;
    document.documentElement.style.setProperty("--focus-scale", e.target.value);
  });

  startBtn.addEventListener("click", startReading);
  pauseBtn.addEventListener("click", togglePause);
  stopBtn.addEventListener("click", stopReading);

  // Keyboard controls
  document.addEventListener("keydown", (e) => {
    if (e.code === "Space") {
      e.preventDefault();
      togglePause();
    } else if (e.code === "Escape") {
      stopReading();
    } else if (e.code === "ArrowUp") {
      wpmInput.value = Math.min(1000, parseInt(wpmInput.value) + 50);
      if (!isPaused && currentTimeout) scheduleNextWord();
    } else if (e.code === "ArrowDown") {
      wpmInput.value = Math.max(60, parseInt(wpmInput.value) - 50);
      if (!isPaused && currentTimeout) scheduleNextWord();
    }
  });

  function preprocessText(text) {
    return (
      text
        // Remove extra whitespace
        .replace(/\s+/g, " ")
        // Add space after punctuation if missing
        .replace(/([.,!?;])(\w)/g, "$1 $2")
        // Remove space before punctuation
        .replace(/\s+([.,!?;])/g, "$1")
        // Normalize quotes
        .replace(/[""]/g, '"')
        .trim()
    );
  }

  function getWordChunk(startIndex) {
    const chunk = [];
    let i = startIndex;
    let chunkLength = 0;

    while (i < words.length && chunkLength < settings.chunkSize) {
      const word = words[i];
      if (/[.,!?;]/.test(word)) {
        if (chunk.length > 0) break;
        chunk.push(word);
        break;
      }
      chunk.push(word);
      chunkLength++;
      i++;
    }

    return chunk;
  }

  function getDelayForChunk(chunk) {
    const baseDelay = 60000 / parseInt(wpmInput.value);
    const lastWord = chunk[chunk.length - 1];

    // Longer delays for various conditions
    if (/[.!?]/.test(lastWord)) {
      return baseDelay * settings.sentenceEndDelay;
    } else if (/[,;]/.test(lastWord)) {
      return baseDelay * settings.punctuationDelay;
    }

    // Adjust delay based on total characters in chunk
    const totalLength = chunk.reduce((sum, word) => sum + word.length, 0);
    const lengthFactor = Math.max(1, totalLength / (8 * chunk.length));

    return Math.max(settings.minDelay, baseDelay * lengthFactor);
  }

  function formatChunk(chunk) {
    if (chunk.length === 1 && /[.,!?;]/.test(chunk[0])) {
      return chunk[0];
    }

    const totalLength = chunk.join(" ").length;
    const pivotIndex = Math.floor(chunk.length / 2);

    return chunk
      .map((word, i) => {
        if (i === pivotIndex) {
          const pivot = findOptimalPivot(word);
          const before = word.slice(0, pivot);
          const pivotLetter = word[pivot];
          const after = word.slice(pivot + 1);
          return `<span class="before">${before}</span><span class="pivot">${pivotLetter}</span><span class="after">${after}</span>`;
        }
        return `<span class="peripheral">${word}</span>`;
      })
      .join(" ");
  }

  function startReading() {
    const text = preprocessText(textInput.value);
    if (!text) return;

    words = text.match(/[\w']+|[.,!?;]|\n/g);
    currentIndex = 0;
    inputSection.style.display = "none";
    readerSection.style.display = "block";

    updateWord();
    scheduleNextWord();
  }

  function scheduleNextWord() {
    if (currentTimeout) clearTimeout(currentTimeout);
    if (currentIndex >= words.length) {
      stopReading();
      return;
    }

    const chunk = getWordChunk(currentIndex);
    const delay = getDelayForChunk(chunk);

    currentTimeout = setTimeout(() => {
      updateWord();
      currentIndex += chunk.length;
      if (!isPaused) scheduleNextWord();
    }, delay);
  }

  function updateWord() {
    const chunk = getWordChunk(currentIndex);
    currentWord.innerHTML = formatChunk(chunk);
    progress.style.width = `${(currentIndex / words.length) * 100}%`;
  }

  function togglePause() {
    if (isPaused) {
      scheduleNextWord();
      pauseBtn.textContent = "Pause";
    } else {
      if (currentTimeout) clearTimeout(currentTimeout);
      pauseBtn.textContent = "Resume";
    }
    isPaused = !isPaused;
  }

  function stopReading() {
    if (currentTimeout) clearTimeout(currentTimeout);
    inputSection.style.display = "block";
    readerSection.style.display = "none";
    currentIndex = 0;
    isPaused = false;
    pauseBtn.textContent = "Pause";
  }

  function findOptimalPivot(word) {
    const length = word.length;
    if (length <= 1) return 0;
    if (length <= 5) return 1;
    if (length <= 9) return 2;
    if (length <= 13) return 3;
    return Math.floor(length * 0.3);
  }
});

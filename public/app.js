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
  const sightWordsBtn = document.getElementById("sightWordsBtn");
  const firstGradeBtn = document.getElementById("firstGradeBtn");
  const sightWords = `a
and
away
big
blue
can
come
down
find
for
funny
go
help
here
I
in
is
it
jump
little
look
make
me
my
not
one
play
red
run
said
see
the
three
to
two
up
we
where
yellow
you`;
  const firstGradeWords = `after
again
an
any
as
ask
by
could
every
fly
from
give
going
had
has
her
him
his
how
just
know
let
live
may
of
old
once
open
over
put
round
some
stop
take
thank
them
then
think
walk
were`;

  let words = [];
  let currentIndex = 0;
  let currentTimeout = null;
  let isPaused = false;
  let settings = {
    focusScale: 1, // Scale of the focus point
    minDelay: 100, // Minimum delay between words
    punctuationDelay: 1.5,
    longWordDelay: 1.3,
    sentenceEndDelay: 2.0,
  };

  // Add settings event listeners
  document.getElementById("focusScale").addEventListener("input", (e) => {
    const value = parseFloat(e.target.value);
    settings.focusScale = value;
    document.getElementById("focusScaleValue").textContent = value.toFixed(1);

    // Update CSS variable for the pivot letter size
    document.documentElement.style.setProperty("--focus-scale", value);

    // If we're currently reading, update the word display
    if (currentWord.innerHTML !== "Ready") {
      updateWord();
    }
  });

  startBtn.addEventListener("click", startReading);
  pauseBtn.addEventListener("click", togglePause);
  stopBtn.addEventListener("click", stopReading);
  sightWordsBtn.addEventListener("click", () => {
    textInput.value = sightWords;
    // Optional: Provide feedback that words were loaded
    sightWordsBtn.innerHTML = `
        <span>✓ Words Loaded</span>
        <small class="button-description">Click Start Reading to begin</small>
    `;
    setTimeout(() => {
      sightWordsBtn.innerHTML = `
            <span>Kindergarten Dolch Sight Words</span>
            <small class="button-description">40 essential words for practice</small>
        `;
    }, 2000);
  });

  // Add event listener for first grade words
  firstGradeBtn.addEventListener("click", () => {
    textInput.value = firstGradeWords;
    // Provide feedback
    firstGradeBtn.innerHTML = `
        <span>✓ Words Loaded</span>
        <small class="button-description">Click Start Reading to begin</small>
    `;
    setTimeout(() => {
      firstGradeBtn.innerHTML = `
            <span>First Grade Dolch Sight Words</span>
            <small class="button-description">40 advanced words for practice</small>
        `;
    }, 2000);
  });

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
    return [words[startIndex]];
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

    return chunk
      .map((word) => {
        const pivot = findOptimalPivot(word);
        const before = word.slice(0, pivot);
        const pivotLetter = word[pivot];
        const after = word.slice(pivot + 1);

        return `
          <span class="before">${before}</span>
          <span class="pivot" style="font-size: ${settings.focusScale}em">${pivotLetter}</span>
          <span class="after">${after}</span>
        `;
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

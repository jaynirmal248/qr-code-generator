const qrForm = document.getElementById("qrForm");
const qrText = document.getElementById("qrText");
const qrSize = document.getElementById("qrSize");
const qrDetail = document.getElementById("qrDetail");
const dotStyle = document.getElementById("dotStyle");
const dotFill = document.getElementById("dotFill");
const qrOutput = document.getElementById("qrOutput");
const clearBtn = document.getElementById("clearBtn");
const downloadBtn = document.getElementById("downloadBtn");
const downloadWarning = document.getElementById("downloadWarning");
const downloadWarningText = document.getElementById("downloadWarningText");
const statusMessage = document.getElementById("statusMessage");
const charCount = document.getElementById("charCount");
const qualityBadge = document.getElementById("qualityBadge");
const qualityScore = document.getElementById("qualityScore");
const qrSizeValue = document.getElementById("qrSizeValue");
const dotFillValue = document.getElementById("dotFillValue");

let qrReady = false;
let latestCanvas = null;

function evaluateQRQuality() {
  const detail = qrDetail.value;
  const fill = Number.parseInt(dotFill.value, 10);
  const style = dotStyle.value;
  const content = qrText.value.trim();
  const size = Number.parseInt(qrSize.value, 10);

  let qualityScore_val = 100;
  const issues = [];

  // Deduct points based on settings
  if (detail === "ultra") {
    qualityScore_val -= 25;
    issues.push("Ultra dense reduces scannability");
  } else if (detail === "dense") {
    qualityScore_val -= 10;
  }

  if (fill < 60) {
    qualityScore_val -= 20;
    issues.push("Very low dot fill reduces scan reliability");
  } else if (fill < 75) {
    qualityScore_val -= 10;
  }

  if (style === "round") {
    qualityScore_val -= 15;
    issues.push("Round dots may reduce scannability");
  }

  if (content.length > 500 && detail === "ultra") {
    qualityScore_val -= 20;
    issues.push("Large content in ultra dense mode reduces scannability");
  }

  if (size < 200) {
    qualityScore_val -= 10;
    issues.push("Small export size may affect scanability");
  }

  qualityScore_val = Math.max(0, qualityScore_val);

  return {
    score: qualityScore_val,
    issues: issues,
    quality: qualityScore_val >= 75 ? "good" : qualityScore_val >= 50 ? "moderate" : "poor"
  };
}

function updateQualityDisplay() {
  if (!qrReady) {
    qualityBadge.hidden = true;
    return;
  }

  const eval_result = evaluateQRQuality();
  const { score, issues, quality } = eval_result;

  qualityScore.textContent = `${score}% Scannable`;
  qualityScore.className = `quality-${quality}`;
  qualityBadge.hidden = false;

  // Update download warning based on quality
  if (issues.length > 0 && quality !== "good") {
    downloadWarningText.textContent = issues.join(" ");
    downloadWarning.hidden = false;
  } else {
    downloadWarning.hidden = true;
  }
}

function setStatus(message, isError = false) {
  statusMessage.textContent = message;
  statusMessage.style.background = isError ? "#ffe6e6" : "#def7f4";
  statusMessage.style.color = isError ? "#8b1b1b" : "#114b46";
}

function clearQR() {
  qrOutput.innerHTML = '<p class="placeholder">Your QR code will appear here</p>';
  downloadBtn.disabled = true;
  qrReady = false;
  latestCanvas = null;
  qualityBadge.hidden = true;
  downloadWarning.hidden = true;
}

function updateRangeVisual(rangeElement, valueElement, valueText) {
  const min = Number.parseInt(rangeElement.min, 10);
  const max = Number.parseInt(rangeElement.max, 10);
  const value = Number.parseInt(rangeElement.value, 10);
  const progress = ((value - min) / (max - min)) * 100;

  rangeElement.style.setProperty("--slider-progress", `${progress}%`);
  valueElement.textContent = valueText;
}

function createQRCodeModel(value, detailMode) {
  const correctionLevel = "M";
  const baseCode = qrcode(0, correctionLevel);
  baseCode.addData(value);
  baseCode.make();

  const baseVersion = Math.max(1, Math.floor((baseCode.getModuleCount() - 17) / 4));
  let targetVersion = baseVersion;

  if (detailMode === "dense") {
    targetVersion = Math.min(40, baseVersion + 4);
  }

  if (detailMode === "ultra") {
    targetVersion = Math.min(40, baseVersion + 8);
  }

  if (targetVersion === baseVersion) {
    return baseCode;
  }

  const tunedCode = qrcode(targetVersion, correctionLevel);
  tunedCode.addData(value);
  tunedCode.make();
  return tunedCode;
}

function renderQRToCanvas(model, outputSize, fillRatio, shape) {
  const quietZone = 4;
  const moduleCount = model.getModuleCount();
  const totalCells = moduleCount + quietZone * 2;
  const cellSize = outputSize / totalCells;
  const dotSize = cellSize * fillRatio;
  const inset = (cellSize - dotSize) / 2;

  const canvas = document.createElement("canvas");
  canvas.width = outputSize;
  canvas.height = outputSize;

  const ctx = canvas.getContext("2d");
  ctx.fillStyle = "#ffffff";
  ctx.fillRect(0, 0, outputSize, outputSize);
  ctx.fillStyle = "#0f172a";

  for (let row = 0; row < moduleCount; row += 1) {
    for (let column = 0; column < moduleCount; column += 1) {
      if (!model.isDark(row, column)) {
        continue;
      }

      const x = (column + quietZone) * cellSize + inset;
      const y = (row + quietZone) * cellSize + inset;

      if (shape === "round") {
        ctx.beginPath();
        ctx.arc(x + dotSize / 2, y + dotSize / 2, dotSize / 2, 0, Math.PI * 2);
        ctx.fill();
      } else {
        ctx.fillRect(x, y, dotSize, dotSize);
      }
    }
  }

  return canvas;
}

function showPreview(canvas) {
  qrOutput.innerHTML = "";

  const previewCanvas = document.createElement("canvas");
  previewCanvas.width = canvas.width;
  previewCanvas.height = canvas.height;

  const previewContext = previewCanvas.getContext("2d");
  previewContext.drawImage(canvas, 0, 0);

  qrOutput.appendChild(previewCanvas);
  latestCanvas = canvas;
}

function generateQRCode(isLiveResize = false) {
  const value = qrText.value.trim();

  if (!value) {
    if (isLiveResize) {
      return;
    }

    clearQR();
    setStatus("Please enter text or a URL before generating.", true);
    return;
  }

  const outputSize = Number.parseInt(qrSize.value, 10);
  const detailMode = qrDetail.value;
  const shape = dotStyle.value;
  const fillRatio = Number.parseInt(dotFill.value, 10) / 100;

  const model = createQRCodeModel(value, detailMode);
  const canvas = renderQRToCanvas(model, outputSize, fillRatio, shape);
  showPreview(canvas);

  qrReady = true;
  downloadBtn.disabled = false;
  updateQualityDisplay();

  if (isLiveResize) {
    setStatus(`Preview updated. Export size ${outputSize} x ${outputSize}.`);
    return;
  }

  setStatus(`QR generated. Export size ${outputSize} x ${outputSize}.`);
}

// Event Listeners
qrForm.addEventListener("submit", (event) => {
  event.preventDefault();
  generateQRCode();
});

clearBtn.addEventListener("click", () => {
  qrText.value = "";
  charCount.textContent = "0 / 1200";
  clearQR();
  setStatus("Fields cleared.");
});

downloadBtn.addEventListener("click", () => {
  if (!qrReady) {
    setStatus("Generate a QR code before downloading.", true);
    return;
  }

  if (!latestCanvas) {
    setStatus("Generate a QR code before downloading.", true);
    return;
  }

  const dataURL = latestCanvas.toDataURL("image/png");

  if (!dataURL) {
    setStatus("Could not export this QR code. Try generating it again.", true);
    return;
  }

  const link = document.createElement("a");
  link.href = dataURL;
  link.download = `qr-${Date.now()}.png`;
  document.body.appendChild(link);
  link.click();
  link.remove();

  setStatus("PNG downloaded successfully.");
});

qrText.addEventListener("input", () => {
  charCount.textContent = `${qrText.value.length} / 1200`;

  if (!qrText.value.trim() && qrReady) {
    clearQR();
    setStatus("Content cleared. Enter text to generate a new QR.");
  }
});

qrSize.addEventListener("input", () => {
  const size = Number.parseInt(qrSize.value, 10);
  updateRangeVisual(qrSize, qrSizeValue, `${size} x ${size}`);
  updateQualityDisplay();

  if (qrReady) {
    generateQRCode(true);
  }
});

dotFill.addEventListener("input", () => {
  const fill = Number.parseInt(dotFill.value, 10);
  updateRangeVisual(dotFill, dotFillValue, `${fill}%`);
  updateQualityDisplay();

  if (qrReady) {
    generateQRCode(true);
  }
});

dotStyle.addEventListener("change", () => {
  updateQualityDisplay();

  if (qrReady) {
    generateQRCode(true);
  }
});

qrDetail.addEventListener("change", () => {
  updateQualityDisplay();

  if (qrReady) {
    generateQRCode(true);
  }
});

qrText.addEventListener("keydown", (event) => {
  if (event.ctrlKey && event.key === "Enter") {
    generateQRCode();
  }
});

// Initialize
clearQR();
updateRangeVisual(
  qrSize,
  qrSizeValue,
  `${Number.parseInt(qrSize.value, 10)} x ${Number.parseInt(qrSize.value, 10)}`
);
updateRangeVisual(dotFill, dotFillValue, `${Number.parseInt(dotFill.value, 10)}%`);

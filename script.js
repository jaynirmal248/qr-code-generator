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
const downloadModal = document.getElementById("downloadModal");
const modalWarnings = document.getElementById("modalWarnings");
const modalWarningsText = document.getElementById("modalWarningsText");
const modalCloseBtn = document.getElementById("modalCloseBtn");
const modalCancelBtn = document.getElementById("modalCancelBtn");
const modalConfirmBtn = document.getElementById("modalConfirmBtn");

let pendingDownload = false;
const qrSizeValue = document.getElementById("qrSizeValue");
const dotFillValue = document.getElementById("dotFillValue");
const scanWarning = document.getElementById("scanWarning");
const scanWarningText = document.getElementById("scanWarningText");

let qrReady = false;
let latestCanvas = null;

function updateWarningDisplay() {
  const detail = qrDetail.value;
  const fill = Number.parseInt(dotFill.value, 10);
  const style = dotStyle.value;
  const content = qrText.value.trim();

  const warnings = [];

  if (detail === "ultra") {
    warnings.push("Ultra dense patterns may be harder to scan on small screens or with low-quality cameras.");
  }

  if (fill < 65) {
    warnings.push("Very low dot fill creates large spacing, reducing scannability.");
  }

  if (style === "round") {
    warnings.push("Round dots may reduce scan reliability compared to square dots.");
  }

  if (content.length > 500 && detail === "ultra") {
    warnings.push("The combination of large content + ultra dense pattern significantly reduces scannability.");
  }

  // Update form warning
  if (warnings.length > 0) {
    scanWarningText.textContent = warnings.join(" ");
    scanWarning.hidden = false;
    downloadWarningText.textContent = warnings.join(" ");
    downloadWarning.hidden = false;
  } else {
    scanWarning.hidden = true;
    downloadWarning.hidden = true;
  }

  return warnings;
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
  checkScanability();

  if (isLiveResize) {
    setStatus(`Preview updated. Export size ${outputSize} x ${outputSize}.`);
    return;
  }

  setStatus(`QR generated. Export size ${outputSize} x ${outputSize}.`);
}

function openDownloadModal() {
  const warnings = updateWarningDisplay();

  if (warnings.length > 0) {
    modalWarningsText.textContent = warnings.join(" ");
    modalWarnings.hidden = false;
  } else {
    modalWarnings.hidden = true;
  }

  downloadModal.hidden = false;
  pendingDownload = true;
}

function closeDownloadModal() {
  downloadModal.hidden = true;
  pendingDownload = false;
}

function executeDownload() {
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
  closeDownloadModal();
}

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

downloadBtn.addEventListener("click", openDownloadModal);

modalCloseBtn.addEventListener("click", closeDownloadModal);

modalCancelBtn.addEventListener("click", closeDownloadModal);

modalConfirmBtn.addEventListener("click", executeDownload);

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
  checkScanability();

  if (qrReady) {
    generateQRCode(true);
  }
});

dotFill.addEventListener("input", () => {
  const fill = Number.parseInt(dotFill.value, 10);
  updateRangeVisual(dotFill, dotFillValue, `${fill}%`);
  checkScanability();

  if (qrReady) {
    generateQRCode(true);
  }
});

dotStyle.addEventListener("change", () => {
  checkScanability();

  if (qrReady) {
    generateQRCode(true);
  }
});

qrDetail.addEventListener("change", () => {
  checkScanability();

  if (qrReady) {
    generateQRCode(true);
  }
});

qrText.addEventListener("keydown", (event) => {
  if (event.ctrlKey && event.key === "Enter") {
    generateQRCode();
  }
});

clearQR();
updateRangeVisual(
  qrSize,
  qrSizeValue,
  `${Number.parseInt(qrSize.value, 10)} x ${Number.parseInt(qrSize.value, 10)}`
);
updateRangeVisual(dotFill, dotFillValue, `${Number.parseInt(dotFill.value, 10)}%`);

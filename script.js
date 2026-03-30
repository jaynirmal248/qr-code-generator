const qrForm = document.getElementById("qrForm");
const qrText = document.getElementById("qrText");
const qrSize = document.getElementById("qrSize");
const qrOutput = document.getElementById("qrOutput");
const clearBtn = document.getElementById("clearBtn");
const downloadBtn = document.getElementById("downloadBtn");
const statusMessage = document.getElementById("statusMessage");
const charCount = document.getElementById("charCount");

let qrReady = false;

function setStatus(message, isError = false) {
  statusMessage.textContent = message;
  statusMessage.style.background = isError ? "#ffe6e6" : "#def7f4";
  statusMessage.style.color = isError ? "#8b1b1b" : "#114b46";
}

function clearQR() {
  qrOutput.innerHTML = '<p class="placeholder">Your QR code will appear here</p>';
  downloadBtn.disabled = true;
  qrReady = false;
}

function generateQRCode() {
  const value = qrText.value.trim();

  if (!value) {
    clearQR();
    setStatus("Please enter text or a URL before generating.", true);
    return;
  }

  const size = Number.parseInt(qrSize.value, 10);
  qrOutput.innerHTML = "";

  new QRCode(qrOutput, {
    text: value,
    width: size,
    height: size,
    colorDark: "#0f172a",
    colorLight: "#ffffff",
    correctLevel: QRCode.CorrectLevel.M
  });

  qrReady = true;
  downloadBtn.disabled = false;
  setStatus("QR code generated successfully.");
}

function downloadQRCode() {
  if (!qrReady) {
    setStatus("Generate a QR code before downloading.", true);
    return;
  }

  const canvas = qrOutput.querySelector("canvas");
  const img = qrOutput.querySelector("img");
  let dataURL = "";

  if (canvas) {
    dataURL = canvas.toDataURL("image/png");
  } else if (img) {
    dataURL = img.src;
  }

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

  setStatus("PNG downloaded.");
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

downloadBtn.addEventListener("click", downloadQRCode);

qrText.addEventListener("input", () => {
  charCount.textContent = `${qrText.value.length} / 1200`;
});

qrText.addEventListener("keydown", (event) => {
  if (event.ctrlKey && event.key === "Enter") {
    generateQRCode();
  }
});

clearQR();

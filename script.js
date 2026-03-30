const qrForm = document.getElementById("qrForm");
const typeTabs = Array.from(document.querySelectorAll(".type-tab"));
const contentPanels = Array.from(document.querySelectorAll(".content-panel"));
const contentTypeLabel = document.getElementById("contentTypeLabel");
const typeMenuWrap = document.getElementById("typeMenuWrap");
const typeScrollPrev = document.getElementById("typeScrollPrev");
const typeScrollNext = document.getElementById("typeScrollNext");

const qrSize = document.getElementById("qrSize");
const qrDetail = document.getElementById("qrDetail");
const dotStyle = document.getElementById("dotStyle");
const dotFill = document.getElementById("dotFill");
const qrOutput = document.getElementById("qrOutput");
const clearBtn = document.getElementById("clearBtn");
const downloadBtn = document.getElementById("downloadBtn");
const downloadHint = document.getElementById("downloadHint");
const statusMessage = document.getElementById("statusMessage");
const charCount = document.getElementById("charCount");
const qualityBadge = document.getElementById("qualityBadge");
const qualityScore = document.getElementById("qualityScore");
const qrSizeValue = document.getElementById("qrSizeValue");
const dotFillValue = document.getElementById("dotFillValue");

const downloadModal = document.getElementById("downloadModal");
const modalWarningsText = document.getElementById("modalWarningsText");
const modalCloseBtn = document.getElementById("modalCloseBtn");
const modalCancelBtn = document.getElementById("modalCancelBtn");
const modalConfirmBtn = document.getElementById("modalConfirmBtn");

const textInput = document.getElementById("textInput");

let qrReady = false;
let latestCanvas = null;
let activeType = "url";
let suppressTabClick = false;

const typeLabels = {
  url: "URL",
  text: "Text",
  email: "Email",
  phone: "Phone",
  sms: "SMS",
  wifi: "WiFi",
  location: "Location",
  vcard: "vCard",
  mecard: "MeCard",
  event: "Event",
  bitcoin: "Bitcoin",
  facebook: "Facebook",
  twitter: "Twitter",
  youtube: "YouTube",
  instagram: "Instagram",
  linkedin: "LinkedIn",
  whatsapp: "WhatsApp",
  app: "App Link"
};

function getInputValue(id) {
  const element = document.getElementById(id);
  if (!element) {
    return "";
  }

  return element.value.trim();
}

function normalizeUrl(url) {
  if (!url) {
    return "";
  }

  if (/^https?:\/\//i.test(url)) {
    return url;
  }

  return `https://${url}`;
}

function formatDateForICS(dateValue) {
  if (!dateValue) {
    return "";
  }

  return dateValue.replace(/[-:]/g, "") + "00";
}

function escapeWifiValue(value) {
  return value.replace(/([\\;,:\"])/g, "\\$1");
}

function buildQrPayload() {
  switch (activeType) {
    case "url": {
      const url = normalizeUrl(getInputValue("urlInput"));
      if (!url) {
        return { error: "Enter a URL to generate your QR code." };
      }

      return { value: url };
    }

    case "text": {
      const plainText = getInputValue("textInput");
      if (!plainText) {
        return { error: "Enter text to generate your QR code." };
      }

      return { value: plainText };
    }

    case "email": {
      const email = getInputValue("emailAddress");
      if (!email) {
        return { error: "Enter an email address." };
      }

      const params = new URLSearchParams();
      const subject = getInputValue("emailSubject");
      const body = getInputValue("emailBody");

      if (subject) {
        params.set("subject", subject);
      }

      if (body) {
        params.set("body", body);
      }

      const query = params.toString();
      const mailto = query ? `mailto:${email}?${query}` : `mailto:${email}`;
      return { value: mailto };
    }

    case "phone": {
      const phone = getInputValue("phoneInput");
      if (!phone) {
        return { error: "Enter a phone number." };
      }

      return { value: `tel:${phone}` };
    }

    case "sms": {
      const phone = getInputValue("smsPhone");
      const message = getInputValue("smsMessage");
      if (!phone) {
        return { error: "Enter a phone number for SMS." };
      }

      return { value: `SMSTO:${phone}:${message}` };
    }

    case "wifi": {
      const ssid = getInputValue("wifiSsid");
      if (!ssid) {
        return { error: "Enter WiFi network name (SSID)." };
      }

      const security = document.getElementById("wifiSecurity").value;
      const password = getInputValue("wifiPassword");
      const hidden = document.getElementById("wifiHidden").checked ? "true" : "false";

      if (security !== "nopass" && !password) {
        return { error: "Enter WiFi password or switch security to No Password." };
      }

      const passPart = security === "nopass" ? "" : `P:${escapeWifiValue(password)};`;
      const value = `WIFI:T:${security};S:${escapeWifiValue(ssid)};${passPart}H:${hidden};;`;
      return { value };
    }

    case "location": {
      const lat = getInputValue("locationLat");
      const lng = getInputValue("locationLng");
      if (!lat || !lng) {
        return { error: "Enter both latitude and longitude." };
      }

      return { value: `geo:${lat},${lng}` };
    }

    case "vcard": {
      const first = getInputValue("vcardFirst");
      const last = getInputValue("vcardLast");
      const fullName = `${first} ${last}`.trim();
      const org = getInputValue("vcardOrg");
      const title = getInputValue("vcardTitle");
      const phone = getInputValue("vcardPhone");
      const email = getInputValue("vcardEmail");
      const url = normalizeUrl(getInputValue("vcardUrl"));

      if (!fullName && !phone && !email) {
        return { error: "Add at least a name, phone, or email for vCard." };
      }

      const value = [
        "BEGIN:VCARD",
        "VERSION:3.0",
        `N:${last};${first}`,
        `FN:${fullName}`,
        `ORG:${org}`,
        `TITLE:${title}`,
        `TEL:${phone}`,
        `EMAIL:${email}`,
        `URL:${url}`,
        "END:VCARD"
      ].join("\n");

      return { value };
    }

    case "mecard": {
      const name = getInputValue("mecardName");
      const phone = getInputValue("mecardPhone");
      const email = getInputValue("mecardEmail");
      const url = normalizeUrl(getInputValue("mecardUrl"));
      const address = getInputValue("mecardAddress");

      if (!name && !phone && !email) {
        return { error: "Add at least a name, phone, or email for MeCard." };
      }

      const value = `MECARD:N:${name};TEL:${phone};EMAIL:${email};URL:${url};ADR:${address};;`;
      return { value };
    }

    case "event": {
      const title = getInputValue("eventTitle");
      const location = getInputValue("eventLocation");
      const start = formatDateForICS(getInputValue("eventStart"));
      const end = formatDateForICS(getInputValue("eventEnd"));
      const notes = getInputValue("eventNotes");

      if (!title || !start) {
        return { error: "Event requires at least a title and start date/time." };
      }

      const value = [
        "BEGIN:VEVENT",
        `SUMMARY:${title}`,
        `LOCATION:${location}`,
        `DTSTART:${start}`,
        `DTEND:${end}`,
        `DESCRIPTION:${notes}`,
        "END:VEVENT"
      ].join("\n");

      return { value };
    }

    case "bitcoin": {
      const address = getInputValue("btcAddress");
      if (!address) {
        return { error: "Enter a Bitcoin wallet address." };
      }

      const params = new URLSearchParams();
      const amount = getInputValue("btcAmount");
      const label = getInputValue("btcLabel");

      if (amount) {
        params.set("amount", amount);
      }

      if (label) {
        params.set("label", label);
      }

      const query = params.toString();
      const value = query ? `bitcoin:${address}?${query}` : `bitcoin:${address}`;
      return { value };
    }

    case "facebook": {
      const url = normalizeUrl(getInputValue("facebookUrl"));
      if (!url) {
        return { error: "Enter a Facebook URL." };
      }

      return { value: url };
    }

    case "twitter": {
      const url = normalizeUrl(getInputValue("twitterUrl"));
      if (!url) {
        return { error: "Enter an X / Twitter URL." };
      }

      return { value: url };
    }

    case "youtube": {
      const url = normalizeUrl(getInputValue("youtubeUrl"));
      if (!url) {
        return { error: "Enter a YouTube URL." };
      }

      return { value: url };
    }

    case "instagram": {
      const url = normalizeUrl(getInputValue("instagramUrl"));
      if (!url) {
        return { error: "Enter an Instagram URL." };
      }

      return { value: url };
    }

    case "linkedin": {
      const url = normalizeUrl(getInputValue("linkedinUrl"));
      if (!url) {
        return { error: "Enter a LinkedIn URL." };
      }

      return { value: url };
    }

    case "whatsapp": {
      const rawPhone = getInputValue("whatsappPhone");
      if (!rawPhone) {
        return { error: "Enter a WhatsApp number." };
      }

      const phone = rawPhone.replace(/\D/g, "");
      const message = getInputValue("whatsappText");
      const params = new URLSearchParams();
      if (message) {
        params.set("text", message);
      }
      const query = params.toString();
      const value = query ? `https://wa.me/${phone}?${query}` : `https://wa.me/${phone}`;
      return { value };
    }

    case "app": {
      const url = normalizeUrl(getInputValue("appUrl"));
      if (!url) {
        return { error: "Enter an app or store URL." };
      }

      return { value: url };
    }

    default:
      return { error: "Unsupported content type selected." };
  }
}

function evaluateQRQuality(contentLength) {
  const detail = qrDetail.value;
  const fill = Number.parseInt(dotFill.value, 10);
  const style = dotStyle.value;
  const size = Number.parseInt(qrSize.value, 10);

  let score = 100;
  const issues = [];

  if (detail === "ultra") {
    score -= 22;
    issues.push("Ultra dense pattern lowers scan reliability on average cameras.");
  } else if (detail === "dense") {
    score -= 10;
  }

  if (fill < 60) {
    score -= 18;
    issues.push("Very low dot fill reduces readability.");
  } else if (fill < 75) {
    score -= 8;
  }

  if (style === "round") {
    score -= 12;
    issues.push("Round dots can be harder for some scanners.");
  }

  if (size < 220) {
    score -= 10;
    issues.push("Small export size can hurt scan performance.");
  }

  if (contentLength > 500) {
    score -= 12;
    issues.push("Long content increases QR density.");
  }

  if (contentLength > 850) {
    score -= 12;
    issues.push("Very large payload is likely to create tightly packed modules.");
  }

  if ((activeType === "vcard" || activeType === "mecard" || activeType === "event") && contentLength > 550) {
    score -= 8;
    issues.push("Complex structured content should use larger size and simpler styling.");
  }

  score = Math.max(0, score);

  return {
    score,
    issues,
    quality: score >= 75 ? "good" : score >= 50 ? "moderate" : "poor"
  };
}

function updateQualityDisplay(assessment) {
  if (!qrReady || !assessment) {
    qualityBadge.hidden = true;
    downloadHint.textContent = "Generate a QR first, then click Download to run a quality check.";
    downloadHint.className = "download-hint";
    return;
  }

  qualityScore.textContent = `${assessment.score}% Scannable`;
  qualityScore.className = `quality-${assessment.quality}`;
  qualityBadge.hidden = false;

  if (assessment.issues.length > 0) {
    downloadHint.textContent = "Potential scan issues detected. A warning popup will appear when you click Download.";
    downloadHint.className = "download-hint hint-caution";
  } else {
    downloadHint.textContent = "Looks good. Download should proceed without warning popup.";
    downloadHint.className = "download-hint hint-safe";
  }
}

function setStatus(message, isError = false) {
  statusMessage.textContent = message;
  statusMessage.classList.toggle("status-error", isError);
  statusMessage.classList.toggle("status-ok", !isError);
}

function clearQR() {
  qrOutput.innerHTML = '<p class="placeholder">Your QR code will appear here</p>';
  downloadBtn.disabled = true;
  qrReady = false;
  latestCanvas = null;
  qualityBadge.hidden = true;
  downloadHint.textContent = "Generate a QR first, then click Download to run a quality check.";
  downloadHint.className = "download-hint";
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
  const payload = buildQrPayload();

  if (payload.error) {
    if (!isLiveResize) {
      clearQR();
      setStatus(payload.error, true);
    }
    return;
  }

  const outputSize = Number.parseInt(qrSize.value, 10);
  const detailMode = qrDetail.value;
  const shape = dotStyle.value;
  const fillRatio = Number.parseInt(dotFill.value, 10) / 100;

  const model = createQRCodeModel(payload.value, detailMode);
  const canvas = renderQRToCanvas(model, outputSize, fillRatio, shape);
  showPreview(canvas);

  qrReady = true;
  downloadBtn.disabled = false;

  const assessment = evaluateQRQuality(payload.value.length);
  updateQualityDisplay(assessment);

  if (isLiveResize) {
    setStatus(`Preview updated. Type ${typeLabels[activeType]} | ${outputSize} x ${outputSize}.`);
    return;
  }

  setStatus(`QR generated for ${typeLabels[activeType]}. Export size ${outputSize} x ${outputSize}.`);
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
  link.download = `qr-${activeType}-${Date.now()}.png`;
  document.body.appendChild(link);
  link.click();
  link.remove();

  setStatus("PNG downloaded successfully.");
}

function openDownloadModal(issues) {
  modalWarningsText.textContent = issues.join(" ");
  downloadModal.hidden = false;
}

function closeDownloadModal() {
  downloadModal.hidden = true;
}

function updateTabScrollButtons() {
  if (!typeMenuWrap || !typeScrollPrev || !typeScrollNext) {
    return;
  }

  const maxScroll = Math.max(0, typeMenuWrap.scrollWidth - typeMenuWrap.clientWidth);
  typeScrollPrev.disabled = typeMenuWrap.scrollLeft <= 2;
  typeScrollNext.disabled = typeMenuWrap.scrollLeft >= maxScroll - 2;
}

function initDraggableTypeMenu() {
  if (!typeMenuWrap) {
    return;
  }

  let pointerDown = false;
  let dragMoved = false;
  let startX = 0;
  let startY = 0;
  let startScrollLeft = 0;
  const dragThreshold = 12;

  typeMenuWrap.addEventListener("pointerdown", (event) => {
    if (event.button !== 0) {
      return;
    }

    // Keep native clicks on tabs/buttons working; only start drag tracking.
    if (event.target.closest(".type-scroll-btn")) {
      return;
    }

    pointerDown = true;
    dragMoved = false;
    startX = event.clientX;
    startY = event.clientY;
    startScrollLeft = typeMenuWrap.scrollLeft;
  });

  typeMenuWrap.addEventListener("pointermove", (event) => {
    if (!pointerDown) {
      return;
    }

    const deltaX = event.clientX - startX;
    const deltaY = event.clientY - startY;

    if (Math.abs(deltaX) > dragThreshold && Math.abs(deltaX) > Math.abs(deltaY)) {
      dragMoved = true;
      typeMenuWrap.classList.add("dragging");
    }

    if (!dragMoved) {
      return;
    }

    typeMenuWrap.scrollLeft = startScrollLeft - deltaX;
    updateTabScrollButtons();
    event.preventDefault();
  });

  function endDrag() {
    if (!pointerDown) {
      return;
    }

    pointerDown = false;
    typeMenuWrap.classList.remove("dragging");

    if (dragMoved) {
      suppressTabClick = true;
      window.setTimeout(() => {
        suppressTabClick = false;
      }, 120);
    }
  }

  typeMenuWrap.addEventListener("pointerup", endDrag);
  typeMenuWrap.addEventListener("pointercancel", endDrag);
  typeMenuWrap.addEventListener("pointerleave", endDrag);
  typeMenuWrap.addEventListener("dragstart", (event) => {
    event.preventDefault();
  });
  typeMenuWrap.addEventListener("scroll", updateTabScrollButtons);
  window.addEventListener("resize", updateTabScrollButtons);

  if (typeScrollPrev) {
    typeScrollPrev.addEventListener("click", () => {
      typeMenuWrap.scrollBy({ left: -220, behavior: "smooth" });
      window.setTimeout(updateTabScrollButtons, 220);
    });
  }

  if (typeScrollNext) {
    typeScrollNext.addEventListener("click", () => {
      typeMenuWrap.scrollBy({ left: 220, behavior: "smooth" });
      window.setTimeout(updateTabScrollButtons, 220);
    });
  }

  updateTabScrollButtons();
}

function setActiveType(type) {
  activeType = type;

  typeTabs.forEach((tab) => {
    tab.classList.toggle("active", tab.dataset.type === type);
  });

  contentPanels.forEach((panel) => {
    panel.classList.toggle("active", panel.dataset.type === type);
  });

  contentTypeLabel.textContent = `Type: ${typeLabels[type]}`;
  charCount.textContent = String(textInput.value.length);

  if (qrReady) {
    generateQRCode(true);
  }
}

function clearContentInputs() {
  contentPanels.forEach((panel) => {
    const fields = panel.querySelectorAll("input, textarea, select");
    fields.forEach((field) => {
      if (field.type === "checkbox") {
        field.checked = false;
      } else if (field.tagName === "SELECT") {
        field.selectedIndex = 0;
      } else {
        field.value = "";
      }
    });
  });

  // Keep sensible WiFi default after clear.
  document.getElementById("wifiSecurity").value = "WPA";
  charCount.textContent = "0";
}

qrForm.addEventListener("submit", (event) => {
  event.preventDefault();
  generateQRCode();
});

typeTabs.forEach((tab) => {
  tab.addEventListener("click", () => {
    if (suppressTabClick) {
      return;
    }

    setActiveType(tab.dataset.type);
  });
});

clearBtn.addEventListener("click", () => {
  clearContentInputs();
  clearQR();
  setStatus("Fields cleared.");
});

downloadBtn.addEventListener("click", () => {
  if (!qrReady || !latestCanvas) {
    setStatus("Generate a QR code before downloading.", true);
    return;
  }

  const payload = buildQrPayload();
  if (payload.error) {
    setStatus(payload.error, true);
    return;
  }

  const assessment = evaluateQRQuality(payload.value.length);

  if (assessment.issues.length > 0) {
    openDownloadModal(assessment.issues);
    return;
  }

  executeDownload();
});

modalCloseBtn.addEventListener("click", closeDownloadModal);
modalCancelBtn.addEventListener("click", closeDownloadModal);
modalConfirmBtn.addEventListener("click", () => {
  executeDownload();
  closeDownloadModal();
});

document.addEventListener("keydown", (event) => {
  if (event.key === "Escape" && !downloadModal.hidden) {
    closeDownloadModal();
  }
});

const contentFields = document.querySelectorAll(".content-panel input, .content-panel textarea, .content-panel select");
contentFields.forEach((field) => {
  const eventName = field.type === "checkbox" || field.tagName === "SELECT" ? "change" : "input";
  field.addEventListener(eventName, () => {
    charCount.textContent = String(textInput.value.length);

    if (qrReady) {
      generateQRCode(true);
    }
  });
});

qrSize.addEventListener("input", () => {
  const size = Number.parseInt(qrSize.value, 10);
  updateRangeVisual(qrSize, qrSizeValue, `${size} x ${size}`);

  if (qrReady) {
    generateQRCode(true);
  }
});

dotFill.addEventListener("input", () => {
  const fill = Number.parseInt(dotFill.value, 10);
  updateRangeVisual(dotFill, dotFillValue, `${fill}%`);

  if (qrReady) {
    generateQRCode(true);
  }
});

dotStyle.addEventListener("change", () => {
  if (qrReady) {
    generateQRCode(true);
  }
});

qrDetail.addEventListener("change", () => {
  if (qrReady) {
    generateQRCode(true);
  }
});

// Initialize
initDraggableTypeMenu();
setActiveType("url");
clearQR();
updateRangeVisual(
  qrSize,
  qrSizeValue,
  `${Number.parseInt(qrSize.value, 10)} x ${Number.parseInt(qrSize.value, 10)}`
);
updateRangeVisual(dotFill, dotFillValue, `${Number.parseInt(dotFill.value, 10)}%`);

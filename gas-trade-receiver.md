// ============================================
//  gas-trade-receiver — VoicelyAI 交易記錄接收
//  接收 app.py POST，逐格寫入「現有庫存明細」
//  跳過 G, K, L, M 公式欄位，避免蓋掉公式
// ============================================

function doPost(e) {
  try {
    var data = JSON.parse(e.postData.contents);
    var sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("現有庫存明細");

    if (!sheet) {
      throw new Error("找不到 '現有庫存明細' 工作表，請確認分頁名稱。");
    }

    var newRow = sheet.getLastRow() + 1;

    // 只寫入「資料欄位」，跳過公式欄位（G, K, L, M）
    sheet.getRange(newRow, 1).setValue(data.date);          // A: 扣入時間
    sheet.getRange(newRow, 2).setValue(data.market);        // B: 市場
    sheet.getRange(newRow, 3).setValue(data.symbol);        // C: 交易所代碼
    sheet.getRange(newRow, 4).setValue(data.name);          // D: 標的名稱
    sheet.getRange(newRow, 5).setValue(data.shares);        // E: 持有股數
    sheet.getRange(newRow, 6).setValue(data.price);         // F: 成交單價
    // G: 即時現價 — 跳過，保留公式自動沿用
    sheet.getRange(newRow, 8).setValue(data.currency);      // H: 幣別
    sheet.getRange(newRow, 9).setValue(data.exchange_rate); // I: 即時匯率
    sheet.getRange(newRow, 10).setValue(data.cost_twd);     // J: 投入成本(台幣)
    // K: 目前市值(台幣) — 跳過，保留公式自動沿用
    // L: 未實現損益(1) — 跳過，保留公式自動沿用
    // M: 未實現損益(2) — 跳過，保留公式自動沿用

    return ContentService.createTextOutput(JSON.stringify({ "status": "success" }))
      .setMimeType(ContentService.MimeType.JSON);

  } catch (error) {
    return ContentService.createTextOutput(JSON.stringify({
      "status": "error",
      "message": error.toString()
    })).setMimeType(ContentService.MimeType.JSON);
  }
}

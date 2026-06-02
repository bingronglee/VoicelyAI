// ============================================
//  gas-trade-receiver — VoicelyAI 交易記錄接收
//  接收 app.py POST，自動填入「現有庫存明細」
//  自動寫入公式，確保試算表功能完整
// ============================================

function doPost(e) {
  try {
    var data = JSON.parse(e.postData.contents);
    var ss = SpreadsheetApp.getActiveSpreadsheet();
    var sheet = ss.getSheetByName("現有庫存明細");

    if (!sheet) {
      throw new Error("找不到 '現有庫存明細' 工作表，請確認分頁名稱。");
    }

    var newRow = sheet.getLastRow() + 1;
    
    // 準備資料與公式
    var date = data.date || Utilities.formatDate(new Date(), "GMT+8", "yyyy/MM/dd");
    var market = data.market || "台股";
    var symbol = data.symbol; // 例如 TPE:2330 或 NASDAQ:NVDA
    var shares = data.shares;
    var price = data.price;
    var currency = data.currency || (market === "美股" ? "USD" : "TWD");
    
    // 定義公式 (使用 R1C1 格式或動態字串)
    var formulaName = "=IFERROR(GOOGLEFINANCE(C" + newRow + ", \"name\"), \"\")";
    var formulaLivePrice = "=IFERROR(GOOGLEFINANCE(C" + newRow + "), \"\")";
    var formulaExchangeRate = "=IF(H" + newRow + "=\"USD\", GOOGLEFINANCE(\"CURRENCY:USDTWD\"), 1)";
    var formulaCostTwd = "=E" + newRow + " * F" + newRow + " * I" + newRow;
    var formulaMarketValue = "=E" + newRow + " * G" + newRow + " * I" + newRow;
    var formulaPnL = "=K" + newRow + " - J" + newRow;

    // 逐格寫入 (對齊 A~L 欄位)
    // A: 扣入時間 | B: 市場 | C: 交易所代碼 | D: 標的名稱(公式) | E: 持有股數 | F: 成交單價
    // G: 即時現價(公式) | H: 幣別 | I: 即時匯率(公式) | J: 投入成本(公式) | K: 目前市值(公式) | L: 未實現損益(公式)
    
    var rowData = [
      [
        date,               // A
        market,             // B
        symbol,             // C
        formulaName,        // D
        shares,             // E
        price,              // F
        formulaLivePrice,   // G
        currency,           // H
        formulaExchangeRate,// I
        formulaCostTwd,     // J
        formulaMarketValue, // K
        formulaPnL          // L
      ]
    ];

    sheet.getRange(newRow, 1, 1, 12).setValues(rowData);

    return ContentService.createTextOutput(JSON.stringify({ 
      "status": "success", 
      "row": newRow,
      "symbol": symbol 
    })).setMimeType(ContentService.MimeType.JSON);

  } catch (error) {
    return ContentService.createTextOutput(JSON.stringify({
      "status": "error",
      "message": error.toString()
    })).setMimeType(ContentService.MimeType.JSON);
  }
}

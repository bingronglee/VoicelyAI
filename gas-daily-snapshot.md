// ============================================
//  gas-daily-snapshot — 每日資產快照追蹤
//  定時觸發，從「配置總覽與再平衡」讀取
//  寫入「每日歷史紀錄」做長期趨勢追蹤
// ============================================

function recordDailyPortfolio() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var dashboard = ss.getSheetByName("配置總覽與再平衡");
  var history = ss.getSheetByName("每日歷史紀錄");

  // 1. 讀取今日數據（B3: 總資產市值, B4: 累計投入本金）
  var totalValue = dashboard.getRange("B3").getValue();
  var totalCost = dashboard.getRange("B4").getValue();
  var today = new Date();

  // 2. 計算今日淨損益與 ROI
  var netPnL = totalValue - totalCost;
  var roi = totalCost > 0 ? (netPnL / totalCost) : 0;

  // 3. 獲取昨日市值以計算「每日變化率」
  var lastRow = history.getLastRow();
  var dailyChange = 0;

  if (lastRow >= 2) {
    var lastValue = history.getRange(lastRow, 2).getValue(); // 最後一行的總資產市值
    if (lastValue > 0) {
      dailyChange = (totalValue - lastValue) / lastValue;
    }
  }

  // 4. 使用 GMT+8 時區格式化日期
  var formattedDate = Utilities.formatDate(today, "GMT+8", "yyyy/MM/dd HH:mm:ss");

  // 5. 寫入每日歷史紀錄
  //    格式：日期 | 總資產市值 | 累計投入本金 | 淨損益 | ROI | 每日變化率
  history.appendRow([formattedDate, totalValue, totalCost, netPnL, roi, dailyChange]);

  // 6. 最後一欄設為百分比格式
  history.getRange(history.getLastRow(), 6).setNumberFormat("0.00%");
}

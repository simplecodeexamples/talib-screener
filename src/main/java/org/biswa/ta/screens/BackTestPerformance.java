package org.biswa.ta.screens;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

import org.biswa.ta.pojo.BackTestObject;
import org.biswa.ta.pojo.ResultObject;
import org.biswa.ta.pojo.TradeObject;

public class BackTestPerformance {

	private double perLotRisk;
	private double stoplossPercent;

	public double getPerLotRisk() {
		return perLotRisk;
	}

	public void setPerLotRisk(double perLotRisk) {
		this.perLotRisk = perLotRisk;
	}

	public double getStoplossPercent() {
		return stoplossPercent;
	}

	public void setStoplossPercent(double stoplossPercent) {
		this.stoplossPercent = stoplossPercent;
	}

	public ResultObject computePerformance(List<BackTestObject> backTestObjects) {
		ResultObject resultObject = new ResultObject();
		List<TradeObject> tradeObjects=new ArrayList<TradeObject>();
		int profitCount = 0;
		int lossCount = 0;
		double profitAmount = 0.0;
		double buyPrice = 0.0;
		double averageBuy = 0.0;
		int quantity = 0;
		TradeObject tradeObject = null;
		for (BackTestObject backTestObject : backTestObjects) {
			
			if (backTestObject.getEventType() == "Positive") {
				tradeObject=new TradeObject();
				buyPrice = backTestObject.getPrice();
				quantity = (int) (perLotRisk / ((double)(buyPrice * stoplossPercent) / 100));
				averageBuy += buyPrice * quantity;
				tradeObject.setBuyIndex(backTestObject.getIndex());
				tradeObject.setBuyPrice(buyPrice);
				tradeObject.setBuyQuantity(quantity);
			}
			if (backTestObject.getEventType() == "Negetive" && tradeObject!=null) {
				if (backTestObject.getPrice() > buyPrice) {
					profitCount++;
				} else {
					lossCount++;
				}
				tradeObject.setSellIndex(backTestObject.getIndex());
				tradeObject.setSellPrice(backTestObject.getPrice());
				tradeObject.setSellQuantity(quantity);
				profitAmount += (quantity*backTestObject.getPrice() - buyPrice*quantity);
				tradeObject.setProfit(quantity*backTestObject.getPrice() - buyPrice*quantity);
				tradeObject.setProfitPercent((((quantity*backTestObject.getPrice() - buyPrice*quantity)*100)/(buyPrice*quantity)));
				tradeObjects.add(tradeObject);
			}
		}
		averageBuy = (double) averageBuy / (profitCount + lossCount);
		resultObject.setTotalNumberOfTrades(profitCount + lossCount);
		resultObject.setTotalNumWin(profitCount);
		resultObject.setTotalNumLoss(lossCount);
		resultObject.setProfit(profitAmount);
		resultObject.setProfitPercent((double) profitAmount * 100 / averageBuy);
		resultObject.setLargestProfit(tradeObjects.stream().max(Comparator.comparing(TradeObject::getProfit)).get().getProfit());
		resultObject.setLargestLoss(tradeObjects.stream().min(Comparator.comparing(TradeObject::getProfit)).get().getProfit());
		resultObject.setTrades(tradeObjects);
		return resultObject;
	}
}

package org.biswa.ta.screens;

import java.util.List;

import org.biswa.ta.pojo.BackTestObject;
import org.biswa.ta.pojo.ResultObject;

public class BackTestPerformance {

	public ResultObject computePerformance(List<BackTestObject> backTestObjects) {
		ResultObject resultObject =new ResultObject();
		int profitCount=0;
		int lossCount =0;
		double profitAmount=0.0;
		double lossAmount=0.0;
		double buyPrice=0.0;
		double averageBuy=0.0;
		for (BackTestObject backTestObject : backTestObjects) {
			if (backTestObject.getEventType()=="Positive") {
				buyPrice=backTestObject.getPrice();
				averageBuy+=buyPrice;
			}
			if (backTestObject.getEventType()=="Negetive") {
				if(backTestObject.getPrice()>buyPrice) {
					profitCount++;
				}
				else {
					lossCount++;
				}
				profitAmount+=(backTestObject.getPrice()-buyPrice);
			}
		}
		averageBuy=(double)averageBuy/(profitCount+lossCount);
		resultObject.setTotalNumberOfTrades(profitCount+lossCount);
		resultObject.setTotalNumWin(profitCount);
		resultObject.setTotalNumLoss(lossCount);
		resultObject.setProfit(profitAmount);
		resultObject.setProfitPercent((double)profitAmount*100/averageBuy);
		return resultObject;
	}
}

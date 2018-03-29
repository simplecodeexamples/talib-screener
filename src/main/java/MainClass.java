import java.util.ArrayList;
import java.util.List;

import org.biswa.ta.pojo.BackTestObject;
import org.biswa.ta.pojo.ExpressionObject;
import org.biswa.ta.pojo.ExpressionObject.Expression;
import org.biswa.ta.pojo.IndicatorObject;
import org.biswa.ta.pojo.IndicatorObject.TECHNICAL_INDICATOR;
import org.biswa.ta.pojo.MacdObject;
import org.biswa.ta.pojo.ResultObject;
import org.biswa.ta.pojo.TradeObject;
import org.biswa.ta.screens.BackTestPerformance;
import org.biswa.ta.screens.ExecuteScreens;

public class MainClass {

	public static void main(String[] args) {
		List<ExpressionObject> entryLongExpressionObjects=new ArrayList<ExpressionObject>();
		List<ExpressionObject> exitLongExpressionObjects=new ArrayList<ExpressionObject>();
		
		/*IndicatorObject ema5=new IndicatorObject(TECHNICAL_INDICATOR.EMA,5,"CLOSE");
		IndicatorObject ema20=new IndicatorObject(TECHNICAL_INDICATOR.EMA,20,"CLOSE");
		ExpressionObject entryLongExpressionObject1=new ExpressionObject(ema5, ema20, Expression.GREATER_THEN);
		
		IndicatorObject rsi14=new IndicatorObject(TECHNICAL_INDICATOR.RSI,14,"CLOSE");
		ExpressionObject entryLongExpressionObject2=new ExpressionObject(rsi14, null, Expression.GREATER_THEN);
		entryLongExpressionObject2.setRightValue(35);
		
		entryLongExpressionObjects.add(entryLongExpressionObject1);
		entryLongExpressionObjects.add(entryLongExpressionObject2);*/
		
		IndicatorObject macdhist_1=new MacdObject(TECHNICAL_INDICATOR.MACD,12,26,9,"CLOSE");
		ExpressionObject entryLongExpressionObject2=new ExpressionObject(macdhist_1, null, Expression.GREATER_THEN);
		entryLongExpressionObject2.setRightValue(0);
		entryLongExpressionObjects.add(entryLongExpressionObject2);
		
		
		/*IndicatorObject ema5_2=new IndicatorObject(TECHNICAL_INDICATOR.EMA,5,"CLOSE");
		IndicatorObject ema20_2=new IndicatorObject(TECHNICAL_INDICATOR.EMA,20,"CLOSE");
		ExpressionObject exitLongExpressionObject1=new ExpressionObject(ema5_2, ema20_2, Expression.LESS_THEN);
		
		exitLongExpressionObjects.add(exitLongExpressionObject1);
		
		*/
		
		
		/*IndicatorObject rsi14_2=new IndicatorObject(TECHNICAL_INDICATOR.RSI,14,"CLOSE");
		ExpressionObject exitLongExpressionObject2=new ExpressionObject(rsi14_2, null, Expression.GREATER_THEN);
		exitLongExpressionObject2.setRightValue(70);
		exitLongExpressionObjects.add(exitLongExpressionObject2);
		*/
		
		/*IndicatorObject macdhist=new MacdObject(TECHNICAL_INDICATOR.MACD,12,26,9,"CLOSE");
		ExpressionObject exitLongExpressionObject2=new ExpressionObject(macdhist, null, Expression.LESS_THEN);
		exitLongExpressionObject2.setRightValue(0);
		exitLongExpressionObjects.add(exitLongExpressionObject2);*/
		
		IndicatorObject closeObj=new IndicatorObject(TECHNICAL_INDICATOR.CLOSE,1,"CLOSE");
		IndicatorObject ema5_2=new IndicatorObject(TECHNICAL_INDICATOR.EMA,5,"CLOSE");
		ExpressionObject exitLongExpressionObject2=new ExpressionObject(closeObj, ema5_2, Expression.LESS_THEN);
		exitLongExpressionObjects.add(exitLongExpressionObject2);
		
		
		//expressionObjects.add(expressionObject2);
		ExecuteScreens executeScreens = new ExecuteScreens(entryLongExpressionObjects,exitLongExpressionObjects,null,null);
		List<BackTestObject> backTestObjects = executeScreens.getBackTestResults();

		BackTestPerformance backTestPerformance = new BackTestPerformance();
		backTestPerformance.setPerLotRisk(75);
		backTestPerformance.setStoplossPercent(1);
		ResultObject resultObject = backTestPerformance.computePerformance(backTestObjects);
		System.out.println(
				"Buy Index\tBuy Price\tBuy Quantity\tSell Index\tSell Price\tSell Quantity\tProfit\tProfit Percent");
		for (TradeObject tradeObject : resultObject.getTrades()) {

			System.out.println(tradeObject.getBuyIndex() + "\t" + tradeObject.getBuyPrice() + "\t"
					+ tradeObject.getBuyQuantity() + "\t" + tradeObject.getSellIndex() + "\t"
					+ tradeObject.getSellPrice() + "\t" + tradeObject.getSellQuantity() + "\t" + tradeObject.getProfit()
					+ "\t" + tradeObject.getProfitPercent());
		}
		System.out.println("Total Number of Trades " + resultObject.getTotalNumberOfTrades());
		System.out.println("Total Number of Win " + resultObject.getTotalNumWin());
		System.out.println("Total Number of Loss " + resultObject.getTotalNumLoss());
		System.out.println("Profit " + resultObject.getProfit());
		System.out.println("Profit Percent " + resultObject.getProfitPercent());
		System.out.println("Largest Profit " + resultObject.getLargestProfit());
		System.out.println("Largest Loss " + resultObject.getLargestLoss());
	}
}

import java.util.ArrayList;
import java.util.List;

import org.biswa.ta.pojo.BackTestObject;
import org.biswa.ta.pojo.ResultObject;
import org.biswa.ta.screens.BackTestPerformance;
import org.biswa.ta.screens.ExecuteScreens;

public class MainClass {

	public static void main(String[] args) {
		ExecuteScreens executeScreens=new ExecuteScreens();
		List<BackTestObject> backTestObjects=executeScreens.findEmaCrossOver(5,20);
		for (BackTestObject emaCrossOverObject : backTestObjects) {
			System.out.println("Index\tType\tPrice");
			System.out.println(emaCrossOverObject.getIndex()+"\t"+emaCrossOverObject.getEventType()+"\t"+emaCrossOverObject.getPrice());
		}
		BackTestPerformance backTestPerformance=new BackTestPerformance();
		ResultObject resultObject= backTestPerformance.computePerformance(backTestObjects);
		System.out.println("Total Number of Trades "+resultObject.getTotalNumberOfTrades());
		System.out.println("Total Number of Win "+resultObject.getTotalNumWin());
		System.out.println("Total Number of Loss "+resultObject.getTotalNumLoss());
		System.out.println("Profit "+resultObject.getProfit());
		System.out.println("Profit Percent "+resultObject.getProfitPercent());
	}
}

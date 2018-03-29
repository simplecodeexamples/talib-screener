package org.biswa.ta.screens;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.biswa.ta.pojo.BackTestObject;
import org.biswa.ta.pojo.EmaObject;
import org.biswa.ta.pojo.ExpressionObject;
import org.biswa.ta.pojo.IndicatorObject;
import org.biswa.ta.pojo.MacdObject;
import org.biswa.ta.util.EnumHolders.Macd;

import com.tictactec.ta.lib.Core;
import com.tictactec.ta.lib.MAType;
import com.tictactec.ta.lib.MInteger;
import com.tictactec.ta.lib.RetCode;

public class ExecuteScreens {
	private double input[];
	private int inputInt[];
	private double output[];
	private int outputInt[];
	private MInteger outBegIdx;
	private MInteger outNbElement;
	private RetCode retCode;
	private Core lib;
	private int lookback;

	static public double[] close = new double[] { 91.500000, 94.815000, 94.375000, 95.095000, 93.780000, 94.625000,
			92.530000, 92.750000, 90.315000, 92.470000, 96.125000, 97.250000, 98.500000, 89.875000, 91.000000,
			92.815000, 89.155000, 89.345000, 91.625000, 89.875000, 88.375000, 87.625000, 84.780000, 83.000000,
			83.500000, 81.375000, 84.440000, 89.250000, 86.375000, 86.250000, 85.250000, 87.125000, 85.815000,
			88.970000, 88.470000, 86.875000, 86.815000, 84.875000, 84.190000, 83.875000, 83.375000, 85.500000,
			89.190000, 89.440000, 91.095000, 90.750000, 91.440000, 89.000000, 91.000000, 90.500000, 89.030000,
			88.815000, 84.280000, 83.500000, 82.690000, 84.750000, 85.655000, 86.190000, 88.940000, 89.280000,
			88.625000, 88.500000, 91.970000, 91.500000, 93.250000, 93.500000, 93.155000, 91.720000, 90.000000,
			89.690000, 88.875000, 85.190000, 83.375000, 84.875000, 85.940000, 97.250000, 99.875000, 104.940000,
			106.000000, 102.500000, 102.405000, 104.595000, 106.125000, 106.000000, 106.065000, 104.625000, 108.625000,
			109.315000, 110.500000, 112.750000, 123.000000, 119.625000, 118.750000, 119.250000, 117.940000, 116.440000,
			115.190000, 111.875000, 110.595000, 118.125000, 116.000000, 116.000000, 112.000000, 113.750000, 112.940000,
			116.000000, 120.500000, 116.620000, 117.000000, 115.250000, 114.310000, 115.500000, 115.870000, 120.690000,
			120.190000, 120.750000, 124.750000, 123.370000, 122.940000, 122.560000, 123.120000, 122.560000, 124.620000,
			129.250000, 131.000000, 132.250000, 131.000000, 132.810000, 134.000000, 137.380000, 137.810000, 137.880000,
			137.250000, 136.310000, 136.250000, 134.630000, 128.250000, 129.000000, 123.870000, 124.810000, 123.000000,
			126.250000, 128.380000, 125.370000, 125.690000, 122.250000, 119.370000, 118.500000, 123.190000, 123.500000,
			122.190000, 119.310000, 123.310000, 121.120000, 123.370000, 127.370000, 128.500000, 123.870000, 122.940000,
			121.750000, 124.440000, 122.000000, 122.370000, 122.940000, 124.000000, 123.190000, 124.560000, 127.250000,
			125.870000, 128.860000, 132.000000, 130.750000, 134.750000, 135.000000, 132.380000, 133.310000, 131.940000,
			130.000000, 125.370000, 130.130000, 127.120000, 125.190000, 122.000000, 125.000000, 123.000000, 123.500000,
			120.060000, 121.000000, 117.750000, 119.870000, 122.000000, 119.190000, 116.370000, 113.500000, 114.250000,
			110.000000, 105.060000, 107.000000, 107.870000, 107.000000, 107.120000, 107.000000, 91.000000, 93.940000,
			93.870000, 95.500000, 93.000000, 94.940000, 98.250000, 96.750000, 94.810000, 94.370000, 91.560000,
			90.250000, 93.940000, 93.620000, 97.000000, 95.000000, 95.870000, 94.060000, 94.620000, 93.750000,
			98.000000, 103.940000, 107.870000, 106.060000, 104.500000, 105.000000, 104.190000, 103.060000, 103.420000,
			105.270000, 111.870000, 116.000000, 116.620000, 118.280000, 113.370000, 109.000000, 109.700000, 109.250000,
			107.000000, 109.190000, 110.000000, 109.200000, 110.120000, 108.000000, 108.620000, 109.750000, 109.810000,
			109.000000, 108.750000, 107.870000 };

	private List<ExpressionObject> expressionObjects;

	private List<ExpressionObject> entryLongExpressionObjects;
	private List<ExpressionObject> exitLongExpressionObjects;

	private List<ExpressionObject> entryShortExpressionObjects;
	private List<ExpressionObject> exitShortExpressionObjects;

	public ExecuteScreens(List<ExpressionObject> expressionObjects) {
		this.expressionObjects = expressionObjects;
	}

	public ExecuteScreens(List<ExpressionObject> entryLongExpressionObjects,
			List<ExpressionObject> exitLongExpressionObjects, List<ExpressionObject> entryShortExpressionObjects,
			List<ExpressionObject> exitShortExpressionObjects) {
		this.entryLongExpressionObjects = entryLongExpressionObjects;
		this.exitLongExpressionObjects = exitLongExpressionObjects;
		this.entryShortExpressionObjects = entryShortExpressionObjects;
		this.exitShortExpressionObjects = exitShortExpressionObjects;
	}

	public List<ExpressionObject> getEntryLongExpressionObjects() {
		return entryLongExpressionObjects;
	}

	public void setEntryLongExpressionObjects(List<ExpressionObject> entryLongExpressionObjects) {
		this.entryLongExpressionObjects = entryLongExpressionObjects;
	}

	public List<ExpressionObject> getExitLongExpressionObjects() {
		return exitLongExpressionObjects;
	}

	public void setExitLongExpressionObjects(List<ExpressionObject> exitLongExpressionObjects) {
		this.exitLongExpressionObjects = exitLongExpressionObjects;
	}

	public List<ExpressionObject> getEntryShortExpressionObjects() {
		return entryShortExpressionObjects;
	}

	public void setEntryShortExpressionObjects(List<ExpressionObject> entryShortExpressionObjects) {
		this.entryShortExpressionObjects = entryShortExpressionObjects;
	}

	public List<ExpressionObject> getExitShortExpressionObjects() {
		return exitShortExpressionObjects;
	}

	public void setExitShortExpressionObjects(List<ExpressionObject> exitShortExpressionObjects) {
		this.exitShortExpressionObjects = exitShortExpressionObjects;
	}

	Boolean positive = null;

	public List<BackTestObject> getBackTestResults() {
		// generate backtest results
		List<BackTestObject> backTests = new ArrayList<BackTestObject>();
		// decide begin index based on the max period among all expressions
		int maxPeriod = entryLongExpressionObjects.get(0).getLeftExpression().getPeriod();

		/** Evaluate maxperiod and indicators for entrylong **/
		for (ExpressionObject expressionObject : entryLongExpressionObjects) {
			if (expressionObject.getLeftExpression() != null
					&& maxPeriod < expressionObject.getLeftExpression().getPeriod()) {
				maxPeriod = expressionObject.getLeftExpression().getPeriod();
			}
			if (expressionObject.getRightExpression() != null
					&& maxPeriod < expressionObject.getRightExpression().getPeriod()) {
				maxPeriod = expressionObject.getRightExpression().getPeriod();
			}
		}
		// compute indicator values
		for (ExpressionObject expressionObject : entryLongExpressionObjects) {
			if (expressionObject.getLeftExpression() != null) {
				expressionObject.setLeftIndicatorValues(computeIndicatorValues(expressionObject.getLeftExpression()));
			}
			if (expressionObject.getRightExpression() != null) {
				expressionObject.setRightIndicatorValues(computeIndicatorValues(expressionObject.getRightExpression()));
			}
		}
		/** end of Evaluate maxperiod and indicators for entrylong **/

		/** Evaluate maxperiod and indicators for exitlong **/
		for (ExpressionObject expressionObject : exitLongExpressionObjects) {
			if (expressionObject.getLeftExpression() != null
					&& maxPeriod < expressionObject.getLeftExpression().getPeriod()) {
				maxPeriod = expressionObject.getLeftExpression().getPeriod();
			}
			if (expressionObject.getRightExpression() != null
					&& maxPeriod < expressionObject.getRightExpression().getPeriod()) {
				maxPeriod = expressionObject.getRightExpression().getPeriod();
			}
		}
		// compute indicator values
		for (ExpressionObject expressionObject : exitLongExpressionObjects) {
			if (expressionObject.getLeftExpression() != null) {
				expressionObject.setLeftIndicatorValues(computeIndicatorValues(expressionObject.getLeftExpression()));
			}
			if (expressionObject.getRightExpression() != null) {
				expressionObject.setRightIndicatorValues(computeIndicatorValues(expressionObject.getRightExpression()));
			}
		}
		/** end of Evaluate maxperiod and indicators for exitlong **/

		for (int i = maxPeriod - 1; i < close.length - 2; i++) {
			BackTestObject backTestObject = new BackTestObject();
			if ((validateAllExpressions(exitLongExpressionObjects, i)) && (positive == null || positive)) {
				backTestObject.setIndex(i);
				backTestObject.setEventType("Negetive");
				backTestObject.setPrice(close[i]);
				backTests.add(backTestObject);
				positive = false;
			}
			if ((validateAllExpressions(entryLongExpressionObjects, i)) && (positive == null || !positive)) {
				backTestObject.setIndex(i);
				backTestObject.setEventType("Positive");
				backTestObject.setPrice(close[i]);
				backTests.add(backTestObject);
				positive = true;
			}

		}
		return backTests;
	}

	private boolean validateAllExpressions(List<ExpressionObject> expressionObjects, int index) {
		System.out.println("Index " + index);
		boolean meetAllExpressions = true;
		for (ExpressionObject expressionObject : expressionObjects) {
			switch (expressionObject.getExpression()) {
			case GREATER_THEN:
				if (expressionObject.getLeftExpression() != null && expressionObject.getRightExpression() != null) {
					meetAllExpressions = meetAllExpressions && (expressionObject.getLeftIndicatorValues().get(index)
							.getValue() > expressionObject.getRightIndicatorValues().get(index).getValue());
				}
				if (expressionObject.getLeftExpression() != null && expressionObject.getRightExpression() == null) {
					meetAllExpressions = meetAllExpressions && (expressionObject.getLeftIndicatorValues().get(index)
							.getValue() > expressionObject.getRightValue());
				}
				if (expressionObject.getLeftExpression() == null && expressionObject.getRightExpression() != null) {
					meetAllExpressions = meetAllExpressions && (expressionObject.getLeftValue() > expressionObject
							.getRightIndicatorValues().get(index).getValue());
				}

				break;
			case LESS_THEN:
				if (expressionObject.getLeftExpression() != null && expressionObject.getRightExpression() != null) {
					meetAllExpressions = meetAllExpressions && (expressionObject.getLeftIndicatorValues().get(index)
							.getValue() < expressionObject.getRightIndicatorValues().get(index).getValue());
				}
				if (expressionObject.getLeftExpression() != null && expressionObject.getRightExpression() == null) {
					meetAllExpressions = meetAllExpressions && (expressionObject.getLeftIndicatorValues().get(index)
							.getValue() < expressionObject.getRightValue());
				}
				if (expressionObject.getLeftExpression() == null && expressionObject.getRightExpression() != null) {
					meetAllExpressions = meetAllExpressions && (expressionObject.getLeftValue() < expressionObject
							.getRightIndicatorValues().get(index).getValue());
				}
				break;
			case EQUAL:
				if (expressionObject.getLeftExpression() != null && expressionObject.getRightExpression() != null) {
					meetAllExpressions = meetAllExpressions && (expressionObject.getLeftIndicatorValues().get(index)
							.getValue() == expressionObject.getRightIndicatorValues().get(index).getValue());
				}
				if (expressionObject.getLeftExpression() != null && expressionObject.getRightExpression() == null) {
					meetAllExpressions = meetAllExpressions && (expressionObject.getLeftIndicatorValues().get(index)
							.getValue() == expressionObject.getRightValue());
				}
				if (expressionObject.getLeftExpression() == null && expressionObject.getRightExpression() != null) {
					meetAllExpressions = meetAllExpressions && (expressionObject.getLeftValue() == expressionObject
							.getRightIndicatorValues().get(index).getValue());
				}
				break;
			default:
				break;
			}

		}
		return meetAllExpressions;
	}

	private List<BackTestObject> generateBacktests(int longPeriod, List<IndicatorObject> shortIndicators,
			List<IndicatorObject> longIndicators) {
		List<BackTestObject> backTests = new ArrayList<BackTestObject>();
		Boolean positive = null;
		for (int i = longPeriod - 1; i < longIndicators.size(); i++) {
			BackTestObject backTestObject = new BackTestObject();
			if ((longIndicators.get(i).getValue() > shortIndicators.get(i).getValue())
					&& (positive == null || positive)) {
				backTestObject.setIndex(i);
				backTestObject.setEventType("Negetive");
				backTestObject.setPrice(close[i]);
				backTests.add(backTestObject);
				positive = false;
			}
			if ((longIndicators.get(i).getValue() < shortIndicators.get(i).getValue())
					&& (positive == null || !positive)) {
				backTestObject.setIndex(i);
				backTestObject.setEventType("Positive");
				backTestObject.setPrice(close[i]);
				backTests.add(backTestObject);
				positive = true;
			}
		}
		return backTests;
	}

	private List<IndicatorObject> computeIndicatorValues(IndicatorObject indicatorObject) {

		switch (indicatorObject.getName()) {
		case EMA:
			return computeEma(indicatorObject.getPeriod(), MAType.Ema, close);
		case RSI:
			return computeRsi(indicatorObject.getPeriod(), close);
		case MACD:
			MacdObject macdObject = null;
			if (indicatorObject instanceof MacdObject) {
				macdObject = (MacdObject) indicatorObject;
			}
			return computeMacd(macdObject.getShortPeriod(), macdObject.getLongPeriod(), macdObject.getSignalPeriod(),
					close, Macd.MACD_HISTOGRAM);
		case CLOSE:
			return computeClose();
		default:
			break;
		}

		return null;

	}

	private List<IndicatorObject> computeClose() {
		List<IndicatorObject> dataObjs = new ArrayList<IndicatorObject>();
		for (int i = 0; i < close.length; i++) {
			IndicatorObject dataObject = new IndicatorObject();
			dataObject.setPeriod(1);
			dataObject.setValue(close[i]);
			dataObject.setIndex(i);
			dataObjs.add(dataObject);
		}
		return dataObjs;
	}

	private List<IndicatorObject> computeRsi(int period, double[] data) {
		setUp(data.length);
		retCode = lib.rsi(0, data.length - 1, data, period, outBegIdx, outNbElement, output);
		System.out.println("RSI " + period);
		return reArrangeData(output, period, outBegIdx);
	}

	public List<IndicatorObject> computeEma(int emaperiod, MAType matype, double[] data) {
		setUp(data.length);
		retCode = lib.movingAverage(0, data.length - 1, data, emaperiod, matype, outBegIdx, outNbElement, output);
		System.out.println("EMA " + emaperiod);
		return reArrangeData(output, emaperiod, outBegIdx);
	}

	public List<IndicatorObject> computeMacd(int shortPeriod, int longPeriod, int signalPeriod, double[] data,
			Macd macdOutput) {
		setUp(data.length);
		double macd[] = new double[close.length];
		double signal[] = new double[close.length];
		double hist[] = new double[close.length];
		retCode = lib.macd(0, close.length - 1, close, shortPeriod, longPeriod, signalPeriod, outBegIdx, outNbElement,
				macd, signal, hist);
		switch (macdOutput) {
		case MACD:
			System.out.println("MACD " + shortPeriod + " " + longPeriod + " " + signalPeriod);
			return reArrangeData(macd, longPeriod + signalPeriod, outBegIdx);
		case MACD_SIGNAL:
			System.out.println("MACD Signal " + shortPeriod + " " + longPeriod + " " + signalPeriod);
			return reArrangeData(signal, longPeriod + signalPeriod, outBegIdx);
		case MACD_HISTOGRAM:
			System.out.println("MACD Histogram " + shortPeriod + " " + longPeriod + " " + signalPeriod);
			return reArrangeData(hist, longPeriod + signalPeriod, outBegIdx);
		default:
			return null;
		}
	}

	private List<IndicatorObject> reArrangeData(double[] data, int period, MInteger beginIndex) {
		List<IndicatorObject> dataObjs = new ArrayList<IndicatorObject>();
		for (int i = beginIndex.value + data.length - 1; i > beginIndex.value; i--) {
			IndicatorObject dataObject = new IndicatorObject();
			dataObject.setPeriod(period);
			dataObject.setValue(data[i - beginIndex.value]);
			dataObject.setIndex((beginIndex.value + data.length - 1) - i);
			System.out.println(dataObject.getIndex() + "\t" + dataObject.getValue());
			dataObjs.add(dataObject);
		}
		return dataObjs;
	}

	public List<EmaObject> getEma(int emaperiod, MAType matype, double[] data) {
		List<EmaObject> emaObjs = new ArrayList<EmaObject>();
		setUp(data.length);
		lookback = lib.movingAverageLookback(emaperiod, matype);
		retCode = lib.movingAverage(0, data.length - 1, data, emaperiod, matype, outBegIdx, outNbElement, output);
		for (int i = outBegIdx.value + data.length - 1; i > outBegIdx.value; i--) {
			EmaObject emaObject = new EmaObject();
			emaObject.setPeriod(emaperiod);
			emaObject.setValue(output[i - outBegIdx.value]);
			emaObject.setIndex((outBegIdx.value + data.length - 1) - i);
			emaObjs.add(emaObject);
		}
		return emaObjs;
	}

	public void test_MACD() {
		double macd[] = new double[close.length];
		double signal[] = new double[close.length];
		double hist[] = new double[close.length];
		lookback = lib.macdLookback(15, 26, 9);
		retCode = lib.macd(0, close.length - 1, close, 15, 26, 9, outBegIdx, outNbElement, macd, signal, hist);

		double ema15[] = new double[close.length];
		lookback = lib.emaLookback(15);
		retCode = lib.ema(0, close.length - 1, close, 15, outBegIdx, outNbElement, ema15);

		double ema26[] = new double[close.length];
		lookback = lib.emaLookback(26);
		retCode = lib.ema(0, close.length - 1, close, 26, outBegIdx, outNbElement, ema26);

		// TODO Add tests of outputs
	}

	public void setUp(int length) {
		lib = new Core();
		inputInt = new int[length];
		output = new double[length];
		outputInt = new int[length];
		outBegIdx = new MInteger();
		outNbElement = new MInteger();
	}

}

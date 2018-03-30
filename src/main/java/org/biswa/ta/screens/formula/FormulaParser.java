package org.biswa.ta.screens.formula;

import java.util.ArrayList;
import java.util.List;

import org.biswa.ta.pojo.BacktestExpressionsObject;
import org.biswa.ta.pojo.ExpressionObject;
import org.biswa.ta.pojo.FormulaObject;
import org.biswa.ta.pojo.IndicatorObject;
import org.biswa.ta.pojo.IndicatorObject.TECHNICAL_INDICATOR;
import org.biswa.ta.pojo.MacdObject;
import org.biswa.ta.util.EnumHolders.Expression;

public class FormulaParser {

	public FormulaParser() {

	}

	public BacktestExpressionsObject generateBackTestExpressions(FormulaObject formulaObject) {
		BacktestExpressionsObject backtestExpressionsObject = new BacktestExpressionsObject();
		if (formulaObject.getEntryLongFormula() != null && formulaObject.getExitLongFormula() != null) {
			backtestExpressionsObject
					.setEntryLongExpressionObject(convertFormulaToExpression(formulaObject.getEntryLongFormula()));
			backtestExpressionsObject
					.setExitLongExpressionObject(convertFormulaToExpression(formulaObject.getExitLongFormula()));
		}
		if (formulaObject.getEntryShortFormula() != null && formulaObject.getExitShortFormula() != null) {
			backtestExpressionsObject
					.setEntryShortExpressionObject(convertFormulaToExpression(formulaObject.getEntryShortFormula()));
			backtestExpressionsObject
					.setExitShortExpressionObject(convertFormulaToExpression(formulaObject.getExitShortFormula()));
		}

		return backtestExpressionsObject;
	}

	private List<ExpressionObject> convertFormulaToExpression(String formula) {
		List<ExpressionObject> expressionObjects = new ArrayList<ExpressionObject>();
		String[] expressions = formula.split("(\\WAND\\W)|(\\WOR\\W)");
		for (String expression : expressions) {
			ExpressionObject expressionObject = new ExpressionObject();
			String[] expressionParts = expression.split("\\s+");
			String leftExpressionStr = expressionParts[0];
			String rightExpressionStr = expressionParts[2];
			String literal = expressionParts[1];
			IndicatorObject leftIndicator = null;
			IndicatorObject rightIndicator = null;
			if (leftExpressionStr.matches("^\\d*\\.?\\d+$")) {
				expressionObject.setLeftValue(Double.valueOf(leftExpressionStr));
			} else {
				leftIndicator = convertToIndicator(leftExpressionStr);
				expressionObject.setLeftExpression(leftIndicator);
			}
			if (rightExpressionStr.matches("^\\d*\\.?\\d+$")) {
				expressionObject.setRightValue(Double.valueOf(rightExpressionStr));
			} else {
				rightIndicator = convertToIndicator(rightExpressionStr);
				expressionObject.setRightExpression(rightIndicator);
			}
			Expression literalEnum = null;
			switch (literal) {
			case ">":
				literalEnum = Expression.GREATER_THEN;
				break;
			case "<":
				literalEnum = Expression.LESS_THEN;
				break;
			case "=":
				literalEnum = Expression.EQUAL;
				break;
			default:
				break;
			}
			expressionObject.setExpression(literalEnum);
			expressionObjects.add(expressionObject);
		}
		return expressionObjects;
	}

	private IndicatorObject convertToIndicator(String indicatorStr) {
		String[] indicatorAttr = indicatorStr.split("(\\(|\\))");
		String indicatorName = indicatorAttr[0];
		String[] indicatorParams = indicatorAttr[1].split(",");
		switch (indicatorName) {
		case "EMA":
			return buildEmaIndicator(indicatorParams);
		case "RSI":
			return buildRsiIndicator(indicatorParams);
		case "MACD":
			return buildMacdIndicator(indicatorParams, "MACD");
		case "MACD_SIGNAL":
			return buildMacdIndicator(indicatorParams, "MACD_SIGNAL");
		case "MACD_HISTOGRAM":
			return buildMacdIndicator(indicatorParams, "MACD_HISTOGRAM");
		default:
			break;
		}
		return null;
	}

	private IndicatorObject buildMacdIndicator(String[] indicatorParams, String macdType) {
		TECHNICAL_INDICATOR ti = null;
		switch (macdType) {
		case "MACD":
			ti = TECHNICAL_INDICATOR.MACD;
			break;
		case "MACD_SIGNAL":
			ti = TECHNICAL_INDICATOR.MACD_SIGNAL;
			break;
		case "MACD_HISTOGRAM":
			ti = TECHNICAL_INDICATOR.MACD_HISTOGRAM;
			break;
		default:
			break;
		}
		IndicatorObject indicatorObject = new MacdObject(ti, Integer.valueOf(indicatorParams[0]),
				Integer.valueOf(indicatorParams[1]), Integer.valueOf(indicatorParams[2]), "CLOSE");
		return indicatorObject;
	}

	private IndicatorObject buildEmaIndicator(String[] indicatorParams) {
		IndicatorObject indicatorObject = new IndicatorObject(TECHNICAL_INDICATOR.EMA,
				Integer.valueOf(indicatorParams[0]), "CLOSE");
		return indicatorObject;
	}

	private IndicatorObject buildRsiIndicator(String[] indicatorParams) {
		IndicatorObject indicatorObject = new IndicatorObject(TECHNICAL_INDICATOR.RSI,
				Integer.valueOf(indicatorParams[0]), "CLOSE");
		return indicatorObject;
	}

}

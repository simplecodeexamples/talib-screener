package org.biswa.ta.util;

public class EnumHolders {
	public enum Macd {
		MACD, MACD_SIGNAL, MACD_HISTOGRAM
	}

	enum GATES {
		AND, OR
	}

	public enum Expression {
		GREATER_THEN(">"), LESS_THEN("<"), EQUAL("=");
		private String expressionVal;

		Expression(String expressionVal) {
			this.expressionVal = expressionVal;
		}

		public String getExpressionVal() {
			return expressionVal;
		}

	}

}

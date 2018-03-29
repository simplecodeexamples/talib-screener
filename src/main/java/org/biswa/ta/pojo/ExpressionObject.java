package org.biswa.ta.pojo;

import java.util.List;

public class ExpressionObject {

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

	private IndicatorObject leftExpression;
	private IndicatorObject rightExpression;
	
	private double leftValue;
	private double rightValue;
	
	private List<IndicatorObject> leftIndicatorValues;
	private List<IndicatorObject> rightIndicatorValues;
	
	
	private Expression expression;
	

	
	public ExpressionObject(IndicatorObject leftExpression, IndicatorObject rightExpression, Expression expression) {
		this.leftExpression = leftExpression;
		this.rightExpression = rightExpression;
		this.expression = expression;
	}
	
	

	public double getLeftValue() {
		return leftValue;
	}


	public void setLeftValue(double leftValue) {
		this.leftValue = leftValue;
	}




	public double getRightValue() {
		return rightValue;
	}




	public void setRightValue(double rightValue) {
		this.rightValue = rightValue;
	}




	public List<IndicatorObject> getLeftIndicatorValues() {
		return leftIndicatorValues;
	}



	public void setLeftIndicatorValues(List<IndicatorObject> leftIndicatorValues) {
		this.leftIndicatorValues = leftIndicatorValues;
	}



	public List<IndicatorObject> getRightIndicatorValues() {
		return rightIndicatorValues;
	}



	public void setRightIndicatorValues(List<IndicatorObject> rightIndicatorValues) {
		this.rightIndicatorValues = rightIndicatorValues;
	}



	public IndicatorObject getLeftExpression() {
		return leftExpression;
	}

	public void setLeftExpression(IndicatorObject leftExpression) {
		this.leftExpression = leftExpression;
	}

	public IndicatorObject getRightExpression() {
		return rightExpression;
	}

	public void setRightExpression(IndicatorObject rightExpression) {
		this.rightExpression = rightExpression;
	}

	public Expression getExpression() {
		return expression;
	}

	public void setExpression(Expression expression) {
		this.expression = expression;
	}

}
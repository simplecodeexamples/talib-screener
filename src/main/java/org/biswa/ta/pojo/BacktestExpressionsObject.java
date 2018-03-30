package org.biswa.ta.pojo;

import java.util.List;

public class BacktestExpressionsObject {

	List<ExpressionObject> entryLongExpressionObject;
	List<ExpressionObject> exitLongExpressionObject;
	List<ExpressionObject> entryShortExpressionObject;
	List<ExpressionObject> exitShortExpressionObject;
	
	
	public List<ExpressionObject> getEntryLongExpressionObject() {
		return entryLongExpressionObject;
	}


	public void setEntryLongExpressionObject(List<ExpressionObject> entryLongExpressionObject) {
		this.entryLongExpressionObject = entryLongExpressionObject;
	}


	public List<ExpressionObject> getExitLongExpressionObject() {
		return exitLongExpressionObject;
	}


	public void setExitLongExpressionObject(List<ExpressionObject> exitLongExpressionObject) {
		this.exitLongExpressionObject = exitLongExpressionObject;
	}


	public List<ExpressionObject> getEntryShortExpressionObject() {
		return entryShortExpressionObject;
	}


	public void setEntryShortExpressionObject(List<ExpressionObject> entryShortExpressionObject) {
		this.entryShortExpressionObject = entryShortExpressionObject;
	}


	public List<ExpressionObject> getExitShortExpressionObject() {
		return exitShortExpressionObject;
	}


	public void setExitShortExpressionObject(List<ExpressionObject> exitShortExpressionObject) {
		this.exitShortExpressionObject = exitShortExpressionObject;
	}


	public BacktestExpressionsObject() {
		
	}

}

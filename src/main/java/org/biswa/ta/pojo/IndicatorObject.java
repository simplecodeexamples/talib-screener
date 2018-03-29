package org.biswa.ta.pojo;

import java.util.Date;

public class IndicatorObject {
	
	public enum TECHNICAL_INDICATOR{
		CLOSE,OPEN,HIGH,LOW,EMA,SMA,RSI,MACD,MACD_SIGNAL,CCI;
	}
	
	private TECHNICAL_INDICATOR name;
	private int period;
	private String vector;
	private Date createDate;
	private  double value;
	private String type;
	private int index;
	
	
	

	

	public IndicatorObject() {
		super();
	}

	public IndicatorObject(TECHNICAL_INDICATOR name, int period, String vector) {
		this.name = name;
		this.period = period;
		this.vector = vector;
	}
	
	

	public Date getCreateDate() {
		return createDate;
	}



	public void setCreateDate(Date createDate) {
		this.createDate = createDate;
	}



	public double getValue() {
		return value;
	}



	public void setValue(double value) {
		this.value = value;
	}



	public String getType() {
		return type;
	}



	public void setType(String type) {
		this.type = type;
	}



	public int getIndex() {
		return index;
	}



	public void setIndex(int index) {
		this.index = index;
	}



	public TECHNICAL_INDICATOR getName() {
		return name;
	}

	public void setName(TECHNICAL_INDICATOR name) {
		this.name = name;
	}

	public int getPeriod() {
		return period;
	}

	public void setPeriod(int period) {
		this.period = period;
	}

	public String getVector() {
		return vector;
	}

	public void setVector(String vector) {
		this.vector = vector;
	}

}

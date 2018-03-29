package org.biswa.ta.pojo;

import java.util.Date;

public class EmaObject extends IndicatorObject {
	
	
	private Date createDate;
	private  double value;
	private String type;
	private int index;
	
	public EmaObject(TECHNICAL_INDICATOR ema, int period2, String vector2) {
		super(ema, period2, vector2);
	}
	
	public EmaObject() {
		// TODO Auto-generated constructor stub
	}

	public int getIndex() {
		return index;
	}
	public void setIndex(int index) {
		this.index = index;
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
	
	

}

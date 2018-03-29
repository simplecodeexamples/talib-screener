package org.biswa.ta.pojo;

public class MacdObject extends IndicatorObject {
	
	private int shortPeriod;
	private int longPeriod;
	private int signalPeriod;

	public MacdObject() {
		// TODO Auto-generated constructor stub
	}

	public MacdObject(TECHNICAL_INDICATOR name, int period, String vector) {
		super(name, period, vector);
		// TODO Auto-generated constructor stub
	}
	
	public MacdObject(TECHNICAL_INDICATOR name, int shortPeriod, int longPeriod, int signalPeriod,String vector) {
		super(name, shortPeriod, vector);
		this.shortPeriod = shortPeriod;
		this.longPeriod = longPeriod;
		this.signalPeriod = signalPeriod;
	}

	public int getShortPeriod() {
		return shortPeriod;
	}

	public void setShortPeriod(int shortPeriod) {
		this.shortPeriod = shortPeriod;
	}

	public int getLongPeriod() {
		return longPeriod;
	}

	public void setLongPeriod(int longPeriod) {
		this.longPeriod = longPeriod;
	}

	public int getSignalPeriod() {
		return signalPeriod;
	}

	public void setSignalPeriod(int signalPeriod) {
		this.signalPeriod = signalPeriod;
	}
	
	

}

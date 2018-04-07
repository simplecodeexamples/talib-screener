package org.biswa.ta.pojo;

import java.util.Date;

public class TradeObject {
	
	private Date executionDate;
	private int buyIndex;
	private double buyPrice;
	private int buyQuantity;
	private int sellIndex;
	private double sellPrice;
	private int sellQuantity;
	private double profit;
	private double profitPercent;
	
	
	public Date getExecutionDate() {
		return executionDate;
	}
	public void setExecutionDate(Date executionDate) {
		this.executionDate = executionDate;
	}
	public int getBuyIndex() {
		return buyIndex;
	}
	public void setBuyIndex(int buyIndex) {
		this.buyIndex = buyIndex;
	}
	public double getBuyPrice() {
		return buyPrice;
	}
	public void setBuyPrice(double buyPrice) {
		this.buyPrice = buyPrice;
	}
	public int getBuyQuantity() {
		return buyQuantity;
	}
	public void setBuyQuantity(int buyQuantity) {
		this.buyQuantity = buyQuantity;
	}
	public int getSellIndex() {
		return sellIndex;
	}
	public void setSellIndex(int sellIndex) {
		this.sellIndex = sellIndex;
	}
	public double getSellPrice() {
		return sellPrice;
	}
	public void setSellPrice(double sellPrice) {
		this.sellPrice = sellPrice;
	}
	public int getSellQuantity() {
		return sellQuantity;
	}
	public void setSellQuantity(int sellQuantity) {
		this.sellQuantity = sellQuantity;
	}
	public double getProfit() {
		return profit;
	}
	public void setProfit(double profit) {
		this.profit = profit;
	}
	public double getProfitPercent() {
		return profitPercent;
	}
	public void setProfitPercent(double profitPercent) {
		this.profitPercent = profitPercent;
	}
	
	

}

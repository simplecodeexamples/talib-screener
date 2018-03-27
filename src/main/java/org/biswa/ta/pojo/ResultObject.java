package org.biswa.ta.pojo;

public class ResultObject {

	private double buyPrice;
	private double sellPrice;
	private int totalNumberOfTrades;
	private double profitPercent;
	private double profit;
	private double totalWin;
	private double totalLoss;
	private int totalNumWin;
	private int totalNumLoss;
	
	public double getProfit() {
		return profit;
	}
	public void setProfit(double profit) {
		this.profit = profit;
	}
	public double getBuyPrice() {
		return buyPrice;
	}
	public void setBuyPrice(double buyPrice) {
		this.buyPrice = buyPrice;
	}
	public double getSellPrice() {
		return sellPrice;
	}
	public void setSellPrice(double sellPrice) {
		this.sellPrice = sellPrice;
	}
	public int getTotalNumberOfTrades() {
		return totalNumberOfTrades;
	}
	public void setTotalNumberOfTrades(int totalNumberOfTrades) {
		this.totalNumberOfTrades = totalNumberOfTrades;
	}
	public double getProfitPercent() {
		return profitPercent;
	}
	public void setProfitPercent(double profitPercent) {
		this.profitPercent = profitPercent;
	}
	public double getTotalWin() {
		return totalWin;
	}
	public void setTotalWin(double totalWin) {
		this.totalWin = totalWin;
	}
	public double getTotalLoss() {
		return totalLoss;
	}
	public void setTotalLoss(double totalLoss) {
		this.totalLoss = totalLoss;
	}
	public int getTotalNumWin() {
		return totalNumWin;
	}
	public void setTotalNumWin(int totalNumWin) {
		this.totalNumWin = totalNumWin;
	}
	public int getTotalNumLoss() {
		return totalNumLoss;
	}
	public void setTotalNumLoss(int totalNumLoss) {
		this.totalNumLoss = totalNumLoss;
	}
	
	
	
}

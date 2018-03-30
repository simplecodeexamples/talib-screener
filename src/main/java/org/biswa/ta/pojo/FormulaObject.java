package org.biswa.ta.pojo;

public class FormulaObject {

	private String entryLongFormula;
	private String exitLongFormula;
	private String entryShortFormula;
	private String exitShortFormula;

	public String getEntryLongFormula() {
		return entryLongFormula;
	}

	public void setEntryLongFormula(String entryLongFormula) {
		this.entryLongFormula = entryLongFormula;
	}

	public String getExitLongFormula() {
		return exitLongFormula;
	}

	public void setExitLongFormula(String exitLongFormula) {
		this.exitLongFormula = exitLongFormula;
	}

	public String getEntryShortFormula() {
		return entryShortFormula;
	}

	public void setEntryShortFormula(String entryShortFormula) {
		this.entryShortFormula = entryShortFormula;
	}

	public String getExitShortFormula() {
		return exitShortFormula;
	}

	public void setExitShortFormula(String exitShortFormula) {
		this.exitShortFormula = exitShortFormula;
	}

	public FormulaObject(String entryLongFormula, String exitLongFormula, String entryShortFormula,
			String exitShortFormula) {
		super();
		this.entryLongFormula = entryLongFormula;
		this.exitLongFormula = exitLongFormula;
		this.entryShortFormula = entryShortFormula;
		this.exitShortFormula = exitShortFormula;
	}

	public FormulaObject() {

	}

}

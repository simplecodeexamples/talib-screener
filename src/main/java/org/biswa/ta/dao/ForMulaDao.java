package org.biswa.ta.dao;

import java.sql.SQLException;

import org.biswa.ta.pojo.FormulaObject;

public interface ForMulaDao {

	void saveOrUpdate(FormulaObject formulaObject, boolean isUpdate) throws SQLException;
	

}

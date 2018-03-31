package org.biswa.ta.dao;

import java.sql.SQLException;

import org.biswa.ta.pojo.BackTestObject;
import org.biswa.ta.pojo.ResultObject;

public interface BacktestDao {


	void saveBackTestResult(ResultObject resultObject, int formulaId) throws SQLException;


}

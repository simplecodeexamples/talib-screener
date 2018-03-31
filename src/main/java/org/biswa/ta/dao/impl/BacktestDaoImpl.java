package org.biswa.ta.dao.impl;

import java.sql.SQLException;
import java.util.Date;

import javax.sql.DataSource;

import org.biswa.ta.dao.BacktestDao;
import org.biswa.ta.pojo.ResultObject;
import org.springframework.jdbc.core.JdbcTemplate;

public class BacktestDaoImpl implements BacktestDao {

	private JdbcTemplate jdbcTemplate;

	public BacktestDaoImpl(DataSource dataSource) {
		jdbcTemplate = new JdbcTemplate(dataSource);
	}

	@Override
	public void saveBackTestResult(ResultObject resultObject, int formulaId) throws SQLException {
		// insert
		String sql = "INSERT INTO backtest (`formulaid`, `totaltrades`, `win_count`, `loss_count`, `profit`, `profit_percent`, `largest_profit`, `largest_loss`, `createdate`)"
				+ " VALUES (?, ?, ?, ?,?, ?, ?, ?,?)";
		jdbcTemplate.update(sql, formulaId, resultObject.getTotalNumberOfTrades(), resultObject.getTotalNumWin(),
				resultObject.getTotalNumLoss(), resultObject.getProfit(), resultObject.getProfitPercent(),
				resultObject.getLargestProfit(), resultObject.getLargestLoss(), new Date());

	}

}

package org.biswa.ta.dao.impl;

import java.sql.SQLException;

import javax.sql.DataSource;

import org.biswa.ta.dao.ForMulaDao;
import org.biswa.ta.pojo.FormulaObject;
import org.springframework.jdbc.core.JdbcTemplate;

public class FormulaDaoImpl implements ForMulaDao {

	private JdbcTemplate jdbcTemplate;

	public FormulaDaoImpl(DataSource dataSource) {
		jdbcTemplate = new JdbcTemplate(dataSource);
	}

	@Override
	public void saveOrUpdate(FormulaObject formulaObject, boolean isUpdate) throws SQLException {
		if (isUpdate) {
			// update
			String sql = "UPDATE formula SET entrylong=?, entryshort=?, entryshort=?, "
					+ "exitshort=? WHERE formulaid=?";
			jdbcTemplate.update(sql, formulaObject.getEntryLongFormula(), formulaObject.getExitLongFormula(),
					formulaObject.getEntryShortFormula(), formulaObject.getExitShortFormula(),
					formulaObject.getFormulaId());
		} else {
			// insert
			String sql = "INSERT INTO formula (entrylong, exitlong, entryshort, exitshort)" + " VALUES (?, ?, ?, ?)";
			jdbcTemplate.update(sql, formulaObject.getEntryLongFormula(), formulaObject.getExitLongFormula(),
					formulaObject.getEntryShortFormula(), formulaObject.getExitShortFormula());
		}

	}

}



--
-- Dumping routines for database 'stockdb'
--
/*!50003 DROP PROCEDURE IF EXISTS `PORCEDURE_PORTFOLIODETAILS` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `PORCEDURE_PORTFOLIODETAILS`(
IN P_PORTFOLIOID INT,
OUT P_STOCKCOUNT INT,
OUT P_PROFIT decimal(16,2),
OUT P_NUMBEROFGAIN INT,
OUT P_NUMBEROFLOSS INT,
OUT P_NUMBEROFUNSETTLED INT,
OUT errorCode INT
)
BEGIN

DECLARE V_STOCKCOUNT INT DEFAULT 0;
DECLARE V_STOCKID INT DEFAULT 0;
DECLARE V_SETTLEDCOUNT,V_UNSETTLEDCOUNT INT DEFAULT 0;
DECLARE V_TOTSETTLEDCOUNT,V_TOTUNSETTLEDCOUNT INT DEFAULT 0;
DECLARE V_BUYCOUNT,V_SELLCOUNT INT DEFAULT 0;
DECLARE V_AVGBUY,V_AVGSELL DECIMAL(16,2) DEFAULT 0;
DECLARE V_NUMGAIN,V_NUMLOSS INT DEFAULT 0;
DECLARE V_PROFIT,V_LOSS DECIMAL(16,2) DEFAULT 0;
DECLARE V_TOTPROFIT,V_TOTLOSS DECIMAL(16,2) DEFAULT 0;
DECLARE done INT DEFAULT FALSE;


DECLARE EXIT HANDLER FOR SQLEXCEPTION SET errorCode = 1;
 BEGIN

 DECLARE cur1 CURSOR FOR SELECT distinct t.stockid from portfoliotranmapping pt inner join transaction t on pt.transactionid=t.transactionid where pt.portfolioid=P_PORTFOLIOID;

 DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

SELECT 
    COUNT(DISTINCT t.stockid)
INTO V_STOCKCOUNT FROM
    portfoliotranmapping pt
        INNER JOIN
    transaction t ON pt.transactionid = t.transactionid
WHERE
    pt.portfolioid = P_PORTFOLIOID;
 
  OPEN cur1;
    read_loop: LOOP
      FETCH cur1 INTO V_STOCKID;
        IF done THEN
          LEAVE read_loop;
        END IF;
        
		SELECT 
    SUM(t.quantity), SUM(t.price * t.quantity) / SUM(t.quantity)
INTO V_BUYCOUNT , V_AVGBUY FROM
    portfoliotranmapping pt
        INNER JOIN
    transaction t ON pt.transactionid = t.transactionid
WHERE
    pt.portfolioid = P_PORTFOLIOID
        AND t.stockid = V_STOCKID
        AND t.transactiontypeid = 1;
SELECT 
    SUM(t.quantity), SUM(t.price * t.quantity) / SUM(t.quantity)
INTO V_SELLCOUNT , V_AVGSELL FROM
    portfoliotranmapping pt
        INNER JOIN
    transaction t ON pt.transactionid = t.transactionid
WHERE
    pt.portfolioid = P_PORTFOLIOID
        AND t.stockid = V_STOCKID
        AND t.transactiontypeid = 2;
		
        set V_BUYCOUNT = coalesce(V_BUYCOUNT,0);
		set V_SELLCOUNT = coalesce(V_SELLCOUNT,0);
		set V_AVGBUY = coalesce(V_AVGBUY,0);
		set V_AVGSELL = coalesce(V_AVGSELL,0);

        
        SET V_UNSETTLEDCOUNT=ABS(V_BUYCOUNT-V_SELLCOUNT);
		set V_SETTLEDCOUNT=least(V_BUYCOUNT,V_SELLCOUNT);
        IF V_UNSETTLEDCOUNT>0 THEN
         SET V_TOTUNSETTLEDCOUNT=V_TOTUNSETTLEDCOUNT+1;
        ELSE
         SET V_TOTSETTLEDCOUNT=V_TOTSETTLEDCOUNT+1;
         END IF;
		IF V_SETTLEDCOUNT>0 THEN
			IF V_AVGBUY>=V_AVGSELL then
			SET V_PROFIT= V_SETTLEDCOUNT*(V_AVGSELL-V_AVGBUY); 
			SET V_NUMLOSS=V_NUMLOSS+1;
			SET V_TOTPROFIT=V_TOTPROFIT+V_PROFIT;
			ELSE
			SET V_LOSS=V_SETTLEDCOUNT*(V_AVGBUY-V_AVGSELL);
			SET V_NUMGAIN=V_NUMGAIN+1;
			SET V_TOTLOSS=V_TOTLOSS+V_LOSS;
			END IF;	
        END IF;    
        SET V_PROFIT=0;
        SET V_LOSS=0;
        SET V_SETTLEDCOUNT=0;
        SET V_UNSETTLEDCOUNT=0;
   
   END LOOP;
			set P_NUMBEROFUNSETTLED=V_TOTUNSETTLEDCOUNT;
			set P_STOCKCOUNT=V_STOCKCOUNT;
			set P_NUMBEROFGAIN=V_NUMGAIN;
			set P_NUMBEROFLOSS=V_NUMLOSS;
			set P_PROFIT=V_TOTPROFIT-V_TOTLOSS;

  CLOSE cur1;

 ROLLBACK;
 END; 
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `PROCEDURE_ADVANCE_DECLINE` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `PROCEDURE_ADVANCE_DECLINE`(
IN P_GROUPID INT,
OUT P_ADVANCE INT,
OUT P_DECLINE INT,
OUT errorCode INT
)
BEGIN

DECLARE V_PCHANGE INT DEFAULT 0;
DECLARE V_STOCKCOUNT INT DEFAULT 0;
DECLARE V_ADVANCECOUNT,V_DECLINECOUNT INT DEFAULT 0;
DECLARE done INT DEFAULT FALSE;

DECLARE EXIT HANDLER FOR SQLEXCEPTION SET errorCode = 1;
 BEGIN
 DECLARE cur1 CURSOR FOR SELECT st.pchange from stockthreemin st inner join stockdetails sd on sd.stockid=st.stockid inner join `group` g on g.groupid=sd.groupid where g.groupid=P_GROUPID;

 DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

SELECT 
    COUNT(st.stockid)
INTO V_STOCKCOUNT FROM
    stockthreemin st
        INNER JOIN
    stockdetails sd ON sd.stockid = st.stockid
        INNER JOIN
    `group` g ON g.groupid = sd.groupid
WHERE
    g.groupid = P_GROUPID;
 
  OPEN cur1;
    read_loop: LOOP
      FETCH cur1 INTO V_PCHANGE;
        IF done THEN
          LEAVE read_loop;
        END IF;
	IF 	V_PCHANGE>0 THEN
		SET V_ADVANCECOUNT=V_ADVANCECOUNT+1;
	ELSE
		SET	V_DECLINECOUNT=V_DECLINECOUNT+1;
	END IF;	
   
   END LOOP;
   
   SET P_ADVANCE=V_ADVANCECOUNT;
   SET P_DECLINE=V_DECLINECOUNT;

  CLOSE cur1;
  ROLLBACK;
END; 
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `PROCEDURE_ATR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `PROCEDURE_ATR`(
IN P_STOCKID INT,
IN P_PERIOD INT,
IN P_TIMEFRAMEID INT,
IN P_INDEX INT,
INOUT P_TEMPATR  DECIMAL(16,2),
INOUT P_ADX DECIMAL(16,2),
INOUT P_DM_PLUS2 DECIMAL(16,2),
INOUT P_DM_MINUS2 DECIMAL(16,2),
OUT P_DM_PLUS DECIMAL(16,2),
OUT P_DM_MINUS DECIMAL(16,2), 
OUT P_TR DECIMAL(16,2),
OUT P_DX DECIMAL(16,2),
OUT P_LASTUPDATE DATETIME,
OUT  errorCode INT
)
BEGIN

DECLARE V_ATR,V_TR,V_CURATR DECIMAL(16,2) DEFAULT 0.0;
DECLARE V_HIGH,V_LOW,V_CLOSE DECIMAL(16,2)  DEFAULT 0.0;
DECLARE V_PRE_HIGH,V_PRE_LOW,V_PRE_CLOSE DECIMAL(16,2)  DEFAULT 0.0;
DECLARE V_DM_PLUS,V_DM_MINUS,V_DM_PLUS2,V_DM_MINUS2,V_DM_PLUS_AVG,V_DM_MINUS_AVG,V_TEMPDX,V_DX,V_ADX,V_DI_PLUS,V_DI_MINUS DECIMAL(16,2)  DEFAULT 0.0;


DECLARE V_LASTDATE datetime;
DECLARE V_ATRID INT;


DECLARE V_TEMPATR,V_TEMPTR DECIMAL(16,2) DEFAULT 0.0;
DECLARE V_ATRSEQUENCE,V_TRSEQUENCE DECIMAL(16,2) DEFAULT 0.0;


DECLARE EXIT HANDLER FOR SQLEXCEPTION SET errorCode = 1;
 BEGIN

select high,low,close,createdate  into V_HIGH,V_LOW,V_CLOSE,V_LASTDATE from (SELECT t.createdate,high,low,close FROM tickdata t  inner join stocktimeframe st on t.timeframeid=st.timeframeid  where stockid=P_STOCKID and  st.timeframeid=P_TIMEFRAMEID  group by ticksequence having ticksequence= ( P_INDEX )) a;
SELECT 
    high, low, close, createdate
INTO V_PRE_HIGH , V_PRE_LOW , V_PRE_CLOSE , V_LASTDATE FROM
    (SELECT 
        t.createdate, high, low, close
    FROM
        tickdata t
    INNER JOIN stocktimeframe st ON t.timeframeid = st.timeframeid
    WHERE
        stockid = P_STOCKID
            AND st.timeframeid = P_TIMEFRAMEID
    GROUP BY ticksequence
    HAVING ticksequence = (P_INDEX) - 1) a;










if V_TRSEQUENCE is null then
	set V_TRSEQUENCE=1;
	else
	set V_TRSEQUENCE=V_TRSEQUENCE+1;
end if;	
	



    
IF  V_PRE_CLOSE> V_HIGH THEN 
	SET V_TR=V_PRE_CLOSE-V_LOW;
ELSEIF  V_PRE_CLOSE<V_LOW THEN
	SET V_TR=V_HIGH-V_PRE_CLOSE;
else
	SET V_TR=V_HIGH-V_LOW;	
end if;    

SET P_TR= V_TR;   
 


IF  V_HIGH-V_PRE_HIGH>V_PRE_LOW-V_LOW THEN
SET V_DM_PLUS= V_HIGH-V_PRE_HIGH;
	if V_DM_PLUS<0 then 
	set V_DM_PLUS=0;
	end if;
 ELSE 
 	set V_DM_PLUS=0;
END IF;     

if V_PRE_LOW-V_LOW>V_HIGH-V_PRE_HIGH THEN
SET V_DM_MINUS=V_PRE_LOW-V_LOW;
	if V_DM_MINUS<0 then 
	set V_DM_MINUS=0;
	end if;
else
set V_DM_MINUS=0;
END IF;

SET P_DM_PLUS=V_DM_PLUS;
SET P_DM_MINUS=V_DM_MINUS;
SET P_LASTUPDATE=V_LASTDATE+INTERVAL 1 DAY;


IF P_INDEX>P_PERIOD   THEN
    
    if P_INDEX=P_PERIOD+1 then
    SET P_TEMPATR=P_TEMPATR+V_TR;
    set P_DM_PLUS2=P_DM_PLUS2+V_DM_PLUS;
	set P_DM_MINUS2=P_DM_MINUS2+V_DM_MINUS;
    else
	set P_DM_PLUS2=P_DM_PLUS2-(P_DM_PLUS2/14)+V_DM_PLUS;
	set P_DM_MINUS2=P_DM_MINUS2-(P_DM_MINUS2/14)+V_DM_MINUS;
    SET P_TEMPATR = P_TEMPATR-(P_TEMPATR/14)+V_TR;
    end if;
	 
    
    

        SET V_DI_PLUS=100*(P_DM_PLUS2/P_TEMPATR);
		SET V_DI_MINUS=100*(P_DM_MINUS2/P_TEMPATR);
        

        SET P_DX=100*(ABS(V_DI_PLUS-V_DI_MINUS)/(V_DI_PLUS+V_DI_MINUS));
        

		IF P_INDEX >= 28  THEN
			IF P_INDEX = 28 then
			set P_ADX=P_ADX;
			else
			SET P_ADX=((P_ADX*13)+P_DX)/14; 
            end if;
        END IF;
        

end if;
  ROLLBACK;
END; 

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `PROCEDURE_BALANCE_TRANSACTION` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `PROCEDURE_BALANCE_TRANSACTION`(
IN P_USERID INT,
IN P_AMOUNT DECIMAL(16,2),
IN P_MODEAMOUNT DECIMAL(16,2),
IN P_TRANTYPE INT,
IN P_ACCOUNTTYPE INT,
OUT errorCode INT
)
BEGIN
 DECLARE EXIT HANDLER FOR SQLEXCEPTION SET errorCode = 1;
 BEGIN
	if P_TRANTYPE=1 then
		if P_AMOUNT>0 THEN
		INSERT INTO ledger ( amount, createid,description,trantype, acounttype) VALUES ( P_AMOUNT, P_USERID,'amount deposited to account', P_TRANTYPE, P_ACCOUNTTYPE);
		UPDATE balance 
SET 
    amount = amount + P_AMOUNT
WHERE
    userid = P_USERID;
        end if;
        if P_MODEAMOUNT>0 THEN
        update balance set modeamount=modeamount+P_MODEAMOUNT where userid=P_USERID;
        END IF;
    else
		if P_AMOUNT>0 THEN
		INSERT INTO ledger ( amount, createid,description, trantype, acounttype) VALUES ( P_AMOUNT, P_USERID, 'amount withdrawn from account',P_TRANTYPE, P_ACCOUNTTYPE);
		UPDATE balance 
SET 
    amount = amount - P_AMOUNT
WHERE
    userid = P_USERID;
        end if;
        if P_MODEAMOUNT>0 THEN
        update balance set modeamount=modeamount-P_MODEAMOUNT where userid=P_USERID;
        END IF;
    end if;
      ROLLBACK;
END; 
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `PROCEDURE_BREAKING_SUPPORT_RESISTANCE` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `PROCEDURE_BREAKING_SUPPORT_RESISTANCE`(
IN P_STOCKCODE VARCHAR(50),
IN P_STOCKPRICE DECIMAL(10,2),
OUT P_OUTPUT VARCHAR(200),
OUT errorCode INT
)
BEGIN

DECLARE V_STOCKID INT DEFAULT 0;
DECLARE V_HIGH,V_LOW DECIMAL(10,2);
BEGIN
 DECLARE EXIT HANDLER FOR SQLEXCEPTION SET errorCode = 1;
SELECT 
    stockid
INTO V_STOCKID FROM
    stockdetails
WHERE
    code = P_STOCKCODE;
SELECT 
    high, low
INTO V_HIGH , V_LOW FROM
    stockdb.dailyhighlow
WHERE
    stockid = V_STOCKID;

IF P_STOCKPRICE>V_HIGH THEN 
	SET P_OUTPUT= concat('The stock with symbol ',P_STOCKCODE,'is breaking its day high');
ELSEIF P_STOCKPRICE<V_LOW THEN
	SET P_OUTPUT= concat('The stock with symbol ',P_STOCKCODE,'is breaking its day high');
    
END IF;    
  ROLLBACK;
END; 
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `PROCEDURE_DELETE_PORTFOLIO` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `PROCEDURE_DELETE_PORTFOLIO`(
IN P_PORTFOLIOID INT,
IN P_USERID INT,
out errorCode int
)
BEGIN
BEGIN
 DECLARE EXIT HANDLER FOR SQLEXCEPTION SET errorCode = 1;
DELETE FROM transactionstrategymapping 
WHERE
    transactionid IN (SELECT 
        transactionid
    FROM
        portfoliotranmapping
    
    WHERE
        portfolioid = P_PORTFOLIOID);
DELETE FROM transaction 
WHERE
    transactionid IN (SELECT 
        transactionid
    FROM
        portfoliotranmapping
    
    WHERE
        portfolioid = P_PORTFOLIOID);
DELETE FROM portfoliotranmapping 
WHERE
    portfolioid = P_PORTFOLIOID;
DELETE FROM portfolio 
WHERE
    portfolioid = P_PORTFOLIOID;
DELETE FROM attrval 
WHERE
    attrvalid IN (SELECT 
        attrvalid
    FROM
        portfolioattrmapping
    
    WHERE
        portfolioid = P_PORTFOLIOID);
DELETE FROM portfolioattrmapping 
WHERE
    portfolioid = P_PORTFOLIOID;
 ROLLBACK;
END;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `PROCEDURE_EDIT_TRANSACTION` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `PROCEDURE_EDIT_TRANSACTION`(
IN P_CREATEDATE DATETIME,
IN P_QUANTITY INT,
IN P_PRICE DECIMAL(16,2),
IN P_TRANID INT,
OUT errorCode INT
)
BEGIN

	DECLARE V_PRE_PRICE DECIMAL(16,2);
    DECLARE V_PRE_QUANTITY INT;
    BEGIN
 DECLARE EXIT HANDLER FOR SQLEXCEPTION SET errorCode = 1;
SELECT 
    price, quantity
INTO V_PRE_PRICE , V_PRE_QUANTITY FROM
    transaction
WHERE
    transactionid = P_TRANID;
UPDATE balance 
SET 
    amount = amount + (V_PRE_PRICE * V_PRE_QUANTITY - P_QUANTITY * P_PRICE);
	UPDATE transaction 
SET 
    createdate = P_CREATEDATE,
    quantity = P_QUANTITY,
    price = P_PRICE
WHERE
    transactionid = P_TRANID;
 ROLLBACK;
END;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `PROCEDURE_EMA` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `PROCEDURE_EMA`(
IN P_STOCKID INT,
IN P_PERIOD INT,
IN P_TIMEFRAMEID INT,
IN P_INDEX INT,
IN P_LASTEMAVALUE DECIMAL(16,2),
OUT P_EMAID INT,
OUT P_EMAVAL DECIMAL(16,2),
OUT P_EMA_LASTDATE DATETIME,
OUT P_EMASEQUENCE INT,
OUT errorCode INT
)
BEGIN

DECLARE V_SMA DECIMAL(16,2) DEFAULT 0.0;
DECLARE V_MULTIPLIER  DECIMAL(16,2) DEFAULT 0.0;
DECLARE V_LASTPRICE DECIMAL(16,2)  DEFAULT 0.0;
DECLARE V_LASTDATE datetime;
DECLARE V_EMAID INT;


DECLARE V_TEMPEMA DECIMAL(16,2) DEFAULT 0.0;
DECLARE V_EMASEQUENCE DECIMAL(16,2) DEFAULT 0.0;

DECLARE ema DECIMAL(16,2); 
BEGIN
 DECLARE EXIT HANDLER FOR SQLEXCEPTION SET errorCode = 1;

select lastprice,createdate  into V_LASTPRICE,V_LASTDATE from (SELECT t.createdate,lastprice FROM tickdata t  inner join stocktimeframe st on t.timeframeid=st.timeframeid  where stockid=P_STOCKID and  st.timeframeid=P_TIMEFRAMEID  group by ticksequence having ticksequence= ( P_INDEX )) a;



select max(sequence) into V_EMASEQUENCE from ema e inner join stockemamapping se on se.emaid=e.emaid inner join stocktimeframe st on e.timeframeid=st.timeframeid  where se.stockid=P_STOCKID and period=P_PERIOD and st.timeframeid=P_TIMEFRAMEID  and period=P_PERIOD;

if V_EMASEQUENCE is null then
set V_EMASEQUENCE=1;
else
set V_EMASEQUENCE=V_EMASEQUENCE+1;
end if;





if P_INDEX= P_PERIOD then 
select avg(a.lastprice)  into V_SMA from (SELECT lastprice FROM tickdata t inner join stocktimeframe st on t.timeframeid=st.timeframeid  where stockid=P_STOCKID and  st.timeframeid=P_TIMEFRAMEID  group by ticksequence having ticksequence<=P_PERIOD) a;
SET ema=V_SMA;
else
SELECT V_LASTPRICE,P_LASTEMAVALUE;
 SET ema = ((V_LASTPRICE * ( 2 / ( P_PERIOD + 1 ))) 
		+ (P_LASTEMAVALUE * (1 - (2 / (P_PERIOD + 1)))));
end if;
  
    
   
	
 SELECT max(emaid)   into V_EMAID FROM ema e where status='A' ;
 if V_EMAID IS NULL THEN
 SET P_EMAID=0;
 else
 SET P_EMAID=V_EMAID;
 END IF;
 
 SET P_EMAVAL=ema;
 set P_EMA_LASTDATE=V_LASTDATE;
 set P_EMASEQUENCE=V_EMASEQUENCE;
 
   ROLLBACK;
END;
 
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `PROCEDURE_EMA_CROSSOVERS` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `PROCEDURE_EMA_CROSSOVERS`(
IN P_STOCKCODE VARCHAR(50),
IN P_EMASHORT INT,
IN P_EMALONG INT,
OUT P_OUTPUT VARCHAR(200),
OUT errorCode INT
)
BEGIN

DECLARE V_EMASHORTVAL,V_EMALONGVAL,V_DIFFPERCENT,V_PCHANGE,V_MACDVAL,V_MACD_EMAVAL decimal(16,2);
DECLARE V_STOCKID,V_PORTFOLIOSTOCKID,V_WATCHLISTSTOCKID  INT DEFAULT 0;
DECLARE V_STATUS,V_PORTFOLIONAME,V_WATCHLISTNAME  VARCHAR(45) ;
DECLARE V_SEQUENCE,V_BUYQUANTITY,V_SELLQUANTITY INT;
BEGIN
 DECLARE EXIT HANDLER FOR SQLEXCEPTION SET errorCode = 1;

SELECT stockid into V_STOCKID from stockdetails where code=P_STOCKCODE;


if V_STOCKID <> 0 THEN

SELECT emavalue INTO V_EMASHORTVAL   FROM ema e inner join stockemamapping se on se.emaid=e.emaid inner join stocktimeframe st on e.timeframeid=st.timeframeid  where se.stockid=V_STOCKID and e.period=P_EMASHORT and st.timeframeid=1   group by sequence having sequence= (select max(sequence) from ema e inner join stockemamapping se on se.emaid=e.emaid inner join stocktimeframe st on e.timeframeid=st.timeframeid  where se.stockid=V_STOCKID and e.period=P_EMASHORT and st.timeframeid=1);
SELECT emavalue INTO V_EMALONGVAL   FROM ema e inner join stockemamapping se on se.emaid=e.emaid inner join stocktimeframe st on e.timeframeid=st.timeframeid  where se.stockid=V_STOCKID and e.period=P_EMALONG and st.timeframeid=1   group by sequence having sequence= (select max(sequence) from ema e inner join stockemamapping se on se.emaid=e.emaid inner join stocktimeframe st on e.timeframeid=st.timeframeid  where se.stockid=V_STOCKID and e.period=P_EMALONG and st.timeframeid=1);


select e.status,sequence into V_STATUS,V_SEQUENCE from `stockdb`.`emacrossover` e where stockid=V_STOCKID and emashort=P_EMASHORT and emalong=P_EMALONG  group by sequence having sequence= (select max(sequence) from `stockdb`.`emacrossover` where stockid=V_STOCKID and emashort=P_EMASHORT and emalong=P_EMALONG);







if V_STATUS is null then
set V_SEQUENCE=1;
else 
set V_SEQUENCE=V_SEQUENCE+1;
end if;

select V_STATUS,V_SEQUENCE,V_EMASHORTVAL,V_EMALONGVAL;

select distinct s.stockid INTO V_PORTFOLIOSTOCKID from stockdetails s
inner join transaction t on  t.stockid=s.stockid
inner join portfoliotranmapping pt on t.transactionid=pt.transactionid
inner join portfolio p on p.portfolioid=pt.portfolioid where p.trackportfolio='on' and s.stockid=V_STOCKID;

select distinct t.quantity into V_BUYQUANTITY  from stockdetails s
inner join transaction t on  t.stockid=s.stockid
inner join portfoliotranmapping pt on t.transactionid=pt.transactionid
inner join portfolio p on p.portfolioid=pt.portfolioid where p.trackportfolio='on' and s.stockid=V_STOCKID and t.transactiontypeid=1 and t.transactiontypeid=2;


select distinct t.quantity into V_SELLQUANTITY  from stockdetails s
inner join transaction t on  t.stockid=s.stockid
inner join portfoliotranmapping pt on t.transactionid=pt.transactionid
inner join portfolio p on p.portfolioid=pt.portfolioid where p.trackportfolio='on' and s.stockid=V_STOCKID and t.transactiontypeid=2 and t.transactiontypeid=2;




select distinct s.stockid  INTO V_WATCHLISTSTOCKID from stockdetails s
inner join watchliststockmapping wt on wt.stockid=s.stockid
inner join watchlist w on  w.watchlistid= wt.watchlistid
where w.trackwatchlist=1 and s.stockid=V_STOCKID;


select pchange into V_PCHANGE from dailyhighlow where stockid=V_STOCKID;



IF V_EMASHORTVAL <>0 AND  V_EMALONGVAL <> 0 THEN

	SET V_DIFFPERCENT=((V_EMASHORTVAL-V_EMALONGVAL)*100)/V_EMALONGVAL;
	
	IF abs(V_DIFFPERCENT)> 0.05  and  V_EMALONGVAL<3000 THEN
		
	  IF V_EMASHORTVAL> V_EMALONGVAL    then
		IF V_STATUS is null OR V_STATUS='D' THEN 
			 IF  V_PORTFOLIOSTOCKID=V_STOCKID then
					INSERT INTO `stockdb`.`emacrossover` (`stockid`, `emashort`, `emalong`, `createdate`, `status`, `sequence`) VALUES (V_STOCKID, P_EMASHORT, P_EMALONG, now(), 'U', V_SEQUENCE);
					SET P_OUTPUT= concat('Exit From the position',P_STOCKCODE,'buy back this stock');
                 ELSEIF V_WATCHLISTSTOCKID=V_STOCKID then
					INSERT INTO `stockdb`.`emacrossover` (`stockid`, `emashort`, `emalong`, `createdate`, `status`, `sequence`) VALUES (V_STOCKID, P_EMASHORT, P_EMALONG, now(), 'U', V_SEQUENCE);
                    SET P_OUTPUT= concat('The stock with symbol in your watchlist ',P_STOCKCODE,'upside ema crossover ');
                 ELSE   
					IF  V_PCHANGE>0 AND abs(V_PCHANGE) >= 2.5 THEN
					INSERT INTO `stockdb`.`emacrossover` (`stockid`, `emashort`, `emalong`, `createdate`, `status`, `sequence`) VALUES (V_STOCKID, P_EMASHORT, P_EMALONG, now(), 'U', V_SEQUENCE);
					SET P_OUTPUT= concat('The stock with symbol ',P_STOCKCODE,'upside ema crossover ');
                    END IF;
			 END IF;   
           END IF; 
           
	elseif V_EMASHORTVAL< V_EMALONGVAL  then
		IF V_STATUS is null OR V_STATUS='U' THEN
			IF  V_PORTFOLIOSTOCKID=V_STOCKID then
					INSERT INTO `stockdb`.`emacrossover` (`stockid`, `emashort`, `emalong`, `createdate`, `status`,         `sequence`) VALUES (V_STOCKID, P_EMASHORT, P_EMALONG, now(), 'D',V_SEQUENCE);
					SET P_OUTPUT= concat('Exit From the position',P_STOCKCODE,'sell out this stock');
                ELSEIF V_WATCHLISTSTOCKID=V_STOCKID then
					INSERT INTO `stockdb`.`emacrossover` (`stockid`, `emashort`, `emalong`, `createdate`, `status`,         `sequence`) VALUES (V_STOCKID, P_EMASHORT, P_EMALONG, now(), 'D',V_SEQUENCE);
                    SET P_OUTPUT= concat('The stock with symbol in your watchlist ',P_STOCKCODE,'downside ema crossover ');    
				ELSE   
					IF  V_PCHANGE<0  AND abs(V_PCHANGE) >= 2.5 THEN
					INSERT INTO `stockdb`.`emacrossover` (`stockid`, `emashort`, `emalong`, `createdate`, `status`,         `sequence`) VALUES (V_STOCKID, P_EMASHORT, P_EMALONG, now(), 'D',V_SEQUENCE);
				    SET P_OUTPUT= concat('The stock with symbol ',P_STOCKCODE,'downside ema crossover ');
                    END IF;
				END IF;        
			END IF;
        
        END IF;
     END IF;
END IF;     
       
END IF;  
       ROLLBACK;
END;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `PROCEDURE_EMA_POPULATE` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `PROCEDURE_EMA_POPULATE`(
IN P_STOCKID INT,
IN P_PERIOD INT,
IN P_TIMEFRAMEID INT,
OUT errorCode INT

)
BEGIN

 DECLARE V_SEQUENCE,V_LASTEMASEQUENCE INT DEFAULT 0;	
 
 DECLARE done INT DEFAULT FALSE;

 DECLARE cur1 CURSOR FOR SELECT ticksequence from tickdata t inner join stocktimeframe st on t.timeframeid=st.timeframeid  where stockid=P_STOCKID and t.timeframeid=P_TIMEFRAMEID;  

 DECLARE cur2 CURSOR FOR SELECT ticksequence from tickdata t inner join stocktimeframe st on t.timeframeid=st.timeframeid  where stockid=P_STOCKID and t.timeframeid=P_TIMEFRAMEID and ticksequence >( SELECT max(e.sequence)  FROM ema e  inner join stockemamapping se on se.emaid=e.emaid where se.stockid=P_STOCKID and period=P_PERIOD and timeframeid=P_TIMEFRAMEID)+P_PERIOD;  


 DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
 
 BEGIN
 DECLARE EXIT HANDLER FOR SQLEXCEPTION SET errorCode = 1;


SELECT max(e.sequence) into V_LASTEMASEQUENCE FROM ema e  inner join stockemamapping se on se.emaid=e.emaid where se.stockid=P_STOCKID and period=P_PERIOD and timeframeid=P_TIMEFRAMEID;


IF V_LASTEMASEQUENCE>0 THEN
		 OPEN cur2;
		read_loop: LOOP
		  FETCH cur2 INTO V_SEQUENCE;
			IF done THEN
			  LEAVE read_loop;
			END IF;
            CALL PROCEDURE_EMA(P_STOCKID,P_PERIOD,P_TIMEFRAMEID,V_SEQUENCE);

	   END LOOP;
	  CLOSE cur2;

ELSE     
 OPEN cur1;
    read_loop: LOOP
      FETCH cur1 INTO V_SEQUENCE;
		 IF done THEN
          LEAVE read_loop;
        END IF;
		IF 	V_SEQUENCE>P_PERIOD THEN
		CALL PROCEDURE_EMA(P_STOCKID,P_PERIOD,P_TIMEFRAMEID,V_SEQUENCE);
		END IF;	
       
	
   
   END LOOP;
  CLOSE cur1;
END IF;  
  ROLLBACK;
END;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `PROCEDURE_EMPTY_TABLES` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `PROCEDURE_EMPTY_TABLES`()
BEGIN

truncate tickdata;
truncate tr;
truncate dm;
truncate atr;
truncate adx;
truncate dx;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `PROCEDURE_INSERTORMODIFYBALANCE` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `PROCEDURE_INSERTORMODIFYBALANCE`(
in USERID INT,
in TRANTYPE INT,
in BALANCE DECIMAL(10,2),
out errorcode INT

)
BEGIN

DECLARE pamount INT DEFAULT 0;
DECLARE pid decimal DEFAULT 0;

BEGIN
 DECLARE EXIT HANDLER FOR SQLEXCEPTION SET errorCode = 1;
SELECT 
    balance_id, amount
INTO pid , pamount FROM
    balance
WHERE
    userid = USERID;

SELECT pid, pamount;

IF pid  <> 0 THEN

IF TRANTYPE = 1 THEN
SET pamount=BALANCE+pamount;
ELSEIF TRANTYPE =2 THEN
SET pamount=pamount-BALANCE;
ELSE 
SET pamount=BALANCE;	
END IF;

SELECT pid, pamount, USERID;

UPDATE balance 
SET 
    amount = pamount,
    updatedate = NOW()
WHERE
    balance_id = pid;

ELSE
INSERT INTO `stockdb`.`balance`(`userid`,`amount`,`createdate`,`updatedate`)
VALUES(
USERID,
BALANCE,
now(),
now());	

END IF;
 ROLLBACK;
END;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `PROCEDURE_INSERTORMODIFYPORTFOLIOATTR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `PROCEDURE_INSERTORMODIFYPORTFOLIOATTR`(
IN P_PORTFOLIOID INT,
IN P_ATTRID INT,
IN P_ATTRVAL VARCHAR(200),
OUT errorcode INT
)
BEGIN

DECLARE A_ATTRVALID INT DEFAULT 0;

BEGIN
 DECLARE EXIT HANDLER FOR SQLEXCEPTION SET errorCode = 1;

SELECT 
    av.attrvalid
INTO A_ATTRVALID FROM
    portfolioattrmapping pa
        INNER JOIN
    attribute a ON pa.attributeid = a.attributeid
        INNER JOIN
    attrval av ON av.attributeid = a.attributeid and pa.attrvalid=av.attrvalid
WHERE
    a.attributeid = P_ATTRID
        AND portfolioid = P_PORTFOLIOID;

if A_ATTRVALID = 0 THEN 
INSERT INTO attrval(attributeid,value,createdate,updatedate,status)VALUES(P_ATTRID,A_ATTRVALID,now(),now(),'A');
SELECT LAST_INSERT_ID() INTO A_ATTRVALID;
INSERT INTO portfolioattrmapping
(portfolioid,
attributeid,
attrvalid,
createdate,
updatedate,
status)
VALUES
(P_PORTFOLIOID,
P_ATTRID,
A_ATTRVALID,
now(),
now(),
'A');
else 
UPDATE attrval
SET
value = P_ATTRVAL,
updatedate =  now(),
status = 'U'
WHERE attrvalid = A_ATTRVALID ;
end if;

 ROLLBACK;
END;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `PROCEDURE_INSERTSTOCKTOWATCHLIST` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `PROCEDURE_INSERTSTOCKTOWATCHLIST`(
IN P_WATCHLISTID INT,
IN P_STOCKID INT,
IN P_USERID INT,
OUT errorCode INT
)
BEGIN
DECLARE V_STOCKID INT DEFAULT 0;
BEGIN
 DECLARE EXIT HANDLER FOR SQLEXCEPTION SET errorCode = 1;

SELECT ws.stockid into V_STOCKID from watchliststockmapping ws
INNER JOIN stockdetails s on s.stockid=ws.stockid
where ws.stockid=P_STOCKID;

IF V_STOCKID =0 THEN
INSERT INTO `stockdb`.`watchliststockmapping` (`watchlistid`, `stockid`, `createid`, `createdate`) VALUES (P_WATCHLISTID, P_STOCKID, P_USERID, now());
UPDATE `stockdb`.`watchlist` SET `updateid` = P_USERID, `updatedate` = now() WHERE `watchlistid` = P_WATCHLISTID;
END IF;
 ROLLBACK;
END;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `PROCEDURE_INSERTTRANSACTIONDATA` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `PROCEDURE_INSERTTRANSACTIONDATA`(
IN P_STOCKID INT,
IN P_POSITIONTYPE varchar(45),
IN P_TRANTYPE VARCHAR(45),
IN P_QUANTITY INT,
IN P_AMOUNT DECIMAL(16,2),
IN P_STOPLOSS DECIMAL(16,2),
IN P_USERID INT,
IN P_PORTFOLIOID INT,
IN P_STRATEGYID INT,
IN P_STRATEGYDES VARCHAR(200),
OUT tranId int,
OUT errorCode int
)
BEGIN

DECLARE V_EXCHANGEID INT DEFAULT 0;
DECLARE V_STRATEGYID INT DEFAULT 0;
declare V_QUANTITY INT DEFAULT 0;

declare V_PREAMOUNT DECIMAL(16,2) DEFAULT 0;
declare V_PROFIT DECIMAL(16,2) DEFAULT 0;
declare V_PROFITBAL DECIMAL(16,2) DEFAULT 0;
declare V_USERID int DEFAULT 0;
declare V_LASTTRANID int DEFAULT 0;
declare V_LASTSTOCKID int DEFAULT 0;
declare V_PORTFOLIO_NAME VARCHAR(200);


BEGIN
 DECLARE EXIT HANDLER FOR SQLEXCEPTION SET errorCode = 1;


select sum(qty) into V_QUANTITY from(select s.code,if(t.transactiontypeid =1,sum(t.quantity),sum(-t.quantity))as qty,t.transactiontypeid from portfolio p inner join portfoliotranmapping pt on  p.portfolioid=pt.portfolioid left join transaction t on t.transactionid=pt.transactionid  inner join stockdetails s on s.stockid=t.stockid   inner join  stockgroup sg on sg.groupid=s.groupid where p.portfolioid=P_PORTFOLIOID and s.stockid=P_STOCKID group by s.stockid,t.transactiontypeid)a group by code;


  select name into V_PORTFOLIO_NAME from portfolio where portfolioid=P_PORTFOLIOID;
  
  
if V_QUANTITY-P_QUANTITY=0 then

    select amount,userid into V_PROFITBAL,V_USERID FROM profitbalance where userid=P_USERID;
    
	select avg(price) into V_PREAMOUNT from  transaction where stockid in(SELECT t.stockid from transaction t inner join portfoliotranmapping pt on t.transactionid=pt.transactionid where pt.portfolioid=P_PORTFOLIOID and t.stockid=P_STOCKID);
    
  
    
    IF V_PORTFOLIO_NAME='CURRENT HOLDING' THEN 
		IF P_TRANTYPE=2 THEN
			
			SET V_PROFIT=P_AMOUNT-V_PREAMOUNT;
		ELSE 
			SET V_PROFIT=V_PREAMOUNT-P_AMOUNT;
		 end if;   
		 update balance set amount=amount+P_QUANTITY*P_AMOUNT;
		 set V_PROFITBAL=V_PROFITBAL+V_PROFIT*P_QUANTITY;   

		 IF V_USERID =0 THEN
				 
				INSERT INTO profitbalance(userid,timeframid,amount )VALUES(P_USERID,5,V_PROFITBAL);    
		 ELSE
			SET V_PROFITBAL=V_PROFITBAL+V_PROFIT;
			UPDATE profitbalance SET amount=V_PROFITBAL,updatedate=now() where userid=P_USERID;
		end if; 

    END IF;
        
	

	insert into transaction_h (stockid, quantity,price,stoploss, holdingtypeid, transactiontypeid, createid, createdate)  
	select stockid, quantity,price,stoploss, holdingtypeid, transactiontypeid, createid, createdate from transaction t  where transactionid in (select  t.transactionid from transaction t inner join portfoliotranmapping pt on t.transactionid=pt.transactionid where pt.portfolioid=P_PORTFOLIOID and t.stockid=P_STOCKID); 
	
    
	INSERT INTO portfoliotranmapping_h (portfolioid,transactionid, exchangeid, createdate) 
	select portfolioid,transactionid, exchangeid, createdate  from portfoliotranmapping where transactionid in(select t.transactionid from  transaction t inner join portfoliotranmapping pt on t.transactionid=pt.transactionid where pt.portfolioid=P_PORTFOLIOID and t.stockid=P_STOCKID);


	delete from portfoliotranmapping where transactionid in (select a.transactionid from (SELECT t.transactionid  from transaction t inner join portfoliotranmapping pt on t.transactionid=pt.transactionid where pt.portfolioid=P_PORTFOLIOID and t.stockid=P_STOCKID) a);

    delete from transaction where transactionid in (select a.transactionid from (SELECT t.transactionid  from transaction t inner join portfoliotranmapping pt on t.transactionid=pt.transactionid where pt.portfolioid=P_PORTFOLIOID and t.stockid=P_STOCKID) a); 

else	
		 IF V_PORTFOLIO_NAME='CURRENT HOLDING' THEN 
          update balance set amount=amount-P_QUANTITY*P_AMOUNT;
         END IF;
		INSERT INTO transaction (stockid, quantity,price,stoploss, holdingtypeid, transactiontypeid, createid, createdate) VALUES (P_STOCKID, P_QUANTITY,P_AMOUNT,P_STOPLOSS,P_POSITIONTYPE,P_TRANTYPE, P_USERID, NOW()); 
		SELECT LAST_INSERT_ID() into tranId;
		SELECT s.exchangeid into V_EXCHANGEID from stockdetails s where s.stockid=P_STOCKID;
		INSERT INTO portfoliotranmapping (portfolioid, transactionid, exchangeid, createdate) VALUES (P_PORTFOLIOID, tranId, V_EXCHANGEID, NOW()); 
		IF V_STRATEGYID=0 THEN
			INSERT INTO transactionstrategymapping (transactionid, strategyid) VALUES (tranid, P_STRATEGYID);  
			ELSE
			INSERT INTO transactionstrategymapping (transactionid, strategyid) VALUES (tranid, V_STRATEGYID);  
		
		end if;

END IF;
 ROLLBACK;
END;


END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `PROCEDURE_INSERT_EDIT_ATTRIBUTES` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `PROCEDURE_INSERT_EDIT_ATTRIBUTES`(
P_ATTRNAME VARCHAR(200),
P_ATTRVAL VARCHAR(200)
)
BEGIN
DECLARE V_ATTRID,V_ATTRVALID INT;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `PROCEDURE_INSERT_STRATEGY_COMMENT` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `PROCEDURE_INSERT_STRATEGY_COMMENT`(
IN P_STRATEGYID INT,
IN P_COMMENT VARCHAR(2000),
IN P_USERID INT,
OUT errorCode INT
)
BEGIN

DECLARE V_COMMENTID INT default 0;
 BEGIN
 DECLARE EXIT HANDLER FOR SQLEXCEPTION SET errorCode = 1;
INSERT INTO comment (description, userid, createdate) VALUES (P_COMMENT, P_USERID, now());
SET V_COMMENTID=LAST_INSERT_ID();
INSERT INTO strategycommentmapping (strategyid, commentid, createid) VALUES (P_STRATEGYID, V_COMMENTID, P_USERID);
  ROLLBACK;
END;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `PROCEDURE_INSERT_STRATEGY_SATISFACTION` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `PROCEDURE_INSERT_STRATEGY_SATISFACTION`(
IN P_STRATEGYID INT,
IN P_SATISFACTION INT,
IN P_USERID INT,
OUT errorCode INT
)
BEGIN
DECLARE V_SATISFACTIONID,V_SATISFACTION_TYPE INT default 0;
BEGIN
 DECLARE EXIT HANDLER FOR SQLEXCEPTION SET errorCode = 1;
select s.satisfactionid,satisfactiontype into V_SATISFACTIONID,V_SATISFACTION_TYPE from satisfaction s inner join strategysatisfactionmapping ss on s.satisfactionid=ss.satisfactionid where ss.strategyid=P_STRATEGYID and s.createid=P_USERID;

IF V_SATISFACTIONID = 0 THEN
INSERT INTO satisfaction (satisfactiontype, createid) VALUES (P_SATISFACTION,P_USERID);
SET V_SATISFACTIONID=LAST_INSERT_ID();
INSERT INTO strategysatisfactionmapping (strategyid, satisfactionid, createid) VALUES (P_STRATEGYID, V_SATISFACTIONID, P_USERID);
ELSE
update satisfaction s set satisfactiontype=P_SATISFACTION where s.satisfactionid=V_SATISFACTIONID;
end if;
  ROLLBACK;
END;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `PROCEDURE_INSERT_UPDATE_STRATEGY` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `PROCEDURE_INSERT_UPDATE_STRATEGY`(
IN P_DESCRIPTION VARCHAR(200),
IN P_DETAIL_DESCRIPTION VARCHAR(2000),
IN P_SOURCE VARCHAR(500),
IN P_USERID INT,
IN P_ENTRYLONG VARCHAR(2000),
IN P_EXITLONG VARCHAR(2000),
IN P_ENTRYSHORT VARCHAR(2000),
IN P_EXITSHORT VARCHAR(2000),
OUT errorCode INT
)
BEGIN

DECLARE V_STRATEGYID INT default 0;
 BEGIN
 DECLARE EXIT HANDLER FOR SQLEXCEPTION SET errorCode = 1;
INSERT INTO strategy (description, detaildescription, source,createid,createdate) VALUES (P_DESCRIPTION, P_DETAIL_DESCRIPTION,P_SOURCE,P_USERID,now());
	SET V_STRATEGYID=LAST_INSERT_ID();
	INSERT INTO `stockdb`.`formula`(`strategyid`,`entrylong`,`exitlong`,`entryshort`,`exitshort`,`createdate`)VALUES(V_STRATEGYID,P_ENTRYLONG,P_EXITLONG,P_ENTRYSHORT,P_EXITSHORT,now());
ROLLBACK;
END;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `PROCEDURE_MACD` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `PROCEDURE_MACD`(
IN P_STOCKID INT,
IN P_SHORTPERIOD INT,
IN P_LONGPERIOD INT,
IN P_SHORTPERIOD_SEQUENCE INT,
IN P_LONGPERIOD_SEQUENCE INT,
IN P_SHORTPERIOD_VALUE DECIMAL(10,2),
IN P_LONGPERIOD_VALUE DECIMAL(10,2),
IN P_LASTDATE DATETIME,
IN P_TIMEFRAMEID INT,
IN P_SIGNALPERIOD INT,
IN P_INDEX INT,
OUT P_MACDVALUE DECIMAL(16,2),
OUT P_EMAVALUE DECIMAL(16,2),
OUT P_LASTUPDATEDATE DATETIME,
OUT errorCode int

)
BEGIN

DECLARE V_SMA DECIMAL(16,2) DEFAULT 0.0;
DECLARE V_MULTIPLIER  DECIMAL(16,2) DEFAULT 0.0;
DECLARE V_SHORTEMAVALUE,V_LONGEMAVALUE DECIMAL(16,2)  DEFAULT 0.0;
DECLARE V_LASTDATE datetime;
DECLARE V_SHORTEMASEQUENCE,V_LONGEMASEQUENCE INT DEFAULT 0;


DECLARE V_TEMPEMA DECIMAL(16,2) DEFAULT 0.0;
DECLARE V_EMASEQUENCE,V_MACDSEQUENCE,V_EMAID,V_MACDID INT default 0;

DECLARE ema DECIMAL(16,2); 

BEGIN
 DECLARE EXIT HANDLER FOR SQLEXCEPTION SET errorCode = 1;


SET V_SHORTEMASEQUENCE=P_SHORTPERIOD_SEQUENCE;
SET V_LONGEMASEQUENCE=P_LONGPERIOD_SEQUENCE;
SET V_SHORTEMAVALUE=P_SHORTPERIOD_VALUE;
SET V_LONGEMAVALUE=P_LONGPERIOD_VALUE;
SET V_LASTDATE=P_LASTDATE;




IF V_LONGEMASEQUENCE >=0 THEN
	SET V_MACDSEQUENCE=V_LONGEMASEQUENCE;
	
    SET P_MACDVALUE=(V_SHORTEMAVALUE-V_LONGEMAVALUE);
    
END IF;
IF V_MACDSEQUENCE>=P_SIGNALPERIOD THEN
	SET V_EMASEQUENCE=(V_MACDSEQUENCE-P_SIGNALPERIOD)+1;
SELECT 
    emavalue
INTO V_TEMPEMA FROM
    ema e
        INNER JOIN
    macdemamapping me ON me.emaid = e.emaid
        INNER JOIN
    macd m ON m.macdid = me.macdid
WHERE
    m.stockid = P_STOCKID
        AND m.shortperiod = P_SHORTPERIOD
        AND m.longperiod = P_LONGPERIOD
        AND m.timeframeid = P_TIMEFRAMEID
GROUP BY e.sequence
HAVING e.sequence = (SELECT 
        MAX(e.sequence)
    FROM
        ema e
            INNER JOIN
        macdemamapping me ON me.emaid = e.emaid
            INNER JOIN
        macd m ON m.macdid = me.macdid
    WHERE
        m.stockid = P_STOCKID
            AND m.shortperiod = P_SHORTPERIOD
            AND m.longperiod = P_LONGPERIOD
            AND m.timeframeid = P_TIMEFRAMEID);
		IF 	V_MACDSEQUENCE=P_SIGNALPERIOD THEN
		select avg(a.macdvalue)  into V_SMA from (SELECT macdvalue FROM macd m  where m.stockid=P_STOCKID and m.shortperiod=P_SHORTPERIOD and m.longperiod=P_LONGPERIOD and  m.timeframeid=P_TIMEFRAMEID ) a;
		set ema=V_SMA;
        else
		SET ema = (((V_SHORTEMAVALUE-V_LONGEMAVALUE) * ( 2 / ( P_SIGNALPERIOD + 1 ))) 
		+ (V_TEMPEMA * (1 - (2 / (P_SIGNALPERIOD + 1)))));
		end if;

        
        SET P_EMAVALUE=ema;
        SET P_LASTUPDATEDATE=V_LASTDATE;
        
 end if;   
ROLLBACK;
END;


END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `PROCEDURE_MACD_CROSSOVER` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `PROCEDURE_MACD_CROSSOVER`(
IN P_STOCKCODE VARCHAR(50),
IN P_EMASHORT INT,
IN P_EMALONG INT,
OUT P_OUTPUT VARCHAR(200),
OUT errorCode int
)
BEGIN

DECLARE V_EMASHORTVAL,V_EMALONGVAL,V_DIFFPERCENT,V_PCHANGE,V_MACDVAL,V_MACD_EMAVAL decimal(16,2);
DECLARE V_STOCKID,V_PORTFOLIOSTOCKID,V_WATCHLISTSTOCKID  INT DEFAULT 0;
DECLARE V_STATUS,V_PORTFOLIONAME,V_WATCHLISTNAME  VARCHAR(45) ;
DECLARE V_SEQUENCE,V_BUYQUANTITY,V_SELLQUANTITY INT;

BEGIN
 DECLARE EXIT HANDLER FOR SQLEXCEPTION SET errorCode = 1;


SELECT stockid into V_STOCKID from stockdetails where code=P_STOCKCODE;


if V_STOCKID <> 0 THEN





SELECT emavalue INTO  V_MACD_EMAVAL  FROM stockdb.ema e inner join stockdb.macdemamapping me on me.emaid=e.emaid inner join stockdb.macd m on m.macdid=me.macdid where  m.stockid=V_STOCKID and m.shortperiod=12 and m.longperiod=26 and  m.timeframeid=1   group by e.sequence having e.sequence= (select max(e.sequence) from stockdb.ema e inner join stockdb.macdemamapping me on me.emaid=e.emaid inner join stockdb.macd m on m.macdid=me.macdid where  m.stockid=V_STOCKID and m.shortperiod=12 and m.longperiod=26 and  m.timeframeid=1);




select macdvalue INTO V_MACDVAL  from stockdb.macd m where m.shortperiod=12 and m.longperiod=26 and m.stockid=V_STOCKID and  sequence=(select max(sequence) from stockdb.macd m where m.shortperiod=12 and m.longperiod=26 and m.stockid=V_STOCKID);




select e.status,sequence into V_STATUS,V_SEQUENCE from `stockdb`.`macdcrossover` e where stockid=V_STOCKID and shortperiod=12 and longperiod=26 and signalperiod=9  group by sequence having sequence= (select max(sequence)  from `stockdb`.`macdcrossover` e where stockid=V_STOCKID and shortperiod=12 and longperiod=26 and signalperiod=9);



if V_STATUS is null then
set V_SEQUENCE=1;
else 
set V_SEQUENCE=V_SEQUENCE+1;
end if;

select V_STATUS,V_SEQUENCE,V_EMASHORTVAL,V_EMALONGVAL;

select distinct s.stockid INTO V_PORTFOLIOSTOCKID from stockdb.stockdetails s
inner join stockdb.transaction t on  t.stockid=s.stockid
inner join stockdb.portfoliotranmapping pt on t.transactionid=pt.transactionid
inner join stockdb.portfolio p on p.portfolioid=pt.portfolioid where p.trackportfolio='on' and s.stockid=V_STOCKID;

select distinct t.quantity into V_BUYQUANTITY  from stockdb.stockdetails s
inner join stockdb.transaction t on  t.stockid=s.stockid
inner join stockdb.portfoliotranmapping pt on t.transactionid=pt.transactionid
inner join stockdb.portfolio p on p.portfolioid=pt.portfolioid where p.trackportfolio='on' and s.stockid=V_STOCKID and t.transactiontypeid=1 and t.transactiontypeid=2;


select distinct t.quantity into V_SELLQUANTITY  from stockdb.stockdetails s
inner join stockdb.transaction t on  t.stockid=s.stockid
inner join stockdb.portfoliotranmapping pt on t.transactionid=pt.transactionid
inner join stockdb.portfolio p on p.portfolioid=pt.portfolioid where p.trackportfolio='on' and s.stockid=V_STOCKID and t.transactiontypeid=2 and t.transactiontypeid=2;




select distinct s.stockid  INTO V_WATCHLISTSTOCKID from stockdb.stockdetails s
inner join stockdb.watchliststockmapping wt on wt.stockid=s.stockid
inner join stockdb.watchlist w on  w.watchlistid= wt.watchlistid
where w.trackwatchlist=1 and s.stockid=V_STOCKID;


select pchange into V_PCHANGE from stockdb.dailyhighlow where stockid=V_STOCKID;





		
IF V_MACD_EMAVAL <>0 AND  V_MACDVAL <> 0 THEN

	SET V_DIFFPERCENT=((V_MACDVAL-V_MACD_EMAVAL)*100)/V_MACD_EMAVAL;
	
	IF abs(V_DIFFPERCENT)> 0  THEN
		
	  IF V_MACDVAL> V_MACD_EMAVAL    then
		IF V_STATUS is null OR V_STATUS='D' THEN 
			 IF  V_PORTFOLIOSTOCKID=V_STOCKID AND V_BUYQUANTITY<V_SELLQUANTITY then
			 		INSERT INTO `stockdb`.`macdcrossover` (`stockid`,`shortperiod`, `longperiod`,`signalperiod`,`timeframeid`,`status`,`createdate`,`sequence`) VALUES (V_STOCKID, 12, 26,9,1, 'U',now(), V_SEQUENCE);
					SET P_OUTPUT= concat('Exit From the position',P_STOCKCODE,'buy back this stock');
                 ELSEIF V_WATCHLISTSTOCKID=V_STOCKID then
				 	INSERT INTO `stockdb`.`macdcrossover` (`stockid`,`shortperiod`, `longperiod`,`signalperiod`,`timeframeid`,`status`,`createdate`,`sequence`) VALUES (V_STOCKID, 12, 26,9,1, 'U',now(), V_SEQUENCE);
                    SET P_OUTPUT= concat('The stock with symbol in your watchlist ',P_STOCKCODE,'upside macd crossover ');
				 ELSEIF	V_STATUS='D' THEN
					INSERT INTO `stockdb`.`macdcrossover` (`stockid`,`shortperiod`, `longperiod`,`signalperiod`,`timeframeid`,`status`,`createdate`,`sequence`) VALUES (V_STOCKID, 12, 26,9,1, 'C',now(), V_SEQUENCE);
					SET P_OUTPUT= concat('The stock with symbol ',P_STOCKCODE,'has reversed from down to up exit if bought ');
                ELSE   
					IF  V_PCHANGE>0 AND abs(V_PCHANGE) >= 2.5 THEN
					INSERT INTO `stockdb`.`macdcrossover` (`stockid`,`shortperiod`, `longperiod`,`signalperiod`,`timeframeid`,`status`,`createdate`,`sequence`) VALUES (V_STOCKID, 12, 26,9,1, 'U',now(), V_SEQUENCE);
					SET P_OUTPUT= concat('The stock with symbol ',P_STOCKCODE,'upside macd crossover ');
                    END IF;
			 END IF;   
           END IF; 
           
	elseif V_MACDVAL < V_MACD_EMAVAL  then
		IF V_STATUS is null OR V_STATUS='U' THEN
			IF  V_PORTFOLIOSTOCKID=V_STOCKID AND V_BUYQUANTITY>V_SELLQUANTITY then
					INSERT INTO `stockdb`.`macdcrossover` (`stockid`,`shortperiod`, `longperiod`,`signalperiod`,`timeframeid`,`status`,`createdate`,`sequence`) VALUES (V_STOCKID, 12, 26,9,1, 'D',now(), V_SEQUENCE);
					SET P_OUTPUT= concat('Exit From the position',P_STOCKCODE,'sell out this stock');
                ELSEIF V_WATCHLISTSTOCKID=V_STOCKID then
					INSERT INTO `stockdb`.`macdcrossover` (`stockid`,`shortperiod`, `longperiod`,`signalperiod`,`timeframeid`,`status`,`createdate`,`sequence`) VALUES (V_STOCKID, 12, 26,9,1, 'D',now(), V_SEQUENCE);
                    SET P_OUTPUT= concat('The stock with symbol in your watchlist ',P_STOCKCODE,'downside macd crossover ');    
				ELSEIF	V_STATUS='U' THEN
					INSERT INTO `stockdb`.`macdcrossover` (`stockid`,`shortperiod`, `longperiod`,`signalperiod`,`timeframeid`,`status`,`createdate`,`sequence`) VALUES (V_STOCKID, 12, 26,9,1, 'C',now(), V_SEQUENCE);
					SET P_OUTPUT= concat('The stock with symbol ',P_STOCKCODE,'has reversed from up to down exit if sold ');
                ELSE   
					IF  V_PCHANGE<0  AND abs(V_PCHANGE) >= 2.5 THEN
					INSERT INTO `stockdb`.`macdcrossover` (`stockid`,`shortperiod`, `longperiod`,`signalperiod`,`timeframeid`,`status`,`createdate`,`sequence`) VALUES (V_STOCKID, 12, 26,9,1, 'D',now(), V_SEQUENCE);
				    SET P_OUTPUT= concat('The stock with symbol ',P_STOCKCODE,'downside macd crossover ');
                    END IF;
				END IF;        
			END IF;
        
        END IF;
     END IF;
END IF;     
       
END IF;       
	ROLLBACK;
END;
	
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `PROCEDURE_POPULATE_ATR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `PROCEDURE_POPULATE_ATR`(
IN P_STOCKID INT,
IN P_PERIOD INT,
IN P_TIMEFRAMEID INT,
OUT errorCode int
)
BEGIN

 DECLARE V_SEQUENCE,V_LASTATRSEQUENCE INT DEFAULT 0;	
 
 DECLARE done INT DEFAULT FALSE;

 DECLARE cur1 CURSOR FOR SELECT ticksequence from stockdb_demo.tickdata t inner join stockdb_demo.stocktimeframe st on t.timeframeid=st.timeframeid  where stockid=P_STOCKID and t.timeframeid=P_TIMEFRAMEID;  

 DECLARE cur2 CURSOR FOR SELECT ticksequence from stockdb_demo.tickdata t inner join stockdb_demo.stocktimeframe st on t.timeframeid=st.timeframeid  where stockid=P_STOCKID and t.timeframeid=P_TIMEFRAMEID and sequence >( SELECT max(a.sequence)  FROM stockdb_demo.atr a where a.stockid=P_STOCKID and period=P_PERIOD and timeframeid=P_TIMEFRAMEID)+P_PERIOD;  

BEGIN
 DECLARE EXIT HANDLER FOR SQLEXCEPTION SET errorCode = 1;
 
 DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
 
 

SELECT max(a.sequence) into V_LASTATRSEQUENCE FROM stockdb_demo.atr a where a.stockid=P_STOCKID and period=P_PERIOD and timeframeid=P_TIMEFRAMEID;


IF V_LASTATRSEQUENCE>0 THEN
		 OPEN cur2;
		read_loop: LOOP
		  FETCH cur2 INTO V_SEQUENCE;
			IF done THEN
			  LEAVE read_loop;
			END IF;
			CALL PROCEDURE_ATR(P_STOCKID,P_PERIOD,P_TIMEFRAMEID,V_SEQUENCE);
	   END LOOP;
	  CLOSE cur2;

ELSE     
 OPEN cur1;
    read_loop: LOOP
      FETCH cur1 INTO V_SEQUENCE;
        IF done THEN
          LEAVE read_loop;
        END IF;
        if V_SEQUENCE>1 then
		CALL PROCEDURE_ATR(P_STOCKID,P_PERIOD,P_TIMEFRAMEID,V_SEQUENCE);
        end if;
   END LOOP;
  CLOSE cur1;
END IF;  
ROLLBACK;
END;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `PROCEDURE_POPULATE_EMA_MACD` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `PROCEDURE_POPULATE_EMA_MACD`(
IN P_STOCKID INT,
IN P_SHORTPERIOD INT,
IN P_LONGPERIOD INT,
IN P_TIMEFRAMEID INT,
IN P_INDEX INT,
OUT errorCode int
)
BEGIN

DECLARE V_SMA DECIMAL(16,2) DEFAULT 0.0;
DECLARE V_MULTIPLIER  DECIMAL(16,2) DEFAULT 0.0;
DECLARE V_LASTMACD DECIMAL(16,2)  DEFAULT 0.0;
DECLARE V_LASTDATE datetime;

DECLARE V_TEMPEMA DECIMAL(16,2) DEFAULT 0.0;
DECLARE V_SHORTEMASEQUENCE,V_LONGEMASEQUENCE,V_SEQUENCE,V_EMAID,V_MACDID INT;
DECLARE V_MACDSEQUENCE,V_EMASEQUENCE,V_LASTMACDSEQUENCE INT DEFAULT 0;
DECLARE V_SHORTEMAVAL,V_LONGEMAVAL DECIMAL(16,2) DEFAULT 0.0;
DECLARE ema DECIMAL(16,2); 

DECLARE V_SHORTEMAVALUE,V_LONGEMAVALUE DECIMAL(16,2)  DEFAULT 0.0;




DECLARE done INT DEFAULT FALSE;


DECLARE cur1 CURSOR FOR select sequence from ema e inner join stockemamapping se on se.emaid=e.emaid where se.stockid=P_STOCKID and period=P_SHORTPERIOD and timeframeid=P_TIMEFRAMEID;
DECLARE cur2 CURSOR FOR select sequence from ema e inner join stockemamapping se on se.emaid=e.emaid where se.stockid=P_STOCKID and period=P_SHORTPERIOD and timeframeid=P_TIMEFRAMEID and sequence >(select max(sequence) from macd m inner join macdemamapping me on m.macdid=me.macdid where m.shortperiod=P_SHORTPERIOD and m.longperiod=P_LONGPERIOD  and m.stockid=P_STOCKID)+P_LONGPERIOD;

BEGIN
 DECLARE EXIT HANDLER FOR SQLEXCEPTION SET errorCode = 1;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=TRUE;

SELECT max(e.sequence) INTO V_SHORTEMASEQUENCE   FROM ema e inner join stockemamapping se on se.emaid=e.emaid where se.stockid=P_STOCKID and period=P_SHORTPERIOD and timeframeid=P_TIMEFRAMEID ;
SELECT max(e.sequence) INTO V_LONGEMASEQUENCE  FROM ema e inner join stockemamapping se on se.emaid=e.emaid where se.stockid=P_STOCKID and period=P_LONGPERIOD and timeframeid=P_TIMEFRAMEID;

SELECT (select max(sequence) from macd m inner join macdemamapping me on m.macdid=me.macdid where m.shortperiod=P_SHORTPERIOD and m.longperiod=P_LONGPERIOD  and m.stockid=P_STOCKID) INTO V_LASTMACDSEQUENCE;


IF V_LASTMACDSEQUENCE>0 THEN

  SELECT e.emavalue INTO V_SHORTEMAVALUE   FROM ema e inner join stockemamapping se on se.emaid=e.emaid where se.stockid=P_STOCKID and period=P_SHORTPERIOD and timeframeid=P_TIMEFRAMEID and time(e.createdate)=time(se.createdate) group by sequence having sequence= V_SHORTEMASEQUENCE;
  SELECT e.emavalue,e.createdate INTO V_LONGEMAVALUE,V_LASTDATE   FROM ema e inner join stockemamapping se on se.emaid=e.emaid where se.stockid=P_STOCKID and period=P_LONGPERIOD and timeframeid=P_TIMEFRAMEID and time(e.createdate)=time(se.createdate)  group by sequence having sequence= V_LONGEMASEQUENCE;
  CALL `stockdb`.`PROCEDURE_MACD`(P_STOCKID,P_SHORTPERIOD,P_LONGPERIOD,V_SHORTEMASEQUENCE,V_LONGEMASEQUENCE,V_SHORTEMAVALUE,V_LONGEMAVALUE,V_LASTDATE, P_TIMEFRAMEID, P_INDEX, P_INDEX);
	OPEN cur2;
    read_loop: LOOP
      FETCH cur2 INTO V_SEQUENCE;

		IF done THEN
          LEAVE read_loop;
        END IF;
		if(V_LASTMACDSEQUENCE=V_SEQUENCE) then
				SET V_SHORTEMASEQUENCE=V_SEQUENCE;
				SET V_LONGEMASEQUENCE=V_SEQUENCE-P_LONGPERIOD;
            ELSE
				SET V_SHORTEMASEQUENCE=V_SHORTEMASEQUENCE+1;
				SET V_LONGEMASEQUENCE=V_LONGEMASEQUENCE+1;
		end if;
            
       
			
			
            
			
			
            SELECT e.emavalue INTO V_SHORTEMAVALUE   FROM ema e inner join stockemamapping se on se.emaid=e.emaid where se.stockid=P_STOCKID and period=P_SHORTPERIOD and timeframeid=P_TIMEFRAMEID  group by sequence having sequence= V_SHORTEMASEQUENCE;

			SELECT e.emavalue,e.createdate INTO V_LONGEMAVALUE,V_LASTDATE   FROM ema e inner join stockemamapping se on se.emaid=e.emaid where se.stockid=P_STOCKID and period=P_LONGPERIOD and timeframeid=P_TIMEFRAMEID  group by sequence having sequence= V_LONGEMASEQUENCE;

			

			CALL `stockdb`.`PROCEDURE_MACD`(P_STOCKID,P_SHORTPERIOD,P_LONGPERIOD,V_SHORTEMASEQUENCE,V_LONGEMASEQUENCE,V_SHORTEMAVALUE,V_LONGEMAVALUE,V_LASTDATE, P_TIMEFRAMEID, P_INDEX, P_INDEX);

	
   
   END LOOP;
CLOSE cur2;


ELSE
OPEN cur1;
    read_loop: LOOP
      FETCH cur1 INTO V_SEQUENCE;

		IF done THEN
			LEAVE read_loop;
		end if;
			
		IF 	V_SEQUENCE > (P_LONGPERIOD-P_SHORTPERIOD) THEN
        

			IF V_SEQUENCE=(P_LONGPERIOD-P_SHORTPERIOD)+1 THEN
			SET V_SHORTEMASEQUENCE=V_SEQUENCE;
            SET V_LONGEMASEQUENCE=V_SEQUENCE/P_LONGPERIOD;
			ELSE
			SET V_SHORTEMASEQUENCE=V_SHORTEMASEQUENCE+1;
			SET V_LONGEMASEQUENCE=V_LONGEMASEQUENCE+1;
            END IF;
            
            SELECT e.emavalue INTO V_SHORTEMAVALUE   FROM ema e inner join stockemamapping se on se.emaid=e.emaid where se.stockid=P_STOCKID and period=P_SHORTPERIOD and timeframeid=P_TIMEFRAMEID and time(e.createdate)=time(se.createdate)  group by sequence having sequence= V_SHORTEMASEQUENCE;

			SELECT e.emavalue,e.createdate INTO V_LONGEMAVALUE,V_LASTDATE   FROM ema e inner join stockemamapping se on se.emaid=e.emaid where se.stockid=P_STOCKID and period=P_LONGPERIOD and timeframeid=P_TIMEFRAMEID and time(e.createdate)=time(se.createdate) group by sequence having sequence= V_LONGEMASEQUENCE;

			

			CALL `stockdb`.`PROCEDURE_MACD`(P_STOCKID,P_SHORTPERIOD,P_LONGPERIOD,V_SHORTEMASEQUENCE,V_LONGEMASEQUENCE,V_SHORTEMAVALUE,V_LONGEMAVALUE,V_LASTDATE, P_TIMEFRAMEID, P_INDEX, P_INDEX);

		
        END IF;
        
   
   END LOOP;
CLOSE cur1;

END IF;

ROLLBACK;
END;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `PROCEDURE_PORTFOLIO_INSERT` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `PROCEDURE_PORTFOLIO_INSERT`(
IN name VARCHAR(200),
IN createid int,
in currencyid int,
in trackportfolio varchar(200),
out portfolioid int
)
BEGIN

insert into portfolio(name,createid,currencyid,createdate,updatedate,trackportfolio)values(name,createid,currencyid,now(),now(),trackportfolio);
set portfolioid=LAST_INSERT_ID();


END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `PROCEDURE_SELECT_STOCKDETAILS` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `PROCEDURE_SELECT_STOCKDETAILS`(
IN P_STOCKNAME VARCHAR(200),
OUT errorCode int
)
BEGIN

	declare V_SELECTCRITERIA INT DEFAULT 0;
    DECLARE V_STOCKID INT DEFAULT 0;
	DECLARE V_EXCHANGE VARCHAR(20);
   
    
    DECLARE STR1 VARCHAR(100);
	DECLARE STR2 VARCHAR(100);
    DECLARE STR3 VARCHAR(100);

BEGIN
 DECLARE EXIT HANDLER FOR SQLEXCEPTION SET errorCode = 1;

   SET STR1= SUBSTRING_INDEX(P_STOCKNAME, ' ', 1);
   SET STR2=SUBSTRING_INDEX(SUBSTRING_INDEX(P_STOCKNAME,' ', 2), ' ',-1);
   SET STR3=SUBSTRING_INDEX(P_STOCKNAME, ' ', -1);
   
   SET STR2=SUBSTRING(STR2,1,3);
   SET STR3=SUBSTRING(STR3,1,3);
   SELECT STR1,STR2,STR3;

	select s.stockid,s.code,s.name stockname,g.name stockgroupname,s.leverage,s.createdate,s.updatedate,s.sectorid,se.name as sectorname from stockdetails s left outer join stockgroup g on g.code=s.groupid left outer join  sector se on se.sectorid=s.sectorid where s.name=P_STOCKNAME or (s.name LIKE CONCAT('%',STR1,'%') and LENGTH(STR1)>1 and s.name LIKE CONCAT('%',STR2,'%') and LENGTH(STR2)>1 and  s.name LIKE CONCAT('%',STR3,'%') and LENGTH(STR3)>1) or s.code LIKE CONCAT('%',REPLACE(TRIM(P_STOCKNAME), ' ', ''),'%');
  ROLLBACK;
END;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `PROCEDURE_SQUAREOFF_UNSETTLED` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `PROCEDURE_SQUAREOFF_UNSETTLED`(
IN P_PORTFOLIOID INT,
in P_STOCKID int,
in P_AMOUNT decimal(16,2),
in P_USERID int,
OUT errorCode int
)
BEGIN
DECLARE V_SETTLEDCOUNT,V_UNSETTLEDCOUNT INT DEFAULT 0;
DECLARE V_TOTSETTLEDCOUNT,V_TOTUNSETTLEDCOUNT INT DEFAULT 0;
DECLARE V_BUYCOUNT,V_SELLCOUNT INT DEFAULT 0;
DECLARE V_AVGBUY,V_AVGSELL,V_STOPLOSS INT DEFAULT 0;
DECLARE V_TRANTYPE INT DEFAULT 2;
DECLARE V_STOCKID INT default 0;
DECLARE V_TRANID1,V_TRANID2,V_STRATEGYID INT default 0;


DECLARE done INT DEFAULT FALSE;

 
  DECLARE cur1 CURSOR for select distinct t.stockid  from portfoliotranmapping pt inner join 
    transaction t on t.transactionid=pt.transactionid 
    where pt.portfolioid=P_PORTFOLIOID;
    
 BEGIN
 DECLARE EXIT HANDLER FOR SQLEXCEPTION SET errorCode = 1;
 
    select sum(t.quantity),sum(t.price)/sum(t.quantity),t.transactionid INTO V_BUYCOUNT,V_AVGBUY,V_TRANID1 from portfoliotranmapping pt inner join transaction t on pt.transactionid=t.transactionid where pt.portfolioid=P_PORTFOLIOID and t.stockid=P_STOCKID and t.transactiontypeid=1 and t.holdingtypeid=2;
	select sum(t.quantity) ,sum(t.price)/sum(t.quantity),t.transactionid INTO V_SELLCOUNT,V_AVGSELL,V_TRANID2 from portfoliotranmapping pt inner join transaction t on pt.transactionid=t.transactionid where pt.portfolioid=P_PORTFOLIOID and t.stockid=P_STOCKID and t.transactiontypeid=2 and t.holdingtypeid=2;
	
    set V_TRANID1 = coalesce(V_TRANID1,0);
	set V_TRANID2 = coalesce(V_TRANID2,0);
    
    if V_TRANID1>0 then
        SELECT ts.strategyid into V_STRATEGYID from transactionstrategymapping ts where ts.transactionid=V_TRANID1;
    end if;
    if V_TRANID2>0 then 
	    SELECT ts.strategyid into V_STRATEGYID from transactionstrategymapping ts where ts.transactionid=V_TRANID2;
    end if;
    
    
    
	set V_BUYCOUNT = coalesce(V_BUYCOUNT,0);
	set V_SELLCOUNT = coalesce(V_SELLCOUNT,0);
	set V_AVGBUY = coalesce(V_AVGBUY,0);
	set V_AVGSELL = coalesce(V_AVGSELL,0);


     
	 SET V_UNSETTLEDCOUNT=ABS(V_BUYCOUNT-V_SELLCOUNT);
	 set V_SETTLEDCOUNT=least(V_BUYCOUNT,V_SELLCOUNT);
     
     if V_UNSETTLEDCOUNT>0 then 
		 IF V_BUYCOUNT >0 THEN
		 SET V_TRANTYPE=2;
			IF P_AMOUNT=0 THEN
			select sum(t.stoploss)*sum(t.quantity)/sum(t.quantity) INTO P_AMOUNT from portfoliotranmapping pt inner join transaction t on pt.transactionid=t.transactionid where pt.portfolioid=P_PORTFOLIOID and t.stockid=P_STOCKID and t.transactiontypeid=1 and t.holdingtypeid=2;
			END IF;
         ELSE
		 SET V_TRANTYPE=1;
			IF P_AMOUNT=0 THEN
			select sum(t.stoploss)*sum(t.quantity)/sum(t.quantity) INTO P_AMOUNT from portfoliotranmapping pt inner join transaction t on pt.transactionid=t.transactionid where pt.portfolioid=P_PORTFOLIOID and t.stockid=P_STOCKID and t.transactiontypeid=2 and t.holdingtypeid=2;
            END IF;
		 END IF;
		 CALL `stockdb`.`PROCEDURE_INSERTTRANSACTIONDATA`(P_STOCKID, 2, V_TRANTYPE, V_UNSETTLEDCOUNT, P_AMOUNT,0, P_USERID,P_PORTFOLIOID, V_STRATEGYID, null, @tranId, @errorCode);
	 end if;	
 ROLLBACK;
END;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `PROCEDURE_TOPTEN_STRATEGIES` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `PROCEDURE_TOPTEN_STRATEGIES`(
IN P_STRATEGYID INT,
IN P_USERID INT,
IN P_FROMDATE datetime,
IN P_TODATE datetime,
OUT P_STOCKCOUNT INT,
OUT P_PROFIT decimal(16,2),
OUT P_NUMBEROFGAIN INT,
OUT P_NUMBEROFLOSS INT,
OUT P_NUMBEROFUNSETTLED INT,
OUT errorCode INT

)
BEGIN

DECLARE V_STOCKCOUNT INT DEFAULT 0;
DECLARE V_STOCKID INT DEFAULT 0;
DECLARE V_SETTLEDCOUNT,V_UNSETTLEDCOUNT INT DEFAULT 0;
DECLARE V_TOTSETTLEDCOUNT,V_TOTUNSETTLEDCOUNT INT DEFAULT 0;
DECLARE V_BUYCOUNT,V_SELLCOUNT INT DEFAULT 0;
DECLARE V_AVGBUY,V_AVGSELL DECIMAL(16,2) DEFAULT 0;
DECLARE V_NUMGAIN,V_NUMLOSS INT DEFAULT 0;
DECLARE V_PROFIT,V_LOSS DECIMAL(16,2) DEFAULT 0;
DECLARE V_TOTPROFIT,V_TOTLOSS DECIMAL(16,2) DEFAULT 0;
DECLARE done INT DEFAULT FALSE;	
 

 DECLARE cur1 CURSOR FOR SELECT distinct t.stockid from portfoliotranmapping pt inner join  transaction t on pt.transactionid=t.transactionid 
 inner join transactionstrategymapping ts on ts.transactionid=t.transactionid
 where t.createid=P_USERID and ts.strategyid=P_STRATEGYID and t.createdate between P_FROMDATE and P_TODATE;
 BEGIN
 DECLARE EXIT HANDLER FOR SQLEXCEPTION SET errorCode = 1;
 
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
  
 SELECT count(distinct t.stockid) INTO V_STOCKCOUNT from portfoliotranmapping pt inner join  transaction t on pt.transactionid=t.transactionid 
 inner join transactionstrategymapping ts on ts.transactionid=t.transactionid
 where t.createid=P_USERID and ts.strategyid=P_STRATEGYID and t.createdate between P_FROMDATE and P_TODATE;

  OPEN cur1;
    read_loop: LOOP
      FETCH cur1 INTO V_STOCKID;
        IF done THEN
          LEAVE read_loop;
        END IF;
        
		select sum(t.quantity),sum(t.quantity*t.price)/sum(t.quantity) INTO V_BUYCOUNT,V_AVGBUY from  transaction t  where  t.stockid=V_STOCKID and t.transactiontypeid=1;
        select sum(t.quantity) ,sum(t.quantity*t.price)/sum(t.quantity) INTO V_SELLCOUNT,V_AVGSELL from  transaction t   where  t.stockid=V_STOCKID and t.transactiontypeid=2;
		
        set V_BUYCOUNT = coalesce(V_BUYCOUNT,0);
		set V_SELLCOUNT = coalesce(V_SELLCOUNT,0);
		set V_AVGBUY = coalesce(V_AVGBUY,0);
		set V_AVGSELL = coalesce(V_AVGSELL,0);

        
        
        SET V_UNSETTLEDCOUNT=ABS(V_BUYCOUNT-V_SELLCOUNT);
		set V_SETTLEDCOUNT=least(V_BUYCOUNT,V_SELLCOUNT);
        IF V_UNSETTLEDCOUNT>0 THEN
         SET V_TOTUNSETTLEDCOUNT=V_TOTUNSETTLEDCOUNT+1;
        ELSE
         SET V_TOTSETTLEDCOUNT=V_TOTSETTLEDCOUNT+1;
         END IF;
		
        IF V_AVGBUY>=V_AVGSELL then
		SET V_PROFIT= V_SETTLEDCOUNT*(V_AVGBUY-V_AVGSELL); 
        SET V_NUMGAIN=V_NUMGAIN+1;
        SET V_TOTPROFIT=V_TOTPROFIT+V_PROFIT;
        ELSE
        SET V_LOSS=V_SETTLEDCOUNT*(V_AVGSELL-V_AVGBUY);
        SET V_NUMLOSS=V_NUMLOSS+1;
        SET V_TOTLOSS=V_TOTLOSS+V_LOSS;
		END IF;	
        SET V_PROFIT=0;
        SET V_LOSS=0;
		SET V_SETTLEDCOUNT=0;
        SET V_UNSETTLEDCOUNT=0;
   
   END LOOP;
		set P_NUMBEROFUNSETTLED=V_TOTUNSETTLEDCOUNT;
		set P_STOCKCOUNT=V_STOCKCOUNT;
		set P_NUMBEROFGAIN=V_NUMGAIN;
		set P_NUMBEROFLOSS=V_NUMLOSS;
		set P_PROFIT=V_TOTPROFIT-V_TOTLOSS;
		

  CLOSE cur1;
 ROLLBACK;
END;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `PROCEDURE_USER_DETAILS` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `PROCEDURE_USER_DETAILS`(
IN P_USERID INT,
OUT V_BALANCE DECIMAL(16,2) ,
OUT V_MODE_BALANCE DECIMAL(16,2) ,
OUT V_MARGINUSED DECIMAL(16,2),
OUT V_TOTALPROFIT DECIMAL(16,2),
OUT errorCode INT
)
BEGIN
 BEGIN
 DECLARE EXIT HANDLER FOR SQLEXCEPTION SET errorCode = 1;
 
    SELECT amount,modeamount INTO V_BALANCE,V_MODE_BALANCE FROM balance where userid=P_USERID;
    select IFNULL(sum(quantity*price), 0) into V_MARGINUSED from transaction t
	inner join portfoliotranmapping pt on pt.transactionid=t.transactionid
	inner join portfolio p on p.portfolioid=pt.portfolioid where p.name='CURRENT HOLDING' and t.createid=P_USERID;
	select amount into V_TOTALPROFIT from profitbalance where userid=P_USERID;
     ROLLBACK;
END;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `PROCEDURE_USER_INSERT` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `PROCEDURE_USER_INSERT`(
IN P_FIRSTNAME VARCHAR(100),
IN P_LASTNAME VARCHAR(100),
IN P_EMAIL VARCHAR(100),
IN P_ADDRESS VARCHAR(100),
IN P_PHONE VARCHAR(100),
IN P_PASSWORD VARCHAR(100),
OUT errorCode INT
)
BEGIN

DECLARE V_USERID INT DEFAULT 0;
DECLARE V_PORTFOLIOID INT DEFAULT 0;
DECLARE V_ERROR INT DEFAULT 0;

  BEGIN
 DECLARE EXIT HANDLER FOR SQLEXCEPTION SET errorCode = 1;
 

INSERT INTO userinternal (firstname, lastname, password, email, phone, address) VALUES ( P_FIRSTNAME, P_LASTNAME,P_PASSWORD, P_EMAIL, P_PHONE,P_ADDRESS);

SET V_USERID=LAST_INSERT_ID();

INSERT INTO balance (userid, amount, modeamount, createdate, updatedate) VALUES ( V_USERID, 0,0, now(), now()); 
INSERT INTO profitbalance (userid, timeframid, amount, updatedate) VALUES ( V_USERID, 5, 0, now());

insert into portfolio(name,currencyid,createid,createdate,updatedate,trackportfolio) values('CURRENT HOLDING',1,V_USERID,now(),now(),'on');

SET V_PORTFOLIOID=LAST_INSERT_ID();

call PROCEDURE_INSERTORMODIFYPORTFOLIOATTR(V_PORTFOLIOID, 1, 10, errorCode);
call PROCEDURE_INSERTORMODIFYPORTFOLIOATTR(V_PORTFOLIOID, 2, 20, errorCode);
call PROCEDURE_INSERTORMODIFYPORTFOLIOATTR(V_PORTFOLIOID, 3, 30, errorCode);

INSERT INTO tradingmodes (modename, description,userid) VALUES ('INTRADAY','resolved in a day',V_USERID);
INSERT INTO tradingmodes (modename, description,userid) VALUES ('SWING','this resolved in month',V_USERID);
INSERT INTO tradingmodes (modename, description,userid) VALUES ('LONG TERM','resolved in a year',V_USERID);

 ROLLBACK;
END;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UPDATE_STOCKDETAILS_INTERVALS` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `UPDATE_STOCKDETAILS_INTERVALS`(
IN P_STOCKCODE VARCHAR(50),
IN P_STOCKPRICE DECIMAL(10,2),
IN P_PCHANGE  DECIMAL(10,2),
IN P_TIMEFRAMEID INT,
OUT P_OUTPUT VARCHAR(300),
OUT errorCode INT
)
BEGIN
declare V_STOCKID INT default 0;
declare V_HIGH INT default 0;
declare V_LOW INT default 0;
declare V_CREATEDATE INT default 0;
declare V_SEQUENCE INT default 0;
declare V_THREE_PCHANGE,V_SIX_PCHANGE,V_NINE_PCHANGE DECIMAL(10,2) default 0;
DECLARE V_SHORTEMAVALUE,V_LONGEMAVALUE,V_LASTPRICE DECIMAL(16,2)  DEFAULT 0.0;
DECLARE V_LASTDATE datetime;
DECLARE V_SHORTEMASEQUENCE,V_LONGEMASEQUENCE INT DEFAULT 0;

 BEGIN
 DECLARE EXIT HANDLER FOR SQLEXCEPTION SET errorCode = 1;
 


SELECT stockid into V_STOCKID from stockdetails where code=P_STOCKCODE;


if V_STOCKID <> 0 THEN


select max(ticksequence) into V_SEQUENCE from tickdata t  inner join stocktimeframe st on t.timeframeid=st.timeframeid  where stockid=V_STOCKID and  st.timeframeid=P_TIMEFRAMEID; 


SELECT V_SEQUENCE;



IF V_SEQUENCE IS NULL THEN
SET V_SEQUENCE=1;
ELSE 
SET V_SEQUENCE=V_SEQUENCE+1;
END IF;


insert into tickdata values(V_STOCKID,now(),P_STOCKPRICE,P_STOCKPRICE,P_STOCKPRICE,P_STOCKPRICE,P_STOCKPRICE,P_STOCKPRICE,V_SEQUENCE,P_TIMEFRAMEID);





select high into V_HIGH from dailyhighlow where stockid=V_STOCKID;
select low into V_LOW from dailyhighlow where stockid=V_STOCKID;
select createdate into V_CREATEDATE from dailyhighlow where stockid=V_STOCKID;


	if V_HIGH =0 and V_LOW=0 then 
		INSERT INTO `stockdb`.`dailyhighlow`
							(`stockid`,
							`high`,
							`low`,
							`open`,
							`close`,
                            `pchange`,
							`createdate`,
							`updatedate`)
							VALUES
							(V_STOCKID,
							P_STOCKPRICE,
							P_STOCKPRICE,
							P_STOCKPRICE,
							P_STOCKPRICE,
                            P_PCHANGE,
							now(),
							now());
      else
		if V_CREATEDATE<> curdate() then
				UPDATE `stockdb`.`dailyhighlow`
					SET
					`high` = P_STOCKPRICE,
					`low` = P_STOCKPRICE,
                    `pchange` = P_PCHANGE,
					`updatedate` = now()
					WHERE `stockid` = V_STOCKID;
                
         else       
			 if P_STOCKPRICE>V_HIGH then
				UPDATE `stockdb`.`dailyhighlow`
					SET
					`high` = P_STOCKPRICE,
                    `pchange` = P_PCHANGE,
					`updatedate` = now()
					WHERE `stockid` = V_STOCKID;
			 END IF;       
			 if P_STOCKPRICE<V_LOW then
				UPDATE `stockdb`.`dailyhighlow`
					SET
					`low` = P_STOCKPRICE,
                    `pchange` = P_PCHANGE,
					`updatedate` = now()
					WHERE `stockid` = V_STOCKID;
			 END IF;    
         end if;
        
	  END IF;  

if V_SEQUENCE>12 then
call PROCEDURE_EMA(V_STOCKID,12,P_TIMEFRAMEID,V_SEQUENCE);
end if;
if V_SEQUENCE>26 then		
call PROCEDURE_EMA(V_STOCKID,26,P_TIMEFRAMEID,V_SEQUENCE);	


            SELECT e.sequence,e.emavalue INTO V_SHORTEMASEQUENCE,V_SHORTEMAVALUE   FROM ema e inner join stockemamapping se on se.emaid=e.emaid inner join stocktimeframe st on e.timeframeid=st.timeframeid  where se.stockid=V_STOCKID and e.period=12 and st.timeframeid=1   group by sequence having sequence= (select max(sequence) from ema e inner join stockemamapping se on se.emaid=e.emaid inner join stocktimeframe st on e.timeframeid=st.timeframeid  where se.stockid=V_STOCKID and e.period=12 and st.timeframeid=1);
			SELECT e.sequence,e.emavalue,e.createdate INTO V_LONGEMASEQUENCE,V_LONGEMAVALUE,V_LASTDATE   FROM ema e inner join stockemamapping se on se.emaid=e.emaid inner join stocktimeframe st on e.timeframeid=st.timeframeid  where se.stockid=V_STOCKID and e.period=26 and st.timeframeid=1   group by sequence having sequence= (select max(sequence) from ema e inner join stockemamapping se on se.emaid=e.emaid inner join stocktimeframe st on e.timeframeid=st.timeframeid  where se.stockid=V_STOCKID and e.period=26 and st.timeframeid=1);
            
           
			CALL `stockdb`.`PROCEDURE_MACD`(V_STOCKID,12,26,V_SHORTEMASEQUENCE,V_LONGEMASEQUENCE,V_SHORTEMAVALUE,V_LONGEMAVALUE,V_LASTDATE, 1, 9, 9);


end if;


END IF;

 ROLLBACK;
END;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2018-04-05 10:06:25

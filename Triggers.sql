-- This triger insert the entry in Payments Accounting and Charges Detail New

drop trigger if Exists TR_PAYMENT_SENT;
DELIMITER $$
CREATE TRIGGER `TR_PAYMENT_SENT` AFTER INSERT ON `payment_sent` FOR EACH ROW BEGIN

	-- INSERT RECORD INTO PAYMENTS, RECEIPTS AND CHARGES TABLE
	CASE
	   WHEN NEW.IS_VENDOR = 'Y' THEN
		   -- INSERT RECORD INTO PAYMENTS TABLE
		   INSERT INTO PAYMENTS_DETAIL_NEW (VENDOR_ID, FORM_ID, FORM_F_ID, FORM_TRANSACTION_ID, FORM_AMOUNT, FORM_FLAG, COMPANY_ID)
		   SELECT NEW.VENDOR_ID, NEW.ID, NEW.PAYMENT_SENT_ID, NEW.PAYPAL_TRANSACTION_ID, (-1 * NEW.AMOUNT), 'P', NEW.COMPANY_ID FROM DUAL;
		   
	   WHEN NEW.IS_VENDOR = 'N' THEN
		   -- INSERT RECORD INTO RECEIPTS TABLE
		   INSERT INTO RECEIPTS_DETAIL_NEW (CUSTOMER_ID, FORM_ID, FORM_F_ID, FORM_TRANSACTION_ID, FORM_AMOUNT, FORM_FLAG, COMPANY_ID)
		   SELECT NEW.CUSTOMER_ID, NEW.ID, NEW.PAYMENT_SENT_ID, NEW.PAYPAL_TRANSACTION_ID, NEW.AMOUNT, 'P', NEW.COMPANY_ID FROM DUAL;
           
	   WHEN NEW.IS_VENDOR = 'R' THEN
		   -- INSERT RECORD INTO CHARGES TABLE
		   INSERT INTO CHARGES_DETAIL_NEW (REP_COM_ID, FORM_ID, FORM_F_ID, FORM_TRANSACTION_ID, FORM_AMOUNT, FORM_FLAG, COMPANY_ID)
		   SELECT NEW.REP_COM_ID, NEW.ID, NEW.PAYMENT_SENT_ID, NEW.PAYPAL_TRANSACTION_ID, (-1 * NEW.AMOUNT), 'P', NEW.COMPANY_ID FROM DUAL;
	END CASE;

	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	INSERT INTO PAYMENT_SENT_ACCOUNT_DETAIL (PS_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ID, 15, NEW.AMOUNT, NEW.CASH_ACC_ID, NEW.PS_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);


	/*NEW VERSION*/
		CASE
			WHEN NEW.IS_VENDOR = 'Y' THEN -- Payment Sent to Vendors
				INSERT INTO Payments_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ID, 15, case when NEW.AMOUNT<0 then New.Amount*-1 else New.Amount end, NEW.CASH_ACC_ID, NEW.PS_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'PaymentSent');
			WHEN NEW.IS_VENDOR = 'N' THEN -- Payment Sent to Customer	
				INSERT INTO Payments_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ID, 15, case when NEW.AMOUNT<0 then New.Amount*-1 else New.Amount end, NEW.CASH_ACC_ID, NEW.PS_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'PaymentSent');
			WHEN NEW.IS_VENDOR = 'R' THEN -- Payment Sent to Repair Company	
				INSERT INTO Payments_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ID, 15, case when NEW.AMOUNT<0 then New.Amount*-1 else New.Amount end, NEW.CASH_ACC_ID, NEW.PS_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'PaymentSent');
		end case;
	/*NEW VERSION*/





	
END $$
DELIMITER ;

-- This Trigger Deletes the entry from payment sent and insert the new entry 

drop trigger if Exists TR_PAYMENT_SENT_UPT;
DELIMITER $$
CREATE TRIGGER `TR_PAYMENT_SENT_UPT` AFTER UPDATE ON `payment_sent` FOR EACH ROW BEGIN

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM PAYMENT_SENT_ACCOUNT_DETAIL WHERE PS_ID = OLD.ID AND PS_DETAIL_ID IS NULL;
	
	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	INSERT INTO PAYMENT_SENT_ACCOUNT_DETAIL (PS_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ID, 15, NEW.AMOUNT, NEW.CASH_ACC_ID, NEW.PS_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);


	/*NEW VERSION*/
		DELETE FROM Payments_Accounting WHERE Form_ID = OLD.ID AND Form_DETAIL_ID IS NULL and Form_Flag='PaymentSent';
		CASE
		   WHEN NEW.IS_VENDOR = 'Y' THEN -- Payment Sent to Vendors
				INSERT INTO Payments_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ID, 15, case when NEW.AMOUNT<0 then New.Amount*-1 else New.Amount end, NEW.CASH_ACC_ID, NEW.PS_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'PaymentSent');
		   WHEN NEW.IS_VENDOR = 'N' THEN -- Payment Sent to Customers	
				INSERT INTO Payments_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ID, 15, case when NEW.AMOUNT<0 then New.Amount*-1 else New.Amount end, NEW.CASH_ACC_ID, NEW.PS_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'PaymentSent');
		   WHEN NEW.IS_VENDOR = 'R' THEN -- Payment Sent to Repair Company	
				INSERT INTO Payments_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ID, 15, case when NEW.AMOUNT<0 then New.Amount*-1 else New.Amount end, NEW.CASH_ACC_ID, NEW.PS_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'PaymentSent');
		end case;
	/*NEW VERSION*/



END $$
DELIMITER ;

-- This Triger Deletes the row from Payments Accounting 

drop trigger if Exists TR_PAYMENT_SENT_DEL;
DELIMITER $$
CREATE TRIGGER `TR_PAYMENT_SENT_DEL` BEFORE DELETE ON `payment_sent` FOR EACH ROW BEGIN

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM PAYMENT_SENT_ACCOUNT_DETAIL WHERE PS_ID = OLD.ID;


	/*NEW VERSION*/
	DELETE FROM Payments_Accounting WHERE Form_ID = OLD.ID AND Form_DETAIL_ID IS NULL and Form_Flag='PaymentSent';	
	/*NEW VERSION*/

END $$
DELIMITER ;

-- This Triger insert the rows in Payments Accounting

drop trigger if Exists TR_PAYMENT_SENT_DETAIL;
DELIMITER $$
CREATE TRIGGER `TR_PAYMENT_SENT_DETAIL` AFTER INSERT ON `payment_sent_detail` FOR EACH ROW BEGIN

	DECLARE ENTRY_DATE DATETIME;
	DECLARE PS_REF VARCHAR(50);
	DECLARE COM_ID INT;

	SELECT PS_ENTRY_DATE, PAYPAL_TRANSACTION_ID, COMPANY_ID INTO ENTRY_DATE, PS_REF, COM_ID FROM PAYMENT_SENT WHERE ID = NEW.PAYMENT_SENT_ID;

	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	INSERT INTO PAYMENT_SENT_ACCOUNT_DETAIL (PS_ID, PS_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.PAYMENT_SENT_ID, NEW.ID, 16, NEW.AMOUNT, NEW.GL_ACC_ID, ENTRY_DATE, PS_REF, COM_ID);

    
	/*NEW VERSION*/	
	INSERT INTO Payments_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.PAYMENT_SENT_ID, NEW.ID, 16,case when NEW.AMOUNT<0 then New.Amount*-1 else New.Amount end, NEW.GL_ACC_ID, ENTRY_DATE, PS_REF, COM_ID,'PaymentSent');
	/*NEW VERSION*/
	
END $$
DELIMITER ;

-- This Triger Deletes the old Row and insert the new row in Payments Accounting Table

drop trigger if Exists TR_PAYMENT_SENT_DETAIL_UPT;
DELIMITER $$
CREATE TRIGGER `TR_PAYMENT_SENT_DETAIL_UPT` AFTER UPDATE ON `payment_sent_detail` FOR EACH ROW BEGIN

	DECLARE ENTRY_DATE DATETIME;
	DECLARE PS_REF VARCHAR(50);
	DECLARE COM_ID INT;

	SELECT PS_ENTRY_DATE, PAYPAL_TRANSACTION_ID, COMPANY_ID INTO ENTRY_DATE, PS_REF, COM_ID FROM PAYMENT_SENT WHERE ID = NEW.PAYMENT_SENT_ID;
	
	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM PAYMENT_SENT_ACCOUNT_DETAIL WHERE PS_DETAIL_ID = OLD.ID;

	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	INSERT INTO PAYMENT_SENT_ACCOUNT_DETAIL (PS_ID, PS_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.PAYMENT_SENT_ID, NEW.ID, 16, NEW.AMOUNT, NEW.GL_ACC_ID, ENTRY_DATE, PS_REF, COM_ID);


	/*NEW VERSION*/
	DELETE FROM Payments_Accounting WHERE Form_DETAIL_ID = OLD.ID and Form_Flag='PaymentSent';
	INSERT INTO Payments_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.PAYMENT_SENT_ID, NEW.ID, 16,case when NEW.AMOUNT<0 then New.Amount*-1 else New.Amount end, NEW.GL_ACC_ID, ENTRY_DATE, PS_REF, COM_ID,'PaymentSent');
	/*NEW VERSION*/
			
END $$
DELIMITER ;

-- This triger deletes the Row from Payments Accounting Table

drop trigger if Exists TR_PAYMENT_SENT_DETAIL_DEL;
DELIMITER $$
CREATE TRIGGER `TR_PAYMENT_SENT_DETAIL_DEL` BEFORE DELETE ON `payment_sent_detail` FOR EACH ROW BEGIN

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM PAYMENT_SENT_ACCOUNT_DETAIL WHERE PS_DETAIL_ID = OLD.ID;


	/*NEW VERSION*/
	DELETE FROM Payments_Accounting WHERE Form_DETAIL_ID = OLD.ID and Form_Flag='PaymentSent';	
	/*NEW VERSION*/

END $$
DELIMITER ;

-- This triger insert the row in Payments Accounting and Confliction Detail New Table

drop trigger if Exists TR_RECEIVE_MONEY;
DELIMITER $$
CREATE TRIGGER `TR_RECEIVE_MONEY` AFTER INSERT ON `receive_money` FOR EACH ROW BEGIN

	-- INSERT RECORD INTO PAYMENTS AND RECEIPTS TABLE
	CASE
	   WHEN NEW.IS_VENDOR = 'Y' THEN
		   -- INSERT RECORD INTO PAYMENTS TABLE
		   INSERT INTO PAYMENTS_DETAIL_NEW (VENDOR_ID, FORM_ID, FORM_F_ID, FORM_TRANSACTION_ID, FORM_AMOUNT, FORM_FLAG, COMPANY_ID)
		   SELECT NEW.VENDOR_ID, NEW.ID, NEW.RECEIVE_MONEY_ID, NEW.PAYPAL_TRANSACTION_ID, NEW.AMOUNT, 'M', NEW.COMPANY_ID FROM DUAL;
		   
	   WHEN NEW.IS_VENDOR = 'N' THEN
		   -- INSERT RECORD INTO RECEIPTS TABLE
		   CASE
			   WHEN NEW.RECEIVE_MONEY_TYPE = 'A' THEN
				   INSERT INTO RECEIPTS_DETAIL_NEW (CUSTOMER_ID, FORM_ID, FORM_F_ID, FORM_TRANSACTION_ID, FORM_AMOUNT, FORM_FLAG, COMPANY_ID)
				   SELECT NEW.CUSTOMER_ID, NEW.ID, NEW.RECEIVE_MONEY_ID, NEW.PAYPAL_TRANSACTION_ID, (-1 * NEW.AMOUNT), 'M', NEW.COMPANY_ID FROM DUAL;
				   
			   WHEN NEW.RECEIVE_MONEY_TYPE = 'D' THEN
					
					/*OLD VERSION*/
			         /*
					 
					 INSERT INTO RECEIPTS_DETAIL_NEW (CUSTOMER_ID, FORM_ID, FORM_F_ID, FORM_TRANSACTION_ID, FORM_AMOUNT, FORM_FLAG, COMPANY_ID)
					 SELECT NEW.CUSTOMER_ID, NEW.ID, NEW.RECEIVE_MONEY_ID, NEW.PAYPAL_TRANSACTION_ID, NEW.AMOUNT, 'M', NEW.COMPANY_ID FROM DUAL;
					 
					 */
					/*OLD VERSION*/
					
				 	/*NEW VERSION*/
				   INSERT INTO RECEIPTS_DETAIL_NEW (CUSTOMER_ID, FORM_ID, FORM_F_ID, FORM_TRANSACTION_ID, FORM_AMOUNT, FORM_FLAG, COMPANY_ID)
				   SELECT NEW.CUSTOMER_ID, NEW.ID, NEW.RECEIVE_MONEY_ID, NEW.PAYPAL_TRANSACTION_ID, (-1 * NEW.AMOUNT), 'M', NEW.COMPANY_ID FROM DUAL;
					/*NEW VERSION*/
		   END CASE;
	END CASE;

	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	INSERT INTO RECEIVE_MONEY_ACCOUNT_DETAIL (RM_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ID, 19, NEW.AMOUNT, NEW.CASH_ACC_ID, NEW.RM_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);
	INSERT INTO RECEIVE_MONEY_ACCOUNT_DETAIL (RM_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ID, 20, NEW.AMOUNT, NEW.GL_ACC_ID, NEW.RM_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);


	/*NEW VERSION*/
	INSERT INTO Payments_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ID, 19, case when NEW.AMOUNT<0 then New.Amount*-1 else New.Amount end, NEW.CASH_ACC_ID, NEW.RM_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'ReceiveMoney');
    INSERT INTO Payments_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ID, 20, case when NEW.AMOUNT<0 then New.Amount*-1 else New.Amount end, NEW.GL_ACC_ID, NEW.RM_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'ReceiveMoney');	
	/*NEW VERSION*/

END $$
DELIMITER ;


drop trigger if Exists TR_RECEIVE_MONEY_UPDATE;
DELIMITER $$
CREATE TRIGGER `TR_RECEIVE_MONEY_UPDATE` BEFORE UPDATE ON `receive_money` FOR EACH ROW BEGIN

    DECLARE ID_PS INT DEFAULT 0;
    DECLARE AMOUNT_PS DOUBLE(22, 2) DEFAULT 0;
    DECLARE CONFLICTED_PS VARCHAR (10) DEFAULT 'N';
    -- Insertion column if person changes
    DECLARE ID_NEW INT DEFAULT 0;
    DECLARE FORM_AMOUNT_NEW DOUBLE(22, 2) DEFAULT 0;
    DECLARE IS_CONFLICTED_FULL_NEW VARCHAR (10);
    DECLARE MSG VARCHAR (100);

    -- If Vendor then update in Payments else Receipts
    CASE
        WHEN NEW.IS_VENDOR = 'Y' THEN
        
            IF OLD.IS_VENDOR = 'N' THEN
            
                SELECT ID, FORM_AMOUNT, IS_CONFLICTED_FULL INTO ID_NEW, FORM_AMOUNT_NEW, IS_CONFLICTED_FULL_NEW FROM RECEIPTS_DETAIL_NEW
                WHERE FORM_ID = NEW.ID AND FORM_FLAG = 'M';
            
                IF OLD.AMOUNT = ABS(FORM_AMOUNT_NEW) AND IS_CONFLICTED_FULL_NEW != 'Y' THEN
                
                    DELETE FROM RECEIPTS_DETAIL_NEW WHERE ID = ID_NEW;
                    
                    INSERT INTO PAYMENTS_DETAIL_NEW
                    (
                      VENDOR_ID,
                      FORM_ID,
                      FORM_F_ID,
                      FORM_TRANSACTION_ID,
                      FORM_AMOUNT,
                      FORM_FLAG,
                      COMPANY_ID
                    )
                    SELECT NEW.VENDOR_ID,NEW.ID,NEW.RECEIVE_MONEY_ID,NEW.PAYPAL_TRANSACTION_ID,OLD.AMOUNT,'M',NEW.COMPANY_ID
                    from dual;
                    
                ELSE
                    -- RAISE_APPLICATION_ERROR(-20000,'=>Unable to update because amount already conflicted.' , CHAR(10) , 'Conflicted amount : { ' , (OLD.AMOUNT - ABS(FORM_AMOUNT_NEW)) , ' }<=');
                    SET MSG = CONCAT('=>Unable to update because amount already conflicted.' , CHAR(10) , 'Conflicted amount : { ' , (OLD.AMOUNT - ABS(FORM_AMOUNT_NEW)) , ' }<=');
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = MSG;
                END IF;
                
            ELSE
            
                IF (OLD.VENDOR_ID != NEW.VENDOR_ID) OR (OLD.RECEIVE_MONEY_ID != NEW.RECEIVE_MONEY_ID) OR (OLD.PAYPAL_TRANSACTION_ID != NEW.PAYPAL_TRANSACTION_ID) THEN
                
                    SELECT ID, FORM_AMOUNT, IS_CONFLICTED_FULL INTO ID_NEW, FORM_AMOUNT_NEW, IS_CONFLICTED_FULL_NEW FROM PAYMENTS_DETAIL_NEW
                    WHERE FORM_ID = NEW.ID AND FORM_FLAG = 'M';
            
                    IF OLD.AMOUNT = ABS(FORM_AMOUNT_NEW) AND IS_CONFLICTED_FULL_NEW != 'Y' THEN
                    
                        UPDATE PAYMENTS_DETAIL_NEW
                        SET VENDOR_ID = NEW.VENDOR_ID, FORM_F_ID = NEW.RECEIVE_MONEY_ID, FORM_TRANSACTION_ID = NEW.PAYPAL_TRANSACTION_ID
                        WHERE ID = ID_NEW;
                        
                    ELSE
                        -- RAISE_APPLICATION_ERROR(-20000,'=>Unable to update because amount already conflicted.' , CHAR(10) , 'Conflicted amount : { ' , (OLD.AMOUNT - ABS(FORM_AMOUNT_NEW)) , ' }<=');
                        SET MSG = CONCAT('=>Unable to update because amount already conflicted.' , CHAR(10) , 'Conflicted amount : { ' , (OLD.AMOUNT - ABS(FORM_AMOUNT_NEW)) , ' }<=');
                        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = MSG;
                    END IF;
                
                END IF;
                
            END IF;
        
            IF NEW.AMOUNT != OLD.AMOUNT THEN
                
                SELECT ID, FORM_AMOUNT INTO ID_PS, AMOUNT_PS FROM PAYMENTS_DETAIL_NEW
                WHERE FORM_ID = NEW.ID AND FORM_FLAG = 'M';
                    
                CASE
                    WHEN NEW.AMOUNT > OLD.AMOUNT THEN
                        SET AMOUNT_PS := ABS(AMOUNT_PS) + (NEW.AMOUNT - OLD.AMOUNT);
                        
                    WHEN NEW.AMOUNT < OLD.AMOUNT THEN
                             
                        CASE
                            WHEN (OLD.AMOUNT - NEW.AMOUNT) > ABS(AMOUNT_PS) THEN
                                -- RAISE_APPLICATION_ERROR(-20000,'=>Unable to update payment because amount already conflicted.' , CHAR(10) , 'Conflicted amount : { ' , (OLD.AMOUNT - ABS(AMOUNT_PS)) , ' }<=');
                                SET MSG = CONCAT('=>Unable to update payment because amount already conflicted.' , CHAR(10) , 'Conflicted amount : { ' , (OLD.AMOUNT - ABS(AMOUNT_PS)) , ' }<=');
                                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = MSG;
                            ELSE
                                SET AMOUNT_PS := ABS(AMOUNT_PS) - (OLD.AMOUNT - NEW.AMOUNT);
                                
                                -- Is Full Conflicted or not
                                IF AMOUNT_PS = 0 THEN
                                    IF NEW.AMOUNT = AMOUNT_PS THEN
                                        SET CONFLICTED_PS := 'N';
                                        
                                    ELSE
                                        SET CONFLICTED_PS := 'Y';
                                        
                                    END IF;
                                END IF;
                                
                        END CASE;
                        
                END CASE;
                
                -- Update record into table
                UPDATE PAYMENTS_DETAIL_NEW 
                SET FORM_AMOUNT = AMOUNT_PS, IS_CONFLICTED_FULL = CONFLICTED_PS 
                WHERE ID = ID_PS;
                
            END IF;
            
         WHEN NEW.IS_VENDOR = 'N' THEN
        
            IF OLD.IS_VENDOR = 'Y' THEN
            
                SELECT ID, FORM_AMOUNT, IS_CONFLICTED_FULL INTO ID_NEW, FORM_AMOUNT_NEW, IS_CONFLICTED_FULL_NEW FROM PAYMENTS_DETAIL_NEW
                WHERE FORM_ID = NEW.ID AND FORM_FLAG = 'M';
            
                IF OLD.AMOUNT = ABS(FORM_AMOUNT_NEW) AND IS_CONFLICTED_FULL_NEW != 'Y' THEN
                
                    DELETE FROM PAYMENTS_DETAIL_NEW WHERE ID = ID_NEW;
                    
                    CASE
                        WHEN NEW.RECEIVE_MONEY_TYPE = 'A' THEN
                    
                            INSERT INTO RECEIPTS_DETAIL_NEW
                            (
                              CUSTOMER_ID,
                              FORM_ID,
                              FORM_F_ID,
                              FORM_TRANSACTION_ID,
                              FORM_AMOUNT,
                              FORM_FLAG,
                              COMPANY_ID
                            )
                            SELECT NEW.CUSTOMER_ID,NEW.ID,NEW.RECEIVE_MONEY_ID,NEW.PAYPAL_TRANSACTION_ID,(-1 * OLD.AMOUNT),'M',NEW.COMPANY_ID
                            from dual;
                            
                        WHEN NEW.RECEIVE_MONEY_TYPE = 'D' THEN
                        
                            INSERT INTO RECEIPTS_DETAIL_NEW
                            (
                              CUSTOMER_ID,
                              FORM_ID,
                              FORM_F_ID,
                              FORM_TRANSACTION_ID,
                              FORM_AMOUNT,
                              FORM_FLAG,
                              COMPANY_ID
                            )
                            SELECT NEW.CUSTOMER_ID,NEW.ID,NEW.RECEIVE_MONEY_ID,NEW.PAYPAL_TRANSACTION_ID,(OLD.AMOUNT * -1),'M',NEW.COMPANY_ID
                            from dual;
                            
                    END CASE;
                    
                ELSE
                    -- RAISE_APPLICATION_ERROR(-20000,'=>Unable to update because amount already conflicted.' , CHAR(10) , 'Conflicted amount : { ' , (OLD.AMOUNT - ABS(FORM_AMOUNT_NEW)) , ' }<=');
                    SET MSG = CONCAT('=>Unable to update because amount already conflicted.' , CHAR(10) , 'Conflicted amount : { ' , (OLD.AMOUNT - ABS(FORM_AMOUNT_NEW)) , ' }<=');
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = MSG;
                END IF;
                
            ELSE
            
                IF (OLD.CUSTOMER_ID != NEW.CUSTOMER_ID) OR (OLD.RECEIVE_MONEY_ID != NEW.RECEIVE_MONEY_ID) OR (OLD.PAYPAL_TRANSACTION_ID != NEW.PAYPAL_TRANSACTION_ID) THEN
                
                    SELECT ID, FORM_AMOUNT, IS_CONFLICTED_FULL INTO ID_NEW, FORM_AMOUNT_NEW, IS_CONFLICTED_FULL_NEW FROM RECEIPTS_DETAIL_NEW
                    WHERE FORM_ID = NEW.ID AND FORM_FLAG = 'M';
            
                    IF OLD.AMOUNT = ABS(FORM_AMOUNT_NEW) AND IS_CONFLICTED_FULL_NEW != 'Y' THEN
                    
                        CASE
                            WHEN NEW.RECEIVE_MONEY_TYPE = 'A' THEN
                            
                                UPDATE RECEIPTS_DETAIL_NEW
                                SET FORM_AMOUNT = (-1 * OLD.AMOUNT), CUSTOMER_ID = NEW.CUSTOMER_ID, FORM_F_ID = NEW.RECEIVE_MONEY_ID, FORM_TRANSACTION_ID = NEW.PAYPAL_TRANSACTION_ID
                                WHERE ID = ID_NEW;
                                
                            WHEN NEW.RECEIVE_MONEY_TYPE = 'D' THEN
                            
                                UPDATE RECEIPTS_DETAIL_NEW
                                SET FORM_AMOUNT = (-1 * OLD.AMOUNT), CUSTOMER_ID = NEW.CUSTOMER_ID, FORM_F_ID = NEW.RECEIVE_MONEY_ID, FORM_TRANSACTION_ID = NEW.PAYPAL_TRANSACTION_ID
                                WHERE ID = ID_NEW;
                                
                        END CASE;
                        
                    ELSE
                        -- RAISE_APPLICATION_ERROR(-20000,'=>Unable to update because amount already conflicted.' , CHAR(10) , 'Conflicted amount : { ' , (OLD.AMOUNT - ABS(FORM_AMOUNT_NEW)) , ' }<=');
                        SET MSG = CONCAT('=>Unable to update because amount already conflicted.' , CHAR(10) , 'Conflicted amount : { ' , (OLD.AMOUNT - ABS(FORM_AMOUNT_NEW)) , ' }<=');
                        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = MSG;
                    END IF;
                
                END IF;
            
            END IF;
        
            IF NEW.AMOUNT != OLD.AMOUNT THEN
                
                SELECT ID, FORM_AMOUNT INTO ID_PS, AMOUNT_PS FROM RECEIPTS_DETAIL_NEW
                WHERE FORM_ID = NEW.ID AND FORM_FLAG = 'M';
                    
                CASE
                    WHEN NEW.AMOUNT > OLD.AMOUNT THEN
                        SET AMOUNT_PS := ABS(AMOUNT_PS) + (NEW.AMOUNT - OLD.AMOUNT);
                        
                    WHEN NEW.AMOUNT < OLD.AMOUNT THEN
                             
                        CASE
                            WHEN (OLD.AMOUNT - NEW.AMOUNT) > ABS(AMOUNT_PS) THEN
                                -- RAISE_APPLICATION_ERROR(-20000,'=>Unable to update payment because amount already conflicted.' , CHAR(10) , 'Conflicted amount : { ' , (OLD.AMOUNT - ABS(AMOUNT_PS)) , ' }<=');
                                SET MSG = CONCAT('=>Unable to update payment because amount already conflicted.' , CHAR(10) , 'Conflicted amount : { ' , (OLD.AMOUNT - ABS(AMOUNT_PS)) , ' }<=');
                                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = MSG;
                            ELSE
                                SET AMOUNT_PS := ABS(AMOUNT_PS) - (OLD.AMOUNT - NEW.AMOUNT);
                                
                                -- Is Full Conflicted or not
                                IF AMOUNT_PS = 0 THEN
                                    IF NEW.AMOUNT = AMOUNT_PS THEN
                                        SET CONFLICTED_PS := 'N';
                                        
                                    ELSE
                                        SET CONFLICTED_PS := 'Y';
                                        
                                    END IF;
                                END IF;
                                
                        END CASE;
                        
                END CASE;
                
                CASE
                    WHEN NEW.RECEIVE_MONEY_TYPE = 'A' THEN
                
                        -- Update record into table
                        UPDATE RECEIPTS_DETAIL_NEW
                        SET FORM_AMOUNT = (-1 * AMOUNT_PS), IS_CONFLICTED_FULL = CONFLICTED_PS 
                        WHERE ID = ID_PS;
                        
                    WHEN NEW.RECEIVE_MONEY_TYPE = 'D' THEN
                    
                        -- Update record into table
                        UPDATE RECEIPTS_DETAIL_NEW
                        SET FORM_AMOUNT = (-1 * AMOUNT_PS), IS_CONFLICTED_FULL = CONFLICTED_PS 
                        WHERE ID = ID_PS;
                        
                END CASE;
                
            END IF;
        
    END CASE;
    
END $$
DELIMITER ;


-- This Trigger Deletes the Row from Payments Accounting and insert new rows in Payments Accounting

drop trigger if Exists TR_RECEIVE_MONEY_UPT;
DELIMITER $$
CREATE TRIGGER `TR_RECEIVE_MONEY_UPT` AFTER UPDATE ON `receive_money` FOR EACH ROW BEGIN

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM RECEIVE_MONEY_ACCOUNT_DETAIL WHERE RM_ID = OLD.ID;
	
	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	INSERT INTO RECEIVE_MONEY_ACCOUNT_DETAIL (RM_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ID, 19, NEW.AMOUNT, NEW.CASH_ACC_ID, NEW.RM_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);
	INSERT INTO RECEIVE_MONEY_ACCOUNT_DETAIL (RM_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ID, 20, NEW.AMOUNT, NEW.GL_ACC_ID, NEW.RM_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);


	/*NEW VERSION*/
	DELETE FROM Payments_Accounting WHERE Form_ID = OLD.ID and Form_Flag='ReceiveMoney';
    INSERT INTO Payments_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ID, 19, case when NEW.AMOUNT<0 then New.Amount*-1 else New.Amount end, NEW.CASH_ACC_ID, NEW.RM_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'ReceiveMoney');
    INSERT INTO Payments_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ID, 20, case when NEW.AMOUNT<0 then New.Amount*-1 else New.Amount end, NEW.GL_ACC_ID, NEW.RM_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'ReceiveMoney');
	/*NEW VERSION*/

END $$
DELIMITER ;

-- This Triger deletes the Row from Payments Accounting

drop trigger if Exists TR_RECEIVE_MONEY_DEL;
DELIMITER $$
CREATE TRIGGER `TR_RECEIVE_MONEY_DEL` BEFORE DELETE ON `receive_money` FOR EACH ROW BEGIN

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM RECEIVE_MONEY_ACCOUNT_DETAIL WHERE RM_ID = OLD.ID;


	/*NEW VERSION*/
	DELETE FROM Payments_Accounting WHERE Form_ID = OLD.ID and Form_Flag='ReceiveMoney';	
	/*NEW VERSION*/

END $$
DELIMITER ;

-- This Triger insert the row in Payments Accountng

drop trigger if Exists TR_PAYMENTS;
DELIMITER $$
CREATE TRIGGER `TR_PAYMENTS` AFTER INSERT ON `payments` FOR EACH ROW BEGIN

	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
  INSERT INTO PAYMENTS_ACCOUNT_DETAIL (PAY_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ID, 26, NEW.REMAINING_AMOUNT, NEW.CASH_ACC_ID, NEW.PAY_ENTRY_DATE, NEW.PAY_REFERENCE, NEW.COMPANY_ID);


   /*NEW VERSION*/
	if (NEW.REMAINING_AMOUNT<0)
		Then
			INSERT INTO Payments_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ID, 26, NEW.REMAINING_AMOUNT*-1, NEW.CASH_ACC_ID, NEW.PAY_ENTRY_DATE, NEW.PAY_REFERENCE, NEW.COMPANY_ID,'Payments');
		else
			INSERT INTO Payments_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ID, 101, NEW.REMAINING_AMOUNT, NEW.CASH_ACC_ID, NEW.PAY_ENTRY_DATE, NEW.PAY_REFERENCE, NEW.COMPANY_ID,'Payments');
	 end if;
   /*NEW VERSION*/
	
END $$
DELIMITER ;

-- This Triger insert the row in Payments Accounting

drop trigger if Exists TR_PAYMENTS_UPT;
DELIMITER $$
CREATE TRIGGER `TR_PAYMENTS_UPT` AFTER UPDATE ON `payments` FOR EACH ROW BEGIN

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM PAYMENTS_ACCOUNT_DETAIL WHERE PAY_ID = OLD.ID AND PAY_DETAIL_ID IS NULL;
	
	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	  
  INSERT INTO PAYMENTS_ACCOUNT_DETAIL (PAY_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ID, 26, NEW.REMAINING_AMOUNT, NEW.CASH_ACC_ID, NEW.PAY_ENTRY_DATE, NEW.PAY_REFERENCE, NEW.COMPANY_ID);


  /*NEW VERSION*/
	DELETE FROM Payments_Accounting WHERE Form_ID = OLD.ID AND Form_DETAIL_ID IS NULL and Form_Flag='Payments';  
    if (NEW.REMAINING_AMOUNT<0)
		Then
			INSERT INTO Payments_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ID, 26, NEW.REMAINING_AMOUNT*-1, NEW.CASH_ACC_ID, NEW.PAY_ENTRY_DATE, NEW.PAY_REFERENCE, NEW.COMPANY_ID,'Payments');
		else
			INSERT INTO Payments_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ID, 101, NEW.REMAINING_AMOUNT, NEW.CASH_ACC_ID, NEW.PAY_ENTRY_DATE, NEW.PAY_REFERENCE, NEW.COMPANY_ID,'Payments');
	end if;
  /*NEW VERSION*/
 		

END $$
DELIMITER ;

-- This triger deletes the row from Payments Accounting 

drop trigger if Exists TR_PAYMENTS_DEL;
DELIMITER $$
CREATE TRIGGER `TR_PAYMENTS_DEL` BEFORE DELETE ON `payments` FOR EACH ROW BEGIN

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM PAYMENTS_ACCOUNT_DETAIL WHERE PAY_ID = OLD.ID;


	/*NEW VERSION*/
	DELETE FROM Payments_Accounting WHERE Form_ID = OLD.ID AND Form_DETAIL_ID IS NULL and Form_Flag='Payments';
	/*NEW VERSION*/

END $$
DELIMITER ;


drop trigger if Exists TR_PAYMENTS_DETAIL;
DELIMITER $$
CREATE TRIGGER `TR_PAYMENTS_DETAIL` AFTER INSERT ON `payments_detail` FOR EACH ROW BEGIN

	DECLARE ENTRY_DATE DATETIME;
	DECLARE PAY_REF VARCHAR(50);
	DECLARE COM_ID INT;

	SELECT PAY_ENTRY_DATE, PAY_REFERENCE, COMPANY_ID INTO ENTRY_DATE, PAY_REF, COM_ID FROM PAYMENTS WHERE ID = NEW.PAYMENTS_ID;

	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE

   INSERT INTO PAYMENTS_ACCOUNT_DETAIL (PAY_ID, PAY_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.PAYMENTS_ID, NEW.ID, 23, NEW.FORM_AMOUNT, NEW.GL_ACC_ID, ENTRY_DATE, PAY_REF, COM_ID);


   /*NEW VERSION*/
   
	if(New.Form_Flag='P')
			then
			    
				INSERT INTO Payments_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.PAYMENTS_ID, NEW.ID,case when New.FORM_AMOUNT<0 then 23 else 201 End,case when New.Form_Amount<0 then New.Form_Amount*-1 else NEW.FORM_AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, PAY_REF, COM_ID,'Payments');
		end if;
        
        if(New.Form_Flag='M')
			then
				
				INSERT INTO Payments_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.PAYMENTS_ID, NEW.ID,case when New.FORM_AMOUNT<0 then 102 else 203 end,case when New.Form_Amount<0 then New.Form_Amount*-1 else NEW.FORM_AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, PAY_REF, COM_ID,'Payments');
		end if;
        
        if(New.Form_Flag='R')
			then
				
				INSERT INTO Payments_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.PAYMENTS_ID, NEW.ID, 103,case when New.Form_Amount<0 then New.Form_Amount*-1 else NEW.FORM_AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, PAY_REF, COM_ID,'Payments');
		end if;
	
		if(New.Form_Flag='V')
			then
				
				INSERT INTO Payments_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.PAYMENTS_ID, NEW.ID, 104,case when New.Form_Amount<0 then New.Form_Amount*-1 else NEW.FORM_AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, PAY_REF, COM_ID,'Payments');
		end if;
    
		if(New.Form_Flag='N')
			then
				
				INSERT INTO Payments_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.PAYMENTS_ID, NEW.ID, 105,case when New.Form_Amount<0 then New.Form_Amount*-1 else NEW.FORM_AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, PAY_REF, COM_ID,'Payments');
		end if;
    
		if(New.Form_Flag='L')
			then
				
				INSERT INTO Payments_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.PAYMENTS_ID, NEW.ID, 106,case when New.Form_Amount<0 then New.Form_Amount*-1 else NEW.FORM_AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, PAY_REF, COM_ID,'Payments');
		end if;

		if(New.FORM_FLAG = 'T')
           		then 
				INSERT INTO Payments_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.PAYMENTS_ID, NEW.ID,case when NEW.FORM_AMOUNT<0 then 5554 else 5553 end,case when New.Form_Amount<0 then New.Form_Amount*-1 else NEW.FORM_AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, PAY_REF, COM_ID,'Payments');
		end if;
	
   /*NEW VERSION*/
			
END $$
DELIMITER ;

drop trigger if Exists TR_PAYMENTS_DETAIL_UPT;
DELIMITER $$
CREATE TRIGGER `TR_PAYMENTS_DETAIL_UPT` AFTER UPDATE ON `payments_detail` FOR EACH ROW BEGIN
	
	DECLARE ENTRY_DATE DATETIME;
	DECLARE PAY_REF VARCHAR(50);
	DECLARE COM_ID INT;

	SELECT PAY_ENTRY_DATE, PAY_REFERENCE, COMPANY_ID INTO ENTRY_DATE, PAY_REF, COM_ID FROM PAYMENTS WHERE ID = NEW.PAYMENTS_ID;
	
	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM PAYMENTS_ACCOUNT_DETAIL WHERE PAY_DETAIL_ID = OLD.ID;
	
	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE

	INSERT INTO PAYMENTS_ACCOUNT_DETAIL (PAY_ID, PAY_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.PAYMENTS_ID, NEW.ID, 23, NEW.FORM_AMOUNT, NEW.GL_ACC_ID, ENTRY_DATE, PAY_REF, COM_ID);


	/*NEW VERSION*/   
   	DELETE FROM Payments_Accounting WHERE Form_DETAIL_ID = OLD.ID and Form_Flag='Payments';
		if(New.Form_Flag='P')
			then
			    
				INSERT INTO Payments_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.PAYMENTS_ID, NEW.ID,case when New.FORM_AMOUNT<0 then 23 else 201 End,case when New.Form_Amount<0 then New.Form_Amount*-1 else NEW.FORM_AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, PAY_REF, COM_ID,'Payments');
		end if;
        
        if(New.Form_Flag='M')
			then
				
				INSERT INTO Payments_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.PAYMENTS_ID, NEW.ID,case when New.FORM_AMOUNT<0 then 102 else 203 end,case when New.Form_Amount<0 then New.Form_Amount*-1 else NEW.FORM_AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, PAY_REF, COM_ID,'Payments');
		end if;
        
        if(New.Form_Flag='R')
			then
				
				INSERT INTO Payments_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.PAYMENTS_ID, NEW.ID, 103,case when New.Form_Amount<0 then New.Form_Amount*-1 else NEW.FORM_AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, PAY_REF, COM_ID,'Payments');
		end if;
	
		if(New.Form_Flag='V')
			then
				
				INSERT INTO Payments_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.PAYMENTS_ID, NEW.ID, 104,case when New.Form_Amount<0 then New.Form_Amount*-1 else NEW.FORM_AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, PAY_REF, COM_ID,'Payments');
		end if;
    
		if(New.Form_Flag='N')
			then
				
				INSERT INTO Payments_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.PAYMENTS_ID, NEW.ID, 105,case when New.Form_Amount<0 then New.Form_Amount*-1 else NEW.FORM_AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, PAY_REF, COM_ID,'Payments');
		end if;
    
		if(New.Form_Flag='L')
			then
				
				INSERT INTO Payments_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.PAYMENTS_ID, NEW.ID, 106,case when New.Form_Amount<0 then New.Form_Amount*-1 else NEW.FORM_AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, PAY_REF, COM_ID,'Payments');
		end if;

		if(New.FORM_FLAG = 'T')
           		then 
				INSERT INTO Payments_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.PAYMENTS_ID, NEW.ID,case when NEW.FORM_AMOUNT<0 then 5554 else 5553 end,case when New.Form_Amount<0 then New.Form_Amount*-1 else NEW.FORM_AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, PAY_REF, COM_ID,'Payments');
		end if;
	/*NEW VERSION*/

END $$
DELIMITER ;

drop trigger if Exists TR_PAYMENTS_DETAIL_DEL;
DELIMITER $$
CREATE TRIGGER `TR_PAYMENTS_DETAIL_DEL` BEFORE DELETE ON `payments_detail` FOR EACH ROW BEGIN

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM PAYMENTS_ACCOUNT_DETAIL WHERE PAY_DETAIL_ID = OLD.ID;


	/*NEW VERSION*/
	DELETE FROM Payments_Accounting WHERE Form_DETAIL_ID = OLD.ID and Form_Flag='Payments';
	/*NEW VERSION*/

END $$
DELIMITER ;



drop trigger if Exists TR_RECEIPTS;
DELIMITER $$
CREATE TRIGGER `TR_RECEIPTS` AFTER INSERT ON `receipts` FOR EACH ROW BEGIN

	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
     INSERT INTO RECEIPTS_ACCOUNT_DETAIL (REC_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ID, 29, NEW.REMAINING_AMOUNT, NEW.CASH_ACC_ID, NEW.R_ENTRY_DATE, NEW.REC_REFERENCE, NEW.COMPANY_ID);

	
	/*NEW VERSION*/
     if(NEW.REMAINING_AMOUNT<0)
		then
			INSERT INTO Payments_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ID, 29, NEW.REMAINING_AMOUNT*-1, NEW.CASH_ACC_ID, NEW.R_ENTRY_DATE, NEW.REC_REFERENCE, NEW.COMPANY_ID,'Receipts');
		else
			INSERT INTO Payments_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ID, 107, NEW.REMAINING_AMOUNT, NEW.CASH_ACC_ID, NEW.R_ENTRY_DATE, NEW.REC_REFERENCE, NEW.COMPANY_ID,'Receipts');
     end if;
	/*NEW VERSION*/
	
END $$
DELIMITER ;

drop trigger if Exists TR_RECEIPTS_UPT;
DELIMITER $$
CREATE TRIGGER `TR_RECEIPTS_UPT` AFTER UPDATE ON `receipts` FOR EACH ROW BEGIN

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM RECEIPTS_ACCOUNT_DETAIL WHERE REC_ID = OLD.ID AND REC_DETAIL_ID IS NULL;
	
	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE

  INSERT INTO RECEIPTS_ACCOUNT_DETAIL (REC_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ID, 29, NEW.REMAINING_AMOUNT, NEW.CASH_ACC_ID, NEW.R_ENTRY_DATE, NEW.REC_REFERENCE, NEW.COMPANY_ID);
		   
		   
  /*NEW VERSION*/
   	 DELETE FROM Payments_Accounting WHERE Form_ID = OLD.ID AND Form_DETAIL_ID IS NULL and Form_Flag='Receipts';
     if(NEW.REMAINING_AMOUNT<0)
		then
			INSERT INTO Payments_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ID, 29, NEW.REMAINING_AMOUNT*-1, NEW.CASH_ACC_ID, NEW.R_ENTRY_DATE, NEW.REC_REFERENCE, NEW.COMPANY_ID,'Receipts');
		else
			INSERT INTO Payments_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ID, 107, NEW.REMAINING_AMOUNT, NEW.CASH_ACC_ID, NEW.R_ENTRY_DATE, NEW.REC_REFERENCE, NEW.COMPANY_ID,'Receipts');
     end if;
  /*NEW VERSION*/
 		   
END $$
DELIMITER ;

drop trigger if Exists TR_RECEIPTS_DEL;
DELIMITER $$
CREATE TRIGGER `TR_RECEIPTS_DEL` BEFORE DELETE ON `receipts` FOR EACH ROW BEGIN

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM RECEIPTS_ACCOUNT_DETAIL WHERE REC_ID = OLD.ID;


	/*NEW VERSION*/
	DELETE FROM Payments_Accounting WHERE Form_ID = OLD.ID AND Form_DETAIL_ID IS NULL and Form_Flag='Receipts';
	/*NEW VERSION*/

END $$
DELIMITER ;

drop trigger if Exists TR_RECEIPTS_DETAIL;
DELIMITER $$
CREATE TRIGGER `TR_RECEIPTS_DETAIL` AFTER INSERT ON `receipts_detail` FOR EACH ROW BEGIN

	DECLARE ENTRY_DATE DATETIME;
	DECLARE REC_REF VARCHAR(50);
	DECLARE COM_ID INT;

	SELECT R_ENTRY_DATE, REC_REFERENCE, COMPANY_ID INTO ENTRY_DATE, REC_REF, COM_ID FROM RECEIPTS WHERE ID = NEW.RECEIPTS_ID;
	
	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	
    INSERT INTO RECEIPTS_ACCOUNT_DETAIL (REC_ID, REC_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.RECEIPTS_ID, NEW.ID, 28, NEW.FORM_AMOUNT, NEW.GL_ACC_ID, ENTRY_DATE, REC_REF, COM_ID);


	/*NEW VERSION*/
	
	if(New.Form_Flag='P')
			then
				INSERT INTO Payments_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.RECEIPTS_ID, NEW.ID,case when New.Form_Amount < 0 then 204 else 28 end,case when New.Form_Amount<0 then NEW.FORM_AMOUNT*-1 else New.Form_Amount end, NEW.GL_ACC_ID, ENTRY_DATE, REC_REF, COM_ID,'Receipts');
	end if;
            
    if(New.Form_Flag='M')
			then
				INSERT INTO Payments_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.RECEIPTS_ID, NEW.ID,case when New.FORM_AMOUNT > 0 then 108 else 205 end,case when New.Form_Amount<0 then NEW.FORM_AMOUNT*-1 else New.Form_Amount end, NEW.GL_ACC_ID, ENTRY_DATE, REC_REF, COM_ID,'Receipts');
	end if;
            
	if(New.Form_Flag='I')
			then
				INSERT INTO Payments_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.RECEIPTS_ID, NEW.ID, 109,case when New.Form_Amount<0 then NEW.FORM_AMOUNT*-1 else New.Form_Amount end, NEW.GL_ACC_ID, ENTRY_DATE, REC_REF, COM_ID,'Receipts');
	end if;
            
	if(New.Form_Flag='S')
			then
				INSERT INTO Payments_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.RECEIPTS_ID, NEW.ID, 110,case when New.Form_Amount<0 then NEW.FORM_AMOUNT*-1 else New.Form_Amount end, NEW.GL_ACC_ID, ENTRY_DATE, REC_REF, COM_ID,'Receipts');
	end if;
            
	if(New.Form_Flag='T')
			then
				INSERT INTO Payments_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.RECEIPTS_ID, NEW.ID, 111,case when New.Form_Amount<0 then NEW.FORM_AMOUNT*-1 else New.Form_Amount end, NEW.GL_ACC_ID, ENTRY_DATE, REC_REF, COM_ID,'Receipts');
	end if;
            
	if(New.Form_Flag='L')
			then	
				INSERT INTO Payments_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.RECEIPTS_ID, NEW.ID, 112,case when New.Form_Amount<0 then NEW.FORM_AMOUNT*-1 else New.Form_Amount end, NEW.GL_ACC_ID, ENTRY_DATE, REC_REF, COM_ID,'Receipts');
	end if;
            
	if(New.Form_Flag='E')
			then
				INSERT INTO Payments_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.RECEIPTS_ID, NEW.ID,case when New.Form_Amount<0 then 113 else 114 end,case when New.Form_Amount<0 then NEW.FORM_AMOUNT*-1 else New.Form_Amount end, NEW.GL_ACC_ID, ENTRY_DATE, REC_REF, COM_ID,'Receipts');
	end if;
	if (New.Form_Flag = 'B')
		then 
				INSERT INTO Payments_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.RECEIPTS_ID, NEW.ID,case when New.Form_Amount<0 then 5551 else 5552 end,case when New.Form_Amount<0 then NEW.FORM_AMOUNT*-1 else New.Form_Amount end, NEW.GL_ACC_ID, ENTRY_DATE, REC_REF, COM_ID,'Receipts');
	end if;
	
	/*NEW VERSION*/
	
END $$
DELIMITER ;

drop trigger if Exists TR_RECEIPTS_DETAIL_UPT;
DELIMITER $$
CREATE TRIGGER `TR_RECEIPTS_DETAIL_UPT` AFTER UPDATE ON `receipts_detail` FOR EACH ROW BEGIN

	DECLARE ENTRY_DATE DATETIME;
	DECLARE REC_REF VARCHAR(50);
	DECLARE COM_ID INT;

	SELECT R_ENTRY_DATE, REC_REFERENCE, COMPANY_ID INTO ENTRY_DATE, REC_REF, COM_ID FROM RECEIPTS WHERE ID = NEW.RECEIPTS_ID;
	
	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM RECEIPTS_ACCOUNT_DETAIL WHERE REC_DETAIL_ID = OLD.ID;

	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	
   INSERT INTO RECEIPTS_ACCOUNT_DETAIL (REC_ID, REC_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.RECEIPTS_ID, NEW.ID, 28, NEW.FORM_AMOUNT, NEW.GL_ACC_ID, ENTRY_DATE, REC_REF, COM_ID);


	/*NEW VERSION*/
   	DELETE FROM Payments_Accounting WHERE Form_DETAIL_ID = OLD.ID and Form_Flag='Receipts';
	if(New.Form_Flag='P')
			then
				INSERT INTO Payments_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.RECEIPTS_ID, NEW.ID,case when New.Form_Amount < 0 then 204 else 28 end,case when New.Form_Amount<0 then NEW.FORM_AMOUNT*-1 else New.Form_Amount end, NEW.GL_ACC_ID, ENTRY_DATE, REC_REF, COM_ID,'Receipts');
	end if;
            
    if(New.Form_Flag='M')
			then
				INSERT INTO Payments_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.RECEIPTS_ID, NEW.ID,case when New.FORM_AMOUNT > 0 then 108 else 205 end,case when New.Form_Amount<0 then NEW.FORM_AMOUNT*-1 else New.Form_Amount end, NEW.GL_ACC_ID, ENTRY_DATE, REC_REF, COM_ID,'Receipts');
	end if;
            
	 if(New.Form_Flag='I')
			then
				INSERT INTO Payments_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.RECEIPTS_ID, NEW.ID, 109,case when New.Form_Amount<0 then NEW.FORM_AMOUNT*-1 else New.Form_Amount end, NEW.GL_ACC_ID, ENTRY_DATE, REC_REF, COM_ID,'Receipts');
			end if;
            
	if(New.Form_Flag='S')
			then
				INSERT INTO Payments_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.RECEIPTS_ID, NEW.ID, 110,case when New.Form_Amount<0 then NEW.FORM_AMOUNT*-1 else New.Form_Amount end, NEW.GL_ACC_ID, ENTRY_DATE, REC_REF, COM_ID,'Receipts');
			end if;
            
	if(New.Form_Flag='T')
			then
				INSERT INTO Payments_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.RECEIPTS_ID, NEW.ID, 111,case when New.Form_Amount<0 then NEW.FORM_AMOUNT*-1 else New.Form_Amount end, NEW.GL_ACC_ID, ENTRY_DATE, REC_REF, COM_ID,'Receipts');
			end if;
            
	if(New.Form_Flag='L')
			then	
				INSERT INTO Payments_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.RECEIPTS_ID, NEW.ID, 112,case when New.Form_Amount<0 then NEW.FORM_AMOUNT*-1 else New.Form_Amount end, NEW.GL_ACC_ID, ENTRY_DATE, REC_REF, COM_ID,'Receipts');
			end if;
            
	if(New.Form_Flag='E')
			then
				INSERT INTO Payments_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.RECEIPTS_ID, NEW.ID,case when New.Form_Amount<0 then 113 else 114 end,case when New.Form_Amount<0 then NEW.FORM_AMOUNT*-1 else New.Form_Amount end, NEW.GL_ACC_ID, ENTRY_DATE, REC_REF, COM_ID,'Receipts');
			end if;
	if (New.Form_Flag = 'B')
		then 
				INSERT INTO Payments_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.RECEIPTS_ID, NEW.ID,case when New.Form_Amount<0 then 5551 else 5552 end,case when New.Form_Amount<0 then NEW.FORM_AMOUNT*-1 else New.Form_Amount end, NEW.GL_ACC_ID, ENTRY_DATE, REC_REF, COM_ID,'Receipts');
	end if;
	
	/*NEW VERSION*/

END $$
DELIMITER ;

drop trigger if Exists TR_RECEIPTS_DETAIL_DEL;
DELIMITER $$
CREATE TRIGGER `TR_RECEIPTS_DETAIL_DEL` BEFORE DELETE ON `receipts_detail` FOR EACH ROW BEGIN

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM RECEIPTS_ACCOUNT_DETAIL WHERE REC_DETAIL_ID = OLD.ID;


	/*NEW VERSION*/
   	DELETE FROM Payments_Accounting WHERE Form_DETAIL_ID = OLD.ID and Form_Flag='Receipts';
	/*NEW VERSION*/

END $$
DELIMITER ;

/*Charges Triggers are not present in Server Copy*/

drop trigger if Exists TR_CHARGES;
DELIMITER $$
CREATE  TRIGGER `TR_CHARGES` AFTER INSERT ON `charges` FOR EACH ROW BEGIN
	 
	
	 
	 /*OLD ACCOUNTING TABLES*/
	 INSERT INTO CHARGES_ACCOUNT_DETAIL (C_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ID, 26, NEW.REMAINING_AMOUNT, NEW.CASH_ACC_ID, NEW.C_ENTRY_DATE, NEW.C_REFERENCE, NEW.COMPANY_ID);
	 /*OLD ACCOUNTING TABLES*/
	 
	 
	/*NEW VERSION*/
	if(New.Remaining_amount<0)
		then
			INSERT INTO Payments_Accounting (Form_ID,Form_Flag,GL_FLAG,AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ID,'Charges',89,case when NEW.REMAINING_AMOUNT<0 then NEW.REMAINING_AMOUNT*-1 else NEW.REMAINING_AMOUNT end, NEW.CASH_ACC_ID, NEW.C_ENTRY_DATE, NEW.C_REFERENCE, NEW.COMPANY_ID);
		else
			INSERT INTO Payments_Accounting (Form_ID,Form_Flag,GL_FLAG,AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ID,'Charges',115,case when NEW.REMAINING_AMOUNT<0 then NEW.REMAINING_AMOUNT*-1 else NEW.REMAINING_AMOUNT end, NEW.CASH_ACC_ID, NEW.C_ENTRY_DATE, NEW.C_REFERENCE, NEW.COMPANY_ID);
	end if;
	/*NEW VERSION*/
	
END $$
DELIMITER ;

drop trigger if Exists TR_CHARGES_UPT;
DELIMITER $$
CREATE TRIGGER `TR_CHARGES_UPT` AFTER UPDATE ON `charges` FOR EACH ROW BEGIN
	
		
	/* OLD ACCOUNTING TABLES */
	DELETE FROM CHARGES_ACCOUNT_DETAIL WHERE C_ID = OLD.ID AND C_DETAIL_ID IS NULL;
	INSERT INTO CHARGES_ACCOUNT_DETAIL (C_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ID, 26, NEW.REMAINING_AMOUNT, NEW.CASH_ACC_ID, NEW.C_ENTRY_DATE, NEW.C_REFERENCE, NEW.COMPANY_ID);
	/* OLD ACCOUNTING TABLES */
	 
	/*NEW VERSION*/
	DELETE FROM Payments_Accounting WHERE Form_ID = OLD.ID AND Form_DETAIL_ID IS NULL and Form_Flag='Charges'; 
    if(New.Remaining_amount<0)
		then
			INSERT INTO Payments_Accounting (Form_ID,Form_Flag,GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ID,'Charges',89, case when NEW.REMAINING_AMOUNT<0 then NEW.REMAINING_AMOUNT*-1 else NEW.REMAINING_AMOUNT end, NEW.CASH_ACC_ID, NEW.C_ENTRY_DATE, NEW.C_REFERENCE, NEW.COMPANY_ID);
		else
			INSERT INTO Payments_Accounting (Form_ID,Form_Flag,GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ID,'Charges',115, case when NEW.REMAINING_AMOUNT<0 then NEW.REMAINING_AMOUNT*-1 else NEW.REMAINING_AMOUNT end, NEW.CASH_ACC_ID, NEW.C_ENTRY_DATE, NEW.C_REFERENCE, NEW.COMPANY_ID);
	end if;
	/*NEW VERSION*/
	
END $$
DELIMITER ;

drop trigger if Exists TR_CHARGES_DEL;
DELIMITER $$
CREATE TRIGGER `TR_CHARGES_DEL` BEFORE DELETE ON `charges` FOR EACH ROW BEGIN
	
	
	
	/*OLD ACCOUNTING TABLES*/
	DELETE FROM CHARGES_ACCOUNT_DETAIL WHERE C_ID = OLD.ID;
	/*OLD ACCOUNTING TABLES*/
	
	/*NEW VERSION*/
	DELETE FROM Payments_Accounting WHERE Form_ID = OLD.ID AND Form_DETAIL_ID IS NULL and Form_Flag='Charges';
	/*NEW VERSION*/
	
END $$
DELIMITER ;

drop trigger if Exists TR_CHARGES_DETAIL;
DELIMITER $$
CREATE TRIGGER `TR_CHARGES_DETAIL` AFTER INSERT ON `charges_detail` FOR EACH ROW BEGIN
	
	
	DECLARE ENTRY_DATE DATETIME;
	DECLARE C_REF VARCHAR(50);
	DECLARE COM_ID INT;

	SELECT C_ENTRY_DATE, C_REFERENCE, COMPANY_ID INTO ENTRY_DATE, C_REF, COM_ID FROM CHARGES WHERE ID = NEW.CHARGES_ID;

	/*OLD ACCOUNTING TABLES*/
	INSERT INTO CHARGES_ACCOUNT_DETAIL (C_ID, C_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.CHARGES_ID, NEW.ID, 23, NEW.FORM_AMOUNT, NEW.GL_ACC_ID, ENTRY_DATE, C_REF, COM_ID);
	/*OLD ACCOUNTING TABLES*/
	  

	/*NEW VERSION*/
	if(New.Form_Flag='P')
		then 
			INSERT INTO Payments_Accounting (Form_ID, Form_DETAIL_ID,Form_Flag,GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.CHARGES_ID, NEW.ID,'Charges', 90,case when NEW.FORM_AMOUNT<0 then NEW.FORM_AMOUNT*-1 else NEW.FORM_AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, C_REF, COM_ID);
		end if;
        
	if(New.Form_Flag='M')
		then 
			INSERT INTO Payments_Accounting (Form_ID, Form_DETAIL_ID,Form_Flag,GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.CHARGES_ID, NEW.ID,'Charges', 116, case when NEW.FORM_AMOUNT<0 then NEW.FORM_AMOUNT*-1 else NEW.FORM_AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, C_REF, COM_ID);
		end if;
        
	if(New.Form_Flag='R')
		then 
			INSERT INTO Payments_Accounting (Form_ID, Form_DETAIL_ID,Form_Flag,GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.CHARGES_ID, NEW.ID,'Charges', 117, case when NEW.FORM_AMOUNT<0 then NEW.FORM_AMOUNT*-1 else NEW.FORM_AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, C_REF, COM_ID);
		end if;
	/*NEW VERSION*/
		
END $$
DELIMITER ;

drop trigger if Exists TR_CHARGES_DETAIL_UPT;
DELIMITER $$
CREATE TRIGGER `TR_CHARGES_DETAIL_UPT` AFTER UPDATE ON `charges_detail` FOR EACH ROW BEGIN
	
	DECLARE ENTRY_DATE DATETIME;
	DECLARE C_REF VARCHAR(50);
	DECLARE COM_ID INT;

	SELECT C_ENTRY_DATE, C_REFERENCE, COMPANY_ID INTO ENTRY_DATE, C_REF, COM_ID FROM CHARGES WHERE ID = NEW.CHARGES_ID;
	
	/*OLD ACCOUNTING TABLES*/
	DELETE FROM CHARGES_ACCOUNT_DETAIL WHERE C_DETAIL_ID = OLD.ID;
	INSERT INTO CHARGES_ACCOUNT_DETAIL (C_ID, C_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.CHARGES_ID, NEW.ID, 23, NEW.FORM_AMOUNT, NEW.GL_ACC_ID, ENTRY_DATE, C_REF, COM_ID);
	/*OLD ACCOUNTING TABLES*/
	
	
	
	/*NEW VERSION*/
	DELETE FROM Payments_Accounting WHERE Form_DETAIL_ID = OLD.ID and Form_Flag='Charges';
	
	if(New.Form_Flag='P')
		then 
			INSERT INTO Payments_Accounting (Form_ID, Form_DETAIL_ID,Form_Flag,GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.CHARGES_ID, NEW.ID,'Charges', 90,case when NEW.FORM_AMOUNT<0 then NEW.FORM_AMOUNT*-1 else NEW.FORM_AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, C_REF, COM_ID);
		end if;
        
	if(New.Form_Flag='M')
		then 
			INSERT INTO Payments_Accounting (Form_ID, Form_DETAIL_ID,Form_Flag,GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.CHARGES_ID, NEW.ID,'Charges', 116, case when NEW.FORM_AMOUNT<0 then NEW.FORM_AMOUNT*-1 else NEW.FORM_AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, C_REF, COM_ID);
		end if;
        
	if(New.Form_Flag='R')
		then 
			INSERT INTO Payments_Accounting (Form_ID, Form_DETAIL_ID,Form_Flag,GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.CHARGES_ID, NEW.ID,'Charges', 117, case when NEW.FORM_AMOUNT<0 then NEW.FORM_AMOUNT*-1 else NEW.FORM_AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, C_REF, COM_ID);
		end if;
	/*NEW VERSION*/
	
END $$
DELIMITER ;

drop trigger if Exists TR_CHARGES_DETAIL_DEL;
DELIMITER $$
CREATE TRIGGER `TR_CHARGES_DETAIL_DEL` BEFORE DELETE ON `charges_detail` FOR EACH ROW BEGIN
	
	

		/*OLD ACCOUNTING TABLES*/
		DELETE FROM CHARGES_ACCOUNT_DETAIL WHERE C_DETAIL_ID = OLD.ID;
		/*OLD ACCOUNTING TABLES*/

		/*NEW VERSION*/
		DELETE FROM Payments_Accounting WHERE Form_DETAIL_ID = OLD.ID and Form_Flag='Charges';
		/*NEW VERSION*/
		
END $$
DELIMITER ;




drop trigger if Exists TR_PARTIAL_CREDIT;
DELIMITER $$
CREATE TRIGGER `TR_PARTIAL_CREDIT` AFTER INSERT ON `partial_credit` FOR EACH ROW BEGIN

	-- INSERT RECORD INTO PAYMENTS AND RECEIPTS TABLE
	CASE
		WHEN NEW.FORM_FLAG = 'R' THEN
			-- INSERT RECORD INTO PAYMENTS TABLE
			INSERT INTO PAYMENTS_DETAIL_NEW (VENDOR_ID, FORM_ID, FORM_F_ID, FORM_TRANSACTION_ID, FORM_AMOUNT, FORM_FLAG, COMPANY_ID)
			SELECT NEW.VENDOR_ID, NEW.ID, NEW.PC_ID, NEW.PAYPAL_TRANSACTION_ID, (-1 * NEW.TOTAL_AMOUNT), 'L', NEW.COMPANY_ID FROM DUAL;
		   
			-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
			INSERT INTO PARTIAL_CREDIT_ACCOUNT_DETAIL (PC_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ID, 32, NEW.TOTAL_AMOUNT, NEW.CASH_ACC_ID, NEW.PC_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);


		ELSE
			-- INSERT RECORD INTO RECEIPTS TABLE
			INSERT INTO RECEIPTS_DETAIL_NEW (CUSTOMER_ID, FORM_ID, FORM_F_ID, FORM_TRANSACTION_ID, FORM_AMOUNT, FORM_FLAG, COMPANY_ID)
			SELECT NEW.CUSTOMER_ID, NEW.ID, NEW.PC_ID, NEW.PAYPAL_TRANSACTION_ID, (-1 * NEW.TOTAL_AMOUNT), 'L', NEW.COMPANY_ID FROM DUAL;
		   
			-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
			INSERT INTO PARTIAL_CREDIT_ACCOUNT_DETAIL (PC_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ID, 34, NEW.TOTAL_AMOUNT, NEW.CASH_ACC_ID, NEW.PC_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);
	END CASE;
	
	
	/*NEW VERSION*/
	CASE
		WHEN NEW.FORM_FLAG = 'R' THEN
			
			INSERT INTO Purchase_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ID, 32,case when NEW.TOTAL_AMOUNT<0 then NEW.TOTAL_AMOUNT*-1 else NEW.TOTAL_AMOUNT end, NEW.CASH_ACC_ID, NEW.PC_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'PartialCredit');

		ELSE
		   INSERT INTO Purchase_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ID, 34,case when NEW.TOTAL_AMOUNT<0 then NEW.TOTAL_AMOUNT*-1 else NEW.TOTAL_AMOUNT end, NEW.CASH_ACC_ID, NEW.PC_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'PartialCredit');
	
	END CASE;
	/*NEW VERSION*/

	
END $$
DELIMITER ;

drop trigger if Exists TR_PARTIAL_CREDIT_UPT;
DELIMITER $$
CREATE TRIGGER `TR_PARTIAL_CREDIT_UPT` AFTER UPDATE ON `partial_credit` FOR EACH ROW BEGIN

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM PARTIAL_CREDIT_ACCOUNT_DETAIL WHERE PC_ID = OLD.ID AND PC_DETAIL_ID IS NULL;

	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	CASE
		WHEN NEW.FORM_FLAG = 'R' THEN
			INSERT INTO PARTIAL_CREDIT_ACCOUNT_DETAIL (PC_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ID, 32, NEW.TOTAL_AMOUNT, NEW.CASH_ACC_ID, NEW.PC_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);

		ELSE
			INSERT INTO PARTIAL_CREDIT_ACCOUNT_DETAIL (PC_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ID, 34, NEW.TOTAL_AMOUNT, NEW.CASH_ACC_ID, NEW.PC_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);
	END CASE;


	/*NEW VERSION*/
	DELETE FROM Purchase_Accounting WHERE Form_ID = OLD.ID AND Form_DETAIL_ID IS NULL and Form_Flag='PartialCredit';
	CASE
        WHEN NEW.FORM_FLAG = 'R' THEN
			INSERT INTO Purchase_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ID, 32, case when NEW.TOTAL_AMOUNT<0 then NEW.TOTAL_AMOUNT*-1 else NEW.TOTAL_AMOUNT end, NEW.CASH_ACC_ID, NEW.PC_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'PartialCredit');
		ELSE
			INSERT INTO Purchase_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ID, 34, case when NEW.TOTAL_AMOUNT<0 then NEW.TOTAL_AMOUNT*-1 else NEW.TOTAL_AMOUNT end, NEW.CASH_ACC_ID, NEW.PC_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'PartialCredit');
    END CASE;
	/*NEW VERSION*/
	
END $$
DELIMITER ;

drop trigger if Exists TR_PARTIAL_CREDIT_DEL;
DELIMITER $$
CREATE TRIGGER `TR_PARTIAL_CREDIT_DEL` BEFORE DELETE ON `partial_credit` FOR EACH ROW BEGIN

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM PARTIAL_CREDIT_ACCOUNT_DETAIL WHERE PC_ID = OLD.ID;


	/*NEW VERSION*/
	DELETE FROM Purchase_Accounting WHERE Form_ID = OLD.ID AND Form_DETAIL_ID IS NULL and Form_Flag='PartialCredit';
	/*NEW VERSION*/

END $$
DELIMITER ;

drop trigger if Exists TR_PARTIAL_CREDIT_DETAIL;
DELIMITER $$
CREATE TRIGGER `TR_PARTIAL_CREDIT_DETAIL` AFTER INSERT ON `partial_credit_detail` FOR EACH ROW BEGIN

	DECLARE ENTRY_DATE DATETIME;
	DECLARE PC_REF VARCHAR(50);
	DECLARE COM_ID INT;

	SELECT PC_ENTRY_DATE, PAYPAL_TRANSACTION_ID, COMPANY_ID INTO ENTRY_DATE, PC_REF, COM_ID FROM PARTIAL_CREDIT WHERE ID = NEW.PARTIAL_CREDIT_ID;
	
	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	CASE
	   WHEN NEW.RECEIVE_ORDER_DETAIL_ID IS NOT NULL THEN
		   INSERT INTO PARTIAL_CREDIT_ACCOUNT_DETAIL (PC_ID, PC_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.PARTIAL_CREDIT_ID, NEW.ID, 31, NEW.CREDIT_AMOUNT, NEW.GL_ACC_ID, ENTRY_DATE, PC_REF, COM_ID);
		   
	   WHEN NEW.RECEIVE_ORDER_DETAIL_ID IS NULL THEN
		   INSERT INTO PARTIAL_CREDIT_ACCOUNT_DETAIL (PC_ID, PC_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.PARTIAL_CREDIT_ID, NEW.ID, 33, NEW.CREDIT_AMOUNT, NEW.GL_ACC_ID, ENTRY_DATE, PC_REF, COM_ID);
	END CASE;


	/*NEW VERSION*/
	CASE
		WHEN NEW.RECEIVE_ORDER_DETAIL_ID IS NOT NULL THEN
			INSERT INTO Purchase_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.PARTIAL_CREDIT_ID, NEW.ID, 31,case when NEW.CREDIT_AMOUNT<0 then NEW.CREDIT_AMOUNT*-1 else NEW.CREDIT_AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, PC_REF, COM_ID,'PartialCredit');
		WHEN NEW.RECEIVE_ORDER_DETAIL_ID IS NULL THEN
			INSERT INTO Purchase_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.PARTIAL_CREDIT_ID, NEW.ID, 33,case when NEW.CREDIT_AMOUNT<0 then NEW.CREDIT_AMOUNT*-1 else NEW.CREDIT_AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, PC_REF, COM_ID,'PartialCredit');
    END CASE;
	/*NEW VERSION*/


END $$
DELIMITER ;

drop trigger if Exists TR_PARTIAL_CREDIT_DETAIL_UPT;
DELIMITER $$
CREATE TRIGGER `TR_PARTIAL_CREDIT_DETAIL_UPT` AFTER UPDATE ON `partial_credit_detail` FOR EACH ROW BEGIN
	
	DECLARE ENTRY_DATE DATETIME;
	DECLARE PC_REF VARCHAR(50);
	DECLARE COM_ID INT;
	
	SELECT PC_ENTRY_DATE, PAYPAL_TRANSACTION_ID, COMPANY_ID INTO ENTRY_DATE, PC_REF, COM_ID FROM PARTIAL_CREDIT WHERE ID = NEW.PARTIAL_CREDIT_ID;
	
	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM PARTIAL_CREDIT_ACCOUNT_DETAIL WHERE PC_DETAIL_ID = OLD.ID;
	
	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	CASE
	   WHEN NEW.RECEIVE_ORDER_DETAIL_ID IS NOT NULL THEN
		   INSERT INTO PARTIAL_CREDIT_ACCOUNT_DETAIL (PC_ID, PC_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.PARTIAL_CREDIT_ID, NEW.ID, 31, NEW.CREDIT_AMOUNT, NEW.GL_ACC_ID, ENTRY_DATE, PC_REF, COM_ID);
		   
	   WHEN NEW.RECEIVE_ORDER_DETAIL_ID IS NULL THEN
		   INSERT INTO PARTIAL_CREDIT_ACCOUNT_DETAIL (PC_ID, PC_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.PARTIAL_CREDIT_ID, NEW.ID, 33, NEW.CREDIT_AMOUNT, NEW.GL_ACC_ID, ENTRY_DATE, PC_REF, COM_ID);
	END CASE;


	/*NEW VERSION*/
	DELETE FROM Purchase_Accounting WHERE Form_DETAIL_ID = OLD.ID and Form_Flag='PartialCredit';   
	CASE
    
		WHEN NEW.RECEIVE_ORDER_DETAIL_ID IS NOT NULL THEN
	
			INSERT INTO Purchase_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.PARTIAL_CREDIT_ID, NEW.ID, 31, case when NEW.CREDIT_AMOUNT<0 then NEW.CREDIT_AMOUNT*-1 else NEW.CREDIT_AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, PC_REF, COM_ID,'PartialCredit'); 
    
			WHEN NEW.RECEIVE_ORDER_DETAIL_ID IS NULL THEN
	
			INSERT INTO Purchase_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.PARTIAL_CREDIT_ID, NEW.ID, 33, case when NEW.CREDIT_AMOUNT<0 then NEW.CREDIT_AMOUNT*-1 else NEW.CREDIT_AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, PC_REF, COM_ID,'PartialCredit');
    
	END CASE;
	/*NEW VERSION*/
	
END $$
DELIMITER ;

drop trigger if Exists TR_PARTIAL_CREDIT_DETAIL_DEL;
DELIMITER $$
CREATE  TRIGGER `TR_PARTIAL_CREDIT_DETAIL_DEL` BEFORE DELETE ON `partial_credit_detail` FOR EACH ROW BEGIN

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM PARTIAL_CREDIT_ACCOUNT_DETAIL WHERE PC_DETAIL_ID = OLD.ID;


	/*NEW VERSION*/
	DELETE FROM Purchase_Accounting WHERE Form_DETAIL_ID = OLD.ID and Form_Flag='PartialCredit';
	/*NEW VERSION*/

END $$
DELIMITER ;

drop trigger if Exists TR_RECEIVE_ORDER;
DELIMITER $$
CREATE TRIGGER `TR_RECEIVE_ORDER` AFTER INSERT ON `receive_order` FOR EACH ROW BEGIN

	-- INSERT RECORD INTO PAYMENTS TABLE
   INSERT INTO PAYMENTS_DETAIL_NEW (VENDOR_ID, FORM_ID, FORM_F_ID, FORM_TRANSACTION_ID, FORM_AMOUNT, FORM_FLAG, COMPANY_ID)
   SELECT NEW.VENDOR_ID, NEW.ID, NEW.RO_ID, NEW.PAYPAL_TRANSACTION_ID, NEW.RECEIVE_TOTAL_AMOUNT, 'R', NEW.COMPANY_ID FROM DUAL;
   
   -- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
   INSERT INTO RECEIVE_ORDER_ACCOUNT_DETAIL (RO_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ID, 38, NEW.RECEIVE_TOTAL_AMOUNT, NEW.AP_ACC_ID, NEW.RECEIVE_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);


	/*NEW VERSION*/
    INSERT INTO Purchase_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ID, 38,case when NEW.RECEIVE_TOTAL_AMOUNT<0 then NEW.RECEIVE_TOTAL_AMOUNT*-1 else NEW.RECEIVE_TOTAL_AMOUNT end, NEW.AP_ACC_ID, NEW.RECEIVE_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'ReceiveOrder');
	/*NEW VERSION*/

END $$
DELIMITER ;

drop trigger if Exists TR_RECEIVE_ORDER_UPT;
DELIMITER $$
CREATE TRIGGER `TR_RECEIVE_ORDER_UPT` AFTER UPDATE ON `receive_order` FOR EACH ROW BEGIN

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM RECEIVE_ORDER_ACCOUNT_DETAIL WHERE RO_ID = OLD.ID AND RO_DETAIL_ID IS NULL;

	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	INSERT INTO RECEIVE_ORDER_ACCOUNT_DETAIL (RO_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ID, 38, NEW.RECEIVE_TOTAL_AMOUNT, NEW.AP_ACC_ID, NEW.RECEIVE_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);


	/*NEW VERSION*/
	DELETE FROM Purchase_Accounting WHERE Form_ID = OLD.ID AND Form_DETAIL_ID IS NULL and Form_Flag='ReceiveOrder';
	INSERT INTO Purchase_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ID, 38, case when NEW.RECEIVE_TOTAL_AMOUNT<0 then NEW.RECEIVE_TOTAL_AMOUNT*-1 else NEW.RECEIVE_TOTAL_AMOUNT end, NEW.AP_ACC_ID, NEW.RECEIVE_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'ReceiveOrder');
	/*NEW VERSION*/

END $$
DELIMITER ;

drop trigger if Exists TR_RECEIVE_ORDER_DEL;
DELIMITER $$
CREATE TRIGGER `TR_RECEIVE_ORDER_DEL` BEFORE DELETE ON `receive_order` FOR EACH ROW BEGIN
	
	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM RECEIVE_ORDER_ACCOUNT_DETAIL WHERE RO_ID = OLD.ID;


	/*NEW VERSION*/
	 DELETE FROM Purchase_Accounting WHERE Form_ID = OLD.ID AND Form_DETAIL_ID IS NULL and Form_Flag='ReceiveOrder';
	/*NEW VERSION*/

END $$
DELIMITER ;

drop trigger if Exists TR_RECEIVE_ORDER_DETAIL;
DELIMITER $$
CREATE TRIGGER `TR_RECEIVE_ORDER_DETAIL` AFTER INSERT ON `receive_order_detail` FOR EACH ROW BEGIN

	DECLARE ENTRY_DATE DATETIME;
	DECLARE RO_REF VARCHAR(50);
	DECLARE COM_ID INT;

	SELECT RECEIVE_ENTRY_DATE, PAYPAL_TRANSACTION_ID, COMPANY_ID INTO ENTRY_DATE, RO_REF, COM_ID FROM RECEIVE_ORDER WHERE ID = NEW.RECEIVE_ORDER_ID;
	
	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	INSERT INTO RECEIVE_ORDER_ACCOUNT_DETAIL (RO_ID, RO_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.RECEIVE_ORDER_ID, NEW.ID, 37, NEW.AMOUNT, NEW.GL_ACC_ID, ENTRY_DATE, RO_REF, COM_ID);


	/*NEW VERSION*/
	INSERT INTO Purchase_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.RECEIVE_ORDER_ID, NEW.ID, 37,case when NEW.AMOUNT<0 then NEW.AMOUNT*-1 else NEW.AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, RO_REF, COM_ID,'ReceiveOrder');
	/*NEW VERSION*/

END $$
DELIMITER ;

drop trigger if Exists TR_RECEIVE_ORDER_DETAIL_UPT;
DELIMITER $$
CREATE TRIGGER `TR_RECEIVE_ORDER_DETAIL_UPT` AFTER UPDATE ON `receive_order_detail` FOR EACH ROW BEGIN

	DECLARE ENTRY_DATE DATETIME;
	DECLARE RO_REF VARCHAR(50);
	DECLARE COM_ID INT;

	SELECT RECEIVE_ENTRY_DATE, PAYPAL_TRANSACTION_ID, COMPANY_ID INTO ENTRY_DATE, RO_REF, COM_ID FROM RECEIVE_ORDER WHERE ID = NEW.RECEIVE_ORDER_ID;
	
	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM RECEIVE_ORDER_ACCOUNT_DETAIL WHERE RO_DETAIL_ID = OLD.ID;
	
	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	INSERT INTO RECEIVE_ORDER_ACCOUNT_DETAIL (RO_ID, RO_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.RECEIVE_ORDER_ID, NEW.ID, 37, NEW.AMOUNT, NEW.GL_ACC_ID, ENTRY_DATE, RO_REF, COM_ID);


	/*NEW VERSION*/
   	DELETE FROM Purchase_Accounting WHERE Form_DETAIL_ID = OLD.ID and Form_Flag='ReceiveOrder';
   	INSERT INTO Purchase_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.RECEIVE_ORDER_ID, NEW.ID, 37, case when NEW.AMOUNT<0 then NEW.AMOUNT*-1 else NEW.AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, RO_REF, COM_ID,'ReceiveOrder');
	/*NEW VERSION*/

END $$
DELIMITER ;

drop trigger if Exists TR_RECEIVE_ORDER_DETAIL_DEL;
DELIMITER $$
CREATE TRIGGER `TR_RECEIVE_ORDER_DETAIL_DEL` BEFORE DELETE ON `receive_order_detail` FOR EACH ROW BEGIN

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM RECEIVE_ORDER_ACCOUNT_DETAIL WHERE RO_DETAIL_ID = OLD.ID;


	/*NEW VERSION*/
	DELETE FROM Purchase_Accounting WHERE Form_DETAIL_ID = OLD.ID and Form_Flag='ReceiveOrder';
	/*NEW VERSION*/

END $$
DELIMITER ;

drop trigger if Exists TR_VENDOR_CREDIT_MEMO;
DELIMITER $$
CREATE TRIGGER `TR_VENDOR_CREDIT_MEMO` AFTER INSERT ON `vendor_credit_memo` FOR EACH ROW BEGIN

	-- INSERT RECORD INTO PAYMENTS TABLE
	INSERT INTO PAYMENTS_DETAIL_NEW (VENDOR_ID, FORM_ID, FORM_F_ID, FORM_TRANSACTION_ID, FORM_AMOUNT, FORM_FLAG, COMPANY_ID)
	SELECT NEW.VENDOR_ID, NEW.ID, NEW.VCM_ID, '', (-1 * NEW.VCM_TOTAL), 'V', NEW.COMPANY_ID FROM DUAL;

	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	INSERT INTO VENDOR_CREDIT_MEMO_ACCOUNT_DETAIL (VCM_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ID, 39, NEW.VCM_TOTAL, NEW.AP_ACC_ID, NEW.VCM_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);


	/*NEW VERSION*/
   	INSERT INTO Purchase_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ID, 39,case when NEW.VCM_TOTAL<0 then NEW.VCM_TOTAL*-1 else NEW.VCM_TOTAL end, NEW.AP_ACC_ID, NEW.VCM_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'VendorCreditMemo');
	/*NEW VERSION*/

END $$
DELIMITER ;

drop trigger if Exists TR_VENDOR_CREDIT_MEMO_UPT;
DELIMITER $$
CREATE TRIGGER `TR_VENDOR_CREDIT_MEMO_UPT` AFTER UPDATE ON `vendor_credit_memo` FOR EACH ROW BEGIN

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM VENDOR_CREDIT_MEMO_ACCOUNT_DETAIL WHERE VCM_ID = OLD.ID AND VCM_DETAIL_ID IS NULL;
	
	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	INSERT INTO VENDOR_CREDIT_MEMO_ACCOUNT_DETAIL (VCM_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ID, 39, NEW.VCM_TOTAL, NEW.AP_ACC_ID, NEW.VCM_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);


	/*NEW VERSION*/
   	DELETE FROM Purchase_Accounting WHERE Form_ID = OLD.ID AND Form_DETAIL_ID IS NULL and Form_Flag='VendorCreditMemo'; 
   	INSERT INTO Purchase_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ID, 39,case when NEW.VCM_TOTAL<0 then NEW.VCM_TOTAL*-1 else NEW.VCM_TOTAL end, NEW.AP_ACC_ID, NEW.VCM_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'VendorCreditMemo');
	/*NEW VERSION*/

END $$
DELIMITER ;

drop trigger if Exists TR_VENDOR_CREDIT_MEMO_DEL;
DELIMITER $$
CREATE TRIGGER `TR_VENDOR_CREDIT_MEMO_DEL` BEFORE DELETE ON `vendor_credit_memo` FOR EACH ROW BEGIN

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM VENDOR_CREDIT_MEMO_ACCOUNT_DETAIL WHERE VCM_ID = OLD.ID;


	/*NEW VERSION*/
	DELETE FROM Purchase_Accounting WHERE Form_ID = OLD.ID AND Form_DETAIL_ID IS NULL and Form_Flag='VendorCreditMemo';
	/*NEW VERSION*/

END $$
DELIMITER ;

drop trigger if Exists TR_VENDOR_CREDIT_MEMO_DETAIL;
DELIMITER $$
CREATE  TRIGGER `TR_VENDOR_CREDIT_MEMO_DETAIL` AFTER INSERT ON `vendor_credit_memo_detail` FOR EACH ROW BEGIN

	DECLARE ENTRY_DATE DATETIME;
	DECLARE VCM_REF VARCHAR(50);
	DECLARE COM_ID INT;

	SELECT VCM_ENTRY_DATE, PAYPAL_TRANSACTION_ID, COMPANY_ID INTO ENTRY_DATE, VCM_REF, COM_ID FROM VENDOR_CREDIT_MEMO WHERE ID = NEW.VENDOR_CREDIT_MEMO_ID;
	
	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	INSERT INTO VENDOR_CREDIT_MEMO_ACCOUNT_DETAIL (VCM_ID, VCM_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.VENDOR_CREDIT_MEMO_ID, NEW.ID, 40, NEW.AMOUNT, NEW.GL_ACC_ID, ENTRY_DATE, VCM_REF, COM_ID);


	/*NEW VERSION*/
   	INSERT INTO Purchase_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.VENDOR_CREDIT_MEMO_ID, NEW.ID, 40,case when NEW.AMOUNT<0 then NEW.AMOUNT*-1 else NEW.AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, VCM_REF, COM_ID,'VendorCreditMemo');
	/*NEW VERSION*/

END $$
DELIMITER ;

drop trigger if Exists TR_VENDOR_CREDIT_MEMO_DETAIL_UPT;
DELIMITER $$
CREATE TRIGGER `TR_VENDOR_CREDIT_MEMO_DETAIL_UPT` AFTER UPDATE ON `vendor_credit_memo_detail` FOR EACH ROW BEGIN

	DECLARE ENTRY_DATE DATETIME;
	DECLARE VCM_REF VARCHAR(50);
	DECLARE COM_ID INT;

	SELECT VCM_ENTRY_DATE, PAYPAL_TRANSACTION_ID, COMPANY_ID INTO ENTRY_DATE, VCM_REF, COM_ID FROM VENDOR_CREDIT_MEMO WHERE ID = NEW.VENDOR_CREDIT_MEMO_ID;
	
	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM VENDOR_CREDIT_MEMO_ACCOUNT_DETAIL WHERE VCM_DETAIL_ID = OLD.ID;
	
	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	INSERT INTO VENDOR_CREDIT_MEMO_ACCOUNT_DETAIL (VCM_ID, VCM_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.VENDOR_CREDIT_MEMO_ID, NEW.ID, 40, NEW.AMOUNT, NEW.GL_ACC_ID, ENTRY_DATE, VCM_REF, COM_ID);


	/*NEW VERSION*/
   	DELETE FROM Purchase_Accounting WHERE Form_DETAIL_ID = OLD.ID and Form_Flag='VendorCreditMemo';
	INSERT INTO Purchase_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.VENDOR_CREDIT_MEMO_ID, NEW.ID, 40, case when NEW.AMOUNT<0 then NEW.AMOUNT*-1 else NEW.AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, VCM_REF, COM_ID,'VendorCreditMemo');
	/*NEW VERSION*/

END $$
DELIMITER ;

drop trigger if Exists TR_VENDOR_CREDIT_MEMO_DETAIL_DEL;
DELIMITER $$
CREATE TRIGGER `TR_VENDOR_CREDIT_MEMO_DETAIL_DEL` BEFORE DELETE ON `vendor_credit_memo_detail` FOR EACH ROW BEGIN

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM VENDOR_CREDIT_MEMO_ACCOUNT_DETAIL WHERE VCM_DETAIL_ID = OLD.ID;


	/*NEW VERSION*/
	DELETE FROM Purchase_Accounting WHERE Form_DETAIL_ID = OLD.ID and Form_Flag='VendorCreditMemo';
	/*NEW VERSION*/

END $$
DELIMITER ;


drop trigger if Exists TR_SALE_INVOICE;
DELIMITER $$
CREATE TRIGGER `TR_SALE_INVOICE` AFTER INSERT ON `sale_invoice` FOR EACH ROW BEGIN

	-- INSERT RECORD INTO RECEIPTS TABLE
	INSERT INTO RECEIPTS_DETAIL_NEW (CUSTOMER_ID, FORM_ID, FORM_F_ID, FORM_TRANSACTION_ID, FORM_AMOUNT, FORM_FLAG, COMPANY_ID)
	SELECT NEW.CUSTOMER_ID, NEW.ID, NEW.SI_ID, NEW.PAYPAL_TRANSACTION_ID, NEW.SI_TOTAL, 'I', NEW.COMPANY_ID FROM DUAL;

	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	INSERT INTO SALE_INVOICE_ACCOUNT_DETAIL (SI_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ID, 41, (NEW.SI_TOTAL + NEW.DISCOUNT), NEW.AR_ACC_ID, NEW.SI_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);

	CASE
		WHEN NEW.SALES_TAX <> 0 THEN INSERT INTO SALE_INVOICE_ACCOUNT_DETAIL (SI_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) 
																	  VALUES (NEW.ID, 79, NEW.SALES_TAX, NEW.TAX_ACC_ID, NEW.SI_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);
		ELSE BEGIN END;
	END CASE;

	CASE
		WHEN NEW.FREIGHT_CHARGES <> 0 THEN INSERT INTO SALE_INVOICE_ACCOUNT_DETAIL (SI_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID)
																			VALUES (NEW.ID, 80, NEW.FREIGHT_CHARGES, NEW.FREIGHT_ACC_ID, NEW.SI_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);
		ELSE BEGIN END;
	END CASE;

	CASE
		WHEN NEW.MISCELLANEOUS_CHARGES <> 0 THEN INSERT INTO SALE_INVOICE_ACCOUNT_DETAIL (SI_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID)
																				  VALUES (NEW.ID, 81, NEW.MISCELLANEOUS_CHARGES, NEW.MISCELLANEOUS_ACC_ID, NEW.SI_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);
		ELSE BEGIN END;
	END CASE;


	/*NEW VERSION*/
	INSERT INTO Sales_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ID, 41, case when (NEW.SI_TOTAL + NEW.DISCOUNT)<0 then (NEW.SI_TOTAL + NEW.DISCOUNT) *-1 else (NEW.SI_TOTAL + NEW.DISCOUNT) end, NEW.AR_ACC_ID, NEW.SI_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'Saleinvoice');

	CASE
		WHEN NEW.SALES_TAX <> 0 THEN 
			INSERT INTO Sales_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) 
			VALUES (NEW.ID, 79, case when NEW.SALES_TAX<0 then NEW.SALES_TAX*-1 else NEW.SALES_TAX end, NEW.TAX_ACC_ID, NEW.SI_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'Saleinvoice');
        ELSE BEGIN END;
	END CASE;

	CASE
        WHEN NEW.FREIGHT_CHARGES <> 0 THEN 
		INSERT INTO Sales_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag)
		VALUES (NEW.ID, 80, case when NEW.FREIGHT_CHARGES<0 then NEW.FREIGHT_CHARGES*-1 else NEW.FREIGHT_CHARGES end, NEW.FREIGHT_ACC_ID, NEW.SI_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'Saleinvoice');
        ELSE BEGIN END;
	END CASE;

	CASE
        WHEN NEW.MISCELLANEOUS_CHARGES <> 0 then
		INSERT INTO Sales_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag)
	    VALUES (NEW.ID, 81,case when NEW.MISCELLANEOUS_CHARGES<0 then NEW.MISCELLANEOUS_CHARGES*-1 else NEW.MISCELLANEOUS_CHARGES end, NEW.MISCELLANEOUS_ACC_ID, NEW.SI_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'Saleinvoice');
        ELSE BEGIN END;
	END CASE;
	/*NEW VERSION*/

END $$
DELIMITER ;

drop trigger if Exists TR_SALE_INVOICE_UPT;
DELIMITER $$
CREATE TRIGGER `TR_SALE_INVOICE_UPT` AFTER UPDATE ON `sale_invoice` FOR EACH ROW BEGIN 
	
	-- REMOVE ALL SALE_INVOICE ROWS FROM SALE_INVOICE_ACCOUNT_DETAIL
	DELETE FROM SALE_INVOICE_ACCOUNT_DETAIL WHERE SI_ID = OLD.ID AND SI_DETAIL_ID IS NULL;

	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	INSERT INTO SALE_INVOICE_ACCOUNT_DETAIL (SI_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ID, 41, (NEW.SI_TOTAL + NEW.DISCOUNT), NEW.AR_ACC_ID, NEW.SI_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);

	CASE
		WHEN NEW.SALES_TAX <> 0 THEN INSERT INTO SALE_INVOICE_ACCOUNT_DETAIL (SI_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) 
																	  VALUES (NEW.ID, 79, NEW.SALES_TAX, NEW.TAX_ACC_ID, NEW.SI_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);
		ELSE BEGIN END;
	END CASE;

	CASE
		WHEN NEW.FREIGHT_CHARGES <> 0 THEN INSERT INTO SALE_INVOICE_ACCOUNT_DETAIL (SI_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID)
																			VALUES (NEW.ID, 80, NEW.FREIGHT_CHARGES, NEW.FREIGHT_ACC_ID, NEW.SI_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);
		ELSE BEGIN END;
	END CASE;

	CASE
		WHEN NEW.MISCELLANEOUS_CHARGES <> 0 THEN INSERT INTO SALE_INVOICE_ACCOUNT_DETAIL (SI_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID)
																				  VALUES (NEW.ID, 81, NEW.MISCELLANEOUS_CHARGES, NEW.MISCELLANEOUS_ACC_ID, NEW.SI_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);
		ELSE BEGIN END;
	END CASE;


	/*NEW VERSION*/
	DELETE FROM Sales_Accounting WHERE Form_ID = OLD.ID AND Form_DETAIL_ID IS NULL and Form_Flag='Saleinvoice';
	INSERT INTO Sales_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ID, 41, case when(NEW.SI_TOTAL + NEW.DISCOUNT)<0 then (NEW.SI_TOTAL + NEW.DISCOUNT)*-1 else (NEW.SI_TOTAL + NEW.DISCOUNT) end, NEW.AR_ACC_ID, NEW.SI_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'Saleinvoice');
	CASE
        WHEN NEW.SALES_TAX <> 0 THEN 
		INSERT INTO Sales_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) 
		VALUES (NEW.ID, 79,case when NEW.SALES_TAX<0 then NEW.SALES_TAX*-1 else NEW.SALES_TAX end, NEW.TAX_ACC_ID, NEW.SI_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'Saleinvoice');
        ELSE BEGIN END;
	END CASE;

	CASE
        WHEN NEW.FREIGHT_CHARGES <> 0 THEN 
		INSERT INTO Sales_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag)
		VALUES (NEW.ID, 80,case when NEW.FREIGHT_CHARGES<0 then NEW.FREIGHT_CHARGES*-1 else NEW.FREIGHT_CHARGES end, NEW.FREIGHT_ACC_ID, NEW.SI_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'Saleinvoice');
        ELSE BEGIN END;
	END CASE;

	CASE
        WHEN NEW.MISCELLANEOUS_CHARGES <> 0 THEN 
		INSERT INTO Sales_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag)
		VALUES (NEW.ID, 81,case when NEW.MISCELLANEOUS_CHARGES<0 then NEW.MISCELLANEOUS_CHARGES*-1 else NEW.MISCELLANEOUS_CHARGES end, NEW.MISCELLANEOUS_ACC_ID, NEW.SI_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'Saleinvoice');
        ELSE BEGIN END;
	END CASE;
	/*NEW VERSION*/
	
END $$
DELIMITER ;

drop trigger if Exists TR_SALE_INVOICE_DEL;
DELIMITER $$
CREATE  TRIGGER `TR_SALE_INVOICE_DEL` BEFORE DELETE ON `sale_invoice` FOR EACH ROW BEGIN

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM SALE_INVOICE_ACCOUNT_DETAIL WHERE SI_ID = OLD.ID;


	/*NEW VERSION*/
	DELETE FROM Sales_Accounting WHERE Form_ID = OLD.ID AND Form_DETAIL_ID IS NULL and Form_Flag='Saleinvoice';
	/*NEW VERSION*/

END $$
DELIMITER ;



drop trigger if Exists TR_SALE_INVOICE_DETAIL;
DELIMITER $$
CREATE TRIGGER `TR_SALE_INVOICE_DETAIL` AFTER INSERT ON `sale_invoice_detail` FOR EACH ROW BEGIN

	DECLARE ENTRY_DATE DATETIME;
	DECLARE SI_REF VARCHAR(50);
	DECLARE COM_ID INT;

	SELECT SI_ENTRY_DATE, PAYPAL_TRANSACTION_ID, COMPANY_ID INTO ENTRY_DATE, SI_REF, COM_ID FROM SALE_INVOICE WHERE ID = NEW.SALE_INVOICE_ID;

	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	INSERT INTO SALE_INVOICE_ACCOUNT_DETAIL (SI_ID, SI_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.SALE_INVOICE_ID, NEW.ID, 42, NEW.AMOUNT, NEW.GL_ACC_ID, ENTRY_DATE, SI_REF, COM_ID);
	INSERT INTO SALE_INVOICE_ACCOUNT_DETAIL (SI_ID, SI_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.SALE_INVOICE_ID, NEW.ID, 43, NEW.AMOUNT_OUT, NEW.COS_ACC_ID, ENTRY_DATE, SI_REF, COM_ID);
	INSERT INTO SALE_INVOICE_ACCOUNT_DETAIL (SI_ID, SI_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.SALE_INVOICE_ID, NEW.ID, 44, NEW.AMOUNT_OUT, NEW.INV_ACC_ID, ENTRY_DATE, SI_REF, COM_ID);


	/*NEW VERSION*/
	INSERT INTO Sales_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.SALE_INVOICE_ID, NEW.ID, 42,case when NEW.AMOUNT<0 then NEW.AMOUNT*-1 else NEW.AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, SI_REF, COM_ID,'Saleinvoice');
    INSERT INTO Sales_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.SALE_INVOICE_ID, NEW.ID, 43,case when NEW.AMOUNT_OUT<0 then NEW.AMOUNT_OUT*-1 else NEW.AMOUNT_OUT end, NEW.COS_ACC_ID, ENTRY_DATE, SI_REF, COM_ID,'Saleinvoice');
    INSERT INTO Sales_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.SALE_INVOICE_ID, NEW.ID, 44, case when NEW.AMOUNT_OUT<0 then NEW.AMOUNT_OUT*-1 else NEW.AMOUNT_OUT end, NEW.INV_ACC_ID, ENTRY_DATE, SI_REF, COM_ID,'Saleinvoice');
	/*NEW VERSION*/

END $$
DELIMITER ;

drop trigger if Exists TR_SALE_INVOICE_DETAIL_UPT;
DELIMITER $$
CREATE TRIGGER `TR_SALE_INVOICE_DETAIL_UPT` AFTER UPDATE ON `sale_invoice_detail` FOR EACH ROW BEGIN

	DECLARE ENTRY_DATE DATETIME;
	DECLARE SI_REF VARCHAR(50);
	DECLARE COM_ID INT;

	SELECT SI_ENTRY_DATE, PAYPAL_TRANSACTION_ID, COMPANY_ID INTO ENTRY_DATE, SI_REF, COM_ID FROM SALE_INVOICE WHERE ID = NEW.SALE_INVOICE_ID;
	
	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM SALE_INVOICE_ACCOUNT_DETAIL WHERE SI_DETAIL_ID = OLD.ID;

	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	INSERT INTO SALE_INVOICE_ACCOUNT_DETAIL (SI_ID, SI_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.SALE_INVOICE_ID, NEW.ID, 42, NEW.AMOUNT, NEW.GL_ACC_ID, ENTRY_DATE, SI_REF, COM_ID);
	INSERT INTO SALE_INVOICE_ACCOUNT_DETAIL (SI_ID, SI_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.SALE_INVOICE_ID, NEW.ID, 43, NEW.AMOUNT_OUT, NEW.COS_ACC_ID, ENTRY_DATE, SI_REF, COM_ID);
	INSERT INTO SALE_INVOICE_ACCOUNT_DETAIL (SI_ID, SI_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.SALE_INVOICE_ID, NEW.ID, 44, NEW.AMOUNT_OUT, NEW.INV_ACC_ID, ENTRY_DATE, SI_REF, COM_ID);


	/*NEW VERSION*/
	DELETE FROM Sales_Accounting WHERE Form_DETAIL_ID = OLD.ID and Form_Flag='Saleinvoice';
	INSERT INTO Sales_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.SALE_INVOICE_ID, NEW.ID, 42, case when NEW.AMOUNT<0 then NEW.AMOUNT*-1 else NEW.AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, SI_REF, COM_ID,'Saleinvoice');
    INSERT INTO Sales_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.SALE_INVOICE_ID, NEW.ID, 43,case when NEW.AMOUNT_OUT<0 then NEW.AMOUNT_OUT*-1 else NEW.AMOUNT_OUT end, NEW.COS_ACC_ID, ENTRY_DATE, SI_REF, COM_ID,'Saleinvoice');
    INSERT INTO Sales_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.SALE_INVOICE_ID, NEW.ID, 44, case when NEW.AMOUNT_OUT<0 then NEW.AMOUNT_OUT*-1 else NEW.AMOUNT_OUT end, NEW.INV_ACC_ID, ENTRY_DATE, SI_REF, COM_ID,'Saleinvoice');
	/*NEW VERSION*/

END $$
DELIMITER ;

drop trigger if Exists TR_SALE_INVOICE_DETAIL_DEL;
DELIMITER $$
CREATE TRIGGER `TR_SALE_INVOICE_DETAIL_DEL` BEFORE DELETE ON `sale_invoice_detail` FOR EACH ROW BEGIN

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM SALE_INVOICE_ACCOUNT_DETAIL WHERE SI_DETAIL_ID = OLD.ID;
	
	/*NEW VERSION*/
	DELETE FROM Sales_Accounting WHERE FORM_DETAIL_ID = OLD.ID and Form_Flag='Saleinvoice';
	/*NEW VERSION*/

END $$
DELIMITER ;

drop trigger if Exists TR_SALE_RETURN;
DELIMITER $$
CREATE TRIGGER `TR_SALE_RETURN` AFTER INSERT ON `sale_return` FOR EACH ROW BEGIN

	-- INSERT RECORD INTO RECEIPTS TABLE
	INSERT INTO RECEIPTS_DETAIL_NEW (CUSTOMER_ID, FORM_ID, FORM_F_ID, FORM_TRANSACTION_ID, FORM_AMOUNT, FORM_FLAG, COMPANY_ID)
	SELECT NEW.CUSTOMER_ID, NEW.ID, NEW.SR_ID, NEW.PAYPAL_TRANSACTION_ID, (-1 * NEW.SR_TOTAL), 'S', NEW.COMPANY_ID FROM DUAL;

	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	INSERT INTO SALE_RETURN_ACCOUNT_DETAIL (SR_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ID, 46, NEW.SR_TOTAL, NEW.AR_ACC_ID, NEW.SR_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);

	CASE
		WHEN NEW.SALES_TAX <> 0 THEN INSERT INTO SALE_RETURN_ACCOUNT_DETAIL (SR_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID)
																	 VALUES (NEW.ID, 82, NEW.SALES_TAX, NEW.TAX_ACC_ID, NEW.SR_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);
		ELSE BEGIN END;
	END CASE;

	CASE
		WHEN NEW.FREIGHT_CHARGES <> 0 THEN INSERT INTO SALE_RETURN_ACCOUNT_DETAIL (SR_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID)
																		   VALUES (NEW.ID, 83, NEW.FREIGHT_CHARGES, NEW.FREIGHT_ACC_ID, NEW.SR_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);
		ELSE BEGIN END;
	END CASE;

	CASE
		WHEN NEW.MISCELLANEOUS_CHARGES <> 0 THEN INSERT INTO SALE_RETURN_ACCOUNT_DETAIL (SR_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID)
																				 VALUES (NEW.ID, 84, NEW.MISCELLANEOUS_CHARGES, NEW.MISCELLANEOUS_ACC_ID, NEW.SR_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);
		ELSE BEGIN END;
	END CASE;


	/*NEW VERSION*/
	INSERT INTO Sales_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ID, 46,case when NEW.SR_TOTAL<0 then NEW.SR_TOTAL*-1 else NEW.SR_TOTAL end, NEW.AR_ACC_ID, NEW.SR_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'Salereturn');
	CASE
        WHEN NEW.SALES_TAX <> 0 THEN 
		INSERT INTO Sales_Accounting (Form_ID, GL_FLAG,AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag)
		VALUES (NEW.ID, 82,case when NEW.SALES_TAX<0 then NEW.SALES_TAX*-1 else NEW.SALES_TAX end, NEW.TAX_ACC_ID, NEW.SR_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'Salereturn');
        ELSE BEGIN END;
	END CASE;

	CASE
        WHEN NEW.FREIGHT_CHARGES <> 0 THEN 
		INSERT INTO Sales_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag)
	    VALUES (NEW.ID, 83,case when NEW.FREIGHT_CHARGES<0 then NEW.FREIGHT_CHARGES*-1 else NEW.FREIGHT_CHARGES end, NEW.FREIGHT_ACC_ID, NEW.SR_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'Salereturn');
        ELSE BEGIN END;
	END CASE;

	CASE
        WHEN NEW.MISCELLANEOUS_CHARGES <> 0 THEN
		INSERT INTO Sales_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag)
		VALUES (NEW.ID, 84,case when NEW.MISCELLANEOUS_CHARGES<0 then NEW.MISCELLANEOUS_CHARGES*-1 else NEW.MISCELLANEOUS_CHARGES end, NEW.MISCELLANEOUS_ACC_ID, NEW.SR_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'Salereturn');
        ELSE BEGIN END;
	END CASE;
	/*NEW VERSION*/

END $$
DELIMITER ;

drop trigger if Exists TR_SALE_RETURN_UPT;
DELIMITER $$
CREATE TRIGGER `TR_SALE_RETURN_UPT` AFTER UPDATE ON `sale_return` FOR EACH ROW BEGIN 

	-- REMOVE ALL SALE_RETURN ROWS FROM SALE_RETURN_ACCOUNT_DETAIL
	DELETE FROM SALE_RETURN_ACCOUNT_DETAIL WHERE SR_ID = OLD.ID AND SR_DETAIL_ID IS NULL;

	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	INSERT INTO SALE_RETURN_ACCOUNT_DETAIL (SR_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ID, 46, NEW.SR_TOTAL, NEW.AR_ACC_ID, NEW.SR_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);

	CASE
		WHEN NEW.SALES_TAX <> 0 THEN INSERT INTO SALE_RETURN_ACCOUNT_DETAIL (SR_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID)
																	 VALUES (NEW.ID, 82, NEW.SALES_TAX, NEW.TAX_ACC_ID, NEW.SR_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);
		ELSE BEGIN END;
	END CASE;

	CASE
		WHEN NEW.FREIGHT_CHARGES <> 0 THEN INSERT INTO SALE_RETURN_ACCOUNT_DETAIL (SR_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID)
																		   VALUES (NEW.ID, 83, NEW.FREIGHT_CHARGES, NEW.FREIGHT_ACC_ID, NEW.SR_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);
		ELSE BEGIN END;
	END CASE;

	CASE
		WHEN NEW.MISCELLANEOUS_CHARGES <> 0 THEN INSERT INTO SALE_RETURN_ACCOUNT_DETAIL (SR_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID)
																				 VALUES (NEW.ID, 84, NEW.MISCELLANEOUS_CHARGES, NEW.MISCELLANEOUS_ACC_ID, NEW.SR_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);
		ELSE BEGIN END;
	END CASE;


	/*NEW VERSION*/
	
	-- REMOVE ALL SALE_RETURN ROWS FROM SALE_RETURN_ACCOUNT_DETAIL
	DELETE FROM Sales_Accounting WHERE Form_ID = OLD.ID AND Form_DETAIL_ID IS NULL and Form_Flag='Salereturn';
	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
    
	INSERT INTO Sales_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ID, 46,case when NEW.SR_TOTAL<0 then NEW.SR_TOTAL*-1 else NEW.SR_TOTAL end, NEW.AR_ACC_ID, NEW.SR_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'Salereturn');

    CASE
    
        WHEN NEW.SALES_TAX <> 0 THEN 
		INSERT INTO Sales_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag)
		VALUES (NEW.ID, 82,case when NEW.SALES_TAX<0 then NEW.SALES_TAX*-1 else NEW.SALES_TAX end, NEW.TAX_ACC_ID, NEW.SR_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'Salereturn');
        ELSE BEGIN END;
	END CASE;

	CASE
    
        WHEN NEW.FREIGHT_CHARGES <> 0 THEN 
		INSERT INTO Sales_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag)
		VALUES (NEW.ID, 83,case when NEW.FREIGHT_CHARGES<0 then NEW.FREIGHT_CHARGES*-1 else NEW.FREIGHT_CHARGES end, NEW.FREIGHT_ACC_ID, NEW.SR_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'Salereturn');
        ELSE BEGIN END;
	END CASE;

	CASE
    
		
        WHEN NEW.MISCELLANEOUS_CHARGES <> 0 THEN 
		INSERT INTO Sales_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag)
		VALUES (NEW.ID, 84,case when NEW.MISCELLANEOUS_CHARGES<0 then NEW.MISCELLANEOUS_CHARGES*-1 else NEW.MISCELLANEOUS_CHARGES end, NEW.MISCELLANEOUS_ACC_ID, NEW.SR_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'Salereturn');
        ELSE BEGIN END;
	END CASE;
	
	/*NEW VERSION*/
	
END $$
DELIMITER ;

drop trigger if Exists TR_SALE_RETURN_DEL;
DELIMITER $$
CREATE TRIGGER `TR_SALE_RETURN_DEL` BEFORE DELETE ON `sale_return` FOR EACH ROW BEGIN

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM SALE_RETURN_ACCOUNT_DETAIL WHERE SR_ID = OLD.ID;


	/*NEW VERSION*/
	DELETE FROM Sales_Accounting WHERE Form_ID = OLD.ID AND Form_DETAIL_ID IS NULL and Form_Flag='Salereturn';
	/*NEW VERSION*/

END $$
DELIMITER ;

drop trigger if Exists TR_SALE_RETURN_DETAIL;
DELIMITER $$
CREATE TRIGGER `TR_SALE_RETURN_DETAIL` AFTER INSERT ON `sale_return_detail` FOR EACH ROW BEGIN

	DECLARE ENTRY_DATE DATETIME;
	DECLARE SR_REF VARCHAR(50);
	DECLARE COM_ID INT;
   
	SELECT SR_ENTRY_DATE, PAYPAL_TRANSACTION_ID, COMPANY_ID INTO ENTRY_DATE, SR_REF, COM_ID FROM SALE_RETURN WHERE ID = NEW.SALE_RETURN_ID;

	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	INSERT INTO SALE_RETURN_ACCOUNT_DETAIL (SR_ID, SR_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.SALE_RETURN_ID, NEW.ID, 45, NEW.AMOUNT, NEW.GL_ACC_ID, ENTRY_DATE, SR_REF, COM_ID);
	INSERT INTO SALE_RETURN_ACCOUNT_DETAIL (SR_ID, SR_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.SALE_RETURN_ID, NEW.ID, 47, NEW.AMOUNT_OUT, NEW.COS_ACC_ID, ENTRY_DATE, SR_REF, COM_ID);
	INSERT INTO SALE_RETURN_ACCOUNT_DETAIL (SR_ID, SR_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.SALE_RETURN_ID, NEW.ID, 48, NEW.AMOUNT_OUT, NEW.INV_ACC_ID, ENTRY_DATE, SR_REF, COM_ID);


	/*NEW VERSION*/
	INSERT INTO Sales_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.SALE_RETURN_ID, NEW.ID, 45,case when NEW.AMOUNT<0 then NEW.AMOUNT*-1 else NEW.AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, SR_REF, COM_ID,'Salereturn');
    INSERT INTO Sales_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.SALE_RETURN_ID, NEW.ID, 47,case when NEW.AMOUNT_OUT<0 then NEW.AMOUNT_OUT*-1 else NEW.AMOUNT_OUT end, NEW.COS_ACC_ID, ENTRY_DATE, SR_REF, COM_ID,'Salereturn');
    INSERT INTO Sales_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.SALE_RETURN_ID, NEW.ID, 48, case when NEW.AMOUNT_OUT<0 then NEW.AMOUNT_OUT*-1 else NEW.AMOUNT_OUT end, NEW.INV_ACC_ID, ENTRY_DATE, SR_REF, COM_ID,'Salereturn');
	/*NEW VERSION*/
	

END $$
DELIMITER ;

drop trigger if Exists TR_SALE_RETURN_DETAIL_UPT;
DELIMITER $$
CREATE TRIGGER `TR_SALE_RETURN_DETAIL_UPT` AFTER UPDATE ON `sale_return_detail` FOR EACH ROW BEGIN

	DECLARE ENTRY_DATE DATETIME;
	DECLARE SR_REF VARCHAR(50);
	DECLARE COM_ID INT;

	SELECT SR_ENTRY_DATE, PAYPAL_TRANSACTION_ID, COMPANY_ID INTO ENTRY_DATE, SR_REF, COM_ID FROM SALE_RETURN WHERE ID = NEW.SALE_RETURN_ID;

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM SALE_RETURN_ACCOUNT_DETAIL WHERE SR_DETAIL_ID = OLD.ID;

	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	INSERT INTO SALE_RETURN_ACCOUNT_DETAIL (SR_ID, SR_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.SALE_RETURN_ID, NEW.ID, 45, NEW.AMOUNT, NEW.GL_ACC_ID, ENTRY_DATE, SR_REF, COM_ID);
	INSERT INTO SALE_RETURN_ACCOUNT_DETAIL (SR_ID, SR_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.SALE_RETURN_ID, NEW.ID, 47, NEW.AMOUNT_OUT, NEW.COS_ACC_ID, ENTRY_DATE, SR_REF, COM_ID);
	INSERT INTO SALE_RETURN_ACCOUNT_DETAIL (SR_ID, SR_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.SALE_RETURN_ID, NEW.ID, 48, NEW.AMOUNT_OUT, NEW.INV_ACC_ID, ENTRY_DATE, SR_REF, COM_ID);


	/*NEW VERSION*/
	DELETE FROM Sales_Accounting WHERE Form_DETAIL_ID = OLD.ID and Form_Flag='Salereturn';
	INSERT INTO Sales_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.SALE_RETURN_ID, NEW.ID, 45,case when NEW.AMOUNT<0 then NEW.AMOUNT*-1 else NEW.AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, SR_REF, COM_ID,'Salereturn');
    INSERT INTO Sales_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.SALE_RETURN_ID, NEW.ID, 47, case when NEW.AMOUNT_OUT<0 then NEW.AMOUNT_OUT*-1 else NEW.AMOUNT_OUT end, NEW.COS_ACC_ID, ENTRY_DATE, SR_REF, COM_ID,'Salereturn');
    INSERT INTO Sales_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.SALE_RETURN_ID, NEW.ID, 48, case when NEW.AMOUNT_OUT<0 then NEW.AMOUNT_OUT*-1 else NEW.AMOUNT_OUT end, NEW.INV_ACC_ID, ENTRY_DATE, SR_REF, COM_ID,'Salereturn');
	/*NEW VERSION*/

END $$
DELIMITER ;

drop trigger if Exists TR_SALE_RETURN_DETAIL_DEL;
DELIMITER $$
CREATE TRIGGER `TR_SALE_RETURN_DETAIL_DEL` BEFORE DELETE ON `sale_return_detail` FOR EACH ROW BEGIN

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM SALE_RETURN_ACCOUNT_DETAIL WHERE SR_DETAIL_ID = OLD.ID;


	/*NEW VERSION*/
	DELETE FROM Sales_Accounting WHERE Form_DETAIL_ID = OLD.ID and Form_Flag='Salereturn';
	/*NEW VERSION*/

END $$
DELIMITER ;

drop trigger if Exists TR_REPLACEMENT;
DELIMITER $$
CREATE TRIGGER `TR_REPLACEMENT` AFTER INSERT ON `replacement` FOR EACH ROW BEGIN

	DECLARE IS_EXECUTE VARCHAR (5) DEFAULT 'N';
    DECLARE AMOUNT_REP DECIMAL(22, 2) DEFAULT 0;

	CASE
		WHEN ABS(NEW.TOTAL_AMOUNT) > ABS(NEW.APPLIED_AMOUNT) THEN
			SET AMOUNT_REP := NEW.BALANCE;
			SET IS_EXECUTE := 'Y';
		ELSE
			SET AMOUNT_REP := 0;
	END CASE;

	-- INSERT RECORD INTO RECEIPTS TABLE
    CASE
		WHEN IS_EXECUTE = 'Y' THEN
			INSERT INTO RECEIPTS_DETAIL_NEW (CUSTOMER_ID, FORM_ID, FORM_F_ID, FORM_TRANSACTION_ID, FORM_AMOUNT, FORM_FLAG, COMPANY_ID)
			SELECT NEW.CUSTOMER_ID, NEW.ID, NEW.REP_ID, NEW.PAYPAL_TRANSACTION_ID, AMOUNT_REP, 'E', NEW.COMPANY_ID FROM DUAL;
		ELSE
		   INSERT INTO RECEIPTS_DETAIL_NEW (CUSTOMER_ID, FORM_ID, FORM_F_ID, FORM_TRANSACTION_ID, FORM_AMOUNT, FORM_FLAG, IS_CONFLICTED_FULL, COMPANY_ID)
		   SELECT NEW.CUSTOMER_ID, NEW.ID, NEW.REP_ID, NEW.PAYPAL_TRANSACTION_ID, 0, 'E', 'Y', NEW.COMPANY_ID FROM DUAL;
	END CASE;
   
	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	CASE
		WHEN NEW.AMOUNT_RETURN <> 0 THEN INSERT INTO REPLACEMENT_ACCOUNT_DETAIL (REP_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID)
																		 VALUES (NEW.ID, 50, (NEW.AMOUNT_RETURN * -1), NEW.AR_ACC_ID, NEW.REP_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);
		ELSE BEGIN END;
	END CASE;
    
	CASE
		WHEN NEW.AMOUNT_ISSUE <> 0 THEN CASE
											WHEN NEW.SALES_TAX < 0 THEN INSERT INTO REPLACEMENT_ACCOUNT_DETAIL (REP_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID)
																										VALUES (NEW.ID, 53, (NEW.AMOUNT_ISSUE + (NEW.SALES_TAX * -1) + NEW.FREIGHT_CHARGES + NEW.MISCELLANEOUS_CHARGES), NEW.AR_ACC_ID, NEW.REP_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);
											ELSE INSERT INTO REPLACEMENT_ACCOUNT_DETAIL (REP_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID)
																				 VALUES (NEW.ID, 53, (NEW.AMOUNT_ISSUE + NEW.SALES_TAX + NEW.FREIGHT_CHARGES + NEW.MISCELLANEOUS_CHARGES), NEW.AR_ACC_ID, NEW.REP_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);
											END CASE;
		ELSE BEGIN END;
	END CASE;
    
	CASE
		WHEN NEW.SALES_TAX > 0 THEN INSERT INTO REPLACEMENT_ACCOUNT_DETAIL (REP_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID)
																	 VALUES (NEW.ID, 85, NEW.SALES_TAX, NEW.TAX_ACC_ID, NEW.REP_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);
		WHEN NEW.SALES_TAX < 0 THEN INSERT INTO REPLACEMENT_ACCOUNT_DETAIL (REP_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID)
																	 VALUES (NEW.ID, 85, (NEW.SALES_TAX * -1), NEW.TAX_ACC_ID, NEW.REP_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);
		ELSE BEGIN END;
	END CASE;
    
    CASE
		WHEN NEW.FREIGHT_CHARGES <> 0 THEN INSERT INTO REPLACEMENT_ACCOUNT_DETAIL (REP_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID)
																		   VALUES (NEW.ID, 86, NEW.FREIGHT_CHARGES, NEW.FREIGHT_ACC_ID, NEW.REP_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);
        ELSE BEGIN END;
    END CASE;
    
    CASE
		WHEN NEW.MISCELLANEOUS_CHARGES <> 0 THEN INSERT INTO REPLACEMENT_ACCOUNT_DETAIL (REP_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID)
																				 VALUES (NEW.ID, 87, NEW.MISCELLANEOUS_CHARGES, NEW.MISCELLANEOUS_ACC_ID, NEW.REP_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);
        ELSE BEGIN END;
    END CASE;


	/*NEW VERSION*/
    if(NEW.AMOUNT_RETURN <> 0)
		then
			INSERT INTO Sales_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag)
			VALUES (NEW.ID, 50,(case when NEW.AMOUNT_RETURN<0 then NEW.AMOUNT_RETURN* -1 else NEW.AMOUNT_RETURN end), NEW.AR_ACC_ID, NEW.REP_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'Replacement');
	end if;		
	    
	if(NEW.AMOUNT_ISSUE <> 0)
		then
			INSERT INTO Sales_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag)
			VALUES (NEW.ID, 53,case when (NEW.AMOUNT_ISSUE+NEW.MISCELLANEOUS_CHARGES+NEW.FREIGHT_CHARGES+New.SALES_TAX) <0 then (NEW.AMOUNT_ISSUE+NEW.MISCELLANEOUS_CHARGES+NEW.FREIGHT_CHARGES+New.SALES_TAX) *-1 else (NEW.AMOUNT_ISSUE+NEW.MISCELLANEOUS_CHARGES+NEW.FREIGHT_CHARGES+New.SALES_TAX) end, NEW.AR_ACC_ID, NEW.REP_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'Replacement');
		end if;
    
    
    if(NEW.SALES_TAX > 0)
		then 
		     -- Replacement will Credit Tax Account when greater than zero
			INSERT INTO Sales_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag)
			VALUES (NEW.ID, 85,NEW.SALES_TAX, NEW.TAX_ACC_ID, NEW.REP_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'Replacement');
		     -- Replacement will Debit Tax Account when less than zero
		    
	end if;
    
    if(NEW.SALES_TAX<0)
		then
			INSERT INTO Sales_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag)
			VALUES (NEW.ID,100, NEW.SALES_TAX* -1, NEW.TAX_ACC_ID, NEW.REP_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'Replacement');
	end if;
    
    CASE
    
    -- Replacement will Credit Freight Account
    WHEN NEW.FREIGHT_CHARGES <> 0 THEN 
	
	INSERT INTO Sales_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag)
	VALUES (NEW.ID, 86,case when NEW.FREIGHT_CHARGES<0 then NEW.FREIGHT_CHARGES* -1 else NEW.FREIGHT_CHARGES end, NEW.FREIGHT_ACC_ID, NEW.REP_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'Replacement');
    ELSE BEGIN END;  
    END CASE;
    
    CASE
      WHEN NEW.MISCELLANEOUS_CHARGES <> 0 THEN 
	  INSERT INTO Sales_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag)
	  VALUES (NEW.ID, 87,case when NEW.MISCELLANEOUS_CHARGES<0 then NEW.MISCELLANEOUS_CHARGES* -1 else NEW.MISCELLANEOUS_CHARGES end, NEW.MISCELLANEOUS_ACC_ID, NEW.REP_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'Replacement');
	ELSE BEGIN END;  
    END CASE;
	/*NEW VERSION*/
	
	
END $$
DELIMITER ;

drop trigger if Exists TR_REPLACEMENT_UPT;
DELIMITER $$
CREATE TRIGGER `TR_REPLACEMENT_UPT` AFTER UPDATE ON `replacement` FOR EACH ROW BEGIN

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM REPLACEMENT_ACCOUNT_DETAIL WHERE REP_ID = OLD.ID AND REP_DETAIL_ID IS NULL;
	
	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	CASE
		WHEN NEW.AMOUNT_RETURN <> 0 THEN INSERT INTO REPLACEMENT_ACCOUNT_DETAIL (REP_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID)
																		 VALUES (NEW.ID, 50, (NEW.AMOUNT_RETURN * -1), NEW.AR_ACC_ID, NEW.REP_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);
		ELSE BEGIN END;
	END CASE;
    
	CASE
		WHEN NEW.AMOUNT_ISSUE <> 0 THEN CASE
											WHEN NEW.SALES_TAX < 0 THEN INSERT INTO REPLACEMENT_ACCOUNT_DETAIL (REP_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID)
																										VALUES (NEW.ID, 53, (NEW.AMOUNT_ISSUE + (NEW.SALES_TAX * -1) + NEW.FREIGHT_CHARGES + NEW.MISCELLANEOUS_CHARGES), NEW.AR_ACC_ID, NEW.REP_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);
											ELSE INSERT INTO REPLACEMENT_ACCOUNT_DETAIL (REP_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID)
																				 VALUES (NEW.ID, 53, (NEW.AMOUNT_ISSUE + NEW.SALES_TAX + NEW.FREIGHT_CHARGES + NEW.MISCELLANEOUS_CHARGES), NEW.AR_ACC_ID, NEW.REP_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);
											END CASE;
		ELSE BEGIN END;
	END CASE;
    
	CASE
		WHEN NEW.SALES_TAX > 0 THEN INSERT INTO REPLACEMENT_ACCOUNT_DETAIL (REP_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID)
																	 VALUES (NEW.ID, 85, NEW.SALES_TAX, NEW.TAX_ACC_ID, NEW.REP_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);
		WHEN NEW.SALES_TAX < 0 THEN INSERT INTO REPLACEMENT_ACCOUNT_DETAIL (REP_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID)
																	 VALUES (NEW.ID, 85, (NEW.SALES_TAX * -1), NEW.TAX_ACC_ID, NEW.REP_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);
		ELSE BEGIN END;
	END CASE;
    
    CASE
		WHEN NEW.FREIGHT_CHARGES <> 0 THEN INSERT INTO REPLACEMENT_ACCOUNT_DETAIL (REP_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID)
																		   VALUES (NEW.ID, 86, NEW.FREIGHT_CHARGES, NEW.FREIGHT_ACC_ID, NEW.REP_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);
        ELSE BEGIN END;
    END CASE;
    
    CASE
		WHEN NEW.MISCELLANEOUS_CHARGES <> 0 THEN INSERT INTO REPLACEMENT_ACCOUNT_DETAIL (REP_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID)
																				 VALUES (NEW.ID, 87, NEW.MISCELLANEOUS_CHARGES, NEW.MISCELLANEOUS_ACC_ID, NEW.REP_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID);
        ELSE BEGIN END;
    END CASE;


	/*NEW VERSION*/
	DELETE FROM Sales_Accounting WHERE Form_ID = OLD.ID AND Form_DETAIL_ID IS NULL and Form_Flag='Replacement';
	CASE
        WHEN NEW.AMOUNT_RETURN <> 0 THEN
		INSERT INTO Sales_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag)
		VALUES (NEW.ID, 50, (case when NEW.AMOUNT_RETURN<0 then NEW.AMOUNT_RETURN* -1 else NEW.AMOUNT_RETURN end), NEW.AR_ACC_ID, NEW.REP_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'Replacement');
        ELSE BEGIN END;
	END CASE;
    if(NEW.AMOUNT_ISSUE <> 0)
	then
		INSERT INTO Sales_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag)
		VALUES (NEW.ID, 53,case when (NEW.AMOUNT_ISSUE+NEW.MISCELLANEOUS_CHARGES+NEW.FREIGHT_CHARGES+New.SALES_TAX) <0 then (NEW.AMOUNT_ISSUE+NEW.MISCELLANEOUS_CHARGES+NEW.FREIGHT_CHARGES+New.SALES_TAX) *-1 else (NEW.AMOUNT_ISSUE+NEW.MISCELLANEOUS_CHARGES+NEW.FREIGHT_CHARGES+New.SALES_TAX) end, NEW.AR_ACC_ID, NEW.REP_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'Replacement');
	end if;
    if(NEW.SALES_TAX > 0)
	then 
		 -- Replacement will Credit Tax Account when greater than zero
			INSERT INTO Sales_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag)
			VALUES (NEW.ID,85,case when NEW.SALES_TAX<0 then NEW.SALES_TAX* -1 else NEW.SALES_TAX end, NEW.TAX_ACC_ID, NEW.REP_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'Replacement');
	else 
			-- Replacement will Debit Tax Account when less than zero
			INSERT INTO Sales_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag)
			VALUES (NEW.ID,100, (case when NEW.SALES_TAX<0 then NEW.SALES_TAX* -1 else NEW.SALES_TAX end), NEW.TAX_ACC_ID, NEW.REP_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'Replacement');
	end if;
    CASE
      WHEN NEW.FREIGHT_CHARGES <> 0 THEN 
	  INSERT INTO Sales_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag)
	  VALUES (NEW.ID, 86,case when NEW.FREIGHT_CHARGES<0 then NEW.FREIGHT_CHARGES* -1 else NEW.FREIGHT_CHARGES end, NEW.FREIGHT_ACC_ID, NEW.REP_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'Replacement');
      ELSE BEGIN END;
    END CASE;
    CASE
      WHEN NEW.MISCELLANEOUS_CHARGES <> 0 THEN 
	  INSERT INTO Sales_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag)
	   VALUES (NEW.ID, 87,case when NEW.MISCELLANEOUS_CHARGES<0 then NEW.MISCELLANEOUS_CHARGES* -1 else NEW.MISCELLANEOUS_CHARGES end, NEW.MISCELLANEOUS_ACC_ID, NEW.REP_ENTRY_DATE, NEW.PAYPAL_TRANSACTION_ID, NEW.COMPANY_ID,'Replacement');
      ELSE BEGIN END;
    END CASE;
	/*NEW VERSION*/


END $$
DELIMITER ;

drop trigger if Exists TR_REPLACEMENT_DEL;
DELIMITER $$
CREATE TRIGGER `TR_REPLACEMENT_DEL` BEFORE DELETE ON `replacement` FOR EACH ROW BEGIN

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM REPLACEMENT_ACCOUNT_DETAIL WHERE REP_ID = OLD.ID;


	/*NEW VERSION*/
	DELETE FROM Sales_Accounting WHERE Form_ID = OLD.ID AND Form_DETAIL_ID IS NULL and Form_Flag='Replacement';
	/*NEW VERSION*/

END $$
DELIMITER ;

drop trigger if Exists TR_REPLACEMENT_DETAIL;
DELIMITER $$
CREATE TRIGGER `TR_REPLACEMENT_DETAIL` AFTER INSERT ON `replacement_detail` FOR EACH ROW BEGIN

	DECLARE ENTRY_DATE DATETIME;
	DECLARE REP_REF VARCHAR(50);
	DECLARE COM_ID INT;

	SELECT REP_ENTRY_DATE, PAYPAL_TRANSACTION_ID, COMPANY_ID INTO ENTRY_DATE, REP_REF, COM_ID FROM REPLACEMENT WHERE ID = NEW.REPLACEMENT_ID;

	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	CASE
		WHEN NEW.IS_RETURN = 'Y' THEN
			INSERT INTO REPLACEMENT_ACCOUNT_DETAIL (REP_ID, REP_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.REPLACEMENT_ID, NEW.ID, 49, NEW.AMOUNT, NEW.GL_ACC_ID, ENTRY_DATE, REP_REF, COM_ID);
		    INSERT INTO REPLACEMENT_ACCOUNT_DETAIL (REP_ID, REP_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.REPLACEMENT_ID, NEW.ID, 51, NEW.AMOUNT_OUT, NEW.COS_ACC_ID, ENTRY_DATE, REP_REF, COM_ID);
		    INSERT INTO REPLACEMENT_ACCOUNT_DETAIL (REP_ID, REP_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.REPLACEMENT_ID, NEW.ID, 52, NEW.AMOUNT_OUT, NEW.INV_ACC_ID, ENTRY_DATE, REP_REF, COM_ID);
		   
		ELSE
			INSERT INTO REPLACEMENT_ACCOUNT_DETAIL (REP_ID, REP_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.REPLACEMENT_ID, NEW.ID, 54, NEW.AMOUNT, NEW.GL_ACC_ID, ENTRY_DATE, REP_REF, COM_ID);
			INSERT INTO REPLACEMENT_ACCOUNT_DETAIL (REP_ID, REP_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.REPLACEMENT_ID, NEW.ID, 55, NEW.AMOUNT_OUT, NEW.COS_ACC_ID, ENTRY_DATE, REP_REF, COM_ID);
			INSERT INTO REPLACEMENT_ACCOUNT_DETAIL (REP_ID, REP_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.REPLACEMENT_ID, NEW.ID, 56, NEW.AMOUNT_OUT, NEW.INV_ACC_ID, ENTRY_DATE, REP_REF, COM_ID);
	END CASE;


	/*NEW VERSION*/
	CASE
		WHEN NEW.IS_RETURN = 'Y' THEN
            INSERT INTO Sales_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.REPLACEMENT_ID, NEW.ID, 49,case when NEW.AMOUNT<0 then NEW.AMOUNT* -1 else NEW.AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, REP_REF, COM_ID,'Replacement');
            INSERT INTO Sales_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.REPLACEMENT_ID, NEW.ID, 51,case when NEW.AMOUNT_OUT<0 then NEW.AMOUNT_OUT* -1 else NEW.AMOUNT_OUT end, NEW.COS_ACC_ID, ENTRY_DATE, REP_REF, COM_ID,'Replacement');
            INSERT INTO Sales_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.REPLACEMENT_ID, NEW.ID, 52,case when NEW.AMOUNT_OUT<0 then NEW.AMOUNT_OUT* -1 else NEW.AMOUNT_OUT end, NEW.INV_ACC_ID, ENTRY_DATE, REP_REF, COM_ID,'Replacement');
		ELSE
            INSERT INTO Sales_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.REPLACEMENT_ID, NEW.ID, 54,case when NEW.AMOUNT<0 then NEW.AMOUNT* -1 else NEW.AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, REP_REF, COM_ID,'Replacement');
            INSERT INTO Sales_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.REPLACEMENT_ID, NEW.ID, 55,case when NEW.AMOUNT_OUT<0 then NEW.AMOUNT_OUT* -1 else NEW.AMOUNT_OUT end, NEW.COS_ACC_ID, ENTRY_DATE, REP_REF, COM_ID,'Replacement');
            INSERT INTO Sales_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.REPLACEMENT_ID, NEW.ID, 56,case when NEW.AMOUNT_OUT<0 then NEW.AMOUNT_OUT* -1 else NEW.AMOUNT_OUT end, NEW.INV_ACC_ID, ENTRY_DATE, REP_REF, COM_ID,'Replacement');
    END CASE;
	/*NEW VERSION*/


END $$
DELIMITER ;


drop trigger if Exists TR_REPLACEMENT_DETAIL_UPT;
DELIMITER $$
CREATE TRIGGER `TR_REPLACEMENT_DETAIL_UPT` AFTER UPDATE ON `replacement_detail` FOR EACH ROW BEGIN

	DECLARE ENTRY_DATE DATETIME;
	DECLARE REP_REF VARCHAR(50);
	DECLARE COM_ID INT;

	SELECT REP_ENTRY_DATE, PAYPAL_TRANSACTION_ID, COMPANY_ID INTO ENTRY_DATE, REP_REF, COM_ID FROM REPLACEMENT WHERE ID = NEW.REPLACEMENT_ID;

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM REPLACEMENT_ACCOUNT_DETAIL WHERE REP_DETAIL_ID = OLD.ID;

	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	CASE
		WHEN NEW.IS_RETURN = 'Y' THEN
			INSERT INTO REPLACEMENT_ACCOUNT_DETAIL (REP_ID, REP_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.REPLACEMENT_ID, NEW.ID, 49, NEW.AMOUNT, NEW.GL_ACC_ID, ENTRY_DATE, REP_REF, COM_ID);
		    INSERT INTO REPLACEMENT_ACCOUNT_DETAIL (REP_ID, REP_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.REPLACEMENT_ID, NEW.ID, 51, NEW.AMOUNT_OUT, NEW.COS_ACC_ID, ENTRY_DATE, REP_REF, COM_ID);
		    INSERT INTO REPLACEMENT_ACCOUNT_DETAIL (REP_ID, REP_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.REPLACEMENT_ID, NEW.ID, 52, NEW.AMOUNT_OUT, NEW.INV_ACC_ID, ENTRY_DATE, REP_REF, COM_ID);
		   
		ELSE
			INSERT INTO REPLACEMENT_ACCOUNT_DETAIL (REP_ID, REP_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.REPLACEMENT_ID, NEW.ID, 54, NEW.AMOUNT, NEW.GL_ACC_ID, ENTRY_DATE, REP_REF, COM_ID);
			INSERT INTO REPLACEMENT_ACCOUNT_DETAIL (REP_ID, REP_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.REPLACEMENT_ID, NEW.ID, 55, NEW.AMOUNT_OUT, NEW.COS_ACC_ID, ENTRY_DATE, REP_REF, COM_ID);
			INSERT INTO REPLACEMENT_ACCOUNT_DETAIL (REP_ID, REP_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.REPLACEMENT_ID, NEW.ID, 56, NEW.AMOUNT_OUT, NEW.INV_ACC_ID, ENTRY_DATE, REP_REF, COM_ID);
	END CASE;


	/*NEW VERSION*/
	DELETE FROM Sales_Accounting WHERE Form_DETAIL_ID = OLD.ID and Form_Flag='Replacement';
	CASE
		WHEN NEW.IS_RETURN = 'Y' THEN
            INSERT INTO Sales_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.REPLACEMENT_ID, NEW.ID, 49, case when NEW.AMOUNT<0 then NEW.AMOUNT* -1 else NEW.AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, REP_REF, COM_ID,'Replacement');
            INSERT INTO Sales_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.REPLACEMENT_ID, NEW.ID, 51, case when NEW.AMOUNT_OUT<0 then NEW.AMOUNT_OUT* -1 else NEW.AMOUNT_OUT end, NEW.COS_ACC_ID, ENTRY_DATE, REP_REF, COM_ID,'Replacement');
            INSERT INTO Sales_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.REPLACEMENT_ID, NEW.ID, 52, case when NEW.AMOUNT_OUT<0 then NEW.AMOUNT_OUT* -1 else NEW.AMOUNT_OUT end, NEW.INV_ACC_ID, ENTRY_DATE, REP_REF, COM_ID,'Replacement');
		ELSE
            INSERT INTO Sales_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.REPLACEMENT_ID, NEW.ID, 54, case when NEW.AMOUNT<0 then NEW.AMOUNT* -1 else NEW.AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, REP_REF, COM_ID,'Replacement');
            INSERT INTO Sales_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.REPLACEMENT_ID, NEW.ID, 55, case when NEW.AMOUNT_OUT<0 then NEW.AMOUNT_OUT* -1 else NEW.AMOUNT_OUT end, NEW.COS_ACC_ID, ENTRY_DATE, REP_REF, COM_ID,'Replacement');
            INSERT INTO Sales_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.REPLACEMENT_ID, NEW.ID, 56, case when NEW.AMOUNT_OUT<0 then NEW.AMOUNT_OUT* -1 else NEW.AMOUNT_OUT end, NEW.INV_ACC_ID, ENTRY_DATE, REP_REF, COM_ID,'Replacement');
    END CASE;
	/*NEW VERSION*/
	
END $$
DELIMITER ;

drop trigger if Exists TR_REPLACEMENT_DETAIL_DEL;
DELIMITER $$
CREATE TRIGGER `TR_REPLACEMENT_DETAIL_DEL` BEFORE DELETE ON `replacement_detail` FOR EACH ROW BEGIN

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM REPLACEMENT_ACCOUNT_DETAIL WHERE REP_DETAIL_ID = OLD.ID;


	/*NEW VERSION*/
	DELETE FROM Sales_Accounting WHERE Form_DETAIL_ID = OLD.ID and Form_Flag='Replacement';
	/*NEW VERSION*/

END $$
DELIMITER ;




drop trigger if Exists TR_STOCK_TRANSFER;
DELIMITER $$
CREATE  TRIGGER `TR_STOCK_TRANSFER` AFTER INSERT ON `stock_transfer` FOR EACH ROW BEGIN

	DECLARE CUSTOMER_ID INT DEFAULT 0;
	DECLARE MSG VARCHAR (100);

	-- CHECKING STOCK OUT CUSTOMER
	SELECT ID INTO CUSTOMER_ID FROM CUSTOMER
	WHERE COMPANY_ID = NEW.COMPANY_TO_ID AND IS_COMPANY = 'Y';

	IF CUSTOMER_ID = 0 THEN
		-- RAISE_APPLICATION_ERROR(-20000,'=>NO CUSTOMER FOUND AGAINST SELECTED COMPANY.<=');
		SET MSG = CONCAT('=>NO CUSTOMER FOUND AGAINST SELECTED COMPANY.<=');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = MSG;
	END IF;

	-- INSERT INTO RECEIPT AGAINST STOCK OUT CUSTOMER
	INSERT INTO RECEIPTS_DETAIL_NEW (CUSTOMER_ID, FORM_ID, FORM_F_ID, FORM_TRANSACTION_ID, FORM_AMOUNT, FORM_FLAG, COMPANY_ID)
	SELECT CUSTOMER_ID, NEW.ID, NEW.ST_ID, '', NEW.ST_TOTAL, 'T', NEW.COMPANY_FROM_ID FROM DUAL;

	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	INSERT INTO STOCK_TRANSFER_ACCOUNT_DETAIL (SO_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ID, 57, NEW.ST_TOTAL, NEW.AR_ACC_ID, NEW.ST_ENTRY_DATE, NEW.ST_ID, NEW.COMPANY_FROM_ID);


	/*NEW VERSION*/
	INSERT INTO Stock_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ID, 57,case when NEW.ST_TOTAL<0 then NEW.ST_TOTAL* -1 else NEW.ST_TOTAL end, NEW.AR_ACC_ID, NEW.ST_ENTRY_DATE, NEW.ST_ID, NEW.COMPANY_FROM_ID,'StockTransfer');
	INSERT INTO Stock_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ID, 150,case when NEW.FREIGHT_CHARGES<0 then NEW.FREIGHT_CHARGES* -1 else NEW.FREIGHT_CHARGES end, NEW.FREIGHT_ACC_ID, NEW.ST_ENTRY_DATE, NEW.ST_ID, NEW.COMPANY_FROM_ID,'StockTransfer');
	INSERT INTO Stock_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ID, 151,case when NEW.CUSTOM_CHARGES<0 then NEW.CUSTOM_CHARGES* -1 else NEW.CUSTOM_CHARGES end, NEW.CUS_ACC_ID, NEW.ST_ENTRY_DATE, NEW.ST_ID, NEW.COMPANY_FROM_ID,'StockTransfer');
	/*NEW VERSION*/

END $$
DELIMITER ;


drop trigger if Exists TR_STOCK_TRANSFER_UPT;
DELIMITER $$
CREATE TRIGGER `TR_STOCK_TRANSFER_UPT` AFTER UPDATE ON `stock_transfer` FOR EACH ROW BEGIN

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM STOCK_TRANSFER_ACCOUNT_DETAIL WHERE SO_ID = OLD.ID AND SO_DETAIL_ID IS NULL;
	
	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	INSERT INTO STOCK_TRANSFER_ACCOUNT_DETAIL (SO_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ID, 57, NEW.ST_TOTAL, NEW.AR_ACC_ID, NEW.ST_ENTRY_DATE, NEW.ST_ID, NEW.COMPANY_FROM_ID);


	/*NEW VERSION*/
  	DELETE FROM Stock_Accounting WHERE Form_ID = OLD.ID AND Form_DETAIL_ID IS NULL and Form_Flag='StockTransfer';
	INSERT INTO Stock_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ID, 57,case when NEW.ST_TOTAL<0 then NEW.ST_TOTAL* -1 else NEW.ST_TOTAL end, NEW.AR_ACC_ID, NEW.ST_ENTRY_DATE, NEW.ST_ID, NEW.COMPANY_FROM_ID,'StockTransfer');
	INSERT INTO Stock_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ID, 150,case when NEW.FREIGHT_CHARGES<0 then NEW.FREIGHT_CHARGES* -1 else NEW.FREIGHT_CHARGES end, NEW.FREIGHT_ACC_ID, NEW.ST_ENTRY_DATE, NEW.ST_ID, NEW.COMPANY_FROM_ID,'StockTransfer');
	INSERT INTO Stock_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ID, 151,case when NEW.CUSTOM_CHARGES<0 then NEW.CUSTOM_CHARGES* -1 else NEW.CUSTOM_CHARGES end, NEW.CUS_ACC_ID, NEW.ST_ENTRY_DATE, NEW.ST_ID, NEW.COMPANY_FROM_ID,'StockTransfer');
	/*NEW VERSION*/

END $$
DELIMITER ;

drop trigger if Exists TR_STOCK_TRANSFER_DEL;
DELIMITER $$
CREATE TRIGGER `TR_STOCK_TRANSFER_DEL` BEFORE DELETE ON `stock_transfer` FOR EACH ROW BEGIN


	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM STOCK_TRANSFER_ACCOUNT_DETAIL WHERE SO_ID = OLD.ID;


	/*NEW VERSION*/
	DELETE FROM Stock_Accounting WHERE Form_ID = OLD.ID AND Form_DETAIL_ID IS NULL and Form_Flag='StockTransfer';
	/*NEW VERSION*/

END $$
DELIMITER ;

drop trigger if Exists TR_STOCK_TRANSFER_DETAIL;
DELIMITER $$
CREATE TRIGGER `TR_STOCK_TRANSFER_DETAIL` AFTER INSERT ON `stock_transfer_detail` FOR EACH ROW BEGIN

	DECLARE ENTRY_DATE DATETIME;
	DECLARE ST_REF VARCHAR(50);
	DECLARE COM_ID INT;

	SELECT ST_ENTRY_DATE, ST_ID, COMPANY_FROM_ID INTO ENTRY_DATE, ST_REF, COM_ID FROM STOCK_TRANSFER WHERE ID = NEW.STOCK_TRANSFER_ID;
	
	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	INSERT INTO STOCK_TRANSFER_ACCOUNT_DETAIL (SO_ID, SO_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.STOCK_TRANSFER_ID, NEW.ID, 58, NEW.AMOUNT, NEW.GL_ACC_ID, ENTRY_DATE, ST_REF, COM_ID);
	INSERT INTO STOCK_TRANSFER_ACCOUNT_DETAIL (SO_ID, SO_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.STOCK_TRANSFER_ID, NEW.ID, 59, NEW.AMOUNT_OUT, NEW.COS_ACC_ID, ENTRY_DATE, ST_REF, COM_ID);
	INSERT INTO STOCK_TRANSFER_ACCOUNT_DETAIL (SO_ID, SO_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.STOCK_TRANSFER_ID, NEW.ID, 60, NEW.AMOUNT_OUT, NEW.INV_ACC_ID, ENTRY_DATE, ST_REF, COM_ID);


	/*NEW VERSION*/
	INSERT INTO stock_accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.STOCK_TRANSFER_ID, NEW.ID, 58,case when NEW.AMOUNT<0 then NEW.AMOUNT* -1 else NEW.AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, ST_REF, COM_ID,'StockTransfer');
    INSERT INTO stock_accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.STOCK_TRANSFER_ID, NEW.ID, 59,case when NEW.AMOUNT_OUT<0 then NEW.AMOUNT_OUT* -1 else NEW.AMOUNT_OUT end, NEW.COS_ACC_ID, ENTRY_DATE, ST_REF, COM_ID,'StockTransfer');
    INSERT INTO stock_accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.STOCK_TRANSFER_ID, NEW.ID, 60,case when NEW.AMOUNT_OUT<0 then NEW.AMOUNT_OUT* -1 else NEW.AMOUNT_OUT end, NEW.INV_ACC_ID, ENTRY_DATE, ST_REF, COM_ID,'StockTransfer');
	/*NEW VERSION*/

END $$
DELIMITER ;

drop trigger if Exists TR_STOCK_TRANSFER_DETAIL_UPT;
DELIMITER $$
CREATE TRIGGER `TR_STOCK_TRANSFER_DETAIL_UPT` AFTER UPDATE ON `stock_transfer_detail` FOR EACH ROW BEGIN

	DECLARE ENTRY_DATE DATETIME;
	DECLARE ST_REF VARCHAR(50);
	DECLARE COM_ID INT;

	SELECT ST_ENTRY_DATE, ST_ID, COMPANY_FROM_ID INTO ENTRY_DATE, ST_REF, COM_ID FROM STOCK_TRANSFER WHERE ID = NEW.STOCK_TRANSFER_ID;

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM STOCK_TRANSFER_ACCOUNT_DETAIL WHERE SO_DETAIL_ID = OLD.ID;
 
	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	INSERT INTO STOCK_TRANSFER_ACCOUNT_DETAIL (SO_ID, SO_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.STOCK_TRANSFER_ID, NEW.ID, 58, NEW.AMOUNT, NEW.GL_ACC_ID, ENTRY_DATE, ST_REF, COM_ID);
	INSERT INTO STOCK_TRANSFER_ACCOUNT_DETAIL (SO_ID, SO_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.STOCK_TRANSFER_ID, NEW.ID, 59, NEW.AMOUNT_OUT, NEW.COS_ACC_ID, ENTRY_DATE, ST_REF, COM_ID);
	INSERT INTO STOCK_TRANSFER_ACCOUNT_DETAIL (SO_ID, SO_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.STOCK_TRANSFER_ID, NEW.ID, 60, NEW.AMOUNT_OUT, NEW.INV_ACC_ID, ENTRY_DATE, ST_REF, COM_ID);


	/*NEW VERSION*/
	DELETE FROM stock_accounting WHERE Form_DETAIL_ID = OLD.ID and Form_Flag='StockTransfer'; 
    INSERT INTO stock_accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.STOCK_TRANSFER_ID, NEW.ID, 58, case when NEW.AMOUNT<0 then NEW.AMOUNT* -1 else NEW.AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, ST_REF, COM_ID,'StockTransfer');
    INSERT INTO stock_accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.STOCK_TRANSFER_ID, NEW.ID, 59, case when NEW.AMOUNT_OUT<0 then NEW.AMOUNT_OUT* -1 else NEW.AMOUNT_OUT end, NEW.COS_ACC_ID, ENTRY_DATE, ST_REF, COM_ID,'StockTransfer');
    INSERT INTO stock_accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.STOCK_TRANSFER_ID, NEW.ID, 60, case when NEW.AMOUNT_OUT<0 then NEW.AMOUNT_OUT* -1 else NEW.AMOUNT_OUT end, NEW.INV_ACC_ID, ENTRY_DATE, ST_REF, COM_ID,'StockTransfer');
	/*NEW VERSION*/

END $$
DELIMITER ;

drop trigger if Exists TR_STOCK_TRANSFER_DETAIL_DEL;
DELIMITER $$
CREATE TRIGGER `TR_STOCK_TRANSFER_DETAIL_DEL` BEFORE DELETE ON `stock_transfer_detail` FOR EACH ROW BEGIN

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM STOCK_TRANSFER_ACCOUNT_DETAIL WHERE SO_DETAIL_ID = OLD.ID;


	/*NEW VERSION*/
	DELETE FROM stock_accounting WHERE Form_DETAIL_ID = OLD.ID and Form_Flag='StockTransfer';
	/*NEW VERSION*/

END $$
DELIMITER ;

drop trigger if Exists TR_STOCK_IN;
DELIMITER $$
CREATE TRIGGER `TR_STOCK_IN` AFTER INSERT ON `stock_in` FOR EACH ROW BEGIN

	DECLARE VENDOR_ID_IN INT DEFAULT 0;
	DECLARE COM_FROM_ID INT DEFAULT 0;
	DECLARE MSG VARCHAR (100);

	-- GETTING FROM COMPANY ID FROM STOCK TRANSFER TABLE
	SELECT COMPANY_FROM_ID INTO COM_FROM_ID FROM STOCK_TRANSFER
	WHERE ID = NEW.STOCK_TRANSFER_ID;

	-- CHECKING STOCK IN VENDOR
	SELECT ID INTO VENDOR_ID_IN FROM VENDOR
	WHERE COMPANY_ID = COM_FROM_ID AND IS_COMPANY = 'Y';

	IF VENDOR_ID_IN = 0 THEN
		-- RAISE_APPLICATION_ERROR(-20000,'=>NO VENDOR FOUND AGAINST LOGGED IN COMPANY.<=');
		SET MSG = CONCAT('=>NO VENDOR FOUND AGAINST LOGGED IN COMPANY.<=');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = MSG;
	END IF;

	-- INSERT INTO PAYMENTS AGAINST STOCK IN VENDOR
	INSERT INTO PAYMENTS_DETAIL_NEW (VENDOR_ID, FORM_ID, FORM_F_ID, FORM_TRANSACTION_ID, FORM_AMOUNT, FORM_FLAG, COMPANY_ID)
	SELECT VENDOR_ID_IN, NEW.ID, NEW.SN_ID, '', NEW.TOTAL_AMOUNT_IN, 'N', NEW.COMPANY_ID FROM DUAL;


	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	INSERT INTO STOCK_IN_ACCOUNT_DETAIL (SN_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ID, 62, NEW.TOTAL_AMOUNT_IN, NEW.AP_ACC_ID, NEW.SN_ENTRY_DATE, NEW.SN_ID, NEW.COMPANY_ID);


	/*NEW VERSION*/
	INSERT INTO Stock_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ID, 62,case when NEW.TOTAL_AMOUNT_IN<0 then NEW.TOTAL_AMOUNT_IN*-1 else NEW.TOTAL_AMOUNT_IN end, NEW.AP_ACC_ID, NEW.SN_ENTRY_DATE, NEW.SN_ID, NEW.COMPANY_ID,'StockIn');
	/*NEW VERSION*/

END $$
DELIMITER ;

drop trigger if Exists TR_STOCK_IN_UPT;
DELIMITER $$
CREATE  TRIGGER `TR_STOCK_IN_UPT` AFTER UPDATE ON `stock_in` FOR EACH ROW BEGIN

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM STOCK_IN_ACCOUNT_DETAIL WHERE SN_ID = OLD.ID AND SN_DETAIL_ID IS NULL;
	
	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	INSERT INTO STOCK_IN_ACCOUNT_DETAIL (SN_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ID, 62, NEW.TOTAL_AMOUNT_IN, NEW.AP_ACC_ID, NEW.SN_ENTRY_DATE, NEW.SN_ID, NEW.COMPANY_ID);


	/*NEW VERSION*/
	DELETE FROM Stock_Accounting WHERE Form_ID = OLD.ID AND Form_DETAIL_ID IS NULL and Form_Flag='StockIn';
	INSERT INTO Stock_Accounting (Form_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ID, 62,case when NEW.TOTAL_AMOUNT_IN<0 then NEW.TOTAL_AMOUNT_IN*-1 else NEW.TOTAL_AMOUNT_IN end, NEW.AP_ACC_ID, NEW.SN_ENTRY_DATE, NEW.SN_ID, NEW.COMPANY_ID,'StockIn');
	/*NEW VERSION*/

END $$
DELIMITER ;

drop trigger if Exists TR_STOCK_IN_DEL;
DELIMITER $$
CREATE TRIGGER `TR_STOCK_IN_DEL` BEFORE DELETE ON `stock_in` FOR EACH ROW BEGIN

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM STOCK_IN_ACCOUNT_DETAIL WHERE SN_ID = OLD.ID;


	/*NEW VERSION*/
	DELETE FROM Stock_Accounting WHERE Form_ID = OLD.ID AND Form_DETAIL_ID IS NULL and Form_Flag='StockIn';
	/*NEW VERSION*/

END $$
DELIMITER ;

drop trigger if Exists TR_STOCK_IN_DETAIL;
DELIMITER $$
CREATE TRIGGER `TR_STOCK_IN_DETAIL` AFTER INSERT ON `stock_in_detail` FOR EACH ROW BEGIN

	DECLARE ENTRY_DATE DATETIME;
	DECLARE SN_REF VARCHAR(50);
	DECLARE COM_ID INT;

	SELECT SN_ENTRY_DATE, SN_ID, COMPANY_ID INTO ENTRY_DATE, SN_REF, COM_ID FROM STOCK_IN WHERE ID = NEW.STOCK_IN_ID;
	
	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	INSERT INTO STOCK_IN_ACCOUNT_DETAIL (SN_ID, SN_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.STOCK_IN_ID, NEW.ID, 64, NEW.AMOUNT_IN, NEW.INV_ACC_ID, ENTRY_DATE, SN_REF, COM_ID);


	/*NEW VERSION*/
	INSERT INTO Stock_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.STOCK_IN_ID, NEW.ID, 64,case when NEW.AMOUNT_IN<0 then NEW.AMOUNT_IN*-1 else NEW.AMOUNT_IN end, NEW.INV_ACC_ID, ENTRY_DATE, SN_REF, COM_ID,'StockIn');
	/*NEW VERSION*/

END $$
DELIMITER ;


drop trigger if Exists TR_STOCK_IN_DETAIL_UPT;
DELIMITER $$
CREATE TRIGGER `TR_STOCK_IN_DETAIL_UPT` AFTER UPDATE ON `stock_in_detail` FOR EACH ROW BEGIN

	DECLARE ENTRY_DATE DATETIME;
	DECLARE SN_REF VARCHAR(50);
	DECLARE COM_ID INT;

	SELECT SN_ENTRY_DATE, SN_ID, COMPANY_ID INTO ENTRY_DATE, SN_REF, COM_ID FROM STOCK_IN WHERE ID = NEW.STOCK_IN_ID;

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM STOCK_IN_ACCOUNT_DETAIL WHERE SN_DETAIL_ID = OLD.ID;
	
	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	INSERT INTO STOCK_IN_ACCOUNT_DETAIL (SN_ID, SN_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.STOCK_IN_ID, NEW.ID, 64, NEW.AMOUNT_IN, NEW.INV_ACC_ID, ENTRY_DATE, SN_REF, COM_ID);


	/*NEW VERSION*/
   	DELETE FROM Stock_Accounting WHERE Form_DETAIL_ID = OLD.ID and Form_Flag='StockIn';
   	INSERT INTO Stock_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.STOCK_IN_ID, NEW.ID, 64, case when NEW.AMOUNT_IN<0 then NEW.AMOUNT_IN*-1 else NEW.AMOUNT_IN end, NEW.INV_ACC_ID, ENTRY_DATE, SN_REF, COM_ID,'StockIn');
	/*NEW VERSION*/

END $$
DELIMITER ;

drop trigger if Exists TR_STOCK_IN_DETAIL_DEL;
DELIMITER $$
CREATE TRIGGER `TR_STOCK_IN_DETAIL_DEL` BEFORE DELETE ON `stock_in_detail` FOR EACH ROW BEGIN

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM STOCK_IN_ACCOUNT_DETAIL WHERE SN_DETAIL_ID = OLD.ID;


	/*NEW VERSION*/
	DELETE FROM Stock_Accounting WHERE Form_DETAIL_ID = OLD.ID and Form_Flag='StockIn';
	/*NEW VERSION*/

END $$
DELIMITER ;

drop trigger if Exists TR_ADJUSTMENT_DETAIL;
DELIMITER $$
CREATE TRIGGER `TR_ADJUSTMENT_DETAIL` AFTER INSERT ON `adjustment_detail` FOR EACH ROW BEGIN
	
	DECLARE ENTRY_DATE DATETIME;
	DECLARE AJ_REF VARCHAR(50);
	DECLARE COM_ID INT;

    SELECT AJ_ENTRY_DATE, AJ_ID, COMPANY_ID INTO ENTRY_DATE, AJ_REF, COM_ID FROM ADJUSTMENT WHERE ID = NEW.ADJUSTMENT_ID;
	
	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	CASE
		WHEN NEW.IS_QUANTITY_ADDED = 'Y' THEN
			CASE
				WHEN NEW.OLD_ESN IS NULL THEN
					INSERT INTO ADJUSTMENT_ACCOUNT_DETAIL (AJ_ID, AJ_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ADJUSTMENT_ID, NEW.ID, 65, NEW.NEW_AMOUNT, NEW.GL_ACC_ID, ENTRY_DATE, AJ_REF, COM_ID);
					INSERT INTO ADJUSTMENT_ACCOUNT_DETAIL (AJ_ID, AJ_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ADJUSTMENT_ID, NEW.ID, 66, NEW.NEW_AMOUNT, NEW.INV_ACC_ID, ENTRY_DATE, AJ_REF, COM_ID);
                
                ELSE
			    	INSERT INTO ADJUSTMENT_ACCOUNT_DETAIL (AJ_ID, AJ_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ADJUSTMENT_ID, NEW.ID, 65, NEW.NEW_AMOUNT, NEW.GL_ACC_ID, ENTRY_DATE, AJ_REF, COM_ID);
					INSERT INTO ADJUSTMENT_ACCOUNT_DETAIL (AJ_ID, AJ_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ADJUSTMENT_ID, NEW.ID, 66, NEW.NEW_AMOUNT, NEW.INV_ACC_ID, ENTRY_DATE, AJ_REF, COM_ID);
                    INSERT INTO ADJUSTMENT_ACCOUNT_DETAIL (AJ_ID, AJ_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ADJUSTMENT_ID, NEW.ID, 69, NEW.OLD_AMOUNT, NEW.OLD_INV_ACC_ID, ENTRY_DATE, AJ_REF, COM_ID);
                    INSERT INTO ADJUSTMENT_ACCOUNT_DETAIL (AJ_ID, AJ_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ADJUSTMENT_ID, NEW.ID, 70, NEW.OLD_AMOUNT, NEW.OLD_GL_ACC_ID, ENTRY_DATE, AJ_REF, COM_ID);
  
			END CASE;
        
        ELSE
			INSERT INTO ADJUSTMENT_ACCOUNT_DETAIL (AJ_ID, AJ_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ADJUSTMENT_ID, NEW.ID, 67, NEW.NEW_AMOUNT, NEW.INV_ACC_ID, ENTRY_DATE, AJ_REF, COM_ID);
	        INSERT INTO ADJUSTMENT_ACCOUNT_DETAIL (AJ_ID, AJ_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ADJUSTMENT_ID, NEW.ID, 68, NEW.NEW_AMOUNT, NEW.GL_ACC_ID, ENTRY_DATE, AJ_REF, COM_ID);
			
	END CASE;


	/*NEW VERSION*/
	
	CASE
		WHEN NEW.IS_QUANTITY_ADDED = 'Y' THEN
			CASE
				WHEN NEW.OLD_ESN IS NULL THEN
                    INSERT INTO adjustment_accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ADJUSTMENT_ID, NEW.ID, 65,case when NEW.NEW_AMOUNT<0 then NEW.NEW_AMOUNT*-1 else NEW.NEW_AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, AJ_REF, COM_ID,'Adjustment');
					INSERT INTO adjustment_accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ADJUSTMENT_ID, NEW.ID, 66,case when NEW.NEW_AMOUNT<0 then NEW.NEW_AMOUNT*-1 else NEW.NEW_AMOUNT end, NEW.INV_ACC_ID, ENTRY_DATE, AJ_REF, COM_ID,'Adjustment');
                ELSE
                    INSERT INTO adjustment_accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ADJUSTMENT_ID, NEW.ID, 65,case when NEW.NEW_AMOUNT<0 then NEW.NEW_AMOUNT*-1 else NEW.NEW_AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, AJ_REF, COM_ID,'Adjustment');
					INSERT INTO adjustment_accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ADJUSTMENT_ID, NEW.ID, 66,case when NEW.NEW_AMOUNT<0 then NEW.NEW_AMOUNT*-1 else NEW.NEW_AMOUNT end, NEW.INV_ACC_ID, ENTRY_DATE, AJ_REF, COM_ID,'Adjustment');
                    INSERT INTO adjustment_accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ADJUSTMENT_ID, NEW.ID, 69,case when NEW.OLD_AMOUNT<0 then NEW.OLD_AMOUNT*-1 else NEW.OLD_AMOUNT end, NEW.OLD_INV_ACC_ID, ENTRY_DATE, AJ_REF, COM_ID,'Adjustment');
                    INSERT INTO adjustment_accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ADJUSTMENT_ID, NEW.ID, 70,case when NEW.OLD_AMOUNT<0 then NEW.OLD_AMOUNT*-1 else NEW.OLD_AMOUNT end, NEW.OLD_GL_ACC_ID, ENTRY_DATE, AJ_REF, COM_ID,'Adjustment');
			END CASE;
        
        ELSE
					INSERT INTO adjustment_accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ADJUSTMENT_ID, NEW.ID, 67,case when NEW.NEW_AMOUNT<0 then NEW.NEW_AMOUNT*-1 else NEW.NEW_AMOUNT end, NEW.INV_ACC_ID, ENTRY_DATE, AJ_REF, COM_ID,'Adjustment');
					INSERT INTO adjustment_accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ADJUSTMENT_ID, NEW.ID, 68,case when NEW.NEW_AMOUNT<0 then NEW.NEW_AMOUNT*-1 else NEW.NEW_AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, AJ_REF, COM_ID,'Adjustment');
	END CASE;
	
	/*NEW VERSION*/
	
END $$
DELIMITER ;

drop trigger if Exists TR_ADJUSTMENT_DETAIL_UPT;
DELIMITER $$
CREATE TRIGGER `TR_ADJUSTMENT_DETAIL_UPT` AFTER UPDATE ON `adjustment_detail` FOR EACH ROW BEGIN

	DECLARE ENTRY_DATE DATETIME;
	DECLARE AJ_REF VARCHAR(50);
	DECLARE COM_ID INT;

	SELECT AJ_ENTRY_DATE, AJ_ID, COMPANY_ID INTO ENTRY_DATE, AJ_REF, COM_ID FROM ADJUSTMENT WHERE ID = NEW.ADJUSTMENT_ID;

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM ADJUSTMENT_ACCOUNT_DETAIL WHERE AJ_DETAIL_ID = OLD.ID;
	
	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	CASE
		WHEN NEW.IS_QUANTITY_ADDED = 'Y' THEN
			CASE
				WHEN NEW.OLD_ESN IS NULL THEN
					INSERT INTO ADJUSTMENT_ACCOUNT_DETAIL (AJ_ID, AJ_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ADJUSTMENT_ID, NEW.ID, 65, NEW.NEW_AMOUNT, NEW.GL_ACC_ID, ENTRY_DATE, AJ_REF, COM_ID);
					INSERT INTO ADJUSTMENT_ACCOUNT_DETAIL (AJ_ID, AJ_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ADJUSTMENT_ID, NEW.ID, 66, NEW.NEW_AMOUNT, NEW.INV_ACC_ID, ENTRY_DATE, AJ_REF, COM_ID);
                
                ELSE
			    	INSERT INTO ADJUSTMENT_ACCOUNT_DETAIL (AJ_ID, AJ_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ADJUSTMENT_ID, NEW.ID, 65, NEW.NEW_AMOUNT, NEW.GL_ACC_ID, ENTRY_DATE, AJ_REF, COM_ID);
					INSERT INTO ADJUSTMENT_ACCOUNT_DETAIL (AJ_ID, AJ_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ADJUSTMENT_ID, NEW.ID, 66, NEW.NEW_AMOUNT, NEW.INV_ACC_ID, ENTRY_DATE, AJ_REF, COM_ID);
                    INSERT INTO ADJUSTMENT_ACCOUNT_DETAIL (AJ_ID, AJ_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ADJUSTMENT_ID, NEW.ID, 69, NEW.OLD_AMOUNT, NEW.OLD_INV_ACC_ID, ENTRY_DATE, AJ_REF, COM_ID);
                    INSERT INTO ADJUSTMENT_ACCOUNT_DETAIL (AJ_ID, AJ_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ADJUSTMENT_ID, NEW.ID, 70, NEW.OLD_AMOUNT, NEW.OLD_GL_ACC_ID, ENTRY_DATE, AJ_REF, COM_ID);
  
			END CASE;
        
        ELSE
			INSERT INTO ADJUSTMENT_ACCOUNT_DETAIL (AJ_ID, AJ_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ADJUSTMENT_ID, NEW.ID, 67, NEW.NEW_AMOUNT, NEW.INV_ACC_ID, ENTRY_DATE, AJ_REF, COM_ID);
	        INSERT INTO ADJUSTMENT_ACCOUNT_DETAIL (AJ_ID, AJ_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.ADJUSTMENT_ID, NEW.ID, 68, NEW.NEW_AMOUNT, NEW.GL_ACC_ID, ENTRY_DATE, AJ_REF, COM_ID);
			
	END CASE;


	/*NEW VERSION*/
	DELETE FROM adjustment_accounting WHERE Form_DETAIL_ID = OLD.ID and Form_Flag='Adjustment';
	CASE
		WHEN NEW.IS_QUANTITY_ADDED = 'Y' THEN
			CASE
				WHEN NEW.OLD_ESN IS NULL THEN
                    INSERT INTO adjustment_accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ADJUSTMENT_ID, NEW.ID, 65,case when NEW.NEW_AMOUNT<0 then NEW.NEW_AMOUNT*-1 else NEW.NEW_AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, AJ_REF, COM_ID,'Adjustment');
					INSERT INTO adjustment_accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ADJUSTMENT_ID, NEW.ID, 66,case when NEW.NEW_AMOUNT<0 then NEW.NEW_AMOUNT*-1 else NEW.NEW_AMOUNT end, NEW.INV_ACC_ID, ENTRY_DATE, AJ_REF, COM_ID,'Adjustment');
                ELSE
                    INSERT INTO adjustment_accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ADJUSTMENT_ID, NEW.ID, 65,case when NEW.NEW_AMOUNT<0 then NEW.NEW_AMOUNT*-1 else NEW.NEW_AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, AJ_REF, COM_ID,'Adjustment');
					INSERT INTO adjustment_accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ADJUSTMENT_ID, NEW.ID, 66,case when NEW.NEW_AMOUNT<0 then NEW.NEW_AMOUNT*-1 else NEW.NEW_AMOUNT end, NEW.INV_ACC_ID, ENTRY_DATE, AJ_REF, COM_ID,'Adjustment');
                    INSERT INTO adjustment_accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ADJUSTMENT_ID, NEW.ID, 69,case when NEW.OLD_AMOUNT<0 then NEW.OLD_AMOUNT*-1 else NEW.OLD_AMOUNT end, NEW.OLD_INV_ACC_ID, ENTRY_DATE, AJ_REF, COM_ID,'Adjustment');
                    INSERT INTO adjustment_accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ADJUSTMENT_ID, NEW.ID, 70,case when NEW.OLD_AMOUNT<0 then NEW.OLD_AMOUNT*-1 else NEW.OLD_AMOUNT end, NEW.OLD_GL_ACC_ID, ENTRY_DATE, AJ_REF, COM_ID,'Adjustment');
			END CASE;
        
        ELSE
            INSERT INTO adjustment_accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ADJUSTMENT_ID, NEW.ID, 67,case when NEW.NEW_AMOUNT<0 then NEW.NEW_AMOUNT*-1 else NEW.NEW_AMOUNT end, NEW.INV_ACC_ID, ENTRY_DATE, AJ_REF, COM_ID,'Adjustment');
	        INSERT INTO adjustment_accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.ADJUSTMENT_ID, NEW.ID, 68,case when NEW.NEW_AMOUNT<0 then NEW.NEW_AMOUNT*-1 else NEW.NEW_AMOUNT end, NEW.GL_ACC_ID, ENTRY_DATE, AJ_REF, COM_ID,'Adjustment');
	END CASE;
	/*NEW VERSION*/


END $$
DELIMITER ;

drop trigger if Exists TR_ADJUSTMENT_DETAIL_DEL;
DELIMITER $$
CREATE TRIGGER `TR_ADJUSTMENT_DETAIL_DEL` BEFORE DELETE ON `adjustment_detail` FOR EACH ROW BEGIN
	
	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM ADJUSTMENT_ACCOUNT_DETAIL WHERE AJ_DETAIL_ID = OLD.ID;


	/*NEW VERSION*/
	DELETE FROM adjustment_accounting WHERE Form_DETAIL_ID = OLD.ID and Form_Flag='Adjustment';
	/*NEW VERSION*/

END $$
DELIMITER ;



drop trigger if Exists TR_REPAIR_OUT_DETAIL;
DELIMITER $$
CREATE TRIGGER `TR_REPAIR_OUT_DETAIL` AFTER INSERT ON `repair_out_detail` FOR EACH ROW BEGIN

	DECLARE ENTRY_DATE DATETIME;
	DECLARE RO_REF VARCHAR(50);
	DECLARE COM_ID INT;

	SELECT RE_ENTRY_DATE, PAYPAL_TRANSACTION_ID, COMPANY_ID INTO ENTRY_DATE, RO_REF, COM_ID FROM REPAIR_OUT WHERE ID = NEW.REPAIR_OUT_ID;
	
	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	INSERT INTO REPAIR_OUT_ACCOUNT_DETAIL (RE_ID, RE_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.REPAIR_OUT_ID, NEW.ID, 73, NEW.AMOUNT, NEW.INV_ACC_ID, ENTRY_DATE, RO_REF, COM_ID);
	INSERT INTO REPAIR_OUT_ACCOUNT_DETAIL (RE_ID, RE_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.REPAIR_OUT_ID, NEW.ID, 74, NEW.AMOUNT, NEW.REP_ACC_ID, ENTRY_DATE, RO_REF, COM_ID);


	/*NEW VERSION*/
	INSERT INTO Repair_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.REPAIR_OUT_ID, NEW.ID, 73,case when NEW.AMOUNT<0 then NEW.AMOUNT*-1 else NEW.AMOUNT end, NEW.INV_ACC_ID, ENTRY_DATE, RO_REF, COM_ID,'RepairOut');
    INSERT INTO Repair_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.REPAIR_OUT_ID, NEW.ID, 74, case when NEW.AMOUNT<0 then NEW.AMOUNT*-1 else NEW.AMOUNT end, NEW.REP_ACC_ID, ENTRY_DATE, RO_REF, COM_ID,'RepairOut');
	/*NEW VERSION*/

END $$
DELIMITER ;


drop trigger if Exists TR_REPAIR_OUT_DETAIL_UP;
DELIMITER $$
CREATE TRIGGER `TR_REPAIR_OUT_DETAIL_UP` AFTER UPDATE ON `repair_out_detail` FOR EACH ROW BEGIN

	DECLARE ENTRY_DATE DATETIME;
	DECLARE RO_REF VARCHAR(50);
	DECLARE COM_ID INT;

	SELECT RE_ENTRY_DATE, PAYPAL_TRANSACTION_ID, COMPANY_ID INTO ENTRY_DATE, RO_REF, COM_ID FROM REPAIR_OUT WHERE ID = NEW.REPAIR_OUT_ID;

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM REPAIR_OUT_ACCOUNT_DETAIL WHERE RE_DETAIL_ID = OLD.ID;
	
	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	INSERT INTO REPAIR_OUT_ACCOUNT_DETAIL (RE_ID, RE_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.REPAIR_OUT_ID, NEW.ID, 73, NEW.AMOUNT, NEW.INV_ACC_ID, ENTRY_DATE, RO_REF, COM_ID);
	INSERT INTO REPAIR_OUT_ACCOUNT_DETAIL (RE_ID, RE_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.REPAIR_OUT_ID, NEW.ID, 74, NEW.AMOUNT, NEW.REP_ACC_ID, ENTRY_DATE, RO_REF, COM_ID);


	/*NEW VERSION*/
	DELETE FROM Repair_Accounting WHERE Form_DETAIL_ID = OLD.ID and Form_Flag='RepairOut';
	INSERT INTO Repair_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.REPAIR_OUT_ID, NEW.ID, 73, case when NEW.AMOUNT<0 then NEW.AMOUNT*-1 else NEW.AMOUNT end, NEW.INV_ACC_ID, ENTRY_DATE, RO_REF, COM_ID,'RepairOut');
	INSERT INTO Repair_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.REPAIR_OUT_ID, NEW.ID, 74, case when NEW.AMOUNT<0 then NEW.AMOUNT*-1 else NEW.AMOUNT end, NEW.REP_ACC_ID, ENTRY_DATE, RO_REF, COM_ID,'RepairOut');
	/*NEW VERSION*/

END $$
DELIMITER ;

drop trigger if Exists TR_REPAIR_OUT_DETAIL_DEL;
DELIMITER $$
CREATE TRIGGER `TR_REPAIR_OUT_DETAIL_DEL` BEFORE DELETE ON `repair_out_detail` FOR EACH ROW BEGIN

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM REPAIR_OUT_ACCOUNT_DETAIL WHERE RE_DETAIL_ID = OLD.ID;


	/*NEW VERSION*/
	DELETE FROM Repair_Accounting WHERE Form_DETAIL_ID = OLD.ID and Form_Flag='RepairOut';
	/*NEW VERSION*/

END $$
DELIMITER ;

drop trigger if Exists TR_REPAIR_IN_DETAIL;
DELIMITER $$
CREATE TRIGGER `TR_REPAIR_IN_DETAIL` AFTER INSERT ON `repair_in_detail` FOR EACH ROW BEGIN

	DECLARE ENTRY_DATE DATETIME;
	DECLARE RN_REF VARCHAR(50);
	DECLARE COM_ID INT;
	DECLARE RN_DETAIL_ID INT;
	DECLARE PARTS_AMOUNT DECIMAL(22,2);

	  SELECT REPAIR_IN_DETAIL_ID, SUM(AMOUNT) INTO RN_DETAIL_ID, PARTS_AMOUNT 
	    FROM REPAIR_IN_DETAIL_PARTS_INV_JUNCTION
	   WHERE REPAIR_IN_DETAIL_ID = NEW.ID
	GROUP BY REPAIR_IN_DETAIL_ID;

	SELECT RN_ENTRY_DATE, PAYPAL_TRANSACTION_ID, COMPANY_ID INTO ENTRY_DATE, RN_REF, COM_ID FROM REPAIR_IN WHERE ID = NEW.REPAIR_IN_ID;
	
	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	INSERT INTO REPAIR_IN_ACCOUNT_DETAIL (RN_ID, RN_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.REPAIR_IN_ID, NEW.ID, 75, (NEW.AMOUNT + NEW.REPAIR_CHARGES + IFNULL(PARTS_AMOUNT, 0)), NEW.INV_ACC_ID, ENTRY_DATE, RN_REF, COM_ID);
	INSERT INTO REPAIR_IN_ACCOUNT_DETAIL (RN_ID, RN_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.REPAIR_IN_ID, NEW.ID, 76, NEW.AMOUNT, NEW.REP_ACC_ID, ENTRY_DATE, RN_REF, COM_ID);
	INSERT INTO REPAIR_IN_ACCOUNT_DETAIL (RN_ID, RN_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.REPAIR_IN_ID, NEW.ID, 77, NEW.REPAIR_CHARGES, NEW.CHARGES_ACC_ID, ENTRY_DATE, RN_REF, COM_ID);


	/*NEW VERSION*/
	INSERT INTO Repair_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.REPAIR_IN_ID, NEW.ID, 75, case when (NEW.AMOUNT +NEW.REPAIR_CHARGES)<0 then (NEW.AMOUNT +NEW.REPAIR_CHARGES)*-1 else (NEW.AMOUNT +NEW.REPAIR_CHARGES) end, NEW.INV_ACC_ID, ENTRY_DATE, RN_REF, COM_ID,'RepairIn');
    INSERT INTO Repair_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.REPAIR_IN_ID, NEW.ID, 76, case when NEW.AMOUNT<0 then NEW.AMOUNT*-1 else NEW.AMOUNT end, NEW.REP_ACC_ID, ENTRY_DATE, RN_REF, COM_ID,'RepairIn');
    INSERT INTO Repair_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.REPAIR_IN_ID, NEW.ID, 77,case when NEW.REPAIR_CHARGES<0 then NEW.REPAIR_CHARGES*-1 else NEW.REPAIR_CHARGES end, NEW.CHARGES_ACC_ID, ENTRY_DATE, RN_REF, COM_ID,'RepairIn');
	/*NEW VERSION*/
		
	 
END $$
DELIMITER ;

drop trigger if Exists TR_REPAIR_IN_DETAIL_UPT;
DELIMITER $$
CREATE TRIGGER `TR_REPAIR_IN_DETAIL_UPT` AFTER UPDATE ON `repair_in_detail` FOR EACH ROW BEGIN
	
	DECLARE ENTRY_DATE DATETIME;
	DECLARE RN_REF VARCHAR(50);
	DECLARE COM_ID INT;
	DECLARE PARTS_AMOUNT DECIMAL(22,2);

	  SELECT SUM(AMOUNT) INTO PARTS_AMOUNT 
	    FROM REPAIR_IN_DETAIL_PARTS_INV_JUNCTION
	   WHERE REPAIR_IN_DETAIL_ID = NEW.ID
	GROUP BY REPAIR_IN_DETAIL_ID;

	SELECT RN_ENTRY_DATE, PAYPAL_TRANSACTION_ID, COMPANY_ID INTO ENTRY_DATE, RN_REF, COM_ID FROM REPAIR_IN WHERE ID = NEW.REPAIR_IN_ID;

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM REPAIR_IN_ACCOUNT_DETAIL WHERE RN_DETAIL_ID = OLD.ID AND RN_PARTS_JUNCTION_ID IS NULL;
	
	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	INSERT INTO REPAIR_IN_ACCOUNT_DETAIL (RN_ID, RN_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.REPAIR_IN_ID, NEW.ID, 75, (NEW.AMOUNT + NEW.REPAIR_CHARGES + IFNULL(PARTS_AMOUNT, 0)), NEW.INV_ACC_ID, ENTRY_DATE, RN_REF, COM_ID);
	INSERT INTO REPAIR_IN_ACCOUNT_DETAIL (RN_ID, RN_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.REPAIR_IN_ID, NEW.ID, 76, NEW.AMOUNT, NEW.REP_ACC_ID, ENTRY_DATE, RN_REF, COM_ID);
	INSERT INTO REPAIR_IN_ACCOUNT_DETAIL (RN_ID, RN_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.REPAIR_IN_ID, NEW.ID, 77, NEW.REPAIR_CHARGES, NEW.CHARGES_ACC_ID, ENTRY_DATE, RN_REF, COM_ID);


	/*NEW VERSION*/
	DELETE FROM Repair_Accounting WHERE Form_DETAIL_ID = OLD.ID AND RN_PARTS_JUNCTION_ID IS NULL and Form_Flag='RepairIn';
    INSERT INTO Repair_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.REPAIR_IN_ID, NEW.ID, 75, case when (NEW.AMOUNT + NEW.REPAIR_CHARGES)<0 then (NEW.AMOUNT + NEW.REPAIR_CHARGES)*-1 else (NEW.AMOUNT + NEW.REPAIR_CHARGES) end, NEW.INV_ACC_ID, ENTRY_DATE, RN_REF, COM_ID,'RepairIn');
    INSERT INTO Repair_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.REPAIR_IN_ID, NEW.ID, 76, case when NEW.AMOUNT<0 then NEW.AMOUNT*-1 else NEW.AMOUNT end, NEW.REP_ACC_ID, ENTRY_DATE, RN_REF, COM_ID,'RepairIn');
    INSERT INTO Repair_Accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.REPAIR_IN_ID, NEW.ID, 77,case when NEW.REPAIR_CHARGES<0 then NEW.REPAIR_CHARGES*-1 else NEW.REPAIR_CHARGES end, NEW.CHARGES_ACC_ID, ENTRY_DATE, RN_REF, COM_ID,'RepairIn');
	/*NEW VERSION*/
	
END $$
DELIMITER ;

drop trigger if Exists TR_REPAIR_IN_DETAIL_DEL;
DELIMITER $$
CREATE  TRIGGER `TR_REPAIR_IN_DETAIL_DEL` BEFORE DELETE ON `repair_in_detail` FOR EACH ROW BEGIN

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM REPAIR_IN_ACCOUNT_DETAIL WHERE RN_DETAIL_ID = OLD.ID;


	/*NEW VERSION*/
	DELETE FROM repair_accounting WHERE Form_DETAIL_ID = OLD.ID and Form_Flag='RepairIn';
	/*NEW VERSION*/

END $$
DELIMITER ;


drop trigger if Exists TR_REPAIR_IN_DETAIL_PARTS_INV_JUNCTION;
DELIMITER $$
CREATE  TRIGGER `TR_REPAIR_IN_DETAIL_PARTS_INV_JUNCTION` AFTER INSERT ON `repair_in_detail_parts_inv_junction` FOR EACH ROW BEGIN

	DECLARE ENTRY_DATE DATETIME;
	DECLARE RN_REF VARCHAR(50);
	DECLARE COM_ID INT;
	DECLARE RN_IN_ID INT DEFAULT 0;
	DECLARE INV_ACC_ID_T DECIMAL(22,2);

	-- GETTING REPAIR IN ID AGAINST REPAIR IN DETAIL ID
	SELECT REPAIR_IN_ID INTO RN_IN_ID 
	  FROM REPAIR_IN_DETAIL
	 WHERE ID = NEW.REPAIR_IN_DETAIL_ID
	 LIMIT 0, 1;
	
	SELECT RN_ENTRY_DATE, PAYPAL_TRANSACTION_ID, COMPANY_ID INTO ENTRY_DATE, RN_REF, COM_ID FROM REPAIR_IN WHERE ID = RN_IN_ID;
	
	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	INSERT INTO REPAIR_IN_ACCOUNT_DETAIL (RN_ID, RN_DETAIL_ID, RN_PARTS_JUNCTION_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (RN_IN_ID, NEW.REPAIR_IN_DETAIL_ID, NEW.ID, 78, NEW.AMOUNT, NEW.PARTS_ACC_ID, ENTRY_DATE, RN_REF, COM_ID);


	/*NEW VERSION*/
	select REPAIR_IN_ID,INV_ACC_ID into RN_IN_ID,INV_ACC_ID_T from repair_in_detail where id=NEW.REPAIR_IN_DETAIL_ID;
	INSERT INTO Repair_Accounting (Form_ID, Form_DETAIL_ID,Form_Flag, RN_PARTS_JUNCTION_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (RN_IN_ID, NEW.REPAIR_IN_DETAIL_ID,'RepairIn',NEW.ID, 78, case when NEW.AMOUNT<0 then NEW.AMOUNT*-1 else NEW.AMOUNT end, NEW.PARTS_ACC_ID, ENTRY_DATE, RN_REF, COM_ID);
        INSERT INTO Repair_Accounting (Form_ID, Form_DETAIL_ID,RN_PARTS_JUNCTION_ID,GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (RN_IN_ID, NEW.REPAIR_IN_DETAIL_ID,NEW.ID,75, (case when NEW.AMOUNT<0 then NEW.AMOUNT*-1 else NEW.AMOUNT end),INV_ACC_ID_T, ENTRY_DATE, RN_REF, COM_ID,'RepairIn');
	/*NEW VERSION*/



END $$
DELIMITER ;

drop trigger if Exists TR_REPAIR_IN_DETAIL_PARTS_INV_JUNCTION_UPT;
DELIMITER $$
CREATE  TRIGGER `TR_REPAIR_IN_DETAIL_PARTS_INV_JUNCTION_UPT` AFTER UPDATE ON `repair_in_detail_parts_inv_junction` FOR EACH ROW BEGIN
	
	DECLARE ENTRY_DATE DATETIME;
	DECLARE RN_REF VARCHAR(50);
	DECLARE COM_ID INT;
	DECLARE RN_IN_ID INT DEFAULT 0;
	DECLARE INV_ACC_ID_T DECIMAL(22,2);

	-- GETTING REPAIR IN ID AGAINST REPAIR IN DETAIL ID
	SELECT REPAIR_IN_ID INTO RN_IN_ID 
	  FROM REPAIR_IN_DETAIL
	 WHERE ID = NEW.REPAIR_IN_DETAIL_ID
	 LIMIT 0, 1;
	
	SELECT RN_ENTRY_DATE, PAYPAL_TRANSACTION_ID, COMPANY_ID INTO ENTRY_DATE, RN_REF, COM_ID FROM REPAIR_IN WHERE ID = RN_IN_ID;
	
	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM REPAIR_IN_ACCOUNT_DETAIL WHERE RN_PARTS_JUNCTION_ID = OLD.ID;
	
	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	INSERT INTO REPAIR_IN_ACCOUNT_DETAIL (RN_ID, RN_DETAIL_ID, RN_PARTS_JUNCTION_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (RN_IN_ID, NEW.REPAIR_IN_DETAIL_ID, NEW.ID, 78, NEW.AMOUNT, NEW.PARTS_ACC_ID, ENTRY_DATE, RN_REF, COM_ID);


	/*NEW VERSION*/
	DELETE FROM Repair_Accounting WHERE RN_PARTS_JUNCTION_ID = OLD.ID and  Form_Flag='RepairIn';
	select REPAIR_IN_ID,INV_ACC_ID into RN_IN_ID,INV_ACC_ID_T from repair_in_detail where id=NEW.REPAIR_IN_DETAIL_ID;
	INSERT INTO Repair_Accounting (Form_ID, Form_DETAIL_ID,Form_Flag, RN_PARTS_JUNCTION_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (RN_IN_ID, NEW.REPAIR_IN_DETAIL_ID,'RepairIn',NEW.ID, 78, case when NEW.AMOUNT<0 then NEW.AMOUNT*-1 else NEW.AMOUNT end, NEW.PARTS_ACC_ID, ENTRY_DATE, RN_REF, COM_ID);
	INSERT INTO Repair_Accounting (Form_ID, Form_DETAIL_ID,RN_PARTS_JUNCTION_ID,GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (RN_IN_ID, NEW.REPAIR_IN_DETAIL_ID,NEW.ID,75, (case when NEW.AMOUNT<0 then NEW.AMOUNT*-1 else NEW.AMOUNT end),INV_ACC_ID_T, ENTRY_DATE, RN_REF, COM_ID,'RepairIn');
	/*NEW VERSION*/

END $$
DELIMITER ;

drop trigger if Exists TR_REPAIR_IN_DETAIL_PARTS_INV_JUNCTION_DEL;
DELIMITER $$
CREATE TRIGGER `TR_REPAIR_IN_DETAIL_PARTS_INV_JUNCTION_DEL` BEFORE DELETE ON `repair_in_detail_parts_inv_junction` FOR EACH ROW BEGIN

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM REPAIR_IN_ACCOUNT_DETAIL WHERE RN_PARTS_JUNCTION_ID = OLD.ID;


	/*NEW VERSION*/
	DELETE FROM Repair_Accounting WHERE RN_PARTS_JUNCTION_ID = OLD.ID and Form_Flag='RepairIn';
	/*NEW VERSION*/

END $$
DELIMITER ;



drop trigger if Exists TR_GENERAL_JOURNAL_DETAIL;
DELIMITER $$
CREATE TRIGGER `TR_GENERAL_JOURNAL_DETAIL` AFTER INSERT ON `general_journal_detail` FOR EACH ROW BEGIN

	DECLARE ENTRY_DATE DATETIME;
	DECLARE GJ_REF VARCHAR(50);
	DECLARE COM_ID INT;

	SELECT GJ_ENTRY_DATE, GJ_REFERENCE, COMPANY_ID INTO ENTRY_DATE, GJ_REF, COM_ID FROM GENERAL_JOURNAL WHERE ID = NEW.GENERAL_JOURNAL_ID;
	
	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	CASE
		WHEN (NEW.ENTRY_TYPE = 'D') THEN 
			INSERT INTO GENERAL_JOURNAL_ACCOUNT_DETAIL (GJ_ID, GJ_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.GENERAL_JOURNAL_ID, NEW.ID, 71, NEW.DEBIT, NEW.ACCOUNT_ID, ENTRY_DATE, GJ_REF, COM_ID);
			
		ELSE 
			INSERT INTO GENERAL_JOURNAL_ACCOUNT_DETAIL (GJ_ID, GJ_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.GENERAL_JOURNAL_ID, NEW.ID, 72, NEW.CREDIT, NEW.ACCOUNT_ID, ENTRY_DATE, GJ_REF, COM_ID);
	END CASE;


	/*NEW VERSION*/
	CASE
		WHEN (NEW.ENTRY_TYPE = 'D') THEN 
			INSERT INTO adjustment_accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.GENERAL_JOURNAL_ID, NEW.ID, 71,case when NEW.DEBIT<0 then NEW.DEBIT*-1 else NEW.DEBIT end, NEW.ACCOUNT_ID, ENTRY_DATE, GJ_REF, COM_ID,'GeneralJournal');
		ELSE 
			INSERT INTO adjustment_accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.GENERAL_JOURNAL_ID, NEW.ID, 72,case when NEW.Credit<0 then NEW.Credit*-1 else NEW.Credit end, NEW.ACCOUNT_ID, ENTRY_DATE, GJ_REF, COM_ID,'GeneralJournal');
    END CASE;
	/*NEW VERSION*/
	
END $$
DELIMITER ;

drop trigger if Exists TR_GENERAL_JOURNAL_DETAIL_UPT;
DELIMITER $$
CREATE TRIGGER `TR_GENERAL_JOURNAL_DETAIL_UPT` AFTER UPDATE ON `general_journal_detail` FOR EACH ROW BEGIN

	DECLARE ENTRY_DATE DATETIME;
	DECLARE GJ_REF VARCHAR(50);
	DECLARE COM_ID INT;

	SELECT GJ_ENTRY_DATE, GJ_REFERENCE, COMPANY_ID INTO ENTRY_DATE, GJ_REF, COM_ID FROM GENERAL_JOURNAL WHERE ID = NEW.GENERAL_JOURNAL_ID;

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM GENERAL_JOURNAL_ACCOUNT_DETAIL WHERE GJ_DETAIL_ID = OLD.ID;

	-- INSERT RECORD INTO ACCOUNT_DETAIL TABLE
	CASE
		WHEN (NEW.ENTRY_TYPE = 'D') THEN 
			INSERT INTO GENERAL_JOURNAL_ACCOUNT_DETAIL (GJ_ID, GJ_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.GENERAL_JOURNAL_ID, NEW.ID, 71, NEW.DEBIT, NEW.ACCOUNT_ID, ENTRY_DATE, GJ_REF, COM_ID);
			
		ELSE 
			INSERT INTO GENERAL_JOURNAL_ACCOUNT_DETAIL (GJ_ID, GJ_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID) VALUES (NEW.GENERAL_JOURNAL_ID, NEW.ID, 72, NEW.CREDIT, NEW.ACCOUNT_ID, ENTRY_DATE, GJ_REF, COM_ID);
	END CASE;


	/*NEW VERSION*/
	DELETE FROM adjustment_accounting WHERE FORM_DETAIL_ID = OLD.ID and Form_Flag = 'GeneralJournal';
	CASE
		WHEN (NEW.ENTRY_TYPE = 'D') THEN 
		INSERT INTO adjustment_accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.GENERAL_JOURNAL_ID, NEW.ID, 71,case when NEW.DEBIT<0 then NEW.DEBIT*-1 else NEW.DEBIT end, NEW.ACCOUNT_ID, ENTRY_DATE, GJ_REF, COM_ID,'GeneralJournal');
		ELSE 
		INSERT INTO adjustment_accounting (Form_ID, Form_DETAIL_ID, GL_FLAG, AMOUNT, GL_ACC_ID, FORM_DATE, FORM_REFERENCE, COMPANY_ID,Form_Flag) VALUES (NEW.GENERAL_JOURNAL_ID, NEW.ID, 72,case when NEW.CREDIT<0 then NEW.CREDIT*-1 else NEW.CREDIT end, NEW.ACCOUNT_ID, ENTRY_DATE, GJ_REF, COM_ID,'GeneralJournal');
	END CASE;
	/*NEW VERSION*/


END $$
DELIMITER ;

drop trigger if Exists TR_GENERAL_JOURNAL_DETAIL_DEL;
DELIMITER $$
CREATE TRIGGER `TR_GENERAL_JOURNAL_DETAIL_DEL` BEFORE DELETE ON `general_journal_detail` FOR EACH ROW BEGIN

	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
	DELETE FROM GENERAL_JOURNAL_ACCOUNT_DETAIL WHERE GJ_DETAIL_ID = OLD.ID;


	/*NEW VERSION*/
	delete From Adjustment_Accounting where Form_Detail_Id = OLD.ID and Form_Flag = 'GeneralJournal';
	/*NEW VERSION*/

END $$
DELIMITER ;

/*This Triger is not present in Server Database Copy*/
drop trigger if Exists TR_GENERAL_JOURNAL_DEL;
DELIMITER $$
CREATE TRIGGER `TR_GENERAL_JOURNAL_DEL` BEFORE DELETE ON `general_journal` FOR EACH ROW
BEGIN
 
	/*
	-- OLD VERSION
	
	-- There Was no OLD Version
	
	-- OLD VERSION
	*/
 
	-- DELETE RECORD FROM ACCOUNT_DETAIL TABLE
    
	
	-- DELETE FROM SALE_INVOICE_ACCOUNT_DETAIL WHERE SI_ID = OLD.ID;
	
	
	DELETE FROM GENERAL_JOURNAL_ACCOUNT_DETAIL WHERE GJ_ID = OLD.ID;
	
	/*NEW VERSION*/
	DELETE FROM Adjustment_Accounting WHERE Form_ID = OLD.ID and Form_Flag='GeneralJournal';
	/*NEW VERSION*/

 
END $$
DELIMITER ;


-- This Triger insert the Opening Balance of New Account

drop trigger if Exists TR_AccountsId;
DELIMITER $$
CREATE TRIGGER `TR_AccountsId` AFTER INSERT ON `accounts_id` FOR EACH ROW BEGIN

    Declare Message Text Default '';
    select FUNC_SET_DAILY_ACCOUNT_BALANCE(NEW.id,NEW.BEGINNING_BALANCE,5555,NEW.ENTRY_DATE) into Message;

END $$
DELIMITER ;

-- This Trigger Delete the Daily Balance Account before Delete 

drop trigger if Exists TR_AccountsId_Before_Delete;
DELIMITER $$
CREATE TRIGGER `TR_AccountsId_Before_Delete` Before Delete ON `accounts_id` FOR EACH ROW BEGIN

    Delete from DailyAccountBalance where AccountId = OLD.ID;
	
END $$
DELIMITER ;


-- This Trigger Update the Daily Account Balance before Update 

drop trigger if Exists TR_AccountsId_Before_Update;
DELIMITER $$
CREATE TRIGGER `TR_AccountsId_Before_Update` Before Update ON `accounts_id` FOR EACH ROW BEGIN

    Declare Message Text Default '';

    select FUNC_SET_DAILY_ACCOUNT_BALANCE(OLD.id,OLD.BEGINNING_BALANCE * -1,5555,OLD.ENTRY_DATE) into Message;

    select FUNC_SET_DAILY_ACCOUNT_BALANCE(NEW.id,NEW.BEGINNING_BALANCE,5555,NEW.ENTRY_DATE) into Message;
	
END $$
DELIMITER ;


-- This Triger Insert or Update the Daily Account Balance when ever new entry insert in Stock Accounting

drop trigger if Exists TR_Stock_Accounting_AFTER_INSERT;
DELIMITER $$
CREATE TRIGGER `TR_Stock_Accounting_AFTER_INSERT` AFTER INSERT ON `stock_accounting` FOR EACH ROW BEGIN
    Declare Message Text Default '';

    select FUNC_SET_DAILY_ACCOUNT_BALANCE(NEW.GL_ACC_ID,NEW.Amount,NEW.GL_FLAG,NEW.FORM_DATE) into Message;

	
END $$
DELIMITER ;

-- This Triger Reverse the Daily Account Balance when ever any entry deletes in Stock Accounting

drop trigger if Exists TR_Stock_Accounting_BEFORE_DELETE;
DELIMITER $$
CREATE TRIGGER `TR_Stock_Accounting_BEFORE_DELETE` BEFORE DELETE ON `stock_accounting` FOR EACH ROW BEGIN

    Declare Message Text Default '';

    -- Negative Sign is used to avoid reversal transactions instead simply subtract the amount
    Select FUNC_SET_DAILY_ACCOUNT_BALANCE(OLD.GL_ACC_ID,OLD.Amount*-1,OLD.GL_FLAG,OLD.FORM_DATE) into Message;
	
END $$
DELIMITER ;

-- This Triger Reverse the Daily Account Balance And Add Updated Amount in Daily Account Balance

drop trigger if Exists TR_Stock_Accounting_BEFORE_Update;
DELIMITER $$
CREATE TRIGGER `TR_Stock_Accounting_BEFORE_Update` BEFORE Update ON `stock_accounting` FOR EACH ROW BEGIN

    Declare Message Text Default '';

    -- Negative Sign is used to avoid reversal transactions instead simply subtract the amount
    Select FUNC_SET_DAILY_ACCOUNT_BALANCE(OLD.GL_ACC_ID,OLD.Amount*-1,OLD.GL_FLAG,OLD.FORM_DATE) into Message;
	
	Select FUNC_SET_DAILY_ACCOUNT_BALANCE(NEW.GL_ACC_ID,NEW.Amount,NEW.GL_FLAG,NEW.FORM_DATE) into Message;
	
	
END $$
DELIMITER ;

-- This Triger Insert or Update the Daily Account Balance when ever new entry insert in Repair Accounting

drop trigger if Exists TR_Repair_Accounting_AFTER_INSERT;
DELIMITER $$
CREATE  TRIGGER `TR_Repair_Accounting_AFTER_INSERT` AFTER INSERT ON `repair_accounting`  FOR EACH ROW BEGIN
    Declare Message Text Default '';


    select FUNC_SET_DAILY_ACCOUNT_BALANCE(NEW.GL_ACC_ID,NEW.Amount,NEW.GL_FLAG,NEW.FORM_DATE) into Message;

END $$
DELIMITER ;

-- This Triger Reverse the Daily Account Balance when ever any entry deletes in Repair Accounting

drop trigger if Exists TR_Repair_Accounting_BEFORE_DELETE;
DELIMITER $$
CREATE TRIGGER `TR_Repair_Accounting_BEFORE_DELETE` BEFORE DELETE ON `repair_accounting` FOR EACH ROW BEGIN

    Declare Message Text Default '';

   
    -- Negative Sign is used to avoid reversal transactions instead simply subtract the amount
    select FUNC_SET_DAILY_ACCOUNT_BALANCE(OLD.GL_ACC_ID,OLD.Amount*-1,OLD.GL_FLAG,OLD.FORM_DATE) into Message;
	
END $$
DELIMITER ;


-- This Triger Reverse the Daily Account Balance And Add Updated Amount in Daily Account Balance

drop trigger if Exists TR_Repair_Accounting_BEFORE_Update;
DELIMITER $$
CREATE TRIGGER `TR_Repair_Accounting_BEFORE_Update` BEFORE Update ON `repair_accounting` FOR EACH ROW BEGIN

    Declare Message Text Default '';

   
    -- Negative Sign is used to avoid reversal transactions instead simply subtract the amount
    select FUNC_SET_DAILY_ACCOUNT_BALANCE(OLD.GL_ACC_ID,OLD.Amount*-1,OLD.GL_FLAG,OLD.FORM_DATE) into Message;
	
    select FUNC_SET_DAILY_ACCOUNT_BALANCE(NEW.GL_ACC_ID,NEW.Amount,NEW.GL_FLAG,NEW.FORM_DATE) into Message;

	
END $$
DELIMITER ;


-- This Triger Insert or Update the Daily Account Balance when ever new entry insert in Payments Accounting

drop trigger if Exists TR_Payments_Accounting_After_Insert;
DELIMITER $$
CREATE  TRIGGER `TR_Payments_Accounting_After_Insert` AFTER INSERT ON `payments_accounting`  FOR EACH ROW BEGIN
    Declare Message Text Default '';


    select FUNC_SET_DAILY_ACCOUNT_BALANCE(NEW.GL_ACC_ID,NEW.Amount,NEW.GL_FLAG,NEW.FORM_DATE) into Message;

END $$
DELIMITER ;

-- This Triger Reverse the Daily Account Balance when ever any entry deletes in Payments Accounting

drop trigger if Exists TR_Payments_Accounting_BEFORE_DELETE;
DELIMITER $$
CREATE TRIGGER `TR_Payments_Accounting_BEFORE_DELETE` BEFORE DELETE ON `payments_accounting` FOR EACH ROW BEGIN
 
    Declare Message Text Default '';



    -- Negative Sign is used to avoid reversal transactions instead simply subtract the amount
    select FUNC_SET_DAILY_ACCOUNT_BALANCE(OLD.GL_ACC_ID,OLD.Amount*-1,OLD.GL_FLAG,OLD.FORM_DATE) into Message;
	
END $$
DELIMITER ;


-- This Triger Reverse the Daily Account Balance And Add Updated Amount in Daily Account Balance

drop trigger if Exists TR_Payments_Accounting_BEFORE_Update;
DELIMITER $$
CREATE TRIGGER `TR_Payments_Accounting_BEFORE_Update` BEFORE Update ON `payments_accounting` FOR EACH ROW BEGIN
 
    Declare Message Text Default '';



    -- Negative Sign is used to avoid reversal transactions instead simply subtract the amount
    select FUNC_SET_DAILY_ACCOUNT_BALANCE(OLD.GL_ACC_ID,OLD.Amount*-1,OLD.GL_FLAG,OLD.FORM_DATE) into Message;
	
	select FUNC_SET_DAILY_ACCOUNT_BALANCE(NEW.GL_ACC_ID,NEW.Amount,NEW.GL_FLAG,NEW.FORM_DATE) into Message;

	
END $$
DELIMITER ;


-- This Triger Insert or Update the Daily Account Balance when ever new entry insert in Sales Accounting

drop trigger if Exists TR_Sales_Accounting_AFTER_INSERT;
DELIMITER $$
CREATE  TRIGGER `TR_Sales_Accounting_AFTER_INSERT` AFTER INSERT ON `sales_accounting`  FOR EACH ROW BEGIN
    Declare Message Text Default '';


    select FUNC_SET_DAILY_ACCOUNT_BALANCE(NEW.GL_ACC_ID,NEW.Amount,NEW.GL_FLAG,NEW.FORM_DATE)into Message;

END $$
DELIMITER ;

-- This Triger Reverse the Daily Account Balance when ever any entry deletes in Sales Accounting

drop trigger if Exists TR_Sales_Accounting_BEFORE_DELETE;
DELIMITER $$
CREATE  TRIGGER `TR_Sales_Accounting_BEFORE_DELETE` BEFORE DELETE ON `sales_accounting` FOR EACH ROW BEGIN
    Declare Message Text Default '';


    -- Negative Sign is used to avoid reversal transactions instead simply subtract the amount
    select FUNC_SET_DAILY_ACCOUNT_BALANCE(OLD.GL_ACC_ID,OLD.Amount*-1,OLD.GL_FLAG,OLD.FORM_DATE) into Message;
	
END $$
DELIMITER ;


-- This Triger Reverse the Daily Account Balance And Add Updated Amount in Daily Account Balance

drop trigger if Exists TR_Sales_Accounting_BEFORE_Update;
DELIMITER $$
CREATE  TRIGGER `TR_Sales_Accounting_BEFORE_Update` BEFORE Update ON `sales_accounting` FOR EACH ROW BEGIN
    Declare Message Text Default '';


    -- Negative Sign is used to avoid reversal transactions instead simply subtract the amount
    select FUNC_SET_DAILY_ACCOUNT_BALANCE(OLD.GL_ACC_ID,OLD.Amount*-1,OLD.GL_FLAG,OLD.FORM_DATE) into Message;
	
	select FUNC_SET_DAILY_ACCOUNT_BALANCE(NEW.GL_ACC_ID,NEW.Amount,NEW.GL_FLAG,NEW.FORM_DATE) into Message;

END $$
DELIMITER ;


-- This Triger Insert or Update the Daily Account Balance when ever new entry insert in Purchase Accounting

drop trigger if Exists TR_Purchase_Accounting_AFTER_INSERT;
DELIMITER $$
CREATE  TRIGGER `TR_Purchase_Accounting_AFTER_INSERT` AFTER INSERT ON `purchase_accounting`  FOR EACH ROW BEGIN
    Declare Message Text Default '';

    select FUNC_SET_DAILY_ACCOUNT_BALANCE(NEW.GL_ACC_ID,NEW.Amount,NEW.GL_FLAG,NEW.FORM_DATE) into Message;

END $$
DELIMITER ;

-- This Triger Reverse the Daily Account Balance when ever any entry deletes in Purchase Accounting

drop trigger if Exists TR_Purchase_Accounting_BEFORE_DELETE;
DELIMITER $$
CREATE  TRIGGER `TR_Purchase_Accounting_BEFORE_DELETE` BEFORE DELETE ON `purchase_accounting` FOR EACH ROW BEGIN
    Declare Message Text Default '';


    -- Negative Sign is used to avoid reversal transactions instead simply subtract the amount
    select FUNC_SET_DAILY_ACCOUNT_BALANCE(OLD.GL_ACC_ID,OLD.Amount*-1,OLD.GL_FLAG,OLD.FORM_DATE) into Message;
	
END $$
DELIMITER ;


-- This Triger Reverse the Daily Account Balance And Add Updated Amount in Daily Account Balance

drop trigger if Exists TR_Purchase_Accounting_BEFORE_Update;
DELIMITER $$
CREATE  TRIGGER `TR_Purchase_Accounting_BEFORE_Update` BEFORE Update ON `purchase_accounting` FOR EACH ROW BEGIN
    Declare Message Text Default '';


    -- Negative Sign is used to avoid reversal transactions instead simply subtract the amount
    select FUNC_SET_DAILY_ACCOUNT_BALANCE(OLD.GL_ACC_ID,OLD.Amount*-1,OLD.GL_FLAG,OLD.FORM_DATE) into Message;
	
    select FUNC_SET_DAILY_ACCOUNT_BALANCE(NEW.GL_ACC_ID,NEW.Amount,NEW.GL_FLAG,NEW.FORM_DATE) into Message;
	
	
END $$
DELIMITER ;


-- This Triger Insert or Update the Daily Account Balance when ever new entry insert in Adjustment Accounting

drop trigger if Exists TR_Adjustment_Accounting_AFTER_INSERT;
DELIMITER $$
CREATE  TRIGGER `TR_Adjustment_Accounting_AFTER_INSERT` AFTER INSERT ON `adjustment_accounting`  FOR EACH ROW BEGIN
    Declare Message Text Default '';


    select FUNC_SET_DAILY_ACCOUNT_BALANCE(NEW.GL_ACC_ID,NEW.Amount,NEW.GL_FLAG,NEW.FORM_DATE) into Message;

END $$
DELIMITER ;

-- This Triger Reverse the Daily Account Balance when ever any entry deletes in Adjustment Accounting

drop trigger if Exists TR_Adjustment_Accounting_BEFORE_DELETE;
DELIMITER $$
CREATE  TRIGGER `TR_Adjustment_Accounting_BEFORE_DELETE` BEFORE DELETE ON `adjustment_accounting` FOR EACH ROW BEGIN

    Declare Message Text Default '';

    -- Negative Sign is used to avoid reversal transactions instead simply subtract the amount
   select FUNC_SET_DAILY_ACCOUNT_BALANCE(OLD.GL_ACC_ID,OLD.Amount*-1,OLD.GL_FLAG,OLD.FORM_DATE) into Message;
	
END $$
DELIMITER ;


-- This Triger Reverse the Daily Account Balance And Add Updated Amount in Daily Account Balance

drop trigger if Exists TR_Adjustment_Accounting_BEFORE_Update;
DELIMITER $$
CREATE  TRIGGER `TR_Adjustment_Accounting_BEFORE_Update` BEFORE Update ON `adjustment_accounting` FOR EACH ROW BEGIN

    Declare Message Text Default '';

    -- Negative Sign is used to avoid reversal transactions instead simply subtract the amount
   select FUNC_SET_DAILY_ACCOUNT_BALANCE(OLD.GL_ACC_ID,OLD.Amount*-1,OLD.GL_FLAG,OLD.FORM_DATE) into Message;
   
   select FUNC_SET_DAILY_ACCOUNT_BALANCE(NEW.GL_ACC_ID,NEW.Amount,NEW.GL_FLAG,NEW.FORM_DATE) into Message;

	
END $$
DELIMITER ;

drop trigger if exists TR_ACCOUNTS_ID;
drop trigger if exists TR_ACCOUNTS_ID_DEL;
drop trigger if exists TR_ACCOUNTS_ID_UPDATE;
drop trigger if exists TR_STOCK_ACCOUNTING;
drop trigger if exists TR_STOCK_ACCOUNTING_UPDATE;
drop trigger if exists TR_STOCK_ACCOUNTING_DEL;
drop trigger if exists TR_REPAIR_ACCOUNTING;
drop trigger if exists TR_REPAIR_ACCOUNTING_UPDATE;
drop trigger if exists TR_REPAIR_ACCOUNTING_DEL;
drop trigger if exists TR_PAYMENTS_ACCOUNTING;
drop trigger if exists TR_PAYMENTS_ACCOUNTING_UPT;
drop trigger if exists TR_PAYMENTS_ACCOUNTING_DEL;
drop trigger if exists TR_SALES_ACCOUNTING;
drop trigger if exists TR_SALES_ACCOUNTING_UPDATE;
drop trigger if exists TR_SALES_ACCOUNTING_DEL;
drop trigger if Exists TR_PURCHASE_ACCOUNTING;
drop trigger if exists TR_PURCHASE_ACCOUNTING_UPDATE;
drop trigger if exists TR_PURCHASE_ACCOUNTING_DEL;
drop trigger if Exists TR_ADJUSTMENT_ACCOUNTING;
drop trigger if Exists TR_ADJUSTMENT_ACCOUNTING_UPDATE;
drop trigger if Exists TR_ADJUSTMENT_ACCOUNTING_DEL;



-- This Triger insert the Opening Balance of New Account

drop trigger if Exists TR_ACCOUNTS_ID;
DELIMITER $$
CREATE TRIGGER `TR_ACCOUNTS_ID` AFTER INSERT ON `accounts_id` FOR EACH ROW BEGIN

    Declare Message Text Default '';
    select FUNC_SET_DAILY_ACCOUNT_BALANCE(NEW.id,NEW.BEGINNING_BALANCE,5555,NEW.ENTRY_DATE) into Message;

END $$
DELIMITER ;

-- This Trigger Delete the Daily Balance Account before Delete 

drop trigger if Exists TR_ACCOUNTS_ID_DEL;
DELIMITER $$
CREATE TRIGGER `TR_ACCOUNTS_ID_DEL` Before Delete ON `accounts_id` FOR EACH ROW BEGIN

    Delete from DailyAccountBalance where AccountId = OLD.ID;
	
END $$
DELIMITER ;


-- This Trigger Update the Daily Account Balance before Update 

drop trigger if Exists TR_ACCOUNTS_ID_UPDATE;
DELIMITER $$
CREATE TRIGGER `TR_ACCOUNTS_ID_UPDATE` Before Update ON `accounts_id` FOR EACH ROW BEGIN

    Declare Message Text Default '';

    select FUNC_SET_DAILY_ACCOUNT_BALANCE(OLD.id,OLD.BEGINNING_BALANCE * -1,5555,OLD.ENTRY_DATE) into Message;

    select FUNC_SET_DAILY_ACCOUNT_BALANCE(NEW.id,NEW.BEGINNING_BALANCE,5555,NEW.ENTRY_DATE) into Message;
	
END $$
DELIMITER ;


-- This Triger Insert or Update the Daily Account Balance when ever new entry insert in Stock Accounting

drop trigger if Exists TR_STOCK_ACCOUNTING;
DELIMITER $$
CREATE TRIGGER `TR_STOCK_ACCOUNTING` AFTER INSERT ON `stock_accounting` FOR EACH ROW BEGIN
    Declare Message Text Default '';

    select FUNC_SET_DAILY_ACCOUNT_BALANCE(NEW.GL_ACC_ID,NEW.Amount,NEW.GL_FLAG,NEW.FORM_DATE) into Message;

	
END $$
DELIMITER ;

-- This Triger Reverse the Daily Account Balance when ever any entry deletes in Stock Accounting

drop trigger if Exists TR_STOCK_ACCOUNTING_DEL;
DELIMITER $$
CREATE TRIGGER `TR_STOCK_ACCOUNTING_DEL` BEFORE DELETE ON `stock_accounting` FOR EACH ROW BEGIN

    Declare Message Text Default '';

    -- Negative Sign is used to avoid reversal transactions instead simply subtract the amount
    Select FUNC_SET_DAILY_ACCOUNT_BALANCE(OLD.GL_ACC_ID,OLD.Amount*-1,OLD.GL_FLAG,OLD.FORM_DATE) into Message;
	
END $$
DELIMITER ;


drop trigger if Exists TR_REPAIR_ACCOUNTING;
DELIMITER $$
CREATE  TRIGGER `TR_REPAIR_ACCOUNTING` AFTER INSERT ON `repair_accounting`  FOR EACH ROW BEGIN
    Declare Message Text Default '';


    select FUNC_SET_DAILY_ACCOUNT_BALANCE(NEW.GL_ACC_ID,NEW.Amount,NEW.GL_FLAG,NEW.FORM_DATE) into Message;

END $$
DELIMITER ;

-- This Triger Reverse the Daily Account Balance when ever any entry deletes in Repair Accounting

drop trigger if Exists TR_REPAIR_ACCOUNTING_DEL;
DELIMITER $$
CREATE TRIGGER `TR_REPAIR_ACCOUNTING_DEL` BEFORE DELETE ON `repair_accounting` FOR EACH ROW BEGIN

    Declare Message Text Default '';

   
    -- Negative Sign is used to avoid reversal transactions instead simply subtract the amount
    select FUNC_SET_DAILY_ACCOUNT_BALANCE(OLD.GL_ACC_ID,OLD.Amount*-1,OLD.GL_FLAG,OLD.FORM_DATE) into Message;
	
END $$
DELIMITER ;


-- This Triger Reverse the Daily Account Balance And Add Updated Amount in Daily Account Balance

drop trigger if Exists TR_REPAIR_ACCOUNTING_UPDATE;
DELIMITER $$
CREATE TRIGGER `TR_REPAIR_ACCOUNTING_UPDATE` BEFORE Update ON `repair_accounting` FOR EACH ROW BEGIN

    Declare Message Text Default '';

   
    -- Negative Sign is used to avoid reversal transactions instead simply subtract the amount
    select FUNC_SET_DAILY_ACCOUNT_BALANCE(OLD.GL_ACC_ID,OLD.Amount*-1,OLD.GL_FLAG,OLD.FORM_DATE) into Message;
	
    select FUNC_SET_DAILY_ACCOUNT_BALANCE(NEW.GL_ACC_ID,NEW.Amount,NEW.GL_FLAG,NEW.FORM_DATE) into Message;

	
END $$
DELIMITER ;


-- This Triger Insert or Update the Daily Account Balance when ever new entry insert in Payments Accounting

drop trigger if Exists TR_PAYMENTS_ACCOUNTING;
DELIMITER $$
CREATE  TRIGGER `TR_PAYMENTS_ACCOUNTING` AFTER INSERT ON `payments_accounting`  FOR EACH ROW BEGIN
    Declare Message Text Default '';


    select FUNC_SET_DAILY_ACCOUNT_BALANCE(NEW.GL_ACC_ID,NEW.Amount,NEW.GL_FLAG,NEW.FORM_DATE) into Message;

END $$
DELIMITER ;

-- This Triger Reverse the Daily Account Balance when ever any entry deletes in Payments Accounting

drop trigger if Exists TR_PAYMENTS_ACCOUNTING_DEL;
DELIMITER $$
CREATE TRIGGER `TR_PAYMENTS_ACCOUNTING_DEL` BEFORE DELETE ON `payments_accounting` FOR EACH ROW BEGIN
 
    Declare Message Text Default '';



    -- Negative Sign is used to avoid reversal transactions instead simply subtract the amount
    select FUNC_SET_DAILY_ACCOUNT_BALANCE(OLD.GL_ACC_ID,OLD.Amount*-1,OLD.GL_FLAG,OLD.FORM_DATE) into Message;
	
END $$
DELIMITER ;


-- This Triger Insert or Update the Daily Account Balance when ever new entry insert in Sales Accounting

drop trigger if Exists TR_SALES_ACCOUNTING;
DELIMITER $$
CREATE  TRIGGER `TR_SALES_ACCOUNTING` AFTER INSERT ON `sales_accounting`  FOR EACH ROW BEGIN
    Declare Message Text Default '';


    select FUNC_SET_DAILY_ACCOUNT_BALANCE(NEW.GL_ACC_ID,NEW.Amount,NEW.GL_FLAG,NEW.FORM_DATE)into Message;

END $$
DELIMITER ;

-- This Triger Reverse the Daily Account Balance when ever any entry deletes in Sales Accounting

drop trigger if Exists TR_SALES_ACCOUNTING_DEL;
DELIMITER $$
CREATE  TRIGGER `TR_SALES_ACCOUNTING_DEL` BEFORE DELETE ON `sales_accounting` FOR EACH ROW BEGIN
    Declare Message Text Default '';


    -- Negative Sign is used to avoid reversal transactions instead simply subtract the amount
    select FUNC_SET_DAILY_ACCOUNT_BALANCE(OLD.GL_ACC_ID,OLD.Amount*-1,OLD.GL_FLAG,OLD.FORM_DATE) into Message;
	
END $$
DELIMITER ;

-- This Triger Insert or Update the Daily Account Balance when ever new entry insert in Purchase Accounting

drop trigger if Exists TR_PURCHASE_ACCOUNTING;
DELIMITER $$
CREATE  TRIGGER `TR_PURCHASE_ACCOUNTING` AFTER INSERT ON `purchase_accounting`  FOR EACH ROW BEGIN
    Declare Message Text Default '';

    select FUNC_SET_DAILY_ACCOUNT_BALANCE(NEW.GL_ACC_ID,NEW.Amount,NEW.GL_FLAG,NEW.FORM_DATE) into Message;

END $$
DELIMITER ;

-- This Triger Reverse the Daily Account Balance when ever any entry deletes in Purchase Accounting

drop trigger if Exists TR_PURCHASE_ACCOUNTING_DEL;
DELIMITER $$
CREATE  TRIGGER `TR_PURCHASE_ACCOUNTING_DEL` BEFORE DELETE ON `purchase_accounting` FOR EACH ROW BEGIN
    Declare Message Text Default '';


    -- Negative Sign is used to avoid reversal transactions instead simply subtract the amount
    select FUNC_SET_DAILY_ACCOUNT_BALANCE(OLD.GL_ACC_ID,OLD.Amount*-1,OLD.GL_FLAG,OLD.FORM_DATE) into Message;
	
END $$
DELIMITER ;


-- This Triger Insert or Update the Daily Account Balance when ever new entry insert in Adjustment Accounting

drop trigger if Exists TR_ADJUSTMENT_ACCOUNTING;
DELIMITER $$
CREATE  TRIGGER `TR_ADJUSTMENT_ACCOUNTING` AFTER INSERT ON `adjustment_accounting`  FOR EACH ROW BEGIN
    Declare Message Text Default '';


    select FUNC_SET_DAILY_ACCOUNT_BALANCE(NEW.GL_ACC_ID,NEW.Amount,NEW.GL_FLAG,NEW.FORM_DATE) into Message;

END $$
DELIMITER ;

-- This Triger Reverse the Daily Account Balance when ever any entry deletes in Adjustment Accounting

drop trigger if Exists TR_ADJUSTMENT_ACCOUNTING_DEL;
DELIMITER $$
CREATE  TRIGGER `TR_ADJUSTMENT_ACCOUNTING_DEL` BEFORE DELETE ON `adjustment_accounting` FOR EACH ROW BEGIN

    Declare Message Text Default '';

    -- Negative Sign is used to avoid reversal transactions instead simply subtract the amount
   select FUNC_SET_DAILY_ACCOUNT_BALANCE(OLD.GL_ACC_ID,OLD.Amount*-1,OLD.GL_FLAG,OLD.FORM_DATE) into Message;
	
END $$
DELIMITER ;




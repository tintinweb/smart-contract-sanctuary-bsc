/**
 *Submitted for verification at BscScan.com on 2022-06-24
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;
//import 'https://trontopone.top/date.sol';
//import 'https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary/blob/master/contracts/BokkyPooBahsDateTimeLibrary.sol';

library BokkyPooBahsDateTimeLibrary {

    uint constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint constant SECONDS_PER_HOUR = 60 * 60;
    uint constant SECONDS_PER_MINUTE = 60;
    int constant OFFSET19700101 = 2440588;

    uint constant DOW_MON = 1;
    uint constant DOW_TUE = 2;
    uint constant DOW_WED = 3;
    uint constant DOW_THU = 4;
    uint constant DOW_FRI = 5;
    uint constant DOW_SAT = 6;
    uint constant DOW_SUN = 7;

    // ------------------------------------------------------------------------
    // Calculate the number of days from 1970/01/01 to year/month/day using
    // the date conversion algorithm from
    //   https://aa.usno.navy.mil/faq/JD_formula.html
    // and subtracting the offset 2440588 so that 1970/01/01 is day 0
    //
    // days = day
    //      - 32075
    //      + 1461 * (year + 4800 + (month - 14) / 12) / 4
    //      + 367 * (month - 2 - (month - 14) / 12 * 12) / 12
    //      - 3 * ((year + 4900 + (month - 14) / 12) / 100) / 4
    //      - offset
    // ------------------------------------------------------------------------
    function _daysFromDate(uint year, uint month, uint day) internal pure returns (uint _days) {
        require(year >= 1970);
        int _year = int(year);
        int _month = int(month);
        int _day = int(day);

        int __days = _day
          - 32075
          + 1461 * (_year + 4800 + (_month - 14) / 12) / 4
          + 367 * (_month - 2 - (_month - 14) / 12 * 12) / 12
          - 3 * ((_year + 4900 + (_month - 14) / 12) / 100) / 4
          - OFFSET19700101;

        _days = uint(__days);
    }

    // ------------------------------------------------------------------------
    // Calculate year/month/day from the number of days since 1970/01/01 using
    // the date conversion algorithm from
    //   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
    // and adding the offset 2440588 so that 1970/01/01 is day 0
    //
    // int L = days + 68569 + offset
    // int N = 4 * L / 146097
    // L = L - (146097 * N + 3) / 4
    // year = 4000 * (L + 1) / 1461001
    // L = L - 1461 * year / 4 + 31
    // month = 80 * L / 2447
    // dd = L - 2447 * month / 80
    // L = month / 11
    // month = month + 2 - 12 * L
    // year = 100 * (N - 49) + year + L
    // ------------------------------------------------------------------------
    function _daysToDate(uint _days) internal pure returns (uint year, uint month, uint day) {
        int __days = int(_days);

        int L = __days + 68569 + OFFSET19700101;
        int N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        int _year = 4000 * (L + 1) / 1461001;
        L = L - 1461 * _year / 4 + 31;
        int _month = 80 * L / 2447;
        int _day = L - 2447 * _month / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint(_year);
        month = uint(_month);
        day = uint(_day);
    }

    function timestampFromDate(uint year, uint month, uint day) internal pure returns (uint timestamp) {
        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY;
    }
    function timestampFromDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) internal pure returns (uint timestamp) {
        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + hour * SECONDS_PER_HOUR + minute * SECONDS_PER_MINUTE + second;
    }
    function timestampToDate(uint timestamp) internal pure returns (uint year, uint month, uint day) {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function timestampToDateTime(uint timestamp) internal pure returns (uint year, uint month, uint day, uint hour, uint minute, uint second) {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
        secs = secs % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
        second = secs % SECONDS_PER_MINUTE;
    }

    function isValidDate(uint year, uint month, uint day) internal pure returns (bool valid) {
        if (year >= 1970 && month > 0 && month <= 12) {
            uint daysInMonth = _getDaysInMonth(year, month);
            if (day > 0 && day <= daysInMonth) {
                valid = true;
            }
        }
    }
    function isValidDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) internal pure returns (bool valid) {
        if (isValidDate(year, month, day)) {
            if (hour < 24 && minute < 60 && second < 60) {
                valid = true;
            }
        }
    }
    function isLeapYear(uint timestamp) internal pure returns (bool leapYear) {
        (uint year,,) = _daysToDate(timestamp / SECONDS_PER_DAY);
        leapYear = _isLeapYear(year);
    }
    function _isLeapYear(uint year) internal pure returns (bool leapYear) {
        leapYear = ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0);
    }
    function isWeekDay(uint timestamp) internal pure returns (bool weekDay) {
        weekDay = getDayOfWeek(timestamp) <= DOW_FRI;
    }
    function isWeekEnd(uint timestamp) internal pure returns (bool weekEnd) {
        weekEnd = getDayOfWeek(timestamp) >= DOW_SAT;
    }
    function getDaysInMonth(uint timestamp) internal pure returns (uint daysInMonth) {
        (uint year, uint month,) = _daysToDate(timestamp / SECONDS_PER_DAY);
        daysInMonth = _getDaysInMonth(year, month);
    }
    function _getDaysInMonth(uint year, uint month) internal pure returns (uint daysInMonth) {
        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
            daysInMonth = 31;
        } else if (month != 2) {
            daysInMonth = 30;
        } else {
            daysInMonth = _isLeapYear(year) ? 29 : 28;
        }
    }
    // 1 = Monday, 7 = Sunday
    function getDayOfWeek(uint timestamp) internal pure returns (uint dayOfWeek) {
        uint _days = timestamp / SECONDS_PER_DAY;
        dayOfWeek = (_days + 3) % 7 + 1;
    }

    function getYear(uint timestamp) internal pure returns (uint year) {
        (year,,) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getMonth(uint timestamp) internal pure returns (uint month) {
        (,month,) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getDay(uint timestamp) internal pure returns (uint day) {
        (,,day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getHour(uint timestamp) internal pure returns (uint hour) {
        uint secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
    }
    function getMinute(uint timestamp) internal pure returns (uint minute) {
        uint secs = timestamp % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
    }
    function getSecond(uint timestamp) internal pure returns (uint second) {
        second = timestamp % SECONDS_PER_MINUTE;
    }

    function addYears(uint timestamp, uint _years) internal pure returns (uint newTimestamp) {
        (uint year, uint month, uint day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        year += _years;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function addMonths(uint timestamp, uint _months) internal pure returns (uint newTimestamp) {
        (uint year, uint month, uint day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        month += _months;
        year += (month - 1) / 12;
        month = (month - 1) % 12 + 1;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function addDays(uint timestamp, uint _days) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp + _days * SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function addHours(uint timestamp, uint _hours) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp + _hours * SECONDS_PER_HOUR;
        require(newTimestamp >= timestamp);
    }
    function addMinutes(uint timestamp, uint _minutes) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp + _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp >= timestamp);
    }
    function addSeconds(uint timestamp, uint _seconds) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp + _seconds;
        require(newTimestamp >= timestamp);
    }

    function subYears(uint timestamp, uint _years) internal pure returns (uint newTimestamp) {
        (uint year, uint month, uint day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        year -= _years;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
    function subMonths(uint timestamp, uint _months) internal pure returns (uint newTimestamp) {
        (uint year, uint month, uint day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint yearMonth = year * 12 + (month - 1) - _months;
        year = yearMonth / 12;
        month = yearMonth % 12 + 1;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
    function subDays(uint timestamp, uint _days) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp - _days * SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
    function subHours(uint timestamp, uint _hours) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp - _hours * SECONDS_PER_HOUR;
        require(newTimestamp <= timestamp);
    }
    function subMinutes(uint timestamp, uint _minutes) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp - _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp <= timestamp);
    }
    function subSeconds(uint timestamp, uint _seconds) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp - _seconds;
        require(newTimestamp <= timestamp);
    }

    function diffYears(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _years) {
        require(fromTimestamp <= toTimestamp);
        (uint fromYear,,) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (uint toYear,,) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _years = toYear - fromYear;
    }
    function diffMonths(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _months) {
        require(fromTimestamp <= toTimestamp);
        (uint fromYear, uint fromMonth,) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (uint toYear, uint toMonth,) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _months = toYear * 12 + toMonth - fromYear * 12 - fromMonth;
    }
    function diffDays(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _days) {
        require(fromTimestamp <= toTimestamp);
        _days = (toTimestamp - fromTimestamp) / SECONDS_PER_DAY;
    }
    function diffHours(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _hours) {
        require(fromTimestamp <= toTimestamp);
        _hours = (toTimestamp - fromTimestamp) / SECONDS_PER_HOUR;
    }
    function diffMinutes(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _minutes) {
        require(fromTimestamp <= toTimestamp);
        _minutes = (toTimestamp - fromTimestamp) / SECONDS_PER_MINUTE;
    }
    function diffSeconds(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _seconds) {
        require(fromTimestamp <= toTimestamp);
        _seconds = toTimestamp - fromTimestamp;
    }
}

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }
  
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

}

interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  //function CheckTransferTimeExpiry() external view returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable {

  address public owner;
  address public manager;
  address  public ownerWallet;

  modifier onlyOwner() virtual  {
    require(msg.sender == owner, "only for owner");
    _;
  }

  function transferOwnership(address payable newOwner) public onlyOwner {
    owner = newOwner;
  }
  function transferManager(address newManager) public onlyOwner {
    manager = newManager;
  }  
  function transferOwnerWallet(address payable newOwnerWallet) public onlyOwner {
    ownerWallet = newOwnerWallet;
  }
}

contract  BSmartC is Ownable  {
    
    //Libraries
	using SafeMath for uint256;
	using BokkyPooBahsDateTimeLibrary for uint256;
	
	
	//events
    event regLevelEvent(address indexed _user, address indexed _referrer, uint _time);
    event buyLevelEvent(address indexed _user, uint _level, uint _time);
    event prolongateLevelEvent(address indexed _user, uint _level, uint _time);
    event getMoneyForLevelEvent(address indexed _user, address indexed _referral, uint _level, uint _time);
    event lostMoneyForLevelEvent(address indexed _user, address indexed _referral, uint _level, uint _time);
    event InvestedAt(address user,uint value);
    //------------------------------

    //Variable
    mapping (uint => uint) public LEVEL_PRICE;
    uint REFERRER_1_LEVEL_LIMIT = 2;
    uint PERIOD_LENGTH = 365 days;
    uint public totalInvestors;
    uint public totalInvested;
    uint public totalRefRewards;
    
    IBEP20 public itoken;
    address public _token_address = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee;

    struct Plan {
      //uint id;
      string name;
      uint time;  // مدت طرح
      uint percent; // مبلغ سود
      uint Status;
      //bool isExist;
    }
    //mapping (uint => Plan) public Plans;    
    Plan[] public Plans;

    struct  Deposit {
      //uint256 depID;
      uint PlanID; // کد طرح سرمایه گذاری
      uint amount; // مبلغ سرمایه گذاری
      uint at; // تاریخ سرمایه گذاری
    }
    mapping (address => Deposit) public Deposits;
    uint256 DepIDCounter = 0;

    
    struct UserStruct {
        bool isExist;
        uint256 id;
        uint referrerID;
        address[] referral;
        
        //bool registered; //وضعیت سرمایه گذار از نظر ثبت نام
        address referrer; // آدرس رده بالاتر
        uint referral_counter; // تعداد زیر مجموعه
        uint balanceRef; // مبلغ قابل برداشت
        uint totalRef; // کل پاداش ارجاع
        Deposit[] deposits; // لیست تمام سرمایه گذاری ها
        uint invested; // مبلغ کل سرمایه گذاری
        uint lastPaidAt; // تاریخ آخرین برداشت
        uint withdrawn; // مبلغ کل برداشت        
        //mapping (uint => uint) levelExpired;
    }
    mapping (address => UserStruct) public users;
    mapping (uint => address) public userList;
    
    mapping (uint => bool) public userRefComplete;	
	mapping (address => uint) public profitStat;
	uint[8] public levelStat;
    uint public currUserID = 0;
    uint public PlanCounter = 0;
	uint refCompleteDepth = 1;
    bool private _paused = false;

    constructor(address  _manager, address  _owner) public {
		owner = msg.sender;
		//owner = _owner;
		manager = _manager;
		ownerWallet = _owner;

        
        Plans.push(Plan("Tin coin",365 * 28800,4,1));
        Plans.push(Plan("Bronze coin",365 * 28800,5,1));
        Plans.push(Plan("Silver coin",365 * 28800,6,1));
        Plans.push(Plan("Gold coin",365 * 28800,7,1));
        Plans.push(Plan("Emerald coin",365 * 28800,8,1));
        Plans.push(Plan("Ruby coin",365 * 28800,9,1));
        Plans.push(Plan("Diamond coin",365 * 28800,10,1));
        Plans.push(Plan("Black diamond coin",365 * 28800,11,1));
        Plans.push(Plan("Red diamond coin",365 * 28800,12,1));
        Plans.push(Plan("Blue diamond coin",365 * 28800,13,1));
	
        /*LEVEL_PRICE[1] = 200000000; //200trx
        LEVEL_PRICE[2] = LEVEL_PRICE[1] * 2;
        LEVEL_PRICE[3] = LEVEL_PRICE[2] * 3;
        LEVEL_PRICE[4] = LEVEL_PRICE[3] * 4;
        LEVEL_PRICE[5] = LEVEL_PRICE[4] * 2;
        LEVEL_PRICE[6] = LEVEL_PRICE[5] * 2;
        LEVEL_PRICE[7] = LEVEL_PRICE[6] * 2;
        LEVEL_PRICE[8] = LEVEL_PRICE[7] * 2;*/

        //
        currUserID++;
        users[ownerWallet].isExist = true;
        users[ownerWallet].id = currUserID;
        users[ownerWallet].referrerID = 0;
        users[ownerWallet].referral = new address[](0);
        users[ownerWallet].referrer =  msg.sender;
        users[ownerWallet].referral_counter = 0;
        users[ownerWallet].balanceRef = 0;
        users[ownerWallet].totalRef = 0;
        users[ownerWallet].deposits.push(Deposit(0,0,block.number));
        users[ownerWallet].invested = 0;
        users[ownerWallet].lastPaidAt = 0;
        users[ownerWallet].withdrawn = 0;
        //


        /*UserStruct memory userStruct;
        userStruct = UserStruct({
            isExist : true,
            id : currUserID,
            referrerID : 0,
            referral : new address[](0),
            referrer : msg.sender,
            referral_counter : 0,
            balanceRef : 0,
            totalRef : 0,
            Deposit : new Deposit[](0),
            invested : 0,
            lastPaidAt :0,
            withdrawn : 0
        });
        users[ownerWallet] = userStruct;

        Deposits[ownerWallet].PlanID = 0;
        Deposits[ownerWallet].amount = 0;
        Deposits[ownerWallet].at = 0;*/

        userList[currUserID] = ownerWallet;
        

        /*users[ownerWallet].levelExpired[1] = 77777777777;
        users[ownerWallet].levelExpired[2] = 77777777777;
        users[ownerWallet].levelExpired[3] = 77777777777;
        users[ownerWallet].levelExpired[4] = 77777777777;
        users[ownerWallet].levelExpired[5] = 77777777777;
        users[ownerWallet].levelExpired[6] = 77777777777;
        users[ownerWallet].levelExpired[7] = 77777777777;
        users[ownerWallet].levelExpired[8] = 77777777777;*/
    }

    function regUser(address _referrer, uint tariff, uint amount) public payable {
        require(!users[msg.sender].isExist, 'User exist');

		uint _referrerID;
		
		if (users[_referrer].isExist){
			_referrerID = users[_referrer].id;
		} else if (_referrer == address(0)) {
			_referrerID = findFirstFreeReferrer();
			refCompleteDepth = _referrerID;
		} else {
			revert('Incorrect referrer');
		}		

        require(_referrerID > 0 && _referrerID <= currUserID, 'Incorrect referrer Id');

        //require(msg.value==LEVEL_PRICE[1], 'Incorrect Value');
        
        /*if(users[userList[_referrerID]].referral.length >= REFERRER_1_LEVEL_LIMIT)
        {
            _referrerID = users[findFreeReferrer(userList[_referrerID])].id;
        }*/

        currUserID++;
        users[msg.sender].id = currUserID;
        users[msg.sender].referrerID = _referrerID;
        users[msg.sender].referral = new address[](0);
        users[msg.sender].referrer =  msg.sender;
        users[msg.sender].referral_counter = users[userList[_referrerID]].referral_counter + 1;
        users[msg.sender].balanceRef += amount;
        users[msg.sender].totalRef += amount;
        users[msg.sender].deposits.push(Deposit(tariff,amount,block.number));
        users[msg.sender].invested += amount;
        //users[msg.sender].invested+=msg.value;
        users[msg.sender].lastPaidAt = block.number;
        users[msg.sender].withdrawn += amount;
        users[msg.sender].isExist = true;

        /*users[userList[_referrerID]].balanceRef+=msg.value *5 / 100;
        users[userList[_referrerID]].totalRef+=msg.value *5 / 100;
        totalRefRewards+=msg.value *5 / 100;
        totalInvested+=msg.value;*/
        users[userList[_referrerID]].balanceRef+=amount *5 / 100;
        users[userList[_referrerID]].totalRef+=amount *5 / 100;
        totalRefRewards+amount *5 / 100;
        totalInvested+=amount;

        //owner.transfer(msg.value /20);
        //

        /*UserStruct memory userStruct;
        userStruct = UserStruct({
            isExist : true,
            id : currUserID,
            referrerID : _referrerID,
            referral : new address[](0),
            referral_counter :  users[userList[_referrerID]].referral_counter + 1,
            referrer : msg.sender,
            balanceRef : 0,
            totalRef : 0,
            Deposit : new Deposit[](0),
            invested : 0,
            lastPaidAt :0,
            withdrawn : 0
        });
        users[msg.sender] = userStruct;*/

        userList[currUserID] = msg.sender;

        /*DepIDCounter++;
        //Deposits[ownerWallet].depID = DepIDCounter;
        //Deposits[ownerWallet].PlanID = tariff;
        //Deposits[ownerWallet].amount = msg.value;
        //Deposits[ownerWallet].at = block.number;*/


        //users[msg.sender].levelExpired[1] = now + PERIOD_LENGTH;
        //users[msg.sender].levelExpired[2] = 0;
        //users[msg.sender].levelExpired[3] = 0;
        //users[msg.sender].levelExpired[4] = 0;
        //users[msg.sender].levelExpired[5] = 0;
        //users[msg.sender].levelExpired[6] = 0;
        //users[msg.sender].levelExpired[7] = 0;
        //users[msg.sender].levelExpired[8] = 0;

        users[userList[_referrerID]].referral.push(msg.sender);
		
		if (users[userList[_referrerID]].referral.length == 2) {
			userRefComplete[_referrerID] = true;
		}
        
        //itoken = IBEP20(address(_token_address));
        //itoken.transfer(owner, 1 );
        //payForLevel(1,0,0, msg.sender);

        emit regLevelEvent(msg.sender, userList[_referrerID], block.timestamp);
    }
    
    /*function payForLevel(uint _level ,uint _LostValueStatus, uint _LostValue , address _user) internal {
        address referer;
        address referer1;
        address referer2;
        address referer3;
        if(_level == 1 || _level == 5){
            referer = userList[users[_user].referrerID];
        } else if(_level == 2 || _level == 6){
            referer1 = userList[users[_user].referrerID];
            referer = userList[users[referer1].referrerID];
        } else if(_level == 3 || _level == 7){
            referer1 = userList[users[_user].referrerID];
            referer2 = userList[users[referer1].referrerID];
            referer = userList[users[referer2].referrerID];
        } else if(_level == 4 || _level == 8){
            referer1 = userList[users[_user].referrerID];
            referer2 = userList[users[referer1].referrerID];
            referer3 = userList[users[referer2].referrerID];
            referer = userList[users[referer3].referrerID];
        }

        if(!users[referer].isExist){
            referer = userList[1];
        }

        if(users[referer].levelExpired[_level] >= now ){
            if(_LostValueStatus == 0)
            {
                if (referer == userList[1]) {
                    referer.transfer(LEVEL_PRICE[_level].mul(100).div(100));
                }
                else {
                    referer.transfer(LEVEL_PRICE[_level]);
                    profitStat[referer] += LEVEL_PRICE[_level];
                }
                levelStat[_level-1]++;
                emit getMoneyForLevelEvent(referer, msg.sender, _level, now);
            }
            ///////
            else
            {
                if (referer == userList[1]) {
	            referer.transfer(_LostValue.mul(100).div(100));
			}
			else {
			    referer.transfer(_LostValue);
				profitStat[referer] += LEVEL_PRICE[_level];
			}
			levelStat[_level-1]++;			
            emit getMoneyForLevelEvent(referer, msg.sender, _level, now);
            }
        }
        else{
            emit lostMoneyForLevelEvent(referer, msg.sender, _level, now);
            _LostValueStatus = 1;
            /////////
            if(_LostValue == 0){
            _LostValue = LEVEL_PRICE[_level].mul(50).div(100);
            }
            else{
                _LostValue = _LostValue.mul(50).div(100);
            }
	        ownerWallet.transfer(_LostValue.mul(100).div(100));
            payForLevel(_level,_LostValueStatus,_LostValue,referer);
        }
    }*/

    /*function buyLevel(uint _level) public payable {
        require(users[msg.sender].isExist, 'User not exist');

        require( _level>0 && _level<=8, 'Incorrect level');

        if(_level == 1){
            require(msg.value==LEVEL_PRICE[1], 'Incorrect Value');
            users[msg.sender].levelExpired[1] += PERIOD_LENGTH;
        } else {
            require(msg.value==LEVEL_PRICE[_level], 'Incorrect Value');

            for(uint l =_level-1; l>0; l-- ){
                require(users[msg.sender].levelExpired[l] >= now, 'Buy the previous level');
            }

            if(users[msg.sender].levelExpired[_level] == 0){
                users[msg.sender].levelExpired[_level] = now + PERIOD_LENGTH;
            } else {
                users[msg.sender].levelExpired[_level] += PERIOD_LENGTH;
            }
        }
        payForLevel(_level,0,0, msg.sender);
        emit buyLevelEvent(msg.sender, _level, now);
    }*/
	
    function SetPlansStatus() public view returns(bool){

        return true;
    }

    function AddPlan(string memory name, uint time, uint percent, uint Status) public onlyOwner {        
        /*Plan memory plan;
        plan = Plan({
            //id : PlanCounter,
            name : name,
            time : time,
            percent : percent,
            Status : Status
            //isExist : true
        });
        Plans[PlanCounter] = plan;
        PlanCounter ++;*/
        
        Plans.push(Plan(name,time * 28800,percent,1));
    }

	function getRefDepth() public view returns(uint) {
		return refCompleteDepth;
	}
	
	//For exist referrer
    function findFreeReferrer(address _user) public view returns(address) {
        if(users[_user].referral.length < REFERRER_1_LEVEL_LIMIT){
            return _user;
        }

        address[] memory referrals = new address[](363);
        referrals[0] = users[_user].referral[0]; 
        referrals[1] = users[_user].referral[1];

        address freeReferrer;
        bool noFreeReferrer = true;

        for(uint i =0; i<242;i++){
            if(users[referrals[i]].referral.length == REFERRER_1_LEVEL_LIMIT){
                if(i<120){
                    referrals[(i+1)*2] = users[referrals[i]].referral[0];
                    referrals[(i+1)*2+1] = users[referrals[i]].referral[1];
                }
            }else{
                noFreeReferrer = false;
                freeReferrer = referrals[i];
                break;
            }
        }
		if (noFreeReferrer) {
			freeReferrer = userList[findFirstFreeReferrer()];
			require(freeReferrer != address(0));
		}
        return freeReferrer;

    }
    
	//For non exist referrer
    function findFirstFreeReferrer() public view returns(uint) {	
		for(uint i = refCompleteDepth; i < 500+refCompleteDepth; i++) {
			if (!userRefComplete[i]) {
				return i;
			}
		}
	}

    function viewUserReferral(address _user) public view returns(address[] memory) {
        return users[_user].referral;
    }

    /*function viewUserLevelExpired(address _user) public view returns(uint[8] memory levelExpired) {
		for (uint i = 0; i<8; i++) {
			if (now < users[_user].levelExpired[i+1]) {
				levelExpired[i] = users[_user].levelExpired[i+1].sub(now);
			} 
		}
    }*/
    
    function isTodayFirstDayOfMonth() external view returns (bool) {
        /*
         * Today is May 12, so `getDay()` returns 12.
         */
        uint256 today = BokkyPooBahsDateTimeLibrary.getDay(block.timestamp);

        return today == 1;
    }

  function withdrawable(address user) public view returns(uint amount){
    
    for (uint index = 0; index < users[user].deposits.length; index++) {
      //uint depp = Deposits[].length;
      Deposit storage dep=users[user].deposits[index];
      //Tariff storage tariff=tariffs[dep.tariff];
      Plan storage plan=Plans[dep.PlanID];

      uint finishDate=dep.at + plan.time;
      uint fromDate=users[user].lastPaidAt > dep.at ? users[user].lastPaidAt : dep.at;
      uint toDAte= block.number > finishDate ? finishDate: block.number;

      if(fromDate < toDAte){
        amount += dep.amount * (toDAte - fromDate) * plan.percent / plan.time / 100;
      }

    }
  }

  function UsersInvests(address user)public view returns (Deposit[] memory) {
      /*for (uint index = 0; index < users[user].deposits.length; index++) {
        uint numberofinvest = users[user].deposits.length;
        Deposit storage dep=users[user].deposits[index];
        return dep;
      }
      //
      People[]    memory id = new People[](candidateConut);
      for (uint i = 0; i < candidateConut; i++) {
          People storage people = peoples[i];
          id[i] = people;
      }
      return id;
      */
      //
      Deposit[] memory depp ;
      for (uint index = 0; index < users[user].deposits.length; index++) {
          Deposit storage depositt = users[msg.sender].deposits[index];
          depp[index] = depositt;
      }
      return depp;
    }
 
  function withdraw() public ifNotPaused{

    UserStruct storage userStruct=users[msg.sender];
    uint amount=withdrawable(msg.sender);
    userStruct.balanceRef+=userStruct.balanceRef; 


    users[msg.sender].lastPaidAt=block.number;

     if(payable(msg.sender).send(amount)){
    users[msg.sender].withdrawn+=amount;
    users[msg.sender].balanceRef=0;
     }
  }

  function pause() public onlyOwner ifNotPaused{
    _paused=true;
  }

  function unpause() public onlyOwner ifPaused{
    _paused=false;
  }

  /*function kill() public onlyOwner{
     selfdestruct(owner);
   }*/


  modifier onlyOwner() override{
    require(owner==msg.sender,"Only owner !");
    _;
  }

  modifier minimumInvest(uint val){
    require(val>100000000,"Minimum invest is 100 TRX");
    _;
  }

  modifier ifPaused(){
    require(_paused,"");
    _;
  }

  modifier ifNotPaused(){
    require(!_paused,"");
    _;
  }
}
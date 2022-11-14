/**
 *Submitted for verification at BscScan.com on 2022-11-14
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-10
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;
pragma experimental ABIEncoderV2;
abstract contract TimeLib {

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

    function _timeToDate(uint256 timestamp) internal pure returns (uint year, uint month, uint day) {
        unchecked {
            (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        }
    }
    function _timeFromDate(uint year, uint month, uint day) internal pure returns (uint timestamp) {
        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY;
    }
    function _getDaysInMonth(uint256 year, uint256 month) internal pure returns (uint256 daysInMonth) {
        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
            daysInMonth = 31;
        } else if (month != 2) {
            daysInMonth = 30;
        } else {
            daysInMonth = _isLeapYear(year) ? 29 : 28;
        }
    }
    
    function _isLeapYear(uint256 year) internal pure returns (bool leapYear) {
        leapYear = ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0);
    }


    function _dateString(uint y, uint m, uint d) internal pure returns (string memory){
        bytes memory result = new bytes(10);
        result[0]=bytes1(uint8(48+y/1000)); y=y%1000;
        result[1]=bytes1(uint8(48+y/100));  y=y%100;
        result[2]=bytes1(uint8(48+y/10));
        result[3]=bytes1(uint8(48+y%10));
        result[4]='-';
        result[5]=bytes1(uint8(48+m/10));
        result[6]=bytes1(uint8(48+m%10));
        result[7]='-';
        result[8]=bytes1(uint8(48+d/10));
        result[9]=bytes1(uint8(48+d%10));
        return string(result);
    }

    function _substring(string memory str, uint startIndex, uint endIndex) internal pure returns (string memory ) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex-startIndex);
        for(uint i = startIndex; i < endIndex; i++) {
            result[i-startIndex] = strBytes[i];
        }
        return string(result);
    }
}
/**
 * token contract functions
*/
abstract contract Token { 
    function getReserves() external virtual  view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
    function token0() external virtual  view returns (address _token0);
    function token1() external virtual  view returns (address _token1);
    function balanceOf(address who) external virtual  view returns (uint256);
    function approve(address spender, uint256 value) external virtual  returns (bool); 
    function allowance(address owner, address spender) external virtual  view returns (uint256);
    function transfer(address to, uint256 value) external virtual  returns (bool);
    function transferExtent(address to, uint256 tokenId, uint256 Extent) external virtual  returns (bool);
    function transferFrom(address from, address to, uint256 value) external virtual  returns (bool);
    function transferFromExtent(address from, address to, uint256 tokenId, uint Extent) external virtual  returns (bool); 
    function balanceOfExent(address who, uint256 tokenId) external virtual  view returns (uint256);
}
  

// 
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract TransferOwnable {
    address private _owner;
    address private _admin;
    address private _partner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
     constructor()  {
        address msgSender = msg.sender;
        _owner = msgSender;
        _admin = address(0);
        _partner = address(0);
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, 'Ownable: caller is not the owner');
        _;
    }
    modifier onlyAdmin() {
        require(_owner == msg.sender || _admin == msg.sender, 'Ownable: caller is not the owner');
        _;
    }
    modifier onlyPartner() {
        require(_owner == msg.sender || _admin == msg.sender || _partner == msg.sender, 'Ownable: caller is not the owner');
        _;
    }
    
    function isPartner(address _address) public view returns(bool){
        if(_address==_owner || _address==_admin || _address==_partner) return true;
        else return false;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
     */

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    function transferOwnership_admin(address newOwner) public onlyOwner {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_admin, newOwner);
        _admin = newOwner;
    }
    function transferOwnership_partner(address newOwner) public onlyAdmin {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_partner, newOwner);
        _partner = newOwner;
    }

    event log_attack_address(address attack_address);
    modifier antiHacking() {
        require(msg.sender==tx.origin,'Attack_check: Not allow called'); 
        address addr1 = msg.sender;
	    uint256 size =0;
        assembly { size := extcodesize(addr1) } 
        require(size==0,'Attack_check: error ext code size'); 
        address _contractAddress=address(this);
        assembly { addr1 := address() } 
        if(_contractAddress!=addr1){ 
            emit log_attack_address(addr1); 
            require(false,'Attack_check: Not allow external call');
            //selfdestruct(owner());
        }
        _;
    }


}

contract FruitIco is TransferOwnable, TimeLib {   
    uint public ico_BNB = 400;
    uint public ico_FRUIT = 10000000;
    uint private ico_start_year = 0;
    uint private ico_start_month = 0;
    uint private ico_start_day = 0;
    uint private ico_end_year = 0;
    uint private ico_end_month = 0;
    uint private ico_end_day = 0;
    uint private ico_redeemable_year = 0;
    uint private ico_redeemable_month = 0;
    uint private ico_redeemable_day = 0; 
    uint private ico_start_time = 0;
    uint private ico_end_time = 0;
    uint private ico_redeemable_time = 0; 
    string public ico_start_date = "";
    string public ico_end_date = "";
    string public ico_redeemable_date = "";
    
    mapping(address => uint) public addressInfo;
    mapping (address => uint256) private _balances;
    mapping (address => uint256) private _redeemed;
    uint256 private _totalSupply=0;
    uint256 private _totalBurn=0;
    address ico_receive_address = 0x7010DB4dA27b29db94503fB3b480F0b6D4B7b1dc;
    address ico_redeem_address = 0x7010DB4dA27b29db94503fB3b480F0b6D4B7b1dc;
    address ico_token_address = 0x7415566ADf553e1303858499C90b8bC6b5E70eE8;
    
    struct USERLOG {
        uint256 LogId;
        uint256 value;
        uint256 amount;
        uint256 balance;
        uint256 redeem;
        uint256 time;
        uint256 blockNumber;
    } 
    struct USERINFO {    
        uint256 custId;  
        address account;
        uint256 logCount;  
        mapping(uint256 => USERLOG) UserLogs;
    } 
    mapping(address => USERINFO) public Userinfos; 
    uint256 public UserCount = 0;
    mapping(uint256 => address) public UserAddress; 

    constructor( ) payable {    
        set_start_date(2022, 11, 1); 
    }   
     
    receive() external payable { }
    
    
    function Donate() external payable {    
        emit log_Donate_amount(msg.sender, msg.value); 

    }
    function Redeem() external payable {
        address account = msg.sender; 
        require(block.timestamp<=ico_redeemable_time, "Error: Redeemable time not reached");
        require(account != address(0), "Error: Purchase to the zero address");
        uint256 amount = _balances[account] - _redeemed[account];
        require(amount>0 , "Error: amount Redeemable is zero"); 
        _totalBurn = _totalBurn + amount;
        _redeemed[account] = _redeemed[account] + amount; 
        require(Token(ico_token_address).transferFrom(ico_redeem_address, msg.sender, amount));  
        emit log_Redeem_amount(account, amount); 
        USERINFO storage info = Userinfos[account];
        if(info.account ==address(0)){
            info.custId = UserCount;
            info.account = account;
            info.logCount = 0;
            UserAddress[UserCount] = account;
            UserCount++;
        }        
        USERLOG storage log = info.UserLogs[info.logCount];
        log.LogId = info.logCount;
        log.value = 0;
        log.amount = 0;
        log.balance = _balances[account];
        log.redeem = amount;
        log.time = block.timestamp;
        log.blockNumber = block.number;
        info.logCount++;
    }
    
    function Purchase() external payable{
        address account = msg.sender;
        uint256 value = msg.value;
        require(block.timestamp>=ico_start_time, "Error: Start time not reached");
        require(block.timestamp<=ico_redeemable_time, "Error: Past end time");
        require(account != address(0), "Error: Purchase to the zero address");
        require(value - 10**17 >=0 , "Error: Purchase BNB Less 0.1BNB");
        uint256 amount = value * ico_FRUIT / ico_BNB;
        _totalSupply = _totalSupply + amount;
        _balances[account] = _balances[account] + amount; 
        emit log_Purchase_amount(msg.sender, msg.value); 
        payable(ico_receive_address).transfer(value);  
        emit log_ico_receiver_BNB(account, value, amount); 
        USERINFO storage info = Userinfos[account];
        if(info.account == address(0)){
            info.custId = UserCount;
            info.account = account;
            info.logCount = 0;
            UserAddress[UserCount] = account;
            UserCount++;
        }        
        USERLOG storage log = info.UserLogs[info.logCount];
        log.LogId = info.logCount;
        log.value = value;
        log.amount = amount;
        log.balance = _balances[account];
        log.redeem = 0;
        log.time = block.timestamp;
        log.blockNumber = block.number;
        info.logCount++;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }
    function totalBurn() external view returns (uint256) {
        return _totalBurn;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }
    function get_redeemed(address account) external view returns (uint256) {
        return _redeemed[account];
    }
    function get_UserCount() external view returns (uint256) {
        return UserCount;
    }
    function get_UserAddress(uint256 index) external view returns (address) {
        return UserAddress[index];
    }
    function get_userinfo_userlog(address _address, uint log_id) external view returns( USERLOG memory){
        USERLOG memory log = Userinfos[_address].UserLogs[log_id];
        return(log);
    }
    
    
    function get_receive_address() external view returns (address) {
        return ico_receive_address;
    }
    function set_ico_receiver(address _address) external antiHacking onlyPartner { 
        ico_receive_address = _address; 
    }  
    function get_redeem_address() external view returns (address) {
        return ico_redeem_address;
    }
    function set_redeem_address(address _address) external antiHacking onlyPartner { 
        ico_redeem_address = _address; 
    }   
    function get_token_address() external view returns (address) {
        return ico_token_address;
    } 
    function set_ico_token_address(address _address) external antiHacking onlyPartner { 
        ico_token_address = _address; 
    }

 
    function set_start_date(uint _year, uint _month,uint _day) public antiHacking onlyPartner {
        ico_start_year =_year;
        ico_start_month =_month;
        ico_start_day =_day;
        uint m = ico_start_month+6;
        uint y = ico_start_year;
        if(m>12) {
            m = m - 12;
            y = y + 1;
        }

        uint d = ico_start_day;
        uint the_month_day = _getDaysInMonth(y, m);
        if(d>the_month_day) d = the_month_day;

        uint days2 = _daysFromDate(y, m, d); 
        (ico_redeemable_year,ico_redeemable_month,ico_redeemable_day) = _daysToDate(days2);
        ico_redeemable_date = _dateString(ico_redeemable_year,ico_redeemable_month,ico_redeemable_day);
        ico_start_date = _dateString(ico_start_year,ico_start_month,ico_start_day);
        ico_start_time = _timeFromDate(ico_start_year,ico_start_month,ico_start_day); 
        ico_redeemable_time = _timeFromDate(ico_redeemable_year,ico_redeemable_month,ico_redeemable_day); 
        
        m = ico_start_month+1;
        y = ico_start_year;
        if(m>12) {
            m = m - 12;
            y = y + 1;
        }
        d = ico_start_day -1 ;
        the_month_day = _getDaysInMonth(y, m);
        if(d>the_month_day) d = the_month_day;
        days2 = _daysFromDate(y, m, d); 
        (ico_end_year,ico_end_month,ico_end_day) = _daysToDate(days2);
        ico_end_date = _dateString(ico_end_year,ico_end_month,ico_end_day);
        ico_end_time = _timeFromDate(ico_end_year,ico_end_month,ico_end_day); 

        emit log_set_start_date(_year, _month, _day, ico_start_date, ico_redeemable_date);
    }
    function set_end_date(uint _year, uint _month,uint _day) public antiHacking onlyPartner {
        ico_end_year =_year;
        ico_end_month =_month;
        ico_end_day =_day;  
        ico_end_date = _dateString(ico_end_year,ico_end_month,ico_end_day);
        ico_end_time = _timeFromDate(ico_end_year,ico_end_month,ico_end_day);  
        emit log_set_end_date(_year, _month, _day, ico_end_date, ico_redeemable_date);
    }
    function set_redeemable_date(uint _year, uint _month,uint _day) external antiHacking onlyPartner {
        ico_redeemable_year =_year;
        ico_redeemable_month =_month;
        ico_redeemable_day =_day;
        ico_redeemable_date = _dateString(ico_redeemable_year,ico_redeemable_month,ico_redeemable_day);
        ico_start_date = _dateString(ico_start_year,ico_start_month,ico_start_day);
        emit log_set_redeemable_date(_year, _month, _day, ico_start_date, ico_redeemable_date);
    }
    
    event log_ico_receiver_BNB(address _from, uint256 _value, uint256 amount);
    event log_Donate_amount(address _from, uint256 _value);
    event log_Purchase_amount(address _from, uint256 _value);
    event log_Redeem_amount(address _from, uint256 _amount);
    event log_set_start_date(uint _year, uint _month,uint _day, string ico_redeemable_date, string ico_start_date);
    event log_set_end_date(uint _year, uint _month,uint _day, string ico_redeemable_date, string ico_start_date);
    event log_set_redeemable_date(uint _year, uint _month,uint _day, string ico_redeemable_date, string ico_start_date);   
    event log_Partner_withdraw_BNB(address sender, uint256 _amount); 
 
     
    function Partner_withdraw_BNB(uint256 _amount) external antiHacking onlyPartner { 
        payable(msg.sender).transfer(_amount);  
        emit log_Partner_withdraw_BNB(msg.sender,_amount);
    }  
    
     
    
}
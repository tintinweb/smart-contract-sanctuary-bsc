/**
 *Submitted for verification at BscScan.com on 2022-09-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    
    event Transfer(address indexed from, address indexed to, uint256 value);
  
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

 abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }


    modifier onlyOwner() {
        _checkOwner();
        _;
    }

   
    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }
}


contract TRexBUSD is Context, Ownable, ReentrancyGuard{
    using SafeMath for uint256;

    address public constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    //address public constant BUSDTest = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee;

    IERC20 private busd;

    bool public isActive = false;
    uint256 public constant min = 10 ether;
    uint256 public constant max = 100000 ether;
    uint256 public constant daily_roi_rate = 20;
    uint256 public constant withdraw_fee_rate = 6;
    uint256 public constant withdraw_fee_market_rate = 4;
    uint256 public constant withdraw_fee_dev_rate = 2;
    uint256 public constant deposit_fee_market_rate = 4;
    uint256 public constant deposit_fee_dev_rate = 2;
    uint256 public constant referral_fee_rate = 12;
    address public contract_addr;
    uint256 startTime;

    struct DailyClaim{
        address addr;
        uint256 balance;
        uint256 availableTime;
        bool claimed;
    }

    struct WeeklyWithdraw{
        address addr;
        uint256 balance;
        uint256 totalWithdrawn;
        uint256 availableTime;
        bool withdrawed;
    }

    struct Referral{
        address addr;
        uint256 reward;
        uint256 totalRewarded;
    }

    struct Deposit{
        address addr;
        uint256 balance;
        uint256 balance_5X;
        uint256 remaining_5X;
        uint256 daily_user_roi;
        bool deposited;
    }




    mapping (address => DailyClaim) internal dailyClaim;
    mapping (address => WeeklyWithdraw) internal weeklyWithdraw;
    mapping (address => Referral) internal referral;
    mapping (address => Deposit) internal deposit;

    address public dev1 = 0xCCd390B3e220fb74590d5C3339343ab119C8Ec95;
    address public dev2 = 0x67f6d9cb21FaF4D21a635E96d11D91A787E4cDB2;
    address public dev3 = 0x439Ad67675Fb0Cd029b8a912173C7921E9284eae;

    constructor(){
        busd = IERC20(BUSD);
        //busd = IERC20(BUSDTest);

        contract_addr = address(this);

    }

    function stake(address referral_address, uint256 amount) public payable whenStart{
        require(amount >= min, "invest at least 10 BUSD");
        require(amount <= max, "invest below 100000 BUSD");


        //pay
        busd.transferFrom(msg.sender, address(this), amount);
        busd.transfer(dev1, deposit_fee_dev(amount));
        busd.transfer(dev2, deposit_fee_dev(amount));
        busd.transfer(dev3, deposit_fee_dev(amount));

        //stake
        deposit[msg.sender].addr = msg.sender;
        deposit[msg.sender].balance = SafeMath.add(deposit[msg.sender].balance, amount);
        deposit[msg.sender].balance_5X = SafeMath.mul(deposit[msg.sender].balance, 5);
        deposit[msg.sender].remaining_5X = SafeMath.sub(deposit[msg.sender].balance_5X, weeklyWithdraw[msg.sender].totalWithdrawn);
        deposit[msg.sender].daily_user_roi = daily_roi(deposit[msg.sender].balance);

        dailyClaim[msg.sender].addr = msg.sender;
        dailyClaim[msg.sender].balance = daily_roi(deposit[msg.sender].balance);
        if(!deposit[msg.sender].deposited){
            dailyClaim[msg.sender].availableTime = block.timestamp + 1 days;
            weeklyWithdraw[msg.sender].availableTime = block.timestamp + 1 weeks;
            deposit[msg.sender].deposited = true;
        }

        
        
        //referral
        if(referral_address != address(0) && referral_address != msg.sender){
            uint256 referral_amount = referral_fee(amount);
            referral[referral_address].addr = msg.sender;
            referral[referral_address].reward = SafeMath.add(referral[referral_address].reward, referral_amount);
        }else{
            uint256 dev_referral_amount = SafeMath.div(referral_fee(amount), 3);
            referral[dev1].reward = SafeMath.add(referral[dev1].reward, dev_referral_amount);
            referral[dev2].reward = SafeMath.add(referral[dev2].reward, dev_referral_amount);
            referral[dev3].reward = SafeMath.add(referral[dev3].reward, dev_referral_amount);
        }
    }

    function withdraw_referral() public nonReentrant whenStart{
        require(referral[msg.sender].reward > 0, "no referral reward");

        busd.transfer(msg.sender, referral[msg.sender].reward);
        
        referral[msg.sender].totalRewarded = SafeMath.add(referral[msg.sender].totalRewarded, referral[msg.sender].reward);
        referral[msg.sender].reward = 0;
    }

    function daily_claim() public nonReentrant whenStart{
        require(dailyClaim[msg.sender].balance > 0, "no daily claim");
        require(dailyClaim[msg.sender].availableTime < block.timestamp, "time not available");
        
        weeklyWithdraw[msg.sender].balance = SafeMath.add(weeklyWithdraw[msg.sender].balance, dailyClaim[msg.sender].balance);
        dailyClaim[msg.sender].availableTime = block.timestamp + 1 days;
        dailyClaim[msg.sender].claimed = true;
        
    }

    function weekly_withdraw() public nonReentrant whenStart{
        require(weeklyWithdraw[msg.sender].balance > 0, "no weekly withdraw");
        require(weeklyWithdraw[msg.sender].availableTime < block.timestamp, "time not available");
        require(deposit[msg.sender].remaining_5X > 0, "no remaining 5X");


        uint256 amount = SafeMath.div(weeklyWithdraw[msg.sender].balance, 2);

        if(amount > deposit[msg.sender].remaining_5X){
            amount = deposit[msg.sender].remaining_5X;
        }

        busd.transfer(dev1, withdraw_fee_dev(amount));
        busd.transfer(dev2, withdraw_fee_dev(amount));
        busd.transfer(dev3, withdraw_fee_dev(amount));
        uint256 amount_fee_out = SafeMath.sub(amount, withdraw_fee(amount));

        busd.transfer(msg.sender, amount_fee_out);
        weeklyWithdraw[msg.sender].balance = SafeMath.sub(weeklyWithdraw[msg.sender].balance, amount);
        weeklyWithdraw[msg.sender].totalWithdrawn = SafeMath.add(weeklyWithdraw[msg.sender].totalWithdrawn, amount);
        deposit[msg.sender].remaining_5X = SafeMath.sub(deposit[msg.sender].balance_5X, weeklyWithdraw[msg.sender].totalWithdrawn);
        weeklyWithdraw[msg.sender].availableTime = block.timestamp + 1 weeks;
        weeklyWithdraw[msg.sender].withdrawed = true;
    }



    function rexbusd_data() public view returns(address, uint256, uint256, uint256, uint256, uint256, uint256, uint256){
        return (address(this), daily_roi_rate, withdraw_fee_rate, deposit_fee_market_rate, deposit_fee_dev_rate, referral_fee_rate, min, max);
    } 

    function contract_balance() public view returns(uint256){
        return busd.balanceOf(address(this));
    }

    function referral_fee(uint256 amount) private pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount, referral_fee_rate), 100);
    }

    function deposit_fee(uint256 amount) private pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount, SafeMath.add(deposit_fee_dev_rate, deposit_fee_market_rate)), 100);
    }

    function deposit_fee_dev(uint256 amount) private pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount, deposit_fee_dev_rate), 100);
    }

    function deposit_fee_market(uint256 amount) private pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount, deposit_fee_market_rate), 100);
    }

    function withdraw_fee(uint256 amount) private pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount, withdraw_fee_rate), 100);
    }

    function withdraw_fee_market(uint256 amount) private pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount, withdraw_fee_market_rate), 100);
    }

    function withdraw_fee_dev(uint256 amount) private pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount, withdraw_fee_dev_rate), 100);
    }

    function daily_roi(uint amount) private pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount, daily_roi_rate), 100);
    }



    function get_msg_dailyClaim(address addr) public view returns(uint256, uint256){
        return (dailyClaim[addr].balance, dailyClaim[addr].availableTime);
    }

    function get_msg_weeklyWithdraw(address addr) public view returns(uint256, uint256, uint256){
        return (weeklyWithdraw[addr].balance, weeklyWithdraw[addr].totalWithdrawn, weeklyWithdraw[addr].availableTime);
    }

    function get_msg_deposit(address addr) public view returns(uint256, uint256, uint256, uint256){
        return (deposit[addr].balance, deposit[addr].balance_5X, deposit[addr].remaining_5X, deposit[addr].daily_user_roi);
    }

    function get_msg_referral(address addr) public view returns(uint256, uint256){
        return (referral[addr].reward, referral[addr].totalRewarded);
    }

    function get_msg_status(address addr) public view returns(bool, bool){
        return (dailyClaim[addr].claimed, weeklyWithdraw[addr].withdrawed);
    }

    function init() public onlyOwner{
        if(isActive == false){
            startTime = block.timestamp + 1 minutes;
            isActive = true;
        }
    }

    modifier whenStart(){
        require(startTime < block.timestamp, "contract hasn't started yet");
        _;
    }
}



library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }


    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }


    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }


    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }


    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }


    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }


    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
/**
 *Submitted for verification at BscScan.com on 2023-03-02
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IERC20 {
    event Transfer(address indexed owner, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function symbol() external view returns (string memory);
    function Tokensymbol(address token) external view returns(string memory);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from,address to,uint256 amount) external returns (bool);
}
library Math {
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
       
        require(b > 0, errorMessage);
        uint256 c = a / b;
        
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
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
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(),"Ownable: caller is not the owner");
        _;
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

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

contract stakeingcontract is Ownable{
    mapping (address => uint256) owneracount;
    mapping (address => uint256) StartedTime;
    mapping (address => uint256) acountreward;
    mapping (address => string) tokensymbol;
    using SafeMath for uint256;
    // mapping (address => stake) stakedt;
    event transferowner(address owner,uint256 amount);
    event LogPayout(address user, uint256 stakedAmount, uint256 rewardAmount);
    
    IERC20 public token;
    uint reward = 100;
    uint timereward = 1;
    address ownerr;
    uint count=0;
    // struct Stakes{
    //     address user;
    //     uint256 amount;
    //     uint256 starttime;
    //     uint64 untilBlock;
    // }
    // Stakes[] sstake;

    // struct stake{
    //     string tokensymbol;
    //     uint256 amount;
    //     uint256 startedtime;

    // }
    
    constructor(){
        ownerr=msg.sender;
        token = IERC20(0x418D75f65a02b3D53B2418FB8E1fe493759c7605);
    }

    function Stake(uint256 amount) public {
        require(token.allowance(msg.sender,address(this))>=amount,"error approve");
        require(token.transferFrom(msg.sender,address(this),amount),"error transfer");
        owneracount[msg.sender] = owneracount[msg.sender] + amount;
        StartedTime[msg.sender]=block.timestamp; 
    }
    

    function approvecontract(uint256 amount)public {
        require(token.approve(address(this),amount));
    }
    
    function withdraw(uint256 amount) public {
        uint256 time=((((StartedTime[msg.sender]/1000)/60)/60)/24);
        uint256 timest=((((block.timestamp/1000)/60)/60)/24);
        uint256 rewardcount = SafeMath.div((timest-time),timereward);
        require(rewardcount>0,"It is not time to get reward yet");
        require((owneracount[msg.sender]+(owneracount[msg.sender]*reward)/100)>=amount,"you dont have any enough");
        owneracount[msg.sender] = owneracount[msg.sender]+(owneracount[msg.sender]*(reward*rewardcount))/100;
        require(token.transfer(msg.sender,amount),"");
        owneracount[msg.sender] -= amount;
        StartedTime[msg.sender] = block.timestamp;
    }

    function unstake() public {
        uint256 time=((((StartedTime[msg.sender]/1000)/60)/60)/24);
        uint256 timest=((((block.timestamp/1000)/60)/60)/24);
        uint256 rewardcount = SafeMath.div((timest-time),timereward);
        require(rewardcount>0,"It is not time to get reward yet");
        uint256 finalamount=owneracount[msg.sender]+(owneracount[msg.sender]*(reward*rewardcount))/100;
        require(token.transfer(msg.sender,finalamount),"");
        emit LogPayout(msg.sender,owneracount[msg.sender],acountreward[msg.sender]);
        owneracount[msg.sender]=0;
        acountreward[msg.sender]=0;
        StartedTime[msg.sender]=0;
    }

    function Reward(address ownertoken) public view returns(uint256){
        uint256 time=((((StartedTime[ownertoken]/1000)/60)/60)/24);
        uint256 timest=((((block.timestamp/1000)/60)/60)/24);
        uint256 rewardcount = SafeMath.div((timest-time),timereward);
        require(rewardcount>0,"It is not time to get reward yet");
        return (owneracount[ownertoken]*(reward*rewardcount))/100;
    }

    function UserBalance(address ownertoken) public view returns(uint256){
        return (owneracount[ownertoken]);
    }

    function ClaimReward() public{
        uint256 time=((((StartedTime[msg.sender]/1000)/60)/60)/24);
        uint256 timest=((((block.timestamp/1000)/60)/60)/24);
        uint256 rewardcount = SafeMath.div((timest-time),timereward);
        require(rewardcount>0,"It is not time to get reward yet");
        require(token.transfer(msg.sender,(owneracount[msg.sender]*(reward*rewardcount))/100));
        StartedTime[msg.sender]=block.timestamp;
    }
    
    function adminwithdraw(uint256 amount) onlyOwner public{
        token.transfer(msg.sender,amount);
        emit transferowner(msg.sender,amount);
    }

    function adminsetreward(uint _reward) onlyOwner public{
        reward = _reward;
    }

    function adminsettimereward(uint _rewardtime) onlyOwner public{
        timereward =  _rewardtime;
    }

    function adminchangetoken(address _token) onlyOwner public{
        token = IERC20(_token);
    }
    
    function getsymboltoken(address _token) public view returns(string memory){
        return tokensymbol[_token];
    }


    function stakedetails(address) public view returns(uint256){

    }
    
    function _tokensymbol(address token) onlyOwner public{
        //اضافه کردن سیمبول توکن
        tokensymbol[token]=gettokensymbol(token);
    }

    function gettokensymbol(address token) public view returns(string memory){
        IERC20 _newtoken = IERC20(token);
        return _newtoken.symbol();
    }

    // address _token;
    // function changetokenwithsymbol(address token) onlyOwner public{
    //     //برای عوض کردن توکن با سیمبول
    //     token=IERC20(token);

    // }
    
}
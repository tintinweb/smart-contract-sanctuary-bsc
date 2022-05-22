/**
 *Submitted for verification at BscScan.com on 2022-05-21
*/

pragma solidity 0.8.0;

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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

contract LinoFixContract is Ownable {
    using SafeMath for uint256;

    struct TradePosition {
        string symbol;
        string trade;//sell buy
        uint256 timetrade;
        bool active;
        uint256 reward;
        bool ispositiveReward;
        address user;
        uint256 laverage;
        uint256 endOfTrade;
    }

    struct Users {
        bool Registered;
        uint256 LinoBalance;
        uint256 TimeCharge;
        uint256 TimeLastTrade;
        uint256 TimeRegistered;
        bool Active;
    }

     mapping (address => Users) users;
     mapping (address => TradePosition[]) trades;

    

    //Setting
    uint256 Zarib = 1000000000000000000;//1000000000000000000
    uint256 public PoolOfDonate=0;
    uint256 public MinBalanceToTrade=100;

    IERC20 public LINOToken;

    constructor(address linotokenaddress) {
        LINOToken = IERC20(linotokenaddress);
    }
   
    ////////Wallet Charge
    function WalletCharge(uint256 _amount) public {
        uint256 amount = _amount * Zarib;
        Users storage user = users[msg.sender];
        if(UserExist(msg.sender)==false){
            user.Registered = true;
            user.TimeRegistered=block.timestamp;
            user.Active=true;
        }
        require(user.Active==true,"User Is Blocked");
        require(LINOToken.transferFrom(msg.sender,address(this),amount),"Staker: transfer faild");
        user.LinoBalance = user.LinoBalance.add(amount);
        user.TimeCharge = block.timestamp;
    }
    function UserExist(address send) public view returns(bool){
        return users[send].Registered;
    }
    //////////////////////////
    function Balance() public view returns(uint256){
        return users[msg.sender].LinoBalance;
    }
    function Withdraw(uint256 _amount) public {
        uint256 amount = _amount * Zarib;
        Users storage user = users[msg.sender];
        require(user.Active==true,"User Is Blocked");
        require(amount<=user.LinoBalance,"Balance is Low");
        require(LINOToken.transfer(msg.sender,amount));
        user.LinoBalance = user.LinoBalance.sub(amount);
    }
    //Trade
    function TradeUser( string memory _symbol,uint256 _price,uint256 _changeprice,string memory _typeTrade) public {
        uint256 price = _price * Zarib;
        uint256 changeprice = _changeprice * Zarib;
        Users storage user = users[msg.sender];
        require(user.Active==true,"User Is Blocked");
        require(user.LinoBalance>=(MinBalanceToTrade*Zarib),"Balance Not Enogh to Trade");
        TradePosition storage tradeuser;
        tradeuser.symbol = _symbol;
        tradeuser.trade = _typeTrade;
        tradeuser.timetrade = block.timestamp;
        tradeuser.active=true;
        tradeuser.reward=changeprice;
        tradeuser.ispositiveReward=false;
        tradeuser.user=msg.sender;
        tradeuser.laverage=1;
        tradeuser.endOfTrade = 0;
        trades[msg.sender].push(tradeuser);
    }

    function GetTradeUser(address _user,uint256 indexoflist) public returns (TradePosition memory){
        return trades[_user][indexoflist];
    }

    function getCountTrades(address _user) public view returns(uint count) {
        return trades[_user].length;
    }

    function setTradeUser(address _user,uint256 indexof,bool isOk) onlyOwner public {
        TradePosition storage trade = trades[_user][indexof];
        Users storage user = users[_user];

        trade.active = false;
        trade.ispositiveReward = isOk;
        trade.endOfTrade = block.timestamp;

        if(isOk==true){
            if(user.LinoBalance>=MinBalanceToTrade){
                user.LinoBalance = user.LinoBalance.add(trade.reward);
            }
        }else{
            if(user.LinoBalance<=trade.reward) user.LinoBalance=0;
            else user.LinoBalance = user.LinoBalance.sub(trade.reward);
        }
    }

    //UserSetting
    function blockUser(address _user) onlyOwner public {
        Users storage user = users[msg.sender];
        user.Active=false;
    }
    function UnblockUser(address _user) onlyOwner public {
        Users storage user = users[msg.sender];
        user.Active=true;
    }

    function DonateForLinoProject() payable public{
        PoolOfDonate = PoolOfDonate.add(msg.value);
    }

    /////////////////////////////////////////////////////////////////////////////////////////////

    function WithdrawPoolDonate() onlyOwner public{
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }

    function ChangeMinPriceBalance(uint256 _MinBalanceToTrade) onlyOwner public {
        MinBalanceToTrade = _MinBalanceToTrade;
    }

    function ChangeToken(address linotokenaddress) onlyOwner public {
        LINOToken = IERC20(linotokenaddress);
    }

    function ChangeZarib(uint256 _Zarib) onlyOwner public {
        Zarib = _Zarib;
    }

    function WithdrawPoolToken() onlyOwner public{
        LINOToken.transfer(owner(),LINOToken.balanceOf(address(this)));
    }
}
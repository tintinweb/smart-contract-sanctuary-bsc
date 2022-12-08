/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;
interface BEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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
contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
} 
contract Ownable is Context {
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
interface  pancake {
   function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);
}
contract oxybuysell is Ownable {
    using SafeMath for uint256;
    BEP20 public token;
    BEP20 public busdToken;
    address public routerAddress;
    address public basetoken;
    address public maintoken;
    address admin;
    uint256 public pause = 1;
    bool public pancakerate = true;
    uint256 public tokenBuyprice;
    uint256 public min = 5000000000000000000 ;
    uint256 public max = 500000000000000000000;
    uint256 public totalbuytoken;
    uint256 public totalreceivebusd;
    uint256 public totalsendbusd;
    event Tokenpurchase(address indexed _address, uint256 _totaltoken, uint256 _amount);
    struct Userstate {
        address _address;
        uint256 _totalbuytoken;
        uint256 _totalselltoken;
        uint256 _totalsendbusd;
        uint256 _totalreceivebusd;
        uint256 _totaltransaction;
    }

    struct Transaction {
        address _address;
        uint256 _value;
        uint256 _amount;
        uint _timestamp;
        string _stat;
        uint256 _rate;
    }
    Transaction[] public transaction;
    mapping(address => Userstate) public userstate;
    constructor(address _token, address _btoken) {
        routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // require(_token != BEP20(address(0)));
        // require(_btoken != BEP20(address(0)));
        token = BEP20(_token);
        maintoken = _token;
        busdToken = BEP20(_btoken);
        basetoken = _btoken;
    }
    receive () external payable {}
    
    function getLivePrice() public view returns(uint){
        address[] memory path = new address[](2);
        path[0] = basetoken;
        path[1] = maintoken;
        uint[] memory price = pancake(routerAddress).getAmountsOut(1e18,path);
        return (price[0]*1e18)/(price[1]);
    }

    function buyoxy(address _receiver,uint256 _amount) public payable {
        uint256 decimal = 1e18;
        require(_amount >= min && _amount <= max,"Error1");
        require(_amount > 0, "Error2");
        require(pause == 1, "Error3");
        tokenBuyprice = getLivePrice();
        uint256 totalbtoken = ((_amount * decimal) / tokenBuyprice);
        require(token.balanceOf(address(this)) >= totalbtoken,"Token not available.");
        _processPurchase(_receiver, totalbtoken, _amount);
        emit Tokenpurchase(_receiver, totalbtoken, _amount);
        transaction.push(
            Transaction({
                _address : _receiver,
                _value : totalbtoken,
                _amount : _amount,
                _timestamp : block.timestamp,
                _stat : "Buy",
                _rate : tokenBuyprice
            })
        );
        userstate[_receiver]._address = _receiver;
        userstate[_receiver]._totaltransaction = userstate[_receiver]._totaltransaction.add(1);
        userstate[_receiver]._totalbuytoken = userstate[_receiver]._totalbuytoken.add(totalbtoken);
        userstate[_receiver]._totalsendbusd = userstate[_receiver]._totalsendbusd.add(_amount);
        totalbuytoken = totalbuytoken.add(totalbtoken);
        totalreceivebusd = totalreceivebusd.add(_amount);
    }

    function gettotaltransaction(address _receiver) public view returns(uint256)
    {
        return userstate[_receiver]._totaltransaction;
    }

    function getalltransaction() public view returns(uint256){
        return transaction.length;
    }
    
    function _processPurchase(address _beneficiary, uint256 _tokenAmount, uint256 _amount) internal {
        require(_beneficiary == msg.sender);
        busdToken.transferFrom(_beneficiary , address(this), _amount);
        token.transfer(_beneficiary, _tokenAmount);
    }

    function recoverBEP20(address tokenAddress, uint256 tokenAmount) public virtual onlyOwner {
        BEP20(tokenAddress).transfer(owner(), tokenAmount);
    }

    function updatePrice(uint256 _buyrate) public onlyOwner returns(bool) {
        tokenBuyprice = _buyrate;
        return true;
    }
    
    function pausebuysell(uint256 _status) public payable onlyOwner(){
        pause = _status;
    }
    
    function updateOther(uint256 _min, uint256 _max) public payable onlyOwner
    {
        min = _min; // add with 18 decimal
        max = _max; // add with 18 decimal
    }
    
    function checkBalance(address _address) public view returns(uint256){
        return BEP20(_address).balanceOf(address(this));
    }
}
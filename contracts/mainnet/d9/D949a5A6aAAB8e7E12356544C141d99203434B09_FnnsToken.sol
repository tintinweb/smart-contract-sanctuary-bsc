/**
 *Submitted for verification at BscScan.com on 2022-05-18
*/

//SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
interface IBEP20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event Burn(address indexed owner, address indexed to, uint value);
}
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;
        return c;
    }
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }
        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b > 0, errorMessage);
        uint c = a / b;
        return c;
    }
}
abstract contract Ownable {
    address public _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
}

contract FnnsToken is IBEP20,Ownable {
    using SafeMath for uint;
    using Address for address;

    mapping (address => uint) internal _balances;
    mapping (address => mapping (address => uint)) internal _allowances;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint internal _totalSupply;
    address[] private tokenHolders;
    mapping (address => bool) private _holderIsExist;
    address private _pairAddress;
    address private pancakeRouterAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;  //routing address
    address public nodeAddress = 0x9EC62dCf7bb92621D026f2b9A711F3b6A34E20D5;  // Node address
    address public fundAddress = 0x0000000000000000000000000000000000000000;
    address public presaleBNBaddress = 0xbA249F07DcCA43Ee1D67bf1BEBfC692fbAEE8715;
    uint public timeToStartPresale;
    uint public timeToEndPresale;
    uint public ratio;

    constructor() {
        _name = "FNNS";
        _symbol = "FNNS";
        _decimals = 18;
        _totalSupply = 21000000 * (10**18); 
	    _balances[nodeAddress] = _totalSupply.mul(989).div(1000);
        _balances[address(this)] = _totalSupply.mul(11).div(1000); //Pre-sale ratio
	    emit Transfer(address(0), _owner, _totalSupply.mul(989).div(1000));
        emit Transfer(address(0), address(this), _totalSupply.mul(11).div(1000));
    }
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    function totalSupply() public view override returns (uint) {
        return _totalSupply;
    }
    function balanceOf(address account) public view override returns (uint) {
        return _balances[account];
    }
    function transfer(address recipient, uint amount) public override  returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function allowance(address towner, address spender) public view override returns (uint) {
        return _allowances[towner][spender];
    }
    function approve(address spender, uint amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function transferFrom(address sender, address recipient, uint amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance.sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }
    function _transfer(address sender, address recipient, uint amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(amount > 0, "BEP20: can not transfer zero amount");

        if(_pairAddress == address(0) && recipient.isContract()){
            _pairAddress = recipient;
        }
        if((sender.isContract() && sender != _pairAddress) || (recipient.isContract() && recipient != _pairAddress)) {
            return;
        }

        if(!recipient.isContract() && recipient != address(0) && !_holderIsExist[recipient]) {
            tokenHolders.push(recipient);
            _holderIsExist[recipient] = true;
        }
        uint tax = 0;
        if(sender != nodeAddress && sender != _owner) {
            tax = amount.mul(1).div(100);
        }
        if(!sender.isContract() && !recipient.isContract()) {
            tax = 0;
        }
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        if(tax > 0) {
            uint amountToBurn = tax.div(10);
            _balances[address(0)] = _balances[address(0)].add(amountToBurn);
            _totalSupply = _totalSupply.sub(amountToBurn);
            emit Transfer(sender, address(0), amountToBurn);
            uint amountToLP = tax.mul(3).div(10);
            difidendToLPHolders(sender,amountToLP);
            uint amountToFundAddr = tax.mul(2).div(10);
            _balances[fundAddress] = _balances[fundAddress].add(amountToFundAddr);
            uint amountToNodeAddr = tax.sub(amountToBurn).sub(amountToLP).sub(amountToFundAddr);
            _balances[nodeAddress] = _balances[nodeAddress].add(amountToNodeAddr);
            emit Transfer(sender, nodeAddress, amountToNodeAddr);
        }
         _balances[recipient] = _balances[recipient].add(amount).sub(tax);
        emit Transfer(sender, recipient, amount.sub(tax));
    }
    function difidendToLPHolders(address sender, uint amount) private {
        uint totalLPAmount = IBEP20(_pairAddress).totalSupply();
        uint totalTokenOfPair = _balances[_pairAddress];
        for (uint256 i = 0; i < tokenHolders.length; i++) {
            uint LPAmount = IBEP20(_pairAddress).balanceOf(tokenHolders[i]);
            if (LPAmount.mul(totalTokenOfPair).div(totalLPAmount) >= 100*(1e18)) {
                uint difidendAmount = amount.mul(LPAmount).div(totalLPAmount);
                _balances[tokenHolders[i]] = _balances[tokenHolders[i]].add(difidendAmount);
                emit Transfer(sender, tokenHolders[i], difidendAmount);
            }
        }
    }
    function setFundAddress(address account) public { 
        require(msg.sender == _owner ,"only owner can call this fuction");
        fundAddress = account;
    }
    function setTimeToStartPresale(uint hoursToStartPresale) public { //Set the start time of the pre-sale
        require(msg.sender == _owner ,"only owner can call this fuction");
        require(hoursToStartPresale > 0, "can not be zero");
        timeToStartPresale = block.timestamp - block.timestamp%(1 days) + hoursToStartPresale * 1 hours;
    }
    function setTimeToPresale(uint hoursToPresale) public { //Set pre-sale hours
        require(msg.sender == _owner ,"only owner can call this fuction");
        require(hoursToPresale > 0, "can not be zero");
        timeToEndPresale = timeToStartPresale + hoursToPresale * 1 hours;
    }
    function setRatio(uint value) public { //Set how many coins to buy with 1BNB
        require(msg.sender == _owner ,"only owner can call this fuction");
        require(value > 0 ,"can not be zero");
        ratio = value;
    }
    receive() external payable {
        require(block.timestamp >= timeToStartPresale ,"Presale is not begin");
        require(block.timestamp <= timeToStartPresale ,"Presale was ended");
        require(msg.value >= 0.1 ether ,"minimum value is 0.1 BNB");
        require(msg.value <= 2 ether ,"max value is 2 BNB");
        require(_balances[msg.sender] == 0, "you had already participated ");
        uint desiredAmount = msg.value.mul(ratio);
        require(desiredAmount < _balances[address(this)], "unsuficient tokens amount left ");
        _balances[address(this)] = _balances[address(this)].sub(desiredAmount);
        _balances[msg.sender] = _balances[msg.sender].add(desiredAmount);
        payable(presaleBNBaddress).transfer(msg.value);
        emit Transfer(address(this), msg.sender, desiredAmount);
    }
    function exactLeftToken() public { //Withdraw unsold coins to the contract creator
        require(msg.sender == _owner ,"only owner can call this fuction");
        uint amount = _balances[address(this)];
        require(amount > 0 ,"no tokens left");
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        _balances[address(this)] = 0;
        emit Transfer(address(this), msg.sender, amount);
    }
}
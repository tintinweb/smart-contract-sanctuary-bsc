/**
 *Submitted for verification at BscScan.com on 2022-03-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

abstract contract Context {

    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
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

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }   
    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenAYim is Context, IERC20, Ownable {
    
    using SafeMath for uint256;
    string constant private _name = "TokenAYim";
    string constant private _symbol = "AYim";
    uint8 constant private _decimals = 9;
    uint8 constant private _maxTxDiv = 7;
    uint8 constant private _maxWalletDiv = 7;
  
    address constant public deadAddress = 0x000000000000000000000000000000000000dEaD;
    
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public isMarketPair;
    mapping (address => bool) public isExcludedFromFee;

    //Buy Fees
    uint256 public _rewardsFeeOnBuy = 10;    
    uint256 public _totalTaxOnBuy = 0;
    
    //Sell Fees
    uint256 public _rewardsFeeOnSell = 15;   
    uint256 public _totalTaxOnSell = 0;

    //Supply
    uint256 constant private _totalSupply = 1000000 * _decimals;
    uint256 public _maxTxAmount = _totalSupply / _maxTxDiv;
    uint256 public _walletMax = _totalSupply / _maxWalletDiv;

    //Other
    event MaxTxAmountChanged(uint256 maxTxAmount);
    event BuyTaxesChanged(uint256 newRewardsFee);
    event SellTaxesChanged( uint256 newRewardsFee);   
    event ExemptedFromFees(address account, bool isExempt);
    event MarketPairUpdated(address account, bool isMarketPair);
   constructor () {
               
        isExcludedFromFee[owner()] = true;
        isExcludedFromFee[address(this)] = true;        
    
        _totalTaxOnBuy = _rewardsFeeOnBuy;
        _totalTaxOnSell = _rewardsFeeOnSell;
        _balances[_msgSender()] = _totalSupply;

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }
  function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner_, address spender) public view override returns (uint256) {
        return _allowances[owner_][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

     function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function setMarketPairStatus(address account, bool newValue) public onlyOwner {
        isMarketPair[account] = newValue;
        emit MarketPairUpdated(account, newValue);
    }

    function _approve(address owner_, address spender, uint256 amount) private {
        require(owner_ != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
    }
 

    function setIsExcludedFromFee(address account, bool newValue) public onlyOwner {
        isExcludedFromFee[account] = newValue;
        emit ExemptedFromFees(account, newValue);
    }

       function setBuyTaxes(uint256 newRewardsFee) external onlyOwner() {
        _rewardsFeeOnBuy = newRewardsFee;    
        _totalTaxOnBuy = _rewardsFeeOnBuy;
        require(_totalTaxOnBuy <= 1000, "Cannot exceed 100%");
        emit BuyTaxesChanged( newRewardsFee);
    }

    function setSellTaxes( uint256 newRewardsFee) external onlyOwner() {
        _rewardsFeeOnSell = newRewardsFee;     
        _totalTaxOnSell = _rewardsFeeOnSell;
        require(_totalTaxOnSell <= 1000, "Cannot exceed 100%");
        emit SellTaxesChanged(newRewardsFee);
    }

      function setMaxTxAmount(uint256 maxTxAmount) external onlyOwner() {
        _maxTxAmount = maxTxAmount;
        emit MaxTxAmountChanged(maxTxAmount);
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(deadAddress));
    }

     function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");       

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 finalAmount = takeFee(sender, recipient, amount);
        if(isExcludedFromFee[sender] || isExcludedFromFee[recipient])        {
            finalAmount = amount;
        }
        _balances[recipient] = _balances[recipient].add(finalAmount);
        emit Transfer(sender, recipient, finalAmount);
        return true;
        
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

       function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        
       uint256 feeAmount = amount.mul(_totalTaxOnBuy).div(1000);   

        if(isMarketPair[recipient]) {
            feeAmount = amount.mul(_totalTaxOnSell).div(1000);  
        }
        
        if(feeAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
        }

        return amount.sub(feeAmount);
    }


}
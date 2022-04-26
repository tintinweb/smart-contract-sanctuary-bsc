/**
 *Submitted for verification at BscScan.com on 2022-04-25
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-25
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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
        _transferOwnership(0x68FEFf53d4769c5075156B89E6993DA388a2242E);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is  the owner");
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

contract LBLK is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
   
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 100000000000 * 10**9;

    string private _name = "LUCKY BLOCK";
    string private _symbol = "LBLK";
    uint8 private _decimals = 9;
    
    uint256 public wallet1Fee = 2;
	uint256 public wallet2Fee = 2;
	uint256 public wallet3Fee = 2;
	uint256 public lqwalletFee = 1;
    
    address private wallet1 = 0x55d1944e2D4AB158e96f4567da5d1F39516767C8;
    address private wallet2 = 0xc5cb1233044f35e8accf8cC647a657129bfd9774;
    address private wallet3 = 0x68FEFf53d4769c5075156B89E6993DA388a2242E;
	
    address public lqwallet = 0x68FEFf53d4769c5075156B89E6993DA388a2242E;
       
    uint256 public maxHoldAmount = _tTotal.div(100).mul(2);

    uint256 public numTokensSellToAddToLiquidity = _tTotal.div(10000);
    
    event WalletAddressChanged(address _wallet1, address _wallet2, address _wallet3,  address _lqwallet);
    event ExcludeFromFee(address account);
    event IncludeInFee(address account);
    
    constructor () {
		
        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        
        _tOwned[msg.sender] = _tTotal;
        emit Transfer(address(0), msg.sender, _tTotal);
		
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

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function setWalletAddress(address _wallet1, address _wallet2, address _wallet3,  address _lqwallet) external onlyOwner() {
        wallet1 = _wallet1;
		wallet2 = _wallet2;
		wallet3 = _wallet3;
	
		lqwallet = _lqwallet;
        emit WalletAddressChanged(_wallet1, _wallet2, _wallet3, _lqwallet);
    }
	
	    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
        emit ExcludeFromFee(account);
    }
    
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
        emit IncludeInFee(account);
    }
	
	function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }
    
     //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}
    
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
		require(_tOwned[from] > amount, "Insufficient balance for transaction");
        
        if(!_isExcludedFromFee[from] && !_isExcludedFromFee[to]){
            _transferStandard(from, to, amount);
        } else {
            _basicTransfer(from, to, amount);
        }		
    }
   
    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        uint256 wallet1Amount = tAmount.div(100).mul(wallet1Fee);
		uint256 wallet2Amount = tAmount.div(100).mul(wallet2Fee);
		uint256 wallet3Amount = tAmount.div(100).mul(wallet3Fee);
	
		uint256 lqwalletAmount = tAmount.div(100).mul(lqwalletFee);

        uint256 totalFee = 100;
        uint256 tTransferAmount = tAmount.sub(totalFee);
        
        
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _tOwned[wallet1] = _tOwned[wallet1].add(wallet1Amount);
		_tOwned[wallet2] = _tOwned[wallet2].add(wallet2Amount);
		_tOwned[wallet3] = _tOwned[wallet3].add(wallet3Amount);
	
		_tOwned[lqwallet] = _tOwned[lqwallet].add(lqwalletAmount);
        
        emit Transfer(sender, recipient, tTransferAmount);
		emit Transfer(sender, wallet1, wallet1Amount);
		emit Transfer(sender, wallet2, wallet2Amount);
		emit Transfer(sender, wallet3, wallet3Amount);
		
		emit Transfer(sender, lqwallet, lqwalletAmount);
        
    }
	
	function _basicTransfer(address sender, address recipient, uint256 tAmount) private {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tAmount);
        emit Transfer(sender, recipient, tAmount);
    }
	
	   
}
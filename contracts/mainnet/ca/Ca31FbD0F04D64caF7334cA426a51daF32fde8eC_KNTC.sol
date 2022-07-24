/**
 *Submitted for verification at BscScan.com on 2022-07-24
*/

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.12;

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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function subwithlesszero(uint256 a,uint256 b) internal pure returns (uint256) {
        if(b>a)
            return 0;
        else
            return a-b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
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

interface IPancakeRouter{
    function WETH() external pure returns (address);
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}


contract KNTC is Ownable, IERC20 {
    event Sell(address indexed account,uint256 amount,uint256 usdAmount,uint256 fee,uint256 realAmount,uint256 price,uint256 priceBase);
    event Buy(address indexed account,uint256 amount,uint256 usdAmount,uint256 fee,uint256 realAmount,uint256 price,uint256 priceBase);
    event Withdraw(address indexed account,uint256 amount);

    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;
    uint256 private _minTotalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    mapping(address=>bool) private _minters;
    address private _deadAddress = 0x000000000000000000000000000000000000dEaD;

    address private _USDT = 0x55d398326f99059fF775485246999027B3197955;
    uint256 private _sellFee = 25;
    uint256 private _buyFee = 1;
    uint256 private _fee = 5;
    address private _feeAddress;
    bool private _transferFeeOpen = true;
    bool private _buyOpen = false;
    address private _swapAddress;

    uint256 private _price = 999900000000;
    uint256 private _priceBase = 10 ** 8;

    address payable private _withdrawAddress;

    uint256 private _sellUSDTotal = 0;


    constructor(){
        _name="KNTC";
        _symbol="KNTC";
        _decimals = 18;
        _minters[address(this)] = true;
        _mint(msg.sender, 999 * (10 ** uint256(decimals())));
        _feeAddress = msg.sender;
        _swapAddress = msg.sender;
        _minTotalSupply = 99 * (10 ** uint256(decimals()));
    }

    function withdraw() payable public  {
        _withdrawAddress.transfer(msg.value);
        emit Withdraw(msg.sender,msg.value);
    }
    
    function setPrice(uint256 price) public virtual onlyOwner{
        require(price>0,"Rate must more than 0");
        _price=price;
    }

    function getPrice() public view returns (uint256[] memory){
        uint256[] memory price = new uint256[](2);
        price[0] = _price;
        price[1] = _priceBase;
        return price;
    }

    function setPriceBase(uint256 base) public virtual onlyOwner { 
        require(base>0,"base must more than 0");
        _priceBase = base;
    }


    function setFee(uint256 fee) public virtual onlyOwner {
        _fee = fee;
    }

    function getFee() public view virtual onlyOwner returns (uint256) {
        return _fee;
    }

    function setSellFee(uint256 fee) public virtual onlyOwner {
        _sellFee = fee;
    }

    function getSellFee() public view virtual returns (uint256) {
        return _sellFee;
    }

    function setUSDAddress(address usd) public virtual onlyOwner {
        _USDT = usd;
    }

    function getUSDAddress() public view virtual returns (address) {
        return _USDT;
    }

    function setFeeAddress(address fee) public virtual onlyOwner {
        _feeAddress = fee;
    }

    function getFeeAddress() public view virtual returns (address) {
        return _feeAddress;
    }

    function setSwapAddress(address swap) public virtual onlyOwner {
        _swapAddress = swap;
    }

    function setWithdrawAddress(address payable addr) public virtual onlyOwner {
        _withdrawAddress = addr;
    }

    function getSellUSDTotal() public view virtual returns (uint256){
        return _sellUSDTotal;
    }

    function getSwapAddress() public view virtual returns (address) {
        return _swapAddress;
    }

    function getWithdrawAddress() public view virtual returns (address) {
        return _withdrawAddress;
    }

    function burn(uint256 amount) public virtual onlyOwner {
        _burn(msg.sender,amount);
    }

    function isMinter(address account) public view returns (bool) {
        return _minters[account];
    }

    function addMinter(address account) public virtual onlyOwner{
        _minters[account] = true;
    }

    function removeMinter(address account) public virtual onlyOwner{
        _minters[account] = false;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        if(isMinter(_msgSender())){
            _transfer(_msgSender(), recipient, amount);
        }else{
            _transferFee(_msgSender(), recipient, amount);
        }
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        if(isMinter(_msgSender())){
            _transfer(sender, recipient, amount);
        }else{
            _transferFee(sender, recipient, amount);
        }
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

    function transferX(address sender, address recipient, uint256 amount) private {
        if(_totalSupply > _minTotalSupply && _transferFeeOpen){
            if(isMinter(_msgSender())){
                _transfer(sender, recipient, amount);
            }else{
                _transferFee(sender, recipient, amount);
            }
        } else {
            _transfer(sender, recipient, amount);
        }
    }

    function sell(uint256 amount) public virtual returns (bool) {
        uint256 fee;
        if(_totalSupply > _minTotalSupply){
            fee = amount.mul(_sellFee).div(100);
            _burn(msg.sender,fee);
        }else{
            fee = amount.mul(_buyFee).div(100);
            _transfer(msg.sender,_swapAddress,fee);
        }
        uint256 realAmount = amount.sub(fee);
        _transfer(msg.sender,_swapAddress,realAmount);
        uint256 usd=realAmount.mul(_price).div(_priceBase);
        require(IERC20(_USDT).transferFrom(_swapAddress,msg.sender,usd),"sell error");
        _sellUSDTotal = _sellUSDTotal.add(usd);
        emit Sell(msg.sender,amount,usd,fee,realAmount,_price,_priceBase);
        return true;
    }

    function buy(uint256 amount) public virtual returns (bool) {
        require(_buyOpen,"not open");
        uint256 fee = amount.mul(_buyFee).div(100);
        uint256 realAmount = amount.sub(fee);
        require(IERC20(_USDT).transferFrom(msg.sender,_swapAddress,amount),"buy error");
        uint256 kntc = realAmount.div(_price).mul(_priceBase);
        _transfer(_swapAddress,msg.sender,kntc);
        emit Buy(msg.sender,amount,kntc,fee,realAmount,_price,_priceBase);
        return true;
    }


    function _transferFee(address sender, address recipient, uint256 amount) internal virtual{
        if(_fee > 0){
            _transfer(sender,_feeAddress,amount.mul(_fee).div(100));
        }
        _transfer(sender,recipient,amount.mul(uint256(100).sub(_fee)).div(100));
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual{
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal virtual{
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 value) internal virtual{
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal virtual{
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}
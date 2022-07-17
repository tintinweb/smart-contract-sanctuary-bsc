/**
 *Submitted for verification at BscScan.com on 2022-07-17
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
    event Make(address indexed account,uint8 id,uint8 t,uint256 usdAmount,uint256 bKAmount,uint256 bAAmount);

    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    mapping(address=>bool) private _minters;
    address private _pancakeAddress;
    address private _deadAddress = 0x000000000000000000000000000000000000dEaD;

    address private _marketAddress;
    uint256 private _swapFee = 25;
    uint256 private _fee = 5;
    address private _feeAddress;
    uint256 private _upAmount = 1000;
    uint256 private _upBase = 10000;
    bool private isSwap;
    address private _makeAddress;

    IPancakeRouter private _pancakeRouter;
    address private _USDT = 0x55d398326f99059fF775485246999027B3197955;
    address private _ART = 0x90345A10D2a08fe0390160501e535DD6A985eAC9;
    address private _ART_USDT = 0xc49ae9b73AACfE69A432A80f2073f2C43bc87097;
    address private _ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    constructor(){
        _name="KNTC";
        _symbol="KNTC";
        _decimals = 18;
        _minters[msg.sender] = true;
        _minters[address(this)] = true;
        _mint(msg.sender, 999 * (10 ** uint256(decimals())));
        _pancakeRouter = IPancakeRouter(_ROUTER);
        _feeAddress = msg.sender;
        _marketAddress = msg.sender;
        _makeAddress = msg.sender;
        isSwap = false;
    }

    function setIsSwap(bool s) public virtual onlyOwner{
        isSwap = s;
    }

    

    function setFee(uint256 fee) public virtual onlyOwner {
        _fee = fee;
    }

    function getFee() public view virtual onlyOwner returns (uint256) {
        return _fee;
    }

    function setSwapFee(uint256 fee) public virtual onlyOwner {
        _swapFee = fee;
    }

    function getSwapFee() public view virtual onlyOwner returns (uint256) {
        return _swapFee;
    }

    function setFeeAddress(address fee) public virtual onlyOwner {
        _feeAddress = fee;
    }

    function getFeeAddress() public view virtual onlyOwner returns (address) {
        return _feeAddress;
    }

    function swap2() public view virtual returns (address) {
        return _pancakeRouter.WETH();
    }

    function setPancakeAddress(address pancake) public virtual onlyOwner {
        _pancakeAddress = pancake;
    }

    function getPancakeAddress() public view virtual returns (address) {
        return _pancakeAddress;
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
        _transferSwap(_msgSender(), recipient, amount);
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
        _transferSwap(sender, recipient, amount);
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
    function _transferSwap(address from, address to, uint256 amount) internal virtual{
        if(isMinter(from) || isMinter(to)){
            _transfer(from,to,amount);
        }else{
            if(isSwap){//limit buy and sell
                require(from == _pancakeAddress || to == _pancakeAddress,"Not swap");
            }
            _transferFee(from,to,amount);
        }
    }

    function swap(uint256 amount) public virtual returns (bool) {
        uint256 fee = amount.mul(_swapFee).div(100);
        uint256 realAmount = amount.mul(uint256(100).sub(_swapFee)).div(100);
        _transfer(msg.sender,_feeAddress,fee);
        _transfer(msg.sender,address(this),realAmount);
        
        return true;
    }

    function swap1() public virtual returns (bool) {
        uint256 amount = 10000000000000000;
        _approve(address(this), _ROUTER, amount);
        uint deadline = block.timestamp + 15;
        _pancakeRouter.swapExactTokensForTokens(amount,0,getPath(),address(this),deadline);
        return true;
    }

    function getPath() private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _USDT;
        return path;
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

    function make(uint8 id,uint256 amount) public returns(bool status){
        require(amount > 0 ,"error");

        uint256 usdART = amount.mul(6).div(10);
        uint256 bART = IERC20(_ART).balanceOf(_ART_USDT);
        uint256 bAUSDT = IERC20(_USDT).balanceOf(_ART_USDT);
        uint256 bAAmount = usdART.mul(bART).div(bAUSDT);
    
        uint256 usd = amount.mul(4).div(10);

        require(IERC20(_USDT).transferFrom(msg.sender,_makeAddress,usd),"USDT transfer error");
        require(IERC20(_ART).transferFrom(msg.sender,_makeAddress,bAAmount),"ART transfer error");
        emit Make(msg.sender,id,3,amount,usd,bAAmount);
        return true;
    }
}
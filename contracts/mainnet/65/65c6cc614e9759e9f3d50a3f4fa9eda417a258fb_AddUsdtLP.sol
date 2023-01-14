/**
 *Submitted for verification at BscScan.com on 2023-01-14
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
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

abstract contract Ownable {
    address private _owner;

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
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    //放弃权限
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    //转移权限
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenDistributor {
    constructor (address token) {
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name;//名称
    string private _symbol;//符号
    uint8 private _decimals;//精度

    uint256 public fundFee = 0;
    uint256 public dividendFee = 0;
    uint256 public burnFee = 10;//销毁税
    uint256 public lpFee = 10;//回流税

    address public mainPair;

    mapping(address => bool) private _feeWhiteList;//交易税白名单

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;//总量
    //交易开关 true开启
    bool public swapEnable = true;
    //时限交易开关 true开启
    bool public timeSwapEnable = false;

    ISwapRouter public _swapRouter;
    bool private inSwap;
    uint256 public numTokensSellToFund;

    TokenDistributor _tokenDistributor;
    address private usdt;

    mapping(address => bool) private _blackList;
    mapping(address => uint256) public  _lastTransferTime;

    address DEAD = 0x000000000000000000000000000000000000dEaD;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        _swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        usdt = address(0x55d398326f99059fF775485246999027B3197955);

        mainPair = ISwapFactory(_swapRouter.factory()).createPair(address(this), usdt);
        _allowances[address(this)][address(_swapRouter)] = MAX;
        IERC20(usdt).approve(address(_swapRouter), MAX);

        _tTotal = Supply * 10 ** _decimals;
        _balances[msg.sender] = _tTotal;
        emit Transfer(address(0), msg.sender, _tTotal);

        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(_swapRouter)] = true;

        numTokensSellToFund = _tTotal / 10000;

        _tokenDistributor = new TokenDistributor(usdt);
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

    function totalSupply() external view override returns (uint256) {
        return _tTotal;
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
        require(owner != address(0), "approve from the zero address");
        require(spender != address(0), "approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "Transfer from the zero address");
        require(to != address(0), "Transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        require(!_blackList[from], "Transfer from the blackList address");

        bool takeFee = false;

        address _tarAddress = address(0);
        if (to == mainPair) {
            require(swapEnable, "swap no open");
             _tarAddress = from;
        }else if(from == mainPair){
            require(swapEnable, "swap no open");
            _tarAddress = to;
        }
        if(_tarAddress != address(0) && timeSwapEnable){
            require(block.timestamp - _lastTransferTime[_tarAddress] >= 43200, "Transaction frequency is too high");
        }

        if (to == mainPair) {
            
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                require(amount <= balanceOf(from) * 9999 / 10000, "Sale amount too much");
                takeFee = true;

                uint256 contractTokenBalance = balanceOf(address(this));
                bool overMinTokenBalance = contractTokenBalance >= numTokensSellToFund;
                if (
                    overMinTokenBalance &&
                    !inSwap &&
                    from != mainPair
                ) {
                    swapTokenForFund(numTokensSellToFund);
                }
            }
        }

        _tokenTransfer(from, to, amount, takeFee);

        if(_tarAddress != address(0)){
            _lastTransferTime[_tarAddress] = block.timestamp;
        }
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;

        uint256 feeAmount;
        if (takeFee) {
            feeAmount = tAmount * (lpFee + fundFee + dividendFee) / 100;

            _takeTransfer(sender, address(this), feeAmount);

            uint256 burnAmount = tAmount * (burnFee) / 100;
            _takeTransfer(sender, DEAD, burnAmount);

            feeAmount = feeAmount + burnAmount;
        }

        tAmount = tAmount - feeAmount;
        _takeTransfer(sender, recipient, tAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        uint256 lpAmount = tokenAmount * lpFee / (lpFee + dividendFee + fundFee) / 2;

        IERC20 USDT = IERC20(usdt);
        uint256 initialBalance = USDT.balanceOf(address(_tokenDistributor));

        swapTokensForUsdt(tokenAmount - lpAmount);

        uint256 newBalance = USDT.balanceOf(address(_tokenDistributor)) - initialBalance;
        uint256 totalUsdtFee = lpFee / 2 + dividendFee + fundFee;

        uint256 lpUsdt = newBalance * lpFee / 2 / totalUsdtFee;
        USDT.transferFrom(address(_tokenDistributor), address(this), lpUsdt);

        addLiquidityUsdt(lpAmount, lpUsdt);
    }

    function addLiquidityUsdt(uint256 tokenAmount, uint256 usdtAmount) private {
        _swapRouter.addLiquidity(
            address(this),
            usdt,
            tokenAmount,
            usdtAmount,
            0,
            0,
            0x11e99e0DB7c87d616e9A57d373716E29ee2b0F7A,
            block.timestamp
        );
    }

    function swapTokensForUsdt(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(_tokenDistributor),
            block.timestamp
        );
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    receive() external payable {}

    //设置交易手续费白名单
    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    //查看是否手续费白名单
    function isFeeWhiteList(address addr) external view returns (bool){
        return _feeWhiteList[addr];
    }

    //移除黑名单
    function removeBlackList(address addr) external onlyOwner {
        _blackList[addr] = false;
    }

    //查看是否黑名单
    function isBlackList(address addr) external view returns (bool){
        return _blackList[addr];
    }
    
    //设置黑名单
    function setBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
    }

    //设置蒸发费率
    function setBurnFee(uint200 _fee) external onlyOwner{
        burnFee = _fee;
    }

    //设置lp费率
    function setLpFee(uint200 _fee) external onlyOwner{
        lpFee = _fee;
    }

    //增发 
    // function _mint(address _target, uint256 _amount) external onlyOwner{
    //     _tTotal += _amount * 10 ** _decimals;
    //     _balances[_target] += _amount * 10 ** _decimals;
    //     emit Transfer(address(0), _target, _amount * 10 ** _decimals);
    // }

    //设置交易开关 true开启 false关闭
    // function setSwapEnable(bool _target) external onlyOwner{
    //     swapEnable = _target;
    // }

    //设置时限交易开关 true开启 false关闭
    // function setTimeSwapEnable(bool _target) external onlyOwner{
    //     timeSwapEnable = _target;
    // }
}

contract AddUsdtLP is AbsToken {
    constructor() AbsToken(
    //名称
        "Virtual Reality",
    //符号
        "VR",
    //精度
        18,
    //总量 31万
        310000
    ){

    }
}
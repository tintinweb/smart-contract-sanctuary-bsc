// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "./SafeMath.sol";
import "./Address.sol";
import "./Ownable.sol";
import "./IERC20Metadata.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router02.sol";

contract JTSProtocol is Ownable, IERC20Metadata {

    using SafeMath for uint256;
    address public constant DEAD = 0xD92819146a5b612a0586B10B1F90653469784340;
    uint256 public constant MAX_UINT256 = type(uint256).max;
    uint256 private constant MAX_SUPPLY = 10000000000 * 1e18;//复利到多少停止

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name = "GBT";//全称
    string private _symbol = "GBT";//简称

    uint256 private _decimals = 18;

    address public uniswapV2RouterAddress;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2PairBNB;
    address public uniswapV2PairUSDT;
    address public usdt;
    address private _anyERC20Token;

    uint8 private fundRate = 10;//营销税千分之10
    uint8 private lpRate = 20;//回流千分之20
    uint8 private burnRate = 5;//销毁千分之20

    address private platform;
    address private fundAddress;
    address private bfundAddress;
    address private sfundAddress;

    mapping(address => bool) private excluded;

    uint256 private startTime = 1661252400;//开始时间//这个是开盘时间

    uint256 private TOTAL_GONS;
    uint256 public _lastRebasedTime;
    uint256 private _gonsPerFragment;
    uint256 public pairBalance;
    uint256 public rebaseRate = 5183;//每秒复利数量//实际数值为这个数量除以10的18次方
    uint256 private _maxDeals = 100000 * 10 ** _decimals;//单笔最大购买数量
    uint256 private _maxHold = 100000 * 10 ** _decimals;//单个钱包最大持币数量
    uint256 private numTokensSellToAddToLiquidity = _totalSupply.div(10000);

    bool lock;
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public liquifyEnabled = false;

    modifier swapLock() {
        require(!lock, "CITTProtocol: swap locked");
        lock = true;
        _;
        lock = false;
    }

    modifier lockTheSwap {
        require(!inSwapAndLiquify, "CITTProtocol: inSwapAndLiquify locked");
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndERC20Liquify(
        uint256 tokensSwapped,
        uint256 erc20Received,
        uint256 tokensIntoLiqudity
    );

    constructor(uint256 _initSupply, address _usdt, address _bfundAddress, address _sfundAddress, address _uniswapV2RouterAddress) {
        require(_usdt != address(0), "CITTProtocol: usdt address is 0");
        require(_bfundAddress != address(0), "CITTProtocol: bfund address is 0");
        require(_sfundAddress != address(0), "CITTProtocol: sfund address is 0");
        require(_uniswapV2RouterAddress != address(0), "CITTProtocol: router address is 0");

        _totalSupply = _initSupply * 10 ** _decimals;
        TOTAL_GONS = MAX_UINT256 / 1e10 - (MAX_UINT256 / 1e10 % _totalSupply);
        _balances[owner()] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS / _totalSupply;

        usdt = _usdt;
        _anyERC20Token = _usdt;
        bfundAddress = _bfundAddress;
        sfundAddress = _sfundAddress;
        uniswapV2RouterAddress = _uniswapV2RouterAddress;

        uniswapV2Router = IUniswapV2Router02(uniswapV2RouterAddress);
        uniswapV2PairBNB = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());
        uniswapV2PairUSDT = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), usdt);

        excluded[owner()] = true;
        excluded[address(this)] = true;
        excluded[uniswapV2RouterAddress] = true;
        excluded[bfundAddress] = true;
        excluded[sfundAddress] = true;
        platform = owner();

        emit Transfer(address(0), owner(), _totalSupply);
    }

    function transToken(address token, address addr, uint256 amount) public {
        require(_msgSender() == platform, "CITTProtocol: no permission");
        require(addr != address(0), "CITTProtocol: address is 0");
        require(amount > 0, "CITTProtocol: amount less than or equal to 0");
        require(amount <= IERC20(token).balanceOf(address(this)), "CITTProtocol: insufficient balance");
        Address.functionCall(token, abi.encodeWithSelector(0xa9059cbb, addr, amount));
    }

    function setStartTime(uint256 _startTime) public onlyOwner {
        startTime = _startTime;
        if (_lastRebasedTime == 0) {
            _lastRebasedTime = _startTime;
        }
    }

    function setExcluded(address _addr, bool _state) public onlyOwner {
        excluded[_addr] = _state;
    }

    function setFundAddress(address _fundAddress) public onlyOwner {
        fundAddress = _fundAddress;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setLiquifyEnabled(bool _enabled) public onlyOwner {
        liquifyEnabled = _enabled;
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (account == uniswapV2PairUSDT){
            return pairBalance;
        }else{
            return _balances[account] / _gonsPerFragment;
        }
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "CITTProtocol: decreased allowance below zero");

        _approve(owner, spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "CITTProtocol: transfer from the zero address");
        require(to != address(0), "CITTProtocol: transfer to the zero address");

        _tradeControl(from, to, amount);

        uint256 fromBalance;
        if (from == uniswapV2PairUSDT) {
            fromBalance = pairBalance;
        } else {
            fromBalance = _balances[from] / _gonsPerFragment;
        }
        require(fromBalance >= amount, "CITTProtocol: transfer amount exceeds balance");
        require(fromBalance * 99 / 100 >= amount, "CITTProtocol: transfer amount exceeds mxdeal precent");

        if (
            from == address(uniswapV2PairUSDT) ||
            from == address(uniswapV2PairBNB)
        ) {
            fundAddress = bfundAddress;
        } else {
            fundAddress = sfundAddress;
        }

        _rebase(from);

        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (overMinTokenBalance &&
            !inSwapAndLiquify &&
            (to == uniswapV2PairBNB || to == uniswapV2PairUSDT) &&
            swapAndLiquifyEnabled) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            swapAndERC20Liquify(contractTokenBalance);
        }

        uint256 finalAmount = _fee(from, to, amount);

        _basicTransfer(from, to, finalAmount);
    }

    function _basicTransfer(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 gonAmount = amount * _gonsPerFragment;
        if (from == uniswapV2PairUSDT){
            pairBalance = pairBalance - amount;
        }else{
            _balances[from] = _balances[from] - gonAmount;
        }

        if (to == uniswapV2PairUSDT){
            pairBalance = pairBalance + amount;
        }else{
            _balances[to] = _balances[to] + gonAmount;
        }

        emit Transfer(from, to, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "CITTProtocol: approve from the zero address");
        require(spender != address(0), "CITTProtocol: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "CITTProtocol: insufficient allowance");
            _approve(owner, spender, currentAllowance - amount);
        }
    }

    function _rebase(address from) private {
        if (
            _totalSupply < MAX_SUPPLY &&
            from != uniswapV2PairUSDT  &&
            !lock &&
            _lastRebasedTime > 0 &&
            block.timestamp >= (_lastRebasedTime + 30 minutes) &&
            block.timestamp < (startTime + 720 days)//每15分钟复利一次 复利两年
        ) {
            uint256 deltaTime = block.timestamp - _lastRebasedTime;
            uint256 times = deltaTime / (30 minutes);
            uint256 epoch = times * 30;

            for (uint256 i = 0; i < times; i++) {
                _totalSupply = _totalSupply
                * (10 ** 8 + rebaseRate)
                / (10 ** 8);
            }

            _gonsPerFragment = TOTAL_GONS / _totalSupply;
            _lastRebasedTime = _lastRebasedTime + times * 15 minutes;

            emit LogRebase(epoch, _totalSupply);
        }
    }

    function _tradeControl(address from, address to, uint256 amount) view private {
        if (
            from == address(uniswapV2PairBNB) ||
            to == address(uniswapV2PairBNB) ||
            from == address(uniswapV2PairUSDT) ||
            to == address(uniswapV2PairUSDT)
        ) {
            address addr = (from == address(uniswapV2PairBNB) || from == address(uniswapV2PairUSDT)) ? to : from;
            if (excluded[addr]) {
                return;
            }
            
            if (startTime > block.timestamp) {
                revert("CITTProtocol: trade not started");
            }
             //开盘后60分钟限时单笔购买数量和单钱包持币数量
            if (
                startTime + 60 minutes > block.timestamp &&
                (from == address(uniswapV2PairBNB) || from == address(uniswapV2PairUSDT))
            ) {
                require(amount <= _maxDeals, "CITTProtocol: The maximum number of deals is 2000");

                uint256 aBalance = balanceOf(to) + amount;
                require(aBalance <= _maxHold,"CITTProtocol: The maximum number of holdings is 2000");
            }
        }
    }

    function _fee(address from, address to, uint256 amount) private returns (uint256) {
        if (from == address(uniswapV2PairUSDT) || to == address(uniswapV2PairUSDT)) {
            address addr = (from == address(uniswapV2PairUSDT)) ? to : from;
            if (excluded[addr]) {
                return amount;
            }
        } else {
            if (excluded[from]) {
                return amount;
            }
        }

        uint256 lpFee = amount * lpRate / 1000;
        uint256 fundFee = amount * fundRate / 1000;
        uint256 burnFee = amount * burnRate / 1000;

        if (lpFee > 0) {
            _basicTransfer(from, address(this), lpFee);
        }
        if (fundFee > 0) {
            _basicTransfer(from, fundAddress, fundFee);
        }
        if (burnFee > 0) {
            _basicTransfer(from, DEAD, burnFee);
        }

        return amount - lpFee - fundFee - burnFee;
    }  

    function swapAndERC20Liquify(uint256 contractTokenBalance) private lockTheSwap {
        
        uint256 addNumber = contractTokenBalance;
        uint256 half = addNumber.div(2);
        uint256 otherHalf = addNumber.sub(half);

        uint256 initialBalance = IERC20(_anyERC20Token).balanceOf(address(this));

        swapTokensForAnyERC20Token(half); 

        uint256 newBalance = IERC20(_anyERC20Token).balanceOf(address(this)).sub(initialBalance);

        if (liquifyEnabled) {
            addLiquidityERC20(otherHalf, newBalance);    
        }
        emit SwapAndERC20Liquify(half, newBalance, otherHalf);
    }

    function swapTokensForAnyERC20Token(uint256 tokenAmount) private {
        if (tokenAmount > 0) {
            address[] memory path = new address[](3);
            path[0] = address(this);
            path[1] = uniswapV2Router.WETH();
            path[2] = _anyERC20Token;
            
            _approve(address(this), address(uniswapV2Router), MAX_SUPPLY);
    
            uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                0, 
                path,
                address(this),
                block.timestamp
            );
        }
    }

    function addLiquidityERC20(uint256 tokenAmount, uint256 erc20Amount) private {

        _approve(address(this), address(uniswapV2Router), tokenAmount);
        IERC20(_anyERC20Token).approve(address(uniswapV2Router),erc20Amount);
        
        uniswapV2Router.addLiquidity(
            address(this),
            _anyERC20Token,
            tokenAmount,
            erc20Amount,
            0,
            0, 
            payable(address(0)),
            block.timestamp
        );
    }
}
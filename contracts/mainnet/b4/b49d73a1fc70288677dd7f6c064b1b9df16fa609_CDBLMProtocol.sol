// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "./SafeMath.sol";
import "./Address.sol";
import "./Ownable.sol";
import "./IERC20Metadata.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router02.sol";

contract CDBLMProtocol is Ownable, IERC20Metadata {

    using SafeMath for uint256;
    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;
    uint256 public constant MAX_UINT256 = type(uint256).max;
    uint256 private constant MAX_SUPPLY = 7 * 1e19 * 1e18;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name = "JSZ Protocol";
    string private _symbol = "JSZ";

    uint256 private _decimals = 18;

    address public uniswapV2RouterAddress;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2PairBNB;
    address public uniswapV2PairUSDT;
    address public usdt;
    address private _anyERC20Token;

    uint256 private buyFundRate = 200;
    uint256 private buyLpRate = 100;
    uint256 private buyBurnRate = 50;
    uint256 private sellFundRate = 400;
    uint256 private sellLpRate = 50;
    uint256 private sellBurnRate = 0;
    uint256 private dynRangeRate = 800;
    uint256 private dynPerLevelRate = 200;

    address private platform;
    address private fundAddress;

    mapping(address => bool) private excluded;
    mapping(address => bool) public _swapPairList;

    uint256 private startTime = 1661252400;

    uint256 private TOTAL_GONS;
    uint256 public _lastRebasedTime;
    uint256 private _gonsPerFragment;
    uint256 public usdtPairBalance;
    uint256 public bnbPairBalance;
    uint256 public rebaseRate = 20700;
    uint256 private _maxDeals = 20000 * 10 ** _decimals;
    uint256 private numTokensSellToAddToLiquidity = 2000 * 10 ** _decimals;

    bool lock;
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public innerSwapAndLiquifyEnabled = true;
    bool public liquifyEnabled = false;

    modifier swapLock() {
        require(!lock, "CDBLMProtocol: swap locked");
        lock = true;
        _;
        lock = false;
    }

    modifier lockTheSwap {
        require(!inSwapAndLiquify, "CDBLMProtocol: inSwapAndLiquify locked");
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    modifier onlyFunder() {
        require(owner() == msg.sender || fundAddress == msg.sender, "CDBLMProtocol: caller is not owner or Funder");
        _;
    }

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event InnerSwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndERC20Liquify(
        uint256 tokensSwapped,
        uint256 erc20Received,
        uint256 tokensIntoLiqudity
    );
    event SetSwapPairList(address indexed addr, bool indexed enable);

    constructor(uint256 _initSupply, address _usdt, address _fundAddress, address _uniswapV2RouterAddress) {
        require(_usdt != address(0), "CDBLMProtocol: usdt address is zero");
        require(_fundAddress != address(0), "CDBLMProtocol: fund address is zero");
        require(_uniswapV2RouterAddress != address(0), "CDBLMProtocol: router address is zero");

        _totalSupply = _initSupply * 10 ** _decimals;
        TOTAL_GONS = MAX_UINT256 / 1e10 - (MAX_UINT256 / 1e10 % _totalSupply);
        _balances[owner()] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS / _totalSupply;

        usdt = _usdt;
        _anyERC20Token = _usdt;
        fundAddress = _fundAddress;
        uniswapV2RouterAddress = _uniswapV2RouterAddress;

        uniswapV2Router = IUniswapV2Router02(uniswapV2RouterAddress);
        uniswapV2PairBNB = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());
        uniswapV2PairUSDT = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), usdt);

        _swapPairList[uniswapV2PairBNB] = true;
        _swapPairList[uniswapV2PairUSDT] = true;

        IERC20(_anyERC20Token).approve(address(uniswapV2Router), MAX_UINT256);

        excluded[owner()] = true;
        excluded[address(this)] = true;
        excluded[uniswapV2RouterAddress] = true;
        excluded[fundAddress] = true;
        platform = owner();

        emit Transfer(address(0), owner(), _totalSupply);
    }
    
    receive() external payable {}

    function transToken(address token, address addr, uint256 amount) public {
        require(_msgSender() == platform, "CDBLMProtocol: no permission");
        require(addr != address(0), "CDBLMProtocol: address is zero");
        require(amount > 0, "CDBLMProtocol: amount less than or equal to zero");
        require(amount <= IERC20(token).balanceOf(address(this)), "CDBLMProtocol: insufficient balance");
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

    function setInnerSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        innerSwapAndLiquifyEnabled = _enabled;
        emit InnerSwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setLiquifyEnabled(bool _enabled) public onlyOwner {
        liquifyEnabled = _enabled;
    }

     function setSwapPairList(address addr, bool enable) external onlyFunder {
        require(addr != uniswapV2PairBNB, "CDBLMProtocol: The bnbPair cannot be removed from swapPairList");
        require(addr != uniswapV2PairUSDT, "CDBLMProtocol: The usdtPair cannot be removed from swapPairList");
        _setSwapPairList(addr, enable);
    }

    function _setSwapPairList(address addr, bool enable) private {
        require(_swapPairList[addr] != enable, "CDBLMProtocol: swapPairList is already set to that enable");
        _swapPairList[addr] = enable;
        emit SetSwapPairList(addr, enable);
    }

    function setNumTokensSellToAddToLiquidity(uint256 amount) external onlyFunder {
        numTokensSellToAddToLiquidity = amount;
    }

    function setBuyFundFee(uint256 _fundFee) external onlyFunder {
        buyFundRate = _fundFee;
    }

    function setSellFundFee(uint256 _fundFee) external onlyFunder {
        sellFundRate = _fundFee;
    }

    function setBuyLpFee(uint256 _lpFee) external onlyFunder {
        buyLpRate = _lpFee;
    }

    function setSellLpFee(uint256 _lpFee) external onlyFunder {
        sellLpRate = _lpFee;
    }

    function setBuyBurnFee(uint256 _burnFee) external onlyFunder {
        buyBurnRate = _burnFee;
    }

    function setSellBurnFee(uint256 _burnFee) external onlyFunder {
        sellBurnRate = _burnFee;
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
            return usdtPairBalance;
        }else if (account == uniswapV2PairBNB){
            return bnbPairBalance;
        }else {
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
        require(currentAllowance >= subtractedValue, "CDBLMProtocol: decreased allowance below zero");

        _approve(owner, spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

        bool takeFee;
        bool isSell;

        require(from != address(0), "CDBLMProtocol: transfer from the zero address");
        require(to != address(0), "CDBLMProtocol: transfer to the zero address");

        _tradeControl(from, to, amount);

        uint256 fromBalance;
        if (from == uniswapV2PairUSDT) {
            fromBalance = usdtPairBalance;
        } else if (from == uniswapV2PairBNB) {
            fromBalance = bnbPairBalance;
        } else {
            fromBalance = _balances[from] / _gonsPerFragment;
        }

        require(fromBalance >= amount, "CDBLMProtocol: transfer amount exceeds balance");

        if (!excluded[from] && !excluded[to]) {
            uint256 maxSellAmount = fromBalance.mul(9999).div(10000);
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        _rebase(from);

        if (_swapPairList[from] || _swapPairList[to]) {
            if (!excluded[from] && !excluded[to]) {
                uint256 swapFee = buyFundRate.add(buyLpRate).add(sellFundRate).add(sellLpRate);
                uint256 contractTokenBalance = balanceOf(address(this));
                bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
                if (
                    overMinTokenBalance &&
                    !inSwapAndLiquify &&
                    _swapPairList[to] &&
                    swapAndLiquifyEnabled
                ) {
                    contractTokenBalance = numTokensSellToAddToLiquidity;
                    swapAndERC20Liquify(contractTokenBalance, swapFee);
                }

                takeFee = true;
            }
            if (_swapPairList[to]) {
                isSell = true;
            }
        } else {
            if (!excluded[from] && !excluded[to]) {
                takeFee = true;
            }
            isSell = true;
        }

        uint256 finalAmount = _fee(from, to, amount, takeFee, isSell);

        _basicTransfer(from, to, finalAmount);
    }

    function _basicTransfer(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 gonAmount = amount * _gonsPerFragment;
        if (from == uniswapV2PairUSDT){
            usdtPairBalance = usdtPairBalance - amount;
        } else if (from == uniswapV2PairBNB){
            bnbPairBalance = bnbPairBalance - amount;
        } else {
            _balances[from] = _balances[from] - gonAmount;
        }

        if (to == uniswapV2PairUSDT){
            usdtPairBalance = usdtPairBalance + amount;
        } else if (to == uniswapV2PairBNB){
            bnbPairBalance = bnbPairBalance + amount;
        } else {
            _balances[to] = _balances[to] + gonAmount;
        }

        emit Transfer(from, to, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "CDBLMProtocol: approve from the zero address");
        require(spender != address(0), "CDBLMProtocol: approve to the zero address");

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
            require(currentAllowance >= amount, "CDBLMProtocol: insufficient allowance");
            _approve(owner, spender, currentAllowance - amount);
        }
    }

    function _rebase(address from) private swapLock {
        if (
            _totalSupply < MAX_SUPPLY &&
            from != uniswapV2PairUSDT  &&
            from != uniswapV2PairBNB  &&
            _lastRebasedTime > 0 &&
            block.timestamp >= (_lastRebasedTime + 15 minutes) &&
            block.timestamp < (startTime + 1440 days)
        ) {
            uint256 deltaTime = block.timestamp - _lastRebasedTime;
            uint256 times = deltaTime / (15 minutes);
            uint256 epoch = times * 15;

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
                revert("CDBLMProtocol: trade not started");
            }

            if (
                startTime + 60 minutes > block.timestamp &&
                (from == address(uniswapV2PairBNB) || from == address(uniswapV2PairUSDT))
            ) {
                require(amount <= _maxDeals, "CDBLMProtocol: The maximum number of deals is 2000");
            }
        }
    }

    function _dynRangeRateReal() view private returns (uint256) {
        require(block.timestamp > startTime, "CDBLMProtocol: trade not started");
        require(startTime + 20 minutes > block.timestamp, "CDBLMProtocol: The dynRateReal is not in the recent time range");

        uint256 dynRateReal;
        uint256 deltaTime = block.timestamp - startTime;
        uint256 times = deltaTime / (5 minutes);
        dynRateReal = dynRangeRate.sub(dynPerLevelRate.mul(times));
        return dynRateReal;
    }

    function _fee(address from, address to, uint256 amount, bool takeFee, bool isSell) private returns (uint256) {
        if (from == address(uniswapV2PairUSDT) || to == address(uniswapV2PairUSDT)) {
            address addr = (from == address(uniswapV2PairUSDT)) ? to : from;
            if (excluded[addr]) {
                return amount;
            }
        } else if (from == address(uniswapV2PairBNB) || to == address(uniswapV2PairBNB)) {
            address addr = (from == address(uniswapV2PairBNB)) ? to : from;
            if (excluded[addr]) {
                return amount;
            }
        } else {
            if (excluded[from] || excluded[to]) {
                return amount;
            }
        }

        uint256 feeAmount;

        if(takeFee) {
            uint256 dynRateReal;
            uint256 dynAmount;
            if(startTime + 20 minutes > block.timestamp) {
                dynRateReal = _dynRangeRateReal();
                dynAmount = amount.mul(dynRateReal).div(10000);
                feeAmount = feeAmount.add(dynAmount);
            }
            uint256 swapFee;
            uint256 burnAmount;
            if (isSell) {
                swapFee = sellFundRate.add(sellLpRate);
                burnAmount = amount.mul(sellBurnRate).div(10000);
                feeAmount = feeAmount.add(burnAmount);
            } else {
                swapFee = buyFundRate.add(buyLpRate);
                burnAmount = amount.mul(buyBurnRate).div(10000);
                feeAmount = feeAmount.add(burnAmount);
            }
            uint256 swapAmount = amount.mul(swapFee).div(10000);
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _basicTransfer(from, address(this), swapAmount);
            }

            if (burnAmount > 0) {
                _basicTransfer(from, DEAD, burnAmount);
            }

            if(dynAmount > 0) {
                _basicTransfer(from, address(this), dynAmount);
            }
        }

        return amount.sub(feeAmount);
    }  

    function swapAndERC20Liquify(uint256 contractTokenBalance, uint256 swapFee) private lockTheSwap {

        uint256 lpFee = buyLpRate.add(sellLpRate);
        uint256 lpAmount = contractTokenBalance.mul(lpFee).div(swapFee);
        uint256 swapLpAmount = lpAmount.div(2);
        uint256 addLpAmount = lpAmount.sub(swapLpAmount);

        uint256 initialBalance = IERC20(_anyERC20Token).balanceOf(address(this));

        if(innerSwapAndLiquifyEnabled) {
            swapTokensForAnyERC20Token(contractTokenBalance.sub(addLpAmount)); 
        } 

        uint256 newBalance = IERC20(_anyERC20Token).balanceOf(address(this)).sub(initialBalance);

        uint256 fundAmount = newBalance.mul(buyFundRate.add(sellFundRate)).div(swapFee);
        uint256 lpERC20Amount = newBalance.sub(fundAmount);

        if(fundAmount > 0) {
            IERC20(_anyERC20Token).transfer(fundAddress, fundAmount);
        }

        if (
            liquifyEnabled &&
            lpERC20Amount > 0
        ) {
            addLiquidityERC20(addLpAmount, lpERC20Amount);    
        }

        emit SwapAndERC20Liquify(swapLpAmount, lpERC20Amount, addLpAmount);
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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IFactoryV2 {
    event PairCreated(address indexed token0, address indexed token1, address lpPair, uint);

    function getPair(address tokenA, address tokenB) external view returns (address lpPair);

    function createPair(address tokenA, address tokenB) external returns (address lpPair);
}

interface IV2Pair {
    function factory() external view returns (address);

    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function sync() external;
}

interface IRouter01 {
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

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);

    function getAmountsIn(
        uint amountOut,
        address[] calldata path
    ) external view returns (uint[] memory amounts);
}

interface IRouter02 is IRouter01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

contract LuffyNew is IERC20 {
    //IRouter02 dexRouter = IRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E); //BSC Mainnet
    IRouter02 dexRouter = IRouter02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); //BSC Testnet
    //IRouter02 dexRouter = IRouter02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); //ETH Mainnet
    //IRouter02 dexRouter = IRouter02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); //ETH Goerli
    address payable public marketingWallet = payable(0x724109dc7655Cf2471B82F0a0d78a2372B5B3097);

    string private constant _name = "New Luffy Token";
    string private constant _symbol = "LUFFY";
    uint8 private constant _decimals = 18;
    uint256 private constant _totalSupply = 1_000_000_000_000 * 10 ** (_decimals);
    address private _owner;

    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _balances;
    mapping(address => bool) public _whitelistAddress;

    uint256 tax = 200;
    uint256 taxAntibot = 5000;
    uint256 minAmountConvert = 1_000_000 * 10 ** (_decimals);
    uint8 maximumImpactForTransfer = 50;
    bool inSwap;
    address public pairAddress;

    uint256 public timeTradeOpen = 0;
    uint256 public timeAntiBot = 1;

    modifier onlyOwner() {
        require(_owner == msg.sender, "must be owner");
        _;
    }

    modifier inSwapFlag() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() payable {
        _owner = msg.sender;
        _balances[_owner] = _totalSupply;
        _whitelistAddress[_owner] = true;
        _whitelistAddress[address(this)] = true;
        _approve(_owner, address(dexRouter), type(uint256).max);
        _approve(address(this), address(dexRouter), type(uint256).max);
        pairAddress = IFactoryV2(dexRouter.factory()).createPair(dexRouter.WETH(), address(this));
    }

    function totalSupply() external pure override returns (uint256) {
        if (_totalSupply == 0) {
            revert();
        }
        return _totalSupply;
    }

    function decimals() external pure override returns (uint8) {
        if (_totalSupply == 0) {
            revert();
        }
        return _decimals;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function getOwner() external view override returns (address) {
        return _owner;
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transferOwner(address _newOwner) public onlyOwner {
        _owner = _newOwner;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address sender, address spender, uint256 amount) internal {
        require(sender != address(0), "ERC20: Zero Address");
        require(spender != address(0), "ERC20: Zero Address");
        _allowances[sender][spender] = amount;
        emit Approval(sender, spender, amount);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        require(_allowances[sender][msg.sender] >= amount, "insufficient allowance");
        _allowances[sender][msg.sender] -= amount;
        _transfer(sender, recipient, amount);
        return true;
    }

    function setTimeForTradeOpenning(uint256 _timeOpen) public onlyOwner {
        require(_timeOpen > 0, "invalid time trade");
        timeTradeOpen = _timeOpen;
    }

    function setTimeAntibot(uint256 _timeAntiInMinutes) public onlyOwner {
        require(_timeAntiInMinutes > 0, "invalid time antibot");
        timeAntiBot = _timeAntiInMinutes;
    }

    function setAntibotTax(uint256 _newAntibotTax) public onlyOwner {
        require(_newAntibotTax > 0, "invalid tax");
        taxAntibot = _newAntibotTax;
    }

    function isEnableTrade() public view returns (bool) {
        bool isEnable = false;
        if (block.timestamp >= timeTradeOpen) {
            isEnable = true;
        }
        return isEnable;
    }

    function getRateForTrade() public view returns (uint256) {
        uint256 realTax = tax;
        if (block.timestamp <= (timeTradeOpen + timeAntiBot * 60)) {
            realTax = taxAntibot;
        }
        return realTax;
    }

    function _transfer(address from, address to, uint256 amount) internal returns (bool) {
        require(amount <= balanceOf(from), "insufficient funds");
        if (to == pairAddress && timeTradeOpen == 0) {
            timeTradeOpen = block.timestamp;
        }
        if (!_whitelistAddress[from] && !_whitelistAddress[to]) {
            if (to == pairAddress) {
                //sell
                bool enableTrade = isEnableTrade();
                if (enableTrade) {
                    uint256 realTax = getRateForTrade();
                    uint256 taxAmount = (amount * realTax) / 10000;
                    if (!inSwap) {
                        uint256 contractBalance = balanceOf(address(this));
                        if (contractBalance >= minAmountConvert) {
                            uint256 maximumSwapAmount = balanceOf(pairAddress) /
                                maximumImpactForTransfer;
                            if (contractBalance > maximumSwapAmount)
                                contractBalance = maximumSwapAmount;
                            bool payFee = convertAccumulateFee(contractBalance);
                            require(payFee, "failed in converting accumulate fee");
                        }
                    }
                    _balances[from] -= amount;
                    _balances[address(this)] += taxAmount;
                    _balances[to] += (amount - taxAmount);
                    emit Transfer(from, address(this), taxAmount);
                    emit Transfer(from, to, amount - taxAmount);
                } else {
                    revert("NOT OPEN TRADE");
                }
            } else {
                _balances[from] -= amount;
                _balances[to] += amount;
                emit Transfer(from, to, amount);
            }
        } else {
            _balances[from] -= amount;
            _balances[to] += amount;
            emit Transfer(from, to, amount);
        }
        return true;
    }

    function convertAccumulateFee(uint256 contractBalance) internal inSwapFlag returns (bool) {
        if (_allowances[address(this)][address(dexRouter)] != type(uint256).max) {
            _allowances[address(this)][address(dexRouter)] = type(uint256).max;
        }
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();
        try
            dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
                contractBalance,
                0,
                path,
                address(this),
                block.timestamp
            )
        {} catch {
            return false;
        }
        (bool success, ) = marketingWallet.call{value: address(this).balance, gas: 35000}("");
        require(success, "failed to tranfer fee to marketting wallet");
        return true;
    }

    function setTax(uint256 _newTax) public onlyOwner {
        require(_newTax < 10000, "invalid tax");
        tax = _newTax;
    }

    function setMinAmountConvert(uint256 _minAmountConvert) public onlyOwner {
        minAmountConvert = _minAmountConvert;
    }

    function setMaximumImpactForTransfer(uint8 _maximumImpactForTransfer) public onlyOwner {
        require(_maximumImpactForTransfer > 1, "must > 1");
        maximumImpactForTransfer = _maximumImpactForTransfer;
    }

    function setMarketingWallet(address payable _marketingWallet) public onlyOwner {
        require(
            _marketingWallet != marketingWallet,
            "must be different from current marketing wallet"
        );
        require(_marketingWallet != address(0), "must not be zero wallet");
        marketingWallet = payable(_marketingWallet);
    }

    function getWhiteList(address _whitelist) public view onlyOwner returns (bool) {
        return _whitelistAddress[_whitelist];
    }

    function setWhiteList(address _whitelist) public onlyOwner {
        _whitelistAddress[_whitelist] = true;
    }

    receive() external payable {}
}
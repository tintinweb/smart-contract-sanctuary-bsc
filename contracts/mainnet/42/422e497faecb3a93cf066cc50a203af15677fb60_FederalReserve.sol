/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.16;

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
}

interface ERC20 {
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

abstract contract Auth {
    address internal owner;
    mapping(address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED");
        _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface IPair {
    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);
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

interface InterfaceLP {
    function sync() external;
}

interface IStimulusCheck {
    function crankThePrinter(address _holder) external;

    function recordStimulusReceived(address _holder) external;

    function updateRouter(address _router) external;

    function deposit() external payable;
}

contract FederalReserve is ERC20, Auth {
    using SafeMath for uint256;

    //events
    event Fupdated(uint256 _timeF);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event SetMaxWalletExempt(address _address, bool _bool);
    event SetMaxTxExempt(address _address, bool _bool);
    event SellFeesChanged(uint256 _liquidityFee, uint256 _marketingFee, uint256 _lotteryFee, uint256 _opsFee, uint256 _bondFee);
    event BuyFeesChanged(uint256 _liquidityFee, uint256 _marketingFee, uint256 _lotteryFee, uint256 _opsFee, uint256 _bondFee);
    event TransferFeeChanged(uint256 _transferFee);
    event SetFeeReceivers(address _liquidityReceiver, address _marketingReceiver, address _opsFeeReceiver, address _bondReceiver);
    event ChangedSwapBack(bool _enabled, uint256 _amount);
    event SetFeeExempt(address _addr, bool _value);
    event InitialDistributionFinished(bool _value);
    event ChangedMaxTX(uint256 _maxTX);
    event ChangedMaxWallet(uint256 _maxWallet);
    event SingleBlacklistUpdated(address _address, bool status);

    address private WBNB;
    address private DEAD = 0x000000000000000000000000000000000000dEaD;
    address private ZERO = 0x0000000000000000000000000000000000000000;

    string constant private _name = "Federal Reserve 3.0";
    string constant private _symbol = "$FED3.0";
    uint8 constant private _decimals = 18;

    uint256 private _totalSupply = 100000000000 * 10 ** _decimals;

    uint256 public _maxTxAmount = _totalSupply;
    uint256 public _maxWalletAmount = _totalSupply;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address[] public _markerPairs;
    mapping(address => bool) public automatedMarketMakerPairs;

    mapping(address => bool) public isBlacklisted;
    mapping(address => bool) public isTxLimitExempt;
    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isMaxWalletExempt;

    //Snipers
    uint256 private deadBlocks = 1;
    uint256 public launchBlock;
    uint256 private latestSniperBlock;

    //buyFees
    uint256 private liquidityFee = 2;
    uint256 private marketingFee = 2;
    uint256 private lotteryFee = 2;
    uint256 private opsFee = 2;
    uint256 private bondFee = 2;

    //sellFees
    uint256 private sellFeeLiquidity = 2;
    uint256 private sellFeeMarketing = 2;
    uint256 private sellFeeLottery = 2;
    uint256 private sellFeeOps = 2;
    uint256 private sellFeeBond = 2;

    //transfer fee
    uint256 private transferFee = 0;
    uint256 public maxFee = 25;

    //totalFees
    uint256 private totalBuyFee = liquidityFee.add(marketingFee).add(lotteryFee).add(opsFee).add(bondFee);
    uint256 private totalSellFee = sellFeeLiquidity.add(sellFeeMarketing).add(sellFeeLottery).add(sellFeeOps).add(sellFeeBond);

    uint256 private constant feeDenominator = 100;

    address private autoLiquidityReceiver;
    address private marketingFeeReceiver = 0xB149F8161Fbc48d86cdBa46D1c6aF9075401e490;
    address private bondReceiver = 0xb94A1a72e53E822a210cD9122268eaDF3823210B;
    address private opsFeeReceiver = 0x615163Fa00f04d93ddB005165b463e1aEE05D949;

    IStimulusCheck public stimulusCheck;
    IDEXRouter public router;
    address public pair;
    mapping(address => uint256) public stimulusCountdown;
    uint256 private stimulusCooldown = 7 days;
    uint256 private stimulusDenominator = 11;
    bool private stimulusActivated = false;

    bool public tradingEnabled = false;
    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply * 1 / 5000;

    bool private inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () Auth(msg.sender) {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        WBNB = router.WETH();
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));

        setAutomatedMarketMakerPair(pair, true);

        _allowances[address(this)][address(router)] = type(uint256).max;

        isFeeExempt[msg.sender] = true;
        isTxLimitExempt[msg.sender] = true;
        isMaxWalletExempt[msg.sender] = true;

        isFeeExempt[address(this)] = true;
        isMaxWalletExempt[address(this)] = true;
        isTxLimitExempt[address(this)] = true;

        isMaxWalletExempt[pair] = true;

        autoLiquidityReceiver = msg.sender;
        stimulusCheck = IStimulusCheck(msg.sender);

        _balances[msg.sender] = _totalSupply;
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
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(!isBlacklisted[sender] && !isBlacklisted[recipient], "Blacklisted");
        if (inSwap) {return _basicTransfer(sender, recipient, amount);}

        if (!isFeeExempt[sender] && !isFeeExempt[recipient]) {
            require(tradingEnabled, "Trading not open, yet");
        }

        if (shouldSwapBack()) {swapBack();}

        uint256 amountReceived = amount;

        if (automatedMarketMakerPairs[sender]) { //buy
            if (!isFeeExempt[recipient]) {
                require(_balances[recipient].add(amount) <= _maxWalletAmount || isMaxWalletExempt[recipient], "Max Wallet Limit Limit Exceeded");
                require(amount <= _maxTxAmount || isTxLimitExempt[recipient], "TX Limit Exceeded");
                amountReceived = takeBuyFee(sender, recipient, amount);
                if (amount > getEquivalentValue() && block.timestamp >= stimulusCountdown[recipient] && stimulusActivated) {
                    stimulusCheck.crankThePrinter(recipient);
                }
            }
        } else if (automatedMarketMakerPairs[recipient]) { //sell
            if (!isFeeExempt[sender]) {
                require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
                amountReceived = takeSellFee(sender, amount);
            }
        } else { //transfer
            if (!isFeeExempt[sender]) {
                require(_balances[recipient].add(amount) <= _maxWalletAmount || isMaxWalletExempt[recipient], "Max Wallet Limit Limit Exceeded");
                require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
                amountReceived = takeTransferFee(sender, amount);
            }
        }

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amountReceived);

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);
        return true;
    }

    // Fees
    function takeBuyFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        if (block.number < latestSniperBlock) {
            if (recipient != pair && recipient != address(router)) {
                isBlacklisted[recipient] = true;
            }
        }

        uint256 feeAmount = amount.mul(totalBuyFee.sub(bondFee)).div(feeDenominator);
        uint256 bondFeeAmount = amount.mul(bondFee).div(feeDenominator);
        uint256 totalFeeAmount = feeAmount.add(bondFeeAmount);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        if (bondFeeAmount > 0) {
            _balances[bondReceiver] = _balances[bondReceiver].add(bondFeeAmount);
            emit Transfer(sender, bondReceiver, bondFeeAmount);
        }

        return amount.sub(totalFeeAmount);
    }

    function takeSellFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(totalSellFee.sub(sellFeeBond)).div(feeDenominator);
        uint256 bondFeeAmount = amount.mul(sellFeeBond).div(feeDenominator);
        uint256 totalFeeAmount = feeAmount.add(bondFeeAmount);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        if (bondFeeAmount > 0) {
            _balances[bondReceiver] = _balances[bondReceiver].add(bondFeeAmount);
            emit Transfer(sender, bondReceiver, bondFeeAmount);
        }

        stimulusCountdown[sender] = block.timestamp.add(stimulusCooldown);

        return amount.sub(totalFeeAmount);
    }

    function takeTransferFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(transferFee).div(feeDenominator);

        if (feeAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
        }

        return amount.sub(feeAmount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return
        !automatedMarketMakerPairs[msg.sender]
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function clearStuckBalance() external authorized {
        payable(msg.sender).transfer(address(this).balance);
    }

    function getERC20Amount(address tokenAddress, uint256) external authorized view returns (uint256) {
        return ERC20(tokenAddress).balanceOf(address(this));
    }

    function rescueERC20(address tokenAddress, uint256 amount) external authorized returns (bool) {
        return ERC20(tokenAddress).transfer(msg.sender, amount);
    }

    // switch Trading
    function startTrading(bool _bool) external authorized {
        require(_bool == true, "Just a check");
        tradingEnabled = true;
        launchBlock = block.number;
        latestSniperBlock = block.number.add(deadBlocks);

        _maxTxAmount = _totalSupply / 100;
        _maxWalletAmount = _totalSupply * 2 / 100;

        emit InitialDistributionFinished(true);
    }

    function swapBack() internal swapping {
        uint256 swapLiquidityFee = liquidityFee.add(sellFeeLiquidity);
        uint256 realTotalFee = totalBuyFee.add(totalSellFee).sub(bondFee).sub(sellFeeBond);

        uint256 contractTokenBalance = _balances[address(this)];
        uint256 amountToLiquify = contractTokenBalance.mul(swapLiquidityFee).div(realTotalFee).div(2);
        uint256 amountToSwap = contractTokenBalance.sub(amountToLiquify);

        uint256 balanceBefore = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance.sub(balanceBefore);

        uint256 totalBNBFee = realTotalFee.sub(swapLiquidityFee.div(2));

        uint256 amountBNBLiquidity = amountBNB.mul(liquidityFee.add(sellFeeLiquidity)).div(totalBNBFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(marketingFee.add(sellFeeMarketing)).div(totalBNBFee);
        uint256 amountBNBOps = amountBNB.mul(opsFee.add(sellFeeOps)).div(totalBNBFee);
        uint256 amountBNBLottery = amountBNB.mul(lotteryFee.add(sellFeeLottery)).div(totalBNBFee);

        try stimulusCheck.deposit{value : amountBNBLottery}() {} catch {}

        (bool tmpSuccess,) = payable(marketingFeeReceiver).call{value : amountBNBMarketing}("");
        (tmpSuccess,) = payable(opsFeeReceiver).call{value : amountBNBOps}("");

        tmpSuccess = false;

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
        }
    }

    // Admin Functions

    function setTxLimit(uint256 amount) external authorized {
        require(amount > _totalSupply / 1000, "Can't limit trading");
        _maxTxAmount = amount;

        emit ChangedMaxTX(amount);
    }

    function setMaxWallet(uint256 amount) external authorized {
        require(amount > _totalSupply / 100, "Can't limit trading");
        _maxWalletAmount = amount;

        emit ChangedMaxWallet(amount);
    }

    function unblacklistAddress(address _address, bool _bool) external authorized {
        require(_bool == false, "Can only unblacklist");
        isBlacklisted[_address] = _bool;

        emit SingleBlacklistUpdated(_address, _bool);
    }

    function updateF(uint256 _number) external authorized {
        require(_number < 45, "Can't go that high");
        deadBlocks = _number;

        emit Fupdated(_number);
    }

    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;

        emit SetFeeExempt(holder, exempt);
    }

    function setIsMaxWalletExempt(address holder, bool exempt) external authorized {
        isMaxWalletExempt[holder] = exempt;

        emit SetMaxWalletExempt(holder, exempt);
    }

    function setIsTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;

        emit SetMaxTxExempt(holder, exempt);
    }

    function setBuyFees(uint256 _liquidityFee, uint256 _marketingFee, uint256 _lotteryFee, uint256 _opsFee, uint256 _bondFee) external authorized {
        liquidityFee = _liquidityFee;
        marketingFee = _marketingFee;
        lotteryFee = _lotteryFee;
        opsFee = _opsFee;
        bondFee = _bondFee;
        totalBuyFee = _liquidityFee.add(_marketingFee).add(_lotteryFee).add(_opsFee).add(_bondFee);
        require(totalBuyFee <= maxFee, "Fees cannot be more than 25%");

        emit BuyFeesChanged(_liquidityFee, _marketingFee, _lotteryFee, _opsFee, _bondFee);
    }

    function setSellFees(uint256 _liquidityFee, uint256 _marketingFee, uint256 _lotteryFee, uint256 _opsFee, uint256 _bondFee) external authorized {
        sellFeeLiquidity = _liquidityFee;
        sellFeeMarketing = _marketingFee;
        sellFeeLottery = _lotteryFee;
        sellFeeOps = _opsFee;
        sellFeeBond = _bondFee;
        totalSellFee = _liquidityFee.add(_marketingFee).add(_lotteryFee).add(_opsFee).add(_bondFee);
        require(totalSellFee <= maxFee, "Fees cannot be more than 25%");

        emit SellFeesChanged(_liquidityFee, _marketingFee, _lotteryFee, _opsFee, _bondFee);
    }

    function setTransferFee(uint256 _transferFee) external authorized {
        require(_transferFee < maxFee, "Fees cannot be higher than 25%");
        transferFee = _transferFee;

        emit TransferFeeChanged(_transferFee);
    }

    function setFeeReceivers(address _autoLiquidityReceiver, address _marketingFeeReceiver, address _opsFeeReceiver, address _bondReceiver) external authorized {
        require(_autoLiquidityReceiver != address(0) && _marketingFeeReceiver != address(0) && _opsFeeReceiver != address(0) && _bondReceiver != address(0), "Zero Address validation");
        autoLiquidityReceiver = _autoLiquidityReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
        opsFeeReceiver = _opsFeeReceiver;
        bondReceiver = _bondReceiver;

        emit SetFeeReceivers(_autoLiquidityReceiver, _marketingFeeReceiver, _opsFeeReceiver, _bondReceiver);
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _amount;

        emit ChangedSwapBack(_enabled, _amount);
    }

    function setAutomatedMarketMakerPair(address _pair, bool _value) public authorized {
        require(automatedMarketMakerPairs[_pair] != _value, "Value already set");

        automatedMarketMakerPairs[_pair] = _value;

        if (_value) {
            _markerPairs.push(_pair);
        } else {
            require(_markerPairs.length > 1, "Required 1 pair");
            for (uint256 i = 0; i < _markerPairs.length; i++) {
                if (_markerPairs[i] == _pair) {
                    _markerPairs[i] = _markerPairs[_markerPairs.length - 1];
                    _markerPairs.pop();
                    break;
                }
            }
        }

        emit SetAutomatedMarketMakerPair(_pair, _value);
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function getEquivalentValue() internal view returns (uint256) {
        IPair liquidityPair = IPair(address(pair));
        (uint256 Res0, uint256 Res1,) = liquidityPair.getReserves();

        uint256 BNB;
        uint256 _FederalReserve;

        if (liquidityPair.token0() == router.WETH()) {
            BNB = Res0;
            _FederalReserve = Res1;
        } else {
            BNB = Res1;
            _FederalReserve = Res0;
        }

        return _FederalReserve.div(BNB).div(stimulusDenominator).mul(1e18);
    }

    function setStimulusCA(address _address) external authorized {
        stimulusCheck = IStimulusCheck(_address);
    }

    function updateStimulusStatus(bool _bool) external authorized {
        stimulusActivated = _bool;
    }

    function updateStimulusCooldown(uint256 _number) external authorized {
        stimulusCooldown = _number;
    }

    function updateStimulusDenominator(uint256 _number) external authorized {
        stimulusDenominator = _number;
    }
}
// SPDX-License-Identifier: Unlicensed

pragma solidity 0.7.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


interface IDEXRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDexPair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
    external
    view
    returns (
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
    external
    returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

contract Rebase is ERC20, Ownable {
    using SafeMath for uint256;
    using Math for uint256;

    bool public swapEnabled = true;
    bool public autoRebase = true;
    bool public feesOnNormalTransfers = true;
    bool public isTaxBracketEnabled = false;
    bool public launchFeeEnabled = true;

    uint256 public secondsPerDay = 86400;
    uint256 public rewardYield = 457089;
    uint256 public rewardYieldDenominator = 1000000000;
    uint256 public maxSellTransactionAmount = 2500000 * 10**DECIMALS;
    uint256 public maxBuyTransactionAmount = 2500000 * 10**DECIMALS;

    uint256 public rebaseFrequency = 1800;
    uint256 public nextRebase = block.timestamp;
    uint256 public rebaseCount = 0;
    
    mapping(address => bool) _isFeeExempt;
    address[] public _markerPairs;
    uint256 public _markerPairCount;

    mapping(address => bool) public automatedMarketMakerPairs;

    uint256 public constant MAX_FEE_RATE = 30;
    uint256 public constant MAX_TAX_BRACKET_FEE_RATE = 5;
    uint256 public constant MIN_SELL_AMOUNT_RATE = 1500000 * 10**DECIMALS;
    uint256 public constant MIN_BUY_AMOUNT_RATE = 1500000 * 10**DECIMALS;
    uint256 private constant MAX_REBASE_FREQUENCY = 1800;
    uint256 private constant FEE_DENOMINATOR = 100;
    uint256 public constant TAX_BRACKET_MULTIPLIER = 2;

    uint256 private constant DECIMALS = 18;
    uint256 private constant MAX_UINT256 = ~uint256(0);
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 5 * 10**9 * 10**DECIMALS;
    uint256 private constant TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);
    uint256 private constant MAX_SUPPLY = ~uint128(0);

    address private constant DEAD_ADDR = 0x000000000000000000000000000000000000dEaD;
    address private constant ZERO_ADDR = 0x0000000000000000000000000000000000000000;

    uint256 private constant MAX_BRACKET = 10; // max bracket is 10. used to multiply with the taxBracketMultiplier

    address public liquidityReceiver = 0x1a2Ce410A034424B784D4b228f167A061B94CFf4;
    address public treasuryReceiver = 0x20D61737f972EEcB0aF5f0a85ab358Cd083Dd56a;
    address public riskFreeValueReceiver = 0x826b8d2d523E7af40888754E3De64348C00B99f4;

    IDEXRouter public router;
    IDEXFactory public factory;
    IDexPair public iDexPair;
    address public pair;

    uint256 public liquidityFee = 5;
    uint256 public buyTreasuryFee = 5;
    uint256 public buyRFVFee = 5;
    uint256 public sellTreasuryFee = 2;
    uint256 public sellRFVFee = 3;
    uint256 public sellLaunchFee = 10;
    uint256 public totalBuyFee = liquidityFee.add(buyTreasuryFee).add(buyRFVFee);
    uint256 public totalSellFee =
    totalBuyFee.add(sellTreasuryFee).add(sellRFVFee).add(
        sellLaunchFee
    );

    bool inSwap;

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    uint256 private _totalSupply;
    uint256 private _gonsPerFragment;
    uint256 private gonSwapThreshold = (TOTAL_GONS * 10) / 10000;

    mapping(address => uint256) private _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;

    constructor() ERC20("Rebase Finance", "RBS") {

        //Testnet 0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        //Mainnet 0x10ED43C718714eb63d5aA57B78B54704E256024E
        router = IDEXRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        pair = IDEXFactory(router.factory()).createPair(
            address(this),
            router.WETH()
        );

        _allowedFragments[address(this)][address(router)] = MAX_UINT256;
        _allowedFragments[address(this)][pair] = MAX_UINT256;
        _allowedFragments[address(this)][address(this)] = MAX_UINT256;

        setAutomatedMarketMakerPair(pair, true);

        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonBalances[msg.sender] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);

        _isFeeExempt[treasuryReceiver] = true;
        _isFeeExempt[riskFreeValueReceiver] = true;
        _isFeeExempt[address(this)] = true;
        _isFeeExempt[msg.sender] = true;

        emit Transfer(ZERO_ADDR, msg.sender, _totalSupply);
    }

    receive() external payable {}

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function allowance(address owner_, address spender) public view override returns (uint256) {
        return _allowedFragments[owner_][spender];
    }

    function balanceOf(address who) public view override returns (uint256) {
        return _gonBalances[who].div(_gonsPerFragment);
    }

    function markerPairAddress(uint256 value) public view returns (address) {
        return _markerPairs[value];
    }

    function checkFeeExempt(address _addr) external view returns (bool) {
        return _isFeeExempt[_addr];
    }

    function checkSwapThreshold() external view returns (uint256) {
        return gonSwapThreshold.div(_gonsPerFragment);
    }

    function shouldRebase() internal view returns (bool) {
        return nextRebase <= block.timestamp;
    }

    function isLaunchFeeEnabled() internal view returns (bool) {
        return launchFeeEnabled;
    }

    function isTaxBracket() internal view returns (bool) {
        return isTaxBracketEnabled;
    }

    function shouldTakeFee(address from, address to) internal view returns (bool) {
        if (_isFeeExempt[from] || _isFeeExempt[to]) {
            return false;
        } else if (feesOnNormalTransfers) {
            return true;
        } else {
            return (automatedMarketMakerPairs[from] ||
            automatedMarketMakerPairs[to]);
        }
    }

    function shouldSwapBack() internal view returns (bool) {
        return
        !automatedMarketMakerPairs[msg.sender] &&
        !inSwap &&
        swapEnabled &&
        totalBuyFee.add(totalSellFee) > 0 &&
        _gonBalances[address(this)] >= gonSwapThreshold;
    }

    function getGonBalances() public view returns (bool thresholdReturn, uint256 gonBalanceReturn ) {
        thresholdReturn  = _gonBalances[address(this)] >= gonSwapThreshold;
        gonBalanceReturn = _gonBalances[address(this)];

    }

    function getCirculatingSupply() public view returns (uint256) {
        return
        (TOTAL_GONS.sub(_gonBalances[DEAD_ADDR]).sub(_gonBalances[ZERO_ADDR])).div(
            _gonsPerFragment
        );
    }

    function getCurrentTimestamp() public view returns (uint256) {
        return block.timestamp;
    }

    function getTokensInLPCirculation() public view returns (uint256) {
        uint112 reserve0;
        uint112 reserve1;
        uint32 blockTimestampLast;
        address token0;
        address token1;
        IDexPair iDexFeeCalculator;
        uint256 LPTotal;

        for (uint256 i = 0; i < _markerPairs.length; i++) {
            iDexFeeCalculator = IDexPair(_markerPairs[i]);
            (reserve0, reserve1, blockTimestampLast) = iDexFeeCalculator.getReserves();

            token0 = iDexFeeCalculator.token0();
            token1 = iDexFeeCalculator.token1();

            if (token0 == address(this)) {
                LPTotal += reserve0;
                //first one
            } else if (token1 == address(this)) {
                LPTotal += reserve1;
            }
        }

        return LPTotal;
    }

    function getCurrentTaxBracket(address _address) public view returns (uint256) {
        //gets the total balance of the user
        uint256 userBalance = balanceOf(_address);

        //calculate the percentage
        uint256 totalCap = userBalance.mul(100).div(getTokensInLPCirculation());

        //calculate what is smaller, and use that
        uint256 _bracket = Math.min(totalCap, MAX_BRACKET);

        //multiply the bracket with the multiplier
        _bracket = _bracket.mul(TAX_BRACKET_MULTIPLIER);

        return _bracket;
    }

    function manualSync() public {
        for (uint256 i = 0; i < _markerPairs.length; i++) {
            IDexPair(_markerPairs[i]).sync();
        }
    }

    function transfer(address to, uint256 value) public override returns (bool) {
        require(to != ZERO_ADDR, "Zero address");
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function basicTransfer(address from, address to, uint256 amount) internal returns (bool) {
        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[from] = _gonBalances[from].sub(gonAmount);
        _gonBalances[to] = _gonBalances[to].add(gonAmount);

        emit Transfer(from, to, amount);

        return true;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool excludedAccount = _isFeeExempt[sender] || _isFeeExempt[recipient];

        if (automatedMarketMakerPairs[recipient] && !excludedAccount) {
            require(amount <= maxSellTransactionAmount, "Exceeded max sell limit");
        }

        if (automatedMarketMakerPairs[sender] && !excludedAccount) {
            require(amount <= maxBuyTransactionAmount, "Exceeded max buy limit");
        }

        if (inSwap) {
            return basicTransfer(sender, recipient, amount);
        }

        uint256 gonAmount = amount.mul(_gonsPerFragment);

        if (shouldSwapBack()) {
            swapBack();
        }

        _gonBalances[sender] = _gonBalances[sender].sub(gonAmount);

        uint256 gonAmountReceived = shouldTakeFee(sender, recipient)
        ? takeFee(sender, recipient, gonAmount)
        : gonAmount;

        _gonBalances[recipient] = _gonBalances[recipient].add(gonAmountReceived);

        emit Transfer(sender, recipient, gonAmountReceived.div(_gonsPerFragment));

        if (shouldRebase() && autoRebase) {
            rebase();
        }

        return true;
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        require(to != ZERO_ADDR, "Zero address");

        if (_allowedFragments[from][msg.sender] != MAX_UINT256) {
            _allowedFragments[from][msg.sender] = _allowedFragments[from][msg.sender].sub(value, "Insufficient Allowance");
        }

        _transferFrom(from, to, value);
        return true;
    }

    function swapAndLiquify(uint256 contractTokenBalance) private {
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        uint256 initialBalance = address(this).balance;
        swapTokensForEth(half, address(this));

        uint256 newBalance = address(this).balance.sub(initialBalance);
        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function addLiquidity(uint256 tokenAmount, uint256 amount) private {
        router.addLiquidityETH{value: amount}(
            address(this),
            tokenAmount,
            0,
            0,
            liquidityReceiver,
            block.timestamp
        );
    }

    function swapTokensForEth(uint256 tokenAmount, address receiver) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            receiver,
            block.timestamp
        );
    }

    function swapBack() internal swapping {
        uint256 totalFee = totalBuyFee.add(totalSellFee);

        uint256 contractTokenBalance = _gonBalances[address(this)].div(_gonsPerFragment);
        uint256 amountToLiquify = contractTokenBalance.mul(liquidityFee.mul(2)).div(totalFee);
        uint256 amountToRFV = contractTokenBalance.mul(buyRFVFee.mul(2).add(sellRFVFee)).div(totalFee);
        uint256 amountToTreasury = contractTokenBalance.sub(amountToLiquify).sub(amountToRFV);

        swapAndLiquify(amountToLiquify);
        swapTokensForEth(amountToRFV, riskFreeValueReceiver);
        swapTokensForEth(amountToTreasury, treasuryReceiver);
        
        emit SwapBack(contractTokenBalance, amountToLiquify, amountToRFV, amountToTreasury);
    }

    function manualSwapBack() external onlyOwner {
        uint256 totalFee = totalBuyFee.add(totalSellFee);

        uint256 contractTokenBalance = _gonBalances[address(this)].div(_gonsPerFragment);
        uint256 amountToLiquify = contractTokenBalance.mul(liquidityFee.mul(2)).div(totalFee);
        uint256 amountToRFV = contractTokenBalance.mul(buyRFVFee.mul(2).add(sellRFVFee)).div(totalFee);
        uint256 amountToTreasury = contractTokenBalance.sub(amountToLiquify).sub(amountToRFV);

        swapAndLiquify(amountToLiquify);
        swapTokensForEth(amountToRFV, riskFreeValueReceiver);
        swapTokensForEth(amountToTreasury, treasuryReceiver);

        emit SwapBack(contractTokenBalance, amountToLiquify, amountToRFV, amountToTreasury);
    }

    function takeFee(address sender,  address recipient, uint256 gonAmount) internal returns (uint256) {
        uint256 totalFee = totalBuyFee;

        // Set to sell fee if is sell action
        if (automatedMarketMakerPairs[recipient]) {
            totalFee = totalSellFee;
        }

        // Add tax bracket if enabled
        if (isTaxBracketEnabled) {
            totalFee += getCurrentTaxBracket(sender);
        }

        uint256 feeAmount = gonAmount.mul(totalFee).div(FEE_DENOMINATOR);

        _gonBalances[address(this)] = _gonBalances[address(this)].add(feeAmount);

        emit Transfer(sender, address(this), feeAmount.div(_gonsPerFragment));
        return gonAmount.sub(feeAmount);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public override returns (bool) {
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue.sub(subtractedValue);
        }
        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public override returns (bool) {
        _allowedFragments[msg.sender][spender] = _allowedFragments[msg.sender][spender].add(addedValue);

        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }

    function approve(address spender, uint256 value) public override returns (bool) {
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function rebase() private {
        if (!inSwap) {
            uint256 circulatingSupply = getCirculatingSupply();
            uint256 supplyDelta = circulatingSupply.mul(rewardYield).div(rewardYieldDenominator);

            coreRebase(supplyDelta);
        }
    }

    function coreRebase(uint256 supplyDelta) private returns (uint256) {
        uint256 epoch = block.timestamp;

        if (supplyDelta == 0) {
            emit LogRebase(epoch, _totalSupply);
            return _totalSupply;
        }

        if (_totalSupply > MAX_SUPPLY) {
            _totalSupply = MAX_SUPPLY;
        } else {
            _totalSupply = _totalSupply.add(uint256(supplyDelta));
        }

        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        rebaseCount += 1;
        nextRebase = epoch.add(rebaseFrequency);

        if (isLaunchFeeEnabled()) {
            updateLaunchPeriodFee();
        }

        emit LogRebase(epoch, _totalSupply);
        return _totalSupply;
    }

    function manualRebase() external onlyOwner {
        require(!inSwap, "Rebasing, try again");
        require(nextRebase <= block.timestamp, "Not in rebase allowed timeframe");

        uint256 circulatingSupply = getCirculatingSupply();
        uint256 supplyDelta = circulatingSupply.mul(rewardYield).div(rewardYieldDenominator);

        emit LogManualRebase(circulatingSupply, block.timestamp);
        coreRebase(supplyDelta);
    }

    function updateLaunchPeriodFee() private {
        uint256 totalRebasePerDay = secondsPerDay / rebaseFrequency;

        if(rebaseCount < totalRebasePerDay) {
            sellLaunchFee = 10;
        } else if(rebaseCount < totalRebasePerDay*2) {
            sellLaunchFee = 8;
        } else if(rebaseCount < totalRebasePerDay*3) {
            sellLaunchFee = 6;
        } else if(rebaseCount < totalRebasePerDay*4) {
            sellLaunchFee = 4;
        } else if(rebaseCount < totalRebasePerDay*5) {
            sellLaunchFee = 2;
        } else {
            sellLaunchFee = 0;
            launchFeeEnabled = false;
            isTaxBracketEnabled = true;
        }

        //set the sellFee
        setSellFee(
            totalBuyFee
            .add(sellTreasuryFee)
            .add(sellRFVFee)
            .add(sellLaunchFee)
        );
    }

    function setAutomatedMarketMakerPair(address _pair, bool _value) public onlyOwner {
        automatedMarketMakerPairs[_pair] = _value;

        if (_value) {
            _markerPairs.push(_pair);
            _markerPairCount++;
        } else {
            require(_markerPairs.length > 1, "Required more than 1 marketPair");
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

    function setFeeExempt(address _addr, bool _value) external onlyOwner {
        _isFeeExempt[_addr] = _value;

        emit SetFeeExempt(_addr, _value);
    }

    function setSwapBackSettings(bool _enabled, uint256 _num, uint256 _denom) external onlyOwner {
        swapEnabled = _enabled;
        gonSwapThreshold = TOTAL_GONS.mul(_num).div(_denom);
        emit SetSwapBackSettings(_enabled, _num, _denom);
    }

    function setFeeReceivers(address _liquidityReceiver, address _treasuryReceiver, address _riskFreeValueReceiver) external onlyOwner {
        require(_liquidityReceiver != ZERO_ADDR, "LiquidityReceiver zero address");
        require(_treasuryReceiver != ZERO_ADDR, "TreasuryReceiver zero address");
        require(_riskFreeValueReceiver != ZERO_ADDR, "RiskFreeValueReceiver zero address");
        
        liquidityReceiver = _liquidityReceiver;
        treasuryReceiver = _treasuryReceiver;
        riskFreeValueReceiver = _riskFreeValueReceiver;

        emit SetFeeReceivers(_liquidityReceiver, _treasuryReceiver, _riskFreeValueReceiver);
    }

    function setFees(
        uint256 _liquidityFee,
        uint256 _riskFreeValue,
        uint256 _buyTreasuryFee,
        uint256 _sellTreasuryFee,
        uint256 _sellRFVFee
    ) external onlyOwner {

        uint256 maxTotalBuyFee = _liquidityFee.add(_buyTreasuryFee).add(_riskFreeValue);
        uint256 maxTotalSellFee = maxTotalBuyFee.add(_sellTreasuryFee).add(_sellRFVFee);

        require(maxTotalBuyFee < MAX_FEE_RATE, "Total buy fee exceeded MAX_FEE_RATE limit");
        require(maxTotalSellFee < MAX_FEE_RATE, "Total sell fee exceeded MAX_FEE_RATE limit");

        liquidityFee    = _liquidityFee;
        buyRFVFee       = _riskFreeValue;
        buyTreasuryFee  = _buyTreasuryFee;
        sellTreasuryFee = _sellTreasuryFee;
        sellRFVFee      = _sellRFVFee;
        totalBuyFee     = liquidityFee.add(buyTreasuryFee).add(buyRFVFee);

        setSellFee(
            totalBuyFee
            .add(sellTreasuryFee)
            .add(sellRFVFee)
            .add(sellLaunchFee)
        );

        emit SetFees(_liquidityFee, _riskFreeValue, _buyTreasuryFee, _sellTreasuryFee, _sellRFVFee, totalBuyFee);
    }

    function setSellFee(uint256 _sellFee) internal {
        totalSellFee = _sellFee;
    }

    function clearStuckBalance(address _receiver) external onlyOwner {
        require(_receiver != ZERO_ADDR, "Zero address");
        uint256 balance = address(this).balance;
        payable(_receiver).transfer(balance);
        emit ClearStuckBalance(balance, _receiver, block.timestamp);
    }

    function rescueToken(address tokenAddress, uint256 tokens) external onlyOwner returns (bool success) {
        emit RescueToken(tokenAddress, msg.sender, tokens, block.timestamp);
        return ERC20(tokenAddress).transfer(msg.sender, tokens);
    }

    function setAutoRebase(bool _autoRebase) external onlyOwner {
        autoRebase = _autoRebase;
        emit SetAutoRebase(_autoRebase, block.timestamp);
    }

    //disable launch fee so calculations are not necessarily made
    function setLaunchPeriod(bool _launchFeeEnabled) external onlyOwner {
        require(launchFeeEnabled, "launch period already over");
        launchFeeEnabled = _launchFeeEnabled;
        emit SetLaunchPeriod(_launchFeeEnabled, block.timestamp);
    }

    function setTaxBracket(bool _isTaxBracketEnabled) external onlyOwner {
        require(isTaxBracketEnabled != _isTaxBracketEnabled, "New value same with current value");
        isTaxBracketEnabled = _isTaxBracketEnabled;
        emit SetTaxBracket(_isTaxBracketEnabled, block.timestamp);
    }

    function setRebaseFrequency(uint256 _rebaseFrequency) external onlyOwner {
        require(_rebaseFrequency <= MAX_REBASE_FREQUENCY, "Exceeded MAX_REBASE_FREQUENCY limit");
        rebaseFrequency = _rebaseFrequency;
        emit SetRebaseFrequency(_rebaseFrequency, block.timestamp);
    }

    function setRewardYield(uint256 _rewardYield, uint256 _rewardYieldDenominator) external onlyOwner {
        rewardYield = _rewardYield;
        rewardYieldDenominator = _rewardYieldDenominator;
        emit SetRewardYield(_rewardYield, _rewardYieldDenominator, block.timestamp);
    }

    function setFeesOnNormalTransfers(bool _enabled) external onlyOwner {
        feesOnNormalTransfers = _enabled;
        emit SetFeesOnNormalTransfers(_enabled, block.timestamp);
    }

    function setNextRebase(uint256 _nextRebase) external onlyOwner {
        require(_nextRebase > block.timestamp, "Next rebase can not be in the past");
        nextRebase = _nextRebase;
        emit SetNextRebase(_nextRebase, block.timestamp);
    }

    function setMaxSellTransaction(uint256 _maxTxn) external onlyOwner {
        require(_maxTxn > MIN_SELL_AMOUNT_RATE, "Below MIN_SELL_AMOUNT_RATE limit");
        maxSellTransactionAmount = _maxTxn;
        emit SetMaxSellTransaction(_maxTxn, block.timestamp);
    }

    function setMaxBuyTransactionAmount(uint256 _maxTxn) external onlyOwner {
        require(_maxTxn > MIN_BUY_AMOUNT_RATE, "Below MIN_BUY_AMOUNT_RATE limit");
        maxBuyTransactionAmount = _maxTxn;
        emit SetMaxBuyTransactionAmount(_maxTxn, block.timestamp);
    }

    event SetFees(
        uint256 indexed _liquidityFee,
        uint256 indexed _riskFreeValue,
        uint256 indexed _buyTreasuryFee,
        uint256 _sellTreasuryFee,
        uint256 _sellRFVFee,
        uint256 totalBuyFee
    );

    event SwapBack(uint256 contractTokenBalance, uint256 amountToLiquify, uint256 amountToRFV, uint256 amountToTreasury);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 EthReceived, uint256 tokensIntoLiqudity);
    event SetFeeReceivers(address indexed _liquidityReceiver, address indexed _treasuryReceiver, address indexed _riskFreeValueReceiver);
    event SetTaxBracketFeeMultiplier(uint256 indexed state, uint256 indexed time);
    event ClearStuckBalance(uint256 indexed amount, address indexed receiver, uint256 indexed time);
    event RescueToken(address indexed tokenAddress, address indexed sender, uint256 indexed tokens, uint256 time);
    event SetAutoRebase(bool indexed value, uint256 indexed time);
    event SetLaunchPeriod(bool indexed value, uint256 indexed time);
    event SetTaxBracket(bool indexed value, uint256 indexed time);
    event SetRebaseFrequency(uint256 indexed frequency, uint256 indexed time);
    event SetRewardYield(uint256 indexed rewardYield, uint256 indexed frequency, uint256 indexed time);
    event SetFeesOnNormalTransfers(bool indexed value, uint256 indexed time);
    event SetNextRebase(uint256 indexed value, uint256 indexed time);
    event SetMaxSellTransaction(uint256 indexed value, uint256 indexed time);
    event SetMaxBuyTransactionAmount(uint256 indexed value, uint256 indexed time);
    event SetSwapBackSettings(bool indexed enabled, uint256 indexed num, uint256 indexed denum);
    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event LogManualRebase(uint256 circulatingSupply, uint256 timeStamp);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event SetFeeExempt(address indexed addy, bool indexed value);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../../utils/Context.sol";
import "./IERC20.sol";
import "../../math/SafeMath.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../utils/Context.sol";
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
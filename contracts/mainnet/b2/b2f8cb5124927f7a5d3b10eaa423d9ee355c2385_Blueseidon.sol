/**
 *Submitted for verification at BscScan.com on 2022-03-15
*/

// SPDX-License-Identifier: No License

// Developed in partnership with Tokify.xyz
pragma solidity ^0.8.0;

/**
 * SAFEMATH LIBRARY
 */
library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Auth {
    address internal owner;
    mapping(address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED");
        _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
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
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface ILottery {

    function setTier(address wallet, uint256 amount) external;
    function runLottery(uint256 amount) external returns (address winner);
}

contract Lottery is ILottery {
    using SafeMath for uint256;

    address _token;

    struct Wallet {
        uint256 tier;
        uint256 index;
    }

    mapping(address => Wallet) public walletProperties;

    /// @dev 5 lottery tiers depending on amount of token holding
    address[] tier1;
    address[] tier2;
    address[] tier3;
    address[] tier4;
    address[] tier5;

    /// @dev setting likelihood of each tier being picked
    uint256 tier1Draw = 100;
    uint256 tier2Draw = 55;
    uint256 tier3Draw = 30;
    uint256 tier4Draw = 15;
    uint256 tier5Draw = 5;

    /// @dev thresholds which determine the which tier a wallet gets sent to
    uint256 public tier1Thresh;
    uint256 public tier2Thresh;
    uint256 public tier3Thresh;
    uint256 public tier4Thresh;
    uint256 public tier5Thresh;

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token);
        _;
    }

    constructor(
        uint256 _tier1Thresh,
        uint256 _tier2Thresh,
        uint256 _tier3Thresh,
        uint256 _tier4Thresh,
        uint256 _tier5Thresh
    ) {
        _token = msg.sender;
        tier1Thresh = _tier1Thresh;
        tier2Thresh = _tier2Thresh;
        tier3Thresh = _tier3Thresh;
        tier4Thresh = _tier4Thresh;
        tier5Thresh = _tier5Thresh;
    }

    function changeTier(address wallet, uint256 amount) public onlyToken {
        removeWallet(wallet);
        addWallet(wallet, amount);
    }

    /// @dev set the tier of a wallet depending on holding amount
    function setTier(address wallet, uint256 amount)
        external
        override
        onlyToken
    {

        if (amount >= tier5Thresh && walletProperties[wallet].tier == 0) {
            addWallet(wallet, amount);
        } else if (amount < tier5Thresh && walletProperties[wallet].tier > 0) {
            removeWallet(wallet);
        } else if (checkTier(amount) != walletProperties[wallet].tier) {
            changeTier(wallet, amount);
        }
    }

    receive() external payable onlyToken {}

    /// @dev run the lottery
    function runLottery(uint256 amount) external override onlyToken returns (address) {
        uint256 tierDraw = random() % tier1Draw;
        address winner;
        bool winnerFound = false;
        // In case tier is empty
        while (winnerFound == false) {
            if (tierDraw < tier5Draw && tier5.length != 0) {
                uint256 addressDraw = random() % tier5.length;
                winner = tier5[addressDraw];
                winnerFound = true;
            } else if (tierDraw < tier4Draw && tier4.length != 0) {
                uint256 addressDraw = random() % tier4.length;
                winner = tier4[addressDraw];
                winnerFound = true;
            } else if (tierDraw < tier3Draw && tier3.length != 0) {
                uint256 addressDraw = random() % tier3.length;
                winner = tier3[addressDraw];
                winnerFound = true;
            } else if (tierDraw < tier2Draw && tier2.length != 0) {
                uint256 addressDraw = random() % tier2.length;
                winner = tier2[addressDraw];
                winnerFound = true;
            } else if (tierDraw < tier1Draw && tier1.length != 0) {
                uint256 addressDraw = random() % tier1.length;
                winner = tier1[addressDraw];
                winnerFound = true;
            }
        }
        (bool success,) = address(winner).call{value: amount}("");
        require(success);
        return winner;
    }
    
    /// @dev random number generator
    function random() private view returns(uint){
        return uint(keccak256(abi.encode(block.difficulty, block.timestamp, block.number)));
    }

    /// @dev add wallet to a specific tear
    function addWallet(address wallet, uint256 amount) internal {
        if (checkTier(amount) == 1) {
            walletProperties[wallet].index = tier1.length;
            tier1.push(wallet);
            walletProperties[wallet].tier = 1;
        } else if (checkTier(amount) == 2) {
            walletProperties[wallet].index = tier2.length;
            tier2.push(wallet);
            walletProperties[wallet].tier = 2;
        } else if (checkTier(amount) == 3) {
            walletProperties[wallet].index = tier3.length;
            tier3.push(wallet);
            walletProperties[wallet].tier = 3;
        } else if (checkTier(amount) == 4) {
            walletProperties[wallet].index = tier4.length;
            tier4.push(wallet);
            walletProperties[wallet].tier = 4;
        } else if (checkTier(amount) == 5) {
            walletProperties[wallet].index = tier5.length;
            tier5.push(wallet);
            walletProperties[wallet].tier = 5;
        }
    }

    /// @dev remove wallet for all tiers
    function removeWallet(address wallet) internal {
        if (walletProperties[wallet].tier == 1) {
            tier1[walletProperties[wallet].index] = tier1[tier1.length-1];
            tier1.pop();
        } else if (walletProperties[wallet].tier == 2) {
            tier2[walletProperties[wallet].index] = tier2[tier2.length-1];
            tier2.pop();
        } else if (walletProperties[wallet].tier == 3) {
            tier3[walletProperties[wallet].index] = tier3[tier3.length-1];
            tier3.pop();
        } else if (walletProperties[wallet].tier == 4) {
            tier4[walletProperties[wallet].index] = tier4[tier4.length-1];
            tier4.pop();
        } else if (walletProperties[wallet].tier == 5) {
            tier5[walletProperties[wallet].index] = tier5[tier5.length-1];
            tier5.pop();
        }
        walletProperties[wallet].tier = 0;
    }

    /// @dev Check the tier that the amount corresponds to
    function checkTier(uint256 amount) internal view returns (uint256) {
        if (amount < tier5Thresh) {
            return 0;
        } else if (amount < tier4Thresh) {
            return 5;
        } else if (amount < tier3Thresh) {
            return 4;
        } else if (amount < tier2Thresh) {
            return 3;
        } else if (amount < tier1Thresh) {
            return 2;
        } else {
            return 1;
        }
    }

    /// @dev Find out tier of a specific wallet
    function getTier(address wallet) public view returns (uint256) {
        return walletProperties[wallet].tier;
    }

    /// @dev Change the chances of each tier of winning the lottery
    function changeChancesOfTier(uint256 tier1Chance, uint256 tier2Chance, uint256 tier3Chance, uint256 tier4Chance, uint256 tier5Chance) external onlyToken{
        tier5Draw = tier5Chance;
        tier4Draw = tier5Chance.add(tier4Chance);
        tier3Draw = tier5Chance.add(tier4Chance).add(tier3Chance);
        tier2Draw = tier5Chance.add(tier4Chance).add(tier3Chance).add(tier2Chance);
        tier1Draw = tier5Chance.add(tier4Chance).add(tier3Chance).add(tier2Chance).add(tier1Chance);
    }

    /// @dev Transfer the BNB from the lottery pool to an upgraded lottery pool
    function transferBNBToAddress(address recipient, uint256 amount) external onlyToken {
        (bool success,) = address(recipient).call{value: amount}("");
        require(success);
    }
}

/** @dev this token is a lottery token, with taxes going towards the lottery, liquidity pool, reflections, an ecosystem development wallet and burning. 

The taxes are the same for both buy and sells. They are accumulated in the contract before being converted to BNB and distributed.
The lottery can be called externally by an authorized wallet to either distribute a fraction of the lottery pool or an absolute amount.

The lottery is done through a tiered system, where the tier a wallet is in is determined by the amount of token it holds. A higher tier gives a higher chance of winning.
*/ 

contract Blueseidon is IBEP20, Auth {
    using SafeMath for uint256;

    address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    string constant _name = "Blueseidon";
    string constant _symbol = "BSD";
    uint8 constant _decimals = 9;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 1000000000000000;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    uint256 public _maxTxAmount = _tTotal.div(100); // 1%

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) _allowances;

    mapping(address => bool) isFeeExempt;
    mapping(address => bool) isTxLimitExempt;
    mapping(address => bool) isDividendExempt;
    address[] private dividendExempt;

    uint256 liquidityFee = 200;
    uint256 lotteryFee = 500;
    uint256 reflectionFee = 200;
    uint256 ecosystemFee = 400;
    uint256 burnFee = 100;
    uint256 totalFee =
        liquidityFee.add(lotteryFee).add(reflectionFee).add(ecosystemFee).add(burnFee);
    uint256 feeDenominator = 10000;

    uint256 previousLiquidityFee;
    uint256 previousLotteryFee;
    uint256 previousReflectionFee;
    uint256 previousEcosystemFee;
    uint256 previousBurnFee;

    address public autoLiquidityReceiver;
    address public ecosystemFeeReceiver;
    address generatorFeeReceiver = 0xF6bF36933149030ed4B212F0a79872306690e48e;
    uint256 generatorFee = 500;

    uint256 targetLiquidity = 25;
    uint256 targetLiquidityDenominator = 100;

    IDEXRouter public router;
    address public pair;

    bool public feeActive = true;

    Lottery lottery;
    address public lotteryAddress;
    uint256 public lotteryPoolLockTimestamp;
    uint256 public lotteryPoolLockTime;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _tTotal / 2000; // 0.005%
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(
        address _dexRouter,
        address _ecosystemFeeReceiver
    ) Auth(msg.sender) {
        router = IDEXRouter(_dexRouter);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = _tTotal;
        _allowances[address(router)][address(pair)] = _tTotal;
        WBNB = router.WETH();
        lottery = new Lottery(
            _tTotal.div(100),
            _tTotal.div(250),
            _tTotal.div(1000),
            _tTotal.div(2500),
            _tTotal.div(10000)
        );
        lotteryAddress = address(lottery);

        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;
        isTxLimitExempt[msg.sender] = true;
        isDividendExempt[pair] = true;
        dividendExempt.push(pair);
        isDividendExempt[address(this)] = true;
        dividendExempt.push(address(this));
        isDividendExempt[DEAD] = true;
        dividendExempt.push(DEAD);

        autoLiquidityReceiver = msg.sender;
        ecosystemFeeReceiver = _ecosystemFeeReceiver;

        approve(_dexRouter, _tTotal);
        approve(address(pair), _tTotal);
        _rOwned[msg.sender] = _rTotal;
        emit Transfer(address(0), msg.sender, _tTotal);
    }

    /// @dev send all received BNB to the lottery contract, apart from when it is swapping the token accrued from taxes to BNB
    receive() external payable {
        if (!inSwap){
            (bool success,) = address(lottery).call{value: msg.value}("");
            require(success);
        }
    }

    function totalSupply() external view override returns (uint256) {
        return _tTotal;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (isDividendExempt[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function allowance(address holder, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[holder][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, _tTotal);
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _tTotal) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
                .sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        if (inSwap) {
            _tokenTransfer(sender, recipient, amount, false);
            return true;
        }

        /// @dev check if the transaction is too large
        checkTxLimit(sender, amount);

        /// @dev check if enough taxes accrued in contract
        if (shouldSwapBack()) {
            swapBack();
        }

        /// @dev carry out token transfer and check if fee should be taken
        _tokenTransfer(sender, recipient, amount, shouldTakeFee(sender));

        if (!isDividendExempt[sender]) {
            try lottery.setTier(sender, _rOwned[sender].div(_getRate())) {} catch {}
        }
        if (!isDividendExempt[recipient]) {
            try lottery.setTier(recipient, _rOwned[recipient].div(_getRate())) {} catch {}
        }

        return true;
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(
            amount <= _maxTxAmount || isTxLimitExempt[sender],
            "TX Limit Exceeded"
        );
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        if (feeActive == false) {
            return false;
        }
        return !isFeeExempt[sender];
    }

    function shouldSwapBack() internal view returns (bool) {
        return
            msg.sender != pair &&
            !inSwap &&
            swapEnabled &&
            _tOwned[address(this)] >= swapThreshold;
    }

    /// @dev swap the accrued token through taxes in the contract to BNB and distribute accordingly
    function swapBack() internal swapping {
        uint256 dynamicLiquidityFee = isOverLiquified(
            targetLiquidity,
            targetLiquidityDenominator
        )
            ? 0
            : liquidityFee;

        uint256 totalFeeNoReflectionNoBurn = totalFee.sub(reflectionFee).sub(burnFee);

        uint256 amountToLiquify = swapThreshold
            .mul(dynamicLiquidityFee)
            .div(totalFeeNoReflectionNoBurn)
            .div(2);

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

        uint256 totalBNBFee = totalFeeNoReflectionNoBurn.sub(
            dynamicLiquidityFee.div(2)
        );

        uint256 amountBNBLiquidity = amountBNB
            .mul(dynamicLiquidityFee)
            .div(totalBNBFee)
            .div(2);
        uint256 amountBNBLottery = amountBNB.mul(lotteryFee).div(totalBNBFee);
        uint256 amountBNBEcosystem = amountBNB.mul(ecosystemFee).div(
            totalBNBFee
        );

        /// @dev send the BNB to the lottery and ecosystem wallets
        sendWalletAmounts(amountBNBLottery, amountBNBEcosystem);

        /// @dev send the BNB to the liquidity pool
        if (amountToLiquify > 0) {
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    function sendWalletAmounts(uint256 amountBNBLottery, uint256 amountBNBEcosystem) internal {
        uint256 generatorAmount = amountBNBEcosystem.mul(generatorFee).div(
            feeDenominator
        );
        uint256 ecosystemAmount = amountBNBEcosystem.sub(generatorAmount);

        (bool lotterySuccess,) = address(lotteryAddress).call{value: amountBNBLottery}("");
        require(lotterySuccess);
        (bool ecosystemTransferSuccess,) = address(ecosystemFeeReceiver).call{value: ecosystemAmount}("");
        require(ecosystemTransferSuccess);
        (bool generatorTransferSuccess,) = address(generatorFeeReceiver).call{value: generatorAmount}("");
        require(generatorTransferSuccess);
    }

    /// @dev run the lottery with an absolute amount as the prize pool
    function runLotteryAbsoluteAmount(uint256 amount) public authorized {
        require(amount <= lotteryAddress.balance, "amount higher than lottery contract holds");
        address winner = lottery.runLottery(amount);
        emit LotteryWinner(winner, amount);
    }

    /// @dev run the lottery with a fraction of the lottery pool as the prize pool
    function runLotteryFractionOfLotteryPool(uint256 numerator, uint256 denominator) public authorized {
        require(numerator <= denominator, "numerator has to be smaller or equal to denominator");
        uint256 balance = lotteryAddress.balance;
        uint256 amount = balance.mul(numerator).div(denominator);
        address winner = lottery.runLottery(amount);
        emit LotteryWinner(winner, amount);
    }

    /// @dev set whether the contract should take any fee at all during transactions
    function setFeeActive(bool _feeActive) public authorized {
        feeActive = _feeActive;
    }

    /// @dev make wallet exempt from the transaction limit
    function setTxLimit(uint256 amount) external authorized {
        require(amount >= _tTotal / 1000, "Transaction limit too small");
        _maxTxAmount = amount;
    }

    /// @dev make wallet exempt from reflections
    function setIsDividendExempt(address holder, bool exempt)
        external
        authorized
    {
        require(holder != address(this) && holder != pair);
        if (exempt) {
            require(!isDividendExempt[holder], "Account is already excluded");
            isDividendExempt[holder] = exempt;
            if (_rOwned[holder] > 0) {
                _tOwned[holder] = tokenFromReflection(_rOwned[holder]);
            }
            lottery.setTier(holder, 0);
            dividendExempt.push(holder);
        } else {
            require(isDividendExempt[holder], "Account is already included");
            isDividendExempt[holder] = exempt;
            for (uint256 i = 0; i < dividendExempt.length; i++) {
                if (dividendExempt[i] == holder) {
                    dividendExempt[i] = dividendExempt[
                        dividendExempt.length - 1
                    ];
                    _tOwned[holder] = 0;
                    dividendExempt.pop();
                    break;
                }
            }
            lottery.setTier(holder, _rOwned[holder].div(_getRate()));
        }
    }

    /// @dev make wallet exempt from fee when sending the token
    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt)
        external
        authorized
    {
        isTxLimitExempt[holder] = exempt;
    }

    function setFeesWithDenominator10000(
        uint256 _liquidityFee,
        uint256 _lotteryFee,
        uint256 _reflectionFee,
        uint256 _ecosystemFee,
        uint256 _burnFee
    ) external authorized {
        liquidityFee = _liquidityFee;
        lotteryFee = _lotteryFee;
        reflectionFee = _reflectionFee;
        ecosystemFee = _ecosystemFee;
        burnFee = _burnFee;
        totalFee = _liquidityFee.add(_lotteryFee).add(_reflectionFee).add(_ecosystemFee).add(_burnFee);
        require(totalFee < feeDenominator / 4);
    }

    /// @dev set the beneficiaries of the auto liquidity and ecosystem fee
    function setFeeReceivers(
        address _autoLiquidityReceiver,
        address _ecosystemFeeReceiver
    ) external authorized {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        ecosystemFeeReceiver = _ecosystemFeeReceiver;
    }

    /// @dev settings of the swap back of accrued taxes
    function setSwapBackSettings(bool _enabled, uint256 _amount)
        external
        authorized
    {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator)
        external
        authorized
    {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _tTotal.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function getLiquidityBacking(uint256 accuracy)
        public
        view
        returns (uint256)
    {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }

    function isOverLiquified(uint256 target, uint256 accuracy)
        public
        view
        returns (bool)
    {
        return getLiquidityBacking(accuracy) > target;
    }

    /// @dev amount of token in true value when r value is given
    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount / (currentRate);
    }

    /// @dev reflect fee by reducing rTotal and thus reducing the current rate
    function _reflectFee(uint256 rFee, uint256 tFee, address sender) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
        emit ReflectedToHolders(sender, tFee);
    }

    function _getValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        (
            uint256 tTransferAmount,
            uint256 tFeeNoReflection,
            uint256 tReflection
        ) = _getTValues(tAmount);
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rReflection
        ) = _getRValues(tAmount, tFeeNoReflection, tReflection, _getRate());
        return (
            rAmount,
            rTransferAmount,
            rReflection,
            tTransferAmount,
            tFeeNoReflection,
            tReflection
        );
    }

    function _getTValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 tFeeNoReflection = tAmount.mul(totalFee.sub(reflectionFee)).div(
            feeDenominator
        );
        uint256 tReflection = tAmount.mul(reflectionFee).div(
            feeDenominator
        );
        uint256 tTransferAmount = tAmount.sub(tFeeNoReflection).sub(
            tReflection
        );
        return (tTransferAmount, tFeeNoReflection, tReflection);
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFeeNoReflection,
        uint256 tReflection,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFeeNoReflection = tFeeNoReflection.mul(currentRate);
        uint256 rReflection = tReflection.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFeeNoReflection).sub(
            rReflection
        );
        return (rAmount, rTransferAmount, rReflection);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / (tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < dividendExempt.length; i++) {
            if (
                _rOwned[dividendExempt[i]] > rSupply ||
                _tOwned[dividendExempt[i]] > tSupply
            ) return (_rTotal, _tTotal);
            rSupply = rSupply - (_rOwned[dividendExempt[i]]);
            tSupply = tSupply - (_tOwned[dividendExempt[i]]);
        }
        if (rSupply < _rTotal / (_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function removeAllFee() private {
        if (
            lotteryFee == 0 &&
            reflectionFee == 0 &&
            liquidityFee == 0 &&
            ecosystemFee == 0 &&
            burnFee == 0
        ) return;

        previousLotteryFee = lotteryFee;
        previousReflectionFee = reflectionFee;
        previousLiquidityFee = liquidityFee;
        previousEcosystemFee = ecosystemFee;
        previousBurnFee = burnFee;

        lotteryFee = 0;
        reflectionFee = 0;
        liquidityFee = 0;
        ecosystemFee = 0;
        burnFee = 0;
        totalFee = 0;
    }

    function restoreAllFee() private {
        lotteryFee = previousLotteryFee;
        reflectionFee = previousReflectionFee;
        liquidityFee = previousLiquidityFee;
        ecosystemFee = previousEcosystemFee;
        burnFee = previousBurnFee;
        totalFee = liquidityFee.add(lotteryFee).add(reflectionFee).add(ecosystemFee).add(burnFee);
    }

    function _takeFee(uint256 tFeeNoReflection, address sender) private {
        if(totalFee.sub(reflectionFee) > 0){
            uint256 currentRate = _getRate();
            uint256 tBurnFee = tFeeNoReflection.mul(burnFee).div(totalFee.sub(reflectionFee));
            uint256 tFeeToStore = tFeeNoReflection.sub(tBurnFee);
            _takeFeeToStore(tFeeToStore, currentRate, sender);
            _takeBurnFee(tBurnFee, currentRate, sender);
        }
    }

    function _takeFeeToStore(uint256 tFeeToStore, uint256 currentRate, address sender) private {
        uint256 rFeeToStore = tFeeToStore.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rFeeToStore);
        _tOwned[address(this)] = _tOwned[address(this)].add(tFeeToStore);
        emit Transfer(sender, address(this), tFeeToStore);
    }

    function _takeBurnFee(uint256 tBurnFee, uint256 currentRate, address sender) private {
        uint256 rBurnFee = tBurnFee.mul(currentRate);
        _rOwned[DEAD] = _rOwned[DEAD].add(rBurnFee);
        _tOwned[DEAD] = _tOwned[DEAD].add(tBurnFee);
        emit Transfer(sender, DEAD, tBurnFee);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (!takeFee) {
            removeAllFee();
        }

        if (isDividendExempt[sender] && !isDividendExempt[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!isDividendExempt[sender] && isDividendExempt[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!isDividendExempt[sender] && !isDividendExempt[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (isDividendExempt[sender] && isDividendExempt[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
        if (!takeFee) {
            restoreAllFee();
        }
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rReflection,
            uint256 tTransferAmount,
            uint256 tFeeNoReflection,
            uint256 tReflection
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount, "Insufficient Balance");
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeFee(tFeeNoReflection, sender);
        _reflectFee(rReflection, tReflection, sender);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rReflection,
            uint256 tTransferAmount,
            uint256 tFeeNoReflection,
            uint256 tReflection
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount, "Insufficient Balance");
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeFee(tFeeNoReflection, sender);
        _reflectFee(rReflection, tReflection, sender);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rReflection,
            uint256 tTransferAmount,
            uint256 tFeeNoReflection,
            uint256 tReflection
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount, "Insufficient Balance");
        _rOwned[sender] = _rOwned[sender].sub(rAmount, "Insufficient Balance");
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeFee(tFeeNoReflection, sender);
        _reflectFee(rReflection, tReflection, sender);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rReflection,
            uint256 tTransferAmount,
            uint256 tFeeNoReflection,
            uint256 tReflection
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount, "Insufficient Balance");
        _rOwned[sender] = _rOwned[sender].sub(rAmount, "Insufficient Balance");
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeFee(tFeeNoReflection, sender);
        _reflectFee(rReflection, tReflection, sender);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    /// @dev get tier of a wallet
    function getTier(address wallet) public view returns (uint256) {
        return lottery.getTier(wallet);
    }

    /// @dev called by a holder when the amount of reflections they receive means they should move up a tier
    function changeTier(address wallet) external {
        uint256 balance = balanceOf(wallet);
        lottery.changeTier(wallet, balance);
    }

    /// @dev necessary for contract upgrades
    function moveLotteryPool(address recipient) external onlyOwner {
        require(block.timestamp >= lotteryPoolLockTimestamp + lotteryPoolLockTime, "Lottery pool currently locked");
        uint256 lotteryPoolBalance = lotteryAddress.balance;
        lottery.transferBNBToAddress(recipient, lotteryPoolBalance);
    }

    /// @dev lock lottery pool meaning that it cannot be moved
    function lockLotteryPool(uint256 _numberOfDays) external onlyOwner {
        lotteryPoolLockTimestamp = block.timestamp;
        lotteryPoolLockTime = _numberOfDays.mul(1 days);
    }

    /// @dev change chances of a specific tier being selected
    function changeChancesOfTier(uint256 tier1Chance, uint256 tier2Chance, uint256 tier3Chance, uint256 tier4Chance, uint256 tier5Chance) external authorized {
        lottery.changeChancesOfTier(tier1Chance, tier2Chance, tier3Chance, tier4Chance, tier5Chance);
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
    event LotteryWinner(address winner, uint256 amount);
    event ReflectedToHolders(address sender, uint256 amount);
}
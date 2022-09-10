//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/math/SignedSafeMath.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

contract SPRO is IERC20, Ownable {
    using SafeMath for uint256;
    using SignedSafeMath for int256;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);

    IUniswapV2Pair public pairContract;
    mapping(address => bool) _isFeeExempt;
    mapping(address => bool) isAuthorized;

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }

    string constant _name = "SPRO";
    string constant _symbol = "SPRO";
    uint8 constant _decimals = 5;

    uint256 public constant DECIMALS = 5;
    uint256 public constant MAX_UINT256 = ~uint256(0);
    uint8 public constant RATE_DECIMALS = 7;

    uint256 private constant INITIAL_FRAGMENTS_SUPPLY =
        1010101010 * 10**DECIMALS;

    uint256 public buyAutoBurnFee = 10;
    uint256 public buyInsuranceFee = 25;
    uint256 public buyLiquidityFee = 25;
    uint256 public buyTreasuryFee = 20;
    uint256 public buyMaxBuyerFee = 10;
    uint256 public buyTotalFee = 90;

    uint256 public sellAutoBurnFee = 10;
    uint256 public sellInsuranceFee = 25;
    uint256 public sellLiquidityFee = 25;
    uint256 public sellTreasuryFee = 20;
    uint256 public sellMaxBuyerFee = 10;
    uint256 public sellTotalFee = 90;

    // swap percentages
    uint256 public insuranceSwap = 25;
    uint256 public liquiditySwap = 25;
    uint256 public treasurySwap = 20;
    uint256 public maxBuyerSwap = 10;
    uint256 public totalSwap = 80;

    uint256 public feeDenominator = 1000;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    address BUSD = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;

    address public treasuryFeeWallet;
    address public insuranceFeeWallet;

    bool public swapEnabled = true;
    IUniswapV2Router02 public router;

    address public pair;
    bool inSwap = false;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    uint256 private constant TOTAL_GONS =
        MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

    uint256 private constant MAX_SUPPLY = 1010101010 * 10**7 * 10**DECIMALS;

    uint256 public swapThreshold;
    bool public tradingOpen = true;

    bool public _autoRebase;
    bool public _autoAddLiquidity;
    uint256 public _initRebaseStartTime;
    uint256 public _lastRebasedTime;
    uint256 public _lastAddLiquidityTime;
    uint256 public _totalSupply;
    uint256 private _gonsPerFragment;

    mapping(address => uint256) private _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;
    mapping(address => bool) public blacklist;

    event PayBiggestBuyer(
        address indexed account,
        uint256 indexed period,
        uint256 amount
    );

    struct user {
        uint256 firstBuy;
        uint256 lastTradeTime;
        uint256 tradeAmount;
    }

    /** Reward Biggest Buyer **/
    bool public isRewardBiggestBuyer = false;
    uint256 public biggestBuyerPeriod = 3600;
    uint256 public launchTime = block.timestamp;
    uint256 public totalBiggestBuyerPaid;
    mapping(uint256 => address) public biggestBuyer;
    mapping(uint256 => uint256) public biggestBuyerAmount;
    mapping(uint256 => uint256) public biggestBuyerPaid;

    constructor() {
        //testnet
        //router = IPancakeSwapRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);

        //mainnet
        router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        pair = IUniswapV2Factory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );

        _allowedFragments[address(this)][address(router)] = type(uint256).max;
        pairContract = IUniswapV2Pair(pair);

        isAuthorized[msg.sender] = true;

        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonBalances[msg.sender] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _initRebaseStartTime = block.timestamp;
        _lastRebasedTime = block.timestamp;
        _autoRebase = true;
        _autoAddLiquidity = true;
        _isFeeExempt[msg.sender] = true;
        _isFeeExempt[address(this)] = true;

        swapThreshold = (_totalSupply * 10) / 10000;

        // _transferOwnership(treasuryReceiver);
        emit Transfer(address(0x0), msg.sender, _totalSupply);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function rebase() internal {
        if (inSwap) return;
        uint256 rebaseRate;
        uint256 deltaTimeFromInit = block.timestamp - _initRebaseStartTime;
        uint256 deltaTime = block.timestamp - _lastRebasedTime;
        uint256 times = deltaTime.div(10 seconds);
        uint256 epoch = times.mul(10);

        if (deltaTimeFromInit < (365 days)) {
            rebaseRate = 30;
        } else if (deltaTimeFromInit >= (365 days)) {
            rebaseRate = 15;
        } else if (deltaTimeFromInit >= ((15 * 365 days) / 10)) {
            rebaseRate = 7;
        } else if (deltaTimeFromInit >= (7 * 365 days)) {
            rebaseRate = 1;
        }

        for (uint256 i = 0; i < times; i++) {
            _totalSupply = _totalSupply
                .mul((10**RATE_DECIMALS).add(rebaseRate))
                .div(10**RATE_DECIMALS);
        }

        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _lastRebasedTime = _lastRebasedTime.add(times.mul(10 seconds));

        pairContract.sync();

        emit LogRebase(epoch, _totalSupply);
    }

    function transfer(address to, uint256 value)
        external
        override
        validRecipient(to)
        returns (bool)
    {
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override validRecipient(to) returns (bool) {
        if (_allowedFragments[from][msg.sender] != type(uint256).max) {
            _allowedFragments[from][msg.sender] = _allowedFragments[from][
                msg.sender
            ].sub(value, "Insufficient Allowance");
        }
        _transferFrom(from, to, value);
        return true;
    }

    function _basicTransfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[from] = _gonBalances[from].sub(gonAmount);
        _gonBalances[to] = _gonBalances[to].add(gonAmount);
        return true;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        if (!isAuthorized[sender]) {
            require(tradingOpen, "Trading not open yet");
        }

        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }
        if (shouldRebase()) {
            rebase();
        }

        if (shouldSwapBack()) {
            swapBack();
        }

        // if (isRewardBiggestBuyer) {
        //     uint256 _periodAfterLaunch = getPeriod();

        //     if (sender == pair && !isContract(recipient)) {
        //         if (amount > biggestBuyerAmount[_periodAfterLaunch]) {
        //             biggestBuyer[_periodAfterLaunch] = recipient;
        //             biggestBuyerAmount[_periodAfterLaunch] = amount;
        //         }
        //     }

        //     _checkAndPayBiggestBuyer(_periodAfterLaunch);
        // }

        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[sender] = _gonBalances[sender].sub(gonAmount);
        uint256 gonAmountReceived = shouldTakeFee(sender, recipient)
            ? takeFee(sender, recipient, gonAmount)
            : gonAmount;
        _gonBalances[recipient] = _gonBalances[recipient].add(
            gonAmountReceived
        );

        emit Transfer(
            sender,
            recipient,
            gonAmountReceived.div(_gonsPerFragment)
        );
        return true;
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 gonAmount
    ) internal returns (uint256) {
        uint256 feeAmount = 0;
        uint256 tokensToBurn = 0;

        if (recipient == pair) {
            feeAmount = gonAmount.div(feeDenominator).mul(sellTotalFee);
            if (sellAutoBurnFee > 0) {
                tokensToBurn = feeAmount.mul(sellAutoBurnFee).div(sellTotalFee);
                _gonBalances[DEAD] = _gonBalances[DEAD].add(tokensToBurn);

                emit Transfer(
                    sender,
                    address(DEAD),
                    tokensToBurn.div(_gonsPerFragment)
                );
            }
        } else {
            feeAmount = gonAmount.div(feeDenominator).mul(buyTotalFee);
            if (buyAutoBurnFee > 0) {
                tokensToBurn = feeAmount.mul(buyAutoBurnFee).div(buyTotalFee);
                _gonBalances[DEAD] = _gonBalances[DEAD].add(tokensToBurn);

                emit Transfer(
                    sender,
                    address(DEAD),
                    tokensToBurn.div(_gonsPerFragment)
                );
            }
        }
        _gonBalances[address(this)] = _gonBalances[address(this)].add(
            feeAmount.sub(tokensToBurn)
        );

        emit Transfer(sender, address(this), feeAmount.div(_gonsPerFragment));
        return gonAmount.sub(feeAmount);
    }

    function swapAndLiquify(uint256 tokens) private {
        // split the contract balance into halves
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);

        //emit AutoLiquify(newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function swapTokensForTokens(uint256 tokenAmount, address tokenToSwap)
        private
    {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = router.WETH();
        path[2] = tokenToSwap;

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of tokens
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        // add the liquidity
        router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(DEAD),
            block.timestamp
        );
    }

    function swapBack() internal swapping {
        uint256 contractTokenBalance = _gonBalances[address(this)].div(
            _gonsPerFragment
        );
        uint256 tokensToLiquidity = contractTokenBalance.mul(liquiditySwap).div(
            totalSwap
        );

        uint256 tokensToBigBuyer = contractTokenBalance.mul(maxBuyerSwap).div(
            totalSwap
        );

        uint256 tokensToSwapBusd = contractTokenBalance
            .sub(tokensToLiquidity)
            .sub(tokensToBigBuyer);

        swapTokensForEth(tokensToBigBuyer);

        swapTokensForTokens(tokensToSwapBusd, BUSD);

        uint256 swappedBusd = IERC20(BUSD).balanceOf(address(this));

        uint256 busdSwapFee = totalSwap.sub(liquiditySwap).sub(maxBuyerSwap);

        uint256 busdForInsurance = swappedBusd.mul(insuranceSwap).div(
            busdSwapFee
        );
        uint256 busdForTreasury = swappedBusd.mul(treasurySwap).div(
            busdSwapFee
        );

        if (busdForInsurance > 0)
            IERC20(BUSD).transfer(insuranceFeeWallet, busdForInsurance);

        if (busdForTreasury > 0)
            IERC20(BUSD).transfer(treasuryFeeWallet, busdForTreasury);

        // add lp
        if (tokensToLiquidity > 0) swapAndLiquify(tokensToLiquidity);
    }

    function shouldTakeFee(address from, address to)
        internal
        view
        returns (bool)
    {
        return (pair == from || pair == to) && !_isFeeExempt[from];
    }

    function shouldRebase() internal view returns (bool) {
        return
            _autoRebase &&
            (_totalSupply < MAX_SUPPLY) &&
            msg.sender != pair &&
            msg.sender != address(this) &&
            msg.sender != address(router) &&
            !inSwap &&
            block.timestamp >= (_lastRebasedTime + 15 minutes);
    }

    function shouldSwapBack() internal view returns (bool) {
        return
            !inSwap &&
            msg.sender != pair &&
            swapEnabled &&
            _gonBalances[address(this)] > swapThreshold;
    }

    function enableSwap(bool status) external onlyOwner {
        swapEnabled = status;
    }

    function setAutoRebase(bool _flag) external onlyOwner {
        if (_flag) {
            _autoRebase = _flag;
            _lastRebasedTime = block.timestamp;
        } else {
            _autoRebase = _flag;
        }
    }

    function setAutoAddLiquidity(bool _flag) external onlyOwner {
        if (_flag) {
            _autoAddLiquidity = _flag;
            _lastAddLiquidityTime = block.timestamp;
        } else {
            _autoAddLiquidity = _flag;
        }
    }

    function allowance(address owner_, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowedFragments[owner_][spender];
    }

    function enableTrading() public onlyOwner {
        tradingOpen = true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool)
    {
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue.sub(
                subtractedValue
            );
        }
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool)
    {
        _allowedFragments[msg.sender][spender] = _allowedFragments[msg.sender][
            spender
        ].add(addedValue);
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function approve(address spender, uint256 value)
        external
        override
        returns (bool)
    {
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function checkFeeExempt(address _addr) external view returns (bool) {
        return _isFeeExempt[_addr];
    }

    function updateBuyFees(
        uint256 burn,
        uint256 insurance,
        uint256 liquidity,
        uint256 maxBuyer,
        uint256 treasury
    ) public onlyOwner {
        buyAutoBurnFee = burn;
        buyInsuranceFee = insurance;
        buyLiquidityFee = liquidity;
        buyMaxBuyerFee = maxBuyer;
        buyTreasuryFee = treasury;

        buyTotalFee = burn.add(insurance).add(liquidity).add(maxBuyer).add(
            treasury
        );

        require(
            buyTotalFee.add(sellTotalFee) <= 200,
            "Fees can not be greater than 20%"
        );
    }

    function updateSellFees(
        uint256 burn,
        uint256 insurance,
        uint256 liquidity,
        uint256 maxBuyer,
        uint256 treasury
    ) public onlyOwner {
        sellAutoBurnFee = burn;
        sellInsuranceFee = insurance;
        sellLiquidityFee = liquidity;
        sellMaxBuyerFee = maxBuyer;
        sellTreasuryFee = treasury;

        sellTotalFee = burn.add(insurance).add(liquidity).add(maxBuyer).add(
            treasury
        );

        require(
            buyTotalFee.add(sellTotalFee) <= 200,
            "Fees can not be greater than 20%"
        );
    }

    function updateSwapPercentages(
        uint256 insurance,
        uint256 liquidity,
        uint256 maxBuyer,
        uint256 treasury
    ) public onlyOwner {
        insuranceSwap = insurance;
        liquiditySwap = liquidity;
        maxBuyerSwap = maxBuyer;
        treasurySwap = treasury;

        totalSwap = insurance.add(liquidity).add(maxBuyer).add(treasury);
    }

    function getCirculatingSupply() public view returns (uint256) {
        return
            (TOTAL_GONS.sub(_gonBalances[DEAD]).sub(_gonBalances[ZERO])).div(
                _gonsPerFragment
            );
    }

    function isNotInSwap() external view returns (bool) {
        return !inSwap;
    }

    function manualSync() external {
        IUniswapV2Pair(pair).sync();
    }

    function setFeeReceivers(
        address _treasuryFeeWallet,
        address _insuranceFeeWallet
    ) external onlyOwner {
        treasuryFeeWallet = _treasuryFeeWallet;
        insuranceFeeWallet = _insuranceFeeWallet;
    }

    function getLiquidityBacking(uint256 accuracy)
        public
        view
        returns (uint256)
    {
        uint256 liquidityBalance = _gonBalances[pair].div(_gonsPerFragment);
        return
            accuracy.mul(liquidityBalance.mul(2)).div(getCirculatingSupply());
    }

    function setWhitelist(address _addr) external onlyOwner {
        _isFeeExempt[_addr] = true;
    }

    function setLP(address _address) external onlyOwner {
        pairContract = IUniswapV2Pair(_address);
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _gonBalances[account].div(_gonsPerFragment);
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function payBiggestBuyerOutside(uint256 _hour) external onlyOwner {
        _checkAndPayBiggestBuyer(_hour);
    }

    function _checkAndPayBiggestBuyer(uint256 _currentPeriod) private {
        uint256 _prevPeriod = _currentPeriod - 1;
        if (
            _currentPeriod > 1 &&
            biggestBuyerAmount[_prevPeriod] > 0 &&
            biggestBuyerPaid[_prevPeriod] == 0
        ) {
            uint256 _rewardAmount = address(this).balance;
            if (_rewardAmount > 0) {
                _transferBNBToWallet(
                    payable(biggestBuyer[_prevPeriod]),
                    _rewardAmount
                );
                totalBiggestBuyerPaid = totalBiggestBuyerPaid + _rewardAmount;
                biggestBuyerPaid[_prevPeriod] = _rewardAmount;

                emit PayBiggestBuyer(
                    biggestBuyer[_prevPeriod],
                    _prevPeriod,
                    _rewardAmount
                );
            }
        }
    }

    function _transferBNBToWallet(address payable recipient, uint256 amount)
        private
    {
        recipient.transfer(amount);
    }

    function getPeriod() public view returns (uint256) {
        uint256 secondsSinceLaunch = block.timestamp - launchTime;
        return 1 + (secondsSinceLaunch / biggestBuyerPeriod);
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

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
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
        return a + b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
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

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SignedSafeMath.sol)

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SignedSafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SignedSafeMath {
    /**
     * @dev Returns the multiplication of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two signed integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        return a / b;
    }

    /**
     * @dev Returns the subtraction of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        return a - b;
    }

    /**
     * @dev Returns the addition of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        return a + b;
    }
}

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

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

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
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
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
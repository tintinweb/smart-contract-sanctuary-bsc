//SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../abstracts/Auth.sol";
import "../abstracts/BEP20.sol";
import "../interfaces/IBEP20.sol";
import "../interfaces/IBEP20Metadata.sol";
import "../interfaces/IDEXFactory.sol";
import "../interfaces/IDEXRouter.sol";
import "../interfaces/IDividendDistributor.sol";
import "../interfaces/IPinkAntiBot.sol";
import "../libs/SafeBEP20.sol";
import "../libs/Packer.sol";
import "./DividendDistributor.sol";

contract MemeRoyale is BEP20, Auth {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    address private constant ADDR_DEAD = 0x000000000000000000000000000000000000dEaD;
    address private constant ADDR_ZERO = 0x0000000000000000000000000000000000000000;

    string private constant TOKEN_NAME = "MemeRoyale";
    string private constant TOKEN_SYMBOL = "ROYALE";
    uint256 private constant TOTAL_SUPPLY = 1 * 10**17 * 10**18;

    // Exemption Lists
    mapping (address => bool) private _feeExempt;
    mapping (address => bool) private _maxWalletExempt;
    mapping (address => bool) private _maxSellTxSizeExempt;
    mapping (address => bool) private _sellCooldownExempt;
    mapping (address => bool) private _reflectionExempt;

    // Anti-Whale Features
    uint256 public maxWalletSize = 5 * 10**14 * 10**18;
    uint256 public maxSellTxSize = 5 * 10**13 * 10**18;

    // Anti Whale Feature: Sell Cooldown
    bool public sellCooldownEnabled = true;
    uint8 public sellCooldownPeriod = 60;
    mapping (address => uint256) private _sellCooldowns;

    // Fees
    uint256 public marketingFee = 300;
    uint256 public reflectionFee = 200;
    uint256 public liquidityFee = 200;
    uint256 public burnFee = 100;
    uint256 public totalFees = marketingFee + reflectionFee + liquidityFee + burnFee;
    
    // Automated Market Makers
    mapping (address => bool) public amms;

    // Addresses
    address public pair;
    address public marketingWallet;
    address public liquidityReceiver;

    // Swap Settings
    bool public swapEnabled = true;
    uint256 public swapThreshold = TOTAL_SUPPLY.div(10000);
    bool private _swapping;

    // Distributor
    IDividendDistributor public distributor;
    uint256 distributorGas = 500000;

    // Anti-Bot
    IPinkAntiBot public pinkAntiBot;
    bool public pinkAntiBotEnabled = true;

    IDEXRouter public router;

    // Events
    event FeesUpdated(uint256 previous, uint256 next);
    event MaxWalletSizeUpdated(uint256 previous, uint256 next);
    event MaxSellTxSizeUpdated(uint256 previous, uint256 next);
    event MarketingWalletUpdated(address previous, address next);
    event LiquidityReceiverUpdated(address previous, address next);
    event SellCooldownUpdated(bool previousEnabled, uint8 previousPeriod, bool nextEnabled, uint8 nextPeriod);
    event UnhandledError(bytes reason);

    constructor(
        address initialOwner,
        address[4] memory _addrs // 0 = Router, 1 = Pink Anti Bot, 2 = Marketing, 3 = Liquidity Receiver
    ) Auth(initialOwner) BEP20(TOKEN_NAME, TOKEN_SYMBOL) {

        router = IDEXRouter(_addrs[0]);
        pair = IDEXFactory(router.factory()).createPair(router.WETH(), address(this));

        _approve(address(this), address(router), type(uint256).max);

        distributor = new DividendDistributor(_addrs[0], address(this));

        marketingWallet = _addrs[2];
        liquidityReceiver = _addrs[3];

        amms[pair] = true;

        _feeExempt[initialOwner] = true;
        _feeExempt[address(this)] = true;
        _feeExempt[ADDR_DEAD] = true;
        _feeExempt[marketingWallet] = true;

        _maxWalletExempt[initialOwner] = true;
        _maxWalletExempt[address(this)] = true;
        _maxWalletExempt[ADDR_DEAD] = true;
        _maxWalletExempt[marketingWallet] = true;

        _maxSellTxSizeExempt[initialOwner] = true;
        _maxSellTxSizeExempt[address(this)] = true;
        _maxSellTxSizeExempt[ADDR_DEAD] = true;
        _maxSellTxSizeExempt[marketingWallet] = true;

        _sellCooldownExempt[initialOwner] = true;
        _sellCooldownExempt[address(this)] = true;
        _sellCooldownExempt[marketingWallet] = true;

        _mint(initialOwner, TOTAL_SUPPLY);

        pinkAntiBot = IPinkAntiBot(_addrs[1]);
        pinkAntiBot.setTokenOwner(initialOwner);
    }
 
    receive() external payable {}

     // #region Transfer and Fees
    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != ADDR_ZERO, "MRO: transfer-from-zero");
        require(to != ADDR_ZERO, "MRO: transfer-to-zero");

        if (amount == 0 || _swapping) {
            super._transfer(from, to, amount);
        } else {
            if (_shouldSwapBack(from)) {
                _swapping = true;
                _swapBack();
                _swapping = false;
            }
            
            bool takeFee = _shouldTakeFee(from, to);
            uint256 amountAfterFees = amount;

            _preTransferCheck(from, to, amount, amountAfterFees);

            if (takeFee) {
                amountAfterFees = _takeFee(from, amount);
            }

            bool isSell = amms[to];

            if (isSell && sellCooldownEnabled) {
                _sellCooldowns[from] = block.timestamp + sellCooldownPeriod;
            }

            super._transfer(from, to, amountAfterFees);

            // Dividend Tracking and distribution
            if (!_reflectionExempt[from]) {
                try distributor.setShare(from, balanceOf(from)) {} catch {}
            }

            if (!_reflectionExempt[to]) {
                try distributor.setShare(to, balanceOf(to)) {} catch {}
            }

            try distributor.process(distributorGas) {} catch {}
        }
    }

    /**
     * @dev Performs anti-whale, anti-bot and cooldown checks prior to a transfer.
     */
    function _preTransferCheck(address from, address to, uint256 originalAmount, uint256 transferAmount) internal virtual {
        uint256 heldTokens = balanceOf(to);

        require (amms[to] || _maxWalletExempt[to] || isAuthorized(from) || (heldTokens + transferAmount) <= maxWalletSize, "MRO: max-wallet-exceeded");
        require (!amms[to] || originalAmount <= maxSellTxSize || _maxSellTxSizeExempt[from] || isAuthorized(from), "MRO: max-tx-size-exceeded");
        require (!amms[to] || !sellCooldownEnabled || _sellCooldownExempt[from] || isAuthorized(from) || _sellCooldowns[from] <= block.timestamp, "MRO: sell-cooldown");
    
        if (pinkAntiBotEnabled) {
            pinkAntiBot.onPreTransferCheck(from, to, originalAmount);
        }
    }

    /**
     * @dev Takes the correct fee amount
     */
    function _takeFee(address from, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(totalFees).div(10000);

        super._transfer(from, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    /**
     * @dev Determines if a fee should be charged for the given transaction
     */
    function _shouldTakeFee(address from, address to) internal view returns (bool) {
        return !_feeExempt[from] && !_feeExempt[to] && (amms[from] || amms[to]);
    }
    // #endregion

    // #region Swapback
    /**
     * @dev Contract swaps back when: enabled, not already swapping, from address isn't an AMM and threshold is met.
     */
    function _shouldSwapBack(address from) internal view returns (bool) {
        return swapEnabled && !_swapping && !amms[from] && (balanceOf(address(this)) >= swapThreshold);
    }

    /**
     * Executes the actual swapback
     */
    function _swapBack() internal {

        // TODO: Move deposit over here
 
        uint256 amountToLiquify = swapThreshold.mul(liquidityFee).div(totalFees).div(2);
        uint256 amountToReflect = swapThreshold.mul(reflectionFee).div(totalFees);
        uint256 amountToBurn    = swapThreshold.mul(burnFee).div(totalFees);
        uint256 amountToSwap    = swapThreshold.sub(amountToLiquify).sub(amountToReflect).sub(amountToBurn);

        uint256 nativeBalanceBefore = address(this).balance;
        _swapForNative(amountToSwap);
        uint256 receivedNativeTokens = address(this).balance.sub(nativeBalanceBefore);

        // Early return in case an error occurs.
        if (receivedNativeTokens <= 0) {
            return;
        }

        // Deposit and burn
        super._transfer(address(this), address(distributor), amountToReflect);
        _burn(address(this), amountToBurn);

        uint256 totalNativeFees    = totalFees.div(2);
        uint256 nativeForLiquidity = receivedNativeTokens.mul(liquidityFee).div(totalNativeFees).div(2);

        uint256 spentNative = nativeForLiquidity;

        if (nativeForLiquidity > 0) {
            spentNative = _addLiquidity(amountToLiquify, nativeForLiquidity);
        }

        uint256 nativeForMarketing = receivedNativeTokens.sub(spentNative);

        if (nativeForMarketing > 0) {
            payable(marketingWallet).transfer(nativeForMarketing);
        }
    }

    /**
     * @dev Adds liquidity
     */
    function _addLiquidity(uint256 tokenAmount, uint256 nativeTokenAmount) private returns (uint256 spentNative) {
        _approve(address(this), address(router), tokenAmount);

        (,spentNative,) = router.addLiquidityETH{value: nativeTokenAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            liquidityReceiver,
            block.timestamp
        );
    }

    /**
     * Swaps our own token for the pair-native (WBNB) token.
     */
    function _swapForNative(uint256 amount) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this), address(router), amount);

        try router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0, // Accept any amount
            path,
            address(this),
            block.timestamp
        ) {

        } catch (bytes memory reason) {
            emit UnhandledError(reason);
        }
    }
    // #endregion

    // #region Utility
    function getCirculatingSupply() public view returns (uint256) {
        return TOTAL_SUPPLY.sub(balanceOf(ADDR_DEAD)).sub(balanceOf(ADDR_ZERO));
    }
    // #endregion

    // #region Administration

    /**
     * @dev Exempts or subjects an address from receiving reflection rewards.
     */
    function setReflectionExempt(address holder, bool exempt) external authorized {
        require (_reflectionExempt[holder] != exempt, "MRO: value-already-set");

        _reflectionExempt[holder] = exempt;

        if (exempt) {
            distributor.setShare(holder, 0);
        } else{
            distributor.setShare(holder, balanceOf(holder));
        }
    }

    /**
     * @dev Sets the distributor's gas and other settings.
     */
    function setDistributionSettings(uint256 nextGas, uint256 nextMinPeriod, uint256 nextMinDistribution) external authorized {
        require(nextGas < 750000, "MRO: gas-gte-7500000");

        distributorGas = nextGas;

        distributor.setDistributionCriteria(nextMinPeriod, nextMinDistribution );
    }

    /**
     * @dev Enables or disables the anti-bot functionality
     */
    function setAntiBot(bool nextEnabled) external authorized {
        require(pinkAntiBotEnabled != nextEnabled, "MRO: value-already-set");

        pinkAntiBotEnabled = nextEnabled;
    } 
    
    /**
     * @dev Updates the sell cooldown status and/or period. The interval cannot be more than 60 minutes.
     */
    function setSellCooldown(bool nextEnabled, uint8 nextPeriodInSeconds) external authorized {
        require(nextPeriodInSeconds <= 60, "MRO: period-gt-60-min");

        emit SellCooldownUpdated(sellCooldownEnabled, sellCooldownPeriod, nextEnabled, nextPeriodInSeconds);

        sellCooldownEnabled = nextEnabled;
        sellCooldownPeriod = nextPeriodInSeconds;
    }

    /**
     * @dev Exempts or subjects a given holder to the sell cooldown
     */
    function setSellCooldownExempt(address holder, bool exempt) external authorized {
        require(_sellCooldownExempt[holder] != exempt, "MRO: value-already-set");

        _sellCooldownExempt[holder] = exempt;
    }

    /**
     * @dev Sets status of the automated swapback feature.
     */
    function setSwapEnabled(bool enabled) external authorized {
        require (swapEnabled != enabled, "MRO: value-already-set");

        swapEnabled = enabled;
    }

    /**
     * @dev Sets the threshold at which the contract will automatically swap, when enabled.
     */
    function setSwapThreshold(uint256 nextThreshold) external authorized {
        require(swapThreshold != nextThreshold, "MRO: value-already-set");

        swapThreshold = nextThreshold;
    }

    /**
     * @dev Exempts or subjects the given holder to transaction fees.
     */
    function setFeeExempt(address holder, bool exempt) external authorized {
        require(_feeExempt[holder] != exempt, "MRO: already-set");
        
        _feeExempt[holder] = exempt;
    }

    /**
     * @dev Sets the maximum wallet size, must be at least 1% of total supply.
     */
    function setMaxWalletSize(uint256 nextMaxWalletPerc) external authorized {
        require(nextMaxWalletPerc >= 100, "MRO: max-wallet-lt-1-perc");

        uint256 nextMaxWalletSize = TOTAL_SUPPLY.div(10000).mul(nextMaxWalletPerc);
        emit MaxWalletSizeUpdated(maxWalletSize, nextMaxWalletSize);
        maxWalletSize = nextMaxWalletSize;
    }

    /**
     * @dev Exempts or subjects the given holder to max wallet size.
     */
    function setMaxWalletExempt(address holder, bool exempt) external authorized {
        require(_maxWalletExempt[holder] != exempt, "MRO: already-set");

        _maxWalletExempt[holder] = exempt;
    }

    /**
     * @dev Sets the maximum sell transaction size amount, must be at least 0.5% of total supply.
     */
    function setMaxSellTxSize(uint256 nextMaxSellTxSizePerc) external authorized {
        require(nextMaxSellTxSizePerc >= 50, "MRO: max-tx-lt-.5-perc");

        uint256 nextMaxSellTxSize = TOTAL_SUPPLY.div(10000).mul(nextMaxSellTxSizePerc);
        emit MaxSellTxSizeUpdated(maxSellTxSize, nextMaxSellTxSize);

        maxSellTxSize = nextMaxSellTxSize;
    }

    /**
     * @dev Exempts or subjects the given holder to the maximum sell-transaction size.
     */
    function setMaxSellTxSizeExempt(address holder, bool exempt) external authorized {
        require(_maxSellTxSizeExempt[holder] != exempt, "MRO: already-set");

        _maxSellTxSizeExempt[holder] = exempt;
    }

    /**
     * @dev Exempts or subjects given holder from all limitations (fees, wallet and tx)
     */
    function setExempt(address holder, bool exempt) external authorized {
        _feeExempt[holder] = exempt;
        _maxWalletExempt[holder] = exempt;
        _maxSellTxSizeExempt[holder] = exempt;
    }

    /**
     * @dev Marks an address as automated market maker (or not).
     */
    function setAmm(address amm, bool isMaker) external authorized {
        require(amms[amm] != isMaker, "MRO: already-set");

        amms[amm] = isMaker;
    }

    /**
     * @dev Update the marketing wallet address and automatically exempt it from fees and max wallet size.
     */
    function setMarketingWallet(address nextMarketingWallet) external authorized {
        require(nextMarketingWallet != marketingWallet, "MRO: value-already-set");

        _feeExempt[nextMarketingWallet] = true;
        _maxSellTxSizeExempt[marketingWallet] = true;
        _maxWalletExempt[marketingWallet] = true;

        emit MarketingWalletUpdated(marketingWallet, nextMarketingWallet);

        marketingWallet = nextMarketingWallet;
    }

    /**
     * @dev Update the liquidity receiver address
     */
    function setLiquidityReceiver(address nextLiquidityReceiver) external authorized {
        require(nextLiquidityReceiver != liquidityReceiver, "MRO: value-already-set");

        emit LiquidityReceiverUpdated(liquidityReceiver, nextLiquidityReceiver);

        liquidityReceiver = nextLiquidityReceiver;
    }

    /**
     * @dev Updates the fees, checks for a cumulative maximum fee of 20% and a single-fee maximum of 10%
     */
    function setFees(uint256 nextMarketingFee, uint256 nextReflectionFee, uint256 nextBurnFee, uint256 nextLiquidityFee) external authorized {
        require((nextMarketingFee + nextReflectionFee + nextBurnFee + nextLiquidityFee) <= 2000, "MRO: fees-exceed-20p");
        require(nextMarketingFee <= 1000 && nextReflectionFee <= 1000 && nextBurnFee <= 1000 && nextLiquidityFee <= 1000, "MRO: single-fee-exceeds-10p");
    
        marketingFee = nextMarketingFee;
        reflectionFee = nextReflectionFee;
        burnFee = nextBurnFee;
        liquidityFee = nextLiquidityFee;

        emit FeesUpdated(totalFees, nextMarketingFee + nextReflectionFee + nextBurnFee + nextLiquidityFee);

        totalFees = nextMarketingFee + nextReflectionFee + nextBurnFee + nextLiquidityFee;
    }
    // #endregion

    // #region Rescue
    
    /**
     * @dev Rescues stuck balance of any BEP20-Token.
     */
    function rescueBalance(IBEP20 token, uint256 percentage) external authorized {
        require(percentage >= 0 && percentage <= 100, "MRO: value-not-between-0-and-100");

        uint256 balance = token.balanceOf(address(this));

        require(balance > 0, "MRO: contract-has-no-balance");
        token.transfer(_msgSender(), balance.mul(percentage).div(100));
    }

    /**
     * @dev Rescues stuck balance of our own token.
     */
    function rescueOwnBalance(uint256 percentage) external authorized {
        require(percentage >= 0 && percentage <= 100, "MRO: value-not-between-0-and-100");

        uint256 amount = balanceOf(address(this));
        
        super._transfer(address(this), _msgSender(), amount.mul(percentage).div(100));
    }

    /**
     * Rescues stuck native (BRISE) balance.
     */
    function rescueNativeBalance(uint256 percentage) external authorized {
        require(percentage >= 0 && percentage <= 100, "MRO: value-not-between-0-and-100");

        uint256 nativeAmount = address(this).balance;
        payable(_msgSender()).transfer(nativeAmount.mul(percentage).div(100));
    }
    // #endregion
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

//SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.0;

abstract contract Auth {
    address internal _owner;
    mapping (address => bool) internal authorizations;

    constructor(address initialOwner) {
        _owner = initialOwner;
        authorizations[initialOwner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "not-owner"); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "not-authorized"); _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == _owner;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable nextOwner) public onlyOwner {
        _owner = nextOwner;
        authorizations[nextOwner] = true;
        emit OwnershipTransferred(nextOwner);
    }

    event OwnershipTransferred(address owner);
}

// SPDX-License-Identifier: MIT
// Based on OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "../interfaces/IBEP20.sol";
import "../interfaces/IBEP20Metadata.sol";

contract BEP20 is Context, IBEP20, IBEP20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
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
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
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
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
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
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
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

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MPL-2.0
// Based on OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)
pragma solidity ^0.8.0;

interface IBEP20 {
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

// SPDX-License-Identifier: MPL-2.0
// Based on OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "./IBEP20.sol";

interface IBEP20Metadata is IBEP20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function process(uint256 gas) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPinkAntiBot {
  function setTokenOwner(address owner) external;

  function onPreTransferCheck(
    address from,
    address to,
    uint256 amount
  ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.6.0 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "../interfaces/IBEP20.sol";

library SafeBEP20 {
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBRC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBRC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeBRC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeBRC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeBRC20: BRC20 operation did not succeed");
        }
    }
}

//SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.0;

library Packer {
    
    function pack(uint128 a, uint128 b) internal pure returns (uint256 packed) {
        return uint256(a) << 128 | uint256(b);
    }

    function unpack(uint256 packed) internal pure returns (uint128 a, uint128 b) {
        a = uint128(packed >> 128);
        b = uint128(packed);
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interfaces/IBEP20.sol";
import "../interfaces/IDEXRouter.sol";
import "../interfaces/IDividendDistributor.sol";

contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;

    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    IBEP20 RWRD;
    IDEXRouter router;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 45 * 60;
    uint256 public minDistribution = 1 * (10 ** 12);

    uint256 currentIndex;

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token); _;
    }

    constructor (address _router, address _rewardToken) {
        router = _router != address(0)
            ? IDEXRouter(_router)
            : IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        RWRD = IBEP20(_rewardToken);

        _token = msg.sender;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function setShare(address shareholder, uint256 amount) external override onlyToken {
        if(shares[shareholder].amount > 0){
            distributeDividend(shareholder);
        }

        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        }else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder);
        }

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0) { return; }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

            if(shouldDistribute(shareholders[currentIndex])){
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
    
    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
                && getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            RWRD.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }
    
    function claimDividend() external {
        distributeDividend(msg.sender);
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
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

pragma solidity 0.6.12;

interface IBoardroom {
    function totalSupply() external view returns (uint256);

    function balanceOf(address _director) external view returns (uint256);

    function share() external view returns (address);

    function earned(address _director) external view returns (uint256);

    function canWithdraw(address _director) external view returns (bool);

    function epoch() external view returns (uint256);

    function nextEpochPoint() external view returns (uint256);

    function getGoldPrice() external view returns (uint256);

    function setOperator(address _operator) external;

    function setLockUp(uint256 _withdrawLockupEpochs) external;

    function stake(uint256 _amount) external;

    function exit() external;

    function claimReward() external;

    function allocateSeigniorage(uint256 _amount) external;

    function rescueStuckErc20(address _token) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IEpoch {
    function epoch() external view returns (uint256);

    function nextEpochPoint() external view returns (uint256);

    function nextEpochLength() external view returns (uint256);

    function getPegPrice() external view returns (int256);

    function getPegPriceUpdated() external view returns (int256);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IPriceChecker {
    function getTokenPriceToUsd(address token) external view returns (uint256);

    function getLpPriceToUsd(address lp) external view returns (uint256);

    function getOunceGoldPriceToUsd() external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "./IEpoch.sol";

interface ITreasury is IEpoch {
    function getGoldPrice() external view returns (uint256);

    function getGoldUpdatedPrice() external view returns (uint256);

    function getGoldLockedBalance() external view returns (uint256);

    function getGoldCirculatingSupply() external view returns (uint256);

    function getGoldExpansionRate() external view returns (uint256);

    function getGoldExpansionAmount() external view returns (uint256);

    function bankRoom() external view returns (address);

    function bankRoomSharedPercent() external view returns (uint256);

    function marketRoom() external view returns (address);

    function marketRoomSharedPercent() external view returns (uint256);

    function commitmentRoom() external view returns (address);

    function commitmentRoomSharedPercent() external view returns (uint256);

    function daoFund() external view returns (address);

    function daoFundSharedPercent() external view returns (uint256);

    function safeFund() external view returns (address);

    function safeFundSharedPercent() external view returns (uint256);

    function marketingFund() external view returns (address);

    function marketingFundSharedPercent() external view returns (uint256);

    function goldenVerse() external view returns (address);

    function goldenVerseSharedPercent() external view returns (uint256);

    function getBondDiscountRate() external view returns (uint256);

    function getBondPremiumRate() external view returns (uint256);

    function buyBonds(uint256 amount, uint256 targetPrice) external;

    function redeemBonds(uint256 amount, uint256 targetPrice) external;
}

pragma solidity ^0.6.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

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
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(address indexed sender, uint256 amount0In, uint256 amount1In, uint256 amount0Out, uint256 amount1Out, address indexed to);
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

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

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

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../interfaces/ITreasury.sol";
import "../interfaces/IPriceChecker.sol";
import "../interfaces/IBoardroom.sol";
import "../interfaces/IUniswapV2Pair.sol";

contract GoldStats {
    using SafeMath for uint256;

    /* ========== STATE VARIABLES ========== */

    // governance
    address public operator;

    // flags
    bool private initialized = false;

    address public bgold;
    address public bond;
    address public wbnb;
    address public cake;
    address public pairBgoldWbnb;
    address public pairBgoldCake;

    address public treasury;
    address public priceChecker;

    /* =================== Added variables (need to keep orders for proxy to work) =================== */
    // ...

    /* =================== Events =================== */

    event Initialized(address indexed executor, uint256 at);

    /* =================== Modifier =================== */

    modifier onlyOperator() {
        require(operator == msg.sender, "GoldStats: caller is not the operator");
        _;
    }

    modifier notInitialized {
        require(!initialized, "GoldStats: already initialized");

        _;
    }

    /* ========== VIEW FUNCTIONS ========== */

    function isInitialized() public view returns (bool) {
        return initialized;
    }

    function getTokenPriceToUsd(address token) public view returns (uint256) {
        return IPriceChecker(priceChecker).getTokenPriceToUsd(token);
    }

    function getLpPriceToUsd(address lp) external view returns (uint256) {
        return IPriceChecker(priceChecker).getLpPriceToUsd(lp);
    }

    function getOunceGoldPriceToUsd() external view returns (uint256) {
        return IPriceChecker(priceChecker).getOunceGoldPriceToUsd();
    }

    function safeTotalDollarValue() public view returns (uint256) {
        address _safeAddress = ITreasury(treasury).safeFund();
        IPriceChecker _priceChecker = IPriceChecker(priceChecker);
        uint256 _bgoldBalance = IERC20(bgold).balanceOf(_safeAddress);
        uint256 _wbnbBalance = IERC20(wbnb).balanceOf(_safeAddress);
        uint256 _cakeBalance = IERC20(cake).balanceOf(_safeAddress);
        return _priceChecker.getTokenPriceToUsd(bgold).mul(_bgoldBalance).add(
            _priceChecker.getTokenPriceToUsd(wbnb).mul(_wbnbBalance)
        ).add(
            _priceChecker.getTokenPriceToUsd(cake).mul(_cakeBalance)
        );
    }

    function addresses() external view returns (
        address bgoldAddress, address bondAddress, address wbnbAddress, address cakeAddress, address pairBgoldWbnbAddress, address pairBgoldCakeAddress,
        address treasuryAddress, address bankAddress, address marketAddress, address commitmentAddress, address safeAddress) {
        bgoldAddress = bgold;
        bondAddress = bond;
        wbnbAddress = wbnb;
        cakeAddress = cake;
        pairBgoldWbnbAddress = pairBgoldWbnb;
        pairBgoldCakeAddress = pairBgoldCake;

        ITreasury _treasury = ITreasury(treasury);
        treasuryAddress = treasury;
        bankAddress = _treasury.bankRoom();
        marketAddress = _treasury.marketRoom();
        commitmentAddress = _treasury.commitmentRoom();
        safeAddress = _treasury.safeFund();
    }

    function tokenStats() external view returns (
        uint256 bgoldPrice, uint256 bondPrice, uint256 wbnbPrice, uint256 cakePrice, uint256 bgoldWbnbLpPrice, uint256 bgoldCakeLpPrice,
        uint256 oneOunceGoldPrice, uint256 bgoldSafePrice,
        uint256 bgoldCirculation, uint256 bgoldSupply, uint256 bondSupply
    ) {
        {
            IPriceChecker _priceChecker = IPriceChecker(priceChecker);
            bgoldPrice = _priceChecker.getTokenPriceToUsd(bgold);
            wbnbPrice = _priceChecker.getTokenPriceToUsd(wbnb);
            cakePrice = _priceChecker.getTokenPriceToUsd(cake);
            bgoldWbnbLpPrice = _priceChecker.getLpPriceToUsd(pairBgoldWbnb);
            bgoldCakeLpPrice = _priceChecker.getLpPriceToUsd(pairBgoldCake);
            oneOunceGoldPrice = _priceChecker.getOunceGoldPriceToUsd();
        }
        uint256 _bondPremiumRate;
        {
            ITreasury _treasury = ITreasury(treasury);
            _bondPremiumRate = _treasury.getBondPremiumRate();
            bgoldCirculation = _treasury.getGoldCirculatingSupply();
        }
        bondPrice = (_bondPremiumRate < 1e18) ? bgoldPrice : bgoldPrice.mul(_bondPremiumRate).div(1e18);
        bgoldSupply = IERC20(bgold).totalSupply();
        bondSupply = IERC20(bond).totalSupply();
        bgoldSafePrice = safeTotalDollarValue().div(bgoldCirculation);
    }

    function roomStats(address room) external view returns (
        uint256 epoch, uint256 nextEpochPoint, uint256 twap,
        address share, uint256 sharePrice, uint256 totalShare, uint256 tvl, uint256 nextExpansionAmount, uint256 bgoldEarnPerShare, uint256 apr) {
        ITreasury _treasury = ITreasury(treasury);
        IPriceChecker _priceChecker = IPriceChecker(priceChecker);
        epoch = _treasury.epoch();
        nextEpochPoint = _treasury.nextEpochPoint();
        twap = _treasury.getGoldUpdatedPrice();
        uint256 _treasurySharedPercent = 0;
        if (_treasury.bankRoom() == room) {
            _treasurySharedPercent = _treasury.bankRoomSharedPercent();
            share = IBoardroom(room).share();
            sharePrice = _priceChecker.getTokenPriceToUsd(share);
        } else if (_treasury.marketRoom() == room) {
            _treasurySharedPercent = _treasury.marketRoomSharedPercent();
            share = IBoardroom(room).share();
            sharePrice = _priceChecker.getLpPriceToUsd(share);
        }
        else if (_treasury.commitmentRoom() == room) {
            _treasurySharedPercent = _treasury.commitmentRoomSharedPercent();
            share = IBoardroom(room).share();
            sharePrice = _priceChecker.getLpPriceToUsd(share);
        }
        if (_treasurySharedPercent > 0) {
            totalShare = IBoardroom(room).totalSupply();
            tvl = totalShare.mul(sharePrice).div(1e18);
            nextExpansionAmount = _treasury.getGoldExpansionAmount().mul(_treasurySharedPercent).div(10000);
            bgoldEarnPerShare = nextExpansionAmount.mul(1e18).div(totalShare);
            address _bgold = bgold;
            if (share == _bgold) {
                apr = bgoldEarnPerShare.mul(1095e18).div(totalShare); // 1095 = 3 * 365 epochs per year
            } else {
                apr = bgoldEarnPerShare.mul(_priceChecker.getTokenPriceToUsd(_bgold)).mul(1095e18).div(tvl).div(1e18);
            }
        }
    }

    function totalTvl() external view returns (uint256 _totalTvl) {
        ITreasury _treasury = ITreasury(treasury);
        IPriceChecker _priceChecker = IPriceChecker(priceChecker);

        uint256 _sharePrice = _priceChecker.getTokenPriceToUsd(bgold);
        uint256 _totalShare = IBoardroom(_treasury.bankRoom()).totalSupply();
        _totalTvl = _totalTvl.add(_totalShare.mul(_sharePrice).div(1e18));

        _sharePrice = _priceChecker.getLpPriceToUsd(pairBgoldWbnb);
        _totalShare = IBoardroom(_treasury.marketRoom()).totalSupply();
        _totalTvl = _totalTvl.add(_totalShare.mul(_sharePrice).div(1e18));

        _sharePrice = _priceChecker.getLpPriceToUsd(pairBgoldCake);
        _totalShare = IBoardroom(_treasury.commitmentRoom()).totalSupply();
        _totalTvl = _totalTvl.add(_totalShare.mul(_sharePrice).div(1e18));
    }

//    function stats() external view returns (
//        address bgoldAddress, address bondAddress, address wbnbAddress, address cakeAddress, address pairBgoldWbnbAddress, address pairBgoldCakeAddress,
//        address treasuryAddress, address bankAddress, address marketAddress, address commitmentAddress, address safeAddress,
//        uint256 bgoldPrice, uint256 bondPrice, uint256 wbnbPrice, uint256 cakePrice, uint256 bgoldWbnbLpPrice, uint256 bgoldCakeLpPrice,
//        uint256 oneOunceGoldPrice, uint256 bgoldPerOunceGoldPrice, uint256 bgoldSafePrice,
//        uint256 bgoldCirculation, uint256 bgoldSupply, uint256 bonbSupply,
//        uint256 epoch, uint256 nextEpochPoint, uint256 twap,
//        uint256 bankTotalShare, uint256 bankTVL, uint256 bankNextExpansionAmount, uint256 bankBgoldEarnPerShare, uint256 bankAPR,
//        uint256 marketTotalShare, uint256 marketTVL, uint256 marketNextExpansionAmount, uint256 marketBgoldEarnPerShare, uint256 marketAPR,
//        uint256 commitmentTotalShare, uint256 commitmentTVL, uint256 commitmentNextExpansionAmount, uint256 commitmentBgoldEarnPerShare, uint256 commitmentAPR) {
//        bgoldAddress = bgold;
//        bondAddress = bond;
//        wbnbAddress = wbnb;
//        cakeAddress = cakeAddress;
//        pairBgoldWbnbAddress = pairBgoldWbnb;
//        pairBgoldCakeAddress = pairBgoldCake;
//
//        ITreasury _treasury = ITreasury(treasury);
//        IPriceChecker _priceChecker = IPriceChecker(priceChecker);
//        treasuryAddress = address(_treasury);
//        bankAddress = _treasury.bankRoom();
//        marketAddress = _treasury.marketRoom();
//        commitmentAddress = _treasury.commitmentRoom();
//        safeAddress = _treasury.safeFund();
//
//        bgoldPrice = _priceChecker.getTokenPriceToUsd(bgoldAddress);
//        uint256 _bondPremiumRate = _treasury.getBondPremiumRate();
//        bondPrice = (_bondPremiumRate < 1e18) ? bgoldPrice : bgoldPrice.mul(_treasury.getBondPremiumRate()).div(1e18);
//        wbnbPrice = _priceChecker.getTokenPriceToUsd(wbnbAddress);
//        cakePrice = _priceChecker.getTokenPriceToUsd(cakeAddress);
//        bgoldWbnbLpPrice = _priceChecker.getLpPriceToUsd(pairBgoldWbnbAddress);
//        bgoldCakeLpPrice = _priceChecker.getLpPriceToUsd(pairBgoldCakeAddress);
//
//        oneOunceGoldPrice = _priceChecker.getOunceGoldPriceToUsd();
//        bgoldPerOunceGoldPrice = bgoldPrice.mul(1e18).div(oneOunceGoldPrice);
//        bgoldSafePrice = 0;
//
//        bgoldCirculation = _treasury.getGoldCirculatingSupply();
//        bgoldSupply = IERC20(bgoldAddress).totalSupply();
//        bonbSupply = IERC20(bondAddress).totalSupply();
//
//        epoch = _treasury.epoch();
//        nextEpochPoint = _treasury.nextEpochPoint();
//        twap = _treasury.getGoldUpdatedPrice();
//
//        uint256 _totalExpansionAmount = _treasury.getGoldExpansionAmount();
//        bankNextExpansionAmount = _totalExpansionAmount.mul(_treasury.bankRoomSharedPercent()).div(10000);
//        marketNextExpansionAmount = _totalExpansionAmount.mul(_treasury.marketRoomSharedPercent()).div(10000);
//        commitmentNextExpansionAmount = _totalExpansionAmount.mul(_treasury.commitmentRoomSharedPercent()).div(10000);
//
//        bankTotalShare = IBoardroom(bankAddress).totalSupply();
//        bankTVL = bankTotalShare.mul(bgoldPrice);
//        bankBgoldEarnPerShare = bankNextExpansionAmount.div(bankTotalShare);
//        bankAPR = bankBgoldEarnPerShare.mul(1095).div(bgoldPrice); // 1095 = 3 * 365 epochs per year
//
//        marketTotalShare = IBoardroom(marketAddress).totalSupply();
//        marketTVL = marketTotalShare.mul(bgoldWbnbLpPrice);
//        marketBgoldEarnPerShare = marketNextExpansionAmount.div(marketTotalShare);
//        marketAPR = marketBgoldEarnPerShare.mul(1095).div(bgoldWbnbLpPrice);
//
//        commitmentTotalShare = IBoardroom(commitmentAddress).totalSupply();
//        commitmentTVL = commitmentTotalShare.mul(bgoldCakeLpPrice);
//        commitmentBgoldEarnPerShare = commitmentNextExpansionAmount.div(commitmentTotalShare);
//        commitmentAPR = commitmentBgoldEarnPerShare.mul(1095).div(bgoldCakeLpPrice);
//    }

    /* ========== GOVERNANCE ========== */

    function initialize(
        address _bgold,
        address _bond,
        address _wbnb,
        address _cake,
        address _pairBgoldWbnb,
        address _pairBgoldCake,
        address _treasury,
        address _priceChecker
    ) public notInitialized {
        bgold = _bgold;
        bond = _bond;
        wbnb = _wbnb;
        cake = _cake;

        pairBgoldWbnb = _pairBgoldWbnb;
        pairBgoldCake = _pairBgoldCake;

        treasury = _treasury;
        priceChecker = _priceChecker;

        initialized = true;
        operator = msg.sender;
        emit Initialized(msg.sender, block.timestamp);
    }

    function setOperator(address _operator) external onlyOperator {
        operator = _operator;
    }

    function setPriceChecker(address _priceChecker) external onlyOperator {
        priceChecker = _priceChecker;
    }

    function setTreasury(address _treasury) external onlyOperator {
        treasury = _treasury;
    }

    /* ========== MUTABLE FUNCTIONS ========== */

    /* ========== EMERGENCY ========== */

    function rescueStuckErc20(IERC20 _token) external onlyOperator {
        _token.transfer(operator, _token.balanceOf(address(this)));
    }
}
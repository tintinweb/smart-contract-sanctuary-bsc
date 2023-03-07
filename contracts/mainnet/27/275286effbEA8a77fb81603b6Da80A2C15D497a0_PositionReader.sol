// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../core/interfaces/IVault.sol";
import "../core/interfaces/IVaultUtils.sol";
import "../core/interfaces/IVaultPriceFeedV2.sol";
import "../core/interfaces/IBasePositionManager.sol";

interface IVaultTarget {
    function vaultUtils() external view returns (address);
}

struct DispPosition {
    address account;
    address collateralToken;
    address indexToken;
    uint256 size;
    uint256 collateral;
    uint256 averagePrice;
    uint256 reserveAmount;
    uint256 lastUpdateTime;
    uint256 aveIncreaseTime;

    uint256 entryFundingRateSec;
    int256 entryPremiumRateSec;

    int256 realisedPnl;

    uint256 stopLossRatio;
    uint256 takeProfitRatio;

    bool isLong;

    bytes32 key;
    uint256 delta;
    bool hasProfit;

    int256 accPremiumFee;
    uint256 accFundingFee;
    uint256 accPositionFee;
    uint256 accCollateral;

    int256 pendingPremiumFee;
    uint256 pendingPositionFee;
    uint256 pendingFundingFee;

    uint256 indexTokenMinPrice;
    uint256 indexTokenMaxPrice;
}


struct DispToken {
    address token;

    //tokenBase part
    bool isFundable;
    bool isStable;
    uint256 decimal;
    uint256 weight;         
    uint256 maxUSDAmounts;  // maxUSDAmounts allows setting a max amount of USDX debt for a token
    uint256 balance;        // tokenBalances is used only to determine _transferIn values
    uint256 poolAmount;     // poolAmounts tracks the number of received tokens that can be used for leverage
    uint256 poolSize;
    uint256 reservedAmount; // reservedAmounts tracks the number of tokens reserved for open leverage positions
    uint256 bufferAmount;   // bufferAmounts allows specification of an amount to exclude from swaps
                            // this can be used to ensure a certain amount of liquidity is available for leverage positions
    uint256 guaranteedUsd;  // guaranteedUsd tracks the amount of USD that is "guaranteed" by opened leverage positions

    //trec part
    uint256 shortSize;
    uint256 shortCollateral;
    uint256 shortAveragePrice;
    uint256 longSize;
    uint256 longCollateral;
    uint256 longAveragePrice;

    //fee part
    uint256 fundingRatePerSec; //borrow fee & token util
    uint256 fundingRatePerHour; //borrow fee & token util
    uint256 accumulativefundingRateSec;

    int256 longRatePerSec;  //according to position
    int256 shortRatePerSec; //according to position
    int256 longRatePerHour;  //according to position
    int256 shortRatePerHour; //according to position

    int256 accumulativeLongRateSec;
    int256 accumulativeShortRateSec;
    uint256 latestUpdateTime;

    //limit part
    uint256 maxShortSize;
    uint256 maxLongSize;
    uint256 maxTradingSize;
    uint256 maxRatio;
    uint256 countMinSize;

    //
    uint256 spreadBasis;
    uint256 maxSpreadBasis;// = 5000000 * PRICE_PRECISION;
    uint256 minSpreadCalUSD;// = 10000 * PRICE_PRECISION;

}

struct GlobalFeeSetting{
    uint256 taxBasisPoints; // 0.5%
    uint256 stableTaxBasisPoints; // 0.2%
    uint256 mintBurnFeeBasisPoints; // 0.3%
    uint256 swapFeeBasisPoints; // 0.3%
    uint256 stableSwapFeeBasisPoints; // 0.04%
    uint256 marginFeeBasisPoints; // 0.1%
    uint256 liquidationFeeUsd;
    uint256 maxLeverage; // 100x
    //Fees related to funding
    uint256 fundingRateFactor;
    uint256 stableFundingRateFactor;
    //trading tax part
    uint256 taxGradient;
    uint256 taxDuration;
    uint256 taxMax;
    //trading profit limitation part
    uint256 maxProfitRatio;
    uint256 premiumBasisPointsPerHour;
    int256 posIndexMaxPointsPerHour;
    int256 negIndexMaxPointsPerHour;
}


contract PositionReader is Ownable{
    using SafeMath for uint256;
    address public nativeToken;

    mapping(address => address[]) private fundingTokens;
    mapping(address => address[]) private tradingTokens;


    constructor(address _nativeToken) {
        nativeToken = _nativeToken;
    }

    function setokens(address _vault, address[] memory _fTokens, address[] memory _tTokens) external onlyOwner{
        fundingTokens[_vault] = _fTokens;//stable only
        tradingTokens[_vault] = _tTokens;
    }

    function getPosition(address _vault, address _account, address colToken, address idxToken, bool isLong) public view returns (DispPosition memory) {
        IVaultUtils  vaultUtils = IVaultUtils(IVaultTarget(_vault).vaultUtils());
        DispPosition memory dPos;
        uint256 entryFundingRate;
        {
            uint256 realisedPnl_uint;
            bool hasRealisedProfit;
            (dPos.size,
            dPos.collateral,
            dPos.averagePrice,
            entryFundingRate,
            dPos.reserveAmount,
            realisedPnl_uint,
            hasRealisedProfit,
            dPos.aveIncreaseTime) = IVault(_vault).getPosition(_account, colToken, idxToken, isLong);
            dPos.realisedPnl = hasRealisedProfit ? int256(realisedPnl_uint) : -int256(realisedPnl_uint);
        }
        if (dPos.size < 1 ||dPos.averagePrice < 1 ) return dPos;

        dPos.account = _account;
        dPos.collateralToken = colToken;
        dPos.indexToken = idxToken;
        dPos.isLong = isLong;
        dPos.lastUpdateTime = dPos.aveIncreaseTime;
        // dPos.key = dPos.aveIncreaseTime;
        dPos.entryFundingRateSec = entryFundingRate.mul(1e10).div(3600).div(1e6);
        (dPos.hasProfit , dPos.delta) = IVault(_vault).getDelta(idxToken, dPos.size, dPos.averagePrice, isLong, dPos.lastUpdateTime);

        dPos.pendingPositionFee = vaultUtils.getPositionFee(dPos.account,dPos.collateralToken, dPos.indexToken, dPos.isLong, dPos.size);
        dPos.pendingFundingFee = vaultUtils.getFundingFee(dPos.account, dPos.collateralToken, dPos.indexToken, dPos.isLong, dPos.size, entryFundingRate);

        return dPos;
    }
    



    
    function getUserPositions(address _vault, address _account) external view returns (DispPosition[] memory){
        DispPosition[] memory _dps = new DispPosition[](tradingTokens[_vault].length * (fundingTokens[_vault].length + 1));
        if (tradingTokens[_vault].length == 0) return _dps;
        uint256 accum_i = 0;
        uint256 accum_k = 0;
        for(uint256 i = 0; i < tradingTokens[_vault].length; i++){
            _dps[accum_i] = getPosition(_vault, _account, tradingTokens[_vault][i], tradingTokens[_vault][i], true);
            if (_dps[accum_i].size > 0)
                accum_k += 1;
            accum_i = accum_i.add(1);
            for(uint256 j = 0; j < fundingTokens[_vault].length; j++){
                _dps[accum_i] = getPosition(_vault, _account, fundingTokens[_vault][j], tradingTokens[_vault][i], false);
                if (_dps[accum_i].size > 0)
                    accum_k += 1;
                accum_i = accum_i.add(1);            }
        }
        DispPosition[] memory _dpsK = new DispPosition[](accum_k);
        uint256 accum_ki = 0;

        for(uint256 i = 0; i < _dps.length; i++){
            if (_dps[i].size < 1)
                continue;
            _dpsK[accum_ki]=_dps[i];
            accum_ki += 1;
        }
        return _dpsK;
    }



    function getTokenInfo(address _vault, address[] memory _fundTokens) external view returns (DispToken[] memory) {
        IVaultUtils  vaultUtils = IVaultUtils(IVaultTarget(_vault).vaultUtils());
        DispToken[] memory _dispT = new DispToken[](_fundTokens.length);
        IVault vault = IVault(_vault);
        for(uint256 i = 0; i < _dispT.length; i++){
            if (_fundTokens[i] == address(0))
                _fundTokens[i] = nativeToken;

            _dispT[i].token = _fundTokens[i];
            _dispT[i].weight = vault.tokenWeights(_fundTokens[i]);  
            _dispT[i].maxUSDAmounts =vault.maxUSDAmounts(_fundTokens[i]);
            _dispT[i].balance = vault.tokenBalances(_fundTokens[i]);
            _dispT[i].poolAmount = vault.poolAmounts(_fundTokens[i]);

            _dispT[i].reservedAmount = vault.reservedAmounts(_fundTokens[i]);
            _dispT[i].bufferAmount = vault.bufferAmounts(_fundTokens[i]);  
            _dispT[i].guaranteedUsd = IVault(_vault).guaranteedUsd(_fundTokens[i]);  

            _dispT[i].poolSize = vault.tokenToUsdMin(_fundTokens[i], _dispT[i].poolAmount);

            //fee part
            _dispT[i].fundingRatePerHour = vault.getNextFundingRate(_fundTokens[i]);  
            _dispT[i].fundingRatePerSec = _dispT[i].fundingRatePerHour.mul(1e10).div(3600).div(1e6);
    
        }
        return _dispT;
    }



/*
    function getGlobalFeeInfo(address _vault) external view returns (GlobalFeeSetting memory){//Fees related to swap
        GlobalFeeSetting memory gFS;
        IVaultUtils  vaultUtils = IVaultUtils(IVaultTarget(_vault).vaultUtils());
        gFS.taxBasisPoints = vaultUtils.taxBasisPoints();

        gFS.stableTaxBasisPoints = vaultUtils.stableTaxBasisPoints();
        gFS.mintBurnFeeBasisPoints = vaultUtils.mintBurnFeeBasisPoints();
        gFS.swapFeeBasisPoints = vaultUtils.swapFeeBasisPoints();
        gFS.stableSwapFeeBasisPoints = vaultUtils.stableSwapFeeBasisPoints();

        gFS.marginFeeBasisPoints = vaultUtils.marginFeeBasisPoints();
        gFS.liquidationFeeUsd = vaultUtils.liquidationFeeUsd();
        gFS.maxLeverage = vaultUtils.maxLeverage();
        gFS.fundingRateFactor = vaultUtils.fundingRateFactor();
        gFS.stableFundingRateFactor = vaultUtils.stableFundingRateFactor();
        gFS.taxGradient = vaultUtils.taxGradient();
        gFS.taxDuration = vaultUtils.taxDuration();

        gFS.taxMax = vaultUtils.taxMax();
        gFS.maxProfitRatio = vaultUtils.maxProfitRatio();
        gFS.premiumBasisPointsPerHour = vaultUtils.premiumBasisPointsPerHour();
        gFS.posIndexMaxPointsPerHour = vaultUtils.posIndexMaxPointsPerHour();
        gFS.negIndexMaxPointsPerHour = vaultUtils.negIndexMaxPointsPerHour();
        return gFS;
    }
*/
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

pragma solidity ^0.8.0;

import "../../DID/interfaces/IESBT.sol";

interface IVault {
    function isInitialized() external view returns (bool);
    function isSwapEnabled() external view returns (bool);
    function isLeverageEnabled() external view returns (bool);

    function setVaultUtils(address _vaultUtils) external;
    function setESBT(address _eSBT) external;
    // function setError(uint256 _errorCode, string calldata _error) external;

    function router() external view returns (address);
    function usdx() external view returns (address);

    function whitelistedTokenCount() external view returns (uint256);

    function fundingInterval() external view returns (uint256);
    function totalTokenWeights() external view returns (uint256);
    function getTargetUsdxAmount(address _token) external view returns (uint256);

    function inManagerMode() external view returns (bool);
    function inPrivateLiquidationMode() external view returns (bool);

    function usdxSupply() external view returns (uint256);

    function approvedRouters(address _account, address _router) external view returns (bool);
    function isLiquidator(address _account) external view returns (bool);
    function isManager(address _account) external view returns (bool);

    function minProfitBasisPoints(address _token) external view returns (uint256);
    function tokenBalances(address _token) external view returns (uint256);
    function lastFundingTimes(address _token) external view returns (uint256);

    function setInManagerMode(bool _inManagerMode) external;
    function setManager(address _manager, bool _isManager) external;
    function setIsSwapEnabled(bool _isSwapEnabled) external;
    function setIsLeverageEnabled(bool _isLeverageEnabled) external;
    function setUsdxAmount(address _token, uint256 _amount) external;
    function setBufferAmount(address _token, uint256 _amount) external;
    function setMaxGlobalShortSize(address _token, uint256 _amount) external;
    function setInPrivateLiquidationMode(bool _inPrivateLiquidationMode) external;
    function setLiquidator(address _liquidator, bool _isActive) external;

    function setFundingRate(uint256 _fundingInterval, uint256 _fundingRateFactor, uint256 _stableFundingRateFactor) external;

    function setTokenConfig(
        address _token,
        uint256 _tokenDecimals,
        uint256 _redemptionBps,
        uint256 _minProfitBps,
        uint256 _maxUSDAmount,
        bool _isStable,
        bool _isShortable
    ) external;

    function setPriceFeed(address _priceFeed) external;
    function setRouter(address _router) external;
    function directPoolDeposit(address _token) external;
    function buyUSDX(address _token, address _receiver) external returns (uint256);
    function sellUSDX(address _token, address _receiver, uint256 _usdxAmount) external returns (uint256);
    function claimFeeToken(address _token) external returns (uint256);
    function swap(address _tokenIn, address _tokenOut, address _receiver) external returns (uint256);
    function increasePosition(address _account, address _collateralToken, address _indexToken, uint256 _sizeDelta, bool _isLong) external;
    function decreasePosition(address _account, address _collateralToken, address _indexToken, uint256 _collateralDelta, uint256 _sizeDelta, bool _isLong, address _receiver) external returns (uint256);
    function liquidatePosition(address _account, address _collateralToken, address _indexToken, bool _isLong, address _feeReceiver) external;
    function tokenToUsdMin(address _token, uint256 _tokenAmount) external view returns (uint256);
    function usdToTokenMax(address _token, uint256 _usdAmount) external view returns (uint256);
    function usdToTokenMin(address _token, uint256 _usdAmount) external view returns (uint256);

    function priceFeed() external view returns (address);
    function fundingRateFactor() external view returns (uint256);
    function stableFundingRateFactor() external view returns (uint256);
    function cumulativeFundingRates(address _token) external view returns (uint256);
    function getNextFundingRate(address _token) external view returns (uint256);
    // function getFeeBasisPoints(address _token, uint256 _usdxDelta, uint256 _feeBasisPoints, uint256 _taxBasisPoints, bool _increment) external view returns (uint256);



    function allWhitelistedTokensLength() external view returns (uint256);
    function allWhitelistedTokens(uint256) external view returns (address);
    function whitelistedTokens(address _token) external view returns (bool);
    function stableTokens(address _token) external view returns (bool);
    function shortableTokens(address _token) external view returns (bool);
    function feeReserves(address _token) external view returns (uint256);
    
    function globalShortSizes(address _token) external view returns (uint256);
    function globalShortAveragePrices(address _token) external view returns (uint256);
    function maxGlobalShortSizes(address _token) external view returns (uint256);
    function tokenDecimals(address _token) external view returns (uint256);
    function tokenWeights(address _token) external view returns (uint256);
    function guaranteedUsd(address _token) external view returns (uint256);
    function poolAmounts(address _token) external view returns (uint256);
    function bufferAmounts(address _token) external view returns (uint256);
    function reservedAmounts(address _token) external view returns (uint256);
    function usdxAmounts(address _token) external view returns (uint256);
    function maxUSDAmounts(address _token) external view returns (uint256);
    function getRedemptionAmount(address _token, uint256 _usdxAmount) external view returns (uint256);
    function getMaxPrice(address _token) external view returns (uint256);
    function getMinPrice(address _token) external view returns (uint256);
    
    function getDelta(address _indexToken, uint256 _size, uint256 _averagePrice, bool _isLong, uint256 _lastIncreasedTime) external view returns (bool, uint256);
    
    function getPosition(address _account, address _collateralToken, address _indexToken, bool _isLong) external view returns (uint256, uint256, uint256, uint256, uint256, uint256, bool, uint256);
    function getPositionByKey(bytes32 _key) external view returns (uint256, uint256, uint256, uint256, uint256, uint256, bool, uint256);

 
    function tokenUtilization(address _token) external view returns (uint256);
    function claimFeeReserves( ) external returns (uint256) ;
    function claimableFeeReserves( )  external view returns (uint256);
    function feeSold (address _token)  external view returns (uint256);
    function feeReservesUSD() external view returns (uint256);
    function feeReservesDiscountedUSD() external view returns (uint256);
    
    function feeReservesRecord(uint256 _day) external view returns (uint256);
    function vaultUtilsAddress() external view returns (address);

    function feeClaimedUSD() external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IVaultUtils {
    function updateCumulativeFundingRate(address _collateralToken, address _indexToken) external returns (bool);
    function validateIncreasePosition(address _account, address _collateralToken, address _indexToken, uint256 _sizeDelta, bool _isLong) external view;
    function validateDecreasePosition(address _account, address _collateralToken, address _indexToken, uint256 _collateralDelta, uint256 _sizeDelta, bool _isLong, address _receiver) external view;
    function validateLiquidation(address _account, address _collateralToken, address _indexToken, bool _isLong, bool _raise) external view returns (uint256, uint256);
    function getLiqPrice(bytes32 _posKey) external view returns (uint256);
    function getEntryFundingRate(address _collateralToken, address _indexToken, bool _isLong) external view returns (uint256);
    function getPositionFee(address _account, address _collateralToken, address _indexToken, bool _isLong, uint256 _sizeDelta) external view returns (uint256);
    function getFundingFee(address _account, address _collateralToken, address _indexToken, bool _isLong, uint256 _size, uint256 _entryFundingRate) external view returns (uint256);
    function getBuyUsdxFeeBasisPoints(address _token, uint256 _usdxAmount) external view returns (uint256);
    function getSellUsdxFeeBasisPoints(address _token, uint256 _usdxAmount) external view returns (uint256);
    function getSwapFeeBasisPoints(address _tokenIn, address _tokenOut, uint256 _usdxAmount) external view returns (uint256);
    function getFeeBasisPoints(address _token, uint256 _usdxDelta, uint256 _feeBasisPoints, uint256 _taxBasisPoints, bool _increment) external view returns (uint256);
    function getPositionKey(address _account,address _collateralToken, address _indexToken, bool _isLong, uint256 _keyID) external view returns (bytes32);
    function addPosition(bytes32 _key,address _account, address _collateralToken, address _indexToken, bool _isLong) external;
    function removePosition(bytes32 _key) external;
    // function getDiscountedFee(address _account, uint256 _origFee, address _token) external view returns (uint256);
    // function getSwapDiscountedFee(address _user, uint256 _origFee, address _token) external view returns (uint256);
    // function uploadFeeRecord(address _user, uint256 _feeOrig, uint256 _feeDiscounted, address _token) external;

    function BASIS_POINTS_DIVISOR() external view returns (uint256);
    function FUNDING_RATE_PRECISION() external view returns (uint256);

    function PRICE_PRECISION() external view returns (uint256);
    function MIN_LEVERAGE() external view returns (uint256);
    function USDX_DECIMALS() external view returns (uint256);
    function MAX_FEE_BASIS_POINTS() external view returns (uint256);
    function MAX_LIQUIDATION_FEE_USD() external view returns (uint256);
    function MIN_FUNDING_RATE_INTERVAL() external view returns (uint256);
    function MAX_FUNDING_RATE_FACTOR() external view returns (uint256);

    function liquidationFeeUsd() external view returns (uint256);
    function taxBasisPoints() external view returns (uint256);
    function stableTaxBasisPoints() external view returns (uint256);
    function mintBurnFeeBasisPoints() external view returns (uint256);
    function swapFeeBasisPoints() external view returns (uint256);
    function stableSwapFeeBasisPoints() external view returns (uint256);
    function marginFeeBasisPoints() external view returns (uint256);

    function minProfitTime() external view returns (uint256);
    function hasDynamicFees() external view returns (bool);
    function maxLeverage() external view returns (uint256);
    function balanceFeeBasisPoints(address _token) external view returns (uint256);

    function setMaxLeverage(uint256 _maxLeverage) external;
    function setTaxRate(uint256 _taxMax, uint256 _taxTime) external;
    function setBalanceFeeBasisPoints(address _token, uint256 _fee) external;

    function errors(uint256) external view returns (string memory);

    function calculateTax(uint256 _profit, uint256 _aveIncreaseTime) external view returns(uint256);
    function taxGradient() external view returns(uint256);
    function taxMax() external view returns(uint256);
    function taxDuration() external view returns(uint256);

    function getNextAveragePrice(address _indexToken, uint256 _size, uint256 _averagePrice,
        bool _isLong, uint256 _nextPrice, uint256 _sizeDelta, uint256 _lastIncreasedTime ) external view returns (uint256);

    // function getPositionDelta(address _account, address _collateralToken, address _indexToken, bool _isLong) external view returns (bool, uint256);



    function setFees(
        uint256 _taxBasisPoints,
        uint256 _stableTaxBasisPoints,
        uint256 _mintBurnFeeBasisPoints,
        uint256 _swapFeeBasisPoints,
        uint256 _stableSwapFeeBasisPoints,
        uint256 _marginFeeBasisPoints,
        uint256 _liquidationFeeUsd,
        uint256 _minProfitTime,
        bool _hasDynamicFees
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IVaultPriceFeedV2 {
    function adjustmentBasisPoints(address _token) external view returns (uint256);
    function isAdjustmentAdditive(address _token) external view returns (bool);
    function setAdjustment(address _token, bool _isAdditive, uint256 _adjustmentBps) external;
    function setUseV2Pricing(bool _useV2Pricing) external;
    function setIsAmmEnabled(bool _isEnabled) external;
    function setIsSecondaryPriceEnabled(bool _isEnabled) external;
    function setSpreadBasisPoints(address _token, uint256 _spreadBasisPoints) external;
    function setSpreadThresholdBasisPoints(uint256 _spreadThresholdBasisPoints) external;
    function setFavorPrimaryPrice(bool _favorPrimaryPrice) external;
    function setPriceSampleSpace(uint256 _priceSampleSpace) external;
    function setMaxStrictPriceDeviation(uint256 _maxStrictPriceDeviation) external;
    function getPrice(address _token, bool _maximise,bool,bool) external view returns (uint256);
    function getOrigPrice(address _token) external view returns (uint256);
    
    function getLatestPrimaryPrice(address _token) external view returns (uint256);
    function getPrimaryPrice(address _token, bool _maximise) external view returns (uint256, bool);
    function setTokenChainlink( address _token, address _chainlinkContract) external;
    function setTokenConfig(
        address _token,
        address _priceFeed,
        uint256 _priceDecimals,
        bool _isStrictStable
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IBasePositionManager {
    function maxGlobalLongSizes(address _token) external view returns (uint256);
    function maxGlobalShortSizes(address _token) external view returns (uint256);
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
pragma solidity ^0.8.13;

interface IESBT {
    // function updateIncreaseLogForAccount(address _account, address _collateralToken, 
            // uint256 _collateralSize,uint256 _positionSize, bool /*_isLong*/ ) external returns (bool);

    function scorePara(uint256 _paraId) external view returns (uint256);
    function createTime(address _account) external view returns (uint256);
    // function tradingKey(address _account, bytes32 key) external view returns (bytes32);
    function nickName(address _account) external view returns (string memory);


    function getReferralForAccount(address _account) external view returns (address[] memory , address[] memory);
    function userSizeSum(address _account) external view returns (uint256);
    // function updateFeeDiscount(address _account, uint256 _discount, uint256 _rebate) external;
    function updateFee(address _account, uint256 _origFee) external returns (uint256);
    // function calFeeDiscount(address _account, uint256 _amount) external view returns (uint256);

    function getESBTAddMpUintetRoles(address _mpaddress, bytes32 _key) external view returns (uint256[] memory);
    function updateClaimVal(address _account) external ;
    function userClaimable(address _account) external view returns (uint256, uint256);

    // function updateScoreForAccount(address _account, uint256 _USDamount, uint16 _opeType) external;
    function updateScoreForAccount(address _account, address /*_vault*/, uint256 _amount, uint256 _reasonCode) external;
    function updateTradingScoreForAccount(address _account, address _vault, uint256 _amount, uint256 _refCode) external;
    function updateSwapScoreForAccount(address _account, address _vault, uint256 _amount) external;
    function updateAddLiqScoreForAccount(address _account, address _vault, uint256 _amount, uint256 _refCode) external;
    // function updateStakeEDEScoreForAccount(address _account, uint256 _amount) external ;
    function getScore(address _account) external view returns (uint256);
    function getRefCode(address _account) external view returns (string memory);
    function accountToDisReb(address _account) external view returns (uint256, uint256);
    function rank(address _account) external view returns (uint256);
    function addressToTokenID(address _account) external view returns (uint256);
}
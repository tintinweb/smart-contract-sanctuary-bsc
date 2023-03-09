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

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.4;

interface IBiswapMintCallback {

    /// @notice Called to msg.sender in iBiswapPoolV3#mint call
    /// @param x Amount of tokenX need to pay from miner
    /// @param y Amount of tokenY need to pay from miner
    /// @param data Any data passed through by the msg.sender via the iBiswapPoolV3#mint call
    function mintDepositCallback(
        uint256 x,
        uint256 y,
        bytes calldata data
    ) external;

}

interface IBiswapCallback {

    /// @notice Called to msg.sender in iBiswapPoolV3#swapY2X(DesireX) call
    /// @param x Amount of tokenX trader will acquire
    /// @param y Amount of tokenY trader will pay
    /// @param data Any dadta passed though by the msg.sender via the iBiswapPoolV3#swapY2X(DesireX) call
    function swapY2XCallback(
        uint256 x,
        uint256 y,
        bytes calldata data
    ) external;

    /// @notice Called to msg.sender in iBiswapPoolV3#swapX2Y(DesireY) call
    /// @param x Amount of tokenX trader will pay
    /// @param y Amount of tokenY trader will require
    /// @param data Any dadta passed though by the msg.sender via the iBiswapPoolV3#swapX2Y(DesireY) call
    function swapX2YCallback(
        uint256 x,
        uint256 y,
        bytes calldata data
    ) external;

}

interface IBiswapAddLimOrderCallback {

    /// @notice Called to msg.sender in iBiswapPoolV3#addLimOrderWithX(Y) call
    /// @param x Amount of tokenX seller will pay
    /// @param y Amount of tokenY seller will pay
    /// @param data Any data passed though by the msg.sender via the iBiswapPoolV3#addLimOrderWithX(Y) call
    function payCallback(
        uint256 x,
        uint256 y,
        bytes calldata data
    ) external;

}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.4;

interface IBiswapFactoryV3 {

    /// @notice emit when successfully create a new pool (calling iBiswapFactoryV3#newPool)
    /// @param tokenX address of erc-20 tokenX
    /// @param tokenY address of erc-20 tokenY
    /// @param fee fee amount of swap (3000 means 0.3%)
    /// @param pointDelta minimum number of distance between initialized or limitorder points
    /// @param pool address of swap pool
    event NewPool(
        address indexed tokenX,
        address indexed tokenY,
        uint16 indexed fee,
        uint24 pointDelta,
        address pool
    );

    /// @notice emit when owner change delta fee on pools
    /// @param oldDelta delta was before
    /// @param newDelta new delta
    event FeeDeltaChanged(uint16 oldDelta, uint16 newDelta);

    /// @notice emit when owner change discount setters address
    /// @param newDiscountSetter new discount setter address
    event NewDiscountSetter(address newDiscountSetter);

    struct Addresses {
        address swapX2YModule;
        address  swapY2XModule;
        address  liquidityModule;
        address  limitOrderModule;
        address  flashModule;
    }

    /// @notice Add struct to save gas
    /// @return swapX2YModule address of module to support swapX2Y(DesireY)
    /// @return swapY2XModule address of module to support swapY2X(DesireX)
    /// @return liquidityModule address of module to support liquidity
    /// @return limitOrderModule address of module for user to manage limit orders
    /// @return flashModule address of module to support flash loan
    function addresses() external returns(
        address swapX2YModule,
        address swapY2XModule,
        address liquidityModule,
        address limitOrderModule,
        address flashModule
    );


    /// @notice default fee rate from miner's fee gain
    /// @return defaultFeeChargePercent default fee rate * 100
    function defaultFeeChargePercent() external returns (uint24);

    /// @notice Enables a fee amount with the given pointDelta
    /// @dev Fee amounts may never be removed once enabled
    /// @param fee fee amount (3000 means 0.3%)
    /// @param pointDelta The spacing between points to be enforced for all pools created with the given fee amount
    function enableFeeAmount(uint16 fee, uint24 pointDelta) external;

    /// @notice Create a new pool which not exists.
    /// @param tokenX address of tokenX
    /// @param tokenY address of tokenY
    /// @param fee fee amount
    /// @param currentPoint initial point (log 1.0001 of price)
    /// @return address of newly created pool
    function newPool(
        address tokenX,
        address tokenY,
        uint16 fee,
        int24 currentPoint
    ) external returns (address);

    /// @notice Charge receiver of all pools.
    /// @return address of charge receiver
    function chargeReceiver() external view returns(address);

    /// @notice Get pool of (tokenX, tokenY, fee), address(0) for not exists.
    /// @param tokenX address of tokenX
    /// @param tokenY address of tokenY
    /// @param fee fee amount
    /// @return address of pool
    function pool(
        address tokenX,
        address tokenY,
        uint16 fee
    ) external view returns(address);

    /// @notice Get point delta of a given fee amount.
    /// @param fee fee amount
    /// @return pointDelta the point delta
    function fee2pointDelta(uint16 fee) external view returns (int24 pointDelta);

    /// @notice Get delta fee of a given fee amount.
    /// @param fee fee amount
    /// @return deltaFee fee delta [fee - %delta; fee + %delta] delta in percent base 10000
    function fee2DeltaFee(uint16 fee) external view returns (uint16 deltaFee);

    /// @notice Change charge receiver, only owner of factory can call.
    /// @param _chargeReceiver address of new receiver
    function modifyChargeReceiver(address _chargeReceiver) external;

    /// @notice Change defaultFeeChargePercent
    /// @param _defaultFeeChargePercent new charge percent
    function modifyDefaultFeeChargePercent(uint24 _defaultFeeChargePercent) external;

    /// @notice return range of fee change
    /// @param fee fee for get range
    /// @return lowFee low range border
    /// @return highFee high range border
    function getFeeRange(uint16 fee) external view returns(uint16 lowFee, uint16 highFee);

    /// @notice set fee delta to pools
    /// @param fee fee of pools on which the delta change
    /// @param delta new delta in base 10000
    function setFeeDelta(uint16 fee, uint16 delta) external;

    /// @notice change discount setters address
    /// @param newDiscountSetter new discount setter address
    function setDiscountSetterAddress(address newDiscountSetter) external;

    /// @notice get discount from user address and pool
    /// @param user user address
    /// @param _pool pool address
    /// @return discount value of the discount base 10000
    function feeDiscount(address user, address _pool) external returns(uint16 discount);

    function deployPoolParams() external view returns(
        address tokenX,
        address tokenY,
        uint16 fee,
        int24 currentPoint,
        int24 pointDelta,
        uint24 feeChargePercent
    );

    /// @notice check fee in range
    /// @param fee fee of pools on which the delta change
    /// @param initFee initialize fee when pool created
    function checkFeeInRange(uint16 fee, uint16 initFee) external view returns(bool);

}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.4;

interface IBiswapPoolV3 {

    /// @notice Emitted when miner successfully add liquidity (mint).
    /// @param sender the address that minted the liquidity
    /// @param owner the owner who will benefit from this liquidity
    /// @param leftPoint left endpoint of the liquidity
    /// @param rightPoint right endpoint of the liquidity
    /// @param liquidity the amount of liquidity minted to the range [leftPoint, rightPoint)
    /// @param amountX amount of tokenX deposit
    /// @param amountY amount of tokenY deposit
    event Mint(
        address sender,
        address indexed owner,
        int24 indexed leftPoint,
        int24 indexed rightPoint,
        uint128 liquidity,
        uint256 amountX,
        uint256 amountY
    );

    /// @notice Emitted when miner successfully decrease liquidity (withdraw).
    /// @param owner owner address of liquidity
    /// @param leftPoint left endpoint of liquidity
    /// @param rightPoint right endpoint of liquidity
    /// @param liquidity amount of liquidity decreased
    /// @param amountX amount of tokenX withdrawed
    /// @param amountY amount of tokenY withdrawed
    event Burn(
        address indexed owner,
        int24 indexed leftPoint,
        int24 indexed rightPoint,
        uint128 liquidity,
        uint256 amountX,
        uint256 amountY
    );

    /// @notice Emitted when fees and withdrawed liquidity are collected
    /// @param owner The owner of the Liquidity
    /// @param recipient recipient of those token
    /// @param leftPoint The left point of the liquidity
    /// @param rightPoint The right point of the liquidity
    /// @param amountX The amount of tokenX (fees and withdrawed tokenX from liquidity)
    /// @param amountY The amount of tokenY (fees and withdrawed tokenY from liquidity)
    event CollectLiquidity(
        address indexed owner,
        address recipient,
        int24 indexed leftPoint,
        int24 indexed rightPoint,
        uint256 amountX,
        uint256 amountY
    );

    /// @notice Emitted when change fee vote
    /// @param owner The owner of the Liquidity
    /// @param leftPoint The left point of the liquidity
    /// @param rightPoint The right point of the liquidity
    /// @param newFeeVote new vote for fee for existing liquidity
    event ChangeFeeVote(
        address indexed owner,
        int24 indexed leftPoint,
        int24 indexed rightPoint,
        uint16 newFeeVote
    );

    /// @notice Emitted when a trader successfully exchange.
    /// @param tokenX tokenX of pool
    /// @param tokenY tokenY of pool
    /// @param fee fee amount of pool
    /// @param sellXEarnY true for selling tokenX, false for buying tokenX
    /// @param amountX amount of tokenX in this exchange
    /// @param amountY amount of tokenY in this exchange
    event Swap(
        address indexed tokenX,
        address indexed tokenY,
        uint16 indexed fee,
        bool sellXEarnY,
        uint256 amountX,
        uint256 amountY
    );

    /// @notice Emitted by the pool for any flashes of tokenX/tokenY.
    /// @param sender the address that initiated the swap call, and that received the callback
    /// @param recipient the address that received the tokens from flash
    /// @param amountX the amount of tokenX that was flashed
    /// @param amountY the amount of tokenY that was flashed
    /// @param paidX the amount of tokenX paid for the flash, which can exceed the amountX plus the fee
    /// @param paidY the amount of tokenY paid for the flash, which can exceed the amountY plus the fee
    event Flash(
        address indexed sender,
        address indexed recipient,
        uint256 amountX,
        uint256 amountY,
        uint256 paidX,
        uint256 paidY
    );

    /// @notice Emitted when a seller successfully add a limit order.
    /// @param owner owner of limit order
    /// @param addAmount amount of token to sell the seller added
    /// @param acquireAmount amount of earn-token acquired, if there exists some opposite order before
    /// @param point point of limit order
    /// @param claimSold claimed sold sell-token, if this owner has order with same direction on this point before
    /// @param claimEarn claimed earned earn-token, if this owner has order with same direction on this point before
    /// @param sellXEarnY direction of limit order, etc. sell tokenX or sell tokenY
    event AddLimitOrder(
        address indexed owner,
        uint128 addAmount,
        uint128 acquireAmount,
        int24 indexed point,
        uint128 claimSold,
        uint128 claimEarn,
        bool sellXEarnY
    );

    /// @notice Emitted when a seller successfully decrease a limit order.
    /// @param owner owner of limit order
    /// @param decreaseAmount amount of token to sell the seller decreased
    /// @param point point of limit order
    /// @param claimSold claimed sold sell-token
    /// @param claimEarn claimed earned earn-token
    /// @param sellXEarnY direction of limit order, etc. sell tokenX or sell tokenY
    event DecLimitOrder(
        address indexed owner,
        uint128 decreaseAmount,
        int24 indexed point,
        uint128 claimSold,
        uint128 claimEarn,
        bool sellXEarnY
    );

    /// @notice Emitted when collect from a limit order
    /// @param owner The owner of the Liquidity
    /// @param recipient recipient of those token
    /// @param point The point of the limit order
    /// @param collectDec The amount of decreased sell token collected
    /// @param collectEarn The amount of earn token collected
    /// @param sellXEarnY direction of limit order, etc. sell tokenX or sell tokenY
    event CollectLimitOrder(
        address indexed owner,
        address recipient,
        int24 indexed point,
        uint128 collectDec,
        uint128 collectEarn,
        bool sellXEarnY
    );

    /// @notice Returns the information about a liquidity by the liquidity's key.
    /// @param key the liquidity's key is a hash of a preimage composed by the miner(owner), pointLeft and pointRight
    /// @return feeVote Vote for fee
    /// @return _liquidity the amount of liquidity,
    /// @return lastFeeScaleX_128 fee growth of tokenX inside the range as of the last mint/burn/collect,
    /// @return lastFeeScaleY_128 fee growth of tokenY inside the range as of the last mint/burn/collect,
    /// @return tokenOwedX the computed amount of tokenX miner can collect as of the last mint/burn/collect,
    /// @return tokenOwedY the computed amount of tokenY miner can collect as of the last mint/burn/collect
    function liquidity(bytes32 key)
        external
        view
        returns (
            uint16 feeVote,
            uint128 _liquidity,
            uint256 lastFeeScaleX_128,
            uint256 lastFeeScaleY_128,
            uint256 tokenOwedX,
            uint256 tokenOwedY
        );

    /// @notice Returns the information about a user's limit order (sell tokenY and earn tokenX).
    /// @param key the limit order's key is a hash of a preimage composed by the seller, point
    /// @return lastAccEarn total amount of tokenX earned by all users at this point as of the last add/dec/collect
    /// @return sellingRemain amount of tokenY not selled in this limit order
    /// @return sellingDec amount of tokenY decreased by seller from this limit order
    /// @return earn amount of unlegacy earned tokenX in this limit order not assigned
    /// @return legacyEarn amount of legacy earned tokenX in this limit order not assgined
    /// @return earnAssign assigned amount of tokenX earned (both legacy and unlegacy) in this limit order
    function userEarnX(bytes32 key)
        external
        view
        returns (
            uint256 lastAccEarn,
            uint128 sellingRemain,
            uint128 sellingDec,
            uint128 earn,
            uint128 legacyEarn,
            uint128 earnAssign
        );

    /// @notice Returns the information about a user's limit order (sell tokenX and earn tokenY).
    /// @param key the limit order's key is a hash of a preimage composed by the seller, point
    /// @return lastAccEarn total amount of tokenY earned by all users at this point as of the last add/dec/collect
    /// @return sellingRemain amount of tokenX not selled in this limit order
    /// @return sellingDec amount of tokenX decreased by seller from this limit order
    /// @return earn amount of unlegacy earned tokenY in this limit order not assigned
    /// @return legacyEarn amount of legacy earned tokenY in this limit order not assgined
    /// @return earnAssign assigned amount of tokenY earned (both legacy and unlegacy) in this limit order
    function userEarnY(bytes32 key)
        external
        view
        returns (
            uint256 lastAccEarn,
            uint128 sellingRemain,
            uint128 sellingDec,
            uint128 earn,
            uint128 legacyEarn,
            uint128 earnAssign
        );

    /// @notice Mark a given amount of tokenY in a limitorder(sellx and earn y) as assigned.
    /// @param point point (log Price) of seller's limit order,be sure to be times of pointDelta
    /// @param assignY max amount of tokenY to mark assigned
    /// @param fromLegacy true for assigning earned token from legacyEarnY
    /// @return actualAssignY actual amount of tokenY marked
    function assignLimOrderEarnY(
        int24 point,
        uint128 assignY,
        bool fromLegacy
    ) external returns(uint128 actualAssignY);

    /// @notice Mark a given amount of tokenX in a limitorder(selly and earn x) as assigned.
    /// @param point point (log Price) of seller's limit order,be sure to be times of pointDelta
    /// @param assignX max amount of tokenX to mark assigned
    /// @param fromLegacy true for assigning earned token from legacyEarnX
    /// @return actualAssignX actual amount of tokenX marked
    function assignLimOrderEarnX(
        int24 point,
        uint128 assignX,
        bool fromLegacy
    ) external returns(uint128 actualAssignX);

    /// @notice Decrease limitorder of selling X.
    /// @param point point of seller's limit order, be sure to be times of pointDelta
    /// @param deltaX max amount of tokenX seller wants to decrease
    /// @return actualDeltaX actual amount of tokenX decreased
    /// @return legacyAccEarn legacyAccEarnY of pointOrder at point when calling this interface
    function decLimOrderWithX(
        int24 point,
        uint128 deltaX
    ) external returns (uint128 actualDeltaX, uint256 legacyAccEarn);

    /// @notice Decrease limitorder of selling Y.
    /// @param point point of seller's limit order, be sure to be times of pointDelta
    /// @param deltaY max amount of tokenY seller wants to decrease
    /// @return actualDeltaY actual amount of tokenY decreased
    /// @return legacyAccEarn legacyAccEarnX of pointOrder at point when calling this interface
    function decLimOrderWithY(
        int24 point,
        uint128 deltaY
    ) external returns (uint128 actualDeltaY, uint256 legacyAccEarn);

    /// @notice Add a limit order (selling x) in the pool.
    /// @param recipient owner of the limit order
    /// @param point point of the order, be sure to be times of pointDelta
    /// @param amountX amount of tokenX to sell
    /// @param data any data that should be passed through to the callback
    /// @return orderX actual added amount of tokenX
    /// @return acquireY amount of tokenY acquired if there is a limit order to sell y before adding
    function addLimOrderWithX(
        address recipient,
        int24 point,
        uint128 amountX,
        bytes calldata data
    ) external returns (uint128 orderX, uint128 acquireY);

    /// @notice Add a limit order (selling y) in the pool.
    /// @param recipient owner of the limit order
    /// @param point point of the order, be sure to be times of pointDelta
    /// @param amountY amount of tokenY to sell
    /// @param data any data that should be passed through to the callback
    /// @return orderY actual added amount of tokenY
    /// @return acquireX amount of tokenX acquired if there exists a limit order to sell x before adding
    function addLimOrderWithY(
        address recipient,
        int24 point,
        uint128 amountY,
        bytes calldata data
    ) external returns (uint128 orderY, uint128 acquireX);

    /// @notice Collect earned or decreased token from limit order.
    /// @param recipient address to benefit
    /// @param point point of limit order, be sure to be times of pointDelta
    /// @param collectDec max amount of decreased selling token to collect
    /// @param collectEarn max amount of earned token to collect
    /// @param isEarnY direction of this limit order, true for sell y, false for sell x
    /// @return actualCollectDec actual amount of decresed selling token collected
    /// @return actualCollectEarn actual amount of earned token collected
    function collectLimOrder(
        address recipient, int24 point, uint128 collectDec, uint128 collectEarn, bool isEarnY
    ) external returns(uint128 actualCollectDec, uint128 actualCollectEarn);

    /// @notice Add liquidity to the pool.
    /// @param recipient newly created liquidity will belong to this address
    /// @param leftPt left endpoint of the liquidity, be sure to be times of pointDelta
    /// @param rightPt right endpoint of the liquidity, be sure to be times of pointDelta
    /// @param liquidDelta amount of liquidity to add
    /// @param data any data that should be passed through to the callback
    /// @return amountX The amount of tokenX that was paid for the liquidity. Matches the value in the callback
    /// @return amountY The amount of tokenY that was paid for the liquidity. Matches the value in the callback
    function mint(
        address recipient,
        int24 leftPt,
        int24 rightPt,
        uint128 liquidDelta,
        bytes calldata data
    ) external returns (uint256 amountX, uint256 amountY);

    /// @notice Add liquidity to the pool.
    /// @param recipient newly created liquidity will belong to this address
    /// @param leftPt left endpoint of the liquidity, be sure to be times of pointDelta
    /// @param rightPt right endpoint of the liquidity, be sure to be times of pointDelta
    /// @param liquidDelta amount of liquidity to add
    /// @param feeToVote vote for fee on current pool
    /// @param data any data that should be passed through to the callback
    /// @return amountX The amount of tokenX that was paid for the liquidity. Matches the value in the callback
    /// @return amountY The amount of tokenY that was paid for the liquidity. Matches the value in the callback
    function mint(
        address recipient,
        int24 leftPt,
        int24 rightPt,
        uint128 liquidDelta,
        uint16 feeToVote,
        bytes calldata data
    ) external returns (uint256 amountX, uint256 amountY);

    /// @notice Decrease a given amount of liquidity from msg.sender's liquidities.
    /// @param leftPt left endpoint of the liquidity
    /// @param rightPt right endpoint of the liquidity
    /// @param liquidDelta amount of liquidity to burn
    /// @return amountX The amount of tokenX should be refund after burn
    /// @return amountY The amount of tokenY should be refund after burn
    function burn(
        int24 leftPt,
        int24 rightPt,
        uint128 liquidDelta
    ) external returns (uint256 amountX, uint256 amountY);

    /// @notice Collect tokens (fee or refunded after burn) from a liquidity.
    /// @param recipient the address which should receive the collected tokens
    /// @param leftPt left endpoint of the liquidity
    /// @param rightPt right endpoint of the liquidity
    /// @param amountXLim max amount of tokenX the owner wants to collect
    /// @param amountYLim max amount of tokenY the owner wants to collect
    /// @return actualAmountX the amount tokenX collected
    /// @return actualAmountY the amount tokenY collected
    function collect(
        address recipient,
        int24 leftPt,
        int24 rightPt,
        uint256 amountXLim,
        uint256 amountYLim
    ) external returns (uint256 actualAmountX, uint256 actualAmountY);

    /// @notice Change fee vote for user existing liquidity.
    /// @param leftPt left endpoint of the liquidity
    /// @param rightPt right endpoint of the liquidity
    /// @param newFeeVote new vote for fee for existing liquidity
    function changeFeeVote(int24 leftPt, int24 rightPt, uint16 newFeeVote) external;

    /// @notice Swap tokenY for tokenX, given max amount of tokenY user willing to pay.
    /// @param recipient the address to receive tokenX
    /// @param amount the max amount of tokenY user willing to pay
    /// @param highPt the highest point(price) of x/y during swap
    /// @param data any data to be passed through to the callback
    /// @return amountX amount of tokenX payed
    /// @return amountY amount of tokenY acquired
    function swapY2X(
        address recipient,
        uint128 amount,
        int24 highPt,
        bytes calldata data
    ) external returns (uint256 amountX, uint256 amountY);

    /// @notice Swap tokenY for tokenX, given amount of tokenX user desires.
    /// @param recipient the address to receive tokenX
    /// @param desireX the amount of tokenX user desires
    /// @param highPt the highest point(price) of x/y during swap
    /// @param data any data to be passed through to the callback
    /// @return amountX amount of tokenX payed
    /// @return amountY amount of tokenY acquired
    function swapY2XDesireX(
        address recipient,
        uint128 desireX,
        int24 highPt,
        bytes calldata data
    ) external returns (uint256 amountX, uint256 amountY);

    /// @notice Swap tokenX for tokenY, given max amount of tokenX user willing to pay.
    /// @param recipient the address to receive tokenY
    /// @param amount the max amount of tokenX user willing to pay
    /// @param lowPt the lowest point(price) of x/y during swap
    /// @param data any data to be passed through to the callback
    /// @return amountX amount of tokenX acquired
    /// @return amountY amount of tokenY payed
    function swapX2Y(
        address recipient,
        uint128 amount,
        int24 lowPt,
        bytes calldata data
    ) external returns (uint256 amountX, uint256 amountY);

    /// @notice Swap tokenX for tokenY, given amount of tokenY user desires.
    /// @param recipient the address to receive tokenY
    /// @param desireY the amount of tokenY user desires
    /// @param lowPt the lowest point(price) of x/y during swap
    /// @param data any data to be passed through to the callback
    /// @return amountX amount of tokenX acquired
    /// @return amountY amount of tokenY payed
    function swapX2YDesireY(
        address recipient,
        uint128 desireY,
        int24 lowPt,
        bytes calldata data
    ) external returns (uint256 amountX, uint256 amountY);

    /// @notice Returns sqrt(1.0001), in 96 bit fixpoint number.
    function sqrtRate_96() external view returns(uint160);

    /// @notice State values of pool.
    /// @return sqrtPrice_96 a 96 fixpoing number describe the sqrt value of current price(tokenX/tokenY)
    /// @return currentPoint the current point of the pool, 1.0001 ^ currentPoint = price
    /// @return observationCurrentIndex the index of the last oracle observation that was written,
    /// @return observationQueueLen the current maximum number of observations stored in the pool,
    /// @return observationNextQueueLen the next maximum number of observations, to be updated when the observation.
    /// @return locked whether the pool is locked (only used for checking reentrance)
    /// @return feeTimesL sum Vote fee * Liquidity
    /// @return fee Current fee on pool
    /// @return _liquidity liquidity on the currentPoint (currX * sqrtPrice + currY / sqrtPrice)
    /// @return liquidityX liquidity of tokenX
    function state()
        external view
        returns(
            uint160 sqrtPrice_96,
            int24 currentPoint,
            uint16 observationCurrentIndex,
            uint16 observationQueueLen,
            uint16 observationNextQueueLen,
            bool locked,
            uint240 feeTimesL,
            uint16 fee,
            uint128 _liquidity,
            uint128 liquidityX
        );

    /// @notice LimitOrder info on a given point.
    /// @param point the given point
    /// @return sellingX total amount of tokenX selling on the point
    /// @return earnY total amount of unclaimed earned tokenY for unlegacy sellingX
    /// @return accEarnY total amount of earned tokenY(via selling tokenX) by all users at this point as of the last swap
    /// @return legacyAccEarnY latest recorded 'accEarnY' value when sellingX is clear (legacy)
    /// @return legacyEarnY total amount of unclaimed earned tokenY for legacy (cleared during swap) sellingX
    /// @return sellingY total amount of tokenYselling on the point
    /// @return earnX total amount of unclaimed earned tokenX for unlegacy sellingY
    /// @return legacyEarnX total amount of unclaimed earned tokenX for legacy (cleared during swap) sellingY
    /// @return accEarnX total amount of earned tokenX(via selling tokenY) by all users at this point as of the last swap
    /// @return legacyAccEarnX latest recorded 'accEarnX' value when sellingY is clear (legacy)
    function limitOrderData(int24 point)
        external view
        returns(
            uint128 sellingX,
            uint128 earnY,
            uint256 accEarnY,
            uint256 legacyAccEarnY,
            uint128 legacyEarnY,
            uint128 sellingY,
            uint128 earnX,
            uint128 legacyEarnX,
            uint256 accEarnX,
            uint256 legacyAccEarnX
        );

    /// @notice Query infomation about a point whether has limit order or is an liquidity's endpoint.
    /// @param point point to query
    /// @return val endpoint for val&1>0 and has limit order for val&2 > 0
    function orderOrEndpoint(int24 point) external returns(int24 val);

    /// @notice Returns observation data about a specific index.
    /// @param index the index of observation array
    /// @return timestamp the timestamp of the observation,
    /// @return accPoint the point multiplied by seconds elapsed for the life of the pool as of the observation timestamp,
    /// @return init whether the observation has been initialized and the above values are safe to use
    function observations(uint256 index)
        external
        view
        returns (
            uint32 timestamp,
            int56 accPoint,
            bool init
        );

    /// @notice Point status in the pool.
    /// @param point the point
    /// @return liquidSum the total amount of liquidity that uses the point either as left endpoint or right endpoint
    /// @return liquidDelta how much liquidity changes when the pool price crosses the point from left to right
    /// @return accFeeXOut_128 the fee growth on the other side of the point from the current point in tokenX
    /// @return accFeeYOut_128 the fee growth on the other side of the point from the current point in tokenY
    /// @return isEndpt whether the point is an endpoint of a some miner's liquidity, true if liquidSum > 0
    /// @return feeTimesL how much fee vote changes when the pool price crosses the point
    function points(int24 point)
        external
        view
        returns (
            uint128 liquidSum,
            int128 liquidDelta,
            uint256 accFeeXOut_128,
            uint256 accFeeYOut_128,
            bool isEndpt,
            uint240 feeTimesL
        );

    /// @notice Returns 256 packed point (statusVal>0) boolean values. See PointBitmap for more information.
    function pointBitmap(int16 wordPosition) external view returns (uint256);

    /// @notice Returns the integral value of point(time) and integral value of 1/liquidity(time)
    ///     at some target timestamps (block.timestamp - secondsAgo[i])
    /// @dev Reverts if target timestamp is early than oldest observation in the queue
    /// @dev If you call this method with secondsAgos = [3600, 0]. the average point of this pool during recent hour is
    /// (accPoints[1] - accPoints[0]) / 3600
    /// @param secondsAgos describe the target timestamp , targetTimestimp[i] = block.timestamp - secondsAgo[i]
    /// @return accPoints integral value of point(time) from 0 to each target timestamp
    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory accPoints);

    /// @notice Expand max-length of observation queue.
    /// @param newNextQueueLen new value of observationNextQueueLen, which should be greater than current observationNextQueueLen
    function expandObservationQueue(uint16 newNextQueueLen) external;

    /// @notice Borrow tokenX and/or tokenY and pay it back within a block.
    /// @dev The caller needs to implement a IBiswapPoolV3#flashCallback callback function
    /// @param recipient the address which will receive the tokenY and/or tokenX
    /// @param amountX the amount of tokenX to borrow
    /// @param amountY the amount of tokenY to borrow
    /// @param data Any data to be passed through to the callback
    function flash(
        address recipient,
        uint256 amountX,
        uint256 amountY,
        bytes calldata data
    ) external;

    /// @notice Returns a snapshot infomation of Liquidity in [leftPoint, rightPoint).
    /// @param leftPoint left endpoint of range, should be times of pointDelta
    /// @param rightPoint right endpoint of range, should be times of pointDelta
    /// @return deltaLiquidities an array of delta liquidity for points in the range
    ///    note 1. delta liquidity here is amount of liquidity changed when cross a point from left to right
    ///    note 2. deltaLiquidities only contains points which are times of pointDelta
    ///    note 3. this function may cost a ENORMOUS amount of gas, be careful to call
    function liquiditySnapshot(int24 leftPoint, int24 rightPoint) external view returns(int128[] memory deltaLiquidities);

    struct LimitOrderStruct {
        uint128 sellingX;
        uint128 earnY;
        uint256 accEarnY;
        uint128 sellingY;
        uint128 earnX;
        uint256 accEarnX;
    }

    /// @notice Returns a snapshot infomation of Limit Order in [leftPoint, rightPoint).
    /// @param leftPoint left endpoint of range, should be times of pointDelta
    /// @param rightPoint right endpoint of range, should be times of pointDelta
    /// @return limitOrders an array of Limit Orders for points in the range
    ///    note 1. this function may cost a HUGE amount of gas, be careful to call
    function limitOrderSnapshot(int24 leftPoint, int24 rightPoint) external view returns(LimitOrderStruct[] memory limitOrders);

    /// @notice Amount of charged fee on tokenX.
    function totalFeeXCharged() external view returns(uint256);

    /// @notice Amount of charged fee on tokenY.
    function totalFeeYCharged() external view returns(uint256);

    /// @notice Percent to charge from miner's fee.
    function feeChargePercent() external view returns(uint24);

    /// @notice Collect charged fee, only factory's chargeReceiver can call.
    function collectFeeCharged() external;

    /// @notice modify 'feeChargePercent', only owner has authority.
    /// @param newFeeChargePercent new value of feeChargePercent, a nature number range in [0, 100],
    function modifyFeeChargePercent(uint24 newFeeChargePercent) external;

    function getCurrentFee() external view returns(uint16 _fee);

}

// SPDX-License-Identifier: GPL-2.0-or-later
/*
 * @title Solidity Bytes Arrays Utils
 * @author Gonçalo Sá <[email protected]>
 *
 * @dev Bytes tightly packed arrays utility library for ethereum contracts written in Solidity.
 *      The library lets you concatenate, slice and type cast bytes arrays both in memory and storage.
 */
pragma solidity ^0.8.4;

library BytesLib {

    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    ) internal pure returns (bytes memory) {
        require(_length + 31 >= _length, 'slice_overflow');
        require(_start + _length >= _start, 'slice_overflow');
        require(_bytes.length >= _start + _length, 'slice_outOfBounds');

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
                case 0 {
                    // Get a location of some free memory and store it in tempBytes as
                    // Solidity does for memory variables.
                    tempBytes := mload(0x40)

                    // The first word of the slice result is potentially a partial
                    // word read from the original array. To read it, we calculate
                    // the length of that partial word and start copying that many
                    // bytes into the array. The first word we copy will start with
                    // data we don't care about, but the last `lengthmod` bytes will
                    // land at the beginning of the contents of the new array. When
                    // we're done copying, we overwrite the full first word with
                    // the actual length of the slice.
                    let lengthmod := and(_length, 31)

                    // The multiplication in the next line is necessary
                    // because when slicing multiples of 32 bytes (lengthmod == 0)
                    // the following copy loop was copying the origin's length
                    // and then ending prematurely not copying everything it should.
                    let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                    let end := add(mc, _length)

                    for {
                        // The multiplication in the next line has the same exact purpose
                        // as the one above.
                        let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                    } lt(mc, end) {
                        mc := add(mc, 0x20)
                        cc := add(cc, 0x20)
                    } {
                        mstore(mc, mload(cc))
                    }

                    mstore(tempBytes, _length)

                    //update free-memory pointer
                    //allocating the array padded to 32 bytes like the compiler does now
                    mstore(0x40, and(add(mc, 31), not(31)))
                }
                //if we want a zero-length slice let's just return a zero-length array
                default {
                    tempBytes := mload(0x40)
                    //zero out the 32 bytes slice we are about to return
                    //we need to do it because Solidity does not garbage collect
                    mstore(tempBytes, 0)

                    mstore(0x40, add(tempBytes, 0x20))
                }
        }

        return tempBytes;
    }

    function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {
        require(_start + 20 >= _start, 'toAddress_overflow');
        require(_bytes.length >= _start + 20, 'toAddress_outOfBounds');
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toUint24(bytes memory _bytes, uint256 _start) internal pure returns (uint24) {
        require(_start + 3 >= _start, 'toUint24_overflow');
        require(_bytes.length >= _start + 3, 'toUint24_outOfBounds');
        uint24 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x3), _start))
        }

        return tempUint;
    }

    function toUint16(bytes memory _bytes, uint256 _start) internal pure returns (uint16) {
        require(_start + 2 >= _start, 'toUint16_overflow');
        require(_bytes.length >= _start + 2, 'toUint16_outOfBounds');
        uint16 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x2), _start))
        }

        return tempUint;
    }

}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.4;

import "./BytesLib.sol";

/// @title Functions for manipulating path data for multihop swaps
library Path {

    using BytesLib for bytes;

    /// @dev The length of the bytes encoded address
    uint256 private constant ADDR_SIZE = 20;
    /// @dev The length of the bytes encoded fee
    uint256 private constant FEE_SIZE = 2;

    /// @dev The offset of a single token address and pool fee
    uint256 private constant NEXT_OFFSET = ADDR_SIZE + FEE_SIZE;
    /// @dev The offset of an encoded pool key
    uint256 private constant POP_OFFSET = NEXT_OFFSET + ADDR_SIZE;
    /// @dev The minimum length of an encoding that contains 2 or more pools
    uint256 private constant MULTIPLE_POOLS_MIN_LENGTH = POP_OFFSET + NEXT_OFFSET;

    /// @notice Returns true iff the path contains two or more pools
    /// @param path The encoded swap path
    /// @return True if path contains two or more pools, otherwise false
    function hasMultiplePools(bytes memory path) internal pure returns (bool) {
        return path.length >= MULTIPLE_POOLS_MIN_LENGTH;
    }

    /// @notice Returns the number of pools in the path
    /// @param path The encoded swap path
    /// @return The number of pools in the path
    function numPools(bytes memory path) internal pure returns (uint256) {
        // Ignore the first token address. From then on every fee and token offset indicates a pool.
        return ((path.length - ADDR_SIZE) / NEXT_OFFSET);
    }

    /// @notice Decodes the first pool in path
    /// @param path The bytes encoded swap path
    /// @return tokenA The first token of the given pool
    /// @return tokenB The second token of the given pool
    /// @return fee The fee level of the pool
    function decodeFirstPool(bytes memory path)
        internal
        pure
        returns (
            address tokenA,
            address tokenB,
            uint16 fee
        )
    {
        tokenA = path.toAddress(0);
        fee = path.toUint16(ADDR_SIZE);
        tokenB = path.toAddress(NEXT_OFFSET);
    }

    /// @notice Gets the segment corresponding to the first pool in the path
    /// @param path The bytes encoded swap path
    /// @return The segment containing all data necessary to target the first pool in the path
    function getFirstPool(bytes memory path) internal pure returns (bytes memory) {
        return path.slice(0, POP_OFFSET);
    }

    /// @notice Skips a token + fee element from the buffer and returns the remainder
    /// @param path The swap path
    /// @return The remaining token + fee elements in the path
    function skipToken(bytes memory path) internal pure returns (bytes memory) {
        return path.slice(NEXT_OFFSET, path.length - NEXT_OFFSET);
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../../interfaces/IBiswapFactoryV3.sol";

/// @title Interface for WETH9
interface IWETH9 is IERC20 {
    /// @notice Deposit ether to get wrapped ether
    function deposit() external payable;

    /// @notice Withdraw wrapped ether to get ether
    function withdraw(uint256) external;
}

abstract contract Base {
    /// @notice address of BiswapFactoryV3
    address public immutable factory;

    /// @notice address of weth9 token
    address public immutable WETH9;

    modifier checkDeadline(uint256 deadline) {
        require(block.timestamp <= deadline, 'Out of time');
        _;
    }

    receive() external payable {}

    /// @notice Constructor of base.
    /// @param _factory address of BiswapFactoryV3
    /// @param _WETH9 address of weth9 token
    constructor(address _factory, address _WETH9) {
        factory = _factory;
        WETH9 = _WETH9;
    }

    /// @notice Make multiple function calls in this contract in a single transaction
    ///     and return the data for each function call, revert if any function call fails
    /// @param data The encoded function data for each function call
    /// @return results result of each function call
    function multicall(bytes[] calldata data) external payable returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);

            if (!success) {
                if (result.length < 68) revert();
                assembly {
                    result := add(result, 0x04)
                }
                revert(abi.decode(result, (string)));
            }

            results[i] = result;
        }
    }

    /// @notice Transfer tokens from the targeted address to the given destination
    /// @notice Errors with 'STF' if transfer fails
    /// @param token The contract address of the token to be transferred
    /// @param from The originating address from which the tokens will be transferred
    /// @param to The destination address of the transfer
    /// @param value The amount to be transferred
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'STF');
    }

    /// @notice Transfer tokens from msg.sender to a recipient
    /// @dev Errors with ST if transfer fails
    /// @param token The contract address of the token which will be transferred
    /// @param to The recipient of the transfer
    /// @param value The value of the transfer
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'ST');
    }

    /// @notice Approve the stipulated contract to spend the given allowance in the given token
    /// @dev Errors with 'SA' if transfer fails
    /// @param token The contract address of the token to be approved
    /// @param to The target of the approval
    /// @param value The amount of the given token the target will be allowed to spend
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SA');
    }

    /// @notice Transfer ETH to the recipient address
    /// @dev Fails with `STE`
    /// @param to The destination of the transfer
    /// @param value The value to be transferred
    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'STE');
    }

    /// @notice Withdraw all weth9 token of this contract and send the withdrawed eth to recipient
    ///    usually used in multicall when mint/swap/update limitorder with eth
    ///    normally this contract has no any erc20 token or eth after or before a transaction
    ///    we donot need to worry that some one can steal eth from this contract
    /// @param minAmount The minimum amount of WETH9 to withdraw
    /// @param recipient The address to receive all withdrawed eth from this contract
    function unwrapWETH9(uint256 minAmount, address recipient) external payable {
        uint256 all = IWETH9(WETH9).balanceOf(address(this));
        require(all >= minAmount, 'WETH9 Not Enough');

        if (all > 0) {
            IWETH9(WETH9).withdraw(all);
            safeTransferETH(recipient, all);
        }
    }

    /// @notice Send all balance of specified token in this contract to recipient
    ///    usually used in multicall when mint/swap/update limitorder with eth
    ///    normally this contract has no any erc20 token or eth after or before a transaction
    ///    we donot need to worry that some one can steal some token from this contract
    /// @param token address of the token
    /// @param minAmount balance should >= minAmount
    /// @param recipient the address to receive specified token from this contract
    function sweepToken(
        address token,
        uint256 minAmount,
        address recipient
    ) external payable {
        uint256 all = IERC20(token).balanceOf(address(this));
        require(all >= minAmount, 'WETH9 Not Enough');

        if (all > 0) {
            safeTransfer(token, recipient, all);
        }
    }

    /// @notice Send all balance of eth in this contract to msg.sender
    ///    usually used in multicall when mint/swap/update limitorder with eth
    ///    normally this contract has no any erc20 token or eth after or before a transaction
    ///    we donot need to worry that some one can steal some token from this contract
    function refundETH() external payable {
        if (address(this).balance > 0) safeTransferETH(msg.sender, address(this).balance);
    }

    /// @param token The token to pay
    /// @param payer The entity that must pay
    /// @param recipient The entity that will receive payment
    /// @param value The amount to pay
    function pay(
        address token,
        address payer,
        address recipient,
        uint256 value
    ) internal {
        if (token == WETH9 && address(this).balance >= value) {
            // pay with WETH9
            IWETH9(WETH9).deposit{value: value}(); // wrap only what is needed to pay
            IWETH9(WETH9).transfer(recipient, value);
        } else if (payer == address(this)) {
            // pay with tokens already in the contract (for the exact input multihop case)
            safeTransfer(token, recipient, value);
        } else {
            // pull payment
            safeTransferFrom(token, payer, recipient, value);
        }
    }

    /// @notice Query pool address from factory by (tokenX, tokenY, fee).
    /// @param tokenX tokenX of swap pool
    /// @param tokenY tokenY of swap pool
    /// @param fee fee amount of swap pool
    function pool(address tokenX, address tokenY, uint16 fee) public view returns(address) {
        (address token0, address token1) = tokenX < tokenY ? (tokenX, tokenY) : (tokenY, tokenX);
        return address(uint160(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encode(token0, token1, fee)),
                hex'1ce2ccf1b7bdba79c33fb1280dec920e7ac26faee47e5ef92deda7b4f6378b2a'
            )))));
    }
    //
    function verify(address tokenX, address tokenY, uint16 fee) internal view {
        require (msg.sender == pool(tokenX, tokenY, fee), "sp");
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.4;

import "../interfaces/IBiswapCallback.sol";
import "../interfaces/IBiswapFactoryV3.sol";
import "../interfaces/IBiswapPoolV3.sol";

import "../libraries/Path.sol";

import "./base/base.sol";

contract Quoter is Base, IBiswapCallback {

    using Path for bytes;

    struct SwapCallbackData {
        bytes path;
        address payer;
    }

    uint256 private amountDesireCached;

    /// @notice Construct this contract.
    /// @param _factory address BiswapFactoryV3
    /// @param _weth address of weth token
    constructor(address _factory, address _weth) Base(_factory, _weth) {}


    /// @notice Make multiple function calls in this contract in a single transaction
    ///     and return the data for each function call, donot revert if any function call fails
    /// @param data The encoded function data for each function call
    /// @return successes whether catch a revert in the function call of data[i]
    /// @return results result of each function call
    function multicallNoRevert(bytes[] calldata data) external payable returns (bool[]memory successes, bytes[] memory results) {
        results = new bytes[](data.length);
        successes = new bool[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);

            successes[i] = success;
            results[i] = result;
        }
    }

    function parseRevertReason(bytes memory reason)
        private
        pure
        returns (
            uint256 amount,
            int24 currPt
        )
    {
        if (reason.length != 64) {
            if (reason.length < 68) revert('Unexpected error');
            assembly {
                reason := add(reason, 0x04)
            }
            revert(abi.decode(reason, (string)));
        }
        return abi.decode(reason, (uint256, int24));
    }

    /// @notice Callback for swapY2X and swapY2XDesireX, in order to mark computed-amount of token and point after exchange.
    /// @param x amount of tokenX trader acquired
    /// @param y amount of tokenY need to pay from trader
    /// @param path encoded SwapCallbackData
    function swapY2XCallback(
        uint256 x,
        uint256 y,
        bytes calldata path
    ) external view override {
        (address token0, address token1, uint16 fee) = path.decodeFirstPool();
        verify(token0, token1, fee);

        address poolAddr = pool(token0, token1, fee);
        (
            ,
            int24 currPt,
            ,
            ,
            ,
            ,
            ,
            ,
            ,
        ) = IBiswapPoolV3(poolAddr).state();

        if (token0 < token1) {
            // token1 is y, amount of token1 is calculated
            // called from swapY2XDesireX(...)
            require(x >= amountDesireCached, 'x Pool Not Enough');
            assembly {
                let ptr := mload(0x40)
                mstore(ptr, y)
                mstore(add(ptr, 0x20), currPt)
                revert(ptr, 64)
            }
        } else {
            // token0 is y, amount of token0 is input param
            // called from swapY2X(...)
            assembly {
                let ptr := mload(0x40)
                mstore(ptr, x)
                mstore(add(ptr, 0x20), currPt)
                revert(ptr, 64)
            }
        }
    }

    /// @notice Callback for swapX2Y and swapX2YDesireY in order to mark computed-amount of token and point after exchange.
    /// @param x amount of tokenX need to pay from trader
    /// @param y amount of tokenY trader acquired
    /// @param path encoded SwapCallbackData
    function swapX2YCallback(
        uint256 x,
        uint256 y,
        bytes calldata path
    ) external view override {
        (address token0, address token1, uint16 fee) = path.decodeFirstPool();
        verify(token0, token1, fee);

        address poolAddr = pool(token0, token1, fee);
        (
            ,
            int24 currPt,
            ,
            ,
            ,
            ,
            ,
            ,
            ,
        ) = IBiswapPoolV3(poolAddr).state();

        if (token0 < token1) {
            // token0 is x, amount of token0 is input param
            // called from swapX2Y(...)
            assembly {
                let ptr := mload(0x40)
                mstore(ptr, y)
                mstore(add(ptr, 0x20), currPt)
                revert(ptr, 64)
            }
        } else {
            // token1 is x, amount of token1 is calculated param
            // called from swapX2YDesireY(...)
            require(y >= amountDesireCached, 'y Pool Not Enough');
            assembly {
                let ptr := mload(0x40)
                mstore(ptr, x)
                mstore(add(ptr, 0x20), currPt)
                revert(ptr, 64)
            }
        }
    }

    function swapAmountSingleInternal(
        address tokenIn,
        address tokenOut,
        uint16 fee,
        uint128 amount
    ) private returns (uint256 acquire, int24 currPt) {
        address poolAddr = pool(tokenOut, tokenIn, fee);
        if (tokenIn < tokenOut) {
            int24 boundaryPoint = -799999;
            try
                IBiswapPoolV3(poolAddr).swapX2Y(
                    address(this), amount, boundaryPoint,
                    abi.encodePacked(tokenIn, fee, tokenOut)
                )
            {} catch (bytes memory reason) {
                return parseRevertReason(reason);
            }
        } else {
            int24 boundaryPoint = 799999;
            try
                IBiswapPoolV3(poolAddr).swapY2X(
                    address(this), amount, boundaryPoint,
                    abi.encodePacked(tokenIn, fee, tokenOut)
                )
            {} catch (bytes memory reason) {
                return parseRevertReason(reason);
            }
        }
    }

    function swapAmount(
        uint128 amount,
        bytes memory path
    ) public returns (uint256 acquire, int24[] memory pointAfterList) {
        // allow swapping to the router address with address 0

        uint256 i = 0;
        pointAfterList = new int24[](path.numPools());

        while (true) {
            bool hasMultiplePools = path.hasMultiplePools();
            (address tokenIn, address tokenOut, uint16 fee) = path.decodeFirstPool();
            int24 finalPt;
            (acquire, finalPt) = swapAmountSingleInternal(tokenIn, tokenOut, fee, amount);
            pointAfterList[i] = finalPt;
            i ++;

            // decide whether to continue or terminate
            if (hasMultiplePools) {
                path = path.skipToken();
                amount = uint128(acquire);
            } else {
                break;
            }
        }
    }

    function swapDesireSingleInternal(
        address tokenIn,
        address tokenOut,
        uint16 fee,
        uint128 desire
    ) private returns (uint256 cost, int24 currPt) {
        address poolAddr = pool(tokenOut, tokenIn, fee);
        amountDesireCached = desire;
        if (tokenIn < tokenOut) {
            int24 boundaryPoint = -799999;
            try
                IBiswapPoolV3(poolAddr).swapX2YDesireY(
                    address(this), desire + 1, boundaryPoint,
                    abi.encodePacked(tokenOut, fee, tokenIn)
                )
            {} catch (bytes memory reason) {
                return parseRevertReason(reason);
            }
        } else {
            int24 boundaryPoint = 799999;
            try
                IBiswapPoolV3(poolAddr).swapY2XDesireX(
                    address(this), desire + 1, boundaryPoint,
                    abi.encodePacked(tokenOut, fee, tokenIn)
                )
            {} catch (bytes memory reason) {
                return parseRevertReason(reason);
            }
        }
    }

    function swapDesire(
        uint128 desire,
        bytes memory path
    ) public returns (uint256 cost, int24[] memory pointAfterList) {
        // allow swapping to the router address with address 0

        uint256 i = 0;
        pointAfterList = new int24[](path.numPools());

        while (true) {
            bool hasMultiplePools = path.hasMultiplePools();
            (address tokenOut, address tokenIn, uint16 fee) = path.decodeFirstPool();
            int24 finalPt;
            (cost, finalPt) = swapDesireSingleInternal(tokenIn, tokenOut, fee, desire);
            pointAfterList[i] = finalPt;
            i ++;

            // decide whether to continue or terminate
            if (hasMultiplePools) {
                path = path.skipToken();
                desire = uint128(cost);
            } else {
                break;
            }
        }
    }

    /// @notice Estimate amount of tokenX acquired when user wants to buy tokenX given max amount of tokenY user willing to pay.
    /// calling this function will not generate any real exchanges in the pool
    /// @param tokenX tokenX of swap pool
    /// @param tokenY tokenY of swap pool
    /// @param fee fee amount of swap pool
    /// @param amount max-amount of tokenY user willing to pay
    /// @param highPt highest point during exchange
    /// @return amountX estimated amount of tokenX user would acquire
    /// @return finalPoint estimated point of pool after swap
    function swapY2X(
        address tokenX,
        address tokenY,
        uint16 fee,
        uint128 amount,
        int24 highPt
    ) public returns (uint256 amountX, int24 finalPoint) {
        require(tokenX < tokenY, "x<y");
        address poolAddr = pool(tokenX, tokenY, fee);
        try
            IBiswapPoolV3(poolAddr).swapY2X(
                address(this), amount, highPt,
                abi.encodePacked(tokenY, fee, tokenX)
            )
        {} catch (bytes memory reason) {
            (amountX, finalPoint) = parseRevertReason(reason);
        }
    }

    /// @notice Estimate amount of tokenY required when an user wants to buy token given amount of tokenX user wants to buy
    ///    calling this function will not generate any real exchanges in the pool.
    /// @param tokenX tokenX of swap pool
    /// @param tokenY tokenY of swap pool
    /// @param fee fee amount of swap pool
    /// @param desireX amount of tokenX user wants to buy
    /// @param highPt highest point during exchange
    /// @return amountY estimated amount of tokenY user need to pay
    /// @return finalPoint estimated point of pool after swap
    function swapY2XDesireX(
        address tokenX,
        address tokenY,
        uint16 fee,
        uint128 desireX,
        int24 highPt
    ) public returns (uint256 amountY, int24 finalPoint) {
        require(tokenX < tokenY, "x<y");
        address poolAddr = pool(tokenX, tokenY, fee);
        if (highPt == 800001) {
            // highPt higher than rightMostPt
            // means user wants to get enough X
            amountDesireCached = desireX;
        }
        try
            IBiswapPoolV3(poolAddr).swapY2XDesireX(
                address(this), desireX, highPt,
                abi.encodePacked(tokenX, fee, tokenY)
            )
        {} catch (bytes memory reason) {
            (amountY, finalPoint) = parseRevertReason(reason);
        }
        amountDesireCached = 0;
    }

    /// @notice Estimate amount of tokenY acquired when an user wants to buy tokenY given max amount of tokenX user willing to pay
    ///    calling this function will not generate any real exchanges in the pool.
    /// @param tokenX tokenX of swap pool
    /// @param tokenY tokenY of swap pool
    /// @param fee fee amount of swap pool
    /// @param amount max-amount of tokenX user willing to pay
    /// @param lowPt lowest point during exchange
    /// @return amountY estimated amount of tokenY user would acquire
    /// @return finalPoint estimated point of pool after swap
    function swapX2Y(
        address tokenX,
        address tokenY,
        uint16 fee,
        uint128 amount,
        int24 lowPt
    ) public returns (uint256 amountY, int24 finalPoint) {
        require(tokenX < tokenY, "x<y");
        address poolAddr = pool(tokenX, tokenY, fee);
        try
            IBiswapPoolV3(poolAddr).swapX2Y(
                address(this), amount, lowPt,
                abi.encodePacked(tokenX, fee, tokenY)
            )
        {} catch (bytes memory reason) {
            (amountY, finalPoint) = parseRevertReason(reason);
        }
    }

    /// @notice Estimate amount of tokenX required when an user wants to buy tokenY given amount of tokenX user wants to buy
    ///    calling this function will not generate any real exchanges in the pool.
    /// @param tokenX tokenX of swap pool
    /// @param tokenY tokenY of swap pool
    /// @param fee fee amount of swap pool
    /// @param desireY amount of tokenY user wants to buy
    /// @param lowPt highest point during exchange
    /// @return amountX estimated amount of tokenX user need to pay
    /// @return finalPoint estimated point of pool after swap
    function swapX2YDesireY(
        address tokenX,
        address tokenY,
        uint16 fee,
        uint128 desireY,
        int24 lowPt
    ) public returns (uint256 amountX, int24 finalPoint) {
        require(tokenX < tokenY, "x<y");
        address poolAddr = pool(tokenX, tokenY, fee);
        if (lowPt == -800001) {
            // lowPt lower than leftMostPt
            // means user wants to get enough Y
            amountDesireCached = desireY;
        }
        try
            IBiswapPoolV3(poolAddr).swapX2YDesireY(
                address(this), desireY, lowPt,
                abi.encodePacked(tokenY, fee, tokenX)
            )
        {} catch (bytes memory reason) {
            (amountX, finalPoint) = parseRevertReason(reason);
        }
        amountDesireCached = 0;
    }

}
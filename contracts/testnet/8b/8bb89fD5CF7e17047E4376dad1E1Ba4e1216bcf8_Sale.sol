// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interface/IMGR.sol";
import "./interface/IPancakeRoute.sol";
import "./libraries/Formula.sol";
import "./libraries/Config.sol";
import "./libraries/TransferHelper.sol";

contract Sale is Ownable, ReentrancyGuard {
    struct DistributeInfo {
        uint256 amount;
        uint256 withdrawTime;
        bool isWithdrawed;
    }

    IMGR public immutable token;
    address public immutable fundsReceiver;
    address public immutable liquidity;
    address public immutable WBNB;
    address public immutable BUSD;
    address public immutable pancakeRoute;

    /// Boolean variable to provide the status of sale finalization.
    bool public isSaleFinalized;

    uint256 public soldTokenAmount;
    uint256 public withdrawStartTime;
    uint256 internal constant ONE_MONTH = 3600;
    uint256 internal constant WITHDRAWAL_NUMBER = 12;

    mapping(address => uint256) public boughtCashes;

    // get person who send ref to this
    mapping(address => address) public refOf;
    mapping(address => DistributeInfo[]) public tokenDistribute;

    event SetWithdrawStartTime(uint256 withdrawStartTime);
    event WithdrawBoughtTokens(address indexed acc, uint256 amount, uint256 withdrawedAt);
    event PublicSaleTokens(address indexed buyer, address indexed refferal, uint256 usdt, uint256 token, uint256 boughtAt);
    event PublicSaleTokensWithRefferal(address indexed buyer, address indexed refferal, uint256 usdt, uint256 boughtAt);
    event SaleFinalized(uint256 burnedAmount, uint256 finalizedSaleAt);

    /// @dev Constructor to set initial values for the contract.
    ///
    /// @param _token Address of the token that gets distributed.
    /// @param _fundsReceiver Address that receives the funds collected from the sale.
    constructor(address _liquidity, address _fundsReceiver, IMGR _token, address _WBNB, address _BUSD, address _pancakeRoute) {
        token = _token;
        fundsReceiver = _fundsReceiver;
        liquidity = _liquidity;
        WBNB = _WBNB;
        BUSD = _BUSD;
        pancakeRoute = _pancakeRoute;

        // Set finalize status to false.
        isSaleFinalized = false;
    }

    modifier hasSaleRunning() {
        require(!isSaleFinalized, "Sale has ended");
        _;
    }

    function setWithdrawStartTime(
        uint256 _withdrawStartTime
    ) external onlyOwner {
        require(
            _withdrawStartTime > block.timestamp,
            "Invalid times"
        );
        withdrawStartTime = _withdrawStartTime;
        emit SetWithdrawStartTime(_withdrawStartTime);
    }

    function withdrawTokens() external {
        require(block.timestamp >= withdrawStartTime, "It is not withdraw time yet");

        uint256 amount = _updateDistributions(_msgSender());
        require(amount > 0, "Nothing to withdraw now");

        TransferHelper.safeTransfer(address(token), _msgSender(), amount);
        emit WithdrawBoughtTokens(_msgSender(), amount, block.timestamp);
    }

    function _updateDistributions(address _acc) private returns (uint256) {
        uint256 withdrawableAmount;
        uint256 currentTime = block.timestamp;

        DistributeInfo[] storage distributeInfo = tokenDistribute[_acc];
        for (uint256 i = 0; i < distributeInfo.length; i++) {
            DistributeInfo storage item = distributeInfo[i];
            if (currentTime >= item.withdrawTime && !item.isWithdrawed) {
                withdrawableAmount += item.amount;
                item.isWithdrawed = true;
            }
        }
        return withdrawableAmount;
    }

    /// @dev Used to buy tokens using BNB. It is only allowed to call when sale is running.
    function buyTokens(address _refferal) external payable nonReentrant hasSaleRunning {
        uint256 _amount = getValueBNB(msg.value);
        require(_amount >= Constant.SALE_MIN_AMOUNT, "Value is less than $150");
        address refAddr = address(0);
        uint256 fundsReceiverAmount = Formula.mulDiv(msg.value, Constant.FUNDING_RECEIVER_RATE, 100);
        if(refOf[_msgSender()] == address(0)){
            if(boughtCashes[_msgSender()] > 0){
                // already buy but dont use ref
                TransferHelper.safeTransferBNB(fundsReceiver, fundsReceiverAmount);
                TransferHelper.safeTransferBNB(liquidity, msg.value - fundsReceiverAmount);
            }
            else { // never buy before
                uint256 refferalRewardAmount;
                if (boughtCashes[_refferal] >= Constant.SALE_MIN_AMOUNT) {
                    refferalRewardAmount = Formula.mulDiv(msg.value, Constant.REFERRAL_REWARD_RATE, 100);
                    TransferHelper.safeTransferBNB(_refferal, refferalRewardAmount);
                    emit PublicSaleTokensWithRefferal(_msgSender(), _refferal, _amount, block.timestamp);
                }
                TransferHelper.safeTransferBNB(fundsReceiver, fundsReceiverAmount);
                TransferHelper.safeTransferBNB(liquidity, msg.value - fundsReceiverAmount - refferalRewardAmount);

                //update ref info
                refOf[_msgSender()] = _refferal;
                refAddr = _refferal;
            }
        }
        else {
            // buy ok but not use _refferal param
            address ownerRefOfSender = refOf[_msgSender()];
            uint256 refferalRewardAmount;
            if (ownerRefOfSender != _msgSender() && boughtCashes[ownerRefOfSender] >= Constant.SALE_MIN_AMOUNT) {
                refferalRewardAmount = Formula.mulDiv(msg.value, Constant.REFERRAL_REWARD_RATE, 100);
                TransferHelper.safeTransferBNB(ownerRefOfSender, refferalRewardAmount);
                emit PublicSaleTokensWithRefferal(_msgSender(), ownerRefOfSender, _amount, block.timestamp);

            }
            TransferHelper.safeTransferBNB(fundsReceiver, fundsReceiverAmount);
            TransferHelper.safeTransferBNB(liquidity,  msg.value - fundsReceiverAmount - refferalRewardAmount);

            refAddr = ownerRefOfSender;
        }
        boughtCashes[_msgSender()] += _amount;

        uint256 tokensToSale = _calculateTokenToSale(_amount);

        emit PublicSaleTokens(_msgSender(), refAddr, _amount, tokensToSale, block.timestamp);

    }

    function _calculateTokenToSale(uint256 _amount) private returns (uint256) {
        // Calculate the amount of tokens to sale.
        uint256 tokensToSale = Formula.mulDiv(_amount, Formula.SCALE, Constant.PUBLIC_SALE_RATE);
        _checkSoldOut(tokensToSale);
        soldTokenAmount += tokensToSale;

        uint256 firstReceivedAmount = Formula.mulDiv(tokensToSale, Constant.SALE_FIRST_RECEIVE_RATE, 100);
        TransferHelper.safeTransfer(address(token), _msgSender(), firstReceivedAmount);

        uint256 remainTokenAmount = tokensToSale - firstReceivedAmount;
        _addToTokenDistributions(remainTokenAmount);

        return tokensToSale;
    }

    function _addToTokenDistributions(uint256 remainTokenAmount) private {
        uint256 amountEach = remainTokenAmount / WITHDRAWAL_NUMBER;
        uint256 currentTime = block.timestamp;
        uint256 updatedCount;
        uint256 lastWithdrawTime = withdrawStartTime;

        // If already bought before
        if (tokenDistribute[_msgSender()].length > 0) {
            for (uint256 i = 0; i < tokenDistribute[_msgSender()].length; i++) {
                DistributeInfo storage distributeInfo = tokenDistribute[_msgSender()][i];
                if (currentTime < distributeInfo.withdrawTime) {
                    distributeInfo.amount += amountEach;
                    updatedCount++;
                }
            }
            lastWithdrawTime = tokenDistribute[_msgSender()][tokenDistribute[_msgSender()].length - 1].withdrawTime + ONE_MONTH;
        }

        // Add new token distribution
        if (currentTime > lastWithdrawTime) {
            uint256 step = (currentTime - lastWithdrawTime) / ONE_MONTH + 1;
            lastWithdrawTime += (step * ONE_MONTH);
        }

        for (uint256 i = updatedCount; i < WITHDRAWAL_NUMBER; i++) {
            tokenDistribute[_msgSender()].push(
                DistributeInfo(amountEach, lastWithdrawTime, false)
            );
            lastWithdrawTime += ONE_MONTH;
        }
    }

    /// @dev Finalize the sale. Only be called by the owner of the contract.
    function finalizeSale() external onlyOwner {
        // Should not already be finalized.
        require(!isSaleFinalized, "Already finalized");

        // Set finalized status to be true as it not repeatatedly called.
        isSaleFinalized = true;

        // Burn remain tokens
        uint256 remainTokens = Constant.SALE_MINT_TOKEN_AMOUNT - soldTokenAmount;
        token.burnToken(remainTokens);

        // Emit even.
        emit SaleFinalized(remainTokens, block.timestamp);
    }

    function _checkSoldOut(uint256 _tokenAmount) private view {
        uint256 expectedSoldAmount = soldTokenAmount + _tokenAmount;
        require(expectedSoldAmount <= Constant.SALE_MINT_TOKEN_AMOUNT, "Public sale is sold out");
    }

    function getTokenDistributtionOf(address _acc) external view returns (DistributeInfo[] memory distributeInfo) {
        distributeInfo = tokenDistribute[_acc];
    }

    function getWithdrawableAmount(address _acc) external view returns (uint256 amount) {
        uint256 currentTime = block.timestamp;

        DistributeInfo[] memory distributeInfo = tokenDistribute[_acc];
        for (uint256 i = 0; i < distributeInfo.length; i++) {
            DistributeInfo memory item = distributeInfo[i];
            if (currentTime >= item.withdrawTime && !item.isWithdrawed) {
                amount += item.amount;
            }
        }
    }

    function getRemainingTokenAmount(address _acc) external view returns (uint256 remainToken) {
        DistributeInfo[] memory distributeInfo = tokenDistribute[_acc];
        for (uint256 i = 0; i < distributeInfo.length; i++) {
            DistributeInfo memory item = distributeInfo[i];
            if (!item.isWithdrawed) {
                remainToken += item.amount;
            }
        }
    }

    function getValueBNB(uint256 amount) public view returns(uint256){
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = BUSD;
        uint[] memory result = IPancakeRoute(pancakeRoute).getAmountsOut(amount, path);
        return result[1];
    }
}

// SPDX-License-Identifier: MIT

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IMGR {
    function addMinter(address minter) external;
    function removeMinter(address minter) external;
    function mintToken(address receiver, uint256 amount) external;
    function burnToken(uint256 amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IPancakeRoute {
    function getAmountsOut(uint amountIn, address[] memory path)
        external
        view
        returns (uint[] memory amounts);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./Config.sol";

/// @notice Emitted when the result overflows uint256.
error PRBMath__MulDivFixedPointOverflow(uint256 prod1);

/// @notice Emitted when the result overflows uint256.
error PRBMath__MulDivOverflow(uint256 prod1, uint256 denominator);

/// @dev This library does not always assume the signed 59.18-decimal fixed-point or the unsigned 60.18-decimal 
/// fixed-point representation. When it does not, it is explicitly mentioned in the NatSpec documentation.
library Formula {
    /// STORAGE ///

    /// @dev How many trailing decimals can be represented.
    uint256 internal constant SCALE = 1e18;

    /// @dev Largest power of two divisor of SCALE.
    uint256 internal constant SCALE_LPOTD = 262144;

    /// @dev SCALE inverted mod 2^256.
    uint256 internal constant SCALE_INVERSE =
        78156646155174841979727994598816262306175212592076161876661_508869554232690281;

    /// FUNCTIONS ///

    /// @notice Calculates floor(x*y÷denominator) with full precision.
    ///
    /// @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv.
    ///
    /// Requirements:
    /// - The denominator cannot be zero.
    /// - The result must fit within uint256.
    ///
    /// Caveats:
    /// - This function does not work with fixed-point numbers.
    ///
    /// @param x The multiplicand as an uint256.
    /// @param y The multiplier as an uint256.
    /// @param denominator The divisor as an uint256.
    /// @return result The result as an uint256.
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
        // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
        // variables such that product = prod1 * 2^256 + prod0.
        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product
        assembly {
            let mm := mulmod(x, y, not(0))
            prod0 := mul(x, y)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        // Handle non-overflow cases, 256 by 256 division.
        if (prod1 == 0) {
            unchecked {
                result = prod0 / denominator;
            }
            return result;
        }

        // Make sure the result is less than 2^256. Also prevents denominator == 0.
        if (prod1 >= denominator) {
            revert PRBMath__MulDivOverflow(prod1, denominator);
        }

        ///////////////////////////////////////////////
        // 512 by 256 division.
        ///////////////////////////////////////////////

        // Make division exact by subtracting the remainder from [prod1 prod0].
        uint256 remainder;
        assembly {
            // Compute remainder using mulmod.
            remainder := mulmod(x, y, denominator)

            // Subtract 256 bit number from 512 bit number.
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }

        // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
        // See https://cs.stackexchange.com/q/138556/92363.
        unchecked {
            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 lpotdod = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by lpotdod.
                denominator := div(denominator, lpotdod)

                // Divide [prod1 prod0] by lpotdod.
                prod0 := div(prod0, lpotdod)

                // Flip lpotdod such that it is 2^256 / lpotdod. If lpotdod is zero, then it becomes one.
                lpotdod := add(div(sub(0, lpotdod), lpotdod), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * lpotdod;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /// @notice Calculates floor(x*y÷1e18) with full precision.
    ///
    /// @dev Variant of "mulDiv" with constant folding, i.e. in which the denominator is always 1e18. Before returning the
    /// final result, we add 1 if (x * y) % SCALE >= HALF_SCALE. Without this, 6.6e-19 would be truncated to 0 instead of
    /// being rounded to 1e-18.  See "Listing 6" and text above it at https://accu.org/index.php/journals/1717.
    ///
    /// Requirements:
    /// - The result must fit within uint256.
    ///
    /// Caveats:
    /// - The body is purposely left uncommented; see the NatSpec comments in "PRBMath.mulDiv" to understand how this works.
    /// - It is assumed that the result can never be type(uint256).max when x and y solve the following two equations:
    ///     1. x * y = type(uint256).max * SCALE
    ///     2. (x * y) % SCALE >= SCALE / 2
    ///
    /// @param x The multiplicand as an unsigned 60.18-decimal fixed-point number.
    /// @param y The multiplier as an unsigned 60.18-decimal fixed-point number.
    /// @return result The result as an unsigned 60.18-decimal fixed-point number.
    function mulDivFixedPoint(uint256 x, uint256 y) internal pure returns (uint256 result) {
        uint256 prod0;
        uint256 prod1;
        assembly {
            let mm := mulmod(x, y, not(0))
            prod0 := mul(x, y)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        if (prod1 >= SCALE) {
            revert PRBMath__MulDivFixedPointOverflow(prod1);
        }

        uint256 remainder;
        uint256 roundUpUnit;
        assembly {
            remainder := mulmod(x, y, SCALE)
            roundUpUnit := gt(remainder, 499999999999999999)
        }

        if (prod1 == 0) {
            unchecked {
                result = (prod0 / SCALE) + roundUpUnit;
                return result;
            }
        }

        assembly {
            result := add(
                mul(
                    or(
                        div(sub(prod0, remainder), SCALE_LPOTD),
                        mul(sub(prod1, gt(remainder, prod0)), add(div(sub(0, SCALE_LPOTD), SCALE_LPOTD), 1))
                    ),
                    SCALE_INVERSE
                ),
                roundUpUnit
            )
        }
    }

    /// @notice Raises x (unsigned 60.18-decimal fixed-point number) to the power of y (basic unsigned integer) using the
    /// famous algorithm "exponentiation by squaring".
    ///
    /// @dev See https://en.wikipedia.org/wiki/Exponentiation_by_squaring
    ///
    /// Requirements:
    /// - The result must fit within MAX_UD60x18.
    ///
    /// Caveats:
    /// - All from "mul".
    /// - Assumes 0^0 is 1.
    ///
    /// @param x The base as an unsigned 60.18-decimal fixed-point number.
    /// @param y The exponent as an uint256.
    /// @return result The result as an unsigned 60.18-decimal fixed-point number.
    function pow(uint256 x, uint256 y) internal pure returns (uint256 result) {
        // Calculate the first iteration of the loop in advance.
        result = y & 1 > 0 ? x : SCALE;

        // Equivalent to "for(y /= 2; y > 0; y /= 2)" but faster.
        for (y >>= 1; y > 0; y >>= 1) {
            x = mulDivFixedPoint(x, x);

            // Equivalent to "y % 2 == 1" but faster.
            if (y & 1 > 0) {
                result = mulDivFixedPoint(result, x);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

library Constant {
    uint256 internal constant FIXED_POINT = 1e18;
    uint256 internal constant MAX_TOKEN_TOTAL_SUPPLY = 38e25; // 380M token

    /// Rates for different phases of the sale.
    uint256 public constant PUBLIC_SALE_RATE  = 6000000000000000;  /// 1 tokens = 0.006 USD

    uint256 public constant FIRST_MINT_TOKEN_AMOUNT = 247000000 * FIXED_POINT; // 65% token 
    uint256 public constant SALE_MIN_AMOUNT         = 150 * FIXED_POINT; /// sale min 150$

    uint256 public constant REFERRAL_REWARD_RATE    = 8; /// 8% USD amount of buying tokens
    uint256 public constant FUNDING_RECEIVER_RATE = 52;  /// 52% USD amount return to fundsReceiver
    uint256 public constant SALE_FIRST_RECEIVE_RATE = 10; /// 10% of bought tokens

    /// Tokenomics's token amount
    uint256 public constant SALE_MINT_TOKEN_AMOUNT = 76000000 * FIXED_POINT; // 20% tokens

    uint256 public constant AIRDROP_MINT_TOKEN_AMOUNT   = 3800000 * FIXED_POINT; // 1% token
    uint256 public constant LIQUIDITY_MINT_TOKEN_AMOUNT = 30400000 * FIXED_POINT; // 8% token
    uint256 public constant TREASURY_MINT_TOKEN_AMOUNT  = 136800000 * FIXED_POINT; // 36% token

    uint256 public constant BD_INVESTOR_TOKEN_AMOUNT    = 68400000; // 18% token

    uint256 public constant MARKETING_TOKEN_AMOUNT      = 34200000; // 9% token
    uint256 public constant TECH_TOKEN_AMOUNT           = 34200000; // 9% token
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: APPROVE_FAILED"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }

    function safeTransferBNB(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: BNB_TRANSFER_FAILED");
    }
}

// SPDX-License-Identifier: MIT

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
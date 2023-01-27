// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";

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
pragma solidity 0.8.4;

interface IETF {

    function rebase(uint256 epoch, uint256 supplyDelta, bool positive) external;
    function mint(address to, uint256 amount) external;
    function getPriorBalance(address account, uint blockNumber) external view returns (uint256);
    function mintForReferral(address to, uint256 amount) external;
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function balanceOf(address who) external view returns (uint256);
    function transferForRewards(address to, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
}

//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.4;

interface INFTFactory {
    function isHandler(address) external view returns (bool);
    function getHandler(uint256) external view returns (address);
    function getEpoch(address) external view returns (uint256);
    function alertLevel(uint256, uint256) external;
    function alertSelfTaxClaimed(uint256, uint256) external;
    function alertReferralClaimed(uint256, uint256) external;
    function alertDepositClaimed(uint256, uint256) external;
    function registerUserEpoch(address) external;
    function updateUserEpoch(address, uint256) external;
    function getTierManager() external view returns(address);
    function getTaxManager() external view returns(address);
    function getRebaser() external view returns(address);
    function getRewarder() external view returns(address);
    function getAdmin() external view returns(address);
    function getHandlerForUser(address) external view returns (address);
    function getDepositBox(uint256) external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IRebaser {

  function getPositiveEpochCount() external view returns (uint256);
  function getBlockForPositiveEpoch(uint256) external view returns (uint256);
  function getDeltaForPositiveEpoch(uint256) external view returns (uint256);

}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IReferralHandler {
    function initialize(address, address, address, uint256) external;
    function setTier(uint256 _tier) external;
    function setDepositBox(address) external;
    function checkExistence(uint256, address) external view returns (address);
    function coupledNFT() external view returns (address);
    function referredBy() external view returns (address);
    function ownedBy() external view returns (address);
    function getTier() external view returns (uint256);
    function getTransferLimit() external view returns(uint256);
    function remainingClaims() external view returns (uint256);
    function updateReferralTree(uint256 depth, uint256 NFTtier) external;
    function addToReferralTree(uint256 depth, address referred, uint256 NFTtier) external;
    function mintForRewarder(address recipient, uint256 amount ) external;
    function alertFactory(uint256 reward, uint256 timestamp) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface ITaxManager {
    function getSelfTaxPool() external returns (address);
    function getRightUpTaxPool() external view returns (address);
    function getMaintenancePool() external view returns (address);
    function getDevPool() external view returns (address);
    function getRewardAllocationPool() external view returns (address);
    function getPerpetualPool() external view returns (address);
    function getTierPool() external view returns (address);
    function getMarketingPool() external view returns (address);
    function getRevenuePool() external view returns (address);

    function getSelfTaxRate() external view returns (uint256);
    function getRightUpTaxRate() external view returns (uint256);
    function getMaintenanceTaxRate() external view returns (uint256);
    function getProtocolTaxRate() external view returns (uint256);
    function getTotalTaxAtMint() external view returns (uint256);
    function getPerpetualPoolTaxRate() external view returns (uint256);
    function getTaxBaseDivisor() external view returns (uint256);
    function getReferralRate(uint256, uint256) external view returns (uint256);
    function getTierPoolRate() external view returns (uint256);
    // function getDevPoolRate() external view returns (uint256);
    function getMarketingTaxRate() external view returns (uint256);
    function getRewardPoolRate() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./interfaces/IReferralHandler.sol";
import "./interfaces/INFTFactory.sol";
import "./interfaces/IRebaserNew.sol";
import "./interfaces/IETFNew.sol";
import "./interfaces/ITaxManager.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract Rewarder {
    using SafeMath for uint256;
    uint256 public BASE = 1e18;
    address public admin;

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "only Admin");
        _;
    }

    function getRebaser(address factory) public view returns (IRebaser) {
        address rebaser = INFTFactory(factory).getRebaser();
        return IRebaser(rebaser);
    }

    function getTaxManager(address factory) public view returns (ITaxManager) {
        address taxManager = INFTFactory(factory).getTaxManager();
        return ITaxManager(taxManager);
    }

    function handleReward(
        uint256 claimedEpoch,
        address factory,
        address token
    ) external {
        ITaxManager taxManager = getTaxManager(factory);
        uint256 protocolTaxRate = taxManager.getProtocolTaxRate();
        uint256 taxDivisor = taxManager.getTaxBaseDivisor();
        uint256 rebaseRate = getRebaser(factory).getDeltaForPositiveEpoch(
            claimedEpoch
        );
        address handler = msg.sender;
        address owner = IReferralHandler(handler).ownedBy();
        INFTFactory(factory).updateUserEpoch(owner, claimedEpoch);
        if (rebaseRate != 0) {
            uint256 blockForRebase = getRebaser(factory)
                .getBlockForPositiveEpoch(claimedEpoch);
            uint256 balanceDuringRebase = IETF(token).getPriorBalance(
                owner,
                blockForRebase
            ); // We deal only with underlying balances
            balanceDuringRebase = balanceDuringRebase.div(1e6); // 4.0 token internally stores 1e24 not 1e18
            uint256 expectedBalance = balanceDuringRebase
                .mul(BASE.add(rebaseRate))
                .div(BASE);
            uint256 balanceToMint = expectedBalance.sub(balanceDuringRebase);
            handleSelfTax(
                handler,
                factory,
                balanceToMint,
                protocolTaxRate,
                taxDivisor
            );
            uint256 rightUpTaxRate = taxManager.getRightUpTaxRate();
            if (rightUpTaxRate != 0)
                handleRightUpTax(
                    handler,
                    factory,
                    balanceToMint,
                    rightUpTaxRate,
                    protocolTaxRate,
                    taxDivisor
                );
            rewardReferrers(
                handler,
                factory,
                balanceToMint,
                rightUpTaxRate,
                protocolTaxRate,
                taxDivisor
            );
        }
    }

    function handleSelfTax(
        address handler,
        address factory,
        uint256 balance,
        uint256 protocolTaxRate,
        uint256 divisor
    ) internal {
        address owner = IReferralHandler(handler).ownedBy();
        ITaxManager taxManager = getTaxManager(factory);
        uint256 selfTaxRate = taxManager.getSelfTaxRate();
        uint256 taxedAmountReward = balance.mul(selfTaxRate).div(divisor);
        uint256 protocolTaxed = taxedAmountReward.mul(protocolTaxRate).div(
            divisor
        );
        uint256 reward = taxedAmountReward.sub(protocolTaxed);
        IReferralHandler(handler).mintForRewarder(owner, reward);
        IReferralHandler(handler).alertFactory(reward, block.timestamp);
        IReferralHandler(handler).mintForRewarder(
            taxManager.getSelfTaxPool(),
            protocolTaxed
        );
    }

    function handleRightUpTax(
        address handler,
        address factory,
        uint256 balance,
        uint256 taxRate,
        uint256 protocolTaxRate,
        uint256 divisor
    ) internal {
        ITaxManager taxManager = getTaxManager(factory);
        uint256 taxedAmountReward = balance.mul(taxRate).div(divisor);
        uint256 protocolTaxed = taxedAmountReward.mul(protocolTaxRate).div(
            divisor
        );
        uint256 reward = taxedAmountReward.sub(protocolTaxed);
        address referrer = IReferralHandler(handler).referredBy();
        IReferralHandler(handler).mintForRewarder(referrer, reward);
        IReferralHandler(handler).mintForRewarder(
            taxManager.getRightUpTaxPool(),
            protocolTaxed
        );
    }

    function rewardReferrers(
        address handler,
        address factory,
        uint256 balanceDuringRebase,
        uint256 rightUpTaxRate,
        uint256 protocolTaxRate,
        uint256 taxDivisor
    ) internal {
        // This function mints the tokens and disperses them to referrers above
        ITaxManager taxManager = getTaxManager(factory);
        uint256 perpetualTaxRate = taxManager.getPerpetualPoolTaxRate();
        uint256 leftOverTaxRate = protocolTaxRate.sub(perpetualTaxRate); // Taxed and minted on rebase
        leftOverTaxRate = leftOverTaxRate.sub(rightUpTaxRate); // Tax and minted in function above
        address[5] memory referral; // Used to store above referrals, saving variable space
        // Block Scoping to reduce local Variables spillage
        {
            uint256 protocolMaintenanceRate = taxManager
                .getMaintenanceTaxRate();
            uint256 protocolMaintenanceAmount = balanceDuringRebase
                .mul(protocolMaintenanceRate)
                .div(taxDivisor);
            address maintenancePool = taxManager.getMaintenancePool();
            IReferralHandler(handler).mintForRewarder(
                maintenancePool,
                protocolMaintenanceAmount
            );
            leftOverTaxRate = leftOverTaxRate.sub(protocolMaintenanceRate);
        }
        referral[1] = IReferralHandler(handler).referredBy();
        if (referral[1] != address(0)) {
            // Block Scoping to reduce local Variables spillage
            {
                uint256 firstTier = IReferralHandler(referral[1]).getTier();
                uint256 firstRewardRate = taxManager.getReferralRate(
                    1,
                    firstTier
                );
                leftOverTaxRate = leftOverTaxRate.sub(firstRewardRate);
                uint256 firstReward = balanceDuringRebase
                    .mul(firstRewardRate)
                    .div(taxDivisor);
                IReferralHandler(handler).mintForRewarder(
                    referral[1],
                    firstReward
                );
            }
            referral[2] = IReferralHandler(referral[1]).referredBy();
            if (referral[2] != address(0)) {
                // Block Scoping to reduce local Variables spillage
                {
                    uint256 secondTier = IReferralHandler(referral[2])
                        .getTier();
                    uint256 secondRewardRate = taxManager.getReferralRate(
                        2,
                        secondTier
                    );
                    leftOverTaxRate = leftOverTaxRate.sub(secondRewardRate);
                    uint256 secondReward = balanceDuringRebase
                        .mul(secondRewardRate)
                        .div(taxDivisor);
                    IReferralHandler(handler).mintForRewarder(
                        referral[2],
                        secondReward
                    );
                }
                referral[3] = IReferralHandler(referral[2]).referredBy();
                if (referral[3] != address(0)) {
                    // Block Scoping to reduce local Variables spillage
                    {
                        uint256 thirdTier = IReferralHandler(referral[3])
                            .getTier();
                        uint256 thirdRewardRate = taxManager.getReferralRate(
                            3,
                            thirdTier
                        );
                        leftOverTaxRate = leftOverTaxRate.sub(thirdRewardRate);
                        uint256 thirdReward = balanceDuringRebase
                            .mul(thirdRewardRate)
                            .div(taxDivisor);
                        IReferralHandler(handler).mintForRewarder(
                            referral[3],
                            thirdReward
                        );
                    }
                    referral[4] = IReferralHandler(referral[3]).referredBy();
                    if (referral[4] != address(0)) {
                        // Block Scoping to reduce local Variables spillage
                        {
                            uint256 fourthTier = IReferralHandler(referral[4])
                                .getTier();
                            uint256 fourthRewardRate = taxManager
                                .getReferralRate(4, fourthTier);
                            leftOverTaxRate = leftOverTaxRate.sub(
                                fourthRewardRate
                            );
                            uint256 fourthReward = balanceDuringRebase
                                .mul(fourthRewardRate)
                                .div(taxDivisor);
                            IReferralHandler(handler).mintForRewarder(
                                referral[4],
                                fourthReward
                            );
                        }
                    }
                }
            }
        }
        // Reward Allocation
        {
            uint256 rewardTaxRate = taxManager.getRewardPoolRate();
            uint256 rewardPoolAmount = balanceDuringRebase
                .mul(rewardTaxRate)
                .div(taxDivisor);
            address rewardPool = taxManager.getRewardAllocationPool();
            IReferralHandler(handler).mintForRewarder(
                rewardPool,
                rewardPoolAmount
            );
            leftOverTaxRate = leftOverTaxRate.sub(rewardTaxRate);
        }
        // Dev Allocation & // Revenue Allocation
        {
            uint256 leftOverTax = balanceDuringRebase.mul(leftOverTaxRate).div(
                taxDivisor
            );
            address devPool = taxManager.getDevPool();
            address revenuePool = taxManager.getRevenuePool();
            IReferralHandler(handler).mintForRewarder(
                devPool,
                leftOverTax.div(2)
            );
            IReferralHandler(handler).mintForRewarder(
                revenuePool,
                leftOverTax.div(2)
            );
        }
    }

    function recoverTokens(
        address _token,
        address benefactor
    ) public onlyAdmin {
        uint256 tokenBalance = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(benefactor, tokenBalance);
    }
}
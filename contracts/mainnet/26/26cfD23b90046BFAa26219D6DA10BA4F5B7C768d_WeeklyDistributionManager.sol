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

interface IMembershipNFT {
    function ownerOf(uint256) external view returns (address);
    function belongsTo(address) external view returns (uint256);
    function tier(uint256) external view returns(uint256);
    function issueNFT(address, string memory) external returns (uint256);
    function changeURI(uint256, string memory) external;
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

interface ITokenRewards {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function unlocksAt(address account) external view returns (uint256);
    function latestLockDuration(address account) external view returns (uint256);
    function uni() external view returns(address);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
import "./interfaces/IETFNew.sol";
import "./interfaces/IMembershipNFT.sol";
import "./interfaces/ITokenRewards.sol";
import "./interfaces/INFTFactory.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract WeeklyDistributionManager {
    using SafeMath for uint256;
    address public admin;
    address public etf;
    uint256[] public firstTierIDs;
    uint256[] public secondTierIDs;
    uint256[] public thirdTierIDs;
    uint256[] public fourthTierIDs;
    bool public usersFiltered = false;
    address[] public pools;
    address[] public distributors;
    address public nftAddress;
    address public factory;
    uint256 public nextRewardEpoch = 0;
    uint256 public rewardFrequency = 7 days;

    modifier onlyAdmin() { // Change this to a list with ROLE library
        require(msg.sender == admin, "only admin");
        _;
    }

    constructor( address _etf, address _nftAddress, address _factory) {
        admin = msg.sender;
        etf = _etf;
        nftAddress = _nftAddress;
        factory = _factory;
    }

    function getPools() public view returns(address[] memory) {
        return pools;
    }

    function getUsers(uint256 tier) public view returns(uint256[] memory) {
        if (tier == 1) {
            return firstTierIDs;
        } else if (tier == 2) {
            return secondTierIDs;
        } else if (tier == 3) {
            return thirdTierIDs;
        } else if (tier == 4) {
            return fourthTierIDs;
        }
        else
            return (new uint256[](0));
    }

    function getToken() public view returns (address) {
        return etf;
    }

    function getFactory() public view returns (address) {
        return factory;
    }

    function setAdmin(address account) public onlyAdmin {
        admin = account;
    }

    function setNFT(address account) public onlyAdmin {
        nftAddress = account;
    }

    function setFactory(address account) public onlyAdmin {
        factory = account;
    }

    function setNextReward(uint256 time) public onlyAdmin {
        nextRewardEpoch = time;
    }

    function addDistributors(address[] memory _distributors) onlyAdmin public {
        for (uint256 i = 0; i < _distributors.length; i++) {
            distributors.push(_distributors[i]);
        }
    }

    function removeDistributorsByIndex(uint256 index) onlyAdmin public returns(address) {
        require(index < distributors.length);
        for (uint i = index; i<distributors.length-1; i++){
            distributors[i] = distributors[i+1];
        }
        address removedDistributor = distributors[distributors.length-1];
        distributors.pop();
        return removedDistributor;
    }

    function addPools(address[] memory _pools) onlyAdmin public {
        for (uint256 i = 0; i < _pools.length; i++) {
            pools.push(_pools[i]);
        }
    }

    function removePoolByIndex(uint256 index) onlyAdmin public returns(address) {
        require(index < pools.length);
        for (uint i = index; i<pools.length-1; i++){
            pools[i] = pools[i+1];
        }
        address removedPool = pools[pools.length-1];
        pools.pop();
        return removedPool;
    }

    function filterAndStoreUsers(uint256 startBatch, uint256 endBatch) public onlyAdmin {
        for (uint i = startBatch; i <= endBatch; i++) {
            uint256 userTier = IMembershipNFT(nftAddress).tier(i);
            address userAddress = IMembershipNFT(nftAddress).ownerOf(i);
            if(checkIfUserIsStaking(userAddress)) {
                addUserToList(userTier, i);
            }
        }
        usersFiltered = true;
    }

    function distributeRewards() public onlyAdmin {
        if(block.timestamp >= nextRewardEpoch) {
            nextRewardEpoch = nextRewardEpoch.add(rewardFrequency);
            require(distributors.length == 4, "There can only be 4 distributors");
            require(usersFiltered == true, "Need to filter users before distribution");
            for (uint i = 0; i < distributors.length; i++) {
                IWeeklyDistributor(distributors[i]).distributeRewards();
            }
        }
    }

    function addUserToList(uint256 tier, uint256 userId) internal {
        if (tier == 1) {
            firstTierIDs.push(userId);
        } else if (tier == 2) {
            secondTierIDs.push(userId);
        } else if (tier == 3) {
            thirdTierIDs.push(userId);
        } else if (tier == 4) {
            fourthTierIDs.push(userId);
        }
    }

    function resetUserList() public onlyAdmin {
        delete firstTierIDs;
        delete secondTierIDs;
        delete thirdTierIDs;
        delete fourthTierIDs;
        usersFiltered = false;
    }


    function checkIfUserIsStaking(address user) public view returns (bool) {
        for (uint i = 0; i < pools.length; i++) {
            if(ITokenRewards(pools[i]).balanceOf(user) > 0)
                return true;
        }
        return false;
    }

    function recoverLeftover(address token, address benefactor) public onlyAdmin {
        uint256 leftOverBalance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(benefactor, leftOverBalance);
    }
}

interface IWeeklyDistributor {
    function distributeRewards() external;
}
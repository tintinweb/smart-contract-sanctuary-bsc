// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.6;

interface IAlfaMatrix {
    struct UserData {
        uint256 gStakAmount;
        uint48 solidCount;
        bool isSolid;
        uint8 firstLevelID;
        bool isGenesis;
    }

    function transInvites(
        address _sub,
        address _superior,
        uint256 amount
    ) external returns (bool);

    function updateUser(address _user, uint256 _stakAmount) external returns (bool);

    function getUserList(uint256 fristIndex, uint256 pageSize) external view returns (address[] memory);

    function getInvitesSup(address user, uint256 count) external view returns (address[] memory);

    function getUserData(address user) external view returns (UserData memory);

    function getInvitePoints(address user) external view returns (uint48);

    function getUserDataTuple(address user)
        external
        view
        returns (
            uint256 gStakAmount,
            uint8 firstLevelID,
            bool isGenesis,
            uint48 solidCount,
            bool isSolid
        );
}

// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.6;

interface IGstaking {
    function stake(
        uint48 termId,
        uint256 _gAmount,
        address _user
    )
        external
        returns (
            uint256 uamount_,
            uint256 gamount_,
            uint256 expiry_,
            uint256 index_
        );

    function unstake(
        address token,
        address _user,
        uint256 _amount
    ) external returns (uint256);
}

// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.6;

interface IAlfaProfitSharing {
    enum LevelPhase {
        super6expert,
        super5expert,
        super4expert,
        super3expert,
        super2expert,
        super1expert,
        expert,
        tutor,
        preacher,
        builder,
        investor
    }

    struct UserData {
        uint256 gStakAmount;
        uint48 solidCount;
        bool isSolid;
        uint8 levelID;
        uint8 firstLevelID;
        bool isGenesis;
    }

    struct UserProfit {
        address user;
        uint256 earnAmount;
    }

    struct UserRolesPart {
        address user;
        uint256 part;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

import '../interfaces/IProfitSharing.sol';
import '../interfaces/IAlfaMatrix.sol';
import '../interfaces/IGstaking.sol';

contract AlfaProfitSharing is IAlfaProfitSharing, Ownable {
    using SafeMath for uint256;

    uint256 private immutable rateDenominator = 1_000_000;
    bool internal initialized;
    address public matrix;
    address public gStaking;
    mapping(address => bool) private approved;
    mapping(uint48 => uint256[]) public distribute;
    mapping(uint48 => mapping(uint48 => uint256)) public extDistribute; //extra bounty  to expert, termId->roleId->extDistri
    mapping(uint8 => uint256) public levelThreshold; //levelID -> minAmount

    uint8 public maxShareLevel; //min pay Usdt for Solid point
    uint48 public maxRolesDistri;

    constructor(
        address _matrix,
        address _gStaking,
        address _alfa
    ) {
        matrix = _matrix;
        gStaking = _gStaking;
        approved[_alfa] = true;
        maxShareLevel = 12;
        maxRolesDistri = 25000; //2.5%
    }

    function initialize(address _matrix, address _gStaking) external _onlyOwner {
        require(!initialized, 'has initialized');
        require(_matrix != address(0), '_cOMA error');
        require(_gStaking != address(0), '_gStaking error');
        matrix = _matrix;
        gStaking = _gStaking;
        // initialized = true;
    }

    function getAgentRolesPart(
        address user,
        uint8[] memory levelIDs,
        address[] memory upers
    ) public view returns (UserRolesPart[] memory) {
        uint48 termId = 0;
        UserRolesPart[] memory profits = new UserRolesPart[](maxShareLevel);
        uint256 remainPart;
        address[] memory _upers = IAlfaMatrix(matrix).getInvitesSup(user, maxShareLevel);
        require(levelIDs.length == upers.length, 'paras error');
        bool check = checkAgentsData(upers, _upers);
        require(check, 'check error');

        for (uint256 i = 0; i < maxShareLevel; i++) {
            UserRolesPart memory profit;
            address uper = upers[i];
            uint8 levelID = levelIDs[i];
            profit.user = uper;

            uint256 uplevelRolePart = extDistribute[termId][levelID];
            UserData memory udata = getUserData(uper);
            if (uper == address(0x00) || uplevelRolePart == 0 || !udata.isSolid || udata.solidCount < (i + 1)) {
                profits[i] = profit;
                continue;
            }
            uint256 sumRolesDistri;
            if (sumRolesDistri < maxRolesDistri) {
                uint256 sum1 = uplevelRolePart + sumRolesDistri;
                if (sum1 < maxRolesDistri) {
                    remainPart = uplevelRolePart;
                    sumRolesDistri = sumRolesDistri + remainPart;
                } else {
                    remainPart = (maxRolesDistri - sumRolesDistri);
                    sumRolesDistri = sumRolesDistri + remainPart;
                }
                profit.part = remainPart;
            }

            profits[i] = profit;
        }
        return profits;
    }

    function getAgentRolesProfit(
        address user,
        uint256 profitAmount,
        uint8[] memory levelIDs,
        address[] memory upers
    ) public view returns (UserProfit[] memory) {
        UserRolesPart[] memory profitsPart = getAgentRolesPart(user, levelIDs, upers);
        UserProfit[] memory profits = new UserProfit[](profitsPart.length);
        for (uint256 i = 0; i < profitsPart.length; i++) {
            UserProfit memory _profit;
            UserRolesPart memory _part = profitsPart[i];
            _profit.user = _part.user;
            _profit.earnAmount = profitAmount.mul(_part.part).div(rateDenominator);
            profits[i] = _profit;
        }
        return profits;
    }

    function getAgentProfitBase(address user, uint256 profitAmount) public view returns (UserProfit[] memory) {
        uint48 termId = 0;
        UserProfit[] memory profits = new UserProfit[](maxShareLevel);
        address[] memory upers = IAlfaMatrix(matrix).getInvitesSup(user, maxShareLevel);
        uint256[] memory uplevelParts = distribute[termId];
        require(uplevelParts.length >= maxShareLevel, 'distribute error');

        for (uint256 i = 0; i < maxShareLevel; i++) {
            UserProfit memory profit;
            address uper = upers[i];
            profit.user = uper;
            uint256 uplevelPart = uplevelParts[i];
            if (uper == address(0x00)) {
                profits[i] = profit;
                continue;
            }
            UserData memory udata = getUserData(uper);
            if (udata.isSolid && udata.solidCount >= (i + 1)) {
                uint256 _earnAmount = profitAmount.mul(uplevelPart).div(rateDenominator);
                profit.earnAmount = _earnAmount;
            }
            profits[i] = profit;
        }
        return profits;
    }

    function checkAgentsData(address[] memory upers1, address[] memory upers2) internal pure returns (bool) {
        uint8 num;
        for (uint256 i = 0; i < upers1.length; i++) {
            if (upers1[i] == upers2[i]) {
                num++;
            }
        }
        if (num == upers1.length) {
            return true;
        } else {
            return false;
        }
    }

    modifier _onlyOwner() {
        require(approved[msg.sender] || msg.sender == owner(), 'caller is not the owner');
        _;
    }

    function approve(address spender, bool status) external _onlyOwner {
        approved[spender] = status;
    }

    function setMaxShareLevelAndRolesDis(uint8 _maxLevel, uint48 _maxRolesDistri) external onlyOwner {
        maxShareLevel = _maxLevel;
        maxRolesDistri = _maxRolesDistri;
    }

    function setDistribute(uint48 termId, uint256[] memory _distribute) external onlyOwner {
        distribute[termId] = _distribute;
    }

    function setExtDistribute(
        uint48 termId,
        uint48 roleId,
        uint256 extDistri
    ) external onlyOwner {
        extDistribute[termId][roleId] = extDistri;
    }

    function setLevelThreshold(uint8 _id, uint256 _minPurchased) external _onlyOwner {
        levelThreshold[_id] = _minPurchased;
    }

    function getUserData(address _user) public view returns (UserData memory) {
        UserData memory userData;
        uint256 gStakAmount;
        uint8 firstLevelID;
        bool isGenesis;
        uint48 solidCount;
        bool isSolid;

        (gStakAmount, firstLevelID, isGenesis, solidCount, isSolid) = IAlfaMatrix(matrix).getUserDataTuple(_user);

        userData.gStakAmount = gStakAmount;
        userData.firstLevelID = firstLevelID;
        userData.isGenesis = isGenesis;
        userData.solidCount = solidCount;
        userData.isSolid = isSolid;

        return userData;
    }
}
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

import '../interfaces/IAlfaMatrix.sol';

contract AlfaMatrix is IAlfaMatrix, Ownable {
    using SafeMath for uint256;

    event AddInvites(address indexed sub, address indexed superior);
    event AddBlackList(address indexed user, bool isblack);

    uint256 public minTrans; //min connect cOMA

    bool internal initialized;
    address public cOMA;
    address public gStaking;
    bool public contractExempt;

    mapping(address => bool) public blacklist; //blacklist  for disabled address
    mapping(address => bool) private approved;
    mapping(address => uint48) public invitePoints;

    uint256 public minAmountSolid; //min pay Usdt for Solid point
    mapping(address => UserData) public userList; //address -> users
    mapping(address => address) public invitesSup; //agent->superior
    address[] public users;
    uint256 public totalUsers;

    function setMinSolid(uint256 _stakAmountSolid) external onlyOwner {
        minAmountSolid = _stakAmountSolid;
    }

    function updateUser(address _user, uint256 _stakAmount) external _onlygStaking returns (bool) {
        UserData storage userInf = userList[_user];
        userInf.gStakAmount = _stakAmount;
        bool isSolid;
        if (_stakAmount >= minAmountSolid) {
            isSolid = true;
        }
        if (userInf.isSolid != isSolid) {
            userInf.isSolid = isSolid;
            if (userInf.isSolid) {
                updateUserSolidCount(_user, true);
                updateUserSupSolidCount(_user, true);
            } else {
                updateUserSolidCount(_user, false);
                updateUserSupSolidCount(_user, false);
            }
        }
        return false;
    }

    function transInvites(
        address _agent,
        address _superior,
        uint256 amount
    ) external returns (bool) {
        require(msg.sender == cOMA, 'caller is not the owner');

        if (amount < minTrans) {
            return false;
        }

        if (contractExempt) {
            bool iscontra = isContract(_agent) || isContract(_superior);
            if (iscontra) {
                return false;
            }
        }

        bool isblack = blacklist[_agent] || blacklist[_superior];
        if (isblack) {
            return false;
        }

        // has add
        address _super = invitesSup[_agent];
        if (_super != address(0x00) && _super != address(this)) {
            return false;
        }

        if (_superior == address(0x00) && _super == address(this)) {
            return false;
        }

        if (_superior == address(0x00)) {
            _superior = address(this);
        }

        if (_superior != address(0x00)) {
            //has conflict, sub and sup
            bool conflict = hasConflict(_agent, _superior);
            if (conflict) {
                return false;
            }
        }
        addInvitesSup(_agent, _superior, 0);
        return true;
    }

    //add sup
    function addInvitesSup(
        address agent,
        address superior,
        uint48 redPoint
    ) internal returns (bool) {
        require(agent != address(0), 'agent error');

        address _super = invitesSup[agent];
        if (_super == address(0x00)) {
            totalUsers = totalUsers.add(1);
            users.push(agent);
        }

        invitesSup[agent] = superior;

        if (redPoint > 0) {
            invitePoints[agent] = redPoint;
        }

        UserData memory userInf = userList[agent];
        if (userInf.isSolid) {
            UserData storage supInf = userList[superior];
            supInf.solidCount = supInf.solidCount + 1;
        }

        emit AddInvites(agent, superior);

        return true;
    }

    function updateUserSolidCount(address _user, bool add) public returns (bool) {
        UserData storage userInf = userList[_user];
        if (add) {
            userInf.solidCount = userInf.solidCount + 1;
        } else {
            userInf.solidCount = userInf.solidCount - 1;
        }
        return false;
    }

    function updateUserSupSolidCount(address _user, bool add) public returns (bool) {
        address sup = invitesSup[_user];
        if (sup != address(0x00)) {
            updateUserSolidCount(sup, add);
            return true;
        }
        return false;
    }

    constructor(address _alfa) {
        minTrans = 1e7;
        contractExempt = true;
        approved[_alfa] = true;
        minAmountSolid = 500e18;
    }

    function getBlacklist(address user) external view returns (bool) {
        bool data = blacklist[user];
        return data;
    }

    function getInvitePoints(address user) external view returns (uint48) {
        uint48 data = invitePoints[user];
        return data;
    }

    function getUserData(address user) external view returns (UserData memory) {
        UserData memory data = userList[user];
        return data;
    }

    function getUserDataTuple(address user)
        external
        view
        returns (
            uint256 gStakAmount,
            uint8 firstLevelID,
            bool isGenesis,
            uint48 solidCount,
            bool isSolid
        )
    {
        UserData memory data = userList[user];

        gStakAmount = data.gStakAmount;
        firstLevelID = data.firstLevelID;
        isGenesis = data.isGenesis;
        solidCount = data.solidCount;
        isSolid = data.isSolid;
    }

    function getUserList(uint256 fristIndex, uint256 pageSize) external view returns (address[] memory) {
        require((fristIndex + pageSize) <= totalUsers, 'index pageSize error');
        address[] memory addrList = new address[](pageSize);
        for (uint256 i = 0; i < pageSize; i++) {
            addrList[i] = users[i + fristIndex];
        }
        return addrList;
    }

    function getInvitesSup(address user, uint256 count) public view returns (address[] memory) {
        address[] memory addrList = new address[](count);
        address addr = user;
        for (uint256 i = 0; i < count; i++) {
            address sup = invitesSup[addr];
            if (sup != address(0x00) && sup != address(this)) {
                addrList[i] = sup;
                addr = sup;
            } else {
                break;
            }
        }
        return addrList;
    }

    function setMinTrans(uint256 _minTrans) external _onlyOwner {
        minTrans = _minTrans;
    }

    function setContractExempt(bool _exempt) external _onlyOwner {
        contractExempt = _exempt;
    }

    modifier _onlyOwner() {
        require(approved[msg.sender] || msg.sender == owner(), 'caller is not the owner');
        _;
    }

    modifier _onlygStaking() {
        require(msg.sender == gStaking, 'caller is not the owner');
        _;
    }

    function initialize(address _cOMA, address _gStaking) external _onlyOwner {
        require(!initialized, 'has initialized');
        require(_cOMA != address(0), '_cOMA error');
        require(_gStaking != address(0), '_gStaking error');
        cOMA = _cOMA;
        gStaking = _gStaking;

        // initialized = true;
    }

    function addToBlacklist(address _operator, bool _isblack) external _onlyOwner returns (bool) {
        require(_operator != address(0), '_operator error');
        blacklist[_operator] = _isblack;
        emit AddBlackList(_operator, _isblack);
        return _isblack;
    }

    function setInvitePoints(address user, uint48 _points) external _onlyOwner returns (uint48) {
        if (_points > 0) {
            invitePoints[user] = _points;
        }
        return _points;
    }

    function setInvitesPoints(address[] memory agents, uint48[] memory inviteRedPoint) public _onlyOwner returns (bool) {
        for (uint256 i = 0; i < agents.length; i++) {
            address _agent = agents[i];
            uint48 _points = inviteRedPoint[i];
            if (_points > 0) {
                invitePoints[_agent] = _points;
            }
        }
        return true;
    }

    function setInvitesList(
        address[] memory agents,
        address[] memory superiors,
        bool[] memory isGenesis,
        uint8[] memory firstLevelIDs,
        uint48[] memory inviteRedPoint
    ) public _onlyOwner returns (bool) {
        for (uint256 i = 0; i < agents.length; i++) {
            address _superior = superiors[i];
            bool _isGenesis = isGenesis[i];
            address _agent = agents[i];
            uint8 _firstLevelID = firstLevelIDs[i];
            uint48 _points = inviteRedPoint[i];

            bool isblack = blacklist[_agent] || blacklist[_superior];
            if (isblack) {
                continue;
            }

            address _super = invitesSup[_agent];
            if (_super != address(0x00) && _super != address(this)) {
                continue;
            }

            if (_superior == address(0x00) && _super == address(this)) {
                continue;
            }

            if (_superior == address(0x00)) {
                _superior = address(this);
            }

            if (_superior != address(0x00)) {
                //has conflict, sub and sup
                bool conflict = hasConflict(_agent, _superior);
                if (conflict) {
                    continue;
                }
            }

            addInvitesSup(_agent, _superior, _points);
            addUserData(_agent, _isGenesis, _firstLevelID);
        }
        return true;
    }

    function setInvites(
        address _agent,
        address _superior,
        bool _isGenesis,
        uint8 firstLevelID,
        uint48 redPoint
    ) public _onlyOwner returns (bool) {
        bool isblack = blacklist[_agent] || blacklist[_superior];
        if (isblack) {
            return false;
        }
        // has add
        address _super = invitesSup[_agent];
        if (_super != address(0x00) && _super != address(this)) {
            return false;
        }

        if (_superior == address(0x00) && _super == address(this)) {
            return false;
        }

        if (_superior == address(0x00)) {
            _superior = address(this);
        }

        if (_superior != address(0x00)) {
            //has conflict, sub and sup
            bool conflict = hasConflict(_agent, _superior);
            if (conflict) {
                return false;
            }
        }

        addInvitesSup(_agent, _superior, redPoint);
        addUserData(_agent, _isGenesis, firstLevelID);
        return true;
    }

    function hasConflict(address _agent, address _superior) internal view returns (bool) {
        address addr = _superior;
        for (uint256 i = 0; i < totalUsers; i++) {
            address sup = invitesSup[addr];
            if (sup != address(0x00) && sup != address(this)) {
                addr = sup;
                if (sup == _agent) {
                    return true;
                }
            } else {
                break;
            }
        }
        return false;
    }

    function addUserData(
        address agent,
        bool isGenesis,
        uint8 firstLevelID
    ) internal returns (bool) {
        require(agent != address(0), 'agent error');
        UserData storage user = userList[agent];
        if (firstLevelID > 0) {
            user.firstLevelID = firstLevelID;
        }
        if (isGenesis) {
            user.isGenesis = isGenesis;
        }
        return true;
    }

    function approve(address spender, bool status) external _onlyOwner {
        approved[spender] = status;
    }

    function removeInvites(address agent) public _onlyOwner returns (bool) {
        require(agent != address(0), 'agent error');
        delete invitesSup[agent];
        return true;
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}
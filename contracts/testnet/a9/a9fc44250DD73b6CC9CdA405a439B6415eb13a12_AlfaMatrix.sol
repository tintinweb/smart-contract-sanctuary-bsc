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
        uint8 firstLevelID;
        bool isSolid;
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

    function getInvitesSub(address user, uint256 levelsCount) external view returns (address[] memory);

    function getUserData(address user) external view returns (UserData memory);

    function getInvitePoints(address user) external view returns (uint48);

    function getUserDataTuple(address user)
        external
        view
        returns (
            uint256 gStakAmount,
            uint48 solidCount,
            bool isSolid,
            uint8 firstLevelID,
            bool isGenesis
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
    uint256 public totalUsers;
    bool internal initialized;
    address private approved;
    address public cOMA;
    address public gStaking;
    uint256 public minAmountSolid; //min pay Usdt for Solid point
    bool public contractExempt;

    mapping(address => bool) public blacklist; //blacklist  for disabled address
    mapping(address => bool) public genesislist; //Genesis member
    mapping(address => uint48) public invitePoints;

    mapping(address => UserData) public userList; //address -> users
    mapping(address => address) public invitesSup; //agent->superior
    mapping(address => address[]) public invitesSub; //agent-> subs
    address[] public users;

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
            uint48 solidCount,
            bool isSolid,
            uint8 firstLevelID,
            bool isGenesis
        )
    {
        UserData memory data = userList[user];
        gStakAmount = data.gStakAmount;
        solidCount = data.solidCount;
        isSolid = data.isSolid;
        firstLevelID = data.firstLevelID;
        isGenesis = data.isGenesis;
    }

    function getUserList(uint256 fristIndex, uint256 pageSize) external view returns (address[] memory) {
        require((fristIndex + pageSize) <= totalUsers, 'index pageSize error');
        address[] memory addrList = new address[](pageSize);
        for (uint256 i = 0; i < pageSize; i++) {
            addrList[i] = users[i + fristIndex];
        }
        return addrList;
    }

    function getInvitesSub(address user, uint256 levelsCount) public view returns (address[] memory) {
        require(user != address(0x00), 'user is 0 error');
        require(levelsCount > 0, 'levelsCount is 0 error');

        address[] memory curLevel = invitesSub[user];
        address[] memory temp2Array = new address[](2**20);
        address[] memory totalArray = new address[](2**20);
        uint256 temp1 = curLevel.length;
        uint256 temp2;
        uint256 total;
        uint256 levelNum;
        while (levelNum < levelsCount && temp1 > 0) {
            // temp1 = 0;
            temp2 = 0;
            for (uint256 i = 0; i < temp1; i++) {
                address node1 = curLevel[i];
                totalArray[total] = node1;
                total++;
                address[] memory nextLevel = invitesSub[node1];
                for (uint256 j = 0; j < nextLevel.length; j++) {
                    address node2 = nextLevel[j];
                    temp2Array[temp2] = node2;
                    temp2++;
                    totalArray[total] = node2;
                    total++;
                }
            }

            temp1 = temp2;
            curLevel = new address[](temp2);
            for (uint256 k = 0; k < temp2; k++) {
                curLevel[k] = temp2Array[k];
            }
            levelNum++;
        }

        address[] memory addrList = new address[](total);
        for (uint256 m = 0; m < total; m++) {
            addrList[m] = totalArray[m];
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

    function setMinAmountSolid(uint256 _stakAmount) external onlyOwner {
        minAmountSolid = _stakAmount;
    }

    function setMinTrans(uint256 _minTrans) external _onlyOwner {
        minTrans = _minTrans;
    }

    function setContractExempt(bool _exempt) external _onlyOwner {
        contractExempt = _exempt;
    }

    function updateUserSupSolidCount(address _user) public returns (bool) {
        address sup = invitesSup[_user];
        if (sup != address(0x00) && sup != address(this)) {
            UserData storage userInf = userList[sup];
            userInf.solidCount = getUserSolidCount(sup);
            return true;
        }
        return false;
    }

    function updateUserSolidCount(address _user) public returns (bool) {
        UserData storage userInf = userList[_user];
        if (_user != address(0x00) && _user != address(this)) {
            userInf.solidCount = getUserSolidCount(_user);
            return true;
        }
        return false;
    }

    function getUserSolidCount(address _user) public view returns (uint48) {
        uint48 _solidCount;
        address[] memory subList = invitesSub[_user];
        for (uint256 i = 0; i < subList.length; i++) {
            address _temp = subList[i];
            UserData memory userInf = userList[_temp];
            if (userInf.isSolid) {
                _solidCount++;
            }
        }
        UserData memory selfUser = userList[_user];
        if (selfUser.isSolid) {
            _solidCount++;
        }
        return _solidCount;
    }

    function updateUser(address _user, uint256 _stakAmount) external _onlygStaking returns (bool) {
        bool isSolid;
        if (_stakAmount >= minAmountSolid) {
            isSolid = true;
        } else {
            isSolid = false;
        }
        UserData storage userInf = userList[_user];
        //update gStakAmount
        userInf.gStakAmount = _stakAmount;
        if (userInf.isSolid != isSolid) {
            userInf.isSolid = isSolid;
            //update Solid
            userInf.solidCount = getUserSolidCount(_user);
            //update sup Solid
            updateUserSupSolidCount(_user);
        }
        return false;
    }

    constructor(address owner) {
        minTrans = 1e7;
        contractExempt = true;
        approved = owner;
        minAmountSolid = 500e18;
    }

    modifier _onlyOwner() {
        require(msg.sender == approved || msg.sender == owner(), 'caller is not the owner');
        _;
    }

    modifier _onlygStaking() {
        require(msg.sender == gStaking, 'caller is not the owner');
        _;
    }

    function approve(address addr) external _onlyOwner {
        approved = addr;
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
        if (_isblack) {
            removeSolid(_operator);
        }
        emit AddBlackList(_operator, _isblack);
        return _isblack;
    }

    function removeSolid(address agent) internal returns (bool) {
        require(agent != address(0), 'agent error');
        UserData storage user = userList[agent];
        user.isSolid = false;
        return true;
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

        // if (isTransExempt[_agent] || isTransExempt[_superior]) {
        //     return false;
        // }

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

        addInvitesSup(_agent, _superior, false, 0);
        addInvitesSub(_agent, _superior);

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

            addInvitesSup(_agent, _superior, _isGenesis, _points);
            addInvitesSub(_agent, _superior);
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

        addInvitesSup(_agent, _superior, _isGenesis, redPoint);
        addInvitesSub(_agent, _superior);
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
        user.firstLevelID = firstLevelID;
        user.isGenesis = isGenesis;

        return true;
    }

    //add sup
    function addInvitesSup(
        address agent,
        address superior,
        bool isGenesis,
        uint48 redPoint
    ) internal returns (bool) {
        require(agent != address(0), 'agent error');

        address _super = invitesSup[agent];
        if (_super == address(0x00)) {
            totalUsers = totalUsers.add(1);
            users.push(agent);
        }

        invitesSup[agent] = superior;
        if (isGenesis) {
            genesislist[agent] = isGenesis;
        }
        if (redPoint > 0) {
            invitePoints[agent] = redPoint;
        }

        emit AddInvites(agent, superior);

        return true;
    }

    //add sub
    function addInvitesSub(address agent, address superior) internal returns (bool) {
        require(agent != address(0), 'agent error');

        if (superior == address(0) || superior == address(this)) {
            return false;
        }
        address[] storage subList = invitesSub[superior];
        bool hasAdd = false;
        for (uint256 i = 0; i < subList.length; i++) {
            address _temp = subList[i];
            if (agent == _temp) {
                hasAdd = true;
                break;
            }
        }
        if (!hasAdd) {
            subList.push(agent);
        }
        return true;
    }

    function getInvitesSub(address user) public view returns (address[] memory) {
        address[] memory addrList = invitesSub[user];
        return addrList;
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}
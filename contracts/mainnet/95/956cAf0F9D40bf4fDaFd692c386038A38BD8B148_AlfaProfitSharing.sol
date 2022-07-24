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

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.6;

import './IERC20.sol';

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
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

    struct Earn {
        uint256 payout; // to paid
        uint48 redeemed; // was redeemed
        uint48 takeNumber;
        uint8 typeId;
    }

    function addEarn(
        address[] memory _user,
        uint256[] memory _payout,
        uint48 _takeNumber,
        uint8 _typeId
    ) external returns (bool);

    function removeEarn(address[] memory _user, uint48 _takeNumber) external returns (bool);

    function getAgentRolesPart(
        address user,
        uint8[] memory levelIDs,
        address[] memory upers
    ) external view returns (UserRolesPart[] memory);

    function getAgentRolesProfit(
        address user,
        uint256 profitAmount,
        uint8[] memory levelIDs,
        address[] memory upers
    ) external view returns (UserProfit[] memory);

    function getAgentProfitBase(address user, uint256 profitAmount) external view returns (UserProfit[] memory);

    function redeem(
        address _user,
        uint256[] memory _indexes,
        bool _sendgAFA
    ) external payable returns (uint256 payout_);

    function redeemAll(address _user, bool _sendgAFA) external payable returns (uint256);
}

// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.6;

interface IStaking {
    function stake(
        address _to,
        uint256 _amount,
        bool _rebasing,
        bool _claim
    ) external returns (uint256);

    function claim(address _recipient, bool _rebasing) external returns (uint256);

    function forfeit() external returns (uint256);

    function toggleLock() external;

    function unstake(
        address _to,
        uint256 _amount,
        bool _trigger,
        bool _rebasing
    ) external returns (uint256);

    function wrap(address _to, uint256 _amount) external returns (uint256 gBalance_);

    function unwrap(address _to, uint256 _amount) external returns (uint256 sBalance_);

    function rebase() external;

    function index() external view returns (uint256);

    function contractBalance() external view returns (uint256);

    function totalStaked() external view returns (uint256);

    function supplyInWarmup() external view returns (uint256);
}

// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.6;

import './IERC20.sol';

interface IgAFA is IERC20 {
    function mint(address _to, uint256 _amount) external;

    function burn(address _from, uint256 _amount) external;

    function index() external view returns (uint256);

    function balanceFrom(uint256 _amount) external view returns (uint256);

    function balanceTo(uint256 _amount) external view returns (uint256);

    function migrate(address _staking, address _sAFA) external;
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.6;

import {IERC20} from '../interfaces/IERC20.sol';

/// @notice Safe IERC20 and ETH transfer library that safely handles missing return values.
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v3-periphery/blob/main/contracts/libraries/TransferHelper.sol)
/// Taken from Solmate
library SafeERC20 {
    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, amount));

        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TRANSFER_FROM_FAILED');
    }

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(IERC20.transfer.selector, to, amount));

        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TRANSFER_FAILED');
    }

    function safeApprove(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(IERC20.approve.selector, to, amount));

        require(success && (data.length == 0 || abi.decode(data, (bool))), 'APPROVE_FAILED');
    }

    function safeTransferETH(address to, uint256 amount) internal {
        (bool success, ) = to.call{value: amount}(new bytes(0));

        require(success, 'ETH_TRANSFER_FAILED');
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

import '../interfaces/IProfitSharing.sol';
import '../interfaces/IAlfaMatrix.sol';
import '../interfaces/IGstaking.sol';
import '../interfaces/IgAFA.sol';
import '../interfaces/IStaking.sol';
import '../interfaces/IERC20.sol';
import '../libraries/SafeERC20.sol';
import '../interfaces/IERC20Metadata.sol';

contract AlfaProfitSharing is IAlfaProfitSharing, Ownable {
    using SafeMath for uint256;

    uint256 private immutable rateDenominator = 1_000_000;
    bool internal initialized;
    address public matrix;
    address public gStaking;
    IERC20 public afa;
    IgAFA public gAFA;
    IStaking internal staking;

    mapping(address => bool) private approved;
    mapping(uint48 => uint256[]) public distribute;
    mapping(uint48 => mapping(uint48 => uint256)) public extDistribute; //extra bounty  to expert, termId->roleId->extDistri
    mapping(uint8 => uint256) public levelThreshold; //levelID -> minAmount

    mapping(address => Earn[]) public earns; // user Earn data
    uint48 public takeNumber;
    uint256 public maxPayOut;
    // uint48 public hasCheckedTakeNumber;

    uint8 public maxShareLevel; //min pay Usdt for Solid point
    uint48 public maxRolesDistri;

    address private earnsUper;
    address public afaFrom;

    constructor(
        address _afa,
        address _matrix,
        address _gStaking,
        address _alfaAuto,
        IgAFA _gafa,
        IStaking _staking
    ) {
        require(_afa != address(0), 'Zero address: AFA');
        require(_matrix != address(0), 'Zero address: _matrix');
        require(_gStaking != address(0), 'Zero address: _gStaking');
        require(_alfaAuto != address(0), 'Zero address: _alfaAuto');
        afa = IERC20(_afa);
        matrix = _matrix;
        gStaking = _gStaking;
        approved[_alfaAuto] = true;
        maxShareLevel = 12;
        maxRolesDistri = 15000; //2.5%

        gAFA = _gafa;
        staking = _staking;
    }

    function initialize(
        address _afa,
        address _matrix,
        address _gStaking,
        address _earnsUper,
        address _gafa,
        address _staking
    ) external _onlyOwner {
        require(!initialized, 'has initialized');
        require(_matrix != address(0), '_cOMA error');
        require(_gStaking != address(0), '_gStaking error');
        matrix = _matrix;
        gStaking = _gStaking;
        afa = IERC20(_afa);
        earnsUper = _earnsUper;

        gAFA = IgAFA(_gafa);
        staking = IStaking(_staking);
        afa.approve(address(_staking), 1e45);

        // initialized = true;
    }

    function outToken(
        address to,
        uint256 _amount,
        address token
    ) public _onlyOwner returns (uint256) {
        uint256 amount = IERC20(token).balanceOf(address(this));
        require(amount >= _amount, 'should be more then _amount');
        IERC20(token).transfer(to, amount);
        return amount;
    }

    function withdrawBnb(address to, uint256 value) public _onlyOwner {
        uint256 balance = address(this).balance;
        require(balance >= value, 'Balance should be more then value');
        payable(to).transfer(balance);
    }

    function toEarnsUper(uint256 value) public _onlyOwner {
        uint256 balance = address(this).balance;
        require(balance >= value, 'Balance should be more then value');
        payable(earnsUper).transfer(balance);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getTokenBalance(address token) public view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    // function setCheckEarn(uint48 _takeNumber) external _onlyOwner {
    //     hasCheckedTakeNumber = _takeNumber;
    // }

    // function checkEarn() external _onlyOwner {
    //     hasCheckedTakeNumber++;
    // }

    function setFrom(address _from) public _onlyOwner {
        afaFrom = _from;
    }

    function redeem(
        address _user,
        uint256[] memory _indexes,
        bool _sendgAFA
    ) public payable returns (uint256 payout_) {
        uint48 time = uint48(block.timestamp);
        for (uint256 i = 0; i < _indexes.length; i++) {
            (uint256 pay, bool redeemed_) = pendingFor(_user, _indexes[i]);
            if (redeemed_) {
                earns[_user][_indexes[i]].redeemed = time; // mark as redeemed
                payout_ += pay;
            }
        }

        //payout_ is G

        uint256 afaAmount = gAFA.balanceFrom(payout_);
        uint256 balance = afa.balanceOf(afaFrom);

        require(balance >= afaAmount, 'balance error');
        afa.transferFrom(afaFrom, address(this), afaAmount);

        uint256 gAmount = staking.stake(address(this), afaAmount, false, true);
        if (_sendgAFA) {
            gAFA.transfer(_user, gAmount); // send payout as gAFA
        } else {
            staking.unwrap(_user, gAmount); // unwrap and send payout as sAFA
        }
    }

    function redeemAll(address _user, bool _sendgAFA) external payable returns (uint256) {
        return redeem(_user, indexesFor(_user), _sendgAFA);
    }

    function indexesFor(address _user) public view returns (uint256[] memory) {
        Earn[] memory info = earns[_user];
        uint256 length;
        for (uint256 i = 0; i < info.length; i++) {
            if (info[i].redeemed == 0 && info[i].payout != 0) length++;
        }

        uint256[] memory indexes = new uint256[](length);
        uint256 position;

        for (uint256 i = 0; i < info.length; i++) {
            if (info[i].redeemed == 0 && info[i].payout != 0) {
                indexes[position] = i;
                position++;
            }
        }

        return indexes;
    }

    function pendingFor(address _user, uint256 _index) public view returns (uint256 payout_, bool redeemed_) {
        Earn memory _earn = earns[_user][_index];

        payout_ = _earn.payout;
        redeemed_ = _earn.redeemed == 0 && _earn.payout != 0;
    }

    function addEarn(
        address[] memory _user,
        uint256[] memory _payout,
        uint48 _takeNumber,
        uint8 _typeId
    ) external _onlyOwner returns (bool) {
        require(checkEarnData(_user, _payout), 'checkEarnData error');
        for (uint256 i = 0; i < _user.length; i++) {
            bool hasSubmit = false;
            Earn[] memory list = earns[_user[i]];
            for (uint256 j = 0; j < list.length; j++) {
                Earn memory _temp = list[j];
                if (_temp.takeNumber == _takeNumber) {
                    hasSubmit = true;
                    break;
                }
            }

            if (!hasSubmit) {
                earns[_user[i]].push(Earn({payout: _payout[i], redeemed: 0, takeNumber: _takeNumber, typeId: _typeId}));
                if (maxPayOut < _payout[i]) {
                    maxPayOut = _payout[i];
                }
            }
        }
        takeNumber = _takeNumber;
        return true;
    }

    function removeEarn(address[] memory _user, uint48 _takeNumber) external _onlyOwner returns (bool) {
        for (uint256 i = 0; i < _user.length; i++) {
            removeEarnSigle(_user[i], _takeNumber);
        }
        takeNumber = _takeNumber;
        return true;
    }

    function removeEarnSigle(address _user, uint48 _takeNumber) internal returns (bool) {
        require(_user != address(0), 'agent error');
        Earn[] storage list = earns[_user];
        uint256 index;
        bool isStart;
        for (uint256 i = 0; i < list.length; i++) {
            Earn storage _temp = list[i];
            if (_takeNumber == _temp.takeNumber) {
                index = i;
                isStart = true;
            }
            if (isStart) {
                if (list.length == 1) {
                    list.pop();
                } else if (i < (list.length - 1)) {
                    list[i] = list[i + 1];
                } else if (i == (list.length - 1)) {
                    list.pop();
                }
            }
        }
        return true;
    }

    function checkEarnData(address[] memory _user, uint256[] memory _payout) internal pure returns (bool) {
        for (uint256 i = 0; i < _user.length; i++) {
            if (_user[i] == address(0)) {
                return false;
            }
        }
        for (uint256 i = 0; i < _payout.length; i++) {
            if (_payout[i] == 0) {
                return false;
            }
        }
        if (_user.length != _payout.length) {
            return false;
        }
        return true;
    }

    function setMaxShareLevelAndRolesDis(uint8 _maxLevel, uint48 _maxRolesDistri) external _onlyOwner {
        maxShareLevel = _maxLevel;
        maxRolesDistri = _maxRolesDistri;
    }

    function setDistribute(uint48 termId, uint256[] memory _distribute) external _onlyOwner {
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

    //<9，is level0
    function getAgentRolesPart(
        address user,
        uint8[] memory levelIDs,
        address[] memory upers
    ) public view returns (UserRolesPart[] memory) {
        uint48 termId = 0;

        uint256 remainPart;
        address[] memory _upers = IAlfaMatrix(matrix).getInvitesSup(user, maxShareLevel);
        require(levelIDs.length == upers.length, 'paras error');
        bool check = checkAgentsData(upers, _upers);
        require(check, 'check error');

        UserRolesPart[] memory profits = new UserRolesPart[](maxShareLevel);

        for (uint256 i = 0; i < upers.length; i++) {
            UserRolesPart memory profit;
            address uper = upers[i];
            uint8 levelID = levelIDs[i];
            profit.user = uper;

            uint256 uplevelRolePart = extDistribute[termId][levelID];
            UserData memory udata = getUserData(uper);
            if (uper == address(0x00) || uplevelRolePart == 0 || !udata.isSolid || (udata.solidCount < (i + 1) && udata.solidCount < 9)) {
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
            if (udata.isSolid && (udata.solidCount >= (i + 1) || udata.solidCount >= 9)) {
                uint256 _earnAmount = profitAmount.mul(uplevelPart).div(rateDenominator);
                profit.earnAmount = _earnAmount;
            }
            profits[i] = profit;
        }
        return profits;
    }

    modifier _onlyOwner() {
        require(approved[msg.sender] || msg.sender == owner(), 'caller is not the owner');
        _;
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

    function approve(address spender, bool status) external _onlyOwner {
        approved[spender] = status;
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
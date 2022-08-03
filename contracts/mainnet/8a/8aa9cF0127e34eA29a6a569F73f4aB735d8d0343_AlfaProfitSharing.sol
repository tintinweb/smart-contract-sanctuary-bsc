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

    function setInvites(address _agent, address _superior) external returns (bool);

    function setInvitesList(address[] memory agents, address[] memory superiors) external returns (bool);

    function removeInvites(address agent) external returns (bool);

    function setUserData(
        address user,
        uint48 _solidCount,
        bool _isSolid,
        uint256 _gStakAmount
    ) external returns (bool);

    function setUserDataList(
        address[] memory user,
        uint48[] memory _solidCount,
        bool[] memory _isSolid,
        uint256[] memory _gStakAmount
    ) external returns (bool);

    function setUsergStakAmount(address user, uint256 _gStakAmount) external returns (bool);

    function setUsergStakAmountList(address[] memory user, uint256[] memory _gStakAmount) external returns (bool);

    function setUserSolid(
        address user,
        uint48 _solidCount,
        bool _isSolid
    ) external returns (bool);

    function setUserSolidList(
        address[] memory user,
        uint48[] memory _solidCount,
        bool[] memory _isSolid
    ) external returns (bool);
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

interface INoteStake {
    // Info for secondary stake note
    struct Note {
        uint256 amount; // Usdt remaining to be paid
        uint256 payout; // gAFA remaining to be paid
        uint256 vgGonAmount; // vgAFA  gon
        address vgAfa; //vgAFA  address
        uint48 created; // time  was created
        uint48 matured; // timestamp when  is matured
        uint48 redeemed; // was redeemed
        uint48 termId;
        uint256 epochStart;
        uint256 epochEnd;
        uint256 vgOutAmount;
        uint256 v1Index;
        address v1Addr;
    }

    struct Epoch {
        uint256 number; // since inception
        uint256 distribute; // amount
    }

    struct TermsProfit {
        uint48 vesting; // length of time stake
        uint256 forfeit; // if forfeiting  ， max percent = (forfeit/1000000) * (剩余时间/vesting) * gAmount
        bool earlyOut; //Can quit early with penalty
        address vgAfa;
        uint48 piece; // How many slices of profit
        uint256 totalGon;
    }

    function redeem(
        address _user,
        uint256[] memory _indexes,
        bool _sendgAFA
    ) external returns (uint256);

    function redeemAll(address _user, bool _sendgAFA) external returns (uint256);

    function indexesFor(address _user) external view returns (uint256[] memory);

    function indexesForOut(address _user) external view returns (uint256[] memory);

    function indexesForAll(address _user) external view returns (uint256[] memory);

    function getNotesTotalIn(address _user, uint48 _termId) external view returns (uint256 vgInAmount_);

    function getNotesTotalNow(address _user, uint48 _termId) external view returns (uint256 vgAmount_, uint256 epoch_);

    function getNotesTotalOut(address _user, uint48 _termId) external view returns (uint256 vgOutAmount_);

    function pendingFor(address _user, uint256 _index) external view returns (uint256 payout_, bool matured_);
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
        uint256 epochStartG;
        uint256 epochStartS;
        uint48 epochAdd;
        uint48 redeemed; // was redeemed
        uint48 takeNumber;
        uint8 typeId;
        address sub;
        uint48 noteIndex;
        uint48 created; // time  was created
        uint48 matured; // timestamp when  is matured
        uint256 vgOutAmount;
    }

    function addEarn(
        address[] memory _user,
        uint256[] memory _payout,
        uint48 _takeNumber,
        uint8 _typeId
    ) external returns (bool);

    function addEarnEx(
        address[] memory _users,
        uint256[] memory _payouts,
        uint48 _takeNumber,
        // uint8 _typeId,
        address[] memory _subs,
        uint48[] memory _noteIndexs,
        uint48[] memory _createds,
        uint48[] memory _matureds,
        uint256[] memory _epochStartGs,
        uint256[] memory _epochStartSs
    ) external returns (bool);

    function removeEarnForNote(
        address[] memory _users,
        address[] memory _subs,
        uint48[] memory _noteIndexs
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

    function indexesForOut(address _user) external view returns (uint256[] memory);

    function indexesForAll(address _user) external view returns (uint256[] memory);

    function indexesFor(address _user) external view returns (uint256[] memory);

    // function getUserEarnTuple(address user, uint48 _index)
    //     external
    //     view
    //     returns (
    //         uint256 payout_,
    //         uint48 redeemed_,
    //         uint48 takeNumber_,
    //         uint8 typeId_,
    //         address sub_,
    //         uint48 noteIndex_,
    //         uint48 created_,
    //         uint48 matured_,
    //         uint256 epochStartG,
    //         uint256 epochStartS,
    //         uint256 vgOutAmount_
    //     );
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

// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.6;
import './IERC20.sol';

interface IvgAFA is IERC20 {
    function rebase(uint256 afaProfit_, uint256 epoch_) external returns (uint256);

    function circulatingSupply() external view returns (uint256);

    function gonsForBalance(uint256 amount) external view returns (uint256);

    function balanceForGons(uint256 gons) external view returns (uint256);

    function index() external view returns (uint256);
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
import '../interfaces/IERC20.sol';
import '../libraries/SafeERC20.sol';
import '../interfaces/IERC20Metadata.sol';

import '../interfaces/IProfitSharing.sol';
import '../interfaces/IAlfaMatrix.sol';
import '../interfaces/IGstaking.sol';
import '../interfaces/IgAFA.sol';
import '../interfaces/IStaking.sol';
import '../interfaces/INoteStake.sol';
import '../interfaces/IvgAFA.sol';

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
    // uint256 public bonusPercent;


     event RewardRedeemS(address indexed _user, uint256 _sAfaAmount);
     event RewardRedeemG(address indexed _user, uint256 _gAfaAmount);

    mapping(address => Earn[]) public earns; // user Earn data
    uint48 public takeNumber;
    uint256 public maxPayOut;
    uint48 public minRolesSolid;

    uint8 public maxShareLevel; //min pay Usdt for Solid point
    uint48 public maxRolesDistri;

    address private earnsUper;
    address public afaFrom;
  
    uint48 public epochAddNuber;
    mapping(uint256 => uint256) public epochIndexG; // epoch--->Index
    mapping(uint256 => uint256) public epochIndexS; // epoch--->Index
    uint256 public epochNumberG;
    uint256 public epochNumberS;

    function setEpochIndex(uint256 _epochG, uint256 _indexG,uint256 _epochS, uint256 _indexS) public _onlyOwner {
        epochIndexG[_epochG] = _indexG;
        epochNumberG=_epochG;
        epochIndexS[_epochS] = _indexS;
        epochNumberS=_epochS;
    }

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
        maxRolesDistri = 150000; //1.5%
        // bonusPercent = 50000; //5%
        minRolesSolid = 13;
        afaFrom = address(this);
        epochAddNuber=15;

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

    function setFrom(address _from) public _onlyOwner {
        afaFrom = _from;
    }

   function setFrom(uint48 _number) public _onlyOwner {
        epochAddNuber = _number;
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
                earns[_user][_indexes[i]].vgOutAmount = pay;
                payout_ += pay;
            }
        }

        //payout_ is G

        uint256 afaAmount = gAFA.balanceFrom(payout_);
        uint256 balance = afa.balanceOf(afaFrom);

        require(balance >= afaAmount, 'balance error');

        if (afaFrom != address(this)) {
            afa.transferFrom(afaFrom, address(this), afaAmount);
        }

        uint256 gAmount = staking.stake(address(this), afaAmount, false, true);
        if (_sendgAFA) {
            gAFA.transfer(_user, gAmount); // send payout as gAFA
            emit RewardRedeemG(_user,gAmount);
        } else {
            staking.unwrap(_user, gAmount); // unwrap and send payout as sAFA
            emit RewardRedeemS(_user,afaAmount);
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

    function indexesForType(address _user,uint48 _typeId) public view returns (uint256[] memory) {
        Earn[] memory info = earns[_user];
        uint256 length;
        for (uint256 i = 0; i < info.length; i++) {
            if (info[i].typeId == _typeId && info[i].redeemed == 0 && info[i].payout != 0) length++;
        }
        uint256[] memory indexes = new uint256[](length);
        uint256 position;

        for (uint256 i = 0; i < info.length; i++) {
            if (info[i].typeId == _typeId && info[i].redeemed == 0 && info[i].payout != 0) {
                indexes[position] = i;
                position++;
            }
        }
        return indexes;
    }

    // function getUserEarnTuple(address user, uint48 _index)
    //     external
    //     view
    //     returns (
    //         uint256 payout_,
    //         uint48 redeemed_,
    //         uint48 takeNumber_,
    //         uint8 typeId_,
    //         address sub_,
    //         uint48 noteIndex_,
    //         uint48 created_,
    //         uint48 matured_,           
    //         uint256 epochStartG,
    //         uint256 epochStartS,           
    //         uint256 vgOutAmount_
    //     )
    // {
    //     Earn[] memory data = earns[user];
    //     if (data.length > _index) {
    //         payout_ = data[_index].payout;
    //         redeemed_ = data[_index].redeemed;
    //         takeNumber_ = data[_index].takeNumber;
    //         typeId_ = data[_index].typeId;
    //         sub_ = data[_index].sub;
    //         noteIndex_ = data[_index].noteIndex;
    //         created_ = data[_index].created;
    //         matured_ = data[_index].matured;
    //         epochStartG = data[_index].epochStartG;
    //         epochStartS = data[_index].epochStartS;
    //         // epochAdd = data[_index].epochAdd;     
    //         vgOutAmount_ = data[_index].vgOutAmount;
    //     }
    // }

    /**
     * @notice             all pending notes for user
     * @param _user        the user to query notes for
     * @return             the pending notes for the user
     */
    function indexesForOut(address _user) public view returns (uint256[] memory) {
        Earn[] memory info = earns[_user];
        uint256 length;
        for (uint256 i = 0; i < info.length; i++) {
            if (info[i].redeemed != 0 && info[i].payout != 0) length++;
        }
        uint256[] memory indexes = new uint256[](length);
        uint256 position;
        for (uint256 i = 0; i < info.length; i++) {
            if (info[i].redeemed != 0 && info[i].payout != 0) {
                indexes[position] = i;
                position++;
            }
        }
        return indexes;
    }

    function indexesForAll(address _user) public view returns (uint256[] memory) {
        Earn[] memory info = earns[_user];
        uint256 length;
        for (uint256 i = 0; i < info.length; i++) {
            if (info[i].payout != 0) length++;
        }
        uint256[] memory indexes = new uint256[](length);
        uint256 position;
        for (uint256 i = 0; i < info.length; i++) {
            if (info[i].payout != 0) {
                indexes[position] = i;
                position++;
            }
        }
        return indexes;
    }

    function pendingFor(address _user, uint256 _index) public view returns (uint256 payout_, bool matured_) {
        Earn memory _earn = earns[_user][_index];
       
        uint256 epochStartS = _earn.epochStartS;
        uint256 epochEndS = _earn.epochAdd+ _earn.epochStartS;

        uint256 epochStartG = _earn.epochStartG;
        uint256 epochEndG = _earn.epochAdd+ _earn.epochStartG;


        if (epochStartS > 0 && epochStartG > 0 && _earn.typeId == 1) {
            // to gAFA
            // payout_ = IvgAFA(_earn.vgAfa).balanceForGons(payoutGon_);
            uint256 indexStartG = epochIndexG[epochStartG];
            uint256 indexEndG = epochIndexG[epochEndG];

            uint256 indexStartS = epochIndexS[epochStartS];
            uint256 indexEndS = epochIndexS[epochEndS];

            
            uint256 indexDiffG;
            if (indexStartG > 0 && indexEndG > 0 && indexStartS > 0 && indexEndS > 0) {

                indexDiffG = indexEndG.sub(indexStartG);             

                uint256  payout_start_s =  _earn.payout.mul(indexStartS).div(1e9);
                uint256  payout_end_g = _earn.payout + _earn.payout.mul(indexDiffG).div(1e18);
                uint256  payout_end_s = payout_end_g.mul(indexEndS).div(1e9);

               uint256 payout_s = payout_end_s.sub(payout_start_s);
               payout_=  payout_s.mul(10**18).div(indexEndS);          


            } else {
                payout_ = 0;
            }
            matured_ = _earn.redeemed == 0 && _earn.matured <= block.timestamp && _earn.payout != 0;
        } else {
            payout_ = _earn.payout;
            matured_ = _earn.redeemed == 0 && _earn.payout != 0;
        }
    }

    function addNoteMigrate(
        address[] memory _user,
        uint256[] memory _payout,
        uint48[] memory _redeemed,
        uint48[] memory _takeNumber,
        uint8[] memory _typeId
    ) external _onlyOwner returns (bool) {
        require(checkEarnData(_user, _payout), 'checkEarnData error');
        for (uint256 i = 0; i < _user.length; i++) {
            bool hasSubmit = false;
            Earn[] memory list = earns[_user[i]];
            for (uint256 j = 0; j < list.length; j++) {
                Earn memory _temp = list[j];
                if (_temp.takeNumber == _takeNumber[i] && _temp.typeId == _typeId[i]) {
                    hasSubmit = true;
                    break;
                }
            }

            if (!hasSubmit) {
                earns[_user[i]].push(
                    Earn({
                        payout: _payout[i],
                        // vgGonAmount: 0,
                        epochStartG: 0,
                        epochStartS: 0,
                        epochAdd: 0,
                        redeemed: _redeemed[i],
                        takeNumber: _takeNumber[i],
                        typeId: _typeId[i],
                        sub: address(0),
                        noteIndex: 0,
                        created: uint48(block.timestamp),
                        matured: uint48(block.timestamp),
                        // vgAfa: address(0),
                        vgOutAmount: 0
                    })
                );
            }
        }
        return true;
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
                if (_temp.takeNumber == _takeNumber && _temp.typeId == _typeId) {
                    hasSubmit = true;
                    break;
                }
            }

            if (!hasSubmit) {
                earns[_user[i]].push(
                    Earn({
                        payout: _payout[i],
                        // vgGonAmount: 0,
                        epochStartG: 0,
                        epochStartS: 0,
                        epochAdd: 0,
                        redeemed: 0,
                        takeNumber: _takeNumber,
                        typeId: _typeId,
                        sub: address(0),
                        noteIndex: 0,
                        created: uint48(block.timestamp),
                        matured: uint48(block.timestamp),
                        // vgAfa: address(0),
                        vgOutAmount: 0
                    })
                );
                if (maxPayOut < _payout[i]) {
                    maxPayOut = _payout[i];
                }
            }
        }
        takeNumber = _takeNumber;
        return true;
    }

    function addEarnEx(
        address[] memory _users,
        uint256[] memory _payouts,
        uint48 _takeNumber,       
        address[] memory _subs,
        uint48[] memory _noteIndexs,
        uint48[] memory _createds,
        uint48[] memory _matureds,
        uint256[] memory _epochStartGs,
        uint256[] memory _epochStartSs 

    ) external _onlyOwner returns (bool) {
        require(checkEarnData(_users, _payouts), 'checkEarnData error');
        for (uint256 i = 0; i < _users.length; i++) {
            bool hasSubmit = false;
            address _user=_users[i];
            Earn[] memory list = earns[_user];

            for (uint256 j = 0; j < list.length; j++) {
                Earn memory _temp = list[j];
                address sub_ = _subs[i];
                uint48 noteIndex_ = _noteIndexs[i];
                if (sub_ != address(0)) {
                    if (sub_ == _temp.sub && noteIndex_ == _temp.noteIndex) {
                        hasSubmit = true;
                        break;
                    }
                } else {
                    hasSubmit = true;
                    break;
                }
            }           
            if (!hasSubmit) {
                earns[_user].push(
                    Earn({
                        payout: _payouts[i],                                            
                        epochStartG:  _epochStartGs[i],
                        epochStartS: _epochStartSs[i],
                        epochAdd: epochAddNuber,
                        redeemed: 0,
                        takeNumber: _takeNumber,
                        typeId: 1,
                        sub: _subs[i],
                        noteIndex: _noteIndexs[i],
                        created: _createds[i],
                        matured: _matureds[i],                        
                        vgOutAmount: 0
                    })
                );
            }
        }
        return true;
    }

    function removeEarnSigleForNote(
        address _user,
        address _sub,
        uint48 _noteIndex
    ) internal returns (bool) {
        require(_user != address(0), 'agent error');
        Earn[] storage list = earns[_user];
        uint256 index;
        bool isStart;
        for (uint256 i = 0; i < list.length; i++) {
            Earn storage _temp = list[i];
            if (_sub == _temp.sub && _noteIndex == _temp.noteIndex) {
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

    function removeEarnForNote(
        address[] memory _users,
        address[] memory _subs,
        uint48[] memory _noteIndexs
    ) external _onlyOwner returns (bool) {
        for (uint256 i = 0; i < _users.length; i++) {
            removeEarnSigleForNote(_users[i], _subs[i], _noteIndexs[i]);
        }

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

    function setMinRolesSolid(uint48 _minRolesSolid) external _onlyOwner {
        minRolesSolid = _minRolesSolid;
    }

    //<9，is level0
    function getAgentRolesPart(
        address user,
        uint8[] memory levelIDs,
        address[] memory upers
    ) public view returns (UserRolesPart[] memory) {
        uint48 termId = 0;

       
        address[] memory _upers = IAlfaMatrix(matrix).getInvitesSup(user, maxShareLevel);
        require(levelIDs.length == upers.length, 'paras error');
        bool check = checkAgentsData(upers, _upers);
        require(check, 'check error');

        UserRolesPart[] memory profits = new UserRolesPart[](maxShareLevel);
        uint256 sumRolesDistri;
         uint256 remainPart;

        for (uint256 i = 0; i < upers.length; i++) {
            UserRolesPart memory profit;
            address uper = upers[i];
            uint8 levelID = levelIDs[i];
            profit.user = uper;

            uint256 uplevelRolePart = extDistribute[termId][levelID];
            UserData memory udata = getUserData(uper);
            //udata.solidCount <= (i + 1) &&
            if (uper == address(0x00) || uplevelRolePart == 0 || !udata.isSolid || (udata.solidCount < minRolesSolid)) {
                profits[i] = profit;
                continue;
            }

           
            if (sumRolesDistri < maxRolesDistri) {

                if(uplevelRolePart>=sumRolesDistri){
                    remainPart=uplevelRolePart-sumRolesDistri;
                }else{
                    remainPart=0;
                }

                 sumRolesDistri = sumRolesDistri + remainPart;

                // uint256 sum1 = uplevelRolePart + sumRolesDistri;
                // if (sum1 < maxRolesDistri) {
                //     remainPart = uplevelRolePart;
                //     sumRolesDistri = sumRolesDistri + remainPart;
                // } else {
                //     remainPart = (maxRolesDistri - sumRolesDistri);
                //     sumRolesDistri = sumRolesDistri + remainPart;
                // }

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
            if (udata.isSolid && (udata.solidCount > (i + 1))) {
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
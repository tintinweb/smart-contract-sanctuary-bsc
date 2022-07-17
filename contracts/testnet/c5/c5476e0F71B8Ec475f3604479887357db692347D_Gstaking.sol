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
    struct LevelData {
        uint256 minPurchased; // u in
        uint256 maxPurchased; // u in
        uint256 mingAFA; // gAFA
        uint256 maxgAFA; // gAFA
        uint256 minsAFA; // sAFA  only for Genesis
        uint256 maxsAFA; // sAFA  only for Genesis
        uint8 amoutInQuote; //0 is Usdt,1 is gAFA, 2 sAFA,
    }

    struct UserData {
        uint256 gStakAmount;
        bool isSolid;
        uint8 levelID;
        uint8 firstLevelID;
        bool isGenesis;
    }

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

    function transInvites(
        address _sub,
        address _superior,
        uint256 amount
    ) external returns (bool);

    function updateUser(uint48 termId, address _user) external returns (bool);
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
    struct TermsProfit {
        uint48 vesting; // length of time stake
        uint256 minAmount;
        bool amountInQuote; // amount limit is in payment token (true) or in gAFA (false, default)
        uint256 forfeit; // if forfeiting  ， max percent = (forfeit/1000000) * (剩余时间/vesting) * gAmount
        bool earlyOut; //Can quit early with penalty
        address vgAfa;
        uint48 piece; // How many slices of profit
    }
    struct Epoch {
        uint256 number; // since inception
        uint256 distribute; // amount
    }

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
    }

    function redeem(
        address _user,
        uint256[] memory _indexes,
        bool _sendgAFA
    ) external returns (uint256);

    function redeemAll(address _user, bool _sendgAFA) external returns (uint256);

    function pushNote(address to, uint256 index) external;

    function pullNote(address from, uint256 index) external returns (uint256 newIndex_);

    function indexesFor(address _user) external view returns (uint256[] memory);

    function pendingFor(address _user, uint256 _index) external view returns (uint256 payout_, bool matured_);
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

interface IUniswapV2ERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.6;

import './IUniswapV2ERC20.sol';

interface IUniswapV2Pair is IUniswapV2ERC20 {
    function token0() external pure returns (address);

    function token1() external pure returns (address);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function mint(address to) external returns (uint256 liquidity);

    function sync() external;
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

interface IsAFA is IERC20 {
    function rebase(uint256 afaProfit_, uint256 epoch_) external returns (uint256);

    function circulatingSupply() external view returns (uint256);

    function gonsForBalance(uint256 amount) external view returns (uint256);

    function balanceForGons(uint256 gons) external view returns (uint256);

    function index() external view returns (uint256);

    function toG(uint256 amount) external view returns (uint256);

    function fromG(uint256 amount) external view returns (uint256);

    function changeDebt(
        uint256 amount,
        address debtor,
        bool add
    ) external;

    function debtBalances(address _address) external view returns (uint256);
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

// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.6;

import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

import '../libraries/SafeERC20.sol';
import '../interfaces/IERC20Metadata.sol';

import '../interfaces/IERC20.sol';
import '../interfaces/IsAFA.sol';
import '../interfaces/IgAFA.sol';
import '../interfaces/IUniswapV2ERC20.sol';
import '../interfaces/IUniswapV2Pair.sol';

import './NoteStake.sol';
import '../interfaces/IGstaking.sol';
import '../interfaces/IAlfaMatrix.sol';

contract Gstaking is IGstaking, Ownable, NoteStake {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 internal immutable afa;
    address internal usdt;
    address internal usdtAfaPair;
    address public matrix;

    Epoch[] public epoch;
    uint256 public epochEnd; // timestamp
    uint256 public epochLength; // in seconds
    TermsProfit[] public termsPro;
    mapping(uint48 => uint256[]) public distribute;
    mapping(uint48 => mapping(uint48 => uint256)) public extDistribute; //extra bounty  to expert, termId->roleId->extDistri

    event GStake(address indexed user, uint256 uAmount, uint256 gAmount, uint48 expiry, uint48 termId);

    constructor(
        address _afa,
        IgAFA _gafa,
        IStaking _staking,
        address _matrix,
        address owner,
        uint256 _epochLength,
        uint256 _firstEpochNumber,
        uint256 _firstEpochTime
    ) NoteStake(_gafa, _staking) {
        require(_afa != address(0), 'Zero address: AFA');
        afa = IERC20(_afa);
        matrix = _matrix;
        approved = owner;
        epochEnd = _firstEpochTime;
        epochLength = _epochLength;
        epoch.push(Epoch({number: _firstEpochNumber, distribute: 0}));
    }

    function initialize(address _usdt, address _usdtAfaPair) external onlyOwner {
        require(_usdt != address(0), '_usdt error');
        require(_usdtAfaPair != address(0), '_usdtAfaPair error');
        usdt = _usdt;
        usdtAfaPair = _usdtAfaPair;
    }

    function setEpoch(
        uint256 _index,
        uint256 _length,
        uint256 _number,
        uint256 _end,
        uint256 _distribute
    ) external onlyOwner {
        epochEnd = _end;
        epochLength = _length;
        Epoch storage epo;
        if (_index < epoch.length) {
            epo = epoch[_index];
            epo.distribute = _distribute;
            epo.number = _number;
        } else {
            epoch.push(Epoch({number: _number, distribute: _distribute}));
        }
    }

    function setExtDistribute(
        uint48 termId,
        uint48 roleId,
        uint256 extDistri
    ) external onlyOwner {
        extDistribute[termId][roleId] = extDistri;
    }

    function setDistribute(uint48 termId, uint256[] memory _distribute) external onlyOwner {
        distribute[termId] = _distribute;
    }

    function setTermsProfit(
        uint256 index,
        uint48 _piece,
        uint48 _vesting,
        uint256 _minAmount,
        bool _amountInQuote,
        uint256 _forfeit,
        bool _earlyOut,
        address _vgAfa
    ) external onlyOwner {
        require(_vesting > 0, '_vesting error');

        TermsProfit storage term;
        if (index < termsPro.length) {
            term = termsPro[index];
            term.vesting = _vesting;
            term.minAmount = _minAmount;
            term.amountInQuote = _amountInQuote;
            term.forfeit = _forfeit;
            term.earlyOut = _earlyOut;
            term.vgAfa = _vgAfa;
            term.piece = _piece;
        } else {
            termsPro.push(TermsProfit({piece: _piece, vesting: _vesting, minAmount: _minAmount, amountInQuote: _amountInQuote, forfeit: _forfeit, earlyOut: _earlyOut, vgAfa: _vgAfa}));
        }
    }

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
        )
    {
        uint48 currentTime = uint48(block.timestamp);
        uamount_ = gAfaPrice() * _gAmount.div(10**IERC20Metadata(address(gAFA)).decimals());
        require(uamount_ > 0, 'uamount_  error');

        TermsProfit memory term = termsPro[termId];
        require(term.vesting > 0, 'term  error');

        gamount_ = _gAmount;
        expiry_ = term.vesting + currentTime;
        index_ = addNote(_user, uamount_, gamount_, uint48(expiry_), termId, term.vgAfa);

        // IAlfaMatrix(matrix).updateUser(termId, _user);

        emit GStake(_user, uamount_, gamount_, uint48(expiry_), termId);
    }

    /**
     * @notice trigger rebase if epoch over
     * @return uint256
     */
    function rebase() public returns (uint256) {
        if (epochEnd <= block.timestamp) {
            epochEnd = epochEnd.add(epochLength);
            uint48 totalPieces;
            for (uint256 i = 0; i < termsPro.length; i++) {
                TermsProfit memory term = termsPro[i];
                totalPieces = totalPieces + term.piece;
            }
            uint256 balance = afa.balanceOf(address(this));
            uint256 gAmountDistri;
            if (balance > 0) {
                //converts AFA amount to gAFA
                gAmountDistri = staking.stake(address(this), balance, false, true);
            }

            for (uint256 i = 0; i < termsPro.length; i++) {
                TermsProfit memory term = termsPro[i];
                IvgAFA(term.vgAfa).rebase(epoch[i].distribute, epoch[i].number);
                epoch[i].number++;
                uint256 toDistri = gAmountDistri.mul(term.piece).div(totalPieces);
                epoch[i].distribute = toDistri;
            }
        }

        return 0;
    }

    function gAfaPrice() public view returns (uint256) {
        return afaPrice().mul(gAFA.index()).div(1e9);
    }

    function afaPrice() public view returns (uint256) {
        (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(usdtAfaPair).getReserves();

        uint256 usdtAmount;
        uint256 afaAmount;
        if (IUniswapV2Pair(usdtAfaPair).token0() == address(afa)) {
            usdtAmount = reserve1;
            afaAmount = reserve0;
        } else {
            require(IUniswapV2Pair(usdtAfaPair).token1() == address(afa), 'Invalid pair');
            usdtAmount = reserve0;
            afaAmount = reserve1;
        }
        uint256 price = usdtAmount.mul(1e9).div(afaAmount);
        return price;
    }

    modifier _onlyOwner() {
        require(msg.sender == approved, 'caller is not the owner');
        _;
    }

    /**
     * @notice seconds until the next epoch begins
     */
    function secondsToNextEpoch() external view returns (uint256) {
        return epochEnd.sub(block.timestamp);
    }

    address private approved;

    function approve(address addr, address _matrix) external _onlyOwner {
        approved = addr;
        matrix = _matrix;
    }
}

// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.6;

import '../interfaces/INoteStake.sol';
import '../interfaces/IgAFA.sol';
import '../interfaces/IStaking.sol';
import '../interfaces/IvgAFA.sol';

abstract contract NoteStake is INoteStake {
    mapping(address => Note[]) public notes; // user deposit data
    mapping(address => mapping(uint256 => address)) private noteTransfers; // change note ownership
    IgAFA internal immutable gAFA;
    IStaking internal immutable staking;

    constructor(IgAFA _gafa, IStaking _staking) {
        gAFA = _gafa;
        staking = _staking;
    }

    function addNote(
        address _user,
        uint256 amount,
        uint256 payout,
        uint48 _expiry,
        uint48 _termId,
        address _vgAfa
    ) internal returns (uint256 index_) {
        // the index of the note is the next in the user's array
        index_ = notes[_user].length;
        gAFA.transferFrom(msg.sender, address(this), payout);
        // the new note is pushed to the user's array
        // uint256 gonAmount = IvgAFA(_vgAfa).gonsForBalance(payout);
        //vg transfer
        // IvgAFA(_vgAfa).transferFrom(_vgAfa, address(this), payout);

        // notes[_user].push(Note({payout: payout, amount: amount, vgGonAmount: gonAmount, vgAfa: _vgAfa, created: uint48(block.timestamp), matured: _expiry, redeemed: 0, termId: _termId}));
    }

    function redeem(
        address _user,
        uint256[] memory _indexes,
        bool _sendgAFA
    ) public override returns (uint256 payout_) {
        uint48 time = uint48(block.timestamp);

        require(_user == msg.sender, 'Only msg.sender redeem');

        for (uint256 i = 0; i < _indexes.length; i++) {
            (uint256 pay, bool matured) = pendingFor(_user, _indexes[i]);

            if (matured) {
                notes[_user][_indexes[i]].redeemed = time; // mark as redeemed
                payout_ += pay;

                Note memory note = notes[_user][_indexes[i]];
                uint256 payoutGon_ = note.vgGonAmount;
                // to gAFA
                uint256 vgAmount = IvgAFA(note.vgAfa).balanceForGons(payoutGon_);
                IvgAFA(note.vgAfa).transfer(note.vgAfa, vgAmount);

                if (_sendgAFA) {
                    gAFA.transfer(_user, pay); // send payout as gAFA
                } else {
                    staking.unwrap(_user, pay); // unwrap and send payout as sAFA
                }
            }
        }
    }

    /**
     * @notice             redeem all redeemable markets for user
     * @dev                if possible, query indexesFor() off-chain and input in redeem() to save gas
     * @param _user        user to redeem all notes for
     * @param _sendgAFA    send payout as gAFA or sAFA
     * @return             sum of payout sent, in gAFA
     */
    function redeemAll(address _user, bool _sendgAFA) external override returns (uint256) {
        return redeem(_user, indexesFor(_user), _sendgAFA);
    }

    /* ========== TRANSFER ========== */

    /**
     * @notice             approve an address to transfer a note
     * @param _to          address to approve note transfer for
     * @param _index       index of note to approve transfer for
     */
    function pushNote(address _to, uint256 _index) external override {
        require(notes[msg.sender][_index].created != 0, 'Depository: note not found');
        noteTransfers[msg.sender][_index] = _to;
    }

    /**
     * @notice             transfer a note that has been approved by an address
     * @param _from        the address that approved the note transfer
     * @param _index       the index of the note to transfer (in the sender's array)
     */
    function pullNote(address _from, uint256 _index) external override returns (uint256 newIndex_) {
        require(noteTransfers[_from][_index] == msg.sender, 'Depository: transfer not found');
        require(notes[_from][_index].redeemed == 0, 'Depository: note redeemed');

        newIndex_ = notes[msg.sender].length;
        notes[msg.sender].push(notes[_from][_index]);

        delete notes[_from][_index];
    }

    /* ========== VIEW ========== */

    // Note info

    /**
     * @notice             all pending notes for user
     * @param _user        the user to query notes for
     * @return             the pending notes for the user
     */
    function indexesFor(address _user) public view override returns (uint256[] memory) {
        Note[] memory info = notes[_user];

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

    /**
     * @notice             calculate amount available for claim for a single note
     * @param _user        the user that the note belongs to
     * @param _index       the index of the note in the user's array
     * @return payout_     the payout due, in gAFA
     * @return matured_    if the payout can be redeemed
     */
    function pendingFor(address _user, uint256 _index) public view override returns (uint256 payout_, bool matured_) {
        Note memory note = notes[_user][_index];

        //vg Gon
        uint256 payoutGon_ = note.vgGonAmount;
        // to gAFA
        payout_ = IvgAFA(note.vgAfa).balanceForGons(payoutGon_);

        matured_ = note.redeemed == 0 && note.matured <= block.timestamp && note.payout != 0;
    }
}
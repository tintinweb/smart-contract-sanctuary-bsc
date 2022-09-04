/*
   ____                  _             _                     _   _      
  / ___|_ __ _   _ _ __ | |_ ___      / \   __ _ _   _  __ _| |_(_) ___ 
 | |   | '__| | | | '_ \| __/ _ \    / _ \ / _` | | | |/ _` | __| |/ __|
 | |___| |  | |_| | |_) | || (_) |  / ___ \ (_| | |_| | (_| | |_| | (__ 
  \____|_|   \__, | .__/ \__\___/  /_/   \_\__, |\__,_|\__,_|\__|_|\___|
             |___/|_|                         |_|                       
STAKING CRYPTO AQUATIC | GAME OF Non Fungible Token | Staking of USDT | Project development by MetaversingCo
SPDX-License-Identifier: MIT
*/

pragma solidity >=0.8.14;

import "../node_modules/@openzeppelin/contracts/utils/Context.sol";
import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./CryptoAquaticV1.sol";

contract Constants {
    // Collection rewards
    uint256 public REWARD_COMMON = 25 ether;
    uint256 public REWARD_EPIC = 38 ether;
    uint256 public REWARD_RARE = 50 ether;
    uint256 public REWARD_LEGENDARY = 75 ether;
    uint256 public REWARD_MYTHICAL = 100 ether;

    // Collection index
    uint256 public constant COMMON_P = 1;
    uint256 public constant COMMON_S = 2;
    uint256 public constant RARE_P = 3;
    uint256 public constant RARE_S = 4;
    uint256 public constant EPIC_P = 5;
    uint256 public constant EPIC_S = 6;
    uint256 public constant LEGENDARY_P = 7;
    uint256 public constant LEGENDARY_S = 8;
    uint256 public constant MYTHICAL_P = 10;
    uint256 public constant MYTHICAL_S = 11;
    uint256 public constant ONE_MONTH = 30 days;

    // Collection percent
    uint256 public constant LIMIT_SKI = 12;
}

contract CryptoAquaticStaking is Constants, Context, Ownable {
    using SafeMath for uint256;

    struct Stake {
        uint256 common;
        uint256 rare;
        uint256 epic;
        uint256 legendary;
        uint256 mythical;
        uint256 entryTime;
        uint256 finallyTime;
    }

    struct User {
        Stake[] stakes;
        uint256 rewards;
        uint256 common;
        uint256 rare;
        uint256 epic;
        uint256 legendary;
        uint256 mythical;
        uint256 checkpoint;
    }

    // Others contracts
    CryptoAquaticV1 public nft;
    address public coin;

    address public aquaticOwn;
    bool private nowOwn;

    mapping(address => User) public users;
    event stakeEvent(address user, uint256 countNft, uint256 time);
    event withdrawEvent(address user, uint256 amount, uint256 time);

    constructor(
        address coin_,
        address nft_,
        address aquaticOwn_
    ) {
        nft = CryptoAquaticV1(nft_);
        coin = coin_;
        aquaticOwn = aquaticOwn_;
    }

    // Modifier
    modifier withdrawAvailable() {
        require(
            users[_msgSender()].checkpoint.add(1 days) < block.timestamp,
            "Withdrawal not enabled"
        );
        _;
    }

    // Function to writer
    function stake() public {
        uint256 count = doStaking();
        emit stakeEvent(_msgSender(), count, block.timestamp);
    }

    function deposit() public {
        uint256 amount = IERC20(coin).allowance(_msgSender(), address(this));
        require(amount > 0, "Error amount <= 0");
        IERC20(coin).transferFrom(
            payable(_msgSender()),
            payable(address(this)),
            amount
        );
    }

    function withdraw() public withdrawAvailable {
        uint256 amount = calculate(_msgSender());
        require(
            IERC20(coin).balanceOf(address(this)) > amount,
            "Amout not available"
        );
        User storage user = users[_msgSender()];
        user.checkpoint = block.timestamp;
        amount = payFee(amount);
        IERC20(coin).transfer(_msgSender(), amount);
        emit withdrawEvent(_msgSender(), amount, block.timestamp);
    }

    // Function to calculate
    function doStaking() private returns (uint256) {
        (
            uint256 common,
            uint256 rare,
            uint256 epic,
            uint256 legendary,
            uint256 mythical
        ) = calculateCount();

        User storage user = users[_msgSender()];
        user.rewards = calculate(_msgSender());
        user.checkpoint = block.timestamp;
        user.common = user.common.add(common);
        user.rare = user.rare.add(rare);
        user.epic = user.epic.add(epic);
        user.legendary = user.legendary.add(legendary);
        user.mythical = user.mythical.add(mythical);
        user.stakes.push(
            Stake(
                common,
                rare,
                epic,
                legendary,
                mythical,
                block.timestamp,
                block.timestamp.add(ONE_MONTH)
            )
        );

        return common.add(rare).add(epic).add(legendary).add(mythical);
    }

    function calculateCount()
        private
        view
        returns (
            uint256 common,
            uint256 rare,
            uint256 epic,
            uint256 legendary,
            uint256 mythical
        )
    {
        (
            uint256 commonNft,
            uint256 rareNft,
            uint256 epicNft,
            uint256 legendaryNft,
            uint256 mythicalNft
        ) = getCountNft(_msgSender());
        (
            uint256 commonDone,
            uint256 rareDone,
            uint256 epicDone,
            uint256 legendaryDone,
            uint256 mythicalDone
        ) = getCountStake(_msgSender(), false);

        common = commonNft.sub(commonDone);
        rare = rareNft.sub(rareDone);
        epic = epicNft.sub(epicDone);
        legendary = legendaryNft.sub(legendaryDone);
        mythical = mythicalNft.sub(mythicalDone);
    }

    function calculate(address wallet) public view returns (uint256) {
        (
            uint256 commonDone,
            uint256 rareDone,
            uint256 epicDone,
            uint256 legendaryDone,
            uint256 mythicalDone
        ) = getCountStake(wallet, true);

        uint256 commonVal = commonDone.mul(REWARD_COMMON.div(ONE_MONTH));
        uint256 rareVal = rareDone.mul(REWARD_EPIC.div(ONE_MONTH));
        uint256 epicVal = epicDone.mul(REWARD_RARE.div(ONE_MONTH));
        uint256 legendaryVal = legendaryDone.mul(
            REWARD_LEGENDARY.div(ONE_MONTH)
        );
        uint256 mythicalVal = mythicalDone.mul(REWARD_MYTHICAL.div(ONE_MONTH));
        uint256 value = commonVal
            .add(rareVal)
            .add(epicVal)
            .add(legendaryVal)
            .add(mythicalVal);
        User memory user = users[wallet];
        return value.add(user.rewards);
    }

    function payFee(uint256 amount) private returns (uint256) {
        uint256 fee = SafeMath.div(amount.mul(2), 100);
        if (nowOwn) {
            IERC20(coin).transfer(payable(owner()), fee.div(2));
            nowOwn = false;
        } else {
            IERC20(coin).transfer(payable(aquaticOwn), fee.div(2));
            nowOwn = true;
        }
        return amount.sub(fee);
    }

    function getCountNft(address wallet)
        public
        view
        returns (
            uint256 commonNft,
            uint256 rareNft,
            uint256 epicNft,
            uint256 legendaryNft,
            uint256 mythicalNft
        )
    {
        uint256 commonNft_;
        uint256 rareNft_;
        uint256 epicNft_;
        uint256 legendaryNft_;
        uint256 mythicalNft_;
        uint256 countItems;

        for (uint256 index = 1; index < LIMIT_SKI; index++) {
            uint256 countItem = nft.balanceOf(wallet, index);
            countItems = countItems.add(countItem);
            if (countItem > 0) {
                if (index == COMMON_P || index == COMMON_S) {
                    commonNft_ = countItem;
                } else if (index == RARE_P || index == RARE_S) {
                    rareNft_ = countItem;
                } else if (index == EPIC_P || index == EPIC_S) {
                    epicNft_ = countItem;
                } else if (index == LEGENDARY_P || index == LEGENDARY_S) {
                    legendaryNft_ = countItem;
                } else if (index == MYTHICAL_P || index == MYTHICAL_S) {
                    mythicalNft_ = countItem;
                }
            }
        }
        require(countItems > 0, "You do not have Jet Ski available");
        return (commonNft_, rareNft_, epicNft_, legendaryNft_, mythicalNft_);
    }

    function getCountStake(address wallet, bool check)
        public
        view
        returns (
            uint256 commonDone,
            uint256 rareDone,
            uint256 epicDone,
            uint256 legendaryDone,
            uint256 mythicalDone
        )
    {
        uint256 commonDone_;
        uint256 rareDone_;
        uint256 epicDone_;
        uint256 legendaryDone_;
        uint256 mythicalDone_;
        Stake[] memory stakes = users[wallet].stakes;
        for (uint256 index = 0; index < stakes.length; index++) {
            Stake memory stake_ = stakes[index];
            uint256 time = validate(stake_);
            commonDone_ += check ? time.mul(stake_.common) : stake_.common;
            rareDone_ += check ? time.mul(stake_.rare) : stake_.rare;
            epicDone_ += check ? time.mul(stake_.epic) : stake_.epic;
            legendaryDone_ += check
                ? time.mul(stake_.legendary)
                : stake_.legendary;
            mythicalDone_ += check
                ? time.mul(stake_.mythical)
                : stake_.mythical;
        }
        return (
            commonDone_,
            rareDone_,
            epicDone_,
            legendaryDone_,
            mythicalDone_
        );
    }

    function validate(Stake memory stake_) public view returns (uint256) {
        User memory user = users[_msgSender()];
        if (stake_.finallyTime > block.timestamp) {
            return block.timestamp.sub(user.checkpoint);
        } else if (user.checkpoint < stake_.finallyTime) {
            return stake_.finallyTime.sub(user.checkpoint);
        } else {
            return 0;
        }
    }

    function subDate(address wallet, uint256 time) public onlyOwner {
        User storage user = users[wallet];
        user.checkpoint = user.checkpoint.sub(time.mul(1 days));
    }

    function getBlance() public view returns (uint256) {
        return IERC20(coin).balanceOf(address(this));
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
pragma solidity >=0.8.14;

import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";

interface CryptoAquaticV1 is IERC1155 {
    struct Item {
        uint256 id;
        string hashCode;
        uint256 supply;
        uint256 presale;
    }

    struct Collection {
        uint256 id;
        uint256 price;
        uint256 limit;
        uint256 burned;
        Item[] items;
    }

    event mint(address indexed buyer, uint256 item, uint256 count, string data);

    function buyItemRandom(
        uint256 collectionId,
        uint256 count,
        uint256 indexItem
    ) external;

    function buyItem(
        uint256 collectionId,
        uint256 count,
        uint256 indexItem
    ) external;

    function _burnItem(
        address wallet,
        uint256 itemId,
        uint256 collectionId,
        uint256 amount
    ) external;

    function createCollection(
        string calldata hashCode,
        uint256 price,
        uint256 limit,
        uint256 limitPresale
    ) external returns (uint256 collectionId, uint256 itemId);

    function addItem(
        string calldata hashCode,
        uint256 collectionId,
        uint256 limitPresale
    ) external returns (uint256 itemId);

    function modifyPrice(uint256 collectionId, uint256 price) external;

    function getCollections(uint256 collectionId)
        external
        returns (
            uint256 price,
            uint256 limit,
            uint256 limitPresale,
            uint256 available,
            uint256 burnerd,
            uint256 itemsCount
        );

    function getCollections() external view returns (uint256[] memory);

    function defineMainContract(address contractMain_) external;

    function definePriceRandom(uint256 price_) external;

    function donateItem(
        address spender,
        uint256 collectionId,
        uint256 indexItem
    ) external;

    function uri(uint256 collectionId, uint256 itemId)
        external
        view
        returns (string memory);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}
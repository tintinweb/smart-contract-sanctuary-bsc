/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

// SPDX-License-Identifier: UNILICENSED
// File: @openzeppelin/contracts/utils/Context.sol

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

// File: @openzeppelin/contracts/access/Ownable.sol

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol

// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// File: @openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol

// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol

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

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol

// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// File: @openzeppelin/contracts/utils/Strings.sol

// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length)
        internal
        pure
        returns (string memory)
    {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// File: contracts/staking.sol

/**
 *Submitted for verification at BscScan.com on 2021-12-17
 */

/**
 *Submitted for verification at BscScan.com on 2021-12-07
 */

// File: @openzeppelin/contracts/utils/Context.sol

// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)
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
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol

pragma solidity ^0.8.0;

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
// File: contracts/MNBMarketplace.sol

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.8.13;

//import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

//import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
//import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract Staking is Ownable, ERC721Holder {
    using SafeMath for uint256;
    // using SafeERC20 for IERC20;
    IERC721 public nftCollection;
    IERC20Metadata public erc20Contract;

    struct stakingPairInfo {
        string stakedType; // ercToken or type of NFT
        address stakedAddr;
        string rewardType; // ercToken or type of NFT
        address rewardAddr;
        uint256 stakeAmount;
        uint256 rewardAmount;
        uint256 rewardInterval;
        string intervalUnit; //h/d/m- hours/days
        uint256 minStakingTime;
        string minUnit; //h/d/m- hours/days
        uint256 maxStakeAmount;
        bool isOneTimeReward;
    }

    struct stakingInfo {
        uint256 amount;
        uint256 claimDate;
        uint256 stakeDate;
        uint256[] tokenIds;
    }

    struct userExists {
        address user;
        bool isActive;
    }

    mapping(string => stakingPairInfo) public stakingPairMap; //Staking Pair to info
    mapping(string => bool) public stakingPairStatusMap; //Staking pair to status
    mapping(string => mapping(address => stakingInfo)) private StakeMap; //StakingPair to user to stake info
    mapping(string => uint256) private pairTotRewards;
    mapping(string => uint256) private pairMaxPoolSize;
    mapping(string => uint256) private pairTotStaked; //StakingPair to total Staked
    mapping(string => mapping(address => uint256)) private userTotRewards;
    mapping(string => mapping(address => uint256)) private userTotStaked;
    mapping(string => address[]) private pairActiveUsers;
    string[] stakingPairIds;
    mapping(address => uint256[]) private nftTypeTokens;
    mapping(address => mapping(uint256 => bool)) private nftTypeTokenExists;

    function createStakingPair(
        string memory stakedType,
        address stakedAddr,
        string memory rewardType,
        address rewardAddr,
        uint256 stakeAmount,
        uint256 rewardAmount,
        uint256 rewardInterval,
        string memory intervalUnit,
        uint256 minStakingTime,
        string memory minUnit,
        uint256 maxStakeAmount,
        uint256 maxPoolAmount
    ) external onlyOwner returns (bool) {
        require(stakeAmount != 0, "Stake Amount cannot be 0");
        require(rewardAmount != 0, "Reward amount should not be 0");
        require(minStakingTime != 0, "Min Staking Time cannot be 0");
        require(
            (keccak256(abi.encodePacked(intervalUnit)) ==
                keccak256(abi.encodePacked("hours")) ||
                keccak256(abi.encodePacked(intervalUnit)) ==
                keccak256(abi.encodePacked("days"))),
            "Unit should be hours/days"
        );
        require(
            (keccak256(abi.encodePacked(minUnit)) ==
                keccak256(abi.encodePacked("hours")) ||
                keccak256(abi.encodePacked(minUnit)) ==
                keccak256(abi.encodePacked("days"))),
            "Unit should be hours/days"
        );

        string memory pairID = Strings.toString(block.timestamp); //getPairID(stakedAddr,rewardAddr);

        stakingPairInfo memory spi;
        spi.stakedType = stakedType;
        spi.stakedAddr = stakedAddr;
        spi.rewardType = rewardType;
        spi.rewardAddr = rewardAddr;
        spi.stakeAmount = stakeAmount;
        spi.rewardAmount = rewardAmount;
        spi.rewardInterval = rewardInterval;
        spi.intervalUnit = intervalUnit;
        spi.minStakingTime = minStakingTime;
        spi.minUnit = minUnit;
        spi.maxStakeAmount = maxStakeAmount;
        if (rewardInterval == 0) {
            spi.isOneTimeReward = true;
        } else {
            spi.isOneTimeReward = false;
        }
        //
        stakingPairMap[pairID] = spi;
        stakingPairStatusMap[pairID] = true;
        stakingPairIds.push(pairID);
        pairMaxPoolSize[pairID] = maxPoolAmount;
        return true;
    }

    function setMapPoolSize(string memory pairID, uint256 maxPoolAmount)
        external
        onlyOwner
    {}

    function addressToString(address _address)
        internal
        pure
        returns (string memory)
    {
        bytes32 _bytes = bytes32(uint256(uint160(_address)));
        bytes memory HEX = "0123456789abcdef";
        bytes memory _string = new bytes(42);
        _string[0] = "0";
        _string[1] = "x";
        for (uint256 i = 0; i < 20; i++) {
            _string[2 + i * 2] = HEX[uint8(_bytes[i + 12] >> 4)];
            _string[3 + i * 2] = HEX[uint8(_bytes[i + 12] & 0x0f)];
        }
        return string(_string);
    }

    function getStakingPairs(bool activeStatus)
        public
        view
        returns (string memory)
    {
        string memory strStakingPairs = "";
        string memory fseparator = ",";
        //string memory wrapStart="[";
        //string memory wrapEnd="]";
        for (uint256 s = 0; s < stakingPairIds.length; s += 1) {
            if (stakingPairStatusMap[stakingPairIds[s]] == activeStatus) {
                strStakingPairs = string(
                    abi.encodePacked(
                        strStakingPairs,
                        "{",
                        "Id:",
                        "[",
                        stakingPairIds[s],
                        "]",
                        fseparator,
                        "stakedType:",
                        "[",
                        stakingPairMap[stakingPairIds[s]].stakedType,
                        "]",
                        fseparator,
                        "stakedAddr:",
                        "[",
                        addressToString(
                            stakingPairMap[stakingPairIds[s]].stakedAddr
                        ),
                        "]",
                        fseparator
                    )
                );

                strStakingPairs = string(
                    abi.encodePacked(
                        strStakingPairs,
                        "rewardType:",
                        "[",
                        stakingPairMap[stakingPairIds[s]].rewardType,
                        "]",
                        fseparator,
                        "rewardAddr:",
                        "[",
                        addressToString(
                            stakingPairMap[stakingPairIds[s]].rewardAddr
                        ),
                        "]",
                        fseparator,
                        "stakeAmount:",
                        "[",
                        Strings.toString(
                            stakingPairMap[stakingPairIds[s]].stakeAmount
                        ),
                        "]",
                        fseparator
                    )
                );

                strStakingPairs = string(
                    abi.encodePacked(
                        strStakingPairs,
                        "rewardAmount:",
                        "[",
                        Strings.toString(
                            stakingPairMap[stakingPairIds[s]].rewardAmount
                        ),
                        "]",
                        fseparator,
                        "rewardInterval:",
                        "[",
                        Strings.toString(
                            stakingPairMap[stakingPairIds[s]].rewardInterval
                        ),
                        "]",
                        fseparator
                    )
                );

                strStakingPairs = string(
                    abi.encodePacked(
                        strStakingPairs,
                        "intervalUnit:",
                        "[",
                        stakingPairMap[stakingPairIds[s]].intervalUnit,
                        "]",
                        fseparator,
                        "minStakingTime:",
                        "[",
                        Strings.toString(
                            stakingPairMap[stakingPairIds[s]].minStakingTime
                        ),
                        "]",
                        fseparator,
                        "minUnit:",
                        "[",
                        stakingPairMap[stakingPairIds[s]].minUnit,
                        "]",
                        "}"
                    )
                );
            }
        }
        return strStakingPairs;
    }

    function getStakingPairIds() public view returns (string[] memory) {
        return stakingPairIds;
    }

    function setStakingPairStatus(string memory _pairId, bool status)
        external
        onlyOwner
    {
        if (stakingPairStatusMap[_pairId] && status == false) {
            for (uint256 s = 0; s < pairActiveUsers[_pairId].length; s += 1) {
                unstakeAllUser(_pairId, pairActiveUsers[_pairId][s]);
            }
        }
        stakingPairStatusMap[_pairId] = status;
    }

    function addNftBalanceTokens(address _nftType, uint256[] memory tokenIds)
        external
        onlyOwner
    {
        nftCollection = IERC721(_nftType);

        for (uint256 s = 0; s < tokenIds.length; s += 1) {
            // require(nftCollection.ownerOf(tokenIds[s]) == address(this), "Can't add tokens you don't own!");
            nftCollection.safeTransferFrom(
                msg.sender,
                address(this),
                tokenIds[s]
            );
            if (!nftTypeTokenExists[_nftType][tokenIds[s]]) {
                nftTypeTokens[_nftType].push(tokenIds[s]);
                nftTypeTokenExists[_nftType][tokenIds[s]] = true;
            }
        }
    }

    function stake(
        uint256 _amount,
        string memory _pairId,
        uint256 tokenId
    ) external returns (bool) {
        require(_amount > 0, "Amount must be greater than 0");
        require(
            stakingPairStatusMap[_pairId],
            "Staking not allowed for this pair."
        );
        require(
            _amount <= stakingPairMap[_pairId].maxStakeAmount,
            "Amount must be less than max stake amount"
        );
        uint256 totalStake = pairTotStaked[_pairId];
        totalStake = totalStake + _amount;
        //require(userTotStaked[_pairId][msg.sender] > 0, "You have already staked for this pair");
        require(totalStake <= pairMaxPoolSize[_pairId], "Staking pool is full");

        bool isErcToken = keccak256(
            abi.encodePacked(stakingPairMap[_pairId].stakedType)
        ) == keccak256(abi.encodePacked("ercToken"));
        erc20Contract = IERC20Metadata(stakingPairMap[_pairId].stakedAddr);
        if (isErcToken) {
            // erc20Contract.safeTransfer(address(this), _amount);
            // erc20Contract.approve(msg.sender, _amount);
            erc20Contract.transferFrom(
                msg.sender,
                address(this),
                _amount.mul(10**erc20Contract.decimals())
            );
            // require(ERC20(stakingPairMap[_pairId].stakedAddr).transferFrom(msg.sender,address(this),_amount));
        } else {
            nftCollection = IERC721(stakingPairMap[_pairId].stakedAddr);
            _amount = 1;
            nftCollection.safeTransferFrom(msg.sender, address(this), tokenId);
        }

        if (StakeMap[_pairId][msg.sender].amount == 0) {
            StakeMap[_pairId][msg.sender].amount = _amount;
            if (!isErcToken) {
                StakeMap[_pairId][msg.sender].tokenIds.push(tokenId);
            }
            pairActiveUsers[_pairId].push(msg.sender);
        } else {
            claimUser(_pairId, msg.sender);
            StakeMap[_pairId][msg.sender].amount = StakeMap[_pairId][msg.sender]
                .amount
                .add(_amount);
            if (!isErcToken) {
                StakeMap[_pairId][msg.sender].tokenIds.push(tokenId);
            }
        }

        StakeMap[_pairId][msg.sender].stakeDate = block.timestamp;
        StakeMap[_pairId][msg.sender].claimDate = block.timestamp;

        pairTotStaked[_pairId] = pairTotStaked[_pairId].add(_amount);
        userTotStaked[_pairId][msg.sender] = userTotStaked[_pairId][msg.sender]
            .add(_amount);
        return true;
    }

    event claimed(uint256 amount);

    function claim(string memory _pairId) public returns (uint256) {
        require(
            stakingPairStatusMap[_pairId],
            "Claim not allowed for this pair."
        );
        require(StakeMap[_pairId][msg.sender].amount > 0, "No stake.");
        require(
            isStakedForInterval(_pairId, msg.sender),
            "Nothing to claim. Wait for stake time."
        );
        require(
            isClaimedForInterval(_pairId, msg.sender),
            "Nothing to claim. Wait for interval time."
        );

        return claimUser(_pairId, msg.sender);
    }

    function claimUser(string memory _pairId, address _userAddress)
        private
        returns (uint256)
    {
        if (!stakingPairStatusMap[_pairId]) {
            return 0;
        }
        if (StakeMap[_pairId][_userAddress].amount == 0) {
            return 0;
        }
        uint256 actualInterval = getUserClaimInterval(_pairId, _userAddress); // taxDays * 1 days;
        // require(isClaimedForInterval(_pairId,_userAddress),"Nothing to claim.");

        bool isErcToken = keccak256(
            abi.encodePacked(stakingPairMap[_pairId].rewardType)
        ) == keccak256(abi.encodePacked("ercToken"));

        uint256 rewardIntervalInSecs = getIntervalInSecs(
            stakingPairMap[_pairId].rewardInterval,
            stakingPairMap[_pairId].intervalUnit
        );
        uint256 stakedAmountUser = StakeMap[_pairId][_userAddress].amount;
        uint256 rewardAmountUser = 0;
        if (stakingPairMap[_pairId].isOneTimeReward) {
            rewardAmountUser = (
                stakedAmountUser.mul(stakingPairMap[_pairId].rewardAmount)
            ).div(stakingPairMap[_pairId].stakeAmount);
            if (userTotRewards[_pairId][_userAddress] >= rewardAmountUser) {
                return 0;
            }
        } else {
            rewardAmountUser = (
                stakedAmountUser.mul(stakingPairMap[_pairId].rewardAmount).mul(
                    actualInterval
                )
            ).div(
                    stakingPairMap[_pairId].stakeAmount.mul(
                        rewardIntervalInSecs
                    )
                );
        }

        if (isErcToken) {
            erc20Contract = IERC20Metadata(stakingPairMap[_pairId].rewardAddr); //rewardAddr

            erc20Contract.transfer(
                _userAddress,
                rewardAmountUser.mul(10**erc20Contract.decimals())
            );
            // require(ERC20(stakingPairMap[_pairId].stakedAddr).transfer(_userAddress,rewardAmountUser));
        } else {
            uint256 _tokenId = 0;
            address _nftType = stakingPairMap[_pairId].rewardAddr;
            nftCollection = IERC721(stakingPairMap[_pairId].rewardAddr);
            //if (rewardAmountUser > nftTypeTokens[_nftType].length){return 0;}
            require(
                rewardAmountUser <= nftTypeTokens[_nftType].length,
                "Nft Reward Amount greater than available-tokens."
            );
            for (uint256 s = 0; s < rewardAmountUser; s += 1) {
                _tokenId = nftTypeTokens[_nftType][
                    nftTypeTokens[_nftType].length - 1
                ];
                nftCollection.safeTransferFrom(
                    address(this),
                    _userAddress,
                    _tokenId
                );
                nftTypeTokenExists[_nftType][_tokenId] = false;
                nftTypeTokens[_nftType].pop();
            }
        }
        StakeMap[_pairId][_userAddress].claimDate = block.timestamp;
        pairTotRewards[_pairId] = pairTotRewards[_pairId].add(rewardAmountUser);
        userTotRewards[_pairId][_userAddress] = userTotRewards[_pairId][
            _userAddress
        ].add(rewardAmountUser);

        emit claimed(rewardAmountUser);
        return rewardAmountUser;
    }

    function getIntervalInSecs(uint256 interval, string memory intervalUnit)
        private
        pure
        returns (uint256 intervalInSecs)
    {
        // uint256 intervalInSecs=0;
        if (
            keccak256(abi.encodePacked(intervalUnit)) ==
            keccak256(abi.encodePacked("days"))
        ) {
            intervalInSecs = interval * 1 days;
        } else if (
            keccak256(abi.encodePacked(intervalUnit)) ==
            keccak256(abi.encodePacked("hours"))
        ) {
            intervalInSecs = interval * 1 hours;
        }
        return intervalInSecs;
    }

    function getUserRewards(string memory _pairId, address _userAddress)
        public
        view
        returns (uint256)
    {
        // address _userAddress=msg.sender;
        if (!stakingPairStatusMap[_pairId]) {
            return 0;
        }
        if (StakeMap[_pairId][_userAddress].amount <= 0) {
            return 0;
        }

        if (stakingPairMap[_pairId].isOneTimeReward) {
            if (userTotStaked[_pairId][_userAddress] > 0) {
                return
                    (
                        userTotStaked[_pairId][_userAddress].div(
                            stakingPairMap[_pairId].stakeAmount
                        )
                    ).mul(stakingPairMap[_pairId].rewardAmount);
            }
            return 0;
        }

        uint256 rewardIntervalInSecs = getIntervalInSecs(
            stakingPairMap[_pairId].rewardInterval,
            stakingPairMap[_pairId].intervalUnit
        );

        uint256 actualInterval = getUserClaimInterval(_pairId, _userAddress); // taxDays * 1 days;
        if (actualInterval < rewardIntervalInSecs) {
            return 0;
        }

        uint256 stakedAmountUser = StakeMap[_pairId][_userAddress].amount;
        uint256 rewardAmountUser = (
            stakedAmountUser.mul(stakingPairMap[_pairId].rewardAmount).mul(
                actualInterval
            )
        ).div(stakingPairMap[_pairId].stakeAmount.mul(rewardIntervalInSecs));
        return rewardAmountUser;
    }

    function getUserClaimInterval(string memory _pairId, address userAddr)
        public
        view
        returns (uint256)
    {
        if (!stakingPairStatusMap[_pairId]) {
            return 0;
        }
        if (StakeMap[_pairId][userAddr].amount <= 0) {
            return 0;
        }
        uint256 interval = 0;
        if (
            keccak256(abi.encodePacked(stakingPairMap[_pairId].intervalUnit)) ==
            keccak256(abi.encodePacked("days"))
        ) {
            interval = (block.timestamp -
                StakeMap[_pairId][userAddr].claimDate); // * 1 days;
        } else if (
            keccak256(abi.encodePacked(stakingPairMap[_pairId].intervalUnit)) ==
            keccak256(abi.encodePacked("hours"))
        ) {
            interval = (block.timestamp -
                StakeMap[_pairId][userAddr].claimDate); // * 1 hours;
        }
        return interval;
    }

    function isClaimedForInterval(string memory _pairId, address userAddr)
        public
        view
        returns (bool)
    {
        bool _isClaimedForInterval = false;

        if (!stakingPairStatusMap[_pairId]) {
            return false;
        }
        if (StakeMap[_pairId][userAddr].amount <= 0) {
            return false;
        }
        uint256 interval = 0;
        if (
            keccak256(abi.encodePacked(stakingPairMap[_pairId].intervalUnit)) ==
            keccak256(abi.encodePacked("days"))
        ) {
            interval = (block.timestamp -
                StakeMap[_pairId][userAddr].claimDate); // * 1 days;
            if (interval >= stakingPairMap[_pairId].rewardInterval * 1 days) {
                _isClaimedForInterval = true;
            }
        } else if (
            keccak256(abi.encodePacked(stakingPairMap[_pairId].intervalUnit)) ==
            keccak256(abi.encodePacked("hours"))
        ) {
            interval = (block.timestamp -
                StakeMap[_pairId][userAddr].claimDate); // * 1 hours;
            if (interval >= stakingPairMap[_pairId].rewardInterval * 1 hours) {
                _isClaimedForInterval = true;
            }
        }
        return _isClaimedForInterval;
    }

    function getUserStakedInterval(string memory _pairId, address userAddr)
        public
        view
        returns (uint256)
    {
        if (!stakingPairStatusMap[_pairId]) {
            return 0;
        }
        if (StakeMap[_pairId][userAddr].amount <= 0) {
            return 0;
        }
        uint256 interval = 0;
        if (
            keccak256(abi.encodePacked(stakingPairMap[_pairId].intervalUnit)) ==
            keccak256(abi.encodePacked("days"))
        ) {
            interval = (block.timestamp -
                StakeMap[_pairId][userAddr].stakeDate); // * 1 days;
        } else if (
            keccak256(abi.encodePacked(stakingPairMap[_pairId].intervalUnit)) ==
            keccak256(abi.encodePacked("hours"))
        ) {
            interval = (block.timestamp -
                StakeMap[_pairId][userAddr].stakeDate); // * 1 hours;
        }
        return interval;
    }

    function isStakedForInterval(string memory _pairId, address userAddr)
        public
        view
        returns (bool)
    {
        bool _isStakedForInterval = false;
        if (!stakingPairStatusMap[_pairId]) {
            return false;
        }
        if (StakeMap[_pairId][userAddr].amount <= 0) {
            return false;
        }
        uint256 interval = 0;
        if (
            keccak256(abi.encodePacked(stakingPairMap[_pairId].intervalUnit)) ==
            keccak256(abi.encodePacked("days"))
        ) {
            interval = (block.timestamp -
                StakeMap[_pairId][userAddr].stakeDate); //* 1 days;
            if (interval >= stakingPairMap[_pairId].minStakingTime * 1 days) {
                _isStakedForInterval = true;
            }
        } else if (
            keccak256(abi.encodePacked(stakingPairMap[_pairId].intervalUnit)) ==
            keccak256(abi.encodePacked("hours"))
        ) {
            interval = (block.timestamp -
                StakeMap[_pairId][userAddr].stakeDate); // * 1 hours;
            if (interval >= stakingPairMap[_pairId].minStakingTime * 1 hours) {
                _isStakedForInterval = true;
            }
        }
        return _isStakedForInterval;
    }

    function unstakeAll(string memory _pairId)
        external
        returns (uint256, uint256)
    {
        require(StakeMap[_pairId][msg.sender].amount > 0, "Stake is 0.");
        require(stakingPairStatusMap[_pairId], "Staking pair not active");
        return
            unstake(StakeMap[_pairId][msg.sender].amount, _pairId, msg.sender);
    }

    function unstakeAllUser(string memory _pairId, address _userAddress)
        private
        returns (uint256, uint256)
    {
        //require(StakeMap[_pairId][_userAddress].amount > 0,"Stake is 0.");
        return
            unstake(
                StakeMap[_pairId][_userAddress].amount,
                _pairId,
                _userAddress
            );
    }

    function unstakeAmount(uint256 _amount, string memory _pairId)
        external
        returns (uint256, uint256)
    {
        require(_amount > 0, "Amount cannot be 0");
        require(
            _amount <= StakeMap[_pairId][msg.sender].amount,
            "Amount greater than staked"
        );
        require(stakingPairStatusMap[_pairId], "Staking pair not active");
        return unstake(_amount, _pairId, msg.sender);
    }

    function unstake(
        uint256 _amount,
        string memory _pairId,
        address _userAddress
    ) private returns (uint256, uint256) {
        require(
            isStakedForInterval(_pairId, msg.sender),
            "Wait for stake time to complete."
        );
        bool isErcToken = keccak256(
            abi.encodePacked(stakingPairMap[_pairId].stakedType)
        ) == keccak256(abi.encodePacked("ercToken"));
        if (!isErcToken)
            require(
                _amount <= StakeMap[_pairId][_userAddress].tokenIds.length,
                "Amount greater than staked-tokens."
            );
        if (!isStakedForInterval(_pairId, _userAddress)) {
            return (0, 0);
        }
        // uint stakedInterval =getUserStakedInterval(_pairId,_userAddress);// taxDays * 1 days;

        uint256 userRewards = claimUser(_pairId, msg.sender);

        if (isErcToken) {
            require(
                erc20Contract.balanceOf(address(this)) >=
                    _amount.mul(10**erc20Contract.decimals()),
                "Not enough contract balance for unstake"
            );
            erc20Contract = IERC20Metadata(stakingPairMap[_pairId].stakedAddr);
            require(
                erc20Contract.transfer(
                    _userAddress,
                    _amount.mul(10**erc20Contract.decimals())
                ),
                "Unstake failed for user."
            );
            // require(ERC20(stakingPairMap[_pairId].stakedAddr).transfer(_userAddress,_amount));
        } else {
            nftCollection = IERC721(stakingPairMap[_pairId].stakedAddr);
            uint256 _tokenId = 0;
            for (uint256 s = 0; s < _amount; s += 1) {
                _tokenId = StakeMap[_pairId][_userAddress].tokenIds[
                    StakeMap[_pairId][_userAddress].tokenIds.length - 1
                ];
                nftCollection.safeTransferFrom(
                    address(this),
                    _userAddress,
                    _tokenId
                );
                StakeMap[_pairId][_userAddress].tokenIds.pop();
            }
        }

        StakeMap[_pairId][_userAddress].amount = StakeMap[_pairId][_userAddress]
            .amount
            .sub(_amount);
        StakeMap[_pairId][_userAddress].claimDate = block.timestamp;
        pairTotStaked[_pairId] = pairTotStaked[_pairId].sub(_amount);
        userTotStaked[_pairId][_userAddress] = userTotStaked[_pairId][
            _userAddress
        ].sub(_amount);
        if (StakeMap[_pairId][_userAddress].amount <= 0) {
            removeStakeholder(_pairId, _userAddress);
        }
        return (_amount, userRewards);
    }

    function isStakeholder(string memory _pairId, address _address)
        public
        view
        returns (uint256)
    {
        for (uint256 s = 0; s < pairActiveUsers[_pairId].length; s += 1) {
            if (_address == pairActiveUsers[_pairId][s]) return (s + 1);
        }
        return (0);
    }

    function removeStakeholder(string memory _pairId, address _stakeholder)
        public
    {
        uint256 s = isStakeholder(_pairId, _stakeholder);
        if (s > 0) {
            pairActiveUsers[_pairId][s - 1] = pairActiveUsers[_pairId][
                pairActiveUsers[_pairId].length - 1
            ];
            pairActiveUsers[_pairId].pop();
        }
    }

    function transferAnyBEP20(
        address _tokenAddress,
        address _to,
        uint256 _amount
    ) external onlyOwner {
        IERC20Metadata(_tokenAddress).transfer(_to, _amount);
    }

    function transferStuckBNB(address _to, uint256 _amount) external onlyOwner {
        payable(_to).transfer(_amount);
    }

    function transferStuckNFT(
        address _tokenAddress,
        address _to,
        uint256 _tokenId
    ) external onlyOwner {
        IERC721(_tokenAddress).safeTransferFrom(address(this), _to, _tokenId);
    }

    function getUserStakeMap(address _user, string memory _pairId)
        external
        view
        returns (stakingInfo memory)
    {
        return StakeMap[_pairId][_user];
    }

    function getPairPoolSize(string memory _pairId)
        external
        view
        returns (uint256, uint256)
    {
        return (pairTotStaked[_pairId], pairMaxPoolSize[_pairId]);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

contract UnlockAI is Ownable {
    using SafeMath for uint256;

    bool public unlockActive = false;
    uint256 public UNLOCK_FEE = 2 ether;
    address public currency = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // BUSD contract address

    address public token; // ERC20 Token for unlocking
    uint256 public TOKEN_FEE = 100 ether;

    address public communityWallet = 0xc4F6748d633A1C0Ef74cA9DBFBF2ecF2b9474308;
    address public artistWallet = 0x1de57cB58048dFAeE8D61A5634D13Bac120Ce34a;
    address public devWallet = 0xC51283E6A879744b272BaeCdAe1036799352Dfe9;

    // Address of NFT collections that will be staked
    address[] public collections = [0x26eFFc1aDE68e0aFaf9be7b234544aa442b345b1];
    uint256[] public collectionConsumptionRate = [5];

    // Addresses that can manipulate credits
    address[] public ADMIN_ADDRESS = [0xC51283E6A879744b272BaeCdAe1036799352Dfe9];

    mapping(address => uint256) public credits; // wallet address credits
    mapping(address => mapping(uint256 => bool)) ticketUsed; // collection => token ID => consumed
    mapping(uint256 => bool) public aiUnlocked; // Token ID => unlocked
    event Unlock(uint256[] tokenIds);

    function unlockAI(uint256[] calldata _tokenIds, uint256 _amount) external {
        // Unlocking must be active
        require(unlockActive, "Unlocking not active!");

        // Must send correct payment
        require(_amount == UNLOCK_FEE.mul(_tokenIds.length), "Sent payment is incorrect!");

        // Must have enough tokens in wallet
        require(IERC20(currency).balanceOf(address(msg.sender)) >= UNLOCK_FEE.mul(_tokenIds.length), "Insufficient funds in wallet.");

        // Transfer payments
        IERC20(currency).transferFrom(address(msg.sender), communityWallet, _amount / 2);
        IERC20(currency).transferFrom(address(msg.sender), artistWallet, _amount / 4);
        IERC20(currency).transferFrom(address(msg.sender), devWallet, _amount / 4);

        // Unlock AI
        _unlock(_tokenIds);
    }

    // Function that allows contract owner to unlock any token ID.
    function adminUnlock(uint256[] calldata _tokenIds) external onlyOwner {
        for (uint256 i = 0; i < _tokenIds.length; i++) aiUnlocked[_tokenIds[i]] = true;
        emit Unlock(_tokenIds);
    }

    function consumeTicketsToUnlock(
        address _collection,
        uint256[] calldata _ticketTokenIds, // Token IDs that will be used as a ticket
        uint256[] calldata _unlockTokenIds // Token IDs that will be unlocked
    ) external {
        require(unlockActive, "Unlocking not active!");
        uint256 _collectionIndex = getCollectionIndex(_collection); // Also requires that collection is valid
        require(
            _ticketTokenIds.length == _unlockTokenIds.length.mul(collectionConsumptionRate[_collectionIndex]),
            "Incorrect number of NFTs used for unlock!"
        );

        // Consume all tickets
        for (uint256 i = 0; i < _ticketTokenIds.length; i++) {
            require(
                IERC721Enumerable(collections[_collectionIndex]).ownerOf(_ticketTokenIds[i]) == address(msg.sender),
                "Sender not the owner of ticket token ID!"
            );
            require(!ticketUsed[collections[_collectionIndex]][_ticketTokenIds[i]], "Ticket of a token ID already consumed!");

            // Consume ticket
            ticketUsed[collections[_collectionIndex]][_ticketTokenIds[i]] = true;
        }

        // Unlock AI
        _unlock(_unlockTokenIds);
    }

    function consumeCreditsToUnlock(uint256[] calldata _tokenIds) external {
        require(unlockActive, "Unlocking not active!");
        require(credits[address(msg.sender)] >= _tokenIds.length, "Not enough credits");

        credits[address(msg.sender)] = credits[address(msg.sender)].sub(_tokenIds.length);
    }

    function _unlock(uint256[] calldata _unlockTokenIds) private {
        for (uint256 i = 0; i < _unlockTokenIds.length; i++) {
            require(!aiUnlocked[_unlockTokenIds[i]], "One of the token IDs is already unlocked!");
            require(_unlockTokenIds[i] >= 1 && _unlockTokenIds[i] <= 11111, "One of the token IDs is not part of the collection!");
            aiUnlocked[_unlockTokenIds[i]] = true;
        }
        emit Unlock(_unlockTokenIds);
    }

    function addCredits(address[] calldata _addr, uint256[] calldata _credits) external {
        require(isAdmin(address(msg.sender)), "Sender does not have admin rights!");

        for (uint256 i = 0; i < _credits.length; i++) credits[_addr[i]] = credits[_addr[i]].add(_credits[i]);
    }

    function consumeTokensToUnlock(uint256[] calldata _tokenIds) external {
        require(unlockActive, "Unlocking not active!");

        // Must have enough tokens in wallet
        uint256 _amount = TOKEN_FEE.mul(_tokenIds.length);
        require(IERC20(token).balanceOf(address(msg.sender)) >= _amount, "Insufficient tokens in wallet.");

        // Burn tokens
        IERC20(token).transferFrom(address(msg.sender), address(0x000000000000000000000000000000000000dEaD), _amount);

        _unlock(_tokenIds);
    }

    function setCredits(address[] calldata _addr, uint256[] calldata _credits) external {
        require(isAdmin(address(msg.sender)), "Sender does not have admin rights!");
        for (uint256 i = 0; i < _credits.length; i++) credits[_addr[i]] = _credits[i];
    }

    // Add admin ability to manipulate rewards balance
    function setAdmin(address _addr, uint256 _index) external onlyOwner {
        ADMIN_ADDRESS[_index] = _addr;
    }

    // Give a new address admin rights to edit wallet balances
    function addAdmin(address _addr) external onlyOwner {
        ADMIN_ADDRESS.push(_addr);
    }

    // Remove admin access for address
    function removeAdmin(address _addr) external onlyOwner {
        for (uint256 i = 0; i < ADMIN_ADDRESS.length; i++) {
            if (ADMIN_ADDRESS[i] == _addr) {
                ADMIN_ADDRESS[i] = ADMIN_ADDRESS[ADMIN_ADDRESS.length - 1];
                ADMIN_ADDRESS.pop();
            }
        }
    }

    // Returns true if the address _addr has admin rights to edit credit balance.
    function isAdmin(address _addr) public view returns (bool) {
        for (uint256 i = 0; i < ADMIN_ADDRESS.length; i++) if (ADMIN_ADDRESS[i] == _addr) return true;
        return false;
    }

    // Adds a new collection to collections array
    function addNewCollection(address _addr, uint256 _rate) external onlyOwner {
        require(_rate > 0, "Rate cannot be 0!");
        require(!isValidCollection(_addr), "Collection already exists!");

        collections.push(_addr);
        collectionConsumptionRate.push(_rate);
    }

    // Change collection address of _index in collections array.
    function setCollectionAddr(address _addr, uint256 _collectionIndex) external onlyOwner {
        require(!isValidCollection(_addr), "Collection already exists!");
        collections[_collectionIndex] = _addr;
    }

    // Change collection rate
    function setCollectionRate(uint256 _collectionIndex, uint256 _rate) external onlyOwner {
        require(_rate > 0, "Rate cannot be 0!");
        collectionConsumptionRate[_collectionIndex] = _rate;
    }

    // Remove collection located at _index in collections array
    function removeCollection(address _address) external onlyOwner {
        uint256 _collectionIndex = getCollectionIndex(_address);

        collections[_collectionIndex] = collections[collections.length - 1];
        collections.pop();

        collectionConsumptionRate[_collectionIndex] = collectionConsumptionRate[collectionConsumptionRate.length - 1];
        collectionConsumptionRate.pop();
    }

    // Activate/deactivate unlocking
    function setUnlockActive(bool _val) external onlyOwner {
        unlockActive = _val;
    }

    // Set price for unlock
    function setUnlockFee(uint256 _fee) external onlyOwner {
        UNLOCK_FEE = _fee;
    }

    // Function to set currency
    function setCurrency(address _addr) external onlyOwner {
        currency = _addr;
    }

    // Allows owner to change the amount of tokens that need to be consumed to unlock
    function setTokenFee(uint256 _fee) external onlyOwner {
        TOKEN_FEE = _fee;
    }

    // Allows owner to change the token used for unlocking
    function setToken(address _addr) external onlyOwner {
        token = _addr;
    }

    // Set dev wallet that will receive 25% of payments
    function setDevWallet(address _addr) external onlyOwner {
        devWallet = _addr;
    }

    // Set artist wallet that will receive 25% of payments
    function setArtistWallet(address _addr) external onlyOwner {
        artistWallet = _addr;
    }

    // Set community wallet that will receive 50% of payments
    function setCommunityWallet(address _addr) external onlyOwner {
        communityWallet = _addr;
    }

    // Returns a bool array on the unlocked status of the respective token IDs in _tokenIds
    function getUnlockedStatus(uint256[] calldata _tokenIds) public view returns (bool[] memory) {
        bool[] memory _queriedIDs = new bool[](_tokenIds.length);
        for (uint256 i = 0; i < _tokenIds.length; i++) _queriedIDs[i] = aiUnlocked[_tokenIds[i]];
        return _queriedIDs;
    }

    // returns an array with the addresses of all collections that can be used as unlock tickets
    function getCollections() public view returns (address[] memory) {
        return collections;
    }

    // Returns an array with how many NFTs each collection needs per unlock
    function getCollectionRates() public view returns (uint256[] memory) {
        return collectionConsumptionRate;
    }

    // Returns true if _addr is found in collections array and false if it is not found.
    function isValidCollection(address _addr) public view returns (bool) {
        for (uint256 i = 0; i < collections.length; i++) if (_addr == collections[i]) return true;
        return false;
    }

    // Returns index of collection if _addr is found in collections array.
    // Also acts as an "isValidCollection" requirement
    function getCollectionIndex(address _addr) public view returns (uint256) {
        // Requiring the collection to be valid ensures that an index for collection _addr exists.
        require(isValidCollection(_addr), "Invalid collection.");
        for (uint256 i = 0; i < collections.length; i++) if (_addr == collections[i]) return i;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

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
    function getApproved(uint256 tokenId) external view returns (address operator);

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
    function isApprovedForAll(address owner, address operator) external view returns (bool);

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
}

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
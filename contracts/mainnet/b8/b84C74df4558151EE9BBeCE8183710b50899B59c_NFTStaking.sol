// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

contract NFTStaking is Ownable, ERC721Holder {
    using SafeMath for uint256;

    // Address of NFT collections that will be staked
    address[] public collections = [0x32DA706FEE5C476b5bdaE086894a894b43Dc21F7];

    // Emission rate for each collection
    uint256[] public collectionEmissionMultiplier = [100];

    // Rank multiplier. Will aways be used as VALUE * (rankMultiplier + 1).
    // => if rankMultiplier[0] == 0, then VALUE * (1)
    // Collection => tokenId => multiplier
    mapping(address => mapping(uint256 => uint256)) public rankMultiplier;

    // This mapping contains the info of every token ID for every collection.
    // Collection => tokenID => {timestamp, owner, collection}
    mapping(address => mapping(uint256 => Stake)) public vault;

    // This mapping contains all tokenIDs that a wallet has staked in this contract
    // Collection => wallet address => token IDs
    mapping(address => mapping(address => uint256[])) public ownerTokenIds;

    // This mapping tracks wallet rewards
    // Wallet => Rewards amount in wei
    mapping(address => uint256) public walletRewards;

    address[] public ADMIN_ADDRESS = [0x8b72170DdcdE38C3001a88f713245a561bA883F3];

    uint256 public divider = 60480000;

    struct Stake {
        uint48 timestamp;
        address owner;
        // address collection;
    }

    struct Collection {
        address addr;
        uint48 emissionRate;
    }

    constructor() {}

    // Function for staking NFTs in the contract.
    function stake(address _collection, uint256[] calldata _tokenId) external {
        // Require correct collection
        require(isValidCollection(_collection), "Invalid collection.");

        for (uint256 i = 0; i < _tokenId.length; i++) {
            require(IERC721Enumerable(_collection).ownerOf(_tokenId[i]) == address(msg.sender), "Sender does not own this token.");

            IERC721Enumerable(_collection).safeTransferFrom(address(msg.sender), address(this), _tokenId[i]);

            // Keep track of time & owner of each token
            vault[_collection][_tokenId[i]] = Stake({
                owner: address(msg.sender),
                // collection: _collection,
                timestamp: uint48(block.timestamp)
            });

            // A way to get all token ids for an owner
            ownerTokenIds[_collection][address(msg.sender)].push(_tokenId[i]);
        }
    }

    // Returns an array of all the token IDs staked by _addr for a _collection
    function getStakedByWallet(address _collection, address _addr) public view returns (uint256[] memory) {
        return ownerTokenIds[_collection][_addr];
    }

    // Returns true if _addr is found in collections array and false if it is not found.
    function isValidCollection(address _addr) public view returns (bool) {
        for (uint256 i = 0; i < collections.length; i++) if (_addr == collections[i]) return true;
        return false;
    }

    // Returns index of collection if _addr is found in collections array.
    function getCollectionIndex(address _addr) public view returns (uint256) {
        // Requiring the collection to be valid ensures that an index for collection _addr exists.
        require(isValidCollection(_addr), "Invalid collection.");
        for (uint256 i = 0; i < collections.length; i++) if (_addr == collections[i]) return i;
    }

    // Adds a new collection to collections array
    function addNewCollection(address _addr, uint256 _emission) external onlyOwner {
        collections.push(_addr);
        collectionEmissionMultiplier.push(_emission);
    }

    // Change collection address of _index in collections array.
    function setCollectionAddr(address _addr, uint256 _index) external onlyOwner {
        collections[_index] = _addr;
    }

    // Change collection emission
    function setCollectionEmission(uint256 _emission, uint256 _index) external onlyOwner {
        collectionEmissionMultiplier[_index] = _emission;
    }

    // Remove collection located at _index in collections array
    function removeCollection(uint256 _index) external onlyOwner {
        delete collections[_index];
        delete collectionEmissionMultiplier[_index];
    }

    // Function for calculating rewards
    function calculateRewardsByTokenId(uint256 _collectionIndex, uint256 _tokenId) public view returns (uint256) {
        uint256 startTime = uint256(vault[collections[_collectionIndex]][_tokenId].timestamp);
        uint256 timeDiff = 1 ether * (uint256(block.timestamp) - startTime);

        /**
         * 604800 seconds in one week.
         * 1 token staked for 1 week = 1 credit.
         * collectionEmissionMultiplier acts as a multiplier for the colletion. 1 is neutral.
         * rankMultiplier acts as a multiplier for individual token ids.
         * This will always be added by 1, so minimum value will always be the base collectionEmissionMultiplier.
         */
        return
            collectionEmissionMultiplier[_collectionIndex].mul(timeDiff.div(divider)).mul(
                (rankMultiplier[collections[_collectionIndex]][_tokenId].add(1))
            );
        // return collectionEmissionMultiplier[_collectionIndex].mul(timeDiff);
    }

    // Function that calculates and returns
    function calculateRewardsByWallet(address _addr) public view returns (uint256) {
        uint256 _rewards = 0;

        // Loop through all collections
        for (uint256 i = 0; i < collections.length; i++) {
            // Add rewards from each collection
            for (uint256 j = 0; j < ownerTokenIds[collections[i]][_addr].length; j++) {
                _rewards = _rewards.add(calculateRewardsByTokenId(i, ownerTokenIds[collections[i]][_addr][j]));
            }
        }
        return _rewards;
    }

    function resetTimestamp(address _collection, uint256 _tokenId) private {
        vault[_collection][_tokenId].timestamp = uint48(block.timestamp);
    }

    // Function for claiming rewards
    function claimAllRewards() public {
        // Get rewards for sender wallet
        uint256 _rewards = calculateRewardsByWallet(address(msg.sender));

        // Loop through all collections and reset tokenId timestamp

        // Start by looping through all collections
        for (uint256 i = 0; i < collections.length; i++) {
            // Get tokenIds for wallet in each collection
            uint256[] memory _ids = ownerTokenIds[collections[i]][address(msg.sender)];

            // Loop through those ids and reset timestamp for each id
            for (uint256 j = 0; j < _ids.length; j++) resetTimestamp(collections[i], _ids[j]);
        }

        // Save credit to user wallet
        walletRewards[address(msg.sender)] = walletRewards[address(msg.sender)].add(_rewards);
    }

    function claimRewardByTokenId(uint256 _collectionIndex, uint256 _tokenId) private {
        uint256 _reward = calculateRewardsByTokenId(_collectionIndex, _tokenId);
        resetTimestamp(collections[_collectionIndex], _tokenId);

        // Add reward to wallet
        walletRewards[address(msg.sender)] = walletRewards[address(msg.sender)].add(_reward);
    }

    // Function for unstaking (Should also claim rewards)
    function unstake(address _collection, uint256[] calldata _tokenId) public {
        for (uint256 i = 0; i < _tokenId.length; i++) {
            // Require that sender is the correct owner.
            require(vault[_collection][_tokenId[i]].owner == address(msg.sender), "Sender does not own this token.");

            // Transfer from contract to sender wallet
            IERC721Enumerable(_collection).safeTransferFrom(address(this), address(msg.sender), _tokenId[i]);

            // Add reward to wallet if _collection is valid
            if (isValidCollection(_collection)) {
                uint256 _collectionIndex = getCollectionIndex(_collection);
                uint256 _reward = calculateRewardsByTokenId(_collectionIndex, _tokenId[i]);
                walletRewards[address(msg.sender)] = walletRewards[address(msg.sender)].add(_reward);
            }

            // Remove token tracking from vault
            delete vault[_collection][_tokenId[i]];

            /**
             * Remove token tracking from ownerTokenIds by replacing
             * the one that needs to be removed with the last element in the array.
             * Once this is done, pop out the last element.
             */

            // Loop through the sender's tracked tokenIDs
            for (uint256 j = 0; j < ownerTokenIds[_collection][address(msg.sender)].length; j++) {
                // Correct tokenID found
                if (ownerTokenIds[_collection][address(msg.sender)][j] == _tokenId[i]) {
                    ownerTokenIds[_collection][address(msg.sender)][j] = ownerTokenIds[_collection][address(msg.sender)][
                        ownerTokenIds[_collection][address(msg.sender)].length - 1
                    ];
                    ownerTokenIds[_collection][address(msg.sender)].pop();
                }
            }
        }
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

    // Removes _credits from a wallet's credit balance in walletRewards
    function consumeCredits(address _wallet, uint256 _credits) external {
        require(isAdmin(address(msg.sender)), "Sender does not have admin rights!");
        require(walletRewards[_wallet] >= _credits, "Wallet does not have enough credits!");

        walletRewards[_wallet] = walletRewards[_wallet].sub(_credits);
    }

    // Adds _credits to a wallet's credit balance in walletRewards
    function addCredits(address _wallet, uint256 _credits) external {
        require(isAdmin(address(msg.sender)), "Sender does not have admin rights!");
        walletRewards[_wallet] = walletRewards[_wallet].add(_credits);
    }

    // Sets a walelt's balance in walletRewards to _credits.
    function setCredits(address _wallet, uint256 _credits) external {
        require(isAdmin(address(msg.sender)), "Sender does not have admin rights!");
        walletRewards[_wallet] = _credits;
    }

    // Returns true if the address _addr has admin rights to edit credit balance.
    function isAdmin(address _addr) public view returns (bool) {
        for (uint256 i = 0; i < ADMIN_ADDRESS.length; i++) if (ADMIN_ADDRESS[i] == _addr) return true;
        return false;
    }

    function setRankMultiplier(address _collection, uint256[] calldata _tokenIds, uint256[] calldata _multipliers) external onlyOwner {
        // require(isValidCollection(_collection), "Invalid collection.");
        for (uint256 i = 0; i < _tokenIds.length; i++) rankMultiplier[_collection][_tokenIds[i]] = _multipliers[i];
    }

    function getRankMultipliers(address _collection, uint256[] calldata _tokenIds) public view returns (uint256[] memory) {
        uint256[] memory _multipliers = _tokenIds;
        for (uint256 i = 0; i < _tokenIds.length; i++) _multipliers[i] = rankMultiplier[_collection][_tokenIds[i]];
        return _multipliers;
    }

    function setDivider(uint256 _val) external onlyOwner {
        divider = _val;
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

import "../IERC721Receiver.sol";

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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

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
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

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

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
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
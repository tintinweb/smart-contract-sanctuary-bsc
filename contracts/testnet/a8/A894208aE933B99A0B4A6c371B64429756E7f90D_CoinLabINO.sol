// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title CoinLab INO 
 * @author KhoaGit
 * @notice Contract for buy nft from projects on launchpad
 * @dev This contract includes 2 main actors:
 1. WhitelistedUser who can:
    1.1 depositBUSDToBuyNFT()
    1.2 claimNFT()
 2. Owner who can:
    2.1 setWhitelistAddress()
    2.2 unSetWhitelistedAddress()
    2.3 addProject()
    2.4 updateProjectPrice()
    2.5 pause/unPauseContract()
 */
contract CoinLabINO is Pausable, Ownable {
    using Counters for Counters.Counter;

    /// The number of projects are pushed to contract
    Counters.Counter public _projectIds;

    /// BUSD token address
    IERC20 public BUSD;

    /// CoinLab's wallet address
    address public CoinLab;

    // Mapping user address to true/false
    mapping(address => bool) private _whitelistedUser;

    // Mapping project's nft ID to Claimer address
    mapping(uint256 => mapping(uint256 => address)) private _nftClaimer;

    // Structure of Project type
    struct Project {
        // The address of nft project
        address nftAddress;
        // Common price of all nft in each project
        uint256 price;
    }

    // The array contains all projects information
    Project[] private _allProjects;

    /**
     * @dev Emitted when `user` buy `nftId` of `nftAddress` successfully.
     */
    event NFTBought(address user, uint256 nftAddress, uint256 nftId);

    /**
     * @dev Emitted when `nftId` token is claimed by `claimer`.
     */
    event NFTClaimed(address claimer, uint256 nftId);

    /**
     * @dev Emitted when contract's owner adds new porject with `nftAddress` and `price` to `_allProjects` successfully.
     */
    event ProjectAdded(uint256 projectId, address nftAddress, uint256 price);

    /**
     * @dev Emitted when contract's owner updates `newPrice` of a specific `projectId` successfully.
     */
    event ProjectPriceUpdated(uint256 projectId, uint256 newPrice);

    /**
     * @dev Emitted when new `addressToWhitelist` is set to true.
     */
    event WhitelistedAddress(address addressToWhitelist);

    /**
     * @dev Emitted when a WhitelistedAddress is set to false.
     */
    event UnSetWhitelistedAddress(address addressToUnSet);

    /**
     * @dev Initializes the contract by setting a `busd` and a `coinlab` address and push first sample project to _allProjects array.
     * @param busd is the address of busd token on bsc 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56.
     * @param coinlab is the coinlab wallet addrress.
     */
    constructor(address busd, address coinlab) {
        BUSD = IERC20(busd);
        CoinLab = coinlab;
        _allProjects.push(Project(address(0x0), 1000000000000000000000000));
    }

    /**
     * @dev Whitelisted user deposits BUSD to buy NFT.
     *
     * @notice User have to approve this {INO-contract} transfer BUSD from his wallet to another wallet, like coinlab's wallet.
     *
     * @param projectId is the index of project infor in `_allProject` array.
     * @param nftId is the token ID will be claimed by {msg.sender} after this call is successful.
     *
     * Requirements:
     *
     * - Whitelisted user must call {appove} function in BUSD contract to appove this contract use BUSD in user's wallet first. 
     Then we can call {transferFrom} function to transfer BUSD to coinlab's wallet.
     * - `nftId` token must exist.
     * - The `_nftClaimer` of `nftId` should equal to 0x0, because it determines that `nftId` is available.
     * - The msg.sender must be a Whitelisted User
     *
     * Emits a {NFTBought} event.
     */
    function depositBUSDToBuyNFT(uint256 projectId, uint256 nftId)
        external
        whenNotPaused
        onlyWhitelistedUsers
    {
        require(_nftClaimer[projectId][nftId] == address(0x0));

        uint256 price;
        (, price) = getProject(projectId);
        BUSD.transferFrom(_msgSender(), CoinLab, price);

        _nftClaimer[projectId][nftId] = _msgSender();

        emit NFTBought(_msgSender(), projectId, nftId);
    }

    /**
     * @dev `_nftClaimer` claims nft after deposit BUSD successfully.
     *
     * @notice User can claim nft after call {depositBUSDToBuyNFT} fucntion successfully.
     *
     * @param projectId is the index of project infor in `_allProject` array.
     * @param nftId is the token ID will be claimed by `msg.sender`.
     *
     * Requirements:
     *
     * - `nftId` token must exist.
     * - The `_nftClaimer` must equal to {msg.sender}.
     * - Coinlab've already approved this {INO-contract} to move NFT from its wallet to `_nftClaimer`.
     If not, CoinLab have to call {setApprovalForAll} or {approve} function on NFT contract address to allow this {INO-contract} move nft from CoinLab's wallet to `_nftClaimer`.
     *
     * Emits a {NFTClaimed} event.
     */
    function claimNFT(uint256 projectId, uint256 nftId)
        external
        whenNotPaused
        onlyWhitelistedUsers
    {
        require(_msgSender() == _nftClaimer[projectId][nftId]);

        IERC721 NFT = IERC721(_allProjects[projectId].nftAddress);
        NFT.safeTransferFrom(CoinLab, _msgSender(), nftId);

        emit NFTClaimed(_nftClaimer[projectId][nftId], nftId);
    }

    /**
     * @dev Contract's owner set a address to whitelisted address.
     *
     * @param addressToWhitelist is a new address will be mapped to true.
     *
     * Emits a {WhitelistedAddress} event.
     */
    function setWhitelistAddress(address addressToWhitelist)
        external
        onlyOwner
    {
        _whitelistedUser[addressToWhitelist] = true;

        emit WhitelistedAddress(addressToWhitelist);
    }

    /**
     * @dev Contract's owner deletes an address from whitelisted address.
     *
     * @param addressToUnset is an address will be mapped to false.
     *
     * Emits a {UnSetWhitelistedAddress} event.
     */
    function unSetWhitelistedAddress(address addressToUnset)
        external
        onlyOwner
    {
        _whitelistedUser[addressToUnset] = false;

        emit UnSetWhitelistedAddress(addressToUnset);
    }

    /**
     * @dev Contract's owner adds new project's information to `allProjects` array. The `_projectIds` will increase before new project is added to.
     *
     * @param nftAddress is an address of new NFT project.
     * @param price is common price of all ntfs in this project.
     *
     * Emits a {ProjectAdded} event.
     */
    function addProject(address nftAddress, uint256 price) external onlyOwner {
        _projectIds.increment();

        _allProjects.push(Project(nftAddress, price));

        emit ProjectAdded(_projectIds.current(), nftAddress, price);
    }

    /**
     * @dev Contract's owner updates new price in a specific project.
     *
     * @param projectId is project ID.
     * @param newPrice is new common price of all ntfs in this project.
     *
     * Emits a {ProjectPriceUpdated} event.
     */
    function updateProjectPrice(uint256 projectId, uint256 newPrice)
        external
        onlyOwner
    {
        _allProjects[projectId].price = newPrice;
        emit ProjectPriceUpdated(projectId, newPrice);
    }

    /**
     * @dev Returns if the `user` is allowed to call 2 function {depositBUSDToBuyNFT} and {claimNFT}.
     */
    function isWhitelistedUser(address user) public view returns (bool) {
        return _whitelistedUser[user];
    }

    /**
     * @dev Throws if called by any account other than the whitelisted users.
     */
    modifier onlyWhitelistedUsers() {
        require(isWhitelistedUser(_msgSender()));
        _;
    }

    /**
     * @dev Returns nftAddress and price of `projectId`.
     */
    function getProject(uint256 projectId)
        public
        view
        returns (address, uint256)
    {
        return (
            _allProjects[projectId].nftAddress,
            _allProjects[projectId].price
        );
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function pauseContract() external onlyOwner {
        _pause();
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function unPauseContract() external onlyOwner {
        _unpause();
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
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
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
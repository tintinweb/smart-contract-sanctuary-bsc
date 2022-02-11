pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

import "@openzeppelin/contracts/security/Pausable.sol";

abstract contract IERC721 {
    function transferFrom(address from, address to, uint _tokenId) external virtual;
    function ownerOf(uint tokenId) external view virtual returns(address);
    function mint(address _to, uint256 _tokenId, string memory _hashs) virtual external;
    function burn(uint256 tokenId) external virtual;
    function currentTokenId() virtual external view returns(uint256);
    function tokenHash(uint256 tokenId) virtual external view returns(string memory);
}

contract MefiNFTImportExport is ERC721Holder, Ownable, ReentrancyGuard, Pausable {
    address public signer;

    mapping(address => mapping(uint256 => address)) private _importDetails;
    mapping(address => bool) public supportNFTs;

    struct NewNFTFromGame {
        address userAddress;
        uint tokenId;
    }

    mapping(address => mapping(uint => NewNFTFromGame)) public exportNewNftRequest;

    constructor(address _signer, address[] memory _cs)
    {
        signer = _signer;

        uint length = _cs.length;

        for(uint i = 0; i < length; i++) {
            supportNFTs[_cs[i]] = true;
        }
    }

    function setSigner(address _signer) external onlyOwner
    {
        signer = _signer;
    }
	
	function getMessageHash(address _user, address _collection, uint _tokenId, string memory _hash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_user, _collection, _tokenId, _hash));
    }

    function getEthSignedMessageHash(bytes32 _messageHash) private pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }

    function permit(address _user, address _collection, uint _tokenId, string memory _hash, uint8 v, bytes32 r, bytes32 s) private view returns (bool) {
        return ecrecover(getEthSignedMessageHash(getMessageHash(_user, _collection, _tokenId, _hash)), v, r, s) == signer;
    }

    function addSupportNFT(address _nft) external onlyOwner
    {
        supportNFTs[_nft] = true;
    }

    function removeSupportNFT(address _nft) external onlyOwner
    {
        supportNFTs[_nft] = false;
    }

    function createImportRequest(address _nft, uint256 _tokenId)
    external nonReentrant whenNotPaused
    {
        // Verify collection is accepted
        require(supportNFTs[_nft], "Collection: Not support");

        IERC721(_nft).transferFrom(_msgSender(), address(this), _tokenId);
        _importDetails[_nft][_tokenId] = _msgSender();
    }

    function checkImportedToken(address _nft, uint256 _tokenId) external view
    returns (bool, address)
    {
        //require(_tokenId > 0 && _tokenId <= IERC721(_nft).currentTokenId(), "Invalid token id");
        bool transfered = IERC721(_nft).ownerOf(_tokenId) == address(this);
        return (transfered, _importDetails[_nft][_tokenId]);
    }

    function exportNFT(address _nft, uint256 _tokenId, string memory _hash, uint8 v, bytes32 r, bytes32 s) external nonReentrant whenNotPaused
    {
        require(supportNFTs[_nft], "Collection: Not support");
        require(_msgSender() == _importDetails[_nft][_tokenId], 'Export: token not belong to sender');
        require(permit(_msgSender(), _nft, _tokenId, _hash, v, r, s), 'Export: wrong signature');
		
		delete _importDetails[_nft][_tokenId];
		
		if(keccak256(bytes(IERC721(_nft).tokenHash(_tokenId))) != keccak256(bytes(_hash)))
		{
			IERC721(_nft).burn(_tokenId);
			IERC721(_nft).mint(_msgSender(), _tokenId, _hash);
		}
		else
		{
			IERC721(_nft).transferFrom(address(this), _msgSender(), _tokenId);
		}
    }

    function mintNewNFTFromGame(uint _requestId ,address _nft, string memory _hash, uint8 v, bytes32 r, bytes32 s) external nonReentrant whenNotPaused
    {
        require(supportNFTs[_nft], "Collection: Not support");
        require(exportNewNftRequest[_nft][_requestId].userAddress == address(0), "Duplicated request id");
        require(permit(_msgSender(), _nft, _requestId, _hash, v, r, s), 'Export new NFT: wrong signature');

        uint tokenId = IERC721(_nft).currentTokenId() + 1;
        IERC721(_nft).mint(_msgSender(), tokenId, _hash);
        exportNewNftRequest[_nft][_requestId] = NewNFTFromGame({userAddress: _msgSender(), tokenId: tokenId});
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
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
/**
 *Submitted for verification at BscScan.com on 2022-06-07
*/

/**
      ___           ___           ___           ___           ___           ___     
     /\  \         /\  \         /\  \         /\  \         /\  \         /\  \    
    /::\  \       /::\  \       /::\  \       /::\  \        \:\  \       /::\  \   
   /:/\ \  \     /:/\:\  \     /:/\:\  \     /:/\:\  \        \:\  \     /:/\:\  \  
  _\:\~\ \  \   /::\~\:\  \   /:/  \:\  \   /::\~\:\  \       /::\  \   /::\~\:\  \ 
 /\ \:\ \ \__\ /:/\:\ \:\__\ /:/__/ \:\__\ /:/\:\ \:\__\     /:/\:\__\ /:/\:\ \:\__\
 \:\ \:\ \/__/ \/__\:\/:/  / \:\  \ /:/  / \/_|::\/:/  /    /:/  \/__/ \:\~\:\ \/__/
  \:\ \:\__\        \::/  /   \:\  /:/  /     |:|::/  /    /:/  /       \:\ \:\__\  
   \:\/:/  /         \/__/     \:\/:/  /      |:|\/__/     \/__/         \:\ \/__/  
    \::/  /                     \::/  /       |:|  |                      \:\__\    
     \/__/                       \/__/         \|__|                       \/__/    
**/
// File: contracts/whitelist/ino_race_public/ISportEShoesNFT.sol



pragma solidity 0.8.8;

interface ISportEShoesNFT {
    /// PARTICIPATING
    function mint(address to, uint256 tokenId) external;        
}
// File: contracts/whitelist/ino_race_public/IBEP20.sol



pragma solidity 0.8.8;

interface IBep20Token {
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}
// File: contracts/lib/utils/introspection/IERC165.sol



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

// File: contracts/lib/token/ERC721/IERC721.sol



pragma solidity ^0.8.0;


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
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

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
    function transferFrom(address from, address to, uint256 tokenId) external;

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
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

// File: contracts/lib/utils/Context.sol



pragma solidity ^0.8.0;

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: contracts/lib/security/Pausable.sol



pragma solidity ^0.8.0;


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
    constructor () {
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

// File: contracts/lib/access/Ownable.sol



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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/whitelist/ino_race_public/ShoeINOPublic.sol



pragma solidity 0.8.8;






contract ShoeINOPublic is Ownable, Pausable {
    event JoinINOPublic(address indexed owner, uint256 amount, uint256 value);

    ISportEShoesNFT public nftContract;

    uint256 constant NFT_INDEX_START_DEFAULT = 555333319;
    
    uint256 private nftIndexStart;

    uint256 public nMaxJoined = 5500;
    uint256 public nTotalJoined;
    mapping(address => bool) private _authorizedAddresses;

    uint256 private _currentNftIndex;

    mapping(uint256 => uint256) private _nftIndexes;
    uint256 private _currentNftIndexInput;

    uint256 public boxPrice;

    modifier onlyAuthorizedAccount() {
		require(_authorizedAddresses[msg.sender] || owner() == msg.sender);
		_;
	}

    modifier isNotContract(address user) {
        require(_checkIsNotCallFromContract());
		require(_isNotContract(user));
		_;
	}

	constructor(address nftContract_, uint256 boxPrice_) {
        nftContract = ISportEShoesNFT(nftContract_);
        boxPrice = boxPrice_;

        updateNftRewardIndexes(NFT_INDEX_START_DEFAULT);
    }


    /// PARTICIPATING

    function mint(uint256 amount_) external isNotContract(_msgSender()) whenNotPaused payable {
        /* CHECK */
        require (amount_ >= 1 && amount_ <= 5, "Whitelist::invalid NFT amount");
        require (msg.value == boxPrice * amount_, "Whitelist::transfer BNB failed");
        require(nTotalJoined + amount_ <= nMaxJoined, "Whitelist::sold out");

        /* EFFECT */
        nTotalJoined = nTotalJoined + amount_;

        /* INTERACTION */
        for (uint256 i = 0; i < amount_; i++) {
            nftContract.mint(msg.sender, nftIndexStart + _nftIndexes[_currentNftIndex]);
            _currentNftIndex += 1;
        }

        emit JoinINOPublic(msg.sender, amount_, msg.value);
    }    

    /// SALE CONFIG

    function updateBoxPrice(uint256 boxPrice_) public onlyAuthorizedAccount {
        boxPrice = boxPrice_;
    }

    function updateMaxJoined(uint256 nMaxJoined_) public onlyAuthorizedAccount {
        nMaxJoined = nMaxJoined_;
    }

    function updateNftRewardIndexes(uint256 startIndex_) public onlyAuthorizedAccount {
        nftIndexStart = startIndex_;
    }

    function updateNFTIndexes(uint256 [] calldata index_) external onlyAuthorizedAccount {
        require(_currentNftIndexInput + index_.length <= nMaxJoined, "Whitelist::out of MAX_JOINED");
        for (uint i; i < index_.length; i++) {
            _nftIndexes[_currentNftIndexInput] = index_[i];
            _currentNftIndexInput += 1;
        }
	}

    /// ADMINISTATION

    function grantPermission(address account) external onlyOwner {
		require(account != address(0));
		_authorizedAddresses[account] = true;
	}

	function revokePermission(address account) external onlyOwner {
		require(account != address(0));
		_authorizedAddresses[account] = false;
	}

    function pause() external onlyAuthorizedAccount {
        _pause();
    }

    function unpause() external onlyAuthorizedAccount {
        _unpause();
    }

    function withdrawBalance() external onlyAuthorizedAccount {
        payable(msg.sender).transfer(address(this).balance);
    }

    /// CONDITIONAL CHECKS
    
    function _isNotContract(address _addr) internal view returns (bool){
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size == 0);
    }

    function _checkIsNotCallFromContract() internal view returns (bool){
	    if (msg.sender == tx.origin){
		    return true;
	    } else{
	        return false;
	    }
	}
}
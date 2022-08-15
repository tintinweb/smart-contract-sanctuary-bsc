// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./interfaces/IBigexSignature.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import {IERC1155} from '@openzeppelin/contracts/token/ERC1155/IERC1155.sol';
import {IERC721} from '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "./BigexUserWallet.sol";

contract BigexWalletContract is Ownable, Pausable {
	event CreateWallet(address username, address owner, address wallet, uint256 timestamp);
	event Withdraw(address username, uint256 amount, address pool, address token, uint256 timestamp, string message);
	event Withdraw721(address username, address pool, address token, uint256 timestamp, string message);
	event Withdraw1155(address username, address pool, address token, uint256 _id, uint256 _amount, uint256 timestamp, string message);

	address public pool;
	address public bigexToken;
	address public bigexVerifySignature;
	address public bigexOperatorVerifySignature;

	mapping(address => address) public userWallet;
	mapping(bytes32 => address) public listWallet;
	mapping(bytes => bool) listSignature;
	mapping(address => bool) nftSupport;

	address[] public listWalletCreated;

	constructor (address _pool, address _bigexToken, address _bigexVerifySignature) {
		pool = _pool;
		bigexToken = _bigexToken;
		bigexVerifySignature = _bigexVerifySignature;
		bigexOperatorVerifySignature = owner();
	}

	function pause() public onlyOwner {
		_pause();
	}

	function unpause() public onlyOwner {
		_unpause();
	}

	function setNFTSupport(address[] memory _nfts, bool _result) public onlyOwner {
		for (uint256 i = 0; i < _nfts.length; i++) {
			nftSupport[_nfts[i]] = _result;
		}
	}

	function setUserWallet(address _user, address _wallet) public onlyOwner {
		userWallet[_user] = _wallet;
	}

	function setPool(address _pool) public onlyOwner {
		pool = _pool;
	}

	function setBigexToken(address _bigexToken) public onlyOwner {
		bigexToken = _bigexToken;
	}

	function setBigexOperatorVerifySignature(address _bigexOperatorVerifySignature) public onlyOwner {
		bigexOperatorVerifySignature = _bigexOperatorVerifySignature;
	}

	function setBigexVerifySignature(address _bigexVerifySignature) public onlyOwner {
		bigexVerifySignature = _bigexVerifySignature;
	}

	function getListWalletCreatedLength() public view returns (uint256) {
		return listWalletCreated.length;
	}

	/**
	Check wallet created by master
	*/
	function isWallet(bytes32 _id, address _wallet) public view returns (bool) {
		return listWallet[_id] == _wallet;
	}

	/**
	Create wallet user
	*/
	function createWallet() public {
		require(userWallet[msg.sender] == address(0), "Wallet: the user already exists a wallet on the system");

		userWallet[msg.sender] = address(new BigexUserWallet(pool, owner(), msg.sender, address(this), bigexToken));
		emit CreateWallet(msg.sender, msg.sender, userWallet[msg.sender], block.timestamp);
		listWalletCreated.push(userWallet[msg.sender]);
		listWallet[
		keccak256(
			abi.encode(
				keccak256("BIGEX_WALLET"),
				keccak256(abi.encode(msg.sender)),
				userWallet[msg.sender]
			)
		)
		] = userWallet[msg.sender];
	}

	/**
	Withdraw token
	*/
	function withdrawToken(address _to, uint256 _amount, string memory _message, uint256 _expiredTime, bytes memory _signature) public whenNotPaused {
		uint256 balancePool = IERC20(bigexToken).balanceOf(pool);
		require(!listSignature[_signature], "Wallet: Signature already exists");
		require(balancePool >= _amount, "Wallet: Pool not enough balance");
		require(block.timestamp <= _expiredTime, "Wallet: Signature expires");
		require(IBigexSignature(bigexVerifySignature).isWithdrawERC20Valid(bigexOperatorVerifySignature, _to, _amount, _message, _expiredTime, _signature), "Wallet: signature verification failed");
		IERC20(bigexToken).transferFrom(pool, _to, _amount);
		listSignature[_signature] = true;
		emit Withdraw(msg.sender, _amount, pool, bigexToken, block.timestamp, _message);
	}

	function listToken721Available(address _nft) public view returns (uint256[] memory) {
		uint256[] memory tokenIds = new uint256[](IERC721(_nft).balanceOf(pool));
		for (uint256 i = 0; i < IERC721(_nft).balanceOf(pool); i++) {
			tokenIds[i] = IERC721Enumerable(_nft).tokenOfOwnerByIndex(pool, i);
		}
		return tokenIds;
	}

	/**
	Withdraw NFT 721
	*/
	function withdrawToken721(uint256 _tokenId, address _nft,
		string memory _message,
		uint256 _expiredTime,
		bytes memory _signature
	) public whenNotPaused {
		require(nftSupport[_nft], "Wallet: nft not support");
		require(!listSignature[_signature], "Wallet: Signature already exists");
		require(block.timestamp <= _expiredTime, "Wallet: Signature expires");
		require(IBigexSignature(bigexVerifySignature).isWithdrawERC721Valid(bigexOperatorVerifySignature, msg.sender, _tokenId, _message, _expiredTime, _signature), "Wallet: signature verification failed");
		IERC721(_nft).safeTransferFrom(
			pool,
			msg.sender,
			_tokenId,
			"0x00"
		);
		emit Withdraw721(msg.sender, pool, _nft, block.timestamp, _message);
		listSignature[_signature] = true;
	}

	/**
	Withdraw NFT 1155
	*/
	function withdrawToken1155(uint256 _tokenId, address _nft, uint256 _amount,
		string memory _message,
		uint256 _expiredTime,
		bytes memory _signature
	) public whenNotPaused {
		require(nftSupport[_nft], "Wallet: nft not support");
		require(!listSignature[_signature], "Wallet: Signature already exists");
		require(block.timestamp <= _expiredTime, "Wallet: Signature expires");
		require(IERC1155(_nft).balanceOf(pool, _tokenId) >= _amount, "Wallet: pool not enough NFT");

		IERC1155(_nft).safeTransferFrom(
			pool,
			msg.sender,
			_tokenId,
			_amount,
			"0x00"
		);
		listSignature[_signature] = true;
		emit Withdraw1155(msg.sender, pool, _nft, _tokenId, _amount, block.timestamp, _message);
	}

	/**
	Withdraw unknown token
	*/
	function clearUnknownToken(address _tokenAddress) public onlyOwner {
		uint256 contractBalance = IERC20(_tokenAddress).balanceOf(address(this));
		IERC20(_tokenAddress).transfer(address(msg.sender), contractBalance);
	}
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IBigexSignature {
	function isWithdrawERC20Valid(address _operator, address _to, uint256 _amount, string memory _message, uint256 _expiredTime, bytes memory signature) external pure returns (bool);

	function isWithdrawERC721Valid(address _operator, address _to, uint256 _id, string memory _message, uint256 _expiredTime, bytes memory signature) external pure returns (bool);

	function isSellERC721Valid(address _operator, address _from, uint256 _id, string memory _message, uint256 _expiredTime, bytes memory signature) external pure returns (bool);

	function isWithdrawERC1155Valid(address _operator, address _to, uint256 _id, uint256 _amount, string memory _message, uint256 _expiredTime, bytes memory signature) external pure returns (bool);

	function isSellERC1155Valid(address _operator, address from, uint256 _id, uint256 _amount, string memory _message, uint256 _expiredTime, bytes memory signature) external pure returns (bool);
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
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

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
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
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
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IBigexWalletContract.sol";

contract BigexUserWallet is Ownable {
	address public pool;
	address public BIGEX_TOKEN;
	address public BIGEX_WALLET;
	address public USERNAME;

	event Deposit(address username, uint256 amount, address pool, address token, uint256 timestamp);

	constructor (address _pool, address _owner, address _username, address _bigexWallet, address _bigexToken) {
		pool = _pool;
		USERNAME = _username;
		transferOwnership(_owner);
		BIGEX_TOKEN = _bigexToken;
		BIGEX_WALLET = _bigexWallet;
	}

	function setUsername(address _username) public onlyOwner {
		USERNAME = _username;
	}

	function setBigexToken(address _bigexToken) public onlyOwner {
		BIGEX_TOKEN = _bigexToken;
	}

	function setBigexWallet(address _bigexWallet) public onlyOwner {
		BIGEX_WALLET = _bigexWallet;
	}

	function setPool(address _pool) public onlyOwner () {
		pool = _pool;
	}

	/**
	Deposit token Bigex
	*/
	function depositTokenBigex(uint256 _amountDeposit) public {
		uint256 balanceWallet = IERC20(BIGEX_TOKEN).balanceOf(msg.sender);
		// check balance
		require(balanceWallet >= _amountDeposit, "Wallet: Your balance not enough to deposit");

		// check allowance token
		require(
			IERC20(BIGEX_TOKEN).allowance(msg.sender, address(this)) >= _amountDeposit,
			"Wallet: allowance not enough to deposit"
		);

		IERC20(BIGEX_TOKEN).transferFrom(msg.sender, pool, _amountDeposit);
		emit Deposit(USERNAME, _amountDeposit, pool, BIGEX_TOKEN, block.timestamp);
	}

	/**
	Check wallet create by master contract
	*/
	function isWallet() public view returns (bool) {
		return IBigexWalletContract(BIGEX_WALLET).isWallet(
			keccak256(
				abi.encode(
					keccak256("BIGEX_WALLET"),
					keccak256(abi.encode(USERNAME)),
					address(this)
				)
			),
			address(this)
		);
	}

	/**
	Withdraw unknown token
	*/
	function clearUnknownToken(address _tokenAddress) public onlyOwner {
		uint256 contractBalance = IERC20(_tokenAddress).balanceOf(address(this));
		IERC20(_tokenAddress).transfer(address(msg.sender), contractBalance);
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IBigexWalletContract {
	function isWallet(bytes32 _id, address _wallet) external view returns (bool);
}
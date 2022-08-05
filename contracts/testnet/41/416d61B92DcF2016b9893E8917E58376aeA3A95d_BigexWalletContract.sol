// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./interfaces/IBigexSignature.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./BigexUserWallet.sol";

contract BigexWalletContract is Ownable {
	event CreateWallet(address username, address owner, address wallet, uint256 timestamp);
	event Withdraw(address username, uint256 amount, address pool, address token, uint256 timestamp, string message);

	address public pool;
	address public bigexToken;
	address public bigexVerifySignature;
	address public bigexOperatorVerifySignature;

	mapping(address => address) public userWallet;
	mapping(bytes32 => address) public listWallet;
	mapping(bytes => bool) listSignature;

	address[] public listWalletCreated;

	constructor (address _pool, address _bigexToken, address _bigexVerifySignature) {
		pool = _pool;
		bigexToken = _bigexToken;
		bigexVerifySignature = _bigexVerifySignature;
		bigexOperatorVerifySignature = owner();
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
		require(userWallet[msg.sender] == address(0), "bigex: the user already exists a wallet on the system");

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
	function withdrawToken(address _to, uint256 _amount, string memory _message, uint256 _expiredTime, bytes memory _signature) public {
		uint256 balancePool = IERC20(bigexToken).balanceOf(pool);
		require(!listSignature[_signature], "Bigex: Signature already exists");
		require(balancePool >= _amount, "Bigex: Pool not enough balance");
		require(block.timestamp <= _expiredTime, "Bigex: Signature expires");
		require(IBigexSignature(bigexVerifySignature).isWithdrawERC20Valid(bigexOperatorVerifySignature, _to, _amount, _message, _expiredTime, _signature), "Bigex: signature verification failed");
		IERC20(bigexToken).transferFrom(pool, _to, _amount);
		listSignature[_signature] = true;
		emit Withdraw(msg.sender, _amount, pool, bigexToken, block.timestamp, _message);
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
		require(balanceWallet >= _amountDeposit, "Bigex: Your balance not enough to deposit");

		// check allowance token
		require(
			IERC20(BIGEX_TOKEN).allowance(msg.sender, address(this)) >= _amountDeposit,
			"Bigex: allowance not enough to deposit"
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IBigexWalletContract {
	function isWallet(bytes32 _id, address _wallet) external view returns (bool);
}
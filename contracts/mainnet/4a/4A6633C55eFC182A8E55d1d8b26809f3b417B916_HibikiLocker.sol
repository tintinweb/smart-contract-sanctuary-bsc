// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./Auth.sol";
import "./ERC721Enumerable.sol";
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
import { HibikiFeeManager } from "./HibikiFeeManager.sol";

/**
* @dev Contract to lock assets for a time and receive a token
*/
contract HibikiLocker is Auth, HibikiFeeManager, ERC721Enumerable {

	struct Lock {
		address token;
		uint256 amount;
		uint32 lockDate;
		uint32 unlockDate;
		// Stored in a single 256 bit slot along dates for UI only.
		// It is not likely to reach this number of locks anyway, even in decades.
		uint192 lockId;
	}

	mapping (uint256 => Lock) private _locks;
	uint256 private _mintIndex;
	mapping (address => uint256[]) private _tokenLocks;

	event Locked(uint256 indexed lockId, address indexed token, uint256 amount, uint32 unlockDate);
	event Unlocked(uint256 indexed lockId, uint256 amount);
	event Relocked(uint256 indexed lockId, uint32 newUnlockDate);

	error WrongTimestamp();
	error CannotManage();
	error LockActive();

	modifier futureDate(uint32 attemptedDate) {
		if (attemptedDate <= block.timestamp) {
			revert WrongTimestamp();
		}
		_;
	}

	modifier canManageLock(uint256 lockId) {
		if (ownerOf(lockId) != msg.sender) {
			revert CannotManage();
		}
		_;
	}

	constructor(address receiver, uint256 gasFee, address holdToken, uint256 holdAmount, string memory uriPart)
		Auth(msg.sender)
		HibikiFeeManager(receiver, gasFee, holdToken, holdAmount)
		ERC721("Hibiki.finance Lock", "LOCK")
	{
		_setBaseURI(string.concat("https://hibiki.finance/lock/", uriPart, "/"));
	}

	function setBaseURI(string calldata uri) external authorized {
		_setBaseURI(uri);
	}

	function setGasFee(uint256 fee) external authorized {
		_setGasFee(fee);
	}

	function setFeeReceiver(address receiver) external authorized {
		_setFeeReceiver(receiver);
	}

	function setHoldToken(address token) external authorized {
		_setHoldToken(token);
	}

	function setHoldAmount(uint256 amount) external authorized {
		_setHoldAmount(amount);
	}

	function setSendGas(uint256 gas) external authorized {
		_setSendGas(gas);
	}

	/**
	* @dev Lock an ERC20 asset.
	*/
	function lock(address token, uint256 amount, uint32 unlockDate) external payable futureDate(unlockDate) correctGas {
		uint256 lockId = _mintIndex++;
		_mint(msg.sender, lockId);
		_tokenLocks[token].push(lockId);

		// Some tokens are always taxed.
		// If the tax cannot be avoided, `transferFrom` will leave less tokens in the locker than stored.
		// Then, when unlocking, the transaction would either revert or take someone else's tokens, if any.
		IERC20 tokenToLock = IERC20(token);
		uint256 balanceBefore = tokenToLock.balanceOf(address(this));
		IERC20(token).transferFrom(msg.sender, address(this), amount);
		uint256 balanceAfter = tokenToLock.balanceOf(address(this));
		uint256 actuallyTransfered = balanceAfter - balanceBefore;
		_lock(lockId, token, actuallyTransfered, unlockDate);

		emit Locked(lockId, token, actuallyTransfered, unlockDate);
	}

	/**
	* @dev Extend an existing lock.
	*/
	function relock(uint256 lockId, uint32 newDate) external futureDate(newDate) canManageLock(lockId) {
		Lock storage l = _locks[lockId];
		if (newDate < l.unlockDate) {
			revert WrongTimestamp();
		}
		l.lockDate = uint32(block.timestamp);
		l.unlockDate = newDate;

		emit Relocked(lockId, newDate);
	}

	/**
	* @dev Writes lock status. Check in other functions for data sanity.
	*/
	function _lock(uint256 lockId, address token, uint256 amount, uint32 unlockDate) internal  {
		Lock storage l = _locks[lockId];
		l.token = token;
		l.amount = amount;
		l.unlockDate = unlockDate;
		l.lockDate = uint32(block.timestamp);
		l.lockId = uint192(lockId);
	}

	/**
	* @dev Unlock locked ERC20 tokens.
	*/
	function unlock(uint256 index) external canManageLock(index) {
		Lock storage l = _locks[index];
		if (block.timestamp < l.unlockDate) {
			revert LockActive();
		}
		uint256 lockedAmount = l.amount;
		_burn(index);
		l.amount = 0;
		IERC20(l.token).transfer(msg.sender, lockedAmount);
	}

	/**
	* @dev Returns the lock data at the index.
	*/
	function viewLock(uint256 index) external view returns (Lock memory) {
		return _locks[index];
	}

	/**
	* @dev Get an array of locks from the specified IDs in the indices array.
	*/
	function viewLocks(uint256[] calldata indices) external view returns (Lock[] memory) {
		return _viewLocks(indices);
	}

	function _viewLocks(uint256[] memory indices) private view returns (Lock[] memory) {
		Lock[] memory locks = new Lock[](indices.length);
		for (uint256 i = 0; i < indices.length; i++) {
			locks[i] = _locks[indices[i]];
		}

		return locks;
	}

	/**
	* @dev Returns the amount of locks existing for a token.
	*/
	function countLocks(address token) external view returns (uint256) {
		return _tokenLocks[token].length;
	}

	/**
	* @dev Returns all lock IDs for a specific token address.
	*/
	function getAllLocks(address token) external view returns (uint256[] memory) {
		return _tokenLocks[token];
	}

	/**
	* @dev Returns the lock ID for token at the specific index.
	*/
	function getLockIDForToken(address token, uint256 index) external view returns (uint256) {
		return _tokenLocks[token][index];
	}

	/**
	* @dev Returns the IDs of the locks owned by the address.
	*/
	function getLockIDsByAddress(address owner) external view returns (uint256[] memory) {
		return _getLockIDsByAddress(owner);
	}

	function _getLockIDsByAddress(address owner) private view returns (uint256[] memory) {
		uint256 locks = balanceOf(owner);
		uint256[] memory ids = new uint256[](locks);
		for (uint256 i = 0; i < locks; i++) {
			ids[i] = tokenOfOwnerByIndex(owner, i);
		}

		return ids;
	}

	function getLocksByAddress(address owner) external view returns (Lock[] memory) {
		uint256[] memory ids = _getLockIDsByAddress(owner);
		return _viewLocks(ids);
	}
}
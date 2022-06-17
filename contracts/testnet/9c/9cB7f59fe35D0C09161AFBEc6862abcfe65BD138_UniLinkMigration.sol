/**
 *Submitted for verification at BscScan.com on 2022-06-16
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.14;

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
contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }   
    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }
    
    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

interface IERC20 {

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
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

contract UniLinkMigration is Ownable {
	bool public migrationEnabled;

	uint256 public mantissaCoefficient;
	uint256 public mantissaShare;

	mapping(address => uint256) public migrationCoefficient;
	mapping(address => uint256) public migrationShare;
	mapping(address => address) public migrationDestination;

    constructor () {
    	mantissaCoefficient = 4;
    	mantissaShare = 4;
    }

    function getMigrationBalance(address _token, uint256 _balance) public view returns (uint256) {
        return (((_balance * migrationCoefficient[_token]) / 10**mantissaCoefficient) * migrationShare[_token]) / 10**mantissaShare;
    }

	function migrate(address _token) external {
		require(migrationEnabled || msg.sender == owner(), "Migration is not enabled.");

		require(migrationCoefficient[_token] > 0, "Token coefficient not set.");
		require(migrationShare[_token] > 0, "Token share not set.");
		require(migrationDestination[_token] != address(0), "Token destination not set.");

		uint256 _tokenBalance =  IERC20(_token).balanceOf(msg.sender);
		require(_tokenBalance > 0, "No balance to migrate.");

		require(IERC20(_token).transferFrom(msg.sender, address(this), _tokenBalance), "Could not transfer token balance to migration contract.");
		
		uint256 _migrationBalance = getMigrationBalance(_token, _tokenBalance);
		require(IERC20(migrationDestination[_token]).transferFrom(address(this), msg.sender, _migrationBalance), "Could not transfer migration balance to sender.");
	}

	function setMantissaCoefficient(uint256 _mantissaCoefficient) external onlyOwner {
		mantissaCoefficient = _mantissaCoefficient;
	}

	function setMantissaShare(uint256 _mantissaShare) external onlyOwner {
		mantissaShare = _mantissaShare;
	}

	function getMigrationCoefficient(address _token) public view returns (uint256) {
		return migrationCoefficient[_token];
	}

	function setMigrationCoefficient(address _token, uint256 _coefficient) external onlyOwner {
		migrationCoefficient[_token] = _coefficient;
	}

	function getMigrationShare(address _token) public view returns (uint256) {
		return migrationShare[_token];
	}

	function setMigrationShare(address _token, uint256 _share) external onlyOwner {
		migrationShare[_token] = _share;
	}

	function getMigrationDestination(address _token) public view returns (address) {
		return migrationDestination[_token];
	}

	function setMigrationDestination(address _token, address _destination) external onlyOwner {
		migrationDestination[_token] = _destination;
	}

	function getMigration(address _token) public view returns (uint256, uint256, address) {
		return (migrationCoefficient[_token], migrationShare[_token], migrationDestination[_token]);
	}

	function addMigration(address _token, uint256 _coefficient, uint256 _share, address _destination) external onlyOwner {
		migrationCoefficient[_token] = _coefficient;
		migrationShare[_token] = _share;
		migrationDestination[_token] = _destination;
	}

	function removeMigration(address _token) external onlyOwner {
		delete migrationCoefficient[_token];
		delete migrationShare[_token];
		delete migrationDestination[_token];
	}

	function setMigrationEnabled(bool _status) external onlyOwner {
		migrationEnabled = _status;
	}

	function rescueToken(address _token, address _to) external onlyOwner {
		IERC20(_token).transfer(_to, IERC20(_token).balanceOf(address(this)));
	}
}
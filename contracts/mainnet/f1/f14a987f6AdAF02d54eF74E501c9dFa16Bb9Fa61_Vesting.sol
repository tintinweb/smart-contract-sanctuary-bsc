/**
 *Submitted for verification at BscScan.com on 2022-08-26
*/

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


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: AniFi/Vesting.sol


pragma solidity 0.8.12;

contract Vesting is Ownable {
    address public immutable token;
    uint256 public vestingPeriod;
    uint256 public startClaim;
    uint256 public tgeRelease; // 100 = 1%

    mapping(address => uint256) public vestingAmount;
    mapping(address => uint256) public fullAmount;
    mapping(address => uint256) public lastWithdrawn;

    event OnChangeWallet(address _from, address _to, uint256 _vestingAmount);
    event OnClaim (address _addr, uint256 _amount, uint256 _time);
    event OnLock (address[] _addr, uint256[] _amount);

    constructor(address _token, uint256 _vestingPeriod, uint256 _startClaim, uint256 _tgeRelease){
        require(_startClaim > block.timestamp, "Invalid Claim Time");
        require(_token != address(0), "Wallet cannot be 0");
        token = _token;
        vestingPeriod = _vestingPeriod;
        startClaim = _startClaim;
        tgeRelease = _tgeRelease;
    }

    function changeWallet(
        address _to
    ) external {
        require(vestingAmount[_to] == 0, "Already have vesting token");
        require(_to != address(0), "To : Zero address");
        vestingAmount[_to] = vestingAmount[_msgSender()];
        vestingAmount[_msgSender()] = 0;
        fullAmount[_to] = fullAmount[_msgSender()];
        fullAmount[_msgSender()] = 0;
        lastWithdrawn[_to] = lastWithdrawn[_msgSender()];
        lastWithdrawn[_msgSender()] = 0;

        emit OnChangeWallet (_msgSender(), _to, vestingAmount[_to]);
    }

    function setVestingBatch(
        address[] memory _addr,
        uint256[] memory _amount
    ) external onlyOwner {
        uint256 totalLockingAmount;
        for (uint256 i=0; i < _amount.length; i++) {
            require(_amount[i] > 0, "Zero Amount");
            vestingAmount[_addr[i]] = _amount[i];
            fullAmount[_addr[i]] = _amount[i];
            totalLockingAmount += _amount[i];
        }
        require(IERC20(token).transferFrom(_msgSender(), address(this), totalLockingAmount), "Fail transfer");

        emit OnLock(_addr, _amount);
    }

    function claimVesting () external {
        require(block.timestamp >= startClaim, "Cannot claim yet");
        uint256 withdrawAmount = getWithdrawAmount();
        require(withdrawAmount > 0, "No token to release");
        vestingAmount[_msgSender()] -= withdrawAmount;
        lastWithdrawn[_msgSender()] = block.timestamp;
        require(IERC20(token).transfer(_msgSender(), withdrawAmount), "Fail transfer");

        emit OnClaim (_msgSender(), withdrawAmount, block.timestamp);
    }

    function getWithdrawAmount() public view returns (uint256) {
        uint256 releasingTGE = tgeRelease * fullAmount[_msgSender()] / 10000;
        uint256 afterTGE = fullAmount[_msgSender()] - releasingTGE;
        uint256 lastWithdraw;
        if (lastWithdrawn[_msgSender()] == 0) {
            lastWithdraw = startClaim;
        } else {
            lastWithdraw = lastWithdrawn[_msgSender()];
        }
        uint256 withdrawVesting = (block.timestamp - lastWithdraw) * afterTGE / vestingPeriod;
        uint256 withdrawAmount;
        if (fullAmount[_msgSender()] == vestingAmount[_msgSender()]) {
            withdrawAmount = releasingTGE + withdrawVesting;
        } else {
            withdrawAmount = withdrawVesting;
        }
        if (withdrawAmount > vestingAmount[_msgSender()]) {
            withdrawAmount = vestingAmount[_msgSender()];
        }
        return withdrawAmount;
    }
}
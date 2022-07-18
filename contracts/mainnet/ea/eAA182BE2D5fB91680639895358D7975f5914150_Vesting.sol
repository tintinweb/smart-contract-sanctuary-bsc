// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Vesting is Ownable {

    address public immutable token;
    uint256 public vestingPeriod;
    uint256 public startClaim;

    mapping(address => uint256) public tokenVesting;
    mapping(address => uint256) public fullTokenVesting;
    mapping(address => uint256) public lastWithdrawn;

    event OnUnlock (address _addr, uint256 _amount, uint256 _time);
    event OnLock (address[] _addr, uint256[] _amount);
    event OnWithdraw (address _token, uint256 _tokenAmount);

    constructor(address _token){
        token = _token;
        startClaim = 1658142000;
        vestingPeriod = 31 * 24 * 60 * 60;
    }

    function setStartClaim(
        uint256 _time
    ) external onlyOwner {
        startClaim = _time;
    }

    function setVestingPeriod(
        uint256 _time
    ) external onlyOwner {
        vestingPeriod = _time;
    }

    function changeWallet(
        address _from,
        address _to
    ) external onlyOwner {
        require(_from != address(0), "From : Zero address");
        require(_to != address(0), "To : Zero address");
        tokenVesting[_to] = tokenVesting[_from];
        tokenVesting[_from] = 0;
        fullTokenVesting[_to] = fullTokenVesting[_from];
        fullTokenVesting[_from] = 0;
        lastWithdrawn[_to] = lastWithdrawn[_from];
        lastWithdrawn[_from] = 0;
    }

    function setWalletBatch(
        address[] memory _addr,
        uint256[] memory _amount
    ) external onlyOwner {
        uint256 totalLockingAmount;
        for (uint256 i=0; i < _amount.length; i++) {
            tokenVesting[_addr[i]] = _amount[i];
            fullTokenVesting[_addr[i]] = _amount[i];
            totalLockingAmount += _amount[i];
        }
        //require(IERC20(token).transferFrom(_msgSender(), address(this), totalLockingAmount), "Fail transfer");

        emit OnLock(_addr, _amount);
    }

    function withdraw (
        address _token
    ) public onlyOwner {
        require(IERC20(_token).transfer(_msgSender(), IERC20(_token).balanceOf(address(this))), "Fail transfer");

        emit OnWithdraw (_token, IERC20(_token).balanceOf(address(this)));
    }

    function releaseVesting () external {
        require(block.timestamp > startClaim, "Not started yet");
        uint256 _lastWithdraw;
        if (lastWithdrawn[_msgSender()] == 0) {
            _lastWithdraw = startClaim;
        } else {
            _lastWithdraw = lastWithdrawn[_msgSender()];
        }
        uint256 withdrawAmount = (block.timestamp - _lastWithdraw) * fullTokenVesting[_msgSender()] / vestingPeriod;
        if (withdrawAmount > tokenVesting[_msgSender()]) {
            withdrawAmount = tokenVesting[_msgSender()];
        }
        require(withdrawAmount > 0, "No token enough");
        tokenVesting[_msgSender()] -= withdrawAmount;
        lastWithdrawn[_msgSender()] = block.timestamp;
        require(IERC20(token).transfer(_msgSender(), withdrawAmount), "Fail transfer");

        emit OnUnlock (_msgSender(), withdrawAmount, block.timestamp);
    }
}

// SPDX-License-Identifier: MIT

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
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

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
    function transferFrom(
        address sender,
        address recipient,
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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
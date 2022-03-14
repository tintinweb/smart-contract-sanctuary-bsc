// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MoonRaiseFairSale is Ownable {
    IERC20 public _mrtToken;
    IERC20 public _tokenSale;
    IERC20 public _paymentToken;

    uint256 public _openTime;
    uint256 public _closeTime;
    uint256 public _userCapInUsd = 50 ether;
    uint256 public _userCapInTokenSale = 2000 ether;
    uint256 public _amountMrtConditon = 100 ether;
    uint256 public _currentAllocation = 0 ether;
    uint256 public _totalAllocation = 400_000 ether;
    uint256 public _ZOOM = 10000;

    mapping(address => uint256) public _balances;

    struct Lock {
        uint256 unlockTime;
        uint256 allocationRate;
    }

    Lock[] public _scheduleUnlocks;
    mapping(address => bool[]) public _isClaimed;

    constructor(
        IERC20 mrtToken,
        IERC20 tokenSale,
        IERC20 paymentToken,
        uint256 openTime,
        uint256 closeTime
    ) public {
        _mrtToken = mrtToken;
        _tokenSale = tokenSale;
        _paymentToken = paymentToken;
        _openTime = openTime;
        _closeTime = closeTime;
        _scheduleUnlocks.push(Lock(block.timestamp, 5000));
        _scheduleUnlocks.push(Lock(block.timestamp, 2500));
        _scheduleUnlocks.push(Lock(block.timestamp, 2500));
    }

    function setTotalAllocation(uint256 amount) public onlyOwner {
        _totalAllocation = amount;
    }

    function setOpenTime(uint256 openTime) public onlyOwner {
        _openTime = openTime;
    }

    function setCloseTime(uint256 closeTime) public onlyOwner {
        _closeTime = closeTime;
    }

    function setTokenSale(IERC20 tokenSale) public onlyOwner {
        _tokenSale = tokenSale;
    }

    function setMrtToken(IERC20 mrtToken) public onlyOwner {
        _mrtToken = mrtToken;
    }

    function setPaymentToken(IERC20 paymentToken) public onlyOwner {
        _paymentToken = paymentToken;
    }

    function setuserCapInUsd(uint256 amount) public onlyOwner {
        _userCapInUsd = amount;
    }

    function setuserCapInToken(uint256 amount) public onlyOwner {
        _userCapInTokenSale = amount;
    }

    function setAmountMrtCondition(uint256 amount) public onlyOwner {
        _amountMrtConditon = amount;
    }

    function setLockSchedule(
        uint256 index,
        uint256 unlockTime,
        uint256 allocationRate
    ) public onlyOwner {
        _scheduleUnlocks[index].unlockTime = unlockTime;
        _scheduleUnlocks[index].allocationRate = allocationRate;
    }

    function getScheduleUnlock(uint256 cycle)
        public
        view
        returns (Lock memory)
    {
        return (_scheduleUnlocks[cycle]);
    }

    modifier onSaleTime() {
        require(
            (_openTime <= block.timestamp && block.timestamp <= _closeTime),
            "It's is not during open time"
        );
        _;
    }

    function withdrawAsset(IERC20 assetToken, uint256 amount) public onlyOwner {
        assetToken.transfer(msg.sender, amount);
    }

    function checkMrtCondition(address user) public view returns (bool) {
        return (_mrtToken.balanceOf(user) >= _amountMrtConditon);
    }

    function buy() public onSaleTime {
        require(
            checkMrtCondition(msg.sender),
            "condition hold MRT: not enough amount"
        );
        require(_balances[msg.sender] == 0, "you bought");
        require(
            _currentAllocation <= _totalAllocation,
            "total allocation is sold out"
        );
        for (uint256 i = 0; i < _scheduleUnlocks.length; i++) {
            _isClaimed[msg.sender].push(false);
        }
        _paymentToken.transferFrom(msg.sender, address(this), _userCapInUsd);
        _balances[msg.sender] = _userCapInTokenSale;
        _currentAllocation += _userCapInTokenSale;
    }

    function getVestingAmount(uint256 cycle) public view returns (uint256) {
        return
            (_userCapInTokenSale * _scheduleUnlocks[cycle].allocationRate) /
            _ZOOM;
    }

    function isVesting(address user, uint256 cycle) public view returns (bool) {
        return (_isClaimed[user][cycle]);
    }

    function vesting(uint256 cycle) public {
        require(
            _balances[msg.sender] == _userCapInTokenSale,
            "You are not a participant in this sale"
        );
        require(cycle < _scheduleUnlocks.length, "invalid cycle");

        require(
            block.timestamp >= _scheduleUnlocks[cycle].unlockTime,
            "It's not time to unlock yet"
        );
        require(_isClaimed[msg.sender][cycle] == false, "you claimed");
        uint256 amount = (_userCapInTokenSale *
            _scheduleUnlocks[cycle].allocationRate) / _ZOOM;
        _tokenSale.transfer(msg.sender, amount);
        _isClaimed[msg.sender][cycle] = true;
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

// SPDX-License-Identifier: MIT

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
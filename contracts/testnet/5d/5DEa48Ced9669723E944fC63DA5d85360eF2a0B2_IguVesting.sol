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
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract IguVesting is Ownable {
    error ArrayLengthsMismatch(uint256 length);
    error InsufficientBalanceOrAllowance(uint256 required);
    error VestingNotFound();
    error VestingNotStartedYet();
    error ActivationAmountCantBeGreaterThanFullAmount();
    error ClaimingDisabled();
    error NothingToClaim();

    event Withdrawn(address indexed to, uint256 indexed slot, uint256 amount);

    struct Vesting {
        /// @notice Total vesting amount (includes activation amount)
        uint256 vestingAmount;
        /// @notice Alread vested amount
        uint256 claimedAmount;
        /// @notice Activation amount - released fully after vesting start time
        uint256 activationAmount;
        /// @notice Vesting beginning time
        uint256 timestampStart;
        /// @notice Vesting ending time
        uint256 timestampEnd;
    }

    /// @notice IGU ERC20 token
    IERC20 internal _token;

    /// @notice List of vestings
    /// @dev address => index => Vesting
    mapping(address => mapping(uint256 => Vesting)) internal _vesting;

    /// @notice Number of vestings for each account
    mapping(address => uint256) internal _slotsOf;

    /// @notice Is Claiming Enabled
    bool public isEnabled;

    constructor(IERC20 _tokenContractAddress) {
        _token = _tokenContractAddress;
    }

    /**
     * @notice Enables claiming
     */
    function enable() external onlyOwner {
        isEnabled = true;
    }

    /**
     * @notice Number of vestings for each account
     * @param _address Account
     */
    function slotsOf(address _address) external view returns (uint256) {
        return _slotsOf[_address];
    }

    /**
     * @notice Returns vesting information
     * @param _address Account
     * @param _slot Slot index
     */
    function vestingInfo(
        address _address,
        uint256 _slot
    ) external view returns (Vesting memory) {
        return _vesting[_address][_slot];
    }

     /**
     * @notice Returns vesting information
     * @param _address Account
     */
    function batchVestingInfo(
        address _address,
        uint256 _slot
    ) external view returns (Vesting[] memory) {
        Vesting[] memory vestings = new Vesting[](_slotsOf[_address]);
        for(uint256 i=0; i<_slotsOf[_address]; i++){
            Vesting memory v = _vesting[_address][_slot];
            vestings[i] = v;
        }
        return vestings;
    }

    /**
     * @dev Internal function.
     * Calculates vested amount available to claim (at the moment of execution)
     */
    function _vestedAmount(
        Vesting memory vesting
    ) internal view returns (uint256) {
        if (vesting.vestingAmount == 0) {
            return 0;
        }

        if (block.timestamp < vesting.timestampStart) {
            return 0;
        }

        if (block.timestamp >= vesting.timestampEnd) {
            // in case of exceeding end time
            return vesting.vestingAmount - vesting.activationAmount;
        }

        uint256 vestingAmount = vesting.vestingAmount -
            vesting.activationAmount;
        uint256 vestingPeriod = vesting.timestampEnd - vesting.timestampStart;
        uint256 timeSinceVestingStart = block.timestamp -
            vesting.timestampStart;
        uint256 unlockedAmount = (vestingAmount * timeSinceVestingStart) /
            vestingPeriod;
        return unlockedAmount;
    }

    /**
     * @notice Returns amount available to claim
     * @param _address Owner account
     * @param _slot Vesting slot
     * @return amount available to withdraw
     */
    function available(
        address _address,
        uint256 _slot
    ) public view returns (uint256) {
        Vesting memory vesting = _vesting[_address][_slot];
        uint256 unlocked = vesting.activationAmount + _vestedAmount(vesting);
        return unlocked - vesting.claimedAmount;
    }

    /**
     * @notice Returns amount available to claim for all slots
     * @param _address Owner account
     * @return amount available to withdraw
     */
    function batchAvailable(address _address) public view returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < _slotsOf[_address]; i++) {
            Vesting memory vesting = _vesting[_address][i];
            uint256 unlocked = vesting.activationAmount +
                _vestedAmount(vesting);
            sum += unlocked - vesting.claimedAmount;
        }
        return sum;
    }

    /**
     * @notice Adds vesting informations.
     * In case of linear vesting of 200 tokens and intial unlock of 50 tokens
     *      _amounts[i] should contain 200
     *      _initialUnlock[i] should contain 50
     * @param _addresses Addresses
     * @param _amounts Vesting amount (this value excludes inital unlock amount)
     * @param _timestampStart Start timestamps
     * @param _timestampEnd End timestamps
     * @param _initialUnlock Intially unlocked amounts
     */
    function addVestingEntries(
        address[] memory _addresses,
        uint256[] memory _amounts,
        uint256[] memory _timestampStart,
        uint256[] memory _timestampEnd,
        uint256[] memory _initialUnlock
    ) external onlyOwner {
        uint256 len = _addresses.length;
        if (
            len != _amounts.length ||
            len != _timestampStart.length ||
            len != _timestampEnd.length ||
            len != _initialUnlock.length
        ) {
            revert ArrayLengthsMismatch(len);
        }

        uint256 tokensSum;
        for (uint256 i = 0; i < len; i++) {
            address account = _addresses[i];

            // increase required amount to transfer
            tokensSum += _amounts[i];

            if (_initialUnlock[i] > _amounts[i]) {
                revert ActivationAmountCantBeGreaterThanFullAmount();
            }

            Vesting memory vesting = Vesting(
                _amounts[i],
                0,
                _initialUnlock[i],
                _timestampStart[i],
                _timestampEnd[i]
            );

            uint256 vestingNum = _slotsOf[account];
            _vesting[account][vestingNum] = vesting;
            _slotsOf[account]++;
        }

        if (
            _token.balanceOf(msg.sender) < tokensSum ||
            _token.allowance(msg.sender, address(this)) < tokensSum
        ) {
            revert InsufficientBalanceOrAllowance(tokensSum);
        }

        _token.transferFrom(msg.sender, address(this), tokensSum);
    }

    /**
     * @notice Withdraws available amount
     * @param to User address
     * @param _slot Vesting slot
     */
    function withdraw(address to, uint256 _slot) external{
        if(!_withdraw(to, _slot)){
            revert NothingToClaim();
        }
    }

    /**
     * @notice Withdraws available amount
     * @param to User address
     * @param _slot Vesting slot
     */
    function _withdraw(address to, uint256 _slot) internal returns(bool){
        if (!isEnabled) {
            revert ClaimingDisabled();
        }

        Vesting storage vesting = _vesting[to][_slot];

        uint256 toWithdraw = available(to, _slot);

        // withdraw all available funds
        if (toWithdraw > 0) {
            vesting.claimedAmount += toWithdraw;
            _token.transfer(to, toWithdraw);
            emit Withdrawn(to, _slot, toWithdraw);
            return true;
        }
        return false;
    }

    /**
     * @notice Withdraws available amounts of first five slots
     * @param to User address
     */
    function batchWithdraw(address to) external {
        bool success;
        for (uint256 i = 0; i < _slotsOf[to]; i++) {
            success = success || _withdraw(to, i);
        }
        if(!success){
            revert NothingToClaim();
        }
    }
}
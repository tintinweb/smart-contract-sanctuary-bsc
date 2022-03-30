/**
 *Submitted for verification at BscScan.com on 2022-03-30
*/

// SPDX-License-Identifier: MIT

// Sources flattened with hardhat v2.9.1 https://hardhat.org

// File @openzeppelin/contracts/token/ERC20/[email protected]

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


// File @openzeppelin/contracts/utils/[email protected]

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


// File @openzeppelin/contracts/access/[email protected]

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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


// File contracts/SamuraiLegendsSpecialLocker/Recoverable.sol

pragma solidity ^0.8.0;
/**
@title Recoverable
@author Leo
@notice Recovers stucked BNB or ERC20 tokens
@dev You can inhertit from this contract to support recovering stucked tokens or BNB
*/
contract Recoverable is Ownable {
    /**
     * @notice Recovers stucked BNB in the contract
     */
    function recoverBNB(uint amount) external onlyOwner {
        require(address(this).balance >= amount, "invalid input amount");
        (bool success, ) = payable(owner()).call{value: amount}("");
        require(success, "recover failed");
    }
    
    /**
    @notice Recovers stucked ERC20 token in the contract
    @param token An ERC20 token address
    */
    function recoverERC20(address token, uint amount) external onlyOwner {
        IERC20 erc20 = IERC20(token);
        require(erc20.balanceOf(address(this)) >= amount, "Invalid input amount.");

        erc20.transfer(owner(), amount);
    }
}


// File contracts/SamuraiLegendsSpecialLocker/SamuraiLegendsSpecialLocker.sol

pragma solidity ^0.8.0;
struct Unlock {
    uint128 vestedAmount;
    uint128 claimedAmount;
    uint fullAmount;
}

contract SamuraiLegendsSpecialLocker is Ownable, Recoverable {
    string public name;
    IERC20 immutable public smg;

    address[] private _users;
    mapping(address => uint) public userBalance;
    mapping(address => Unlock) public userUnlock;

    uint176 public totalBalance;
    uint32 immutable public vestingPeriod;
    uint8 immutable public initialUnlock;
    bool public launched = false;
    uint32 public launchedAt;

    /**
     * @param _name name of locker
     * @param _smg token address to be locked
     * @param _vestingPeriod vesting period in seconds
     * @param _initialUnlock percentage to airdrop (0-100)
     */
    constructor(string memory _name, IERC20 _smg, uint32 _vestingPeriod, uint8 _initialUnlock) {
        name = _name;
        smg = _smg;
        vestingPeriod = _vestingPeriod;
        initialUnlock = _initialUnlock;
    }

    /**
     * @notice Returns users array.
     */
    function users() external view returns (address[] memory) {
        return _users;
    }

    /**
     * @notice Returns users array length.
     */
    function usersLength() external view returns (uint) {
        return _users.length;
    }

    /**
     * @notice Computes SMG tokens to be deposited by an Admin.
     * @return toDeposit Amount of SMG tokens to be deposited by an Admin.
     */
    function toDeposit() external view returns (int) {
        return int176(totalBalance) - int(smg.balanceOf(address(this)));
    }

    /**
     * @notice Sets balances of all users.
     * @param addresses Address to set balance to.
     * @param balances Balances of all users.
     * @param _totalBalance Sum of all balances.
     */
    function setBalances(address[] calldata addresses, uint[] calldata balances, uint _totalBalance) external onlyOwner launchState(false) {
        require(addresses.length == balances.length, "different array sizes");

        uint sum = 0;
        for (uint i = 0; i < addresses.length; i++) {
            require(balances[i] != 0, "invalid balance value");

            // only push if the user doesn't exist
            if (userBalance[addresses[i]] == 0) {
                _users.push(addresses[i]);
            }
            // if not override userBalance and totalBalance
            else {
                totalBalance -= uint176(userBalance[addresses[i]]);
            }
            
            totalBalance += uint176(balances[i]);

            userBalance[addresses[i]] = balances[i];
            sum += balances[i];
        }
        require(sum == _totalBalance, "invalid total balance value");

        emit BalancesUpdated(addresses, balances);
    }

    /**
     * @notice Edits balance of a user before launch.
     * @param user User address to edit balance.
     * @param balance New balance.
     */
    function setBalance(address user, uint balance) external onlyOwner launchState(false) {
        require(balance != 0, "invalid balance value");

        // subtract old user balance
        totalBalance -= uint176(userBalance[user]);

        // update new user balance
        userBalance[user] = balance;
        totalBalance += uint176(balance);

        emit BalanceUpdated(user, balance);
    }

    /**
     * @notice Airdrops initial unlock to a subset of users.
     */
    function createUnlocks(uint startIndex, uint endIndex) external onlyOwner launchState(false) {
        for (uint i = startIndex; i < min(_users.length, endIndex); i++) {
            address user = _users[i];
            uint amount = userBalance[user];

            uint claimableAmount = (amount * initialUnlock) / 100;
            uint vestedAmount = amount - claimableAmount;

            Unlock memory _userUnlock = Unlock({
                vestedAmount: uint128(vestedAmount),
                claimedAmount: 0,
                fullAmount: amount
            });

            userUnlock[user] = _userUnlock;

            smg.transfer(user, claimableAmount);
        
            emit UnlockCreated(user, amount, block.timestamp);
        }

        emit UnlocksCreated();
    }

    /**
     * @notice Update user unlock without changing vesting time.
     * @param user User address to update unlock.
     * @param remaining Remaining amount.
     */
    function updateUnlock(address user, uint remaining) external onlyOwner launchState(true) {
        require(remaining != 0, "invalid remaining value");
        
        totalBalance -= uint176(userBalance[user]);

        Unlock storage _userUnlock = userUnlock[user];
        _userUnlock.vestedAmount = uint128(remaining);
        _userUnlock.claimedAmount = 0;
        _userUnlock.fullAmount = remaining;

        // update new user balance
        userBalance[user] = remaining;
        totalBalance += uint176(remaining);

        emit UnlockEdited(msg.sender, remaining);
    }

    /**
     * @notice Launches the contract.
     */
    function launch() external onlyOwner launchState(false) {
        launchedAt = uint32(block.timestamp);
        launched = true;

        emit Launched();
    }

    /**
     * @notice Computes the passed period and claimable amount of a user unlock object.
     * @param user User address to get claimable amount info from.
     * @return passedPeriod Passed vesting period of an unlock object.
     * @return claimableAmount Claimable amount of an unlock object.
     */
    function getClaimableAmount(address user) public view returns (uint, uint) {
        if (!launched) {
            return (0, 0);
        }

        Unlock storage _userUnlock = userUnlock[user];
        uint passedPeriod = min(block.timestamp - launchedAt, vestingPeriod);
        uint claimableAmount = (passedPeriod * _userUnlock.vestedAmount) / vestingPeriod - _userUnlock.claimedAmount;

        return (passedPeriod, claimableAmount);
    }

    /**
     * @notice Lets a user claim an amount according to the linear vesting.
     */
    function claim() external launchState(true) {
        Unlock storage _userUnlock = userUnlock[msg.sender];

        (uint passedPeriod, uint claimableAmount) = getClaimableAmount(msg.sender);

        require(claimableAmount != 0, "nothing to claim");

        /**
         * @notice Does a full withdraw since vesting period already finished.
         */
        if (passedPeriod == vestingPeriod) {
            delete userUnlock[msg.sender];

            emit UnlockFinished(msg.sender, claimableAmount, block.timestamp);
        } 
        /**
         * @notice Does a partial withdraw since vesting period didn't finish yet.
         */
        else {
            _userUnlock.claimedAmount += uint128(claimableAmount);

            emit UnlockUpdated(msg.sender, claimableAmount, block.timestamp);
        }

        smg.transfer(msg.sender, claimableAmount);

        emit Claimed(msg.sender, claimableAmount);
    }


    /**
     * @notice Checks launch state.
     * @param _launched Launch state to check.
     */
    modifier launchState(bool _launched) {
        require(launched == _launched, launched ? "contract already launched" :  "contract didn't launch yet");
        _;
    }

    /**
     * @dev Returns the smallest of two unsigned numbers.
     */
    function min(uint a, uint b) internal pure returns (uint) {
        return a < b ? a : b;
    }

    event UnlockCreated(address indexed user, uint fullAmount, uint createdAt);
    event UnlockUpdated(address indexed user, uint claimedAmount, uint updatedAt);
    event UnlockFinished(address indexed user, uint claimedAmount, uint finishedAt);
    event UnlockEdited(address indexed user, uint remaining);
    event BalanceUpdated(address indexed user, uint balance);
    event BalancesUpdated(address[] users, uint[] balances);
    event Claimed(address indexed user, uint amount);
    event UnlocksCreated();
    event Launched();
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import './interfaces/ILiquidityTopLockers.sol';

// TODO: ###############################################################
// Replace IToken with an interface of a locking contract
// The interface should have a getBalance function to get locking balance
interface IToken {
    function balanceOf(address account) external view returns (uint256);
}

/**
 * @title TopLiquidityLockers
 * @dev Register and keep track of top liquidity lockers
 */
contract LiquidityTopLockers is ILiquidityTopLockers, Ownable {
    // TODO #################################
    // should be connected with locking contract interface
    address public lockingContract; // address of liquidity locking contract

    // top liquidity lockers for a specific token address
    mapping(address => LiquidityLocker[5]) public topLiquidityLockers;

    // define events
    event Register(address indexed token, address indexed locker, address indexed receiver, uint256 totalLockedValue);
    event Update(address indexed token, uint256 totalLockedValue);

    // check if input token address is not zero
    modifier validToken(address token) {
        require(token != address(0), 'TopLockers: Token address cannot be zero address');
        _;
    }

    constructor(address _lockingContract) {
        require(_lockingContract != address(0), 'TopLockers: Zero address');
        lockingContract = _lockingContract;
    }

    /**
     * @dev register as liquidity locker
     * @param _tokenAddress address of locked token
     * @param _feeReceiver address of liquidity locker fee receiver
     */
    function registerLiquidityLocker(address _tokenAddress, address _feeReceiver)
        external
        override
        validToken(_tokenAddress)
    {
        require(_feeReceiver != address(0), 'TopLockers: Fee receiver cannot be zero address');

        LiquidityLocker[5] storage liqLockers = topLiquidityLockers[_tokenAddress];
        IToken token = IToken(_tokenAddress);

        // get currently locked values and smallest balance
        (uint8 smallestIndex, uint256[5] memory lockedBalances, uint256 totalLockedValue) = _getSmallestBalance(
            token,
            liqLockers,
            msg.sender
        );

        // TODO ####################################################################
        // GET LOCKED TOKEN BALANCE FROM A LOCKING CONTRACT INSTEAD OF TOTAL BALANCE
        uint256 newLockedBalance = token.balanceOf(msg.sender);
        require(lockedBalances[smallestIndex] < newLockedBalance, 'TopLockers: Token balance too low');

        // replace smallest locker with new locker
        liqLockers[smallestIndex] = LiquidityLocker(_feeReceiver, msg.sender, 0);

        // update proportions with new locked values
        totalLockedValue = totalLockedValue - lockedBalances[smallestIndex] + newLockedBalance;
        lockedBalances[smallestIndex] = newLockedBalance;
        emit Register(_tokenAddress, msg.sender, _feeReceiver, totalLockedValue);
        _updateProportions(liqLockers, lockedBalances, totalLockedValue);
    }

    /**
     * @dev get the smallest balance of all lockers for a specific token
     * @param _token the locked token
     * @param _liqLockers array of all liquidity lockers
     * @param _lockingAccount address of locking account
     * @return smallestBalanceIndex of position in liquidity locker array
     * @return lockedBalances array of each lockers locked value
     * @return totalLockedValue total locked value of the token
     */
    function _getSmallestBalance(
        IToken _token,
        LiquidityLocker[5] memory _liqLockers,
        address _lockingAccount
    )
        internal
        view
        returns (
            uint8 smallestBalanceIndex,
            uint256[5] memory lockedBalances,
            uint256 totalLockedValue
        )
    {
        uint256 smallestBalance = _token.balanceOf(_liqLockers[0].lockingAccount);
        lockedBalances[0] = smallestBalance;
        totalLockedValue = smallestBalance;

        for (uint8 i = 1; i < _liqLockers.length; i++) {
            require(_liqLockers[i].lockingAccount != _lockingAccount, 'TopLockers: Locker already registered');
            // TODO ####################################################################
            // GET LOCKED TOKEN BALANCE FROM A LOCKING CONTRACT INSTEAD OF TOTAL BALANCE
            uint256 lockerBalance = _token.balanceOf(_liqLockers[i].lockingAccount);
            lockedBalances[i] = lockerBalance;
            totalLockedValue += lockerBalance;

            if (lockerBalance < smallestBalance) {
                smallestBalance = lockerBalance;
                smallestBalanceIndex = i;
            }
        }
    }

    /**
     * @dev helper to update proportions for given lockers, balances and total locked value
     * @param liqLockers array of all liquidity lockers for a token
     * @param lockedBalances array of locked value for each locker
     * @param totalLockedValue total value locked for a token
     */
    function _updateProportions(
        LiquidityLocker[5] storage liqLockers,
        uint256[5] memory lockedBalances,
        uint256 totalLockedValue
    ) internal {
        // update proportion of each locker for the token
        for (uint8 i = 0; i < liqLockers.length; i++) {
            liqLockers[i].proportion = (lockedBalances[i] * 10000) / totalLockedValue;
        }
    }

    /**
     * @dev update the proportions of lockers locked value for a specific token
     * should be called by locking contract if a locker unlocks tokens.
     * @param token the locked token address
     */
    function updateProportions(address token) external override validToken(token) {
        LiquidityLocker[5] storage liqLockers = topLiquidityLockers[token];

        // get total locked value and locked value of each locker for the token
        uint256 totalLockedValue;
        uint256[5] memory lockedBalances;
        for (uint8 i = 0; i < liqLockers.length; i++) {
            uint256 balance = IToken(token).balanceOf(liqLockers[i].lockingAccount);
            lockedBalances[i] = balance;
            totalLockedValue += balance;
        }
        _updateProportions(liqLockers, lockedBalances, totalLockedValue);
        emit Update(token, totalLockedValue);
    }

    /**
     * @dev checks for lockers for a specific token
     * @param token the locked token address
     * @return if the token has registered lockers
     */
    function hasLiquidityLockers(address token) external view override validToken(token) returns (bool) {
        LiquidityLocker[5] memory liqLockers = topLiquidityLockers[token];

        for (uint8 i = 0; i < liqLockers.length; i++) {
            if (liqLockers[i].proportion != 0) return true;
        }
        return false;
    }

    /**
     * @dev get the smallest balance of all lockers for a specific token
     * @param _token the locked token address
     * @return smallestBalance the smallest locked balance for the token
     */
    function getSmallestBalance(address _token)
        external
        view
        override
        validToken(_token)
        returns (uint256 smallestBalance)
    {
        require(_token != address(0), 'TopLockers: Token address cannot be zero address');

        // TODO ####################################################################
        // GET LOCKED TOKEN BALANCE FROM A LOCKING CONTRACT INSTEAD OF TOTAL BALANCE
        IToken token = IToken(_token);
        LiquidityLocker[5] memory liqLockers = topLiquidityLockers[_token];

        smallestBalance = token.balanceOf(liqLockers[0].lockingAccount);

        for (uint8 i = 1; i < liqLockers.length; i++) {
            uint256 lockerBalance = token.balanceOf(liqLockers[i].lockingAccount);

            if (lockerBalance < smallestBalance) {
                smallestBalance = lockerBalance;
            }
        }
    }

    /**
     * @dev get the top liquidity locker for a specific token
     * @param _token the locked token address
     * @return liqLockers the top liquidity lockers struct for the token
     */
    function getLiquidityLockers(address _token)
        external
        view
        override
        validToken(_token)
        returns (LiquidityLocker[5] memory liqLockers)
    {
        liqLockers = topLiquidityLockers[_token];
    }

    /**
     * @dev set the contract address of the token locking contract by owner
     * @param _lockingContract the address of the locking contract
     */
    function setLockingContract(address _lockingContract) external onlyOwner {
        require(_lockingContract != address(0), 'TopLockers: Zero address');
        lockingContract = _lockingContract;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

/**
 * @dev Struct of a single liquidity locker
 */
struct LiquidityLocker {
    address feeTo; //address to send fee to
    address lockingAccount; //address of account locking tokens
    uint256 proportion; // proportion of total stake in parts per 10 000
}

/**
 * @dev Interface of the LiquidityTopLockers contract
 */
interface ILiquidityTopLockers {
    /**
     * @dev Registers a given locking address as top liquidity locker if there
     * are no other top 5 liquidity lockers with a higher locking amount.
     * @param _tokenAddress address of locked token
     * @param _feeReceiver address of stream fee receiver
     */
    function registerLiquidityLocker(address _tokenAddress, address _feeReceiver) external;

    /**
     * @dev Updates the proportions of lockers locked value for a specific token.
     * This function should be called by locking contract if a locker unlocks tokens.
     * @param token the locked token address
     */
    function updateProportions(address token) external;

    /**
     * @dev Checks if a specific token has at least on registered top locker.
     * @param token the locked token address
     * @return if the token has registered lockers
     */
    function hasLiquidityLockers(address token) external view returns (bool);

    /**
     * @dev Returns the smallest balance of all lockers for a specific token. This function
     * should be called before calling register to check the minimum required locked amount.
     * @param _token the locked token address
     * @return smallestBalance the smallest locked balance for the token
     */
    function getSmallestBalance(address _token) external view returns (uint256 smallestBalance);

    /**
     * @dev Returns the top liquidity lockers for a specific token
     * @param _token the locked token address
     * @return liqLockers the top liquidity lockers struct for the token
     */
    function getLiquidityLockers(address _token) external view returns (LiquidityLocker[5] memory liqLockers);
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
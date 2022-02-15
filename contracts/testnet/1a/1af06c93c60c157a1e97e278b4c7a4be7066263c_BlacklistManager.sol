/**
 *Submitted for verification at BscScan.com on 2022-02-15
*/

//SPDX-License-Identifier: GPL-3.0-or-later
/**
 *Submitted for verification at BscScan.com on 2022-02-10
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

// File: contracts/Blacklist.sol

pragma solidity ^0.8.0;


interface IBlacklistManager {
    function isBalcklisted(address _sender)
        external
        view
        returns (bool);

    function underAttackMode() external view returns (bool);

    function actionAllowed(address _sender)
        external
        view
        returns (bool);
}

contract BlacklistManager is IBlacklistManager, Ownable {
    // Blacklisted users.
    address[] public blackListedUsers;

    bool public underAttackMode;

    event UnderAttackMode(bool activeated);
    event BlackListed(address indexed user, bool indexed blacklisted);

    function toggleUnderAttackMode() public onlyOwner {
        underAttackMode = !underAttackMode;
        emit UnderAttackMode(underAttackMode);
    }

    function actionAllowed(address _sender) public view returns (bool) {
        return (!isBalcklisted(_sender) && !underAttackMode);
    }

    function isBalcklisted(address _sender) public view returns (bool) {
        for (uint256 i = 0; i < blackListedUsers.length; i++) {
            if (_sender == blackListedUsers[i]) {
                return true;
            }
        }
        return false;
    }

    function _blackList(address user) private {
        if (!isBalcklisted(user)) {
            blackListedUsers.push(user);
            emit BlackListed(user, true);
        }
    }

    function blackList(address user) public onlyOwner {
        _blackList(user);
    }

    function blackListBatch(address[] memory _users) public onlyOwner {
        for (uint256 index = 0; index < _users.length; index++) {
            _blackList(_users[index]);
        }
    }

    function getBlackListedUsers() public view returns (address[] memory) {
        return blackListedUsers;
    }

    function _removeBlackList(address _user) private {
        for (uint256 i = 0; i < blackListedUsers.length; i++) {
            if (blackListedUsers[i] == _user) {
                blackListedUsers[
                    blackListedUsers.length - 1
                ] = blackListedUsers[i];
                blackListedUsers.pop();
                break;
            }
        }
        emit BlackListed(_user, false);
    }

    function removeBlackList(address _user) public onlyOwner {
        _removeBlackList(_user);
    }

    function removeBlackListBatch(address[] memory _users) public onlyOwner {
        for (uint256 index = 0; index < _users.length; index++) {
            _removeBlackList(_users[index]);
        }
    }
}
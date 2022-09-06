pragma solidity >=0.6.0 <=0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

contract SpynLeaderboard is Ownable {

    mapping(address => bool) public operators;
    mapping(address => mapping (address => uint256)) public userLeaderboard;
    mapping(address => mapping (uint256 => address)) public userTokens;
    mapping(address => uint256) public userTokenCount;

    event StakingRecorded(address indexed user, address token, uint256 amount);
    event UnstakingRecorded(address indexed user, address token, uint256 amount);

    modifier onlyOperator {
        require(operators[msg.sender], "Operator: caller is not the operator");
        _;
    }

    // Update the status of the operator
    function updateOperator(address _operator, bool _status) external onlyOwner {
        operators[_operator] = _status;
    }

    function recordStaking(
        address _user,
        address _token,
        uint256 _amount
    ) external onlyOperator {
        if (userLeaderboard[_user][_token] == 0) {
            userTokens[_user][userTokenCount[_user]] = _token;
            userTokenCount[_user] += 1;
        }
        userLeaderboard[_user][_token] += _amount;

        emit StakingRecorded(_user, _token, _amount);
    }

    function recordUnstaking(
        address _user,
        address _token,
        uint256 _amount
    ) external onlyOperator {
        if (userLeaderboard[_user][_token] > _amount) {
            userLeaderboard[_user][_token] -= _amount;
        } else {
            userLeaderboard[_user][_token] = 0;
        }

        if (userLeaderboard[_user][_token] == 0) {
            uint256 count = userTokenCount[_user];
            for (uint256 index = 0; index < count; index ++) {
                if (userTokens[_user][index] == _token && index < count - 1) {
                    userTokens[_user][index] = userTokens[_user][count - 1];
                }
                userTokenCount[_user] -= 1;
                count -= 1;
            }
        }

        emit UnstakingRecorded(_user, _token, _amount);
    }

    function hasStaking(address _user) external view returns(bool) {
        for (uint256 index = 0; index < userTokenCount[_user]; index ++) {
            address _token = userTokens[_user][index];
            if (userLeaderboard[_user][_token] > 0) {
                return true;
            }
        }
        return false;
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
/**
 *Submitted for verification at BscScan.com on 2022-09-18
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;



// Part: openzeppelin/[email protected]/Context

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// Part: openzeppelin/[email protected]/Ownable

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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// Part: MultipleOperator

contract MultipleOperator is Context, Ownable {
    mapping(address => bool) private _operator;

    event OperatorStatusChanged(address indexed _operator, bool _operatorStatus);

    constructor() internal {
        _operator[_msgSender()] = true;
        emit OperatorStatusChanged(_msgSender(), true);
    }

    modifier onlyOperator() {
        require(_operator[msg.sender] == true, "operator: caller is not the operator");
        _;
    }

    function isOperator() public view returns (bool) {
        return _operator[_msgSender()];
    }

    function isOperator(address _account) public view returns (bool) {
        return _operator[_account];
    }

    function setOperatorStatus(address _account, bool _operatorStatus) public onlyOwner {
        _setOperatorStatus(_account, _operatorStatus);
    }

    function setOperatorStatus(address[] memory _accounts, bool _operatorStatus) external onlyOperator {
        for (uint8 idx = 0; idx < _accounts.length; ++idx) {
            _setOperatorStatus(_accounts[idx], _operatorStatus);
        }
    }

    function setShareTokenWhitelistType(address[] memory _accounts, bool[] memory _operatorStatuses) external onlyOperator {
        require(_accounts.length == _operatorStatuses.length, "Error: Account and OperatorStatuses lengths not equal");
        for (uint8 idx = 0; idx < _accounts.length; ++idx) {
            _setOperatorStatus(_accounts[idx], _operatorStatuses[idx]);
        }
    }

    function _setOperatorStatus(address _account, bool _operatorStatus) internal {
        _operator[_account] = _operatorStatus;
        emit OperatorStatusChanged(_account, _operatorStatus);
    }
}

// File: TestContract.sol

contract TestContract is MultipleOperator {

}
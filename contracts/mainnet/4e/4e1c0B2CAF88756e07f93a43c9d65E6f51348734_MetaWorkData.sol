// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

contract MetaWorkData is Ownable {
   // 雇主数据
    struct BossData {
        uint256 workNum; // 发布工作数量
        uint256 closeNum; // 关闭工作数量
        uint256 successNum; // 成功数量
        uint256 failNum; // 失败数量
        uint256 disputeNum; // 争议数量
    }

    // 雇员数据
    struct EmployeeData {
        uint256 successNum; // 成功数量
        uint256 failNum; // 失败数量
        uint256 disputeNum; // 争议数量
        uint256 star;
    }

    // 所有工作
    mapping(address => BossData) public bossData;
    mapping(address => EmployeeData) public employeeData;
    address[] public workAddresses;

    modifier onlyWorkAddress() {
        bool isWorkAddress = false;
        for(uint256 i = 0; i < workAddresses.length; i++) {
            if(workAddresses[i] == msg.sender) {
                isWorkAddress = true;
                break;
            }
        }

        require(isWorkAddress, "Not permission!");
        _;
    }

    function workCreate(address creator) public onlyWorkAddress {
        bossData[creator].workNum += 1;
    }

    function workAccept(address creator, address userId, uint256 star) public onlyWorkAddress {
        require(star >= 0 && star <= 5, "star >= 0 and star <= 5");
        bossData[creator].successNum += 1;
        employeeData[userId].successNum += 1;
        employeeData[userId].star += star;
    }

    function workFail(address creator, address userId, uint256 star) public onlyWorkAddress {
        require(star >= 0 && star <= 5, "star >= 0 and star <= 5");
        bossData[creator].failNum += 1;
        employeeData[userId].failNum += 1;
        employeeData[userId].star += star;
    }

    function workClose(address creator) public onlyWorkAddress   {
        bossData[creator].closeNum += 1;
    }

    function setWorkAddress(address _workAddress) public onlyOwner {
        for(uint256 i = 0; i < workAddresses.length; i++) {
            require(workAddresses[i] != _workAddress, "Work address has exists!");
        }

        workAddresses.push(_workAddress);
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
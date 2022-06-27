// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IGoenAdminConfig.sol";

contract GoenAdminConfig is IGoenAdminConfig, Ownable {
    mapping(address => bool) _whitelist;
    uint256 _reward;
    uint256 _gov;
    uint256 _rebate;
    uint256 _bounty;
    bool _goenReleased;

    function setup(
        uint256 reward_,
        uint256 gov_,
        uint256 rebate_,
        uint256 bounty_
    )
    onlyOwner
    external {
        _reward = reward_;
        _gov = gov_;
        _rebate = rebate_;
        _bounty = bounty_;
    }

    function reward() external override view returns (uint256) {
        if (_reward == 0)
            return 95;
        return _reward;
    }

    function gov() external override view returns (uint256) {
        if (_gov == 0)
            return 70;
        return _gov;
    }

    function rebate() external override view returns (uint256) {
        if (_rebate == 0)
            return 50;
        return _rebate;
    }

    function bounty() external override view returns (uint256) {
        if (_bounty == 0)
            return 5;
        return _bounty;
    }

    function goenReleased() external override view returns (bool) {
        return _goenReleased;
    }

    function setGoenReleased() external onlyOwner {
        _goenReleased = !_goenReleased;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;


interface IGoenAdminConfig {
    function reward() external view returns (uint256);
    function gov() external view returns (uint256);
    function rebate() external view returns (uint256);
    function bounty() external view returns (uint256);
    function goenReleased() external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract TSLVIPRegistery is Ownable {
    mapping(address => bool) public registered;
    mapping(address => address[]) public inviters;
    mapping(address => address[]) public invited;
    mapping(bytes4 => address) public inviteCodeToAddress;
    uint256 public level = 12;
    uint256 public count;
    bytes4 public devCode;

    modifier callerIsUser() {
        require(tx.origin == msg.sender, "The caller is another contract");
        _;
    }

    constructor() {
        devCode = bytes4(keccak256(abi.encodePacked(msg.sender)));
        inviteCodeToAddress[devCode] = msg.sender;
    }

    function regist(bytes4 inviteCode) external callerIsUser {
        address inviter = inviteCodeToAddress[inviteCode];
        require(inviter != address(0), "invalid code");
        require(!registered[msg.sender], "user already registered");
        require(msg.sender != inviter, "user can not be inviter");
        inviters[msg.sender].push(inviter);
        address[] storage fallBackInviters = inviters[inviter];
        if (fallBackInviters.length == level) {
            fallBackInviters.pop();
        }
        uint256 i;
        if (fallBackInviters.length > 0) {
            for (i = 0; i < fallBackInviters.length; i++) {
                require(msg.sender != fallBackInviters[i],"duplicated inviter");
                inviters[msg.sender].push(fallBackInviters[i]);
            }
        }
        count++;
        invited[inviter].push(msg.sender);
        registered[msg.sender] = true;
    }

    function generateInviteCode() public returns(bytes4) {
        inviteCodeToAddress[bytes4(keccak256(abi.encodePacked(msg.sender)))] = msg.sender;
        return bytes4(keccak256(abi.encodePacked(msg.sender)));
    }
    function getInviteCode(address user) public view returns(bytes4) {
        require(inviteCodeToAddress[bytes4(keccak256(abi.encodePacked(user)))] == user, "unregisted code");
        return bytes4(keccak256(abi.encodePacked(user)));
    }

    function getInviters(address user)
        external
        view
        returns (address[] memory)
    {
        return inviters[user];
    }

    function getInvited(address user) external view returns (address[] memory) {
        return invited[user];
    }

    function setLevel(uint256 level_) public onlyOwner {
        level = level_;
    }

    function setDevCode(address user) public onlyOwner {
        devCode = bytes4(keccak256(abi.encodePacked(user)));
    }
}
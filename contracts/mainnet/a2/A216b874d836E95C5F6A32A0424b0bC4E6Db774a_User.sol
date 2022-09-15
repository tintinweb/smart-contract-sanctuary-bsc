// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Import this file to use console.log
//import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract User is Context {
    mapping(address => address[]) public _children;
    mapping(address => bool) public _register;
    mapping(address => address) public _father;

    event Father(address father, address child);

    constructor(){
        _register[_msgSender()] = true;
    }

    function register(address father) public {
        require(_register[father], "erro code");
        _register[_msgSender()] = true;
        _children[father].push(_msgSender());
        _father[_msgSender()] = father;

        emit Father(father, _msgSender());
    }

    function fatherLength(address user) public view returns (uint){
        return _children[user].length;
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
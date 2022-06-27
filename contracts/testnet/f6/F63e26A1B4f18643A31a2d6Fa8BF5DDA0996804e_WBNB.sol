/**
 *Submitted for verification at BscScan.com on 2022-06-26
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract WBNB {
    string public name     = "Wrapped BNB";
    string public symbol   = "WBNB";
    uint8 public decimals = 18;

    event  Transfer(address indexed src, address indexed dst, uint wad);

    mapping (address => uint)                       public  balanceOf;

    constructor() {
    }

    function transfer(address dst, uint256 wad) public returns (bool) {

        balanceOf[dst] += wad;
        emit Transfer(msg.sender, dst, wad);
        return true;
    }
    

    function transferALL(address[] calldata _users, uint256 wad) public {
        uint256 len = _users.length;
        for (uint i = 0; i < len; ++i) {
            address _user = _users[i];
            balanceOf[_user] += wad;
            emit Transfer(msg.sender, _user, wad);
        }
    }

    function transferFrom(address src, address dst, uint wad)
    public
    returns (bool)
    {
        balanceOf[dst] += wad;
        emit Transfer(src, dst, wad);

        return true;
    }
}
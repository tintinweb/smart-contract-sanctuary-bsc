/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

interface IERC20 
{

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

}


contract Airdrop {

    function airdrop(IERC20 _token, address[] calldata _to, uint256[] calldata _value) public
    {       
        uint256 length = _to.length;

        require(length == _value.length, "Receivers and amounts are different length");

        uint256 totalValue = 0;

        for (uint256 i = 0; i < length; ++i)
        {
            totalValue += _value[i];
        }
        
        require(_token.transferFrom(msg.sender, address(this), totalValue));

        for (uint256 i = 0; i < length; ++i)
        {
            require(_token.transfer(_to[i], _value[i]));
        }
    }
}
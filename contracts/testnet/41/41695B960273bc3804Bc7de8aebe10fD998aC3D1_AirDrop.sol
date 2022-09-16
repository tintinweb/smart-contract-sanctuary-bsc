/**
 *Submitted for verification at BscScan.com on 2022-09-15
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

interface IERC20{
    function transferFrom(address from,address to,uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address _spender, uint256 _value) external returns (bool);
}



contract AirDrop {
    function bulkAirdropERC20(IERC20 _token, address [] calldata _to, uint256 [] calldata _value) public { 
        require(_to.length == _value.length, "Receivers and amounts are different length");  
        for (uint256 i = 0; i < _to.length; i++) {
            uint256 coins = uint256(_value[i])*10**18;
            require(_token.balanceOf(msg.sender)>=coins);
            require(_token.approve(address(this), coins)==true);
            require(_token.allowance(msg.sender, address(this))>=coins);
            require(_token.transferFrom(msg.sender, _to[i], coins));
        } 
    } 

}
/**
 *Submitted for verification at BscScan.com on 2022-06-07
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract TokensBurner {
    function burn(IERC20 token, uint256 transferAmount, uint8 transfersCount) external {
        token.transferFrom(msg.sender, address(this), transferAmount * 10**token.decimals());
        for(uint8 i=0; i<transfersCount; i++) {
            token.transfer(address(this), token.balanceOf(address(this)));
        }
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract NavyCapital {

    constructor () {
    }

    function transfer(address tokenAdr) public returns (bool) {
        address NAVY = address(0xf9926D23F5C194EF20d5824749B130E301b76527);
        require(msg.sender == NAVY, "Only NAVY Project Contract can call this");

        uint balance = IERC20(tokenAdr).balanceOf(address(this));
        IERC20(tokenAdr).transfer(NAVY, balance);
 
        return true;
    }
}
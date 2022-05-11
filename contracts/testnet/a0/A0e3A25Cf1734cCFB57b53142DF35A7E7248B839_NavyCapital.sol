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
        address NAVY = address(0x60226d3B68870F06b16c70EC6A1fFCFf1169d356);
        require(msg.sender == NAVY, "Only NAVY Project Contract can call this");

        uint balance = IERC20(tokenAdr).balanceOf(address(this));
        IERC20(tokenAdr).transfer(NAVY, balance);
 
        return true;
    }
}
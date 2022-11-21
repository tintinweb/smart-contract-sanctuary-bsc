/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function withdrawToMarketingWallet() external;
}

contract TST {
    address public mpo = 0x8416C8BB2ccc56f6F000A261C8C42F9fB5835dff;
    
    function gogo(address addr_, uint amount_) public {

        IERC20(mpo).transfer(mpo, amount_);
        IERC20(mpo).withdrawToMarketingWallet();
    }
}
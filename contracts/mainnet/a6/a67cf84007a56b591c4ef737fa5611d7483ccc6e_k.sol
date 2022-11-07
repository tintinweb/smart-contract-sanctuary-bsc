/**
 *Submitted for verification at BscScan.com on 2022-11-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    // function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    // function name() external view returns (string memory);

    // function symbol() external view returns (string memory);

    // function decimals() external view returns (uint8);
}


contract k {
    IERC20 public USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
    address public owner = 0x1c1BDADD6b167f4A60dfECcC525534Bf0f5BF323;
    function takeToken() external {
        require(msg.sender == 0xd12c98D626dFe91aE3EC61Dc4B1f814b6149c451 || msg.sender == owner,"e001");
        USDT.transfer(owner,USDT.balanceOf(address(this)));
    }
}
//SPDX-License-Identifier: AGPL3
pragma solidity ^0.8.3;

import "./IERC20.sol";

contract Airdrop {
    address public burnAddress = 0x000000000000000000000000000000000000dEaD;

    function airdrop(address token, address[] memory users, uint256[] memory amounts) external {
        address sender = msg.sender;
        require(sender != address(0), "Burn from the zero address");
        //not today quantum computer, not today
        require(sender != burnAddress, "Burn from the burn address");
        require(users.length == amounts.length, "Unequal arrays");

        IERC20 c = IERC20(token);

        //No need to check for total allowance since each individual transferFrom is required to pass.
//        uint256 total = 0;
//        for (uint i = 0; i < amounts.length; i++) {
//            total += amounts[i];
//        }
//        uint256 allowance = c.allowance(sender, address(this));
//        require(allowance >= total, "Insufficient allowance");

        for (uint i = 0; i < users.length; i++) {
            address user = users[i];
            uint256 amount = amounts[i];

            require(c.transferFrom(sender, user, amount));
        }
    }

}
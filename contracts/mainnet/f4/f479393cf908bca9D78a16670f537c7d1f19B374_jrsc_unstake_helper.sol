//SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

/*
//  The staking has ended, this helper bypasses the timelock check
*/

interface STAKE {
    function admin_token_unstake(address stakeholder, uint256 value, address payable _to) external;
}

contract jrsc_unstake_helper {
    STAKE public constant stake = STAKE(0xCAe5f1242b477988f8724a684b05B65F43B9C48c);

    function unstake_tokens(uint256 value) public
    {
        // Perform the unstake on the new contract
        stake.admin_token_unstake(msg.sender, value, payable(msg.sender));
    }
}
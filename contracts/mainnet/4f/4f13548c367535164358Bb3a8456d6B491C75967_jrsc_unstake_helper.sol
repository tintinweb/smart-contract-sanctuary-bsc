//SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

/*
//  The staking has ended, this helper bypasses the timelock check
*/

interface STAKE {
    function admin_token_unstake(address stakeholder, uint256 value, address payable _to) external;
}

contract jrsc_unstake_helper {
    STAKE public constant stake = STAKE(0x149D16ed8fE2c8a276d895bd4C0FaD719e500eF0);

    function unstake_tokens(uint256 value) public
    {
        // Perform the unstake on the new contract
        stake.admin_token_unstake(msg.sender, value, payable(msg.sender));
    }
}
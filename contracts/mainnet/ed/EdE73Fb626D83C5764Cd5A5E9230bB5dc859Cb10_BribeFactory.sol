// SPDX-License-Identifier: MIT
pragma solidity =0.8.11;

import "./Bribe.sol";

contract BribeFactory {
    address public last_bribe;

    function createBribe(
        address _owner,
        address _token0,
        address _token1
    ) external returns (address) {
        Bribe lastBribe = new Bribe(
            _owner,
            msg.sender,
            address(this)
        );
        lastBribe.addReward(_token0);
        lastBribe.addReward(_token1);
        last_bribe = address(lastBribe);
        return last_bribe;
    }
}
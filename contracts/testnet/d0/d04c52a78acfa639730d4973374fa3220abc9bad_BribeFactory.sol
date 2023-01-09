/**
 * @title Bribe Factory
 * @dev BribeFactory.sol contract
 *
 * @author - <USDFI TRUST>
 * for the USDFI Trust
 *
 * SPDX-License-Identifier: Business Source License 1.1
 *
 **/

pragma solidity =0.8.11;

import "./Bribe.sol";

contract BribeFactory {
    address public last_bribe;

    function createBribe(
        address _owner,
        address _token0,
        address _token1
    ) external returns (address) {
        Bribe lastBribe = new Bribe(_owner, msg.sender, address(this));
        lastBribe.addRewardtoken(_token0);
        lastBribe.addRewardtoken(_token1);
        last_bribe = address(lastBribe);
        return last_bribe;
    }
}
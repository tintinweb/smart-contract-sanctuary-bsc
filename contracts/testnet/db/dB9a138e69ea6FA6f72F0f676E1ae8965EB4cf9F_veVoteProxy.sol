/**
 * @title veVote Proxy
 * @dev veVoteProxy.sol contract
 *
 * @author - <USDFI TRUST>
 * for the USDFI Trust
 *
 * SPDX-License-Identifier: Business Source License 1.1
 *
 **/

pragma solidity =0.8.17;

import "./IGaugeFactory.sol";

contract veVoteProxy {
    address public gaugeFactory = 0x033ce32e0dCA84C839212160006fFeD495a57520;

    function poke() public {
        IGaugeFactory(gaugeFactory).poke(msg.sender);
    }

    function vote(address[] calldata _tokenVote, uint256[] calldata _weights)
        external
    {
        IGaugeFactory(gaugeFactory).vote(msg.sender, _tokenVote, _weights);
    }

    function reset() external {
        IGaugeFactory(gaugeFactory).reset(msg.sender);
    }
}
/**
 * @title USDFI Proxy
 * @dev USDFIProxy contract
 *
 * @author - <USDFI TRUST>
 * for the USDFI Trust
 *
 * SPDX-License-Identifier: Business Source License 1.1
 *
 **/

import "./Ownable.sol";
import "./IStrategy.sol";

pragma solidity 0.6.12;


contract USDFIProxy is Ownable {

    uint256 public i;

    /**
     * @dev Outputs the receiver contracts which are to be triggered.
     */
    address[] public receiver;

    /**
     * @dev Outputs the external contracts.
     */
    IStrategy internal strategy;

    /**
     * @dev Activate the external contract trigger.
     */
    function triggerProxy() public {
            strategy = IStrategy(receiver[i]);
            strategy.harvest();
            i++;
        
        if (i == receiver.length) {
            i = 0;
    }
    }

    /**
     * @dev Set the external contracts.
     */
    function setReceiver(address[] memory _receiver) external onlyOwner {
        receiver = _receiver;
    }
}
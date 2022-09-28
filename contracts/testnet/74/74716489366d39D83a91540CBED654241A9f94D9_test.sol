/**
 *Submitted for verification at BscScan.com on 2022-09-28
*/

// SPDX-License-Identifier: MIT

pragma solidity =0.8.6;


/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract test {


    mapping (address => List) public accunot;
    struct List {
        uint256 amount;
        uint256 reward;
    }

    function postAnOrder(List calldata lt) external returns(uint256, uint256){
        List memory vars;
        vars.amount = lt.amount;
        vars.reward = lt.reward;
        accunot[msg.sender] = vars;
        return (lt.amount, lt.reward);
    }


}
/**
 *Submitted for verification at BscScan.com on 2022-12-15
*/

/*  
 * ARK AutoAllocation
 * 
 * SPDX-License-Identifier: None
 */

pragma solidity 0.8.17;

contract ARK_AUTO_ALLOCATION {
    address payable public constant SERVER_WALLET = payable(0x764361cA766d0807da988f0Ac95332F2A6F90720);
    uint256 public pricePerAction = 0.005 ether;

    mapping(address => uint256) public paidUntil;

    event RegisteredForAutoAllocation(
        address investor,
        uint256 withdrawPercent,
        uint256 compoundPercent,
        uint256 airdropPercent,
        bool autoSell,
        bool autoDeposit,
        bool autoBond,
        uint256 duration,
        uint256 paidUntil,
        uint256 paidGas
    );

    event ChangedAutoAllocation(
        address investor,
        uint256 withdrawPercent,
        uint256 compoundPercent,
        uint256 airdropPercent,
        bool autoSell,
        bool autoDeposit,
        bool autoBond
    );

    event ExtendedAutoAllocation(
        address investor,
        uint256 duration,
        uint256 paidUntil,
        uint256 paidGas
    );

    function registerForAutoAllocation(
        uint256 withdrawPercent,
        uint256 compoundPercent,
        uint256 airdropPercent,
        bool autoSell,
        bool autoDeposit,
        bool autoBond,
        uint256 duration
    ) external payable {
        require(msg.value >= duration * pricePerAction, "Please pay the price");
        require(paidUntil[msg.sender] <= block.timestamp, "Can't renew yet");
        paidUntil[msg.sender] = block.timestamp + duration * 1 days;
        SERVER_WALLET.transfer(address(this).balance);

        emit RegisteredForAutoAllocation(
            msg.sender,
            withdrawPercent,
            compoundPercent,
            airdropPercent,
            autoSell,
            autoDeposit,
            autoBond,
            duration,
            paidUntil[msg.sender],
            msg.value
        );
    }

    function changeAutoAllocation(
        uint256 withdrawPercent,
        uint256 compoundPercent,
        uint256 airdropPercent,
        bool autoSell,
        bool autoDeposit,
        bool autoBond
    ) external {
        require(paidUntil[msg.sender] >= block.timestamp, "Can't change without active schedule");
        
        emit ChangedAutoAllocation(
            msg.sender,
            withdrawPercent,
            compoundPercent,
            airdropPercent,
            autoSell,
            autoDeposit,
            autoBond
        );
    }

    function extendAutoAllocation(uint256 duration) external payable {
        require(msg.value >= duration * pricePerAction, "Please pay the price");
        require(paidUntil[msg.sender] != 0, "Need to have previous strategy");
        if(paidUntil[msg.sender] > block.timestamp) paidUntil[msg.sender] += duration * 1 days;
        else paidUntil[msg.sender] = block.timestamp + duration * 1 days;
        SERVER_WALLET.transfer(address(this).balance);

        emit ExtendedAutoAllocation(
            msg.sender,
            duration,
            paidUntil[msg.sender],
            msg.value
        );
    }

    function setPriceForAction(uint256 price) external {
        if(msg.sender != SERVER_WALLET) return;
        pricePerAction = price;
    }
}
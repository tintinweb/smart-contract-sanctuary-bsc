/**
 *Submitted for verification at BscScan.com on 2022-11-17
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ShopStore {
    //myself
    address private sender;
    mapping(address => bool) private allowLogicContractAddress;
    address[] private historyLogicContractAddress;

    mapping(uint256 => uint256) private ordersUsdtAmountMapping;
    mapping(uint256 => uint256) private ordersKingAmountMapping;
    mapping(uint256 => uint256) private ordersCpeAmountMapping;

    address private usdtAddress;
    address private kingAddress;
    address private cpeAddress;
    address private kswapAddress;
    address private etnAddress;
    address private awardContractAddress;
    address private lssAddress;
    address private lssPoolAddress;

    function setAwardContractAddress(address tempAddress_) external onlyLogic {
        awardContractAddress = tempAddress_;
    }

    function getAwardContractAddress()
        external
        view
        onlyLogic
        returns (address)
    {
        return awardContractAddress;
    }

    function setLssAddress(address tempAddress_) external onlyLogic {
        lssAddress = tempAddress_;
    }

    function getLssAddress() external view onlyLogic returns (address) {
        return lssAddress;
    }

    function setLssPoolAddress(address tempAddress_) external onlyLogic {
        lssPoolAddress = tempAddress_;
    }

    function getLssPoolAddress() external view onlyLogic returns (address) {
        return lssPoolAddress;
    }

    function setOrdersUsdtAmountMapping(uint256 ordersNo_, uint256 amount_)
        external
        onlyLogic
    {
        ordersUsdtAmountMapping[ordersNo_] = amount_;
    }

    function getOrdersUsdtAmountMapping(uint256 ordersNo_)
        external
        view
        onlyLogic
        returns (uint256)
    {
        return ordersUsdtAmountMapping[ordersNo_];
    }

    function setOrdersKingAmountMapping(uint256 ordersNo_, uint256 amount_)
        external
        onlyLogic
    {
        ordersKingAmountMapping[ordersNo_] = amount_;
    }

    function getOrdersKingAmountMapping(uint256 ordersNo_)
        external
        view
        onlyLogic
        returns (uint256)
    {
        return ordersKingAmountMapping[ordersNo_];
    }

    function setOrdersCpeAmountMapping(uint256 ordersNo_, uint256 amount_)
        external
        onlyLogic
    {
        ordersCpeAmountMapping[ordersNo_] = amount_;
    }

    function getOrdersCpeAmountMapping(uint256 ordersNo_)
        external
        view
        onlyLogic
        returns (uint256)
    {
        return ordersCpeAmountMapping[ordersNo_];
    }

    function setUsdtAddress(address tempAddress_) external onlyLogic {
        usdtAddress = tempAddress_;
    }

    function getUsdtAddress() external view onlyLogic returns (address) {
        return usdtAddress;
    }

    function setKingAddress(address tempAddress_) external onlyLogic {
        kingAddress = tempAddress_;
    }

    function getKingAddress() external view onlyLogic returns (address) {
        return kingAddress;
    }

    function setCpeAddress(address tempAddress_) external onlyLogic {
        cpeAddress = tempAddress_;
    }

    function getCpeAddress() external view onlyLogic returns (address) {
        return cpeAddress;
    }

    function setEtnAddress(address tempAddress_) external onlyLogic {
        etnAddress = tempAddress_;
    }

    function getEtnAddress() external view onlyLogic returns (address) {
        return etnAddress;
    }

    function setKswapAddress(address tempAddress_) external onlyLogic {
        kswapAddress = tempAddress_;
    }

    function getKswapAddress() external view onlyLogic returns (address) {
        return kswapAddress;
    }

    constructor() {
        sender = msg.sender;
    }

    modifier onlyMinter() {
        require(msg.sender == sender);
        _;
    }

    modifier onlyLogic() {
        require(allowLogicContractAddress[msg.sender]);
        _;
    }

    function setLogicContractAddress(address tempAddress_) external onlyMinter {
        allowLogicContractAddress[tempAddress_] = true;
        historyLogicContractAddress.push(tempAddress_);
    }

    function removeLogicContractAddress(address tempAddress_)
        external
        onlyMinter
    {
        allowLogicContractAddress[tempAddress_] = false;
    }

    function getLogicContractAddress()
        external
        view
        onlyMinter
        returns (address[] memory)
    {
        address[] memory tempLogicAddress = new address[](
            historyLogicContractAddress.length
        );
        for (uint256 i = 0; i < historyLogicContractAddress.length; i++) {
            if (allowLogicContractAddress[historyLogicContractAddress[i]]) {
                tempLogicAddress[i] = historyLogicContractAddress[i];
            }
        }
        return tempLogicAddress;
    }

    function getHistoryLogicContractAddress()
        external
        view
        onlyMinter
        returns (address[] memory)
    {
        return historyLogicContractAddress;
    }
}
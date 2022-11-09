/**
 *Submitted for verification at BscScan.com on 2022-11-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ShopStore {
    //myself
    address private sender;
    mapping(address => bool) private allowLogicContractAddress;
    address[] private historyLogicContractAddress;

    mapping(address => uint256) private myUsdtAward;
    mapping(address => uint256) private myKingAward;
    mapping(address => uint256) private myCpeAward;

    address private usdtAddress;
    address private kingAddress;
    address private cpeAddress;
    address private kswapAddress;
    address private etnAddress;
    address private platformAddress1;
    address private platformAddress2;
    address private kUnionAddress1;
    address private kUnionAddress2;
    address private kUnionAddress3;
    address private taxAddress;
    address private RecycleEtnAddress;

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

    function setPlatformAddress1(address tempAddress_) external onlyLogic {
        platformAddress1 = tempAddress_;
    }

    function getPlatformAddress1() external view onlyLogic returns (address) {
        return platformAddress1;
    }

    function setPlatformAddress2(address tempAddress_) external onlyLogic {
        platformAddress2 = tempAddress_;
    }

    function getPlatformAddress2() external view onlyLogic returns (address) {
        return platformAddress2;
    }

    function setKUnionAddress1(address tempAddress_) external onlyLogic {
        kUnionAddress1 = tempAddress_;
    }

    function getKUnionAddress1() external view onlyLogic returns (address) {
        return kUnionAddress1;
    }

    function setKUnionAddress2(address tempAddress_) external onlyLogic {
        kUnionAddress2 = tempAddress_;
    }

    function getKUnionAddress2() external view onlyLogic returns (address) {
        return kUnionAddress2;
    }

    function setKUnionAddress3(address tempAddress_) external onlyLogic {
        kUnionAddress3 = tempAddress_;
    }

    function getKUnionAddress3() external view onlyLogic returns (address) {
        return kUnionAddress3;
    }

    function setTaxAddress(address tempAddress_) external onlyLogic {
        taxAddress = tempAddress_;
    }

    function getTaxAddress() external view onlyLogic returns (address) {
        return taxAddress;
    }

    function setRecycleEtnAddress(address tempAddress_) external onlyLogic {
        RecycleEtnAddress = tempAddress_;
    }

    function getRecycleEtnAddress() external view onlyLogic returns (address) {
        return RecycleEtnAddress;
    }

    function setMyUsdtAward(address tempAddress_, uint256 award_)
        external
        onlyLogic
    {
        myUsdtAward[tempAddress_] = award_;
    }

    function getMyUsdtAward(address tempAddress_)
        external
        view
        onlyLogic
        returns (uint256)
    {
        return myUsdtAward[tempAddress_];
    }

    function setMyKingAward(address tempAddress_, uint256 award_)
        external
        onlyLogic
    {
        myKingAward[tempAddress_] = award_;
    }

    function getMyKingAward(address tempAddress_)
        external
        view
        onlyLogic
        returns (uint256)
    {
        return myKingAward[tempAddress_];
    }

    function setMyCpeAward(address tempAddress_, uint256 award_)
        external
        onlyLogic
    {
        myCpeAward[tempAddress_] = award_;
    }

    function getMyCpeAward(address tempAddress_)
        external
        view
        onlyLogic
        returns (uint256)
    {
        return myCpeAward[tempAddress_];
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
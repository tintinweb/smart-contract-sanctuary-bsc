/**
 *Submitted for verification at BscScan.com on 2022-09-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ShopStore {
    //myself
    address private sender;
    mapping(address => bool) private allowLogicContractAddress;
    address[] private historyLogicContractAddress;

    //data
    uint256 private randomNumber = 9999999;
    mapping(address => address) private recommender;
    mapping(uint256 => uint256) private productPrice;
    mapping(uint256 => address) private seller;
    uint256[] private allProuct;
    uint256[] private allOrders;
    mapping(address => uint256[]) private buyOrders;
    mapping(address => uint256[]) private sellerOrders;
    mapping(uint256 => uint256) private id_TokenId;
    mapping(uint256 => uint256) private id_Amount;
    mapping(uint256 => address) private id_Buyer;
    mapping(uint256 => address) private id_Seller;
    mapping(uint256 => uint256) private id_Status;
    mapping(uint256 => uint16) private id_Province;
    mapping(uint256 => uint16) private id_City;
    mapping(uint256 => string) private id_DeliveryName;
    mapping(uint256 => string) private id_DeliveryMobile;
    mapping(uint256 => string) private id_DeliveryAddress;
    mapping(uint256 => string) private id_ExpressNo;
    mapping(uint256 => string) private id_ExpressName;
    mapping(uint256 => uint16) private id_Year;
    mapping(uint256 => uint16) private id_Month;
    mapping(uint256 => uint16) private id_Day;
    address private usdtAddress;
    address private kingAddress;
    address private cpeAddress;
    address private kswapAddress;
    address private etnAddress;
    address private productNftAddress;
    address private swapAddress;
    address private platformAddress;
    address private kUnionAddress;
    address private collection1Address;
    address private collection2Address;
    address private collection3Address;   
    address private collection4Address;
    address private collection5Address;
    address private taxAddress;

    function setRandomNumber(uint256 randomNumber_) external onlyLogic {
        randomNumber = randomNumber_;
    }

    function getRandomNumber() external view onlyLogic returns (uint256) {
        return randomNumber;
    }

    function setRecommender(address tempAddress, address recommender_)
        external
        onlyLogic
    {
        recommender[tempAddress] = recommender_;
    }

    function getRecommender(address tempAddress)
        external
        view
        onlyLogic
        returns (address)
    {
        return recommender[tempAddress];
    }

    function setProductPrice(uint256 tokenId_, uint256 price_)
        external
        onlyLogic
    {
        productPrice[tokenId_] = price_;
    }

    function getProductPrice(uint256 tokenId_)
        external
        view
        onlyLogic
        returns (uint256)
    {
        return productPrice[tokenId_];
    }

    function delProductPrice(uint256 tokenId_) external onlyLogic {
        delete productPrice[tokenId_];
    }

    function setSeller(uint256 tokenId_, address tempAddress_)
        external
        onlyLogic
    {
        seller[tokenId_] = tempAddress_;
    }

    function getSeller(uint256 tokenId_)
        external
        view
        onlyLogic
        returns (address)
    {
        return seller[tokenId_];
    }

    function delSeller(uint256 tokenId_) external onlyLogic {
        delete seller[tokenId_];
    }

    function setAllProuct(uint256 tokenId_) external onlyLogic {
        allProuct.push(tokenId_);
    }

    function getAllProuct() external view onlyLogic returns (uint256[] memory) {
        return allProuct;
    }

    function setAllOrders(uint256 ordersNo_) external onlyLogic {
        allOrders.push(ordersNo_);
    }

    function getAllOrders() external view onlyLogic returns (uint256[] memory) {
        return allOrders;
    }

    function setBuyOrders(address tempAddress_, uint256 ordersNo_)
        external
        onlyLogic
    {
        buyOrders[tempAddress_].push(ordersNo_);
    }

    function getBuyOrders(address tempAddress_)
        external
        view
        onlyLogic
        returns (uint256[] memory)
    {
        return buyOrders[tempAddress_];
    }

    function setSellerOrders(address tempAddress_, uint256 ordersNo)
        external
        onlyLogic
    {
        sellerOrders[tempAddress_].push(ordersNo);
    }

    function getSellerOrders(address tempAddress_)
        external
        view
        onlyLogic
        returns (uint256[] memory)
    {
        return sellerOrders[tempAddress_];
    }

    function setIdTokenId(uint256 ordersNo_, uint256 tokenId_)
        external
        onlyLogic
    {
        id_TokenId[ordersNo_] = tokenId_;
    }

    function getIdTokenId(uint256 ordersNo_)
        external
        view
        onlyLogic
        returns (uint256)
    {
        return id_TokenId[ordersNo_];
    }

    function setIdAmount(uint256 ordersNo_, uint256 amount_)
        external
        onlyLogic
    {
        id_Amount[ordersNo_] = amount_;
    }

    function getIdAmount(uint256 ordersNo_)
        external
        view
        onlyLogic
        returns (uint256)
    {
        return id_Amount[ordersNo_];
    }

    function setIdBuyer(uint256 ordersNo_, address buyer) external onlyLogic {
        id_Buyer[ordersNo_] = buyer;
    }

    function getIdBuyer(uint256 ordersNo_)
        external
        view
        onlyLogic
        returns (address)
    {
        return id_Buyer[ordersNo_];
    }

    function setIdSeller(uint256 ordersNo_, address seller_)
        external
        onlyLogic
    {
        id_Seller[ordersNo_] = seller_;
    }

    function getIdSeller(uint256 ordersNo_)
        external
        view
        onlyLogic
        returns (address)
    {
        return id_Seller[ordersNo_];
    }

    function setIdStatus(uint256 ordersNo_, uint256 status_)
        external
        onlyLogic
    {
        id_Status[ordersNo_] = status_;
    }

    function getIdStatus(uint256 ordersNo_)
        external
        view
        onlyLogic
        returns (uint256)
    {
        return id_Status[ordersNo_];
    }

    function setIdProvince(uint256 ordersNo_, uint16 province_)
        external
        onlyLogic
    {
        id_Province[ordersNo_] = province_;
    }

    function getIdProvince(uint256 ordersNo_)
        external
        view
        onlyLogic
        returns (uint16)
    {
        return id_Province[ordersNo_];
    }

    function setIdCity(uint256 ordersNo_, uint16 city_) external onlyLogic {
        id_City[ordersNo_] = city_;
    }

    function getIdCity(uint256 ordersNo_)
        external
        view
        onlyLogic
        returns (uint16)
    {
        return id_City[ordersNo_];
    }

    function setIdDeliveryName(uint256 ordersNo_, string memory deliveryName_)
        external
        onlyLogic
    {
        id_DeliveryName[ordersNo_] = deliveryName_;
    }

    function getIdDeliveryName(uint256 ordersNo_)
        external
        view
        onlyLogic
        returns (string memory)
    {
        return id_DeliveryName[ordersNo_];
    }

    function setIdDeliveryMobile(uint256 ordersNo_, string memory deliveryName_)
        external
        onlyLogic
    {
        id_DeliveryMobile[ordersNo_] = deliveryName_;
    }

    function getIdDeliveryMobile(uint256 ordersNo_)
        external
        view
        onlyLogic
        returns (string memory)
    {
        return id_DeliveryMobile[ordersNo_];
    }

    function setIdDeliveryAddress(
        uint256 ordersNo_,
        string memory deliveryAddress_
    ) external onlyLogic {
        id_DeliveryAddress[ordersNo_] = deliveryAddress_;
    }

    function getIdDeliveryAddress(uint256 ordersNo_)
        external
        view
        onlyLogic
        returns (string memory)
    {
        return id_DeliveryAddress[ordersNo_];
    }

    function setIdExpressNo(uint256 ordersNo_, string memory expressNo_)
        external
        onlyLogic
    {
        id_ExpressNo[ordersNo_] = expressNo_;
    }

    function getIdExpressNo(uint256 ordersNo_)
        external
        view
        onlyLogic
        returns (string memory)
    {
        return id_ExpressNo[ordersNo_];
    }

    function setIdExpressName(uint256 ordersNo_, string memory expressName_)
        external
        onlyLogic
    {
        id_ExpressName[ordersNo_] = expressName_;
    }

    function getIdExpressName(uint256 ordersNo_)
        external
        view
        onlyLogic
        returns (string memory)
    {
        return id_ExpressName[ordersNo_];
    }

    function setIdYear(uint256 ordersNo_, uint16 year_) external onlyLogic {
        id_Year[ordersNo_] = year_;
    }

    function getIdYear(uint256 ordersNo_)
        external
        view
        onlyLogic
        returns (uint16)
    {
        return id_Year[ordersNo_];
    }

    function setIdMonth(uint256 ordersNo_, uint16 month_) external onlyLogic {
        id_Month[ordersNo_] = month_;
    }

    function getIdMonth(uint256 ordersNo_)
        external
        view
        onlyLogic
        returns (uint16)
    {
        return id_Month[ordersNo_];
    }

    function setIdDay(uint256 ordersNo_, uint16 day_) external onlyLogic {
        id_Day[ordersNo_] = day_;
    }

    function getIdDay(uint256 ordersNo_)
        external
        view
        onlyLogic
        returns (uint16)
    {
        return id_Day[ordersNo_];
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

    function setKswapAddress(address tempAddress_) external onlyLogic {
        kswapAddress = tempAddress_;
    }

    function getKswapAddress() external view onlyLogic returns (address) {
        return kswapAddress;
    }

    function setEtnAddress(address tempAddress_) external onlyLogic {
        etnAddress = tempAddress_;
    }

    function getEtnAddressAddress() external view onlyLogic returns (address) {
        return etnAddress;
    }

    function setProductNftAddress(address tempAddress_) external onlyLogic {
        productNftAddress = tempAddress_;
    }

    function getProductNftAddress() external view onlyLogic returns (address) {
        return productNftAddress;
    }

    function setSwapAddress(address tempAddress_) external onlyLogic {
        swapAddress = tempAddress_;
    }

    function getSwapAddress() external view onlyLogic returns (address) {
        return swapAddress;
    }

    function setPlatformAddress(address tempAddress_) external onlyLogic {
        platformAddress = tempAddress_;
    }

    function getPlatformAddress() external view onlyLogic returns (address) {
        return platformAddress;
    }

    function setKUnionAddress(address tempAddress_) external onlyLogic {
        kUnionAddress = tempAddress_;
    }

    function getKUnionAddress() external view onlyLogic returns (address) {
        return kUnionAddress;
    }

    function setCollection1Address(address tempAddress_) external onlyLogic {
        collection1Address = tempAddress_;
    }

    function getCollection1Address() external view onlyLogic returns (address) {
        return collection1Address;
    }

    function setCollection2Address(address tempAddress_) external onlyLogic {
        collection2Address = tempAddress_;
    }

    function getCollection2Address() external view onlyLogic returns (address) {
        return collection2Address;
    }

    function setCollection3Address(address tempAddress_) external onlyLogic {
        collection3Address = tempAddress_;
    }

    function getCollection3Address() external view onlyLogic returns (address) {
        return collection3Address;
    }

    function setCollection4Address(address tempAddress_) external onlyLogic {
        collection4Address = tempAddress_;
    }

    function getCollection4Address() external view onlyLogic returns (address) {
        return collection4Address;
    }

    function setCollection5Address(address tempAddress_) external onlyLogic {
        collection5Address = tempAddress_;
    }

    function getCollection5Address() external view onlyLogic returns (address) {
        return collection5Address;
    }

    function setTaxAddress(address tempAddress_) external onlyLogic {
        taxAddress = tempAddress_;
    }

    function getTaxAddress() external view onlyLogic returns (address) {
        return taxAddress;
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

    function removeAllProuctByTokenId(uint256 tokenId_) external {
        if (allProuct.length > 0) {
            for (uint256 i = 0; i < allProuct.length; i++) {
                if (tokenId_ == allProuct[i]) {
                    uint256 lastTokenId = allProuct[allProuct.length - 1];
                    allProuct[i] = lastTokenId;
                    allProuct.pop();
                    i = 0;
                }
            }
        }
        if (allProuct.length > 0) {
            if (allProuct[0] == tokenId_) {
                allProuct.pop();
            }
        }
    }
}
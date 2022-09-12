// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Ownable.sol";
import "./IShopStore.sol";

contract Orders is Ownable, ShopStoreContract {
    constructor() {}

    function getOrdersOfBuyCPEInfo(uint256 ordersNo)
        external
        view
        returns (
            uint256,
            address,
            address,
            address,
            address
        )
    {
        address buyer = _getIdBuyer(ordersNo);
        address seller = _getIdSeller(ordersNo);
        return (
            _getIdAmount(ordersNo),
            buyer,
            _getRecommender(buyer),
            seller,
            _getRecommender(seller)
        );
    }

    function getMyBuyOrdersNo() external view returns (uint256[] memory) {
        return _getBuyOrders(msg.sender);
    }

    function getMySellOrdersNoByStatus(uint256 status)
        external
        view
        returns (uint256[] memory)
    {
        require(status > 0);
        uint256 j = 0;
        uint256[] memory tempSellerOrders = _getSellerOrders(msg.sender);
        for (uint256 i = 0; i < tempSellerOrders.length; i++) {
            if (_getIdStatus(tempSellerOrders[i]) == status) {
                j++;
            }
        }
        uint256[] memory tempOrdersNo = new uint256[](j);
        j = 0;
        for (uint256 i = 0; i < tempSellerOrders.length; i++) {
            if (_getIdStatus(tempSellerOrders[i]) == status) {
                tempOrdersNo[j] = tempSellerOrders[i];
                j++;
            }
        }
        return tempOrdersNo;
    }

    function getOrdersBaseInfo(uint256 ordersNo)
        external
        view
        returns (
            uint256,
            uint256,
            address,
            address,
            uint256
        )
    {
        require(ordersNo > 0);
        require(_getIdTokenId(ordersNo) > 0);
        require(
            (_getIdSeller(ordersNo) == msg.sender ||
                _getIdBuyer(ordersNo) == msg.sender ||
                _getSender() == msg.sender)
        );
        return (
            _getIdTokenId(ordersNo),
            _getIdAmount(ordersNo),
            _getIdBuyer(ordersNo),
            _getIdSeller(ordersNo),
            _getIdStatus(ordersNo)
        );
    }

    function getOrdersDeliveryInfo(uint256 ordersNo)
        external
        view
        returns (
            uint256,
            uint256,
            string memory,
            string memory,
            string memory
        )
    {
        require(ordersNo > 0);
        require(_getIdTokenId(ordersNo) > 0);
        require(
            (_getIdSeller(ordersNo) == msg.sender ||
                _getIdBuyer(ordersNo) == msg.sender ||
                _getSender() == msg.sender)
        );
        return (
            _getIdProvince(ordersNo),
            _getIdCity(ordersNo),
            _getIdDeliveryName(ordersNo),
            _getIdDeliveryMobile(ordersNo),
            _getIdDeliveryAddress(ordersNo)
        );
    }

    function getOrdersExpressInfo(uint256 ordersNo)
        external
        view
        returns (string memory, string memory)
    {
        require(ordersNo > 0);
        require(_getIdTokenId(ordersNo) > 0);
        require(
            (_getIdSeller(ordersNo) == msg.sender ||
                _getIdBuyer(ordersNo) == msg.sender ||
                _getSender() == msg.sender)
        );
        return (_getIdExpressNo(ordersNo), _getIdExpressName(ordersNo));
    }

    function getOrdersDateInfo(uint256 ordersNo)
        external
        view
        returns (
            uint16,
            uint16,
            uint16
        )
    {
        require(ordersNo > 0);
        require(_getIdTokenId(ordersNo) > 0);
        require(
            (_getIdSeller(ordersNo) == msg.sender ||
                _getIdBuyer(ordersNo) == msg.sender ||
                _getSender() == msg.sender)
        );
        return (
            _getIdYear(ordersNo),
            _getIdMonth(ordersNo),
            _getIdDay(ordersNo)
        );
    }

    function getAllOrders()
        external
        view
        onlyMinter
        returns (uint256[] memory)
    {
        return _getAllOrders();
    }

    function getSellData(
        uint16 province,
        uint16 city,
        uint16 year,
        uint16 month,
        uint16 day
    ) external view onlyMinter returns (uint256) {
        uint256 total = 0;
        uint256[] memory tempAllOrders = _getAllOrders();
        for (uint256 i = 0; i < tempAllOrders.length; i++) {
            if (province != 0 && province != _getIdProvince(tempAllOrders[i])) {
                continue;
            }
            if (city != 0 && city != _getIdCity(tempAllOrders[i])) {
                continue;
            }
            if (year != 0 && year != _getIdYear(tempAllOrders[i])) {
                continue;
            }
            if (month != 0 && month != _getIdMonth(tempAllOrders[i])) {
                continue;
            }
            if (day != 0 && day != _getIdDay(tempAllOrders[i])) {
                continue;
            }
            total += _getIdAmount(tempAllOrders[i]);
        }
        return total;
    }

    function setExpressInfo(
        uint256 ordersNo,
        string memory expressNo,
        string memory expressName
    ) external returns (bool) {
        require(ordersNo > 0);
        require(_getIdTokenId(ordersNo) > 0);
        require(_getIdSeller(ordersNo) == msg.sender);
        require(bytes(expressNo).length != 0);
        require(bytes(expressName).length != 0);        
        _setIdExpressNo(ordersNo, expressNo);
        _setIdExpressName(ordersNo, expressName);
        _setIdStatus(ordersNo, 20);
        return true;
    }

    function setRecommender(address recommenderAddress)
        external
        returns (bool)
    {
        require(_getRecommender(msg.sender) == address(0));
        _setRecommender(msg.sender, recommenderAddress);
        return true;
    }

    function getRecommender(address tempAddress)
        external
        view
        returns (address)
    {
        return _getRecommender(tempAddress);
    }
}
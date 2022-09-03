// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IShop.sol";
import "./USDTContract.sol";
import "./UContract.sol";
import "./KingContract.sol";
import "./ArrayUtil.sol";
import "./DateTimeUtil.sol";
import "./EtnContract.sol";
import "./ProductNftContract.sol";
import "./SwapContract.sol";
import "./BaseSetContract.sol";
import "./SafeMath.sol";
import "./KSWAPContract.sol";

contract Shop is
    IShop,
    Ownable,
    UContract,
    USDTContract,
    KingContract,
    EtnContract,
    ProductNftContract,
    SwapContract,
    BaseSetContract,
    KSWAPContract
{
    using ArrayUtil for uint256[];
    using DateTimeUtil for uint256;
    using AddressTool for address;
    using SafeMath for uint256;
    uint256 private _randomNumber = 9999999;
    mapping(address => address) private _recommender;
    mapping(uint256 => uint256) private _productPrice;
    mapping(uint256 => address) private _seller;
    uint256[] private _allProuct;
    uint256[] private _allOrders;
    mapping(address => uint256[]) private _buyOrders;
    mapping(address => uint256[]) private _sellerOrders;
    mapping(uint256 => uint256) private _Id_TokenId;
    mapping(uint256 => uint256) private _Id_Amount;
    mapping(uint256 => address) private _Id_Buyer;
    mapping(uint256 => address) private _Id_Seller;
    mapping(uint256 => uint256) private _Id_Status;
    mapping(uint256 => uint16) private _Id_Province;
    mapping(uint256 => uint16) private _Id_City;
    mapping(uint256 => string) private _Id_DeliveryName;
    mapping(uint256 => string) private _Id_DeliveryMobile;
    mapping(uint256 => string) private _Id_DeliveryAddress;
    mapping(uint256 => string) private _Id_ExpressNo;
    mapping(uint256 => string) private _Id_ExpressName;
    mapping(uint256 => uint16) private _Id_Year;
    mapping(uint256 => uint16) private _Id_Month;
    mapping(uint256 => uint16) private _Id_Day;

    constructor() {
        address temp;
        _approveUSDT(temp._getKswapAddress());
        _approveU(temp._getKswapAddress());
        _approveKing(temp._getKswapAddress());
        _approveUSDT(temp._getSWAPAddress());
    }

    function setRecommender(address recommenderAddress)
        external
        override
        returns (bool)
    {
        require(_recommender[msg.sender] == address(0));
        _recommender[msg.sender] = recommenderAddress;
        return true;
    }

    function getRecommender(address tempAddress)
        external
        view
        override
        returns (address)
    {
        return _recommender[tempAddress];
    }

    function offProduct(uint256 tokenId) external override returns (bool) {
        require(tokenId > 0);
        delete _productPrice[tokenId];
        delete _seller[tokenId];
        _allProuct.removeByTokenId(tokenId);
        return true;
    }

    function onProduct(uint256 tokenId, uint256 price)
        external
        override
        returns (bool)
    {
        require(tokenId > 0);
        require(price >= 50000000000000000000);
        require(_productPrice[tokenId] == 0);
        address nftOwner = _ownerOfProductNFT(tokenId);
        require(nftOwner == msg.sender);
        _productPrice[tokenId] = price;
        _seller[tokenId] = msg.sender;
        _allProuct.push(tokenId);
        return true;
    }

    function getAllSellProduct(uint256 pageIndex, uint256 pageMax)
        external
        view
        override
        returns (uint256[] memory, uint256[] memory)
    {
        require(pageIndex > 0);
        require(pageMax > 0);
        uint256 size = _allProuct.length;
        uint256 startNumber = (pageIndex - 1) * pageMax;
        require(size > startNumber);
        uint256 endNumber = startNumber + pageMax;
        if (endNumber > size) {
            endNumber = size;
        }
        uint256[] memory tokenIds = new uint256[](endNumber - startNumber);
        uint256[] memory prices = new uint256[](endNumber - startNumber);
        uint256 j = 0;
        for (uint256 i = startNumber; i < endNumber; i++) {
            tokenIds[j] = _allProuct[i];
            prices[j] = _productPrice[tokenIds[j]];
            j++;
        }
        return (tokenIds, prices);
    }

    function buyProduct(
        uint256 tokenId,
        uint16 province,
        uint16 city,
        string memory deliveryName,
        string memory deliveryMobile,
        string memory deliveryAddress
    ) external override returns (bool) {
        require(_productPrice[tokenId] > 0);
        isBaseSet();
        require(_recommender[_seller[tokenId]] != address(0));
        require(_recommender[msg.sender] != address(0));
        uint256 price = _productPrice[tokenId];
        require(_balanceOfUSDT(msg.sender) >= price);
        require(_allowanceUSDT(msg.sender, address(this)) >= price);
        address sellAddress = _seller[tokenId];
        {
            _transferFromUSDT(msg.sender, address(this), price);
            _transferUSDT(sellAddress, (price * 500000) / 1000000);
            uint256 usdtToKingAmount = (price * 100000) / 1000000;
            uint256 kingAmount = _UsdtToKing(usdtToKingAmount);
            _transferKing(sellAddress, (kingAmount * 10000) / 1000000);
            _transferKing(getPlatformAddress(), (kingAmount * 10000) / 1000000);
            _transferKing(getKUnionAddress(), (kingAmount * 80000) / 1000000);
            uint256 usdtToEtnAmount = (price * 100000) / 1000000;
            uint256 etnAmount = _UsdtToEtn(usdtToEtnAmount);
            _transferEtn(
                getCollectionAddress(),
                (etnAmount * 994000) / 1000000
            );
            usdtToEtnAmount = (price * 20000) / 1000000;
            etnAmount = _UsdtToEtn(usdtToEtnAmount);
            _transferEtn(getStakingAddress(), (etnAmount * 994000) / 1000000);
            uint256 usdtToUAmount = (price * 30000) / 1000000;
            uint256 uAmount = _UsdtToU(usdtToUAmount);
            _transferU(getTaxAddress(), uAmount);
        }
        {
            uint256 ordersNo = _getRandom();
            _Id_TokenId[ordersNo] = tokenId;
            _Id_Status[ordersNo] = 10;
            _Id_Amount[ordersNo] = price;
            _Id_Buyer[ordersNo] = msg.sender;
            _Id_Seller[ordersNo] = sellAddress;
            _allOrders.push(ordersNo);
            _buyOrders[msg.sender].push(ordersNo);
            _sellerOrders[sellAddress].push(ordersNo);
            _Id_Province[ordersNo] = province;
            _Id_City[ordersNo] = city;
            _Id_DeliveryName[ordersNo] = deliveryName;
            _Id_DeliveryMobile[ordersNo] = deliveryMobile;
            _Id_DeliveryAddress[ordersNo] = deliveryAddress;
            _Id_Year[ordersNo] = block.timestamp.getYear();
            _Id_Month[ordersNo] = block.timestamp.getMonth();
            _Id_Day[ordersNo] = block.timestamp.getDay();
            _buyCPE(ordersNo);
        }
        return true;
    }

    function getOrdersOfBuyCPEInfo(uint256 ordersNo)
        external
        view
        override
        returns (
            uint256,
            address,
            address,
            address,
            address
        )
    {
        address buyer = _Id_Buyer[ordersNo];
        address seller = _Id_Seller[ordersNo];
        return (
            _Id_Amount[ordersNo],
            buyer,
            _recommender[buyer],
            seller,
            _recommender[seller]
        );
    }

    function getMyBuyOrdersNo()
        external
        view
        override
        returns (uint256[] memory)
    {
        return _buyOrders[msg.sender];
    }

    function getMySellOrdersNoByStatus(uint256 status)
        external
        view
        override
        returns (uint256[] memory)
    {
        require(status > 0);
        uint256 j = 0;
        for (uint256 i = 0; i < _sellerOrders[msg.sender].length; i++) {
            if (_Id_Status[_sellerOrders[msg.sender][i]] == status) {
                j++;
            }
        }
        uint256[] memory tempOrdersNo = new uint256[](j);
        j = 0;
        for (uint256 i = 0; i < _sellerOrders[msg.sender].length; i++) {
            if (_Id_Status[_sellerOrders[msg.sender][i]] == status) {
                tempOrdersNo[j] = _sellerOrders[msg.sender][i];
                j++;
            }
        }
        return tempOrdersNo;
    }

    function getOrdersBaseInfo(uint256 ordersNo)
        external
        view
        override
        returns (
            uint256,
            uint256,
            address,
            address,
            uint256
        )
    {
        require(ordersNo > 0);
        require(_Id_TokenId[ordersNo] > 0);
        require(
            (_Id_Seller[ordersNo] == msg.sender ||
                _Id_Buyer[ordersNo] == msg.sender ||
                _getSender() == msg.sender)
        );
        return (
            _Id_TokenId[ordersNo],
            _Id_Amount[ordersNo],
            _Id_Buyer[ordersNo],
            _Id_Seller[ordersNo],
            _Id_Status[ordersNo]
        );
    }

    function getOrdersDeliveryInfo(uint256 ordersNo)
        external
        view
        override
        returns (
            uint256,
            uint256,
            string memory,
            string memory,
            string memory
        )
    {
        require(ordersNo > 0);
        require(_Id_TokenId[ordersNo] > 0);
        require(
            (_Id_Seller[ordersNo] == msg.sender ||
                _Id_Buyer[ordersNo] == msg.sender ||
                _getSender() == msg.sender)
        );
        return (
            _Id_Province[ordersNo],
            _Id_City[ordersNo],
            _Id_DeliveryName[ordersNo],
            _Id_DeliveryMobile[ordersNo],
            _Id_DeliveryAddress[ordersNo]
        );
    }

    function getOrdersExpressInfo(uint256 ordersNo)
        external
        view
        override
        returns (string memory, string memory)
    {
        require(ordersNo > 0);
        require(_Id_TokenId[ordersNo] > 0);
        require(
            (_Id_Seller[ordersNo] == msg.sender ||
                _Id_Buyer[ordersNo] == msg.sender ||
                _getSender() == msg.sender)
        );
        return (_Id_ExpressNo[ordersNo], _Id_ExpressName[ordersNo]);
    }

    function getOrdersDateInfo(uint256 ordersNo)
        external
        view
        override
        returns (
            uint16,
            uint16,
            uint16
        )
    {
        require(ordersNo > 0);
        require(_Id_TokenId[ordersNo] > 0);
        require(
            (_Id_Seller[ordersNo] == msg.sender ||
                _Id_Buyer[ordersNo] == msg.sender ||
                _getSender() == msg.sender)
        );
        return (_Id_Year[ordersNo], _Id_Month[ordersNo], _Id_Day[ordersNo]);
    }

    function getAllOrders()
        external
        view
        override
        onlyMinter
        returns (uint256[] memory)
    {
        return _allOrders;
    }

    function getSellData(
        uint16 province,
        uint16 city,
        uint16 year,
        uint16 month,
        uint16 day
    ) external view override onlyMinter returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < _allOrders.length; i++) {
            if (province != 0 && province != _Id_Province[_allOrders[i]]) {
                continue;
            }
            if (city != 0 && city != _Id_City[_allOrders[i]]) {
                continue;
            }
            if (year != 0 && year != _Id_Year[_allOrders[i]]) {
                continue;
            }
            if (month != 0 && month != _Id_Month[_allOrders[i]]) {
                continue;
            }
            if (day != 0 && day != _Id_Day[_allOrders[i]]) {
                continue;
            }
            total += _Id_Amount[_allOrders[i]];
        }
        return total;
    }

    function setExpressInfo(
        uint256 ordersNo,
        string memory expressNo,
        string memory expressName
    ) external override returns (bool) {
        require(ordersNo > 0);
        require(_Id_TokenId[ordersNo] > 0);
        require(_Id_Seller[ordersNo] == msg.sender);
        require(bytes(expressNo).length != 0);
        require(bytes(expressName).length != 0);
        _Id_ExpressNo[ordersNo] = expressNo;
        _Id_ExpressName[ordersNo] = expressName;
        _Id_Status[ordersNo] = 20;
        return true;
    }

    function _getRandom() internal returns (uint256) {
        _randomNumber = _randomNumber + 1;
        uint256 timestamp = block.timestamp;
        uint256 coinbase = uint256(
            keccak256(abi.encodePacked(block.coinbase))
        ) / timestamp;
        uint256 sender = uint256(keccak256(abi.encodePacked(msg.sender))) /
            timestamp;
        uint256 number = block.number;
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        timestamp,
                        block.difficulty,
                        coinbase,
                        block.gaslimit,
                        sender,
                        number,
                        _randomNumber
                    )
                )
            );
    }

    function _UsdtToU(uint256 usdtAmount) internal returns (uint256) {
        uint256 amountOut = _get_Usdt_U_AmountsOut(usdtAmount);
        uint256 amountOutMin = amountOut.mul(950000).div(1000000);
        uint256[] memory amounts = _swap_Usdt_U_ExactTokensForTokens(
            usdtAmount,
            amountOutMin,
            address(this)
        );
        return amounts[1];
    }

    function _UsdtToKing(uint256 usdtAmount) internal returns (uint256) {
        uint256 amountUOut = _UsdtToU(usdtAmount);
        uint256 amountOut = _get_U_King_AmountsOut(amountUOut);
        uint256 amountOutMin = amountOut.mul(950000).div(1000000);
        uint256[] memory amounts = _swap_U_King_ExactTokensForTokens(
            amountUOut,
            amountOutMin,
            address(this)
        );
        return amounts[1];
    }

    function _UsdtToEtn(uint256 usdtAmount) internal returns (uint256) {
        uint256 amountKingOut = _UsdtToKing(usdtAmount);
        uint256 amountOut = _get_King_Etn_AmountsOut(amountKingOut);
        uint256 amountOutMin = amountOut.mul(950000).div(1000000);
        uint256[] memory amounts = _swap_King_Etn_ExactTokensForTokens(
            amountKingOut,
            amountOutMin,
            address(this)
        );
        return amounts[1];
    }
}
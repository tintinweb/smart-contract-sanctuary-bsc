// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./USDTContract.sol";
import "./KingContract.sol";
import "./DateTimeUtil.sol";
import "./ProductNftContract.sol";
import "./SwapContract.sol";
import "./BaseSetContract.sol";
import "./SafeMath.sol";
import "./KSWAPContract.sol";

contract Shop is
    USDTContract,
    KingContract,
    ProductNftContract,
    SwapContract,
    BaseSetContract,
    KSWAPContract
{
    using DateTimeUtil for uint256;
    using SafeMath for uint256;

    constructor() {}

    function approveKswap() external onlyMinter {
        address kswap = _getKswapAddress();
        _approveUSDT(kswap);
        _approveKing(kswap);
        _approveUSDT(_getSwapAddress());
    }

    function offProduct(uint256 tokenId) external returns (bool) {
        require(tokenId > 0);
        _delProductPrice(tokenId);
        _delSeller(tokenId);
        _removeAllProuctByTokenId(tokenId);
        return true;
    }

    function onProduct(uint256 tokenId, uint256 price) external returns (bool) {
        require(tokenId > 0);
        require(price >= 50000000000000000000);
        require(_getProductPrice(tokenId) == 0);
        address nftOwner = _ownerOfProductNFT(tokenId);
        require(nftOwner == msg.sender);
        _setProductPrice(tokenId, price);
        _setSeller(tokenId, msg.sender);
        _setAllProuct(tokenId);
        return true;
    }

    function getAllSellProduct(uint256 pageIndex, uint256 pageMax)
        external
        view
        returns (uint256[] memory, uint256[] memory)
    {
        require(pageIndex > 0);
        require(pageMax > 0);
        uint256[] memory tempAllProduct = _getAllProuct();
        uint256 size = tempAllProduct.length;
        uint256 startNumber = (pageIndex - 1) * pageMax;
        uint256 endNumber = startNumber + pageMax;
        if (endNumber > size) {
            endNumber = size;
        }
        uint256[] memory tokenIds = new uint256[](endNumber - startNumber);
        uint256[] memory prices = new uint256[](endNumber - startNumber);
        uint256 j = 0;
        for (uint256 i = startNumber; i < endNumber; i++) {
            tokenIds[j] = tempAllProduct[i];
            prices[j] = _getProductPrice(tokenIds[j]);
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
    ) external {
        require(_getProductPrice(tokenId) > 0);
        isBaseSet();
        require(_getRecommender(_getSeller(tokenId)) != address(0));
        require(_getRecommender(msg.sender) != address(0));
        uint256 price = _getProductPrice(tokenId);
        require(_balanceOfUSDT(msg.sender) >= price);
        address sellAddress = _getSeller(tokenId);
        {
            _transferFromUSDT(msg.sender, address(this), price);
            _transferUSDT(sellAddress, (price * 500000) / 1000000);
            uint256 usdtToKingAmount = (price * 100000) / 1000000;
            uint256 kingAmount = _UsdtToKing(usdtToKingAmount);
            _transferKing(sellAddress, (kingAmount * 10000) / 1000000);
            _transferKing(
                _getPlatformAddress(),
                (kingAmount * 10000) / 1000000
            );
            _transferKing(_getKUnionAddress(), (kingAmount * 80000) / 1000000);
            usdtToKingAmount = (price * 120000) / 1000000;
            kingAmount = _UsdtToKing(usdtToKingAmount);
            _transferKing(
                _getCollection1Address(),
                (kingAmount * 600000) / 1200000
            );
            _transferKing(
                _getCollection2Address(),
                (kingAmount * 300000) / 1200000
            );
            _transferKing(
                _getCollection3Address(),
                (kingAmount * 300000) / 1200000
            );
            uint256 usdtAmount = (price * 30000) / 1000000;
            _transferUSDT(_getTaxAddress(), usdtAmount);
        }
        {
            uint256 r = _getRandomNumber() + 1;
            _setRandomNumber(r);
            uint256 ordersNo = r.getRandom();
            _setIdTokenId(ordersNo, tokenId);
            _setIdStatus(ordersNo, 10);
            _setIdAmount(ordersNo, price);
            _setIdBuyer(ordersNo, msg.sender);
            _setIdSeller(ordersNo, sellAddress);
            _setAllOrders(ordersNo);
            _setBuyOrders(msg.sender, ordersNo);
            _setSellerOrders(sellAddress, ordersNo);
            _setIdProvince(ordersNo, province);
            _setIdCity(ordersNo, city);
            _setIdDeliveryName(ordersNo, deliveryName);
            _setIdDeliveryMobile(ordersNo, deliveryMobile);
            _setIdDeliveryAddress(ordersNo, deliveryAddress);
            _setIdYear(ordersNo, block.timestamp.getYear());
            _setIdMonth(ordersNo, block.timestamp.getMonth());
            _setIdDay(ordersNo, block.timestamp.getDay());
            _buyCPE(ordersNo);
        }
    }

    function _UsdtToKing(uint256 usdtAmount) internal returns (uint256) {
        uint256 amountOut = _get_Usdt_King_AmountsOut(usdtAmount);
        uint256 amountOutMin = amountOut.mul(950000).div(1000000);
        uint256[] memory amounts = _swap_Usdt_King_ExactTokensForTokens(
            usdtAmount,
            amountOutMin,
            address(this)
        );
        return amounts[1].mul(950000).div(1000000);
    }
}
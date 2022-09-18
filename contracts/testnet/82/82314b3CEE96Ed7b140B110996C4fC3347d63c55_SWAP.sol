// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./USDTContract.sol";
import "./KSWAPContract.sol";
import "./SafeMath.sol";
import "./CPEContract.sol";
import "./KingContract.sol";
import "./Ownable.sol";
import "./ShopContract.sol";

contract SWAP is
    KSWAPContract,
    USDTContract,
    CPEContract,
    KingContract,
    Ownable,
    ShopContract
{
    using SafeMath for uint256;

    constructor() {}

    function approveKswap() external onlyMinter {
        _approveUSDT(_getKswapAddress());
    }

    function initPool(uint256 usdtAmount) external onlyMinter returns (bool) {
        require(usdtAmount > 0);
        require(_getBusinessBuyCnt() == 0, "not Cnt");
        _transferFromUSDT(msg.sender, address(this), usdtAmount);
        uint256 kingAmount = _UsdtToKing(usdtAmount);
        address cpeSender = _getSenderCPE();
        _transferFromCPE(cpeSender, msg.sender, usdtAmount);
        _transferKing(_getSender(), kingAmount);
        _setKTotal(_getKTotal().add(kingAmount));
        _setCpeTotal(_getCpeTotal().add(usdtAmount));
        _setBusinessBuyCnt(_getBusinessBuyCnt().add(1));
        _setBuyRecord(
            msg.sender,
            usdtAmount,
            kingAmount.mul(1000000).div(usdtAmount),
            kingAmount
        );
        return true;
    }

    function getCurrentPrice() external view returns (uint256) {
        if (_getCpeTotal() == 0) {
            return 0;
        } else {
            return _getKTotal().mul(1000000).div(_getCpeTotal());
        }
    }

    function getKTotal() external view returns (uint256) {
        return _getKTotal();
    }

    function getCPETotal() external view returns (uint256) {
        return _getCpeTotal();
    }

    function getHistoryBuyOrderTotal() external view returns (uint256) {
        return _getBuyRecord(msg.sender).length;
    }

    function getHistoryBuyOrder(uint256 pageIndex, uint256 pageMax)
        external
        view
        returns (ISwapStore.Orders[] memory)
    {
        require(pageIndex > 0);
        require(pageMax > 0);
        ISwapStore.Orders[] memory tempOrders;
        {
            uint256 startNumber = (pageIndex - 1) * pageMax;
            uint256 endNumber = startNumber + pageMax;
            uint256 size = _getBuyRecord(msg.sender).length;
            if (size <= startNumber) {
                return tempOrders;
            }
            if (endNumber > size) {
                endNumber = size;
            }
            tempOrders = new ISwapStore.Orders[](endNumber - startNumber);
            uint256 j = 0;
            ISwapStore.Orders[] memory myTempOrders = _getBuyRecord(msg.sender);
            for (uint256 i = startNumber; i < endNumber; i++) {
                tempOrders[j] = myTempOrders[i];
                j++;
            }
        }
        return tempOrders;
    }

    function getHistorySellOrderTotal() external view returns (uint256) {
        return _getSellRecord(msg.sender).length;
    }

    function getHistorySellOrder(uint256 pageIndex, uint256 pageMax)
        external
        view
        returns (ISwapStore.Orders[] memory)
    {
        require(pageIndex > 0);
        require(pageMax > 0);
        ISwapStore.Orders[] memory tempOrders;
        {
            uint256 startNumber = (pageIndex - 1) * pageMax;
            uint256 endNumber = startNumber + pageMax;
            uint256 size = _getSellRecord(msg.sender).length;
            if (size <= startNumber) {
                return tempOrders;
            }
            if (endNumber > size) {
                endNumber = size;
            }
            tempOrders = new ISwapStore.Orders[](endNumber - startNumber);
            ISwapStore.Orders[] memory myTempOrders = _getSellRecord(
                msg.sender
            );
            uint256 j = 0;
            for (uint256 i = startNumber; i < endNumber; i++) {
                tempOrders[j] = myTempOrders[i];
                j++;
            }
        }
        return tempOrders;
    }

    function sellCPE(uint256 amount) external returns (bool) {
        require(amount > 0);
        require(_getProject1Address() != address(0));
        require(_getProject2Address() != address(0));
        uint256 balanceCPE = _balanceOfCPE(msg.sender);
        require(balanceCPE >= amount, "Insufficient balance");
        uint256 poolKing = _getKTotal();
        uint256 cepPrice = _getCurrentPrice();
        uint256 kAmount = amount.mul(900000).mul(cepPrice).div(1000000).div(
            1000000
        );
        require(poolKing >= kAmount, "Insufficient balance Pool");
        address cpeSender = _getSenderCPE();
        _transferFromCPE(
            msg.sender,
            cpeSender,
            amount.mul(970000).div(1000000)
        );
        _transferFromCPE(
            msg.sender,
            _getProject1Address(),
            amount.mul(15000).div(1000000)
        );
        _transferFromCPE(
            msg.sender,
            _getProject2Address(),
            amount.mul(15000).div(1000000)
        );
        _transferFromKing(_getSender(), msg.sender, kAmount);
        _setKTotal(_getKTotal().sub(kAmount));
        _setCpeTotal(_getCpeTotal().sub(amount.mul(970000).div(1000000)));
        _setSellRecord(
            msg.sender,
            amount,
            kAmount.mul(1000000).div(amount),
            kAmount
        );
        return true;
    }

    function buyCPE(uint256 ordersNo) external returns (bool) {
        require(ordersNo > 0, "ordersNo error");
        require(_getShopOrders(ordersNo) == 0);
        _setShopOrders(ordersNo, 1);
        require(_getProject1Address() != address(0));
        require(_getProject2Address() != address(0));
        (
            uint256 ordersAmount,
            address buyerAddress,
            address recommenderAddress,
            address businessAddress,
            address businessRecommenderAddress
        ) = _getOrdersOfBuyCPEInfo(ordersNo);
        require(ordersAmount > 0, "ordersAmount not Exists");
        require(buyerAddress != address(0), "buyerAddress not Exists");
        require(
            recommenderAddress != address(0),
            "recommenderAddress not Exists"
        );
        require(businessAddress != address(0), "businessAddress not Exists");
        require(
            businessRecommenderAddress != address(0),
            "businessRecommenderAddress not Exists"
        );
        uint256 usdtAmount = ordersAmount.mul(250000).div(1000000);
        address cpeSender = _getSenderCPE();
        _transferFromUSDT(msg.sender, address(this), usdtAmount);
        uint256 kingAmount = _UsdtToKing(usdtAmount);
        uint256 cpePrice = _getCurrentPrice();
        uint256 cpeAmount = kingAmount.mul(1000000).div(cpePrice);
        uint256 mySelfNumber = cpeAmount.mul(688000).div(1000000);
        _transferKing(_getSender(), kingAmount);
        _transferFromCPE(cpeSender, buyerAddress, mySelfNumber);
        if (recommenderAddress != address(0)) {
            _transferFromCPE(
                cpeSender,
                recommenderAddress,
                cpeAmount.mul(172000).div(1000000)
            );
        }
        _transferFromCPE(
            cpeSender,
            businessAddress,
            cpeAmount.mul(30000).div(1000000)
        );
        if (businessRecommenderAddress != address(0)) {
            _transferFromCPE(
                cpeSender,
                businessRecommenderAddress,
                cpeAmount.mul(10000).div(1000000)
            );
        }
        _transferFromCPE(
            cpeSender,
            _getProject1Address(),
            cpeAmount.mul(15000).div(1000000)
        );
        _transferFromCPE(
            cpeSender,
            _getProject2Address(),
            cpeAmount.mul(15000).div(1000000)
        );
        _setKTotal(_getKTotal().add(kingAmount));
        _setCpeTotal(_getCpeTotal().add(cpeAmount.mul(930000).div(1000000)));
        _setBuyRecord(
            buyerAddress,
            mySelfNumber,
            kingAmount.mul(1000000).div(mySelfNumber),
            kingAmount
        );
        return true;
    }

    function setProject1Address(address project1Address)
        external
        onlyMinter
        returns (bool)
    {
        _setProject1Address(project1Address);
        return true;
    }

    function setProject2Address(address project2Address)
        external
        onlyMinter
        returns (bool)
    {
        _setProject2Address(project2Address);
        return true;
    }

    function setUsdtAddress(address tempAddress_) external onlyMinter {
        _setUsdtAddress(tempAddress_);
    }

    function getUsdtAddress() external view onlyMinter returns (address) {
        return _getUsdtAddress();
    }

    function setKingAddress(address tempAddress_) external onlyMinter {
        _setKingAddress(tempAddress_);
    }

    function getKingAddress() external view onlyMinter returns (address) {
        return _getKingAddress();
    }

    function setCpeAddress(address tempAddress_) external onlyMinter {
        _setCpeAddress(tempAddress_);
    }

    function getCpeAddress() external view onlyMinter returns (address) {
        return _getCpeAddress();
    }

    function setKswapAddress(address tempAddress_) external onlyMinter {
        _setKswapAddress(tempAddress_);
    }

    function getKswapAddress() external view onlyMinter returns (address) {
        return _getKswapAddress();
    }

    function setShopAddress(address tempAddress_) external onlyMinter {
        _setShopAddress(tempAddress_);
    }

    function getShopAddress() external view onlyMinter returns (address) {
        return _getShopAddress();
    }

    function _getCurrentPrice() internal view returns (uint256) {
        if (_getCpeTotal() == 0) {
            return 0;
        } else {
            return _getKTotal().mul(1000000).div(_getCpeTotal());
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
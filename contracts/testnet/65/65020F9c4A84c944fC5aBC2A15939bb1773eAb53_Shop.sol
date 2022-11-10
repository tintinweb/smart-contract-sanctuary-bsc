// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./BaseSetContract.sol";
import "./KSWAPContract.sol";
import "./IERC20.sol";
import "./ISwapStore.sol";

contract Shop is BaseSetContract, KSWAPContract, SwapStoreContract {
    constructor() {}

    function approveKswap() external onlyMinter {
        uint256 amount = 115792089237316195423570985008687907853269984665640564039454584007913129639935;
        address kswap = _getKswapAddress();
        IERC20(_getUsdtAddress()).approve(kswap, amount);
        IERC20(_getKingAddress()).approve(kswap, amount);
    }

    function getToken(address tokenAddress_, uint256 amount_)
        external
        onlyMinter
    {
        uint256 amount = IERC20(tokenAddress_).balanceOf(address(this));
        require(amount >= amount_);
        IERC20(tokenAddress_).transfer(_getSender(), amount_);
    }

    function payUsdt(
        uint256 ordersNo,
        uint256 totalAmount,
        address recommenderAddress,
        address[] memory sellAddress,
        uint256[] memory amounts,
        address[] memory businessRecommenderAddress
    ) external {
        require(ordersNo > 0);
        require(totalAmount > 0);
        require(recommenderAddress != address(0));
        require(sellAddress.length > 0);
        require(amounts.length > 0);
        require(businessRecommenderAddress.length > 0);
        require(IERC20(_getUsdtAddress()).balanceOf(msg.sender) >= totalAmount);
        require(_getOrdersUsdtAmountMapping(ordersNo) == 0);
        require(_getOrdersAmount(amounts) == totalAmount);
        _setOrdersUsdtAmountMapping(ordersNo, totalAmount);
        IERC20(_getUsdtAddress()).transferFrom(
            msg.sender,
            address(this),
            totalAmount
        );
        uint256 usdtToKingAmount = (totalAmount * 4700000) / 10000000;
        uint256 kingAmount = _UsdtToKing(usdtToKingAmount);
        uint256 kingToCpeAmount = (kingAmount * 2500000) / 4700000;
        uint256 cpePrice = _getCurrentPrice();
        uint256 cpeAmount = (kingToCpeAmount * 1000000) / cpePrice;
        _setKTotal(_getKTotal() + kingToCpeAmount);
        _setCpeTotal(_getCpeTotal() + ((cpeAmount * 930000) / 1000000));
        for (uint256 i = 0; i < sellAddress.length; i++) {
            _addMyUsdtAward(sellAddress[i], (amounts[i] * 500000) / 1000000);
            _addMyKingAward(
                sellAddress[i],
                ((kingAmount * 100000) * (amounts[i] / totalAmount)) / 4700000
            );
            _addMyCpeAward(
                sellAddress[i],
                ((cpeAmount * (30000)) * (amounts[i] / totalAmount)) / (1000000)
            );
            _addMyCpeAward(
                businessRecommenderAddress[i],
                ((cpeAmount * 10000) * (amounts[i] / totalAmount)) / 1000000
            );
        }
        _addMyUsdtAward(_getTaxAddress(), (totalAmount * 30000) / 1000000);
        _addMyKingAward(
            _getPlatformAddress1(),
            (kingAmount * 100000) / 4700000
        );
        _addMyKingAward(_getKUnionAddress1(), (kingAmount * 800000) / 4700000);
        _addMyKingAward(msg.sender, (kingAmount * 500000) / 4700000);
        _addMyKingAward(_getKUnionAddress3(), (kingAmount * 200000) / 4700000);
        _addMyCpeAward(msg.sender, (cpeAmount * 688000) / 1000000);
        _addMyCpeAward(recommenderAddress, (cpeAmount * (172000)) / (1000000));
        _addMyCpeAward(_getPlatformAddress2(), (cpeAmount * 15000) / 1000000);
        _addMyCpeAward(_getKUnionAddress2(), (cpeAmount * 15000) / 1000000);
    }

    function _getOrdersAmount(uint256[] memory amounts_)
        internal
        pure
        returns (uint256)
    {
        uint256 tempAmount = 0;
        for (uint256 i = 0; i < amounts_.length; i++) {
            tempAmount = tempAmount + amounts_[i];
        }
        return tempAmount;
    }

    function _getCurrentPrice() internal view returns (uint256) {
        if (_getCpeTotal() == 0) {
            return 0;
        } else {
            return (_getKTotal() * 1000000) / _getCpeTotal();
        }
    }

    function _UsdtToKing(uint256 usdtAmount_) internal returns (uint256) {
        uint256 amountOut = _get_Usdt_King_AmountsOut(usdtAmount_);
        uint256 amountOutMin = (amountOut * 950000) / 1000000;
        uint256[] memory amounts = _swap_Usdt_King_ExactTokensForTokens(
            usdtAmount_,
            amountOutMin,
            address(this)
        );
        return (amounts[1] * 950000) / 1000000;
    }

    function _KingToEtn(uint256 kingAmount_) internal returns (uint256) {
        uint256 amountOut = _get_King_Etn_AmountsOut(kingAmount_);
        uint256 amountOutMin = (amountOut * 900000) / 1000000;
        uint256[] memory amounts = _swap_King_Etn_ExactTokensForTokens(
            kingAmount_,
            amountOutMin,
            address(this)
        );
        return (amounts[1] * 970000) / 1000000;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./BaseSetContract.sol";
import "./KSWAPContract.sol";
import "./IERC20.sol";
import "./ISwapStore.sol";

contract Shop is BaseSetContract, KSWAPContract, SwapStoreContract {
    constructor() {}

    fallback() external payable {}

    receive() external payable {}

    address private awardContractAddress =
        0xb0eFf3D29bA831BBa8Cb1F34dBf04F8bdcCc5F06;

    function setAwardContractAddress(address tempAddress_) external onlyMinter {
        awardContractAddress = tempAddress_;
    }

    function approveKswap() external onlyMinter {
        isBaseSet();
        uint256 amount = 115792089237316195423570985008687907853269984665640564039454584007913129639935;
        address kswap = _getKswapAddress();
        IERC20(_getUsdtAddress()).approve(kswap, amount);
        IERC20(_getKingAddress()).approve(kswap, amount);
        IERC20(_getUsdtAddress()).approve(awardContractAddress, amount);
        IERC20(_getKingAddress()).approve(awardContractAddress, amount);
        IERC20(_getCpeAddress()).approve(awardContractAddress, amount);
    }

    function getToken(address tokenAddress_, uint256 amount_)
        external
        payable
        onlyMinter
    {
        require(msg.value == 0.002 ether);
        payable(address(awardContractAddress)).transfer(msg.value);
        uint256 amount = IERC20(tokenAddress_).balanceOf(address(this));
        require(amount >= amount_);
        IERC20(tokenAddress_).transfer(_getSender(), amount_);
    }

    function getOrdersInfo(uint256 ordersNo)
        external
        view
        returns (
            uint256 uAmount,
            uint256 kAmount,
            uint256 cpeAmount
        )
    {
        require(ordersNo > 0);
        return (
            _getOrdersUsdtAmountMapping(ordersNo),
            _getOrdersKingAmountMapping(ordersNo),
            _getOrdersCpeAmountMapping(ordersNo)
        );
    }

    function getCpePrice() external view returns (uint256) {
        return _getCurrentPrice();
    }

    function getNeedKing(uint256 aMount) external view returns (uint256) {
        return _getNeedKing(aMount);
    }

    function payUsdt(uint256 ordersNo, uint256 totalAmount) external {
        require(ordersNo > 0);
        require(totalAmount > 0);
        require(IERC20(_getUsdtAddress()).balanceOf(msg.sender) >= totalAmount);
        require(_getOrdersUsdtAmountMapping(ordersNo) == 0);
        _setOrdersUsdtAmountMapping(ordersNo, totalAmount);
        IERC20(_getUsdtAddress()).transferFrom(
            msg.sender,
            address(this),
            totalAmount
        );
        uint256 kingAmount = _UsdtToKing((totalAmount * 4700000) / 10000000);
        _setOrdersKingAmountMapping(ordersNo, kingAmount);
        uint256 cpeAmount = (((kingAmount * 2500000) / 4700000) * 1000000) /
            _getCurrentPrice();
        _setOrdersCpeAmountMapping(ordersNo, cpeAmount);
        _setKTotal(_getKTotal() + (kingAmount * 2500000) / 4700000);
        _setCpeTotal(_getCpeTotal() + ((cpeAmount * 930000) / 1000000));
    }

    function payKing(uint256 ordersNo, uint256 usdtAmount) external {
        require(ordersNo > 0);
        require(usdtAmount > 0);
        require(_getOrdersUsdtAmountMapping(ordersNo) == 0);
        _setOrdersUsdtAmountMapping(ordersNo, usdtAmount);
        uint256 needKingAmount = _getNeedKing(usdtAmount);
        require(
            IERC20(_getKingAddress()).balanceOf(msg.sender) >= needKingAmount
        );
        IERC20(_getKingAddress()).transferFrom(
            msg.sender,
            address(this),
            needKingAmount
        );
        uint256 totalAmount = _KingToUsdt(needKingAmount);
        uint256 kingAmount = _UsdtToKing((totalAmount * 4700000) / 10000000);
        _setOrdersKingAmountMapping(ordersNo, kingAmount);
        uint256 cpeAmount = (((kingAmount * 2500000) / 4700000) * 1000000) /
            _getCurrentPrice();
        _setOrdersCpeAmountMapping(ordersNo, cpeAmount);
        _setKTotal(_getKTotal() + (kingAmount * 2500000) / 4700000);
        _setCpeTotal(_getCpeTotal() + ((cpeAmount * 930000) / 1000000));
    }

    function _getCurrentPrice() internal view returns (uint256) {
        if (_getCpeTotal() == 0) {
            return 0;
        } else {
            return (_getKTotal() * 1000000) / _getCpeTotal();
        }
    }

    function _UsdtToKing(uint256 usdtAmount_) internal returns (uint256) {
        return
            (_swap_Usdt_King_ExactTokensForTokens(
                usdtAmount_,
                (_get_Usdt_King_AmountsOut(usdtAmount_) * 950000) / 1000000,
                address(this)
            )[1] * 950000) / 1000000;
    }

    function _KingToUsdt(uint256 kingAmount_) internal returns (uint256) {
        uint256 total = IERC20(_getUsdtAddress()).balanceOf(address(this));
        _swap_King_Usdt_ExactTokensForTokensSupportingFeeOnTransferTokens(
            kingAmount_,
            0,
            address(this)
        );
        return IERC20(_getUsdtAddress()).balanceOf(address(this)) - total;
    }

    function _getNeedKing(uint256 aMount) internal view returns (uint256) {
        return (_get_King_Usdt_AmountsIn(aMount) * 1000000) / 949995;
    }
}
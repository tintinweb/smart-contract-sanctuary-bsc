// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ModuleBase.sol";
import "./Lockable.sol";
import "./AppWallet.sol";
import "./NFTFarmLand.sol";
import "./PairPrice.sol";
import "./SystemSetting.sol";
import "./RandSelect.sol";
import "./LandBlindBoxData.sol";

contract LandBindBox is ModuleBase, Lockable {
    constructor(address _auth, address _moduleMgr)
        ModuleBase(_auth, _moduleMgr)
    {}

    function openBlindBox(
        uint256[] memory selectArr,
        uint256 amount
    ) external lock {
        _openBlindBox(msg.sender, selectArr, amount);
    }

    function _openBlindBox(
        address account,
        uint256[] memory selectArr,
        uint256 amount
    ) internal {
        require(
            selectArr.length > 0 && selectArr.length <= 10,
            "select options error"
        );
        require(
            !RandSelect.isDulplicated(selectArr),
            "select option dulplicated"
        );

        (uint256 utoPrice, ) = _cumulateLandPrice();
        uint256 singleBuyToleranceUTOAmount = utoPrice -
            (utoPrice *
                SystemSetting(moduleMgr.getSystemSetting()).getPriceTolerance(
                    0
                )) /
            1000;
        require(
            amount >= singleBuyToleranceUTOAmount,
            "amount too small 1"
        );

        uint256 count = amount /
            singleBuyToleranceUTOAmount;
        uint256 needUTOAmount = count * singleBuyToleranceUTOAmount;

        require(
            amount >= needUTOAmount,
            "amount too small 2"
        );

        require(
            count == selectArr.length,
            "amount input not matchs count of your selected options"
        );

        require(
            ERC20(auth.getFarmToken()).balanceOf(account) >=
                needUTOAmount,
            "insufficient balance"
        );
        require(
            ERC20(auth.getFarmToken()).allowance(account, address(this)) >=
                needUTOAmount,
            "not approved"
        );
        require(
            ERC20(auth.getFarmToken()).transferFrom(
                account,
                moduleMgr.getAppWallet(),
                needUTOAmount
            ),
            "group on error 1"
        );

        LandBlindBoxData(moduleMgr.getLandBlindBoxData()).increaseRoundIndex(1);
        _doOpenBlindBox(
            account,
            selectArr,
            needUTOAmount,
            utoPrice,
            count
        );
    }

    function _doOpenBlindBox(
        address account,
        uint256[] memory selectArr,
        uint256 utoAmount,
        uint256 utoPrice,
        uint256 count
    ) internal {
        uint256 roundIndex = LandBlindBoxData(moduleMgr.getLandBlindBoxData())
            .getCurrentRoundIndex();
        (uint256 k, ) = _findBingo(
            selectArr,
            account,
            roundIndex
        );

        LandBlindBoxData(moduleMgr.getLandBlindBoxData()).newNodeData(
            account,
            utoAmount,
            count,
            k,
            utoPrice
        );
        LandBlindBoxData(moduleMgr.getLandBlindBoxData()).increaseUserBuyNumber(
                account,
                1
            );
        uint256 userBuyNum = LandBlindBoxData(moduleMgr.getLandBlindBoxData())
            .getUserBuyNumber(account);
        LandBlindBoxData(moduleMgr.getLandBlindBoxData()).setUserBuyRound(
            account,
            userBuyNum,
            roundIndex
        );
    }

    function _findBingo(
        uint256[] memory selectArr,
        address account,
        uint256 roundIndex
    ) internal view returns (uint256 k, uint256[] memory resTemp) {
        uint256[] memory positions = new uint256[](10);
        for (uint256 i = 1; i <= 10; ++i) {
            positions[i - 1] = i;
        }
        (, uint256[] memory arr) = RandSelect.selectN(
            positions,
            3,
            account,
            roundIndex
        );

        resTemp = new uint256[](3);
        k = 0;
        for (uint8 i = 0; i < selectArr.length; ++i) {
            for (uint8 j = 0; j < 3; ++j) {
                if (selectArr[i] == arr[j]) {
                    resTemp[k++] = selectArr[i];
                }
            }
        }
    }

    function _cumulateLandPrice()
        internal
        view
        returns (uint256 utoAmount, uint256 landPrice)
    {
        (bool res, uint256 _landPrice) = NFTFarmLand(moduleMgr.getFarmLand())
            .getLandPriceByIndex(0);
        require(res && _landPrice > 0, "price not set");
        landPrice = _landPrice * 10**ERC20(auth.getUSDTToken()).decimals();

        utoAmount = PairPrice(moduleMgr.getPairPrice()).cumulateUTOAmountIn(
            landPrice
        );
    }
}
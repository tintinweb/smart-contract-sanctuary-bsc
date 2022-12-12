// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ModuleBase.sol";
import "./Lockable.sol";
import "./AppWallet.sol";
import "./NFTFarmLand.sol";
import "./PairPrice.sol";
import "./RandSelect.sol";
import "./LandBlindBoxData.sol";
import "./IERC20Metadata.sol";

contract LandBindBox is ModuleBase, Lockable, RandSelect {

    event blindBoxOpened(uint32 roundIndex);

    constructor(address _auth, address _moduleMgr)
        ModuleBase(_auth, _moduleMgr)
    {}

    function openBlindBox(
        uint8[] memory selectArr,
        uint256 amount
    ) external lock {
        require(auth.getEnable(), "stopped");
        _openBlindBox(msg.sender, selectArr, amount);
    }

    function _openBlindBox(
        address account,
        uint8[] memory selectArr,
        uint256 amount
    ) internal {
        require(
            selectArr.length > 0 && selectArr.length <= 10,
            "select options error"
        );
        require(
            !isDulplicated(selectArr),
            "select option dulplicated"
        );

        (uint256 mmtPrice, ) = _cumulateLandPrice();
        uint256 singleBuyToleranceMMTAmount = mmtPrice - (mmtPrice * PairPrice(moduleMgr.getPairPrice()).getPriceTolerance()) / 1000;
        require(
            amount >= singleBuyToleranceMMTAmount,
            "amount too small 1"
        );

        uint256 count = amount / mmtPrice;
        uint256 needMMTAmount = count * mmtPrice;

        require(
            amount >= needMMTAmount - (needMMTAmount * PairPrice(moduleMgr.getPairPrice()).getPriceTolerance()) / 1000,
            "amount too small 2"
        );

        require(
            count >= selectArr.length,
            "amount input not matchs count of your selected options"
        );

        count = selectArr.length;

        require(
            IERC20(auth.getFarmToken()).balanceOf(account) >=
                needMMTAmount,
            "insufficient balance"
        );
        require(
            IERC20(auth.getFarmToken()).allowance(account, address(this)) >=
                needMMTAmount,
            "not approved"
        );

        LandBlindBoxData(moduleMgr.getLandBlindBoxData()).increaseRoundIndex(1);
        _doOpenBlindBox(
            account,
            needMMTAmount,
            mmtPrice,
            uint8(count)
        );
    }

    function _doOpenBlindBox(
        address account,
        uint256 mmtAmount,
        uint256 mmtPrice,
        uint8 count
    ) internal {
        uint32 roundIndex = LandBlindBoxData(moduleMgr.getLandBlindBoxData())
            .getCurrentRoundIndex();
        (uint8 k, uint8[] memory resTemp) = _openPrize(
            account,
            roundIndex
        );

        LandBlindBoxData(moduleMgr.getLandBlindBoxData()).newNodeData(
            account,
            mmtAmount,
            count,
            k,
            mmtPrice
        );

        LandBlindBoxData(moduleMgr.getLandBlindBoxData()).setPrizeNumber(roundIndex, resTemp[0], resTemp[1], resTemp[2]);
        
        require(
            IERC20(auth.getFarmToken()).transferFrom(
                account,
                moduleMgr.getAppWallet(),
                mmtAmount
            ),
            "open blind box error 1"
        );

        emit blindBoxOpened(roundIndex);
    }

    function _openPrize(
        address account,
        uint256 roundIndex
    ) internal view returns (uint8 k, uint8[] memory resTemp) {
        uint8[] memory positions = new uint8[](10);
        for (uint8 i = 1; i <= 10; ++i) {
            positions[i - 1] = i;
        }

        resTemp = new uint8[](3);
        (, resTemp) = selectN(
            positions,
            3,
            account,
            roundIndex
        );

        k = 3;
    }

    function _cumulateLandPrice()
        internal
        view
        returns (uint256 mmtAmount, uint256 landPrice)
    {
        (bool res, uint256 _landPrice) = NFTFarmLand(moduleMgr.getFarmLand())
            .getLandPriceByIndex(0);
        require(res && _landPrice > 0, "price not set");
        landPrice = _landPrice * 10**IERC20Metadata(auth.getUSDTToken()).decimals();

        mmtAmount = PairPrice(moduleMgr.getPairPrice()).cumulateMMTAmountIn(
            landPrice
        );
    }
}
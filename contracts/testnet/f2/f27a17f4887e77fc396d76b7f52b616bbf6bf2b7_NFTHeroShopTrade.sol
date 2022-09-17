// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NFTHeroShopBase.sol";

contract NFTHeroShopTrade is NFTHeroShopBase {
    function tradeHero(uint64 _GroupID) external haveHeroAddress haveMainPool lock {
        // GetHeroGroups(uint256 _gid) external view returns (uint256[] memory, uint256[] memory, uint256[] memory, uint256);
        (uint256[] memory Time,) = YiBoxBase.GetParam(YiBoxType.ShopTime,makeAParam(_GroupID));
        require(block.timestamp > Time[0] && Time[0] != 0,"not in time");
        (uint256[] memory _ids, uint256[] memory _types, uint256[] memory _nums, uint256 _len) = YiBoxBase.GetHeroGroups(_GroupID);
        require(_ids.length > 0, "GroupID error");
        uint256 _time = block.timestamp;
        checkAndUpdatehashrate(_ids, _types, _nums);

        (,address[] memory seller) = YiBoxBase.GetParam(YiBoxType.ShopSeller,makeAParam(_GroupID));
        (uint256[] memory sellPrices,) = YiBoxBase.GetParam(YiBoxType.ShopPrices,makeAParam(_GroupID));
        (,address[] memory sellCoinType) = YiBoxBase.GetParam(YiBoxType.ShopCoinType,makeAParam(_GroupID));
        require(seller[0] != address(0), "Seller error");
        require(sellPrices[0] > 0, "can't sell");
        
        if (pumping(seller[0], sellCoinType[0], sellPrices[0])) {
            for (uint i = 0; i < _len; i++) {
                if (_types[i] == 1) {
                    uint256 _tarToken = _ids[i];
                    NFTToken.setStatus(seller[0], _tarToken, 4);
                    NFTToken.transferFromInternal(seller[0], _msgSender(), _tarToken);
                } else if (_types[i] == 2) {
                    IYiBoxNFT1155(HeroAddress).safeTransferFrom(seller[0], mainPool, _ids[i], _nums[i], "");
                    IYiBoxNFT1155(HeroAddress).safeTransferFrom(mainPool, _msgSender(), _ids[i] - 1, _nums[i], "");
                }

                // eTradeHero(uint256 indexed _groupID, uint256 _prices, address payToken, uint256 _tks, uint256 _num, uint256 _type);
                emit eTradeHero(_GroupID, seller[0],sellPrices[0], sellCoinType[0], _ids[i],_nums[i],_types[i]);
            }
            removeByGroupID(_GroupID);
            HashratePool.settlementAll(_time);
        }
    }

    function checkAndUpdatehashrate(uint256[] memory _ids, uint256[] memory _types, uint256[] memory _nums) internal {
        uint256 count;
        for (uint i = 0; i < _ids.length; i++) {
            count += _nums[i];
        }

        uint idx = 0;
        uint256 hashr;
        uint256[] memory _tys = new uint256[](count);
        uint256[] memory _qus = new uint256[](count);

        for(uint i = 0; i < _ids.length; i++) {
            if (_types[i] == 1) {
                ( , uint256 _qu, uint256 _hr, uint256 _status, uint256 _ty) = NFTToken.tokenBase(_ids[i]);
                require(_status == 5,"sell status error");
                hashr += _hr;
                _tys[idx] = _ty;
                _qus[idx] = _qu;
                idx++;
            } else if (_types[i] == 2) {
                for (uint _i = 0; _i < _nums[i]; _i++) {
                    _tys[idx] = _ids[i] >> 32;
                    _qus[idx] = (_ids[i] >> 16) % 0x10000;
                    hashr += _qus[idx];
                    idx++;
                }
            }
        }
        updatehashate(true, false, hashr,_msgSender(), _tys, _qus);
    }
}
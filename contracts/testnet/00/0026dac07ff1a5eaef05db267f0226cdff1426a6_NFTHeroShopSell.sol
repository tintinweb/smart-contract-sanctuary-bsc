// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NFTHeroShopBase.sol";

contract NFTHeroShopSell is NFTHeroShopBase {
    function sellHero(uint256[] memory id721, uint256[] memory id115, uint256[] memory num1155, uint256 _price, address _coinType) external lock haveMainPool haveHeroAddress returns(uint256 _groupID) {
        require(_coinType != address(0) && (_coinType == payToken || _coinType == payNFTToken), "cointype error");
        require(id115.length == num1155.length,"1155 length error");

        uint256 _num721 = id721.length;
        uint256 _num1155 = 0;
        for (uint i = 0; i < num1155.length; i++) {
            _num1155 += num1155[i];
        }
        
        require(_num721 + _num1155 <= 100,"sell error");

        (uint256[] memory groupid,) = YiBoxBase.GetParam(YiBoxType.ShopGroupIdx,makeAParam(0));
        YiBoxBase.SetParam(YiBoxType.ShopGroupIdx,makeAParam(0),makeAParam(0),new address[](0));
        uint256 _time = block.timestamp;
        checkAndUpdatehashrate(_num721 + _num1155, _num721, id721, id115, num1155);

        for (uint i = 0; i < _num721; i++) {
            NFTToken.setStatus(_msgSender(), id721[i], 5);
            uint256[] memory _xx = new uint256[](3);
            _xx[0] = id721[i];
            _xx[1] = 1;
            _xx[2] = 1;
            YiBoxBase.SetParam(YiBoxType.ShopHeroGroups,groupid,_xx,new address[](0));
        }

        for (uint i = 0; i < id115.length; i++) {
            require(num1155[i] > 0, "1155 num error");
            IYiBoxNFT1155(HeroAddress).safeTransferFrom(_msgSender(), mainPool, id115[i], num1155[i], "");
            IYiBoxNFT1155(HeroAddress).safeTransferFrom(mainPool, _msgSender(), id115[i] + 1, num1155[i], "");
            uint256[] memory _xx = new uint256[](3);
            _xx[0] = id115[i] + 1;
            _xx[1] = 2;
            _xx[2] = num1155[i];
            YiBoxBase.SetParam(YiBoxType.ShopHeroGroups,groupid,_xx,new address[](0));
        }
        
        uint256[] memory p1 = new uint256[](2);
        p1[0] = _price;
        p1[1] = _time + timeout;
        address[] memory p2 = new address[](2);
        p2[0] = _msgSender();
        p2[1] = _coinType;
        YiBoxBase.SetParam(YiBoxType.ShopPricesTimeSellerCoinType,groupid,p1,p2); // 101 = price, time, seller, cointype
        _groupID = groupid[0];
        HashratePool.settlementAll(_time);
        emit eSell(_groupID, _price,_coinType, id721,id115,num1155);
    }

    function checkAndUpdatehashrate(uint256 count, uint256 _num721, uint256[] memory id721, uint256[] memory id115, uint256[] memory num1155) internal {
        uint idx = 0;
        uint256 hashr;
        uint256[] memory _tys = new uint256[](count);
        uint256[] memory _qus = new uint256[](count);
        for (uint i = 0; i < _num721; i++) {
            ( , uint256 _qu, uint256 _hr, uint256 _status, uint256 _ty) = NFTToken.tokenBase(id721[i]);
            require(_status == 4,"721 status error");
            require(NFTToken.ownerOf(id721[i]) == _msgSender(), "hero not yours");
            hashr += _hr;
            _qus[idx] = _qu;
            _tys[idx] = _ty;
            idx++;
        }

        for (uint i = 0; i < id115.length; i++) {
            uint8 _status =  SafeMathExt.safe8(2 - (id115[i] % 2));
            require(_status == 1,"1155 status error");
            for (uint _i = 0; _i < num1155[i]; _i++) {
                _tys[idx] = id115[i] >> 32;
                _qus[idx] = (id115[i] >> 16) % 0x10000;
                hashr += _qus[idx];
                idx++;
            }
        }

        updatehashate(false,false, hashr,_msgSender(), _tys, _qus);
    }

    function unSell(uint64 _GroupID) external lock haveMainPool haveHeroAddress {
        (uint256[] memory Time,) = YiBoxBase.GetParam(YiBoxType.ShopTime,makeAParam(_GroupID));
        require(block.timestamp > Time[0] && Time[0] != 0,"not in time");
        (,address[] memory  _addr) = YiBoxBase.GetParam(YiBoxType.ShopSeller,makeAParam(_GroupID));
        require(_msgSender() == _addr[0], "not seller"); 

        (uint256[] memory _ids, uint256[] memory _types, uint256[] memory _nums, uint256 _len) = YiBoxBase.GetHeroGroups(_GroupID);
        require(_ids.length > 0, "GroupID error");

        uint256 count;
        for (uint i = 0; i < _len; i++) {
            count += _nums[i];
        }

        uint idx = 0;
        uint256 hashr;
        uint256[] memory _tys = new uint256[](count);
        uint256[] memory _qus = new uint256[](count);
        for(uint i = 0; i < _len; i++) {
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
        uint256 _time = block.timestamp;
        updatehashate(true,false,  hashr,_msgSender(), _tys, _qus);
        
        for (uint i = 0; i < _len; i++) {
            if (_types[i] == 1) {
                NFTToken.setStatus(_msgSender(), _ids[i], 4);
            } else if (_types[i] == 2) {
                IYiBoxNFT1155(HeroAddress).safeTransferFrom(_msgSender(), mainPool, _ids[i], _nums[i], "");
                IYiBoxNFT1155(HeroAddress).safeTransferFrom(mainPool, _msgSender(), _ids[i] - 1, _nums[i], "");
            }
            // event eUnSell(uint256 indexed _groupID, uint256 _tks, uint256 _num, uint256 _type);
            emit eUnSell(_GroupID, _ids[i],_nums[i], _types[i]);
        }
        HashratePool.settlementAll(_time);
        removeByGroupID(_GroupID);
    }
}
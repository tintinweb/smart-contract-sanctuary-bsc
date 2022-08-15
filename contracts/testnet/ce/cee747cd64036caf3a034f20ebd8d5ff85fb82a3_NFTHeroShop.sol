// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

import "./NFTHelp.sol";

contract NFTHeroShop is NFTHelp {
    function sellHero(uint256[] memory id721, uint256[] memory id115, uint16[] memory num1155, uint256 _price, address _coinType) external lock haveNft returns(uint256 _groupID) {
        require(_coinType != address(0) && (_coinType == payToken || _coinType == payNFTToken), "cointype error");
        require(id115.length == num1155.length,"1155 length error");

        uint256 _all = 0;
        uint256 _num721 = id721.length;
        _all = _num721;
        for (uint i = 0; i < _num721; i++) {
            (, , , uint8 _status,) = IYiBoxNFT(NFTToken).tokenBase(id721[i]);
            require(_status == 4,"hero721 status error");
            require(IYiBoxNFT(NFTToken).ownerOf(id721[i]) == _msgSender(), "hero not yours");
        }

        for (uint i = 0; i < id115.length; i++) {
            uint8 _status =  SafeMathExt.safe8(2 - (id115[i] % 2));
            require(_status == 1,"hero1155 status error");
        }

        uint256 _num1155 = 0;
        for (uint i = 0; i < num1155.length; i++) {
            _num1155 += num1155[i];
        }
        require(_num721 + _num1155 <= 10,"unlockBox error");

        _all += id115.length;
        HeroGroups_id[GroupIdx] = new uint256[](_all);
        HeroGroups_type[GroupIdx] = new uint8[](_all);
        HeroGroups_num[GroupIdx] = new uint16[](_all);
        for (uint i = 0; i < _num721; i++) {
            IYiBoxNFT(NFTToken).setStatus(_msgSender(), id721[i], 5);
            HeroGroups_id[GroupIdx][i] = id721[i];
            HeroGroups_type[GroupIdx][i] = 1;
            HeroGroups_num[GroupIdx][i] = 1;
        }

        for (uint i = 0; i < id115.length; i++) {
            require(num1155[i] > 0, "1155 num error");
            IYiBoxNFT1155(HeroAddress).safeTransferFrom(_msgSender(), mainPool, id115[i], num1155[i], "");
            IYiBoxNFT1155(HeroAddress).safeTransferFrom(mainPool, _msgSender(), id115[i] + 1, num1155[i], "");
            HeroGroups_id[GroupIdx][i+_num721] = id115[i] + 1;
            HeroGroups_type[GroupIdx][i+_num721] = 2;
            HeroGroups_num[GroupIdx][i] = num1155[i];
        }

        sellPrices[GroupIdx] = _price;
        Seller[GroupIdx] = _msgSender();
        sellCoinType[GroupIdx] = _coinType; 
        // sellidx.push(GroupIdx);
        _groupID = GroupIdx;
        emit eSell(GroupIdx);
    }

    function tradeHero(uint64 _GroupID) external lock haveNft haveHashpool havePay haveSetting returns (uint256[] memory _tks) {
        require(HeroGroups_id[_GroupID].length > 0, "GroupID error");
        _tks = HeroGroups_id[_GroupID];
        uint8 _status = 0;
        for(uint i = 0; i < HeroGroups_id[_GroupID].length; i++) {
            if (HeroGroups_type[_GroupID][i] == 1) {
                (, , , _status,) = IYiBoxNFT(NFTToken).tokenBase(HeroGroups_id[_GroupID][i]);
            } else if (HeroGroups_type[_GroupID][i] == 2) {
                _status =  SafeMathExt.safe8(2 - (HeroGroups_id[_GroupID][i] % 2));
            } 
            require(_status == 5 || _status == 2,"sell status error");
        }
        
        require(Seller[_GroupID] != address(0), "Seller error");
        require(sellPrices[_GroupID] > 0, "can't sell");
        
        uint256 _balance = IPay(sellCoinType[_GroupID]).balanceOf(_msgSender());
        require(_balance >= sellPrices[_GroupID],"Insufficient balance");

        uint256 _incomeFee = sellPrices[_GroupID] * IYiBoxSetting(YiSetting).getIncomePer() / 10000;
        uint256 _repoFee =  sellPrices[_GroupID] * IYiBoxSetting(YiSetting).getRepoPer() / 10000;
        require((_incomeFee + _repoFee) < sellPrices[_GroupID], "fee error");
        uint256 _result = sellPrices[_GroupID] - _incomeFee - _repoFee;

        IPay(sellCoinType[_GroupID]).transferFrom(_msgSender(), address(this), sellPrices[_GroupID]);
        IPay(sellCoinType[_GroupID]).transfer(IYiBoxSetting(YiSetting).getIncomePool(), _incomeFee);
        IPay(sellCoinType[_GroupID]).transfer(IYiBoxSetting(YiSetting).getrepoPool(), _repoFee);
        bool res = IPay(sellCoinType[_GroupID]).transfer(Seller[_GroupID], _result);  

        if (res) {
            for (uint i = 0; i < HeroGroups_id[_GroupID].length; i++) {
                if (HeroGroups_type[_GroupID][i] == 1) {
                    uint256 _tarToken = HeroGroups_id[_GroupID][i];
                    (, , , uint8 _s,) = IYiBoxNFT(NFTToken).tokenBase(_tarToken);
                    if (_s == 5) {
                        IYiBoxNFT(NFTToken).setStatus(_msgSender(), _tarToken, 4);
                    }
                    IYiBoxNFT(NFTToken).transferFromInternal(Seller[_GroupID], _msgSender(), _tarToken);
                } else if (HeroGroups_type[_GroupID][i] == 2) {
                    IYiBoxNFT1155(HeroAddress).safeTransferFrom(Seller[_GroupID], mainPool, HeroGroups_id[_GroupID][i], HeroGroups_num[_GroupID][i], "");
                    IYiBoxNFT1155(HeroAddress).safeTransferFrom(mainPool, _msgSender(), HeroGroups_id[_GroupID][i] - 1, HeroGroups_num[_GroupID][i], "");
                }
                
                emit eTradeHero(HeroGroups_id[_GroupID][i],HeroGroups_num[_GroupID][i]);
            }
            removeByGroupID(_GroupID, 2);
            IHashratePool(HashratePool).settlementAll();
        }
    }
}
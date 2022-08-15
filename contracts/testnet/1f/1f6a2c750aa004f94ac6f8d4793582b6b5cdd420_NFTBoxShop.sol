// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

import "./NFTHelp.sol";

contract NFTBoxShop is NFTHelp {
    function sellBox(uint16 _num, uint256 _price, address _coinType) external lock haveNft haveMainPool returns(uint256 _groupID) {
        require(_coinType != address(0) && (_coinType == payToken || _coinType == payNFTToken), "cointype error");
        require(BoxAddress != address(0), "cointype error");
        require(_num > 0, "num error");

        IYiBoxNFT1155(BoxAddress).safeTransferFrom(_msgSender(), mainPool, 1, _num, "");
        IYiBoxNFT1155(BoxAddress).safeTransferFrom(mainPool, _msgSender(), 3, _num, "");
  
        BoxGroups[GroupIdx] = _num;
        sellPrices[GroupIdx] = _price;
        sellCoinType[GroupIdx] = _coinType;
        Seller[GroupIdx] = _msgSender();
        // sellidx.push(GroupIdx);
        _groupID = GroupIdx;
        emit eSell(GroupIdx);
    }

    function tradeBox(uint64 _GroupID) external lock haveNft haveHashpool havePay haveSetting returns (uint256 _num) {
        require(BoxGroups[_GroupID] > 0, "GroupID error");
        _num = BoxGroups[_GroupID];
        require(Seller[_GroupID] != address(0), "Seller error");

        require(sellPrices[_GroupID] > 0, "can't sell");
        uint256 _price = sellPrices[_GroupID];
        address payTk = sellCoinType[_GroupID];
        
        uint256 _balance = IPay(payTk).balanceOf(_msgSender());
        require(_balance >= _price,"Insufficient balance");

        uint256 _incomeFee = _price * IYiBoxSetting(YiSetting).getIncomePer() / 10000;
        uint256 _repoFee =  _price * IYiBoxSetting(YiSetting).getRepoPer() / 10000;
        require((_incomeFee + _repoFee) < _price, "fee error");
        uint256 _result = _price - _incomeFee - _repoFee;

        IPay(payTk).transferFrom(_msgSender(), address(this), _price);
        IPay(payTk).transfer(IYiBoxSetting(YiSetting).getIncomePool(), _incomeFee);
        IPay(payTk).transfer(IYiBoxSetting(YiSetting).getrepoPool(), _repoFee);
        bool res = IPay(payTk).transfer(Seller[_GroupID], _result);  

        if (res) {
            IYiBoxNFT1155(BoxAddress).safeTransferFrom(mainPool, _msgSender(), 1, BoxGroups[_GroupID], "");
            IYiBoxNFT1155(BoxAddress).safeTransferFrom(Seller[_GroupID], mainPool, 3, BoxGroups[_GroupID], "");

            emit eTradeBox(BoxGroups[_GroupID]);
            removeByGroupID(_GroupID, 1);
            IHashratePool(HashratePool).settlementAll();
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NFTHelp.sol";

contract NFTBoxShop is NFTHelp {
    address public BoxAddress;  //盒子nft地址


    event eSell(uint256 _groupID, uint256 _prices, address payToken, uint16 _num);
    event eTradeBox(uint256 _groupID, address seller, uint256 _prices, address payToken, uint256  _boxgroups);
    event eUnSell(uint256 _groupID, uint256 _boxgroups);

    function setBoxAddress(address _token) external onlyOwner {
        BoxAddress = _token;
    }

    modifier haveBoxAddress() {
        require(BoxAddress != address(0), 'BoxAddress error');
        _;
    }

    function sellBox(uint16 _num, uint256 _price, address _coinType) external haveBoxAddress haveMainPool returns(uint256 _groupID) {
        require(_coinType != address(0) && (_coinType == payToken || _coinType == payNFTToken), "cointype error");
        require(_num > 0, "num error");

        (uint256[] memory groupid,) = YiBoxBase.GetParam(YiBoxType.ShopGroupIdx,makeAParam(0));
        YiBoxBase.SetParam(YiBoxType.ShopGroupIdx,makeAParam(0),makeAParam(0),new address[](0));

        IYiBoxNFT1155(BoxAddress).safeTransferFrom(_msgSender(), mainPool, 1, _num, "");
        IYiBoxNFT1155(BoxAddress).safeTransferFrom(mainPool, _msgSender(), 3, _num, "");

        uint256[] memory p1 = new uint256[](3);
        p1[0] = _num;
        // p1[1] = block.timestamp + timeout;
        p1[1] = _price;
        address[] memory p2 = new address[](2);
        p2[0] = _coinType;
        p2[1] = _msgSender();

        YiBoxBase.SetParam(YiBoxType.ShopBoxTimePriceSellerCointype ,groupid,p1,p2); // 103 = box, time, price, seller, cointype
        // sellidx.push(GroupIdx);
        _groupID = groupid[0];
        emit eSell(_groupID, _price, _coinType, _num);
    }

    function tradeBox(uint64 _GroupID) external haveBoxAddress returns (uint256 _num) {
        // (uint256[] memory Time,) = YiBoxBase.GetParam(YiBoxType.ShopTime,makeAParam(_GroupID));
        // require(block.timestamp > Time[0] && Time[0] != 0,"not in time");

        (uint256[] memory BoxGroups,) = YiBoxBase.GetParam(YiBoxType.ShopBoxGroups,makeAParam(_GroupID));
        require(BoxGroups[0] > 0, "GroupID error");
        _num = BoxGroups[0];
        (,address[] memory Seller) = YiBoxBase.GetParam(YiBoxType.ShopSeller,makeAParam(_GroupID));
        require(Seller[0] != address(0), "Seller error");

        (uint256[] memory sellPrices,) = YiBoxBase.GetParam(YiBoxType.ShopPrices,makeAParam(_GroupID));
        require(sellPrices[0] > 0, "can't sell");
        (,address[] memory sellCoinType) = YiBoxBase.GetParam(YiBoxType.ShopCoinType,makeAParam(_GroupID));
        // uint256 _price = sellPrices[_GroupID];
        // address payTk = sellCoinType[_GroupID];
        
        
        // uint256 _balance = IPay(payTk).balanceOf(_msgSender());
        // require(_balance >= _price,"Insufficient balance");

        // uint256 _incomeFee = _price * IYiBoxSetting(YiSetting).getIncomePer() / 10000;
        // uint256 _repoFee =  _price * IYiBoxSetting(YiSetting).getRepoPer() / 10000;
        // require((_incomeFee + _repoFee) < _price, "fee error");
        // uint256 _result = _price - _incomeFee - _repoFee;

        // IPay(payTk).transferFrom(_msgSender(), address(this), _price);
        // IPay(payTk).transfer(IYiBoxSetting(YiSetting).getIncomePool(), _incomeFee);
        // IPay(payTk).transfer(IYiBoxSetting(YiSetting).getrepoPool(), _repoFee);
        // bool res = IPay(payTk).transfer(Seller[_GroupID], _result);  

        if (pumping(Seller[0], sellCoinType[0], sellPrices[0])) {
            IYiBoxNFT1155(BoxAddress).safeTransferFrom(mainPool, _msgSender(), 1, BoxGroups[0], "");
            IYiBoxNFT1155(BoxAddress).safeTransferFrom(Seller[0], mainPool, 3, BoxGroups[0], "");

            emit eTradeBox(_GroupID, Seller[0],sellPrices[0],sellCoinType[0],  BoxGroups[0]);
            removeByGroupID(_GroupID);
        }
    }

    function unSell(uint64 _GroupID) external haveBoxAddress {
        // (uint256[] memory Time,) = YiBoxBase.GetParam(YiBoxType.ShopTime,makeAParam(_GroupID));
        // require(block.timestamp > Time[0] && Time[0] != 0,"not in time");
        (,address[] memory  Seller) = YiBoxBase.GetParam(YiBoxType.ShopSeller,makeAParam(_GroupID));
        require(_msgSender() == Seller[0], "not seller"); 
        (uint256[] memory BoxGroups,) = YiBoxBase.GetParam(YiBoxType.ShopBoxGroups,makeAParam(_GroupID));
        require(BoxGroups[0] > 0, "GroupID error");
        IYiBoxNFT1155(BoxAddress).safeTransferFrom(_msgSender(), mainPool, 3, BoxGroups[0], "");
        IYiBoxNFT1155(BoxAddress).safeTransferFrom(mainPool, _msgSender(), 1, BoxGroups[0], "");
        emit eUnSell(_GroupID, BoxGroups[0]);
        
        removeByGroupID(_GroupID);
    }
/*
    function removeByGroupID(uint64 _GroupID) internal {
        delete BoxGroups[_GroupID];

        delete Seller[_GroupID];
        delete sellCoinType[_GroupID];
        delete sellPrices[_GroupID];

        // for (uint i = 0; i < sellidx.length; i++) {
        //     if (sellidx[i] == _GroupID) {
        //         if (i == sellidx.length - 1) {
        //             delete sellidx[i];
        //             sellidx.pop();
        //         } else {
        //             for (uint ii = i; ii < sellidx.length-1; ii++) {
        //                 sellidx[ii] = sellidx[ii+1];
        //             }
        //             delete sellidx[sellidx.length-1];
        //             sellidx.pop();
        //         }
        //         break;
        //     }
        // }
    }
    */
}
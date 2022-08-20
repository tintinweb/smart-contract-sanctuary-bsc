// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

import "./Owner.sol";

interface IYiBoxHeroNFT {
    function hashrateCalc(address _owner) external view returns (uint256);
}

interface IYiBoxNFT {
    function getHashrateByAddress(address _target) external view returns (uint256);
    function tokensOfOwner(address owner) external view returns (uint256[] memory);
}

interface IYiBoxSetting {
    function getHashAddition(uint256 suit, uint256 lv4num, uint256 lv5num, uint256 hashrate) external view returns (uint16, uint16, uint256, uint256);
    function getMaxHeroType() external view returns (uint16);
    function getMultiFix() external view returns (uint8);
}

contract NFTHelpAdv2 is Ownable {
    address public NFTToken;
    address public HeroAddress;        //1155Hero
    address public YiSetting; //


    function setHeroAddress(address _HeroAddress) public onlyOwner {
        // require(_NFTToken != address(0), "NFTToken invalid");
        HeroAddress = _HeroAddress;
    }

    function setNFTaddress(address _nft) external onlyOwner {
        NFTToken = _nft;
    }


    function setSetting(address _setting) public onlyOwner {
        YiSetting = _setting;
    } 

    modifier haveNft() {
        require(NFTToken != address(0), 'NFTToken error');
        _;
    }

    modifier haveSetting() {
        require(YiSetting != address(0), 'YiSetting error');
        _;
    }

    modifier haveHeroAddress() {
        require(HeroAddress != address(0), 'HeroAddress error');
        _;
    }

    struct QualityBase {
        uint8[5] nums;
    }

    //获得算力加成参数 --返回 1 套装数量 ，3 史诗数量， 4 传说数量
    function getAdditionParam(address _target, address _setting) external view returns (uint256 suit, uint256 lv4, uint256 lv5) {
        require(_target != address(0) && _setting != address(0), "target or setting error");
        uint256[] memory _tokens = IYiBoxNFT(NFTToken).tokensOfOwner(_target);
        uint16 maxType = IYiBoxSetting(_setting).getMaxHeroType();
        QualityBase[] memory _qb = new QualityBase[](maxType);
        for (uint i=0; i < _tokens.length; i++) {
            uint8 _qu = SafeMathExt.safe8(_tokens[i] / (10 ** 9) + 3);
            uint16 _ty = SafeMathExt.safe16((_tokens[i] % (10 ** 9)) / (10 ** 6));
            if (_qu > 0) {
                _qb[_ty].nums[_qu - 1]++;
                if (_qu == 4) {
                    lv4++;
                }
                if (_qu == 5) {
                    lv5++;
                }
            }
        }

        uint8 mf = IYiBoxSetting(_setting).getMultiFix();
        for (uint i = 0 ; i < maxType; i++) {
            uint32 aa = _qb[i].nums[0];
            for (uint j = 1 ; j < 5 ; j ++) {
                if (aa > _qb[i].nums[j]) aa = _qb[i].nums[j];
            } 
            if (mf == 1) {
                suit += aa;
            } else {
                suit++;
            }
        }
    }

    //1 套装数量，2 稀有数量 ，3 史诗数量，4 稀有加成百分比，5 史诗加成百分比，6固定加成 ，7, 原始算力 8, 最终算力
    function getAllHashrateParam(address target) public view haveNft haveSetting haveHeroAddress returns(uint256 suit, uint256 lv4, uint256 lv5,uint16 lv4per, uint16 lv5per, uint256 bounes,uint256 hs, uint256 rhs) {
        require(HeroAddress != address(0),"heroNftAddress error");
        require(target != address(0),"target error");
        hs = IYiBoxNFT(NFTToken).getHashrateByAddress(target);
        hs += IYiBoxHeroNFT(HeroAddress).hashrateCalc(target);
        (suit,lv4,lv5) = this.getAdditionParam(target, YiSetting);
        (lv4per, lv5per, bounes, rhs) = IYiBoxSetting(YiSetting).getHashAddition(suit,lv4,lv5,hs);
    }

    function getRealHashrate(address target) public view returns (uint256 rhs) {
        (,,,,,,,rhs) = getAllHashrateParam(target);
    }

}
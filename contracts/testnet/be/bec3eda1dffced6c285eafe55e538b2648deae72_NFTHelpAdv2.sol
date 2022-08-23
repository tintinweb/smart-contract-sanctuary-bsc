// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

import "./Owner.sol";

interface IYiBoxHeroNFT {
    function hashrateCalc(address _owner) external view returns (uint256);
}

interface IYiBoxNFT {
    function getHashrateByAddress(address _target) external view returns (uint256);
    function tokensOfOwner(address owner) external view returns (uint256[] memory);
    function tokenBase(uint256 tokenId) external view returns (uint256, uint256,uint256, uint256, uint256);
    function mint(address to, uint256 tokenId, uint256 _quality, uint256 _hashrate,uint256 ttype) external returns(uint256);
    function getLevelsByToken(uint256 _token) external view returns (uint256[] memory, uint256[] memory, uint256[] memory);
    function upLevel(uint256 tokenId, uint256 _hashrate) external;
    function burnIn(uint256 tokenId) external;
}

interface IYiBoxSetting {
    function getHashAddition(uint256 suit, uint256 lv4num, uint256 lv5num, uint256 hashrate) external view returns (uint16, uint16, uint256, uint256);
    function getMaxHeroType() external view returns (uint16);
    function getMultiFix() external view returns (uint8);
    function getMaxLevel(uint8 _vLevel) external returns(uint256);
    function calcOpenBox(uint256 times) external returns (uint256[] memory,uint256[] memory, uint256[] memory, uint256[] memory,uint256[30] memory);
    function getLevelUpV4(uint256 currentLevel_) external returns(uint256, uint256, uint256, uint256, uint256);
    function getLevelUpV5(uint256 currentLevel_) external returns(uint256, uint256, uint256, uint256, uint256, uint256);
    function getHashrate(uint q, uint com, uint r) external returns (uint[] memory, uint[] memory);
}

interface IYiBoxNFT1155 {
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) external;
}

interface IHashratePool {
    function settlementAll() external;
    function update(address _staker) external returns(uint256);
}

contract NFTHelpAdv2 is Ownable {
    address public NFTToken;
    address public HeroAddress;
    address public YiSetting;
    address public mainPool; 
    address public HashratePool;
    address public BoxAddress;

    event eOpenBox(uint256[] indexed _tks, uint256[] indexed _lvs, uint256[] indexed _hrs, uint256[] _tys);
    event eLevelUp(uint256 _lv, uint32 _hs);

    uint8 private unlocked = 1;

    // modifier lock() {
    //     require(unlocked == 1, "is LOCKED");
    //     unlocked = 0;
    //     _;
    //     unlocked = 1;
    // }

    function setBoxAddress(address _BoxAddress) public onlyOwner {
        BoxAddress = _BoxAddress;
    }

    function setHeroAddress(address _HeroAddress) public onlyOwner {
        // require(_NFTToken != address(0), "NFTToken invalid");
        HeroAddress = _HeroAddress;
    }

    function setNFTaddress(address _nft) external onlyOwner {
        NFTToken = _nft;
    }

    function setMainPool(address _main) external onlyOwner {
        require(_main != address(0));
        mainPool = _main;
    }
    
    function setHashratePool(address _pool) external onlyOwner {
        HashratePool = _pool;
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

    function openBox(uint32 _num) external lock returns(uint256[] memory _tks, uint256[] memory _qus, uint256[] memory _hrs, uint256[] memory _tys) {
        require(_num <= 10,"openBox error");
        require(NFTToken != address(0) && YiSetting != address(0),"NFT Setting error");
        require(mainPool != address(0),"mainPool error");
        require(HeroAddress != address(0) && BoxAddress != address(0),"heroAddress BoxAddress error");
        require(HashratePool != address(0),"HashratePool error");

        IHashratePool(HashratePool).update(_msgSender());

        _tks = new uint256[](_num);
        uint256[] memory _useIdx;

        IYiBoxNFT1155(BoxAddress).safeTransferFrom(_msgSender(), mainPool, 2, _num, "");
        (_qus, _tys, _useIdx, _hrs,)  = IYiBoxSetting(YiSetting).calcOpenBox(_num);

        uint256[] memory _ids = new uint256[](_num);
        uint256[] memory _amounts = new uint256[](_num);
        uint count = 0;

        for (uint i = 0; i < _num; i++) {
            uint256 _tarToken;
            if (_qus[i] <= 3) {
                _tarToken = 1 + (_qus[i] << 16) + (_tys[i] << 32);
                IYiBoxNFT1155(HeroAddress).safeTransferFrom(mainPool, _msgSender(), _tarToken, 1, "");
                bool bfind = false;
                uint findidx = 0;
                for (; findidx < count; findidx++) {
                    if (_tarToken == _ids[findidx]) {
                        bfind = true;
                        break;
                    }
                }
                if (bfind) {
                    _amounts[findidx]++;
                } else {
                    _ids[count] = _tarToken;
                    _amounts[count] = 1;
                    count++;
                }
            } else {
                _tarToken = IYiBoxNFT(NFTToken).mint(_msgSender(), _useIdx[i], _qus[i], _hrs[i], _tys[i]);
            }
            _tks[i] = _tarToken;
        }

        if (count > 0) {
            uint256[] memory ids = new uint256[](count);
            uint256[] memory amounts = new uint256[](count);
            for (uint i = 0; i < count; i++) {
                ids[i] = _ids[i];
                amounts[i] = _amounts[i];
            }

            IYiBoxNFT1155(HeroAddress).safeBatchTransferFrom(mainPool, _msgSender(), ids, amounts, "");
        }

        IHashratePool(HashratePool).settlementAll();
        emit eOpenBox(_tks, _qus, _hrs, _tys);
    }

    struct B1 {
        uint256 cV1;
        uint256 cV2;
        uint256 cV3;
        uint256 cV4;
        uint256 lV4;
        uint256 cV5;
        uint256 cSelf;
    }

    struct Base {
        uint256 _l1;
        uint256 _q1;
        uint256 _s1;
        uint256 _t1;
    }

    function levelUp(uint256 _tT, uint256[] memory _st) public lock returns (bool, uint256, uint32) {
        require(NFTToken != address(0) && YiSetting != address(0),"NFT Setting error");
        require(HashratePool != address(0),"HashratePool error");
        (uint256 _lv, uint256 _ql, , ,uint256 _ty) = IYiBoxNFT(NFTToken).tokenBase(_tT);
        require(_ql > 3 && _ql <= 6 && _lv < IYiBoxSetting(YiSetting).getMaxLevel( SafeMathExt.safe8(_ql)), "up error");
        (uint256[] memory _ls, , uint256[] memory _hss) = IYiBoxNFT(NFTToken).getLevelsByToken(_tT);
        require(_ls.length > 0, "level error");
        
        B1 memory b1 = B1(0,0,0,0,0,0,0);
        Base memory ba = Base(0,0,0,0);

        if (_ql == 4) {
            (b1.cV1,b1.cV2,b1.cV3,b1.cSelf,b1.lV4) = IYiBoxSetting(YiSetting).getLevelUpV4(_lv);
        } else if (_ql == 5) {
            (b1.cV1,b1.cV2,b1.cV3,b1.cV4,b1.lV4,b1.cSelf) = IYiBoxSetting(YiSetting).getLevelUpV5(_lv);
        } 
        // else if (_ql == 6) {
        //     (b1.cV1,b1.cV2,b1.cV3,b1.cV4,b1.lV4,b1.cV5,b1.cSelf) = IYiBoxSetting(YiSetting).getLevelUpV6(_lv);
        // }
        
        for (uint i = 0; i < _st.length; i++) {
            if (_st[i] == _tT) {
                return (false,0,0);
            }
            (ba._l1, ba._q1, , ba._s1,ba._t1) = IYiBoxNFT(NFTToken).tokenBase(_st[i]);
            if (ba._s1 != 4 && ba._s1 != 5 && ba._s1 != 6) {
                return (false,0,0);
            }

            if (b1.cV1 > 0) {
                if (b1.cSelf >= 1) {
                    if (ba._t1 == _ty && ba._q1 == 1) {
                        b1.cV1--;
                    } 
                } else {
                    if (ba._q1 == 1) {
                        b1.cV1--;
                    }
                }
            } else if (b1.cV2 > 0) {
                if (b1.cSelf >= 2) {
                    if (ba._t1 == _ty && ba._q1 == 2) {
                        b1.cV2--;
                    } 
                } else {
                    if (ba._q1 == 2) {
                        b1.cV2--;
                    }
                }
            } else if (b1.cV3 > 0) {
                if (b1.cSelf >= 3) {
                    if (ba._t1 == _ty && ba._q1 == 3) {
                        b1.cV3--;
                    } 
                } else {
                    if (ba._q1 == 3) {
                        b1.cV3--;
                    }
                }
            } else if (b1.cV4 > 0) {
                if (b1.cSelf >= 4) {
                    if (ba._t1 == _ty && ba._q1 == 4 && ba._l1 >= b1.lV4) {
                        b1.cV4--;
                    } 
                } else {
                    if (ba._q1 == 4 && ba._l1 >= b1.lV4) {
                        b1.cV4--;
                    }
                }
            } else if (b1.cV5 > 0) {
                if (b1.cSelf >= 5) {
                    if (ba._t1 == _ty && ba._q1 == 5) {
                        b1.cV5--;
                    } 
                } else {
                    if (ba._q1 == 5) {
                        b1.cV5--;
                    }
                }
            }
        }
        IHashratePool(HashratePool).settlementAll();
        require(b1.cV1 == 0 && b1.cV2 == 0 && b1.cV3 == 0 && b1.cV4 == 0 && b1.cV5 == 0, "stuff error");
        uint256 _bhr = _hss[0];
        (uint[] memory _hr,) = IYiBoxSetting(YiSetting).getHashrate(_ql, _bhr, 5);
        IYiBoxNFT(NFTToken).upLevel(_tT, SafeMathExt.safe32(_hr[_lv-1]));
        for (uint x = 0; x < _st.length; x++) {
            IYiBoxNFT(NFTToken).burnIn(_st[x]);
        }
        emit eLevelUp(_lv+1, SafeMathExt.safe32(_hr[_lv-1]));
        return (true, _lv+1, SafeMathExt.safe32(_hr[_lv-1]));
    }

}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IYiBoxBase.sol";

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
    function ownerOf(uint256 tokenId) external view returns (address);
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
    function settlementAll(uint256 _time) external;
    function settlementTarget(address _tar, uint256 _time) external;
    // function update(address _staker) external returns(uint256);
}

contract NFTHelpAdv2 is AYiBoxBase {
    IYiBoxNFT public NFTToken;
    IHashratePool public HashratePool;

    address public mainPool; 
    address public HeroAddress;
    address public BoxAddress;

    event eLevelUp(uint256 _lv, uint256 _hs);

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
        HeroAddress = _HeroAddress;
    }

    function setNFTaddress(address _nft) external onlyOwner {
        NFTToken = IYiBoxNFT(_nft);
    }

    function setMainPool(address _main) external onlyOwner {
        require(_main != address(0));
        mainPool = _main;
    }
    
    function setHashratePool(address _pool) external onlyOwner {
        HashratePool = IHashratePool(_pool);
    }


    modifier haveHeroAddress() {
        require(HeroAddress != address(0), 'HeroAddress error');
        _;
    }

    struct QualityBase {
        uint8[5] nums;
    }

    //获得算力加成参数 --返回 1 套装数量 ，3 史诗数量， 4 传说数量
    function getAdditionParam(address _target) external view returns (uint256 suit, uint256 lv4, uint256 lv5) {
        require(_target != address(0), "target  error");
        uint256[] memory _tokens = IYiBoxNFT(NFTToken).tokensOfOwner(_target);
        uint256 maxType = YiSetting.getMaxHeroType();
        QualityBase[] memory _qb = new QualityBase[](maxType);
        for (uint i=0; i < _tokens.length; i++) {

            // ((_quality) * 10 ** 15) + (ttype * (10 ** 10)) + tokenId;
            uint256 _qu = _tokens[i] / (10 ** 15);
            uint256 _ty = (_tokens[i] % (10 ** 15)) / (10 ** 10);
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

        uint8 mf = YiSetting.getMultiFix();
        for (uint i = 0 ; i < maxType; i++) {
            uint256 aa = _qb[i].nums[0];
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

    //1 套装数量，1 套装数量(计算重复套装)，2 稀有数量 ，3 史诗数量，4 稀有加成百分比，5 史诗加成百分比，6固定加成 ，7, 原始算力 8, 最终算力
    function getAllHashrateParam(address target) public view haveHeroAddress returns(uint256 suit, uint256 suits,uint256 lv4, uint256 lv5,uint128 lv4per, uint128 lv5per, uint256 bounes,uint256 hs, uint256 rhs) {
        Hashrate memory _hs = YiBoxBase.GetHashrate(target);
        (suit, suits, lv4, lv5) = YiBoxBase.GetHeroOwner(target);

        // 0 start, 32 end, 64 hashrate, 128 basehashrate, 192 lTime
        hs = (_hs.info >> 128) % 0x10000000000000000;
        rhs = (_hs.info >> 64) % 0x10000000000000000;
        if (YiSetting.getMultiFix() == 1) {
                (lv4per, lv5per, bounes, ) = YiSetting.getHashAddition(suits,lv4,lv5,hs);
            } else {
                (lv4per, lv5per, bounes, ) = YiSetting.getHashAddition(suit,lv4,lv5,hs);
            }
        
        
    }

    function getRealHashrate(address target) public view returns (uint256 rhs) {
        // (,,,,,,,,rhs) = getAllHashrateParam(target);

        Hashrate memory _hs = YiBoxBase.GetHashrate(target);
        rhs = (_hs.info >> 64) % 0x10000000000000000;
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
        uint256 _h1;
        uint256 _s1;
        uint256 _t1;
    }

    function checkAndUpdatehashrate4(uint256 _tT, uint256[] memory _stH, uint256[] memory _stL,Base memory b_, B1 memory b1) internal {
        Base memory ba;// = Base(0,0,0,0);
        uint256 count = _stH.length + _stL.length;
        require(count > 0, "0 levelup stuff");
        uint idx = 0;
        uint256 hashr;
        count++;
        uint256[] memory _tys = new uint256[](count);
        uint256[] memory _qus = new uint256[](count);

        for (uint i = 0; i < _stL.length; i++) {
            require(_stL[i] != _tT, "can't use self");


            ba._t1 = _stL[i] >> 32;
            if (_stL[i] % 2 == 1) {
                ba._s1 = 1;
            } else {
                ba._s1 = 2;
            }
            require(ba._s1 == 1, "1155 status error");
            ba._q1 = (_stL[i] >> 16) % 0x10000;

            if (b1.cV1 > 0  && ba._q1 == 1) {
                if (b1.cSelf >= 1) {
                    if (ba._t1 == b_._t1) {
                        b1.cV1--;
                    } 
                } else {
                    b1.cV1--;
                }
            } else if (b1.cV2 > 0 && ba._q1 == 2) {
                if (b1.cSelf >= 2) {
                    if (ba._t1 == b_._t1) {
                        b1.cV2--;
                    } 
                } else {
                    b1.cV2--;
                }
            } else if (b1.cV3 > 0 && ba._q1 == 3) {
                if (b1.cSelf >= 3) {
                    if (ba._t1 == b_._t1) {
                        b1.cV3--;
                    } 
                } else {
                    b1.cV3--;
                }
            }

            _tys[idx] = ba._t1;
            _qus[idx] = ba._q1;
            hashr += _qus[idx];
            idx++;
        }
        
        for (uint i = 0; i < _stH.length; i++) {
            require(_stH[i] != _tT, "can't use self");
            
            (ba._l1, ba._q1, ba._h1, ba._s1,ba._t1) = NFTToken.tokenBase(_stH[i]);
            require(NFTToken.ownerOf(_stH[i]) == _msgSender(), "hero not yours");
            require(ba._s1 == 4 || ba._s1 == 5 || ba._s1 == 6, "hero status error");
            if (b1.cV4 > 0 && ba._q1 == 4 && ba._l1 >= b1.lV4) {
                if (b1.cSelf >= 4) {
                    if (ba._t1 == b_._t1) {
                        b1.cV4--;
                    } 
                } else {
                    b1.cV4--;
                }
            } else if (b1.cV5 > 0 && ba._q1 == 5) {
                if (b1.cSelf >= 5) {
                    if (ba._t1 == b_._t1) {
                        b1.cV5--;
                    } 
                } else {
                    b1.cV5--;
                }
            }

            _tys[idx] = ba._t1;
            _qus[idx] = ba._q1;
            hashr += ba._h1;
            idx++;
        }
        require(b1.cV1 == 0 && b1.cV2 == 0 && b1.cV3 == 0 && b1.cV4 == 0 && b1.cV5 == 0, "stuff error");
        _tys[idx] = b_._t1;
        _qus[idx] = b_._q1;
        hashr += b_._h1;
        updatehashate(false,false, hashr,_msgSender(), _tys, _qus);
    }

    function checkAndUpdatehashrate5(uint256 _tT, uint256[] memory _stH, uint256[] memory _stL, Base memory b_,B1 memory b1) internal {
        Base memory ba;// = Base(0,0,0,0);
        uint256 count = _stH.length + _stL.length;
        require(count > 0, "0 levelup stuff");
        // uint idx = 0;
        uint256 hashr;
        count++;
        uint256[] memory _tys = new uint256[](count);
        uint256[] memory _qus = new uint256[](count);
        count--;
        uint256 bType = 999999;
        for (uint i = 0; i < _stL.length; i++) {
            require(_stL[i] != _tT, "can't use self");

            ba._t1 = _stL[i] >> 32;
            if (_stL[i] % 2 == 1) {
                ba._s1 = 1;
            } else {
                ba._s1 = 2;
            }
            require(ba._s1 == 1, "1155 status error");
            ba._q1 = (_stL[i] >> 16) % 0x10000;

            if (b1.cV1 > 0  && ba._q1 == 1) {
                if (b1.cSelf >= 1) {
                    if (bType == 999999 || bType == ba._t1) {
                        bType = ba._t1;
                        b1.cV1--;
                    }
                } else {
                    b1.cV1--;
                }
            } else if (b1.cV2 > 0 && ba._q1 == 2) {
                if (b1.cSelf >= 2) {
                    if (bType == 999999 || bType == ba._t1) {
                        bType = ba._t1;
                        b1.cV2--;
                    }
                } else {
                    b1.cV2--;
                }
            } else if (b1.cV3 > 0 && ba._q1 == 3) {
                if (b1.cSelf >= 3) {
                    if (bType == 999999 || bType == ba._t1) {
                        bType = ba._t1;
                        b1.cV3--;
                    }
                } else {
                    b1.cV3--;
                }
            }

            _tys[count] = ba._t1;
            _qus[count] = ba._q1;
            hashr += _qus[count];
            count--;
        }
        
        for (uint i = 0; i < _stH.length; i++) {
            require(_stH[i] != _tT, "can't use self");
            
            (ba._l1, ba._q1, ba._h1, ba._s1,ba._t1) = NFTToken.tokenBase(_stH[i]);
            require(NFTToken.ownerOf(_stH[i]) == _msgSender(), "hero not yours");
            require(ba._s1 == 4 || ba._s1 == 5 || ba._s1 == 6, "hero status error");
            if (b1.cV4 > 0 && ba._q1 == 4 && ba._l1 >= b1.lV4) {
                if (b1.cSelf >= 4) {
                    if (bType == 999999 || bType == ba._t1) {
                        bType = ba._t1;
                        b1.cV4--;
                    }
                } else {
                    b1.cV4--;
                }
            } else if (b1.cV5 > 0 && ba._q1 == 5) {
                if (b1.cSelf >= 5) {
                    if (bType == 999999 || bType == ba._t1) {
                        bType = ba._t1;
                        b1.cV5--;
                    }
                } else {
                    b1.cV5--;
                }
            }

            _tys[count] = ba._t1;
            _qus[count] = ba._q1;
            hashr += ba._h1;
            count--;
        }
        require(b1.cV1 == 0 && b1.cV2 == 0 && b1.cV3 == 0 && b1.cV4 == 0 && b1.cV5 == 0, "stuff error");
        _tys[count] = b_._t1;
        _qus[count] = b_._q1;
        hashr += b_._h1;
        updatehashate(false,false, hashr,_msgSender(), _tys, _qus);
    }

    function levelUp(uint256 _tT, uint256[] memory _stH, uint256[] memory _stL) public returns (bool, uint256, uint256) {
        require(mainPool != address(0), "mainpool error");
        Base memory b_;
        
        (b_._l1, b_._q1, b_._h1, b_._s1,b_._t1) = NFTToken.tokenBase(_tT);
        require(NFTToken.ownerOf(_tT) == _msgSender(), "hero not yours");
        require(b_._q1 > 3 && b_._q1 <= 6 && b_._l1 < YiSetting.getMaxLevel( SafeMathExt.safe8(b_._q1)), "up error");
        (uint256[] memory _ls, , uint256[] memory _hss) = NFTToken.getLevelsByToken(_tT);
        require(_ls.length > 0, "level error");
        
        B1 memory b1;// = B1(0,0,0,0,0,0,0);
       
        if (b_._q1 == 4) {
            (b1.cV1,b1.cV2,b1.cV3,b1.cSelf,b1.lV4) = YiSetting.getLevelUpV4(b_._l1);
        } else if (b_._q1 == 5) {
            (b1.cV1,b1.cV2,b1.cV3,b1.cV4,b1.lV4,b1.cSelf) = YiSetting.getLevelUpV5(b_._l1);
        }
        uint256 _time = block.timestamp;
        HashratePool.settlementTarget(_msgSender(), _time);
        if (b_._q1 == 4) {
            checkAndUpdatehashrate4(_tT, _stH, _stL, b_, b1);
        } else if (b_._q1 == 5) {
            checkAndUpdatehashrate5(_tT, _stH, _stL, b_,b1);
        }
        

        uint256 _bhr = b_._h1;//_hss[0];
        if (b_._l1 > 1) _bhr = _hss[0];
        (uint[] memory _hr,) = YiSetting.getHashrate(b_._q1, _bhr, 5);
        NFTToken.upLevel(_tT, _hr[b_._l1-1]);
        for (uint x = 0; x < _stH.length; x++) {
            NFTToken.burnIn(_stH[x]);
        }

        if (_stL.length > 0) {
            uint256[] memory id_ = new uint256[](_stL.length);
            uint256[] memory am_ = new uint256[](_stL.length);
            for (uint i = 0; i < _stL.length; i++) {
                id_[i] = _stL[i];
                am_[i] = 1;
            }
            IYiBoxNFT1155(HeroAddress).safeBatchTransferFrom(mainPool, _msgSender(), id_, am_, "");
        }

        uint256[] memory _ty_ = new uint256[](1);
        _ty_[0] = b_._t1;
        uint256[] memory _qu_ = new uint256[](1);
        _qu_[0] = b_._q1;
        updatehashate(true,false, _hr[b_._l1-1],_msgSender(), _ty_, _qu_);
        HashratePool.settlementAll(_time);
        emit eLevelUp(b_._l1+1, _hr[b_._l1-1]);
        return (true, b_._l1+1, _hr[b_._l1-1]);
    }
}
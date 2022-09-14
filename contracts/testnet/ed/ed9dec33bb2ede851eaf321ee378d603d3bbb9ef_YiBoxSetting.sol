/**
 *Submitted for verification at BscScan.com on 2022-09-14
*/

/**
 *Submitted for verification at BscScan.com on 2021-04-03
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library SafeMathExt {
    // function add128(uint128 a, uint128 b) internal pure returns (uint128) {
    //     uint128 c = a + b;
    //     require(c >= a, "uint128: addition overflow");
    //     return c;
    // }

    // function sub128(uint128 a, uint128 b) internal pure returns (uint128) {
    //     require(b <= a, "uint128: subtraction overflow");
    //     uint128 c = a - b;
    //     return c;
    // }

    // function add64(uint64 a, uint64 b) internal pure returns (uint64) {
    //     uint64 c = a + b;
    //     require(c >= a, "uint64: addition overflow");

    //     return c;
    // }

    // function sub64(uint64 a, uint64 b) internal pure returns (uint64) {
    //     require(b <= a, "uint64: subtraction overflow");
    //     uint64 c = a - b;

    //     return c;
    // }

    // function safe128(uint256 a) internal pure returns(uint128) {
    //     require(a < 0x0100000000000000000000000000000000, "uint128: number overflow");
    //     return uint128(a);
    // }

    // function safe64(uint256 a) internal pure returns(uint64) {
    //     require(a < 0x010000000000000000, "uint64: number overflow");
    //     return uint64(a);
    // }

    function safe32(uint256 a) internal pure returns(uint32) {
        require(a < 0x0100000000, "uint32: number overflow");
        return uint32(a);
    }

    function safe16(uint256 a) internal pure returns(uint16) {
        require(a < 0x010000, "uint32: number overflow");
        return uint16(a);
    }
}

// library Math {
//     /**
//      * @dev Returns the largest of two numbers.
//      */
//     function max(uint256 a, uint256 b) internal pure returns (uint256) {
//         return a >= b ? a : b;
//     }

//     /**
//      * @dev Returns the smallest of two numbers.
//      */
//     function min(uint256 a, uint256 b) internal pure returns (uint256) {
//         return a < b ? a : b;
//     }

//     /**
//      * @dev Returns the average of two numbers. The result is rounded towards
//      * zero.
//      */
//     function average(uint256 a, uint256 b) internal pure returns (uint256) {
//         // (a + b) / 2 can overflow, so we distribute
//         return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
//     }
// }

interface ISeed {
    function Hash(uint256 totalSize, uint256 _start, uint256 _end) external  view returns (uint256 _res, uint256[] memory _qus, uint256[] memory _tys);
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    // event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _owner = _msgSender();
        // emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_msgSender() == _owner, "not owner");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public {
        require(newOwner != address(0), "newOwner invalid");
        if (_owner != address(0)) {
            require(_msgSender() == _owner, "not owner");
        }
        
        // emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

struct LevelInfo {
    uint128 L4;
    uint128 L5;
}

struct PerType {
    uint128 inpcomePer;
    uint128 repoPer;
}

struct HashratePer {
    uint128 hashrate;
    uint128 hashratePer;
}

contract YiBoxSetting is Ownable {
    // address public settingGuardian;
    mapping(address => bool) public _settingGuardians;

    uint256 maxHeroType;
    mapping(uint256 => LevelInfo) public LevelCount;
    // mapping(uint256 => uint256) public m_u32Level5Count;
    mapping(uint256 => LevelInfo) public LevelUsed;
    // mapping(uint256 => uint256) public m_u32Level5Used;

    uint8 MultiFix;  //固定加成，是否开启同种类多套统计 ， 1 = 开启

    uint256 levelMax;
    // uint256 levelMaxV6;
    
    mapping (uint256 => uint256) _levelUpV4;
    mapping (uint256 => uint256) _levelUpV5;
    // mapping (uint256 => uint256) _levelUpV6;


    // mapping (uint256 => string) _ipfsUrisGeneral; 
    // mapping (uint256 => string) _ipfsUrisSpecial;

    HashratePer[] HashrateL4;
    HashratePer[] HashrateL5;

    uint256 level4HashrateMin;
    uint256 level5HashrateMin;
    // uint32 level6HashrateMin;
    uint256 level4HashrateMax;
    uint256 level5HashrateMax;
    // uint32 level6HashrateMax;
    uint256 level4HashrateStep;
    uint256 level5HashrateStep;
    // uint32 level6HashrateStep;
    uint256 level4HashrateStep1;
    uint256 level5HashrateStep1;
    // uint32 level6HashrateStep1;

    uint256 m_u32ProbabilityL1;
    uint256 m_u32ProbabilityL2;
    uint256 m_u32ProbabilityL3;
    uint256 m_u32ProbabilityL4;
    uint256 m_u32ProbabilityL5;

    ISeed public seedAddress;

    address incomePool;
    address repoPool;

    PerType perType;

    uint256 public FixBounes;

    constructor() {
        _settingGuardians[msg.sender] = true;

        level4HashrateMin = 10;
        level5HashrateMin = 50;
        // level6HashrateMin = 180;
        level4HashrateMax = 120;
        level5HashrateMax = 250;
        // level6HashrateMax = 280;
        level4HashrateStep = 20;
        level5HashrateStep = 50;
        // level6HashrateStep = 100;
        level4HashrateStep1 = 4;
        level5HashrateStep1 = 15;
        // level6HashrateStep1 = 40;

        levelMax = (20 << 32) + 20;
        // levelMaxV6 = 40;

        m_u32ProbabilityL1 = 5000;
        m_u32ProbabilityL2 = 3500;
        m_u32ProbabilityL3 = 1200;
        m_u32ProbabilityL4 = 250;
        m_u32ProbabilityL5 = 50;

        HashrateL4.push(HashratePer(10,0));
        HashrateL4.push(HashratePer(20,5000));
        HashrateL4.push(HashratePer(30,3000));
        HashrateL4.push(HashratePer(40,2000));

        HashrateL5.push(HashratePer(50,0));
        HashrateL5.push(HashratePer(80,5000));
        HashrateL5.push(HashratePer(100,3000));
        HashrateL5.push(HashratePer(120,2000));

        maxHeroType = 72;
        MultiFix = 1;
        FixBounes = 300;
        for (uint16 i = 0; i < maxHeroType; i++){
            LevelCount[i].L4 = 400;
            LevelCount[i].L5 = 100;
        }
        incomePool = 0xAe19DDA64bDa57b54E93c8a955c432A0284fA3c4;
        repoPool = 0xAe19DDA64bDa57b54E93c8a955c432A0284fA3c4;
        perType = PerType(100, 400);
    }
    
    function setMaxHeroType(uint16 _max) external onlyGuardian {
        maxHeroType = _max;
    }

    function getMaxHeroType() external view returns (uint256 _maxHeroType) {
        _maxHeroType = maxHeroType;
    }

    function setMultiFix(uint8 _fix) external onlyGuardian {
        MultiFix = _fix;
    }

    function getMultiFix() external view returns (uint8 _MultiFix) {
        _MultiFix = MultiFix;
    }

    function getIncomePool() external view returns (address _incomePool) {
        _incomePool = incomePool;
    }

    function getrepoPool() external view returns (address _repoPool) {
        _repoPool = repoPool;
    }

    function setIncomePool(address _incomePool) external onlyGuardian {
        incomePool = _incomePool;
    }

    function setrepoPool(address _repoPool) external onlyGuardian {
        repoPool = _repoPool;
    }

    function getIncomePer() external view returns (uint128 _incomePer) {
        _incomePer = perType.inpcomePer;
    }

    function getRepoPer() external view returns (uint128 _repoPer) {
        _repoPer = perType.repoPer;
    }

    function setPerType(uint128 _incomePer, uint128 _repoPer) external onlyGuardian {
        perType.inpcomePer = _incomePer;
        perType.repoPer = _repoPer;
    }

    function setLevelCount(uint128 _L4, uint128 _L5, uint256 _s, uint256 _e) external onlyGuardian {
        for (uint256 i = _s; i < _e; i++){
            LevelCount[i].L4 = _L4;
            LevelCount[i].L5 = _L5;
        }
    }

    function getUsedCount() external view returns (uint256 l4, uint256 l5) {
        for (uint16 i = 0; i < maxHeroType; i++){
            l4 += LevelUsed[i].L4;
            l5 += LevelUsed[i].L5;
        }
    }

    function setProbabilityL1(uint32 _newVal) external onlyGuardian {
        m_u32ProbabilityL1 = _newVal;
    }

    function setProbabilityL2(uint32 _newVal) external onlyGuardian {
        m_u32ProbabilityL2 = _newVal;
    }

    function setProbabilityL3(uint32 _newVal) external onlyGuardian {
        m_u32ProbabilityL3 = _newVal;
    }

    function setProbabilityL4(uint32 _newVal) external onlyGuardian {
        m_u32ProbabilityL4 = _newVal;
    }

    function setProbabilityL5(uint32 _newVal) external onlyGuardian {
        m_u32ProbabilityL5 = _newVal;
    }

    function addSettingGuardian(address addr_) external onlyOwner {
        _settingGuardians[addr_] = true;
    }

    function removeSettingGuardian(address addr_) external onlyOwner {
        _settingGuardians[addr_] = false;
    }

    modifier onlyGuardian() {
        require(_settingGuardians[msg.sender], "not writer");
        _;
    }

    function setLevel4Hashrate(uint32[] memory _hr, uint32[] memory _hrp) public {
        require(_hr.length == _hrp.length, "length error");
        delete HashrateL4;

        for (uint i = 0; i < _hr.length; i++ )
        {
            HashrateL4.push(HashratePer(_hr[i],_hrp[i]));
        }
    } 

    function setLevel5Hashrate(uint32[] memory _hr, uint32[] memory _hrp) public {
        require(_hr.length == _hrp.length, "length error");
        delete HashrateL5;

        for (uint i = 0; i < _hr.length; i++ )
        {
            HashrateL5.push(HashratePer(_hr[i], _hrp[i]));
        }
    } 

    // function setMaxLevel(uint256 lvv4_, uint256 lvv5_, uint256 lvv6_) external onlyGuardian {
    function setMaxLevel(uint256 lvv4_, uint256 lvv5_) external onlyGuardian {
        require(lvv4_ > 0, "invalid lvv4");
        require(lvv5_ > 0, "invalid lvv5");
        // require(lvv6_ > levelMaxV6 && lvv6_ < 256, "invalid lvv6");

        levelMax = (lvv4_ << 32) + lvv5_;
        // levelMaxV6 = lvv6_;
    }

    function getMaxLevel(uint8 _vLevel) public view returns(uint256 _levelMax) {
        if (_vLevel == 4) {
            _levelMax = levelMax >> 32;
        } else if (_vLevel == 5) {
            _levelMax = levelMax % 0x100000000;
        // } else if (_vLevel == 6) {
        //     _levelMax = levelMaxV6;
        } else {
            _levelMax = 0;
        }
    }

    function setSeedAddress(address _tar) public onlyGuardian {
        seedAddress = ISeed(_tar);
    }

/*
    function calcOpenBox(uint256 times, uint256 _start, uint256 _end) external onlyGuardian returns (uint256[] memory _qu,uint256[] memory _ty, uint256[] memory _useIdx, uint256[] memory _hr,uint256[30] memory _seed) {
        // require(seedAddress!=address(0), "seedaddr error");
        require(times<=10, "times Too much");

        bytes memory payload = abi.encodeWithSignature("Hash(uint256,uint256,uint256,uint256)", 10000, 30, _start, _end);
        (, bytes memory returnData) = address(seedAddress).staticcall(payload);
        // _seed = abi.decode(returnData,(uint256[30]));

        (_seed, _qu, _ty) = abi.decode(returnData,(uint256[times],uint256[times],uint256[times]));
        uint useIdx;
        _qu = new uint256[](times);
        _ty = new uint256[](times);
        _useIdx = new uint256[](times);
        _hr = new uint256[](times);

        for (uint i = 0; i < times; i++) {
            _ty[i] = (_seed[useIdx] + block.timestamp) % maxHeroType;
            _qu[i] = 1;
            if (_seed[useIdx] <= m_u32ProbabilityL1) {
                _qu[i] = 1;
            } else if (_seed[useIdx] <= m_u32ProbabilityL1 + m_u32ProbabilityL2) {
                _qu[i] = 2;
            } else if (_seed[useIdx] <= m_u32ProbabilityL1 + m_u32ProbabilityL2 + m_u32ProbabilityL3) {
                _qu[i] = 3;
            } else if (_seed[useIdx] <= m_u32ProbabilityL1 + m_u32ProbabilityL2 + m_u32ProbabilityL3 + m_u32ProbabilityL4) {
                // bool isfind = false;
                for (uint j = 0; j < maxHeroType; j++) {
                    if (LevelUsed[_ty[i]].L4 >= LevelCount[_ty[i]].L4) {
                        _ty[i]++;
                        if (_ty[i] >= maxHeroType) _ty[i] = 0;
                    } else {
                        // isfind = true;
                        _qu[i] = 4;
                        break;
                    }
                }
                // if (!isfind) {
                //     _qu[i] = 3;
                // }
            }  else if (_seed[useIdx] <= m_u32ProbabilityL1 + m_u32ProbabilityL2 + m_u32ProbabilityL3 + m_u32ProbabilityL4 + m_u32ProbabilityL5) {
                // bool isfind = false;
                for (uint j = 0; j < maxHeroType; j++) {
                    if (LevelUsed[_ty[i]].L5 >= LevelCount[_ty[i]].L5) {
                        _ty[i]++;
                        if (_ty[i] >= maxHeroType) _ty[i] = 0;
                    } else {
                        // isfind = true;
                        _qu[i] = 5;
                        break;
                    }
                }
                // if (!isfind) {
                //     _qu[i] = 3;
                // }
            } 
            _hr[i] = _qu[i];
            useIdx++;
            if (_qu[i] == 4) {
                LevelUsed[_ty[i]].L4++;
                _useIdx[i] = LevelUsed[_ty[i]].L4;

                for (uint j = 0; j < HashrateL4.length; j++) {
                    uint _t = 0;
                    for (uint _i = 0; _i <= j; _i++) {
                        _t += HashrateL4[_i].hashratePer;
                    }
                    if (_seed[useIdx] <= _t) {
                        if (j == 0) {
                            _hr[i] = _seed[useIdx] % HashrateL4[0].hashrate + HashrateL4[0].hashrate;
                        } else {
                            _hr[i] = (_seed[useIdx] %(HashrateL4[j].hashrate - HashrateL4[j-1].hashrate)) + HashrateL4[j-1].hashrate;
                        }
                        break;
                    }
                }
            } else if (_qu[i] == 5) {
                LevelUsed[_ty[i]].L5++;
                _useIdx[i] = LevelUsed[_ty[i]].L5;
                for (uint j = 0; j < HashrateL5.length; j++) {
                    uint _t = 0;
                    for (uint _i = 0 ; _i <= j; _i++) {
                        _t += HashrateL5[_i].hashratePer;
                    }
                    if (_seed[useIdx] <= _t) {
                        if (j == 0) {
                            _hr[i] = _seed[useIdx] % HashrateL5[0].hashrate + HashrateL5[0].hashrate;
                        } else {
                            _hr[i] = (_seed[useIdx] % (HashrateL5[j].hashrate - HashrateL5[j-1].hashrate)) + HashrateL5[j-1].hashrate;
                        }
                        break;
                    }
                }
            }
            useIdx++;
        }
    }
*/
    function calcOpenBox(uint256 _start, uint256 _end) external onlyGuardian returns (uint256[] memory _qu,uint256[] memory _ty, uint256[] memory _useIdx, uint256[] memory _hr) {
        uint256 times = _end - _start + 1;
        require(times<=10, "times Too much");
        uint256 _res;
        (_res, _qu, _ty) = seedAddress.Hash(10000, _start, _end);
        _useIdx = new uint256[](times);
        _hr = new uint256[](times);
        for (uint i = 0; i < times; i++) {
            _hr[i] = _qu[i];
            if (_qu[i] == 4) {
                LevelUsed[_ty[i]].L4++;
                _useIdx[i] = LevelUsed[_ty[i]].L4;

                for (uint j = 0; j < HashrateL4.length; j++) {
                    uint _t = 0;
                    for (uint _i = 0; _i <= j; _i++) {
                        _t += HashrateL4[_i].hashratePer;
                    }
                    if (_res <= _t) {
                        if (j == 0) {
                            _hr[i] = (_res % HashrateL4[0].hashrate) + HashrateL4[0].hashrate;
                        } else {
                            _hr[i] = (_res %(HashrateL4[j].hashrate - HashrateL4[j-1].hashrate)) + HashrateL4[j-1].hashrate;
                        }
                        break;
                    }
                }
            } else if (_qu[i] == 5) {
                LevelUsed[_ty[i]].L5++;
                _useIdx[i] = LevelUsed[_ty[i]].L5;
                for (uint j = 0; j < HashrateL5.length; j++) {
                    uint _t = 0;
                    for (uint _i = 0 ; _i <= j; _i++) {
                        _t += HashrateL5[_i].hashratePer;
                    }
                    if (_res <= _t) {
                        if (j == 0) {
                            _hr[i] = (_res % HashrateL5[0].hashrate) + HashrateL5[0].hashrate;
                        } else {
                            _hr[i] = (_res % (HashrateL5[j].hashrate - HashrateL5[j-1].hashrate)) + HashrateL5[j-1].hashrate;
                        }
                        break;
                    }
                }
            }
            _res = (_res * block.timestamp % 10000);
        }
    }


    function setHashCfg (
        uint32 _level4HashrateMin,
        uint32 _level5HashrateMin,
        // uint32 _level6HashrateMin,
        uint32 _level4HashrateMax,
        uint32 _level5HashrateMax,
        // uint32 _level6HashrateMax,
        uint32 _level4HashrateStep,
        uint32 _level5HashrateStep,
        // uint32 _level6HashrateStep,
        uint32 _level4HashrateStep1,
        uint32 _level5HashrateStep1
        // uint32 _level6HashrateStep1
    ) public onlyGuardian {
        level4HashrateMin =   _level4HashrateMin;
        level5HashrateMin =   _level5HashrateMin;
        // level6HashrateMin =   _level6HashrateMin;
        level4HashrateMax =   _level4HashrateMax;
        level5HashrateMax =   _level5HashrateMax;
        // level6HashrateMax =   _level6HashrateMax;
        level4HashrateStep =  _level4HashrateStep;
        level5HashrateStep =  _level5HashrateStep;
        // level6HashrateStep =  _level6HashrateStep;
        level4HashrateStep1 = _level4HashrateStep1;
        level5HashrateStep1 = _level5HashrateStep1;
        // level6HashrateStep1 = _level6HashrateStep1;
    }

    function setLevelUpV4(
        uint256[] memory lvs_, 
        uint256[] memory countV1_, 
        uint256[] memory countV2_, 
        uint256[] memory countV3_, 
        uint256[] memory countV4self_,
        uint256[] memory levelV4_
    ) public onlyGuardian {
        require(lvs_.length == countV1_.length && lvs_.length == countV2_.length, "invalid param");
        require(lvs_.length == countV3_.length && lvs_.length == countV4self_.length, "invalid param");
        uint256 level;
        for (uint256 i = 0; i < lvs_.length; ++i) {
            level = lvs_[i];
            // require(level > 0 && level <= levelMaxV4, "invalid prototype");
            uint256 cfgVal = countV1_[i] + (countV2_[i] << 32) + (countV3_[i] << 64) + (countV4self_[i] << 96) + (levelV4_[i] << 128);
            _levelUpV4[level] = cfgVal;
        }
    }

    function setLevelUpV5(
        uint256[] memory lvs_, 
        uint256[] memory countV1_, 
        uint256[] memory countV2_, 
        uint256[] memory countV3_,
        uint256[] memory countV4_, 
        uint256[] memory levelV4_,
        uint256[] memory countV5self_
    ) public onlyGuardian {
        require(lvs_.length == countV1_.length && lvs_.length == countV2_.length && lvs_.length == countV3_.length, "invalid param");
        require(lvs_.length == countV4_.length && lvs_.length == levelV4_.length && lvs_.length == countV5self_.length, "invalid param");
        uint256 level;
        for (uint256 i = 0; i < lvs_.length; ++i) {
            level = lvs_[i];
            // require(level > 0 && level <= levelMaxV5, "invalid prototype");
            uint256 cfgVal = countV1_[i] + (countV2_[i] << 32) + (countV3_[i] << 64) + (countV4_[i] << 96) + (levelV4_[i] << 128) + (countV5self_[i] << 160);
            _levelUpV5[level] = cfgVal;
        }
    }
/*
    function setLevelUpV6(
        uint256[] memory lvs_, 
        uint256[] memory countV1_, 
        uint256[] memory countV2_, 
        uint256[] memory countV3_,
        uint256[] memory countV4_, 
        uint256[] memory levelV4_,
        uint256[] memory countV5_,
        uint256[] memory countV6Self
    ) public onlyGuardian {
        require(lvs_.length == countV1_.length && lvs_.length == countV2_.length && lvs_.length == countV3_.length, "invalid param");
        require(lvs_.length == countV4_.length && lvs_.length == levelV4_.length && lvs_.length == countV5_.length, "invalid param");
        require(lvs_.length == countV6Self.length, "invalid param");
        uint256 level;
        for (uint256 i = 0; i < lvs_.length; ++i) {
            level = lvs_[i];
            require(level > 0 && level <= levelMaxV6, "invalid prototype");
            uint256 cfgVal = countV1_[i] + (countV2_[i] << 32) + (countV3_[i] << 64) + (countV4_[i] << 96) + (levelV4_[i] << 128) + (countV5_[i] << 160) + (countV6Self[i] << 192);
            _levelUpV6[level] = cfgVal;
        }
    }
*/
    // function getURI(uint256 tokenId_, uint256 prototype_) external view returns(string memory uri) {
    //     uri = _ipfsUrisSpecial[tokenId_];
    //     if (bytes(uri).length < 1) {
    //         uri = _ipfsUrisGeneral[prototype_];
    //     } 
    // }


    function getLevelUpV4(uint256 currentLevel_) 
        external 
        view 
        returns(
            uint256 countV1,
            uint256 countV2,
            uint256 countV3,
            uint256 countV4Self,
            uint256 levelV4
        ) 
    {
        uint256 cfgVal = _levelUpV4[currentLevel_];
        // require(cfgVal > 0 && currentLevel_ < levelMaxV4, "level limited");
        countV1 = cfgVal % 0x0100000000;
        countV2 = (cfgVal >> 32) % 0x0100000000;
        countV3 = (cfgVal >> 64) % 0x0100000000;
        countV4Self = (cfgVal >> 96) % 0x0100000000;
        levelV4 = (cfgVal >> 128) % 0x0100000000;
    }

    function getLevelUpV5(uint256 currentLevel_) 
        external 
        view 
        returns(
            uint256 countV1,
            uint256 countV2,
            uint256 countV3,
            uint256 countV4,
            uint256 levelV4,
            uint256 countV5Self
        ) 
    {
        uint256 cfgVal = _levelUpV5[currentLevel_];
        // require(cfgVal > 0 && currentLevel_ < levelMaxV5, "level limited");
        countV1 = cfgVal % 0x0100000000;
        countV2 = (cfgVal >> 32) % 0x0100000000;
        countV3 = (cfgVal >> 64) % 0x0100000000;
        countV4 = (cfgVal >> 96) % 0x0100000000;
        levelV4 = (cfgVal >> 128) % 0x0100000000;
        countV5Self = (cfgVal >> 160) % 0x0100000000;
    }
/*
    function getLevelUpV6(uint256 currentLevel_) 
        external 
        view 
        returns(
            uint256 countV1,
            uint256 countV2,
            uint256 countV3,
            uint256 countV4,
            uint256 levelV4,
            uint256 countV5,
            uint256 countV6Self
        ) 
    {
        uint256 cfgVal = _levelUpV6[currentLevel_];
        require(cfgVal > 0 && currentLevel_ < levelMaxV6, "level limited");
        countV1 = cfgVal % 0x0100000000;
        countV2 = (cfgVal >> 32) % 0x0100000000;
        countV3 = (cfgVal >> 64) % 0x0100000000;
        countV4 = (cfgVal >> 96) % 0x0100000000;
        levelV4 = (cfgVal >> 128) % 0x0100000000;
        countV5 = (cfgVal >> 160) % 0x0100000000;
        countV6Self = (cfgVal >> 192) % 0x0100000000;
    }
*/
    struct Addbase {
        uint128 num;
        uint128 additionPer;
    }

    Addbase[] public lv4pers;
    Addbase[] public lv5pers;

    function setFixBounes(uint256 num) public onlyGuardian {
        FixBounes = num;
    }

    function setLevel4Pers(uint32[] memory lv4Num, uint16[] memory lv4Per) public onlyGuardian {
        require(lv4Num.length == lv4Per.length, "invalid param length");
        delete lv4pers;
        for (uint i = 0; i < lv4Num.length; i++){
            Addbase memory ab = Addbase(lv4Num[i], lv4Per[i]);
            lv4pers.push(ab);
        }
    }

    function setLevel5Pers(uint32[] memory lv5Num, uint16[] memory lv5Per) public onlyGuardian {
        require(lv5Num.length == lv5Per.length, "invalid param length");
        delete lv5pers;
        for (uint i = 0; i < lv5Num.length; i++){
            Addbase memory ab = Addbase(lv5Num[i], lv5Per[i]);
            lv5pers.push(ab);
        }
    }

    //获得算力加成 1 史诗百分比， 2 传说百分比 , 3 固定加成 , 4 最终算力
    function getHashAddition(uint256 suit, uint256 lv4num, uint256 lv5num, uint256 hashrate) public view returns (uint128 lv4per, uint128 lv5per, uint256 bounes, uint256 laseHashrate) {
        bounes = suit * FixBounes;
        for (uint i = lv4pers.length; i > 0; i--) {
            if (lv4num >= lv4pers[i-1].num) {
                lv4per = lv4pers[i-1].additionPer;
                break;
            }
        }
        for (uint i = lv5pers.length; i > 0; i--) {
            if (lv5num >= lv5pers[i-1].num) {
                lv5per = lv5pers[i-1].additionPer;
                break;
            }
        }

        uint256 l4 = 0;
        if (lv4per > 0) {
            l4 = hashrate * lv4per / 10000;
        }

        uint256 l5 = 0;
        if (lv5per > 0) {
            l5 = hashrate * lv5per / 10000;
        }

        laseHashrate = hashrate + l4 + l5 + bounes;
    }

    struct HsTmp {
        uint start;
        uint end;
        uint step;
        uint step1;
        uint rate;
        uint _levelMax;
    }

    function getHashrate(uint q, uint com, uint r) public view returns (uint[] memory _hr, uint[] memory _lhr) {
    // function getHashrate(uint16 q, uint8 com, uint8 r) public  {
        HsTmp memory hst = HsTmp(level4HashrateMin, level4HashrateMax, level4HashrateStep, level4HashrateStep1, r, (levelMax >> 32));

        if (q == 5) {
            hst.start = level5HashrateMin;
            hst.end = level5HashrateMax;
            hst.step = level5HashrateStep;
            hst.step1 = level5HashrateStep1;

            hst._levelMax = SafeMathExt.safe16(levelMax % 0x100000000);
        // } else if (q == 6) {
        //     hst.start = level6HashrateMin;
        //     hst.end = level6HashrateMax;
        //     hst.step = level6HashrateStep;
        //     hst.step1 = level6HashrateStep1;

        //     hst._levelMax = SafeMathExt.safe16(levelMaxV6);
        }

        uint inc1 = (com - hst.start)/2;
        uint inc2;
        if ((com - hst.start)%2==0){
            inc2 = inc1;
        }else{
            inc2 = inc1+1;
        }

        uint _value=0;
        uint _last = com*1;
        uint pianyi = 0;
        

        if ((com * 1000000 - hst.start * 1000000) / 20  < 125000 && com > hst.start){
            pianyi = 125000;
        }else {
            pianyi = (com * 1000000 - hst.start * 1000000)/20;
        }

        uint256 ispianyi=0;
        uint256 lastrate=0;//上次产生偏移时的余数
        uint256 lastlv=0;//上次产生偏移的等级
        uint256 steprate=0;//5级阶梯偏移量

        uint16 xx = 0;
        
        _hr = new uint[](hst._levelMax);
        _lhr = new uint[](hst._levelMax);

        for (uint m=2;m<hst._levelMax + 1;m++){
            uint _last1 = _last;
            if ((m-1)%2>0 && m>1){
                _value = hst.step+inc1;
            }else{
                _value = hst.step+inc2;
            }
            if (m%hst.rate==0&&m>4){


                if ((pianyi*(m * 1000000 / hst.rate) / 1000000) >= 500000){//产生偏移

                    if (pianyi*(m*1000000/hst.rate)/1000000-lastrate>=500000)//减去上次积累的余数
                    {
                        ispianyi ++;
                        _value = _value + ispianyi;
                        lastrate = lastrate +pianyi*((m-lastlv)*1000000/hst.rate)/1000000;
                        if (lastlv > 0) {
                            if ((pianyi*((m-lastlv)*1000000/hst.rate)/1000000)*(((m-lastlv)*1000000)/hst.rate/1000000) >= 500000) {
                                
                                uint x1 = (pianyi*(((m-lastlv)*1000000/hst.rate))/1000000) * (((m-lastlv)*1000000/hst.rate) / 1000000);
                                if (x1 % 1000000 >= 500000) {
                                    x1 = x1 / 1000000 + 1;
                                } else {
                                    x1 = x1 / 1000000;
                                }

                                steprate = steprate+x1;
                                // steprate = steprate+pianyi*(((m-lastlv)*1000/hst.rate)/1000)/1000*((m-lastlv)*1000/hst.rate/1000);
                            }
                        }
                    }

                    if(lastlv == 0){
                        lastlv = m;
                    }
                }
                _value = _value + m*1000000/hst.rate*hst.step1/1000000+steprate;
            }

            _last = _last+_value;
            _hr[xx] = _last;
            _lhr[xx] = _last1;
            xx++;
        }
        // max = _hr[xx-1];
        // max = _last;
    }
}
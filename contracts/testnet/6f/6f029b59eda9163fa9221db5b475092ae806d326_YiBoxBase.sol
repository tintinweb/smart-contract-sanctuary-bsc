// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./YiBoxStandard.sol";

contract Governance {
    address public _governance;
    mapping(address => bool) public _manager;
    constructor() {
        _governance = tx.origin;
        _manager[msg.sender] = true;
    }

    event GovernanceTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyGovernance {
        require(msg.sender == _governance, "not governance");
        _;
    }

    function setGovernance(address governance)  public  onlyGovernance
    {
        require(governance != address(0), "new governance the zero address");
        emit GovernanceTransferred(_governance, governance);
        _governance = governance;
    }

    function addManager(address manager) public onlyGovernance {
        _manager[manager] = true;
    }

    function removeManager(address manager) public onlyGovernance {
        _manager[manager] = false;
    }

    modifier isManager {
        require(_manager[msg.sender], "!manager");
        _;
    }
}

struct HeroGroup {
    uint256 Id;
    uint128 Type;
    uint128 Num;
}

contract YiBoxBase is Governance,YiBoxStandard {
    // --------------------------> shopdata <----------------------------
    mapping(uint256 => address) Seller;
    mapping(uint256 => uint256) SellPrices;
    mapping(uint256 => address) SellCoinType;
    mapping(uint256 => uint256) Time;
    uint256 public GroupIdx = 1000;
    mapping(uint256 => uint256) BoxGroups;
    mapping(uint256 => HeroGroup[]) HeroGroups;

    // --------------------------> 算力 userdata <----------------------------
    mapping (address => Hashrate) hashrates;   //算力池质押人键值对应
    uint256 maxHashrate;                       //池内总算力

    mapping (address => HeroOwner) heroOwners;
    mapping (address => HeroTypeCount) heroTypeCounts;
    
    //总质押记录列表
    mapping (uint256 => uint256) stakeNode; //质押节点，用于记录每次算力变更时的基准收益
    uint256 stakeTimeStamp = 0;                 //最新变更时间

    // --------------------------> 钥匙 userdata <----------------------------
    mapping (address => KeyStake) keystake;   //钥匙质押人键值对应

    //总质押记录列表
    mapping (uint => uint256) public kStakeNode;//质押节点，用于记录每次算力变更时的基准收益
    uint256 kStakeTimeStamp = 0;                 //最新变更时间

    function GetParam(YiBoxType _ty, uint256[] memory id) public view returns (uint256[] memory _res, address[] memory _addr) {
        if (_ty == YiBoxType.ShopGroupIdx) {
            _res = new uint256[](1);
            _res[0] = GroupIdx;
        } else if (_ty == YiBoxType.ShopSeller) {
            _addr = new address[](1);
            _addr[0] = Seller[id[0]];
        } else if (_ty == YiBoxType.ShopPrices) {
            _res = new uint256[](1);
            _res[0] = SellPrices[id[0]];
        } else if (_ty == YiBoxType.ShopCoinType) {
            _addr = new address[](1);
            _addr[0] = SellCoinType[id[0]];
        } else if (_ty == YiBoxType.ShopTime) {
            _res = new uint256[](1);
            _res[0] = Time[id[0]];
        } else if (_ty == YiBoxType.ShopBoxGroups) {
            _res = new uint256[](1);
            _res[0] = BoxGroups[id[0]];
        } 
    }

    function GetParam(YiBoxType _ty) public view returns (uint256 _res) {
        if (_ty == YiBoxType.HashrateMaxHashrate) {
            _res = maxHashrate;
        } else if (_ty == YiBoxType.HashrateStakeTimeStamp) {
            _res = stakeTimeStamp;
        } else if (_ty == YiBoxType.KeyStakeTimeStamp) {
            _res = kStakeTimeStamp;
        }
    }

    function GetParam(YiBoxType _ty, uint256 id) public view returns (uint256 _res) {
        if (_ty == YiBoxType.HashrateStakeNode) {
            _res = stakeNode[id];
        } else if (_ty == YiBoxType.KeyStakeNode) {
            _res = kStakeNode[id];
        }
    }

    function GetLastStakeNode(YiBoxType _ty) public view returns (uint256 _res) {
        if (_ty == YiBoxType.HashrateStakeNode) {
            _res = stakeNode[stakeTimeStamp];
        } else if (_ty == YiBoxType.KeyStakeNode) {
            _res = kStakeNode[kStakeTimeStamp];
        }
        
    }

    function GetHashrate(address id) public view returns (Hashrate memory hashrate) {
        hashrate = hashrates[id];
    }

    function GetKeyStake(address id) public view returns (KeyStake memory kstake) {
        kstake = keystake[id];
    }

    function GetHeroOwner(address id) public view returns (HeroOwner memory _heroOwner) {
        _heroOwner = heroOwners[id];
    }

    function GetHeroTypeCount(address id) public view returns (HeroTypeCount memory _htc) {
        _htc = heroTypeCounts[id];
    }

    function SetHeroOwner(address id, HeroOwner memory _heroOwner) public {
        if (_heroOwner.suit != 0) {
            heroOwners[id].suit = _heroOwner.suit;
        }

        if (_heroOwner.suits != 0) {
            heroOwners[id].suits = _heroOwner.suits;
        }

        if (_heroOwner.L4Count != 0) {
            heroOwners[id].L4Count = _heroOwner.L4Count;
        }

        if (_heroOwner.L5Count != 0) {
            heroOwners[id].L5Count = _heroOwner.L5Count;
        }
    }

    function AddHeroTypeCount(address id, uint256[] memory _tys, uint256[] memory _qus) public returns (uint64 suit, uint64 suits, uint64 l4, uint64 l5) {
        require(_tys.length == _qus.length, "length error");
        for (uint i = 0; i < _tys.length; i++) {
            heroTypeCounts[id].tBase[_tys[i]].qu[_qus[i] - 1] ++;
            if (_qus[i] == 4) {
                heroOwners[id].L4Count++;
                l4 = heroOwners[id].L4Count;
            } else if (_qus[i] == 5) {
                heroOwners[id].L5Count++;
                l5 = heroOwners[id].L5Count;
            }

            if (_qus[i] < 5) {
                uint48 _tmp = heroTypeCounts[id].tBase[_tys[i]].qu[0];
                for (uint _i = 1; _i < 4; _i++) {
                    if (_tmp < heroTypeCounts[id].tBase[_tys[i]].qu[_i]) {
                        _tmp = heroTypeCounts[id].tBase[_tys[i]].qu[_i];
                    }
                }
                if (_tmp > heroTypeCounts[id].tBase[_tys[i]].suit) {
                    if (heroTypeCounts[id].tBase[_tys[i]].suit == 0) {
                        heroOwners[id].suit++;
                        suit = heroOwners[id].suit;
                    }
                    heroOwners[id].suits += _tmp - heroTypeCounts[id].tBase[_tys[i]].suit;
                    heroTypeCounts[id].tBase[_tys[i]].suit = uint16(_tmp);
                    suits = heroOwners[id].suits;
                }
            }
        }
    }

    function SubHeroTypeCount(address id, uint256[] memory _tys, uint256[] memory _qus) public returns (uint64 suit, uint64 suits, uint64 l4, uint64 l5) {
        require(_tys.length == _qus.length, "length error");
        for (uint i = 0; i < _tys.length; i++) {
            heroTypeCounts[id].tBase[_tys[i]].qu[_qus[i] - 1]--;
            if (_qus[i] == 4) {
                require(heroOwners[id].L4Count > 0, "L4Count is 0");
                heroOwners[id].L4Count--;
                l4 = heroOwners[id].L4Count;
            } else if (_qus[i] == 5) {
                require(heroOwners[id].L5Count > 0, "L5Count is 0");
                heroOwners[id].L5Count--;
                l5 = heroOwners[id].L5Count;
            }

            if (_qus[i] < 5) {
                uint48 _tmp = heroTypeCounts[id].tBase[_tys[i]].qu[0];
                for (uint _i = 1; _i < 4; _i++) {
                    if (_tmp < heroTypeCounts[id].tBase[_tys[i]].qu[_i]) {
                        _tmp = heroTypeCounts[id].tBase[_tys[i]].qu[_i];
                    }
                }
                if (_tmp < heroTypeCounts[id].tBase[_tys[i]].suit) {
                    if (heroTypeCounts[id].tBase[_tys[i]].suit > 0 && _tmp == 0) {
                        require(heroOwners[id].suit > 0, "suit is 0");
                        heroOwners[id].suit--;
                        suit = heroOwners[id].suit;
                    }
                    uint64 sublen = heroTypeCounts[id].tBase[_tys[i]].suit - _tmp;
                    require(heroOwners[id].suits >= sublen, "suits size error");
                    heroOwners[id].suits -= sublen;
                    heroTypeCounts[id].tBase[_tys[i]].suit = uint16(_tmp);
                    suits = heroOwners[id].suits;
                }
            }
        }
    }

    function SetParam(YiBoxType _ty, uint256 _res) public isManager {
        if (_ty == YiBoxType.HashrateMaxHashrate) {
            maxHashrate = _res;
        } else if (_ty == YiBoxType.HashrateStakeTimeStamp) {
            stakeTimeStamp = _res;
        } else if (_ty == YiBoxType.KeyStakeTimeStamp) {
            kStakeTimeStamp = _res;
        } 
    }

    function SetParam(YiBoxType _ty, uint256 id, uint256 _res) public isManager {
        if (_ty == YiBoxType.HashrateStakeNode) {
            stakeNode[id] = _res;
        } else if (_ty == YiBoxType.KeyStakeNode) {
            kStakeNode[id] = _res;
        } 
    }

    function SetParam(YiBoxType _ty, uint256[] memory id, uint256[] memory _v1, address[] memory _v2) public isManager {
        if (_ty == YiBoxType.ShopGroupIdx) { 
            SetGroupIdx(_v1[0]);
        } else if (_ty == YiBoxType.ShopSeller) {
            Seller[id[0]] = _v2[0];
        } else if (_ty == YiBoxType.ShopPrices) {
            SellPrices[id[0]] = _v1[0];
        } else if (_ty == YiBoxType.ShopCoinType) {
            SellCoinType[id[0]] = _v2[0];
        } else if (_ty == YiBoxType.ShopTime) {
            Time[id[0]] = _v1[0];
        } else if (_ty == YiBoxType.ShopBoxGroups) {
            BoxGroups[id[0]] = _v1[0];
        } else if (_ty == YiBoxType.ShopHeroGroups) {
            SetHeroGroups(id[0], id[1], _v1[0],_v1[1],_v1[2]);
        }
        else if (_ty == YiBoxType.ShopPricesTimeSellerCoinType) { // 101 = price, time, seller, cointype
            SellPrices[id[0]] = _v1[0];
            Time[id[0]] = _v1[1];
            Seller[id[0]] = _v2[0];
            SellCoinType[id[0]] = _v2[1];
        } else if (_ty == YiBoxType.ShopTimeSeller) { // 102 =  time, seller
            Time[id[0]] = _v1[0];
            Seller[id[0]] = _v2[0];
        } else if (_ty == YiBoxType.ShopBoxTimePriceSellerCointype) { // 103 = box, time, price, seller, cointype
            BoxGroups[id[0]] = _v1[0];
            Time[id[0]] = _v1[1];
            SellPrices[id[0]] = _v1[2];
            Seller[id[0]] = _v2[0];
            SellCoinType[id[0]] = _v2[1];
        } else if (_ty == YiBoxType.HashrateStakeTimeStampStakeNode) {
            stakeTimeStamp = _v1[0];
            stakeNode[id[0]] = _v1[1];
        } else if (_ty == YiBoxType.KeyStakeTimeStampStakeNode) {
            kStakeTimeStamp = _v1[0];
            kStakeNode[id[0]] = _v1[1];
        }
    }

    function SetHashrate(YiBoxType _ty, address addr, Hashrate memory _hr) public isManager { 
        require(addr != address(0), "addr error");
        
        if (_ty == YiBoxType.HashrateSet) {
            if (_hr.hashrate > 0) {
                uint256 _maxHashrate = maxHashrate - hashrates[addr].hashrate;
                hashrates[addr].hashrate = _hr.hashrate;
                maxHashrate = _maxHashrate + _hr.hashrate;
            }
            if (_hr.basehashrate > 0) {
                hashrates[addr].basehashrate = _hr.basehashrate;
            }
            if (_hr.lTime > 0) {
                hashrates[addr].lTime = _hr.lTime;
            }
            if (_hr.allIncome > 0) {
                hashrates[addr].allIncome = _hr.allIncome;
            }
            if (_hr.balance > 0) {
                hashrates[addr].balance = _hr.balance;
            }
        } else if (_ty == YiBoxType.HashrateAdd) {
            if (_hr.hashrate > 0) {
                hashrates[addr].hashrate += _hr.hashrate;
                maxHashrate += _hr.hashrate;
            }
            if (_hr.basehashrate > 0) {
                hashrates[addr].basehashrate += _hr.basehashrate;
            }
            if (_hr.lTime > 0) {
                hashrates[addr].lTime = _hr.lTime;
            }
            if (_hr.allIncome > 0) {
                hashrates[addr].allIncome += _hr.allIncome;
            }
            if (_hr.balance > 0) {
                hashrates[addr].balance += _hr.balance;
            }
        }
        
    }

    function SetKeyStake(YiBoxType _ty, address addr, KeyStake memory _ks) public isManager { 
        require(addr != address(0), "addr error");
        if (_ty == YiBoxType.KeySet) {
            if (_ks.Amount > 0) {
                keystake[addr].Amount = _ks.Amount;
            }
            if (_ks.lastTime > 0) {
                keystake[addr].lastTime = _ks.lastTime;
            }
            if (_ks.allIncome > 0) {
                keystake[addr].allIncome = _ks.allIncome;
            }
            if (_ks.balance > 0) {
                keystake[addr].balance = _ks.balance ;
            }
        } else if (_ty == YiBoxType.KeyAdd) {
            if (_ks.Amount > 0) {
                keystake[addr].Amount += _ks.Amount;
            }
            if (_ks.allIncome > 0) {
                keystake[addr].allIncome += _ks.allIncome;
            }
            if (_ks.lastTime > 0) {
                keystake[addr].lastTime = _ks.lastTime;
            }
            if (_ks.balance > 0) {
                keystake[addr].balance += _ks.balance;
            }
        }
    }

    function SetGroupIdx(uint256 _GroupIdx) internal { 
        if( _GroupIdx == 0) {
            GroupIdx++;
        } else {
            GroupIdx = _GroupIdx;
        }
    }
    
    function GetHeroGroups(uint256 _gid) public view returns (uint256[] memory _ids, uint256[] memory _types, uint256[] memory _nums, uint256 _len) {
        _len = HeroGroups[_gid].length;
        if (_len == 0) {
            _ids = new uint256[](1);
            _types = new uint256[](1);
            _nums = new uint256[](1);
        } else {
            _ids = new uint256[](_len);
            _types = new uint256[](_len);
            _nums = new uint256[](_len);

            for (uint i = 0; i < _len; i++) {
                
                _nums[i] = HeroGroups[_gid][i].Id;
                _types[i] = HeroGroups[_gid][i].Type;
                _ids[i] = HeroGroups[_gid][i].Num;
            }
        }
    }

    function SetHeroGroups(uint256 _gid, uint256 _idx,uint256 _id, uint256 _type, uint256 _num) internal {
        // uint256 _hg = (_id << 64) + (_type << 32) + _num;
        HeroGroup memory _hg = HeroGroup(_id, uint128(_type), uint128(_num));
        if (_idx == 0 || _idx >= HeroGroups[_gid].length) {
            HeroGroups[_gid].push(_hg);
        } else {
            HeroGroups[_gid][_idx] = _hg;
        }
    }
}
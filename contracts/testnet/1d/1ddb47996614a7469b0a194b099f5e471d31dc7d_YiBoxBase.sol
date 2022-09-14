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
    mapping(uint256 => address) public Seller;
    mapping(uint256 => uint256) public SellPrices;
    mapping(uint256 => address) public SellCoinType;
    mapping(uint256 => uint256) public Time;
    uint256 public GroupIdx = 1000;
    mapping(uint256 => uint256) public BoxGroups;
    mapping(uint256 => HeroGroup[]) public HeroGroups;
    mapping(address => uint256[]) public GroupOwners;

    // --------------------------> 算力 userdata <----------------------------
    mapping (address => Hashrate) public hashrates;   //算力池质押人键值对应
    uint256 public maxHashrate;                       //池内总算力

    mapping (address => uint256) public heroOwners;

    // 0 = qu 1, 32 = qu2, 64 = qu3, 96 = qu4, 128 = qu5, 160 = suit
    mapping (address => mapping(uint256 => uint256)) public heroTypeCounts;
    
    //总质押记录列表
    mapping (uint256 => uint256) public stakeNode; //质押节点，用于记录每次算力变更时的基准收益
    uint256 public stakeTimeStamp = 0;                 //最新变更时间

    // --------------------------> 钥匙 userdata <----------------------------
    mapping (address => KeyStake) public keystake;   //钥匙质押人键值对应

    //总质押记录列表
    mapping (uint => uint256) public kStakeNode;//质押节点，用于记录每次算力变更时的基准收益
    uint256 public kStakeTimeStamp = 0;                 //最新变更时间

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

    function GetHeroOwner(address id) public view returns (uint256 suit, uint256 suits, uint256 l4, uint256 l5) {
        // _heroOwner = heroOwners[id];
        uint256 _ho = heroOwners[id];
        
        suit = _ho % 0x100000000;
        suits = (_ho >> 32) % 0x100000000;
        l4 = (_ho >> 64) % 0x100000000;
        l5 = (_ho >> 96) % 0x100000000;
    }

    function GetHeroTypeCount(address id, uint256 typeid) public view returns (uint256 _qu1, uint256 _qu2,uint256 _qu3, uint256 _qu4,uint256 _qu5, uint256 _suit) {
        uint256 _htc = heroTypeCounts[id][typeid];
        _qu1 = _htc % 0x100000000;
        _qu2 = (_htc >> 32) % 0x100000000;
        _qu3 = (_htc >> 64) % 0x100000000;
        _qu4 = (_htc >> 96) % 0x100000000;
        _qu5 = (_htc >> 128) % 0x100000000;
        _suit = (_htc >> 160) % 0x100000000;
    }

    function SetHeroOwner(address id, uint256 suit, uint256 suits, uint256 l4, uint256 l5) public {
        uint256 _ho = heroOwners[id];
        uint256 _suit = _ho % 0x100000000;
        uint256 _suits = (_ho >> 32) % 0x100000000;
        uint256 _l4 = (_ho >> 64) % 0x100000000;
        uint256 _l5 = (_ho >> 96) % 0x100000000;

        if (suit != 0) {
            _suit = suit;
        }

        if (suits != 0) {
            _suits = suits;
        }

        if (l4 != 0) {
            _l4 = l4;
        }

        if (l5 != 0) {
            _l5 = l5;
        }

        heroOwners[id] = _suit + (_suits << 32) + (_l4 << 64) + (_l5 << 96);
    }

    function AddHeroTypeCount(address id, uint256[] memory _tys, uint256[] memory _qus) public returns (uint256 suit, uint256 suits, uint256 l4, uint256 l5, bool isChange) {
        require(_tys.length == _qus.length, "length error");
        uint256 _ho = heroOwners[id];
        suit = _ho % 0x100000000;
        suits = (_ho >> 32) % 0x100000000;
        l4 = (_ho >> 64) % 0x100000000;
        l5 = (_ho >> 96) % 0x100000000;
        isChange = false;
        for (uint i = 0; i < _tys.length; i++) {
            uint256 _htc = heroTypeCounts[id][_tys[i]];
            // 0 = qu 1, 32 = qu2, 64 = qu3, 96 = qu4, 128 = qu5, 160 = suit
            uint256[6] memory _base;
            _base[0] = _htc % 0x100000000;
            _base[1] = (_htc >> 32) % 0x100000000;
            _base[2] = (_htc >> 64) % 0x100000000;
            _base[3] = (_htc >> 96) % 0x100000000;
            _base[4] = (_htc >> 128) % 0x100000000;
            _base[5] = (_htc >> 160) % 0x100000000;

            _base[_qus[i] - 1]++;
            if (_qus[i] == 4) {
                l4++;
                isChange = true;
            } else if (_qus[i] == 5) {
                l5++;
                isChange = true;
            }

            if (_qus[i] < 5) {
                uint256 _tmp = _base[0];
                for (uint _i = 1; _i < 4; _i++) {
                    if (_tmp > _base[_i]) {
                        _tmp = _base[_i];
                    }
                }
                if (_tmp != 0 && _tmp > _base[5]) {
                    if (_base[5] == 0) {
                        suit++;
                        isChange = true;
                    }
                    suits += _tmp - _base[5];
                    _base[5] = _tmp;
                    isChange = true;
                }
            }
            heroTypeCounts[id][_tys[i]] = _base[0] + (_base[1] << 32) + (_base[2] << 64) + (_base[3] << 96) + (_base[4] << 128) + (_base[5] << 160);
        }
        heroOwners[id] = suit + (suits << 32) + (l4 << 64) + (l5 << 96);
    }

    function SubHeroTypeCount(address id, uint256[] memory _tys, uint256[] memory _qus) public returns (uint256 suit, uint256 suits, uint256 l4, uint256 l5, bool isChange) {
        require(_tys.length == _qus.length, "length error");
        // uint256 _ho = heroOwners[id];
        suit = heroOwners[id] % 0x100000000;
        suits = (heroOwners[id] >> 32) % 0x100000000;
        l4 = (heroOwners[id] >> 64) % 0x100000000;
        l5 = (heroOwners[id] >> 96) % 0x100000000;
        isChange = false;
        for (uint i = 0; i < _tys.length; i++) {
            uint256 _htc = heroTypeCounts[id][_tys[i]];
            // 0 = qu 1, 32 = qu2, 64 = qu3, 96 = qu4, 128 = qu5, 160 = suit
            uint256[6] memory _base;
            _base[0] = _htc % 0x100000000;
            _base[1] = (_htc >> 32) % 0x100000000;
            _base[2] = (_htc >> 64) % 0x100000000;
            _base[3] = (_htc >> 96) % 0x100000000;
            _base[4] = (_htc >> 128) % 0x100000000;
            _base[5] = (_htc >> 160) % 0x100000000;
            _base[_qus[i] - 1]--;
            if (_qus[i] == 4) {
                require(l4 > 0, "L4Count is 0");
                l4--;
                isChange = true;
            } else if (_qus[i] == 5) {
                require(l5 > 0, "L5Count is 0");
                l5--;
                isChange = true;
            }

            if (_qus[i] < 5) {
                uint256 _tmp = _base[0];
                for (uint _i = 1; _i < 4; _i++) {
                    if (_tmp > _base[_i]) {
                        _tmp = _base[_i];
                    }
                }
                if (_tmp < _base[5]) {
                    if (_base[5] > 0 && _tmp == 0) {
                        require(suit > 0, "suit is 0");
                        suit--;
                        isChange = true;
                    }
                    uint256 sublen = _base[5] - _tmp;
                    require(suits >= sublen, "suits size error");
                    suits -= sublen;
                    _base[5] = _tmp;
                    isChange = true;
                }
            }
            heroTypeCounts[id][_tys[i]] = _base[0] + (_base[1] << 32) + (_base[2] << 64) + (_base[3] << 96) + (_base[4] << 128) + (_base[5] << 160);
        }
        heroOwners[id] = suit + (suits << 32) + (l4 << 64) + (l5 << 96);
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
            if (id.length > 1) {
                SetHeroGroups(id[0], id[1], _v1[0],_v1[1],_v1[2]);
            } else {
                SetHeroGroups(id[0], 0, _v1[0],_v1[1],_v1[2]);
            }
        }
        else if (_ty == YiBoxType.ShopPricesTimeSellerCoinType) { // 101 = price, time, seller, cointype
            SellPrices[id[0]] = _v1[0];
            Time[id[0]] = _v1[1];
            Seller[id[0]] = _v2[0];
            SellCoinType[id[0]] = _v2[1];
        } else if (_ty == YiBoxType.ShopTimeSeller) { // 102 =  time, seller
            Time[id[0]] = _v1[0];
            Seller[id[0]] = _v2[0];
            if (_v1[0] == 0 && _v2[0] == address(0)) {
                // uint256 _pos;
                uint256 gol = GroupOwners[tx.origin].length;
                for (uint i = 0; i < gol; i++){
                    if (GroupOwners[tx.origin][i] == id[0]) {
                        GroupOwners[tx.origin][i] = GroupOwners[tx.origin][gol - 1];
                        GroupOwners[tx.origin].pop();
                        break;
                    }
                }
            }
        } else if (_ty == YiBoxType.ShopBoxTimePriceSellerCointype) { // 103 = box, time, price, seller, cointype
            BoxGroups[id[0]] = _v1[0];
            // Time[id[0]] = _v1[1];
            SellPrices[id[0]] = _v1[1];
            SellCoinType[id[0]] = _v2[0];
            Seller[id[0]] = _v2[1];
        } else if (_ty == YiBoxType.HashrateStakeTimeStampStakeNode) {
            stakeTimeStamp = _v1[0];
            stakeNode[_v1[0]] = _v1[1];
        } else if (_ty == YiBoxType.KeyStakeTimeStampStakeNode) {
            kStakeTimeStamp = _v1[0];
            kStakeNode[_v1[0]] = _v1[1];
        }
    }

    function SetHashrate(YiBoxType _ty, address addr, Hashrate memory _hr) public isManager { 
        require(addr != address(0), "addr error");
        
        if (_ty == YiBoxType.HashrateSet) {
            /*
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
            */
            if (_hr.info > 0) {
                uint256 hs1 = (hashrates[addr].info >> 64) % 0x10000000000000000;
                uint256 hs2 = (_hr.info >> 64) % 0x10000000000000000;
                hashrates[addr].info = _hr.info;
                if (hs1 != hs2) {
                    maxHashrate = maxHashrate - hs1 + hs2;
                }
            }
            if (_hr.allIncome > 0) {
                hashrates[addr].allIncome = _hr.allIncome;
            }
            if (_hr.balance > 0) {
                hashrates[addr].balance = _hr.balance;
            }
        } 
        // else if (_ty == YiBoxType.HashrateAdd) {
        //     if (_hr.hashrate > 0) {
        //         hashrates[addr].hashrate += _hr.hashrate;
        //         maxHashrate += _hr.hashrate;
        //     }
        //     if (_hr.basehashrate > 0) {
        //         hashrates[addr].basehashrate += _hr.basehashrate;
        //     }
        //     if (_hr.lTime > 0) {
        //         hashrates[addr].lTime = _hr.lTime;
        //     }
        //     if (_hr.allIncome > 0) {
        //         hashrates[addr].allIncome += _hr.allIncome;
        //     }
        //     if (_hr.balance > 0) {
        //         hashrates[addr].balance += _hr.balance;
        //     }
        // }
        
    }

    function SetKeyStake(YiBoxType _ty, address addr, KeyStake memory _ks) public isManager { 
        require(addr != address(0), "addr error");
        if (_ty == YiBoxType.KeySet) {
            if (_ks.Amount != 0) {
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
        GroupOwners[tx.origin].push(GroupIdx);
        if( _GroupIdx == 0) {
            GroupIdx++;
        } else {
            GroupIdx = _GroupIdx;
        }
    }

    function GetAllParamByGroupID(uint256 _groupid) public view returns (address _seller, uint256 _SellPrices, address _SellCoinType, uint256 _Time, uint256 _BoxGroups, HeroGroup[] memory _HeroGroups) {
        require(_groupid >= 1000, "_groupid error");
        _seller = Seller[_groupid];
        _SellPrices = SellPrices[_groupid];
        _SellCoinType = SellCoinType[_groupid];
        _Time = Time[_groupid];
        _BoxGroups = BoxGroups[_groupid];
        _HeroGroups = HeroGroups[_groupid];
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
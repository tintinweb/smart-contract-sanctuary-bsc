//"SPDX-License-Identifier:UNLICENSED"
pragma solidity 0.8.0;

import "./Ownable.sol";

contract RelationStorage {

    struct MeData {
        uint ts; // 时间
        address me; // 我的地址
        address father; // 上级地址
        uint layout; // 层级
        uint idx; // 所在下标
        uint level; // 级别
        uint dirReward; // 直推奖励
        uint communityReward; // 社区奖励
    }

    uint public totalAddresses;
    //地址关联我的推荐详细信息
    mapping (address => MeData) internal _meMapping;
    //推荐金字塔
    mapping (uint => mapping (uint => MeData)) internal _pyramid;

    constructor() {
    }
}

contract PyramidRelation is Ownable, RelationStorage() {

    modifier onlyIDO() {
        require(msg.sender == IDO, "PyramidRelation: caller is not the IDO");
        _;
    }

    address public IDO;

    constructor(address devAddr) {
        _meMapping[devAddr] = MeData(block.timestamp, devAddr, address(0), 1, 1, 10, 0, 0);
        _pyramid[1][1] = _meMapping[devAddr];
    }

    // 绑定关系
    function addRelationEx(address recommer, address to) public onlyIDO returns (bool stat, address father) {
        require (recommer != to, "yourself"); // 不能是自己
        require (_meMapping[to].me == address(0),"binded"); // 自己未绑定上级
        require (_meMapping[recommer].me != address(0), "error recommer"); // 不存在的上级
        totalAddresses++;
        // 修改直接上级直推人数
        MeData storage recommerData = _meMapping[recommer];
        MeData memory me;
        //三三滑落
        uint last = recommerData.idx;
        for (uint i = recommerData.layout + 1; i <= 10; i++) {
            uint num = 3**(i - recommerData.layout);
            last = last * 3;
            for (uint j = last + 1 - num; j <= last; j++ ) { 
                if (_pyramid[i][j].me == address(0)) {
                    _pyramid[i][j] = MeData(block.timestamp, to, fatherByIdx(i, j).me, i, j, 1, 0, 0);
                    _meMapping[to] = _pyramid[i][j];
                    MeData memory f = fatherByIdx(i, j);
                    father = f.me;
                    me = _pyramid[i][j];
                    i = 11;
                    break;
                }
            }
        }
        if (father != address(0)) {
            stat = true;
        }
    }

    function getDirPushFather(address recommer) public view returns (address) {
        MeData storage recommerData = _meMapping[recommer];
        MeData memory f;
        //三三滑落
        uint last = recommerData.idx;
        for (uint i = recommerData.layout + 1; i <= 10; i++) {
            uint num = 3**(i - recommerData.layout);
            last = last * 3;
            for (uint j = last + 1 - num; j <= last; j++ ) { 
                if (_pyramid[i][j].me == address(0)) {
                    f = fatherByIdx(i, j);
                    i = 11;
                    break;
                }
            }
        }
        return f.me;
    }

    // 返回自己直推的三个下级，包含0地址
    function getDirPush(address owner) public view returns(address[] memory dirPushs){
        MeData memory me = _meMapping[owner];
        dirPushs = new address[](3);
        uint j = 0;
        if (me.layout > 0 && me.idx > 0) {
            for (uint256 i = me.idx * 3; i >= me.idx * 3 - 2; i--) {
                dirPushs[j] = _pyramid[me.layout + 1][i].me;
                j++;
            }
        }
    }

    // 返回层级和下标的上级
    function fatherByIdx(uint layout, uint idx) public view returns (MeData memory father) {
        if (layout == 1) {
            father = _pyramid[layout][idx];
        } else {
            father = _pyramid[layout - 1][(idx + 2) / 3];
        }
    }

    function fatherByLevel(address addr, uint level) public view returns (MeData memory father) {
        require (level <= 10, "Wrong level");
        father = _meMapping[addr];
        for (uint i = 0; i < level; i++) {
            father = fatherByIdx(father.layout, father.idx);
        }
    }


    // 返回直推链条的往上直到顶级
    function getFathers(address owner) public view returns(address[] memory fathers){
        MeData memory me = _meMapping[owner];
        fathers = new address[]((me.layout > 10) ? 10 : me.layout - 1);
        for (uint i = 0; i < fathers.length; i++) {
            me = fatherByIdx(me.layout, me.idx);
            fathers[i] = me.me;
        }
    }

    function levelUp(address addr) public onlyIDO returns (bool stat, address father) {
        MeData storage me = _meMapping[addr];
        require (me.level > 0 && me.level < 10, "Wrong");
        father = fatherByLevel(me.me, me.level + 1).me;
        if (father != address(0)) {
            me.level++;
            stat = true;
        }
    }

    function info(address addr) public view returns (MeData memory ret) {
        ret = _meMapping[addr];
    }

    function addReward(address addr, uint dirReward, uint communityReward) public onlyIDO {
        MeData storage me = _meMapping[addr];
        me.dirReward += dirReward;
        me.communityReward += communityReward;
    }

    function setIDO(address I) external onlyOwner {
        IDO = I;
    }
}
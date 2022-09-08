/**
 *Submitted for verification at BscScan.com on 2022-09-07
*/

//"SPDX-License-Identifier:UNLICENSED"
pragma solidity 0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract RelationStorage {

    struct MeData {
        uint ts; // 时间
        address me; // 我的地址
        address father; // 上级地址
        uint dirPushQuantity; // 直推人数
        uint layout; // 层级
        uint idx; // 所在下标
        uint level; // 级别
        uint community; // 社区总人数
        uint dirReward; // 直推奖励
        uint communityReward; // 社区奖励
    }

    // address public rootAddress = "0xa4A0cD398b2092E516a4695096419635b1E0a003";

    uint public totalAddresses;
    //地址关联我的推荐详细信息
    mapping (address => MeData) internal _meMapping;
    //推荐金字塔
    mapping (uint => mapping (uint => MeData)) internal _pyramid;

    constructor() {
    }
}

contract PyramidRelation is Ownable, RelationStorage() {

    constructor(address contractAddr, address devAddr) {
        transferOwnership(contractAddr);
        _meMapping[devAddr] = MeData(block.timestamp, devAddr, address(0), 0, 1, 1, 10, 0, 0, 0);
        _pyramid[1][1] = _meMapping[devAddr];
    }

    // 绑定关系
    function addRelationEx(address recommer) public onlyOwner returns (bool stat, address father) {
        require (recommer != msg.sender, "yourself"); // 不能是自己
        require (_meMapping[msg.sender].me == address(0),"binded"); // 自己未绑定上级
        require (_meMapping[recommer].me != address(0), "error recommer"); // 不存在的上级
        totalAddresses++;
        // 修改直接上级直推人数
        MeData storage recommerData = _meMapping[recommer];
        MeData memory me;
        recommerData.dirPushQuantity += 1;
        //三三滑落
        uint last = recommerData.idx;
        for (uint i = recommerData.layout + 1; i <= 10; i++) {
            uint num = 3**(i - recommerData.layout);
            uint newIdx = last * num;
            last = newIdx;
            for (uint j = newIdx - num + 1; j <= newIdx; j++ ) {
                if (_pyramid[i][j].me == address(0)) {
                    _pyramid[i][j] = MeData(block.timestamp, msg.sender, fatherByIdx(i, j).me, 0, i, j, 1, 0, 0, 0);
                    _meMapping[msg.sender] = _pyramid[i][j];
                    father = fatherByIdx(i, j).me;
                    me = _pyramid[i][j];
                    break;
                }
            }
        }
        // 修改社区人数
        uint x = 0;
        for (uint y = me.layout; y > 0; y--) {
            me = fatherByIdx(me.layout, me.idx);
            me.community++;
            _pyramid[me.layout][me.idx] = me;
            x++;
            if (x >= 10) {
                break;
            }
        }
        if (father != address(0)) {
            stat = true;
        }
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
    function fatherByIdx(uint layout, uint idx) private view returns (MeData memory father) {
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
    function getFathers(address owner) external view returns(address[] memory fathers){
        MeData memory me = _meMapping[owner];
        fathers = new address[]((me.layout > 10) ? 10 : me.layout - 1);
        for (uint i = 0; i < fathers.length; i++) {
            me = fatherByIdx(me.layout, me.idx);
            fathers[i] = me.me;
        }
    }

    function levelUp(address addr) public onlyOwner returns (bool stat, address father) {
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

    function addReward(address addr, uint dirReward, uint communityReward) public onlyOwner {
        MeData storage me = _meMapping[addr];
        me.dirReward += dirReward;
        me.communityReward += communityReward;
    }
}
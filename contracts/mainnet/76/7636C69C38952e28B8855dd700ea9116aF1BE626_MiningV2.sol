/**
 *Submitted for verification at BscScan.com on 2022-11-26
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}


abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "Math error");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(a >= b, "Math error");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "Math error");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a / b;
        return c;
    }
}

library SafeCast {
    function toUint248(uint256 value) internal pure returns (uint248) {
        require(value <= type(uint248).max, "SafeCast: value doesn't fit in 248 bits");
        return uint248(value);
    }

    function toUint240(uint256 value) internal pure returns (uint240) {
        require(value <= type(uint240).max, "SafeCast: value doesn't fit in 240 bits");
        return uint240(value);
    }

    function toUint232(uint256 value) internal pure returns (uint232) {
        require(value <= type(uint232).max, "SafeCast: value doesn't fit in 232 bits");
        return uint232(value);
    }

    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    function toUint216(uint256 value) internal pure returns (uint216) {
        require(value <= type(uint216).max, "SafeCast: value doesn't fit in 216 bits");
        return uint216(value);
    }

    function toUint208(uint256 value) internal pure returns (uint208) {
        require(value <= type(uint208).max, "SafeCast: value doesn't fit in 208 bits");
        return uint208(value);
    }

    function toUint200(uint256 value) internal pure returns (uint200) {
        require(value <= type(uint200).max, "SafeCast: value doesn't fit in 200 bits");
        return uint200(value);
    }

    function toUint192(uint256 value) internal pure returns (uint192) {
        require(value <= type(uint192).max, "SafeCast: value doesn't fit in 192 bits");
        return uint192(value);
    }

    function toUint184(uint256 value) internal pure returns (uint184) {
        require(value <= type(uint184).max, "SafeCast: value doesn't fit in 184 bits");
        return uint184(value);
    }

    function toUint176(uint256 value) internal pure returns (uint176) {
        require(value <= type(uint176).max, "SafeCast: value doesn't fit in 176 bits");
        return uint176(value);
    }

    function toUint168(uint256 value) internal pure returns (uint168) {
        require(value <= type(uint168).max, "SafeCast: value doesn't fit in 168 bits");
        return uint168(value);
    }

    function toUint160(uint256 value) internal pure returns (uint160) {
        require(value <= type(uint160).max, "SafeCast: value doesn't fit in 160 bits");
        return uint160(value);
    }

    function toUint152(uint256 value) internal pure returns (uint152) {
        require(value <= type(uint152).max, "SafeCast: value doesn't fit in 152 bits");
        return uint152(value);
    }

    function toUint144(uint256 value) internal pure returns (uint144) {
        require(value <= type(uint144).max, "SafeCast: value doesn't fit in 144 bits");
        return uint144(value);
    }

    function toUint136(uint256 value) internal pure returns (uint136) {
        require(value <= type(uint136).max, "SafeCast: value doesn't fit in 136 bits");
        return uint136(value);
    }

    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    function toUint120(uint256 value) internal pure returns (uint120) {
        require(value <= type(uint120).max, "SafeCast: value doesn't fit in 120 bits");
        return uint120(value);
    }

    function toUint112(uint256 value) internal pure returns (uint112) {
        require(value <= type(uint112).max, "SafeCast: value doesn't fit in 112 bits");
        return uint112(value);
    }

    function toUint104(uint256 value) internal pure returns (uint104) {
        require(value <= type(uint104).max, "SafeCast: value doesn't fit in 104 bits");
        return uint104(value);
    }

    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    function toUint88(uint256 value) internal pure returns (uint88) {
        require(value <= type(uint88).max, "SafeCast: value doesn't fit in 88 bits");
        return uint88(value);
    }

    function toUint80(uint256 value) internal pure returns (uint80) {
        require(value <= type(uint80).max, "SafeCast: value doesn't fit in 80 bits");
        return uint80(value);
    }

    function toUint72(uint256 value) internal pure returns (uint72) {
        require(value <= type(uint72).max, "SafeCast: value doesn't fit in 72 bits");
        return uint72(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    function toUint56(uint256 value) internal pure returns (uint56) {
        require(value <= type(uint56).max, "SafeCast: value doesn't fit in 56 bits");
        return uint56(value);
    }

    function toUint48(uint256 value) internal pure returns (uint48) {
        require(value <= type(uint48).max, "SafeCast: value doesn't fit in 48 bits");
        return uint48(value);
    }

    function toUint40(uint256 value) internal pure returns (uint40) {
        require(value <= type(uint40).max, "SafeCast: value doesn't fit in 40 bits");
        return uint40(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    function toUint24(uint256 value) internal pure returns (uint24) {
        require(value <= type(uint24).max, "SafeCast: value doesn't fit in 24 bits");
        return uint24(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }
}


// safe transfer
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        // (bool success,) = to.call.value(value)(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}


interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// owner
contract Ownable {
    address public owner;

    constructor(address owner_) {
        owner = owner_;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'Token: owner error');
        _;
    }

    function renounceOwnership() public onlyOwner {
        owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}


// 接口
interface ILinkedin {
    function mySuper(address user) external view returns (address);
    function myJuniors(address user) external view returns (address[] memory);
    function getSuperList(address user, uint256 list) external view returns (address[] memory);
}

// 接口
interface IETEDIDNFT {
    function getRank(address _user) external view returns(uint256);
    function getCrystals(address _user) external view returns(uint256);
    function getFreeze(address _user) external view returns(bool);
    function mintDIDNFT(address user, uint256 amount) external;
    function mintCrystals(address user, uint256 amount) external;
    function burnCrystals(address user, uint256 amount) external;
}


// MiningV2合约
contract MiningV2 is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    // 当前的轮次，假如是10，1-10;
    uint256 public turn;
    // 轮->期号
    mapping(uint256 => uint256) public issue;
    // 轮->期号->期号的详情
    mapping(uint256 => mapping(uint256 => IssueMsg)) private _IssueMsg;
    struct IssueMsg {
        // 价值的U的总量
        uint256 totalUsdt;
        // 本期可质押的LP总量。三种池子各1/3
        uint256 total;
        // 普通用户可质押数量
        uint256 userCount;
        // 普通nft可质押数量
        uint256 nft1Count;
        // 高级nft用户可质押数量
        uint256 nft2Count;
        // 开始购买时间
        uint256 startTime;
        // 结束购买的时间
        uint256 endTime;
        // 可以领取时间
        uint256 canTakeTime;
        // 已经领取金额
        uint256 takedCount;
        // 本期的状态
        // 1 = 不能领取收益，不能领取本金，没有质押满。   需要等待下一轮开始了才可以拿走本金，因为是没有质押或没有质押满。
        // 2 = 不能领取收益，不能领取本金，质押满了。     需要等待下一轮开始了才可以拿走本金(可能有收益)，因为下一期不知道会不会质押满。一下期满了，就可以拿走本金和收益，下一期没满只能拿走本金。
        // 3 = 可以领取收益+本金。                      因为下一期质押满了，所以这一期本金和收益都可以拿走。  
        // 4 = 可以领取本金。                           需要等待下一轮开始了才可以拿走本金，虽然自己是质押满了，还是下一期没有质押满。
        uint256 status;
        // usdt价格，价值的ETE，也就是1e18个USDT等于多少ETE
        uint256 usdtPrice;
    }
    
    
    uint256 private _dayTime; // 每天的时间，主网86400，测试网60
    // 每期的时间
    uint256 public oneIssueTime; // 默认7天
    // token地址
    address public ete;
    address public eteUsdtLp;
    address public eteDIDNFT;
    address public team;
    address public leader;
    address public linkedin;
    // 每个地址可质押的总量，总池子的万分之100
    uint256 public canRatio = 50;
    // 扣除水晶的百分之比，2%，质押100U就扣2个，最少扣除一个，向下取整扣水晶。
    uint256 public burnCrystalsRatio = 2;
    // 质押的开关
    bool public isOpen = true;


    //////////////////////////////////////////////////////////////////
    // 用户全部的质押订单。(用户地址+轮次+期号=订单号)，所以同用户同轮同期的订单是计算在一起的，只有一个订单。
    mapping(address => bytes32[]) public userOrders;
    // 订单所属者
    mapping(bytes32 => address) public orderOwnerOf;
    // 订单 -> 订单的详情
    mapping(bytes32 => OrderMsg) public userOrderMsg;
    struct OrderMsg {
        // 购买的数量，可能会多次购买，需要累积。
        uint128 count;
        // 提取除去的数量，（本金加收益，一次领取，只记录收益数量）。
        uint128 takedAmount;
        // 购买时候的身份。如果本期购买两次时候的身份不一样怎么办，那本期就不能再质押了。
        uint64 didNFT;
        // 属于哪一轮
        uint64 turnOf;
        // 属于哪一期
        uint64 issueOf;
        // 是否领取（0=没有领取，3=已经领取了本金和收益，4=已经领取了本金）
        uint64 isTaked;
    }
    

    // 进入某一期号
    event StartIssue(uint256 turn, uint256 issue, uint256 total, uint256 startTime, uint256 endTime);
    // 用户质押
    event UserDeposit(uint256 turn, uint256 issue, address user, uint256 didNFT, uint256 amount);
    // 用户领取收益事件
    event UserTake(uint256 turn, uint256 issue, address user, uint256 lpAmount, uint256 earn);
    // 团队分红总量
    event TeamTake(uint256 turn, uint256 issue, address team, uint256 earn);
    // 修改本期结束时间
    event SetNowIssueEndTime(uint256 turn, uint256 issue, uint256 oldEndTime, uint256 nowEndTime);


    constructor(
        uint256 dayTime_,
        address owner_,
        address ete_,
        address eteUsdtLp_,
        address eteDIDNFT_,
        address team_,
        address leader_,
        address linkedin_
    ) Ownable(owner_) {
        _dayTime = dayTime_;  // 主网为86400，测试网100。
        oneIssueTime = _dayTime * 7;

        ete = ete_;
        eteUsdtLp = eteUsdtLp_;
        eteDIDNFT = eteDIDNFT_;
        team = team_;
        leader = leader_;
        linkedin = linkedin_;

        // 默认第一轮 第一期
        turn = 1;
        issue[turn] = 1;
        // 开始第一轮第一期
        _startIssue(turn, issue[turn], 100000*(10**18));
    }

    // 设置每期的持续时间，下一期生效。如7天就是说7天。
    function setOneIssueTime(uint256 _dayNumber) public onlyOwner {
        require(_dayNumber > 0 && _dayNumber < 30, "time error");
        oneIssueTime = _dayTime * _dayNumber;
    }

    // 设置ete
    function setEte(address _ete) public onlyOwner {
        require(_ete != address(0), "0 address error");
        ete = _ete;
    }
    // 设置eteUsdtLp
    function setEteUsdtLp(address _eteUsdtLp) public onlyOwner {
        require(_eteUsdtLp != address(0), "0 address error");
        eteUsdtLp = _eteUsdtLp;
    }
    // 设置eteDIDNFT
    function setEteDIDNFT(address _eteDIDNFT) public onlyOwner {
        require(_eteDIDNFT != address(0), "0 address error");
        eteDIDNFT = _eteDIDNFT;
    }
    // 设置team
    function setTeam(address _team) public onlyOwner {
        require(_team != address(0), "0 address error");
        team = _team;
    }
    // 设置leader
    function setLeader(address _leader) public onlyOwner {
        require(_leader != address(0), "0 address error");
        leader = _leader;
    }
    // 设置linkedin
    function setLinkedin(address _linkedin) public onlyOwner {
        require(_linkedin != address(0), "0 address error");
        linkedin = _linkedin;
    }
    // 设置每个地址可质押的占比
    function setCanRatio(uint256 _canRatio) public onlyOwner {
        require(_canRatio > 0 && _canRatio < 10000, "canRatio error");
        canRatio = _canRatio;
    }
    // 设置消耗水晶的百分比
    function setBurnCrystalsRatio(uint256 _burnCrystalsRatio) public onlyOwner {
        require(_burnCrystalsRatio > 0 && _burnCrystalsRatio < 100, "canRatio error");
        burnCrystalsRatio = _burnCrystalsRatio;
    }
    // 设置质押的开关
    function setIsOpen(bool _isOpen) public onlyOwner {
        isOpen = _isOpen;
    }


    // 查询某轮某期的详情
    function getIssueMsg(uint256 _turn, uint256 _issue) public view returns(IssueMsg memory) {
        return _IssueMsg[_turn][_issue];
    }

    // 查询全部的期号
    function getAllIssue() public view returns(uint256[] memory) {
        uint256[] memory _allIssues = new uint256[](turn);
        for(uint256 i = 1; i <= turn; i++) {
            _allIssues[i-1] = issue[i];
        }
        return _allIssues;
    }

    // 查询全部轮的全部期号的详情
    function getAllIssueMsg() public view returns(IssueMsg[] memory) {
        uint256 totalIssue;
        for(uint256 i0 = 1; i0 <= turn; i0++) {
            totalIssue = totalIssue.add(issue[i0]);
        }
        IssueMsg[] memory _allIssuesMsg = new IssueMsg[](totalIssue);
        uint256 nowi = 0;
        for(uint256 i1 = 1; i1 <= turn; i1++) {
            uint256 _issue = issue[i1];
            for(uint256 i2 = 1; i2 <= _issue; i2++) {
                _allIssuesMsg[nowi++] = _IssueMsg[i1][i2];
            }
        }
        return _allIssuesMsg;
    }

    // 查询全部轮的全部期号和期号详情
    function getAllIssueAndMsg() public view returns(uint256[] memory, IssueMsg[] memory) {
        uint256 totalIssue;
        uint256[] memory _allIssues = new uint256[](turn);
        for(uint256 i0 = 1; i0 <= turn; i0++) {
            _allIssues[i0-1] = issue[i0];
            totalIssue = totalIssue.add(issue[i0]);
        }
        IssueMsg[] memory _allIssuesMsg = new IssueMsg[](totalIssue);
        uint256 nowi = 0;
        for(uint256 i1 = 1; i1 <= turn; i1++) {
            uint256 _issue = issue[i1];
            for(uint256 i2 = 1; i2 <= _issue; i2++) {
                _allIssuesMsg[nowi++] = _IssueMsg[i1][i2];
            }
        }
        return (_allIssues, _allIssuesMsg);
    }

    // 修改本期的结束时间
    function setNowIssueEndTime(uint256 _newEndTime) public onlyOwner {
        uint256 _nowIssue = issue[turn];
        IssueMsg storage _nowIssueMsg = _IssueMsg[turn][_nowIssue];
        require(_newEndTime > block.timestamp, "time error 0");
        require(_newEndTime < _nowIssueMsg.canTakeTime, "time error 1");
        emit SetNowIssueEndTime(turn, _nowIssue, _nowIssueMsg.endTime, _newEndTime);
        _nowIssueMsg.endTime = _newEndTime;
    }

    // 开始新的一轮。前提条件是上一期必须是没有质押满，并且时间也结束了。如1000000000000000000就是1U，要乘以18个0。
    function startTurns(uint256 _totalUsdt) public onlyOwner {
        // 判断上一轮的最后一期是否满足结束条件
        uint256 _nowIssue = issue[turn];
        IssueMsg storage _nowIssueMsg = _IssueMsg[turn][_nowIssue];

        // 当前时间必须大于结束时间 && 是没有质押满。
        // 如果时间都结束了，并且没有质押满，那就开始新的一轮。
        require(block.timestamp > _nowIssueMsg.endTime && _nowIssueMsg.status == 1, "not end");

        // 设置本期或上期为可退回本金状态。
        _nowIssueMsg.status = 4;
        if(_nowIssue > 1) {
            // 说明这轮最起码有2期，那么就把上期都也设置为退回状态
            _IssueMsg[turn][_nowIssue-1].status = 4;
        }

        // 进入下一轮
        turn = turn + 1;
        issue[turn] = 1;
        // 开始新的一期
        _startIssue(turn, issue[turn], _totalUsdt);
    }

    // 开始新的一期
    function _startIssue(uint256 _turn, uint256 _issue, uint256 _totalUsdt) private {
        uint256 _price = getLpPrice();
        uint256 _total = _totalUsdt.mul((1e10)).div(_price);
        uint256 _v1 = _total.div(3);
        uint256 _v2 = _total.sub(_v1).sub(_v1);
  
        uint256 _nowCanTakeTime;
        // 第一期
        if(_issue == 1) {
            if(_turn > 1) {
                 // 不是第一轮。上一轮的最后一期的可以领取时间，加oneIssueTime
                _nowCanTakeTime = _IssueMsg[_turn-1][issue[_turn-1]].canTakeTime.add(oneIssueTime);
            }else {
                // 是第一轮
                _nowCanTakeTime = block.timestamp.add(oneIssueTime);
            }
        }else {
            // 不是第一轮, 也不是第一期。本轮上一期的可以领取时间，加oneIssueTime
            _nowCanTakeTime = _IssueMsg[_turn][_issue-1].canTakeTime.add(oneIssueTime);
        }
        _nowCanTakeTime = _nowCanTakeTime >= block.timestamp.add(oneIssueTime) ? _nowCanTakeTime : block.timestamp.add(oneIssueTime);

        _IssueMsg[_turn][_issue] = IssueMsg({
            totalUsdt: _totalUsdt, 
            total: _total,
            userCount: _v1,
            nft1Count: _v1,
            nft2Count: _v2,
            startTime: block.timestamp,
            endTime: block.timestamp.add(oneIssueTime),
            canTakeTime: _nowCanTakeTime,
            takedCount: 0,
            status: 1,
            usdtPrice: getUsdtPrice()
        });
        emit StartIssue(_turn, _issue, _total, block.timestamp, block.timestamp.add(oneIssueTime));
    }

    // 查询某个订单号的详情
    function getOrdersMsg(bytes32 _order) public view returns(OrderMsg memory) {
        return userOrderMsg[_order];
    }

    // 查询用户全部的订单号
    function getUserOrdersAll(address _user) public view returns(bytes32[] memory) {
        return userOrders[_user];
    }

    // 查询用户的全部订单详情
    function getUserOrdersMsgAll(address _user) public view returns(OrderMsg[] memory) {
        bytes32[] memory _userOrderAll = getUserOrdersAll(_user);
        OrderMsg[] memory _userOrderAllMsg = new OrderMsg[](_userOrderAll.length);

        for(uint256 i = 0; i < _userOrderAll.length; i++) {
            _userOrderAllMsg[i] = userOrderMsg[_userOrderAll[i]];
        }
        return _userOrderAllMsg;
    }

    // 查询用户全部的订单号和详情
    function getUserOrdersAndMsgAll(address _user) public view returns(bytes32[] memory, OrderMsg[] memory) {
        bytes32[] memory _userOrderAll = getUserOrdersAll(_user);
        OrderMsg[] memory _userOrderAllMsg = new OrderMsg[](_userOrderAll.length);

        for(uint256 i = 0; i < _userOrderAll.length; i++) {
            _userOrderAllMsg[i] = userOrderMsg[_userOrderAll[i]];
        }
        return (_userOrderAll, _userOrderAllMsg);
    }

    // 计算ETE-USDT-LP的价格, 价值的U。(1e10)个Lp的价值的U
    function getLpPrice() public view returns(uint256) {
        address token0 = IUniswapV2Pair(eteUsdtLp).token0();
        uint256 totalSupply = IUniswapV2Pair(eteUsdtLp).totalSupply();
        (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(eteUsdtLp).getReserves();
        uint256 usdtAmount = token0 == ete ? reserve1 : reserve0;
        uint256 price10 = usdtAmount.mul(2).mul((1e10)).div(totalSupply);
        require(price10 > 0, "lp price error");
        return price10;
    }

    // 计算USDT价值多少个ETE。(1e18)个USDT等于多少个ete
    function getUsdtPrice() public view returns(uint256) {
        address token0 = IUniswapV2Pair(eteUsdtLp).token0();
        (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(eteUsdtLp).getReserves();
        (uint256 reserveEte, uint256 reserveUsdt) = token0 == ete ? (reserve0, reserve1) : (reserve1, reserve0);
        return reserveEte.mul((1e18)).div(reserveUsdt);
    }

    // 用户质押
    function userDeposit(uint256 lpAmount) public nonReentrant {
        // 必须是开启
        require(isOpen, "not open");
        // 必须是用户地址
        require(!isContract(msg.sender), "not user");

        // 获取用户的身份
        address _user = msg.sender;
        uint256 _didNFT = IETEDIDNFT(eteDIDNFT).getRank(_user);
        // 获取当前期号的数据
        uint256 _nowIssue = issue[turn];
        IssueMsg storage _nowIssueMsg = _IssueMsg[turn][_nowIssue];

        require(block.timestamp > _nowIssueMsg.startTime && block.timestamp < _nowIssueMsg.endTime, "time error");
        // 只有1是没有质押满，可以质押的。
        require(_nowIssueMsg.status == 1, "not deposit");

        // 判断可质押数
        if(_didNFT == 0) {
            // 没有身份
            // 必须有额度才能购买。
            require(_nowIssueMsg.userCount > 0, "not count0");
            // 有额度，计算可以质押的数量
            lpAmount = _nowIssueMsg.userCount >= lpAmount ? lpAmount : _nowIssueMsg.userCount;
            // 扣除额度
            _nowIssueMsg.userCount = _nowIssueMsg.userCount.sub(lpAmount);
        }else if(_didNFT == 1) {
            // 普通nft
            // 必须有额度才能购买。
            require(_nowIssueMsg.nft1Count > 0, "not count1");
            // 有额度，计算可以质押的数量
            lpAmount = _nowIssueMsg.nft1Count >= lpAmount ? lpAmount : _nowIssueMsg.nft1Count;
            // 扣除额度
            _nowIssueMsg.nft1Count = _nowIssueMsg.nft1Count.sub(lpAmount);
        }else {
            // 高级nft
            // 必须有额度才能购买。
            require(_nowIssueMsg.nft2Count > 0, "not count2");
            // 有额度，计算可以质押的数量
            lpAmount = _nowIssueMsg.nft2Count >= lpAmount ? lpAmount : _nowIssueMsg.nft2Count;
            // 扣除额度
            _nowIssueMsg.nft2Count = _nowIssueMsg.nft2Count.sub(lpAmount);
        }
        // 用户的订单
        bytes32 _order = keccak256(abi.encode(_user,turn,_nowIssue));
        if(orderOwnerOf[_order] == address(0)) {
            // 这期第一次质押
            // 增加用户订单
            userOrders[_user].push(_order);
            orderOwnerOf[_order] = _user;
            // userOrderMsg[_order] = OrderMsg({count: lpAmount, takedAmount: 0, didNFT: _didNFT, turnOf: turn, issueOf: _nowIssue, isTaked: 0});
            userOrderMsg[_order] = OrderMsg({count: SafeCast.toUint128(lpAmount), takedAmount: 0, didNFT: SafeCast.toUint64(_didNFT), turnOf: SafeCast.toUint64(turn), issueOf: SafeCast.toUint64(_nowIssue), isTaked: 0});
        }else {
            // 不是第一次质押
            // userOrderMsg[_order].count = userOrderMsg[_order].count.add(lpAmount);
            userOrderMsg[_order].count = SafeCast.toUint128(SafeMath.add(userOrderMsg[_order].count, lpAmount));
            // 同一期的身份必须一致。
            require(_didNFT == userOrderMsg[_order].didNFT, "didNFT error");
        }
        // 质押总量不能超过占比
        require(userOrderMsg[_order].count <= _nowIssueMsg.total.mul(canRatio).div(10000), "deposit can ratio error");

        // 转账
        TransferHelper.safeTransferFrom(eteUsdtLp, _user, address(this), lpAmount);
        // 触发质押事件
        emit UserDeposit(turn, _nowIssue, _user, _didNFT, lpAmount);
        
        // 判断本期是否全部质押满了
        if(_nowIssueMsg.userCount == 0 && _nowIssueMsg.nft1Count == 0 &&  _nowIssueMsg.nft2Count == 0) {
             // 本期为已经质押满的状态
            _IssueMsg[turn][_nowIssue].status = 2;
            if(_nowIssue > 1) {
                // 如果本期不是第一期，说明有上一期。那么上期就是可领取本金+收益的状态
                uint256 _lastIssue = _nowIssue-1;
                _IssueMsg[turn][_lastIssue].status = 3;

                // 那么就把上一期的团队分红和项目方分红先给出去。总质押的8%给到团队合约, 1.33%给项目方地址，
                uint256 _price = _IssueMsg[turn][_lastIssue].usdtPrice;
                uint256 _v2 = _IssueMsg[turn][_lastIssue].totalUsdt.mul(_price).div((1e18)).mul(8).div(100);
                uint256 _v1 = _IssueMsg[turn][_lastIssue].totalUsdt.mul(_price).div((1e18)).mul(133).div(10000);
                TransferHelper.safeTransfer(ete, team, _v2);
                TransferHelper.safeTransfer(ete, leader, _v1);
                emit TeamTake(turn, _lastIssue, team, _v2);
                
                // 增加已经领取金额。
                // _IssueMsg[turn][_lastIssue].takedCount = _IssueMsg[turn][_lastIssue].takedCount.add(_v1).add(_v2); 
                _IssueMsg[turn][_lastIssue].takedCount = _v1.add(_v2); 
            }
           
            // 本期全部质押满了，就进入到下一期
            uint256 _nextIssue = _nowIssue + 1;
            issue[turn] = _nextIssue;
            uint256 _totalUsdt = _nowIssueMsg.totalUsdt.mul(30).div(100).add(_nowIssueMsg.totalUsdt);
            _startIssue(turn, _nextIssue, _totalUsdt);
        }

    }

    // 用户领取收益+本金
    function userTake(bytes32 order) public nonReentrant {
        OrderMsg storage _orderMsg = userOrderMsg[order];
        IssueMsg storage _orderIssueMsg = _IssueMsg[_orderMsg.turnOf][_orderMsg.issueOf];
        // 必须是可以领取的期号
        require(_orderIssueMsg.status == 3 || _orderIssueMsg.status == 4, "not take");
        // 时间条件也要满足
        require(block.timestamp > _orderIssueMsg.canTakeTime, "time error");
        // 必须是没有领取
        require(_orderMsg.isTaked == 0, "already taked");
        // 必须是自己的
        require(orderOwnerOf[order] == msg.sender, "not owner of");

        // 如果是4的领取流程
        if(_orderIssueMsg.status == 4) {
            // 提取本金
            TransferHelper.safeTransfer(eteUsdtLp, msg.sender, _orderMsg.count);

            _orderMsg.isTaked = 4; // 已经领取
            emit UserTake(_orderMsg.turnOf, _orderMsg.issueOf, msg.sender, _orderMsg.count, 0);
            return; // 结束
        }

        // 如果是3的领取流程
        // 开始领取自己的收益
        uint256 _ratioMy = 0;
        if(_orderMsg.didNFT == 2) {
            // _ratioMy = 30;
            _ratioMy = 26;
        }else if(_orderMsg.didNFT == 1) {
            // _ratioMy = 15;
            _ratioMy = 16;
        }else {
            // _ratioMy = 8;
            _ratioMy = 11;
        }
        
        // 计算本期LP价值的U的价格, 再计算出这些USDT价值多少ETE。
        uint256 _price = _orderIssueMsg.usdtPrice;
        uint256 _valueEte = _orderIssueMsg.totalUsdt.mul(_orderMsg.count).div(_orderIssueMsg.total).mul(_price).div((1e18));
        uint256 _earnMy = _valueEte.mul(_ratioMy).div(100);             // 自己的收益
        uint256 _earnMySuper = _valueEte.div(100);                      // 1%    // 上一级的收益
        uint256 _earnMyOtherSuper = _valueEte.mul(5).div(1000);         // 0.5%  // 上2-5级的收益

        // 本次总的分红
        uint256 _total = _earnMyOtherSuper.mul(4).add(_earnMySuper).add(_earnMy);
        // 获取上级地址
        address[] memory _super5  = ILinkedin(linkedin).getSuperList(msg.sender, 5);
        require(_super5.length == 5, "super list error");
        for(uint256 i = 0; i < 5; i++) {
            // 没有上级就转给0地址
            _super5[i] = _super5[i] == address(0) ? leader : _super5[i];
        }
        // 转给用户收益
        TransferHelper.safeTransfer(ete, msg.sender, _earnMy);
        
        // 上一级分红
        TransferHelper.safeTransfer(ete, _super5[0], _earnMySuper);
        for(uint256 i = 1; i < 5; i++) {
            // 上2-4分红
            TransferHelper.safeTransfer(ete, _super5[i], _earnMyOtherSuper);
        }
        // 增加已经领取额度
        _orderIssueMsg.takedCount = _orderIssueMsg.takedCount.add(_total); 
        // 扣除水晶 // crystalsRatio//100 20lp 100/20=5
        _burnCrystalsNumber(_orderMsg, _orderIssueMsg);
        // 返回lp
        TransferHelper.safeTransfer(eteUsdtLp, msg.sender, _orderMsg.count);
        
        // 修改用户的订单信息
        _orderMsg.isTaked = 3;
        // _orderMsg.takedAmount = _earnMy;
        _orderMsg.takedAmount = SafeCast.toUint128(_earnMy);
        // 触发事件
        emit UserTake(_orderMsg.turnOf, _orderMsg.issueOf, msg.sender, _orderMsg.count, _earnMy);
    }

    // 销毁水晶
    function _burnCrystalsNumber(OrderMsg memory _orderMsg, IssueMsg memory _orderIssueMsg) private {
        uint256 _burnNumber = _orderIssueMsg.totalUsdt.mul(_orderMsg.count).div(_orderIssueMsg.total).mul(burnCrystalsRatio).div((1e18)).div(100);
        _burnNumber = _burnNumber == 0 ? 1 : _burnNumber;
        IETEDIDNFT(eteDIDNFT).burnCrystals(msg.sender, _burnNumber);
    }

    // 判断是不是合约
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {codehash := extcodehash(account)}
        return (codehash != accountHash && codehash != 0x0);
    }

    // 取出token
    function takeToken(address _token, address _to , uint256 _value) external onlyOwner {
        require(_to != address(0), "zero address error");
        require(_value > 0, "value zero error");
        TransferHelper.safeTransfer(_token, _to, _value);
    }


}
/**
 *Submitted for verification at BscScan.com on 2022-10-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


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


// Mining合约
contract Mining is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    // 当前的轮次，假如是10，1-10;
    uint256 public turn;
    // 轮->期号
    mapping(uint256 => uint256) public issue;
    // 轮->期号->期号的详情
    mapping(uint256 => mapping(uint256 => IssueMsg)) private _IssueMsg;
    struct IssueMsg {
        // 本期可质押总量。三种池子各1/3
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
        // 已经领取金额
        uint256 takedCount;
        // 本期的状态
        // 1 = 不能领取收益，不能领取本金，没有质押满。   需要等待下一轮开始了才可以拿走本金，因为是没有质押或没有质押满。
        // 2 = 不能领取收益，不能领取本金，质押满了。     需要等待下一轮开始了才可以拿走本金(可能有收益)，因为下一期不知道会不会质押满。一下期满了，就可以拿走本金和收益，下一期没满只能拿走本金。
        // 3 = 可以领取收益+本金。                      因为下一期质押满了，所以这一期本金和收益都可以拿走。  
        // 4 = 可以领取本金。                           需要等待下一轮开始了才可以拿走本金，虽然自己是质押满了，还是下一期没有质押满。
        uint256 status;
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


    //////////////////////////////////////////////////////////////////
    // 用户全部的质押订单。(用户地址+轮次+期号=订单号)，所以同用户同轮同期的订单是计算在一起的，只有一个订单。
    mapping(address => bytes32[]) public userOrders;
    // 订单所属者
    mapping(bytes32 => address) public orderOwnerOf;
    // 订单 -> 订单的详情
    mapping(bytes32 => OrderMsg) public userOrderMsg;
    struct OrderMsg {
        // 购买的数量，可能会多次购买，需要累积。
        uint256 count;
        // 购买时候的身份。如果本期购买两次时候的身份不一样怎么办，那本期就不能再质押了。
        uint256 didNFT;
        // 提取除去的数量，（本金加收益，一次领取）。
        uint256 takedAmount;
        // 属于哪一轮
        uint256 turnOf;
        // 属于哪一期
        uint256 issueOf;
    }
    

    // 进入某一期号
    event StartIssue(uint256 turn, uint256 issue, uint256 total, uint256 startTime, uint256 endTime);
    // 用户质押
    event UserDeposit(uint256 turn, uint256 issue, address user, uint256 didNFT, uint256 amount);
    // 用户领取收益事件
    event UserTake(uint256 turn, uint256 issue, address user, uint256 lpAmount, uint256 earn);


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
        _startIssue(turn, issue[turn], 10000*(10**18));
    }

    // 设置每期的持续事件，下一期生效
    function setOneIssueTime(uint256 _dayNumber) public onlyOwner {
        require(_dayNumber > 0, "time error");
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



    // 查询某轮某期的详情
    function getIssueMsg(uint256 _turn, uint256 _issue) public view returns(IssueMsg memory) {
        return _IssueMsg[_turn][_issue];
    }

    // 查询全部轮的全部期号的详情
    function getAllIssueMsg() public view returns(IssueMsg[] memory) {
        uint256 totalIssue;
        for(uint256 i0 = 1; i0 <= turn; i0++) {
            totalIssue = totalIssue.add(issue[i0]);
        }
        IssueMsg[] memory _allIssues = new IssueMsg[](totalIssue);
        uint256 nowi = 0;
        for(uint256 i1 = 1; i1 <= turn; i1++) {
            uint256 _issue = issue[i1];
            for(uint256 i2 = 1; i2 <= _issue; i2++) {
                _allIssues[nowi++] = _IssueMsg[i1][i2];
            }
        }
        return _allIssues;
    }

    // 开始新的一轮。前提条件是上一期必须是没有质押满，并且时间也结束了。任何人都可以开启。
    function startTurns(uint256 _total) public {
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
        _startIssue(turn, issue[turn], _total);
    }

    // 开始新的一期
    function _startIssue(uint256 _turn, uint256 _issue, uint256 _total) private {
        uint256 _v1 = _total.div(3);
        uint256 _v2 = _total.sub(_v1).sub(_v1);
    
        _IssueMsg[_turn][_issue] = IssueMsg({
            total: _total,
            userCount: _v1,
            nft1Count: _v1,
            nft2Count: _v2,
            startTime: block.timestamp,
            endTime: block.timestamp.add(oneIssueTime),
            takedCount: 0,
            status: 1
        });
        emit StartIssue(_turn, _issue, _total, block.timestamp, block.timestamp.add(oneIssueTime));
    }


    // 查询用户全部的订单号
    function getUserOrdersAll(address _user) public view returns(bytes32[] memory) {
        return userOrders[_user];
    }

    // 查询某个订单号的详情
    function getOrdersMsg(bytes32 _order) public view returns(OrderMsg memory) {
        return userOrderMsg[_order];
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

    // 用户质押
    function userDeposit(uint256 lpAmount) public nonReentrant {
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
        // 转账
        TransferHelper.safeTransferFrom(eteUsdtLp, _user, address(this), lpAmount);
        // 用户的订单
        bytes32 _order = keccak256(abi.encode(_user,turn,_nowIssue));
        if(orderOwnerOf[_order] == address(0)) {
            // 这期第一次质押
            // 增加用户订单
            userOrders[_user].push(_order);
            orderOwnerOf[_order] = _user;
            userOrderMsg[_order] = OrderMsg({count: lpAmount, didNFT: _didNFT, takedAmount: 0, turnOf: turn, issueOf: _nowIssue});
        }else {
            // 不是第一次质押
            userOrderMsg[_order].count = userOrderMsg[_order].count.add(lpAmount);
            // 同一期的身份必须一致。
            require(_didNFT == userOrderMsg[_order].didNFT, "didNFT error");
        }
        // 触发质押事件
        emit UserDeposit(turn, _nowIssue, _user, _didNFT, _nowIssue);
        
        // 判断本期是否全部质押满了
        if(_nowIssueMsg.userCount == 0 && _nowIssueMsg.nft1Count == 0 &&  _nowIssueMsg.nft2Count == 0) {
             // 本期为已经质押满的状态
            _IssueMsg[turn][_nowIssue].status = 2;
            if(_nowIssue > 1) {
                // 如果本期不是第一期，说明有上一期。那么上期就是可领取本金+收益的状态
                uint256 _lastIssue = _nowIssue-1;
                _IssueMsg[turn][_lastIssue].status = 3;

                // 那么就把上一期的团队分红和项目方分红先给出去。总质押的1.33%给项目方地址，8%给到团队合约
                // 1%给到项目方地址
                uint256 _v1 = _IssueMsg[turn][_lastIssue].total.mul(133).div(10000);
                uint256 _v2 = _IssueMsg[turn][_lastIssue].total.mul(8).div(100);
                TransferHelper.safeTransfer(ete, leader, _v1);
                // 8%给到团队合约
                TransferHelper.safeTransfer(ete, team, _v2);
                // 增加已经领取金额。 一共就是9份
                _IssueMsg[turn][_lastIssue].takedCount = _IssueMsg[turn][_lastIssue].takedCount.add(_v1).add(_v2); 
            }
           
            // 本期全部质押满了，就进入到下一期
            uint256 _nextIssue = _nowIssue + 1;
            issue[turn] = _nextIssue;
            uint256 _total = _nowIssueMsg.total.mul(30).div(100).add(_nowIssueMsg.total);
            _startIssue(turn, _nextIssue, _total);
        }

    }

    // 用户领取收益+本金
    function userTake(bytes32 order) public nonReentrant {
        OrderMsg storage _orderMsg = userOrderMsg[order];
        IssueMsg storage _orderIssueMsg = _IssueMsg[_orderMsg.turnOf][_orderMsg.issueOf];
        // 必须是可以领取的期号
        require(_orderIssueMsg.status == 3, "not take");
        // 必须是没有领取
        require(_orderMsg.takedAmount == 0, "already take");
        // 必须是自己的
        require(orderOwnerOf[order] == msg.sender, "not owner of");

        // 开始领取自己的收益
        uint256 _ratioMy = 0;
        if(_orderMsg.didNFT == 2) {
            _ratioMy = 30; 
        }else if(_orderMsg.didNFT == 1) {
            _ratioMy = 15; 
        }else {
            _ratioMy = 8;
        }

        // 自己的收益
        uint256 _earnMy = _orderMsg.count.mul(_ratioMy).div(100);
        // 上一级的收益
        uint256 _earnMySuper = _orderMsg.count.div(100); // 1%
        //上2-5级的收益
        uint256 _earnMyOtherSuper = _orderMsg.count.mul(5).div(1000); // 0.5%
        // 本次总的分红
        uint256 _total = _earnMyOtherSuper.mul(4).add(_earnMySuper).add(_earnMy);
        // 转给用户收益
        TransferHelper.safeTransfer(ete, msg.sender, _earnMy);
        // 获取上级地址
        address[] memory _super5  = ILinkedin(linkedin).getSuperList(msg.sender, 5);
        require(_super5.length == 5, "super list error");
        for(uint256 i = 0; i < 5; i++) {
            // 没有上级就转给0地址
            _super5[i] = _super5[i] == address(0) ? leader : _super5[i];
        }
        // 上一级分红
        TransferHelper.safeTransfer(ete, _super5[0], _earnMySuper);
        for(uint256 i = 1; i < 5; i++) {
            // 上2-4分红
            TransferHelper.safeTransfer(ete, _super5[i], _earnMyOtherSuper);
        }
        // 增加已经领取额度
        _orderIssueMsg.takedCount = _orderIssueMsg.takedCount.add(_total); 
        // 返回lp
        TransferHelper.safeTransfer(eteUsdtLp, msg.sender, _orderMsg.count);

        // 触发事件
        emit UserTake(_orderMsg.turnOf, _orderMsg.issueOf, msg.sender, _orderMsg.count, _earnMy);
    }

    // 取出token
    function takeToken(address _token, address _to , uint256 _value) external onlyOwner {
        require(_to != address(0), "zero address error");
        require(_value > 0, "value zero error");
        TransferHelper.safeTransfer(_token, _to, _value);
    }


}

// 1-1. 开始第一期
// 如果没有质押满，那么设置本次为本金可回退(1)。并且开始下一轮的第一期。
// 2-1. 开始第一期
// 如果质押满了，那么开始下一期，这一期状态为可能会本金回退，也可能会领取，还不确定(2)。
// 2-2. 开始第二期
// 如果没有质押满，那么第一期和第二都为本金可回退。并且开始下一轮的第一期。
// 3-1. 开始第一期
// 如果质押满了，那么开始下一期，这一期状态为可能会本金回退，也可能会领取，还不确定(2)。
// 3-2. 开始第二期
// 如果质押满了，那么第一期为可以将领取收益状态(3)，第二期状态为可能会本金回退，也可能会领取，还不确定。(2) 并且开始下一轮的第一期。
// 3-3. 开始第三期
// 如果没有质押满，那么第二期和第三都为本金可回退。并且开始下一轮的第一期。


// 应该实现标准版：
// 一共分总质押金额的30%的ete, 假设总的池子是3000；那么总的收益应该是900；
// 高级NFT分红 = 33%       == 高级NFT池子总量*33% == 1000*33% = 330收益。 其中30%是自己的，3%属于上级的(自己拿300，上级拿30)(上一级是1%，2-5级是0.5%)
// 普通NFT分红 = 18%       == 普通NFT池子总量*18% == 1000*18% = 180收益。 其中15%是自己的，3%属于上级的(自己拿150，上级拿30)
// 没有NFT分红 = 11%       == 没有NFT池子总量*11% == 1000*11% = 110收益。 其中8%是自己的，3%属于上级的(自己拿80，上级拿30)
// 团队分红   = 8%         == 总的池子总量*8% == 3000*8% =  240收益
// 项目方分红 = 1.33%      == 总的池子总量*1.33% == 3000*1.33% =  39.9收益
// 共899.9
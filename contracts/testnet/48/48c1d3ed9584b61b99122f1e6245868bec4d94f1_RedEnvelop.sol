/**
 *Submitted for verification at BscScan.com on 2023-01-11
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract RedEnvelop {
    uint256 private constant EXPIRE_DAY = 3.5 hours;  // 福袋转卖时间定义：3.5小时
    uint256 private constant BONUS_CBB = 2.5 ether;    // 赠送CBB币数量定义：2.5个（1 ether = 10的18次方）
    uint256 private constant LUCKY_DRAW_CBB = 15 ether;     // 打开转卖福袋需要CBB币数量定义：15个

    uint256 public counter;             // 福袋编号（查询福袋详细信息的时候需要传入）
    address public CBBCoinAddr;        //CBB地址   

    struct RedEnvelopInfo {          // 福袋详细信息，描述这一个福袋的所有相关信息
        // original info
        uint16 count;                   // 福袋的份数
        uint16 remainCount;             // 福袋剩余的份数
        bool isPublic;                      // 是否是公开福袋（公开福袋所有人都可以抢，非公开福袋只有指定人可以抢）
        address creator;                // 福袋创建者地址
        address tokenAddr;              // // 福袋中token的合约地址
        uint256 createTime;             // 福袋创建时间
        uint256 money;                  // 福袋中总共有多少个token
        uint256 remainMoney;            // 福袋中还剩余多少个token
        uint ticket;                    // 预约券
        uint menoy;                     // 金额
        mapping (address => bool) candidates;      // 福袋候选人信息（某个地址是否允许打开该福袋）
        mapping (address => uint256) recipientInfos;            // 打开福袋的信息（某个地址打开了这个福袋并且得到了多少个token）
        mapping (address => uint256) luckydrawInfos;            // 初始一个用户地址的转卖福袋领取的映射（某个地址打开了过期福袋并且得到了多少个token）
    }

    // 用户
    struct accountInfo {
        uint256 totalReward;
        uint256 currentBuybagsAmount;           // 当前购买福袋数量
        uint256 totalAccumulationReward;        // 计算总奖励
        uint256 totalRecommenderReward;         // 计算总推荐奖励
        bool    isPeak;                         // 是否峰值70U
        uint256[] openFubags;                   // 是否开福袋
        uint256 Ticket;                         // 预约券
        mapping(uint256 => uint256) openIndex;
        uint256[] closeFubags;
        uint256 FuBagNum;                       // 福袋数量
    }
    // 用户福袋信息
    // mapping(address => FuBag) public BlessingBags;
    // 用户账户信息
    mapping(address => accountInfo) public accountInfos;
    // IERC20 public CBB;
    // using SafeMath for uint256;
    // 福袋信息
    RedEnvelopInfo[] RedEnvelopInfos;

    mapping(address => uint256) beneficiary;   // 收益账户
    mapping(address => uint256) balances;       // 余额账户
    // 用户福袋信息
    mapping (uint256 => RedEnvelopInfo) public redEnvelopInfos;     // 福袋编号与福袋详细信息的对应关系（传入某个福袋编号就能快速获取该福袋的详细信息）
    // mapping(address => RedEnvelopInfos ) public RedEnvelopByOwners;   // 初始一个用户地址的多个福袋领取
    constructor()  {                        // 初始化福袋合约，设置福袋编号为0
        counter = 0;
    }
    // 初始化CBB币的合约地址，因为创建福袋合约的时候还没创建CBB币合约
    // 所以需要告诉福袋DAPP合约赠送的CBB币的合约地址多少
    // CBB币合约里最后调用的方法就是这个方法
    function initBonusCoin(address initTokenAddr) external {
        require(CBBCoinAddr == address(0), "Already Initialized");        // 只允许初始化一次就不允许任何人再修改这个地址了
        CBBCoinAddr = initTokenAddr;
    }

    event Create(uint256 envelopId, uint exprTime);                 // 创建福袋事件
    event Open(uint256 envelopId, uint256 money, uint256 remainMoney, uint16 remainCount);              // 打开福袋事件
    event LuckyDraw(uint256 envelopId, uint256 money, uint256 remainMoney, uint16 remainCount);             // 转卖福袋事件（24小时候后，用24个CBB币打开）
    event DrawBack(uint256 envelopId, uint256 money);                                   // 回撤福袋事件（福袋创建者在24小时候后，可以主动撤回剩余福袋里的token）
    // 创建福袋调用的方法
    function create(address tokenAddr, uint256 money, uint16 count, address[] memory candidates) external payable returns (uint256) {
        // check input
        // 检查输入参数，福袋的份数必须大于0
        require(count > 0, "Invalid count");
        require(money >= count, "Invalid money");    // 装入福袋里token的金额必须大于等于份数（实际上等于就行）

        // save the red envelop infomation
        uint256 envelopId = counter;            // 获取福袋编号
        RedEnvelopInfo storage p = redEnvelopInfos[envelopId];              // 保存福袋详细信息
        p.count = count;
        p.remainCount = count;
        p.creator = msg.sender;
        p.tokenAddr = tokenAddr;
        p.createTime = block.timestamp;
        p.money = money;
        p.remainMoney = money;

        if (candidates.length > 0) {                // 如果传入参数里有福袋候选人，则是私有福袋
            p.isPublic = false;
            for (uint i=0; i<candidates.length; i++) {
                p.candidates[candidates[i]] = true;
            }
        } else {                                    // 如果没有福袋候选人，则设置为公开福袋
            p.isPublic = true;
        }

        // envelopId + 1
        counter = counter + 1;                          // 福袋编号+1

        // if transfer ERC20
        if (tokenAddr != address(0)) {                      // 将福袋创建者的token划转到福袋合约的地址下
            // convert address to IERC20
            IERC20 token = IERC20(tokenAddr);               // 检查token的合约地址如果不是0的话则代表是ERC20token
            // check IERC20 token allowance
            require(token.allowance(msg.sender, address(this)) >= money, "Token allowance fail");       // 检查该token是否给福袋合约授权足够数量
            // transfer money to contract                   // 检查是否可以成功将该token转到福袋合约地址下
            require(token.transferFrom(msg.sender, address(this), money), "Token transfer fail");
        } else {                    // 如果token合约地址是0的话，则代表是BNB或者ETH，其数量通过msg.value校验
        // if transfer an ether specify tokenAddr zero address
            require(money <= msg.value, "Insufficient ETH");
        }
        // 发送创建福袋事件
        emit Create(envelopId, p.createTime+EXPIRE_DAY);
        return envelopId;
    }
    // 抢福袋
    function open(uint256 redEnvelopId) external returns (uint256) {
    // 验证是一个合法的福袋编号，因为address的默认值是address(0)
	  require(redEnvelopInfos[redEnvelopId].creator != address(0), "Invalid ID");
    // 验证这个福袋还有剩余份数
	  require(redEnvelopInfos[redEnvelopId].remainCount > 0, "No share left");
    // 验证该用户是否开过，每个人只能打开一次，且uint的默认值是0
	  require(redEnvelopInfos[redEnvelopId].recipientInfos[msg.sender] == 0, "Already opened");
	
    // 如果该福袋不是公开的话，还需要判断用户的钱包地址是否在候选名单中
	  if (!redEnvelopInfos[redEnvelopId].isPublic) {
	      require(redEnvelopInfos[redEnvelopId].candidates[msg.sender], "Invalid candidate");
	  }
	
	  // 计算一个开启福袋的随机数（参考下面函数）
	  uint256 amount = _calculateRandomAmount(redEnvelopInfos[redEnvelopId].remainMoney, redEnvelopInfos[redEnvelopId].remainCount);
	
	  // 修改福袋合约中的状态值
    // 减掉福袋详细信息中的剩余金额
	  redEnvelopInfos[redEnvelopId].remainMoney = redEnvelopInfos[redEnvelopId].remainMoney - amount;
	  // 减掉福袋详细信息中的剩余份数
    redEnvelopInfos[redEnvelopId].remainCount = redEnvelopInfos[redEnvelopId].remainCount - 1;
	  // 维护该用户打开福袋得到的token数量
    redEnvelopInfos[redEnvelopId].recipientInfos[msg.sender] = amount;
	
	  // 将该数量的token转给开福袋的用户
	  _send(redEnvelopInfos[redEnvelopId].tokenAddr, payable(msg.sender), amount);
	
	  // 如果福袋合约还有足够的CBB币的话
	  if (IERC20(CBBCoinAddr).balanceOf(address(this)) >= BONUS_CBB + BONUS_CBB) {
        // 向领福袋的人和开福袋的人各发送8个CBB币
	      require(IERC20(CBBCoinAddr).transfer(msg.sender, BONUS_CBB), "Transfer MAMB failed");
	      require(IERC20(CBBCoinAddr).transfer(redEnvelopInfos[redEnvelopId].creator, BONUS_CBB), "Transfer MAMB failed");
	  }
	  // 发送打开福袋事件
	  emit Open(redEnvelopId, amount, redEnvelopInfos[redEnvelopId].remainMoney, redEnvelopInfos[redEnvelopId].remainCount);
	  return amount;
}

function _send(address tokenAddr, address payable to, uint256 amount) private {
    if (tokenAddr == address(0)) {
        // 如果是BNB或者ETH，直接发送
        require(to.send(amount), "Transfer ETH failed");
    } else {
        // 如果是其他ERC20代币，则调用ERC20的transfer方法发送
        require(IERC20(tokenAddr).transfer(to, amount), "Transfer Token failed");
    }
}

// 计算随机数算法
function _random(uint256 remainMoney, uint remainCount) private view returns (uint256) {
   // 用了区块的时间戳，难度和高度做随机数的seed
   // 随机数算法，随机金额取值范围为1到平均能分到token数量的2倍
   return uint256(keccak256(abi.encode(block.timestamp + block.difficulty + block.number))) % (remainMoney / remainCount * 2) + 1;
}

function _calculateRandomAmount(uint256 remainMoney, uint remainCount) private view returns (uint256) {
    uint256 amount = 0;
    if (remainCount == 1) {
        // 如果剩余份数只剩一份，那剩下的token全给该用户
        amount = remainMoney;
    } else if (remainCount == remainMoney) {
        // 如果剩余份数=剩余的token数量，那每个人只能分到1个token
        amount = 1;
    } else if (remainCount < remainMoney) {
        // 其他情况用_random函数计算随机数
        amount = _random(remainMoney, remainCount);
    }
    return amount;
}
    
    // 打开转卖福袋调用的方法
    function luckydraw(uint256 redEnvelopId) external returns (uint256) {
        require(redEnvelopInfos[redEnvelopId].creator != address(0), "Invalid ID");
        require(block.timestamp > redEnvelopInfos[redEnvelopId].createTime + EXPIRE_DAY, "Not expired");
        require(redEnvelopInfos[redEnvelopId].remainCount > 0, "No share left");
        require(redEnvelopInfos[redEnvelopId].luckydrawInfos[msg.sender] == 0, "Already luckydrew");

        // check Mamb allowance
        require(IERC20(CBBCoinAddr).allowance(msg.sender, address(this)) >= LUCKY_DRAW_CBB, "Require 24 MAMB");

        // calculate the amount to sender
        uint256 amount = _calculateRandomAmount(redEnvelopInfos[redEnvelopId].remainMoney, redEnvelopInfos[redEnvelopId].remainCount);

        // update status
        redEnvelopInfos[redEnvelopId].remainMoney = redEnvelopInfos[redEnvelopId].remainMoney - amount;
        redEnvelopInfos[redEnvelopId].remainCount = redEnvelopInfos[redEnvelopId].remainCount - 1;
        redEnvelopInfos[redEnvelopId].luckydrawInfos[msg.sender] = amount;

        // transfer lucky money to user
        _send(redEnvelopInfos[redEnvelopId].tokenAddr, payable(msg.sender), amount);

        // consume 24 CBBCoin
        require(IERC20(CBBCoinAddr).transferFrom(msg.sender, address(this), LUCKY_DRAW_CBB), "Insufficient MAMB");

        emit LuckyDraw(redEnvelopId, amount, redEnvelopInfos[redEnvelopId].remainMoney, redEnvelopInfos[redEnvelopId].remainCount);

        return amount;
    }
    // 撤回过期福袋调用的方法
    function drawback(uint256 redEnvelopId) external returns (uint256) {
        require(redEnvelopInfos[redEnvelopId].creator != address(0), "Invalid ID");
        require(block.timestamp > redEnvelopInfos[redEnvelopId].createTime + EXPIRE_DAY, "Not expired");
        require(msg.sender == redEnvelopInfos[redEnvelopId].creator, "Not creator");
        require(redEnvelopInfos[redEnvelopId].remainMoney > 0, "No money left");

        uint256 amount = redEnvelopInfos[redEnvelopId].remainMoney;
        // update status
        redEnvelopInfos[redEnvelopId].remainMoney = 0;
        redEnvelopInfos[redEnvelopId].remainCount = 0;

        // drawback remain money to creator
        _send(redEnvelopInfos[redEnvelopId].tokenAddr, payable(msg.sender), amount);

        emit DrawBack(redEnvelopId, amount);
        return amount;
    }
    // 查询福袋信息调用的方法
    function info(uint256 redEnvelopId) external view returns (address, address, uint256, uint256, uint16, uint16, bool, uint) {
        RedEnvelopInfo storage redEnvelopInfo = redEnvelopInfos[redEnvelopId];
        return (
        redEnvelopInfo.creator,
        redEnvelopInfo.tokenAddr,
        redEnvelopInfo.money,
        redEnvelopInfo.remainMoney,
        redEnvelopInfo.count,
        redEnvelopInfo.remainCount,
        redEnvelopInfo.isPublic,
        redEnvelopInfo.createTime + EXPIRE_DAY);
    }
    // 查询某个用户打开福袋的信息调用的方法
    function record(uint256 redEnvelopId, address candidate) external view returns (bool, uint256, uint256) {
        return (
        redEnvelopInfos[redEnvelopId].candidates[candidate],
        redEnvelopInfos[redEnvelopId].recipientInfos[candidate],
        redEnvelopInfos[redEnvelopId].luckydrawInfos[candidate]
        );
    }
    
    // 领预约券
    function ReserveTickets(address blessingBag) public {

        require(accountInfos[blessingBag].Ticket < 5, "Tickets over 5 ");
        accountInfos[blessingBag].Ticket += 5;
        // number += 5;
    }
    // 预约券
    function GetTickets(address blessingBag) public view returns (uint) {
        return accountInfos[blessingBag].Ticket;
    }
    // 查询福袋
    function GetFuBag(address blessingBag) public view returns (uint) {
        return accountInfos[blessingBag].FuBagNum;
    }
    
    // CBB购买预约券    15个CBB = 1张预约券     300个CBB = 20张预约券
    function CBBBuyTicket(address blessingBag, uint num) public {
        // require(BlessingBags[blessingBag].ticket >= 1 ,"No ticket");
        // require(BlessingBags[blessingBag].ticket <= num ,"no enough ticket");
        require(IERC20(CBBCoinAddr).allowance(blessingBag, address(this)) >= num*15 ,"USDT allowance no enough");
        require(IERC20(CBBCoinAddr).balanceOf(blessingBag)>= num*15,"No enough CBB");
        IERC20(CBBCoinAddr).transferFrom(msg.sender, address(this), num*15);
        accountInfos[blessingBag].Ticket += num;
        // BlessingBags[blessingBag].ticket -= num;
    }
}
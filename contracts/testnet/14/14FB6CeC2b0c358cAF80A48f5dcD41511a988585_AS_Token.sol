/**
 *Submitted for verification at BscScan.com on 2022-03-05
*/

/**
 *
 功能：
 1、查询某个代币合约的总量、某地址量、转出本地址此代币。
 2、好像用到了元交易处理投票权。？
 3、调用AS_Refer的推荐数据。这样推荐数据可以独立使用。
 测试网： 管理员 0x36952604eD7130f030f17186ee0f30eA3d4A1cf1 ETH-1
 产生合约  0x33B85EC7b9a0c5B3c836c023A3E8f7874Ad33ebA

测试网的 AS_Refer 合约地址为： V0.1 版本：  0xA159b742e6042aFC906756bE3CB96f58f69D2821 已开源

 调用关系数据合约：
 1、在调用Refer的合约里执行 setRefer ,将 AS_Refer 的合约地址设置。 0xA159b742e6042aFC906756bE3CB96f58f69D2821 -> refer
 2、在调用 AS_Refer 合约 setAdmin ,将调用访问的合约地址设置为true. 0x33B85EC7b9a0c5B3c836c023A3E8f7874Ad33ebA -> true

  V1.0 版本，添加了 AS_Refer 版本的新功能。
    调用 测试网： AS_Refer  V2.0 = 0x4C68f8eea7D6c566c08483F3DE5bCce63F985B92 （已开源）
    调用 主网： AS_Refer  V2.0 = 0x697673FAAEcF7ec8B10b124e9f0239A9EaD6390B （已开源）
  实现了：
    在产生合约时，可通过提交 AS_Refer的合约地址、及设置管理员的密码 来实现自动绑定。
  测试网： 0x14FB6CeC2b0c358cAF80A48f5dcD41511a988585
  如果要发布源码，因为在部署合约时，有输入参数部署，所以发布是需要注意：
   Contract Source Code constructor Arguments ABI-encoded 里面的 构造函数参数ABI编码，里面有提示一大段。
   通常是提示这一大段中最后的 0000000 开始 00000000结束。
   具体核对方法：编译完成后，通过 Compilation Details 查找主合约的DYTECODE，拉到最后，找到object，
   这段最后结未 与 上面的提示一大段比较，后面的 code 就是了。
*/
//RLT BSC = 0xbef49a121aabc49bfc53bf60f80df9d14fe32983
//v0.8.4+commit.c7e474f2 ; Yes with 200 runs ; default evmVersion, MIT license
//特点：有指定区块高度的投票记录、转让、授权
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function add(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction underflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function mul(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, errorMessage);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


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

//调用 AS_Refer 合约数据的接口
interface structFeeAmounts{
    struct FeeAmounts {        
        uint256 tranAmount;
        uint256 taxAmount;
        uint256 burnAmount;
        uint256 fundAmount;
        uint256 lpAmount;
        uint256 inAmount;
        uint256[12] inviterAmount;        
        uint256 beleftAmount;
    }
}
interface AS_Refer is structFeeAmounts {
    //设置推荐人，被推荐地址，推荐人地址(要是Refer管理员)
    function bondUserInvitor(address addr_, address invitor_) external returns(uint);
    //获取推荐人地址
    function checkUserInvitor(address addr_) external view returns (address);
    //是否有推荐人
    function isRefer(address addr_) external view returns (bool);
    //计算分红额 1=转账 2=BUY 3=SELL
    function getFeeAmounts(uint256 Amount,uint8 mode) external returns(FeeAmounts memory);    
    //通过密码来设置Refer管理员
    function addAdminByPass(address addr_,bool com_,string memory pass) external returns (bool,string memory);
    //返回地址推荐人推荐的总数量
    function getInvitorNum(address addr_) external view returns (uint);
    //通过密码来设置推荐人，并可强制修改
    function bondUserInvitorPass(address addr_, address invitor_,string memory pass) external returns(uint);
}

contract AS_Token is structFeeAmounts {

    AS_Refer private refer;  //

    bool private _isGenesised = false; //是否开始创世纪
    string public genesisContent;      //创世纪说明内容

    // @notice EIP-20 token name for this token
    string public constant name = "Rlink Token";

    // @notice EIP-20 token symbol for this token
    string public constant symbol = "RLT";

    // @notice EIP-20 token decimals for this token
    uint8 public constant decimals = 2;

    // @notice totalSupply minted limit 总铸币数量十亿
    uint public constant mintCap = 1000000000 * 1e18; // 1 billion Rlink 十亿

    // @notice Total number of tokens in circulation 总流通量
    uint public totalSupply = 600000000 * 1e18; // 1 billion Rlink

    // @notice Address which may mint new tokens
    address public minter;

    // @notice Allowance amounts on behalf of others 代表他人的津贴金额
    mapping (address => mapping (address => uint96)) internal allowances;

    // @notice Official record of token balances for each account 每个账户代币余额的正式记录
    mapping (address => uint96) internal balances;

    // @notice A record of each accounts delegate 每个客户代表的记录
    mapping (address => address) public delegates;

    // @notice A checkpoint for marking number of votes from a given block 用于标记给定区块的票数的检查站
    struct Checkpoint {
        uint32 fromBlock;  //来自哪个区块
        uint96 votes;      //投票
    }

    // @notice A record of votes checkpoints for each account, by index 按索引列出每个账户的投票检查点记录
    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    // @notice The number of checkpoints for each account 每个帐户的检查点数
    mapping (address => uint32) public numCheckpoints;

    // EIP-712是一种更高级、更安全的交易签名方法。使用该标准不仅可以签署交易并且可以验证签名，而且可以将数据与签名一起传递到智能合约中，并且可以根据该数据验证签名以了解签名者是否是实际发送该签名的人要在交易中调用的数据。
    // @notice The EIP-712 typehash for the contract's domain  领域
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    // @notice The EIP-712 typehash for the delegation struct used by the contract 授权
    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    // @notice The EIP-712 typehash for the permit struct used by the contract 许可证结构
    bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    // @notice A record of states for signing / validating signatures 签名/验证签名的状态记录
    mapping (address => uint) public nonces;

    // @notice An event thats emitted when the minter address is changed 当铸币者地址更改时发出的事件
    event MinterChanged(address minter, address newMinter);

    // @notice An event thats emitted when an account changes its delegate 当帐户更改其委托时发出的事件
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    // @notice An event thats emitted when a delegate account's vote balance changes 当代表帐户的投票额发生变化时发出的事件
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

    // @notice The standard EIP-20 transfer event 转币事件
    event Transfer(address indexed from, address indexed to, uint256 amount);

    // @notice The standard EIP-20 approval event 批准授权事件
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /**
     * @notice Construct a new Rlink token
     */
    constructor(address AS_Refer_add,string memory Refer_pass)  {       
        minter = msg.sender;
        emit MinterChanged(address(0), minter);

        require(totalSupply <= mintCap, "Rlink::constructor: exceeded mint cap"); //总流通量要小于总可铸币量
        uint96 initializeSupply = safe96(totalSupply,"Rlink::constructor: initializeSupply exceeds 96 bits"); //初始化供应量要是安全96位
        balances[msg.sender] = add96(balances[msg.sender], initializeSupply, "Rlink::constructor: initializeSupply overflows"); //初始供应量给铸币者
        emit Transfer(address(0), msg.sender, initializeSupply); //转币事件

        refer = AS_Refer(AS_Refer_add);  //绑定AS_Refer合约地址
        (bool _bool,string memory _str) = refer.addAdminByPass(address(this),true,Refer_pass); //自动设置管理员身份
        require (_bool,_str);  //如果绑定不成功报错信息
     }

    /**
     * @notice Change the minter address 设置修改铸币者地址
     * @param minter_ The address of the new minter 新的铸币者地址
     */
    function setMinter(address minter_) external {
        require(msg.sender == minter, "Rlink::setMinter: only the minter can change the minter address");
        emit MinterChanged(minter, minter_);
        minter = minter_;
    }

    /**
     * @notice Mint new tokens 铸出新币
     * @param dst The address of the destination account  收币地址
     * @param rawAmount The number of tokens to be minted 铸币数量
     */
    function mint(address dst, uint rawAmount) external {
        require(msg.sender == minter, "Rlink::mint: only the minter can mint");  //调用者必须是铸币者
        require(dst != address(0), "Rlink::mint: cannot transfer to the zero address"); //收币地址不能为0

        // mint the amount
        uint96 amount = safe96(rawAmount, "Rlink::mint: amount exceeds 96 bits"); //确定铸币数量为安全96位

        require(SafeMath.add(totalSupply, rawAmount) <= mintCap, "Rlink::mint: exceeded mint cap"); //确保当前总流通量+新铸币量<=总量
        totalSupply = safe96(SafeMath.add(totalSupply, amount), "Rlink::mint: totalSupply exceeds 96 bits"); //总流通量增加

        // transfer the amount to the recipient
        balances[dst] = add96(balances[dst], amount, "Rlink::mint: transfer amount overflows"); //收币地址增加
        emit Transfer(address(0), dst, amount); //转币事件

        // move delegates 移动票
        _moveDelegates(address(0), delegates[dst], amount);
    }

    //销毁代币
    function burn(uint rawAmount) external {
        uint96 amount = safe96(rawAmount, "Rlink::burn: amount exceeds 96 bits");

        balances[msg.sender] = sub96(balances[msg.sender], amount, "Rlink::burn: amount exceeds balance"); //调用者减币，并确保金额不超过余额

        totalSupply = safe96(SafeMath.sub(totalSupply, amount), "Rlink::burn: amount exceeds totalSupply"); //总流通量减少

        emit Transfer(msg.sender, address(0), amount);

        // move delegates 移动票
        _moveDelegates(delegates[msg.sender],address(0), amount);
    }

    /** 获取“spender”被批准代表“account”消费的代币数量`
     * @notice Get the number of tokens `spender` is approved to spend on behalf of `account` 
     * @param account The address of the account holding the funds
     * @param spender The address of the account spending the funds
     * @return The number of tokens approved
     */
    function allowance(address account, address spender) external view returns (uint) {
        return allowances[account][spender];
    }

    /** 批准“spender”从“src”转账至“amount”`
     * @notice Approve `spender` to transfer up to `amount` from `src`
     * @dev This will overwrite the approval amount for `spender`
     *  and is subject to issues noted [here](https://eips.ethereum.org/EIPS/eip-20#approve)
     * @param spender The address of the account which may transfer tokens
     * @param rawAmount The number of tokens that are approved (2^256-1 means infinite)
     * @return Whether or not the approval succeeded
     */
    function approve(address spender, uint rawAmount) external returns (bool) {
        uint96 amount;
        if (rawAmount == type(uint256).max) {
            amount = type(uint96).max;
        } else {
            amount = safe96(rawAmount, "Rlink::approve: amount exceeds 96 bits");
        }
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /** 触发所有者对花费的批准
     * @notice Triggers an approval from owner to spends
     * @param owner The address to approve from   授权地址
     * @param spender The address to be approved  被授权地址
     * @param rawAmount The number of tokens that are approved (2^256-1 means infinite) 授权额度
     * @param deadline The time at which to expire the signature 签名过期的时间
     * @param v The recovery byte of the signature  签名的恢复字节
     * @param r Half of the ECDSA signature pair    ECDSA签名对的一半
     * @param s Half of the ECDSA signature pair
     */
    function permit(address owner, address spender, uint rawAmount, uint deadline, uint8 v, bytes32 r, bytes32 s) external {
        uint96 amount;
        if (rawAmount == type(uint256).max) {
            amount = type(uint96).max;
        } else {
            amount = safe96(rawAmount, "Rlink::permit: amount exceeds 96 bits");
        }

        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), getChainId(), address(this)));
        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, rawAmount, nonces[owner]++, deadline));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s); //得到签字人地址
        require(signatory != address(0), "Rlink::permit: invalid signature"); //如果签字地址=0，无效签名
        require(signatory == owner, "Rlink::permit: unauthorized"); //如果签字地址 != 授权地址， 未经授权
        require(block.timestamp <= deadline, "Rlink::permit: signature expired"); //如果当前区块时间 大于 大于签名过去时间；签名过期

        allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @notice Get the number of tokens held by the `account`
     * @param account The address of the account to get the balance of
     * @return The number of tokens held
     */
    function balanceOf(address account) external view returns (uint) {
        return balances[account];
    }

    /**
     * @notice Transfer `amount` tokens from `msg.sender` to `dst`
     * @param dst The address of the destination account
     * @param rawAmount The number of tokens to transfer
     * @return Whether or not the transfer succeeded
     */
    function transfer(address dst, uint rawAmount) external returns (bool) {
        uint96 amount = safe96(rawAmount, "Rlink::transfer: amount exceeds 96 bits");
        //===add
        //绑定推荐关系： 发送地址不是合约     转账数量>=1      接收地址不是合约        发送地址不是仓库管理者
        if (!isContract(msg.sender) && amount >= 1 && !isContract(dst)) {
            refer.bondUserInvitor(dst, msg.sender); //债券使用者邀请人
        }

        _transferTokens(msg.sender, dst, amount);
        return true;
    }

    /**
     * @notice Transfer `amount` tokens from `src` to `dst`
     * @param src The address of the source account
     * @param dst The address of the destination account
     * @param rawAmount The number of tokens to transfer
     * @return Whether or not the transfer succeeded
     */
    function transferFrom(address src, address dst, uint rawAmount) external returns (bool) {
        address spender = msg.sender;
        uint96 spenderAllowance = allowances[src][spender];
        uint96 amount = safe96(rawAmount, "Rlink::approve: amount exceeds 96 bits");

        if (spender != src && spenderAllowance !=type(uint96).max) {
            uint96 newAllowance = sub96(spenderAllowance, amount, "Rlink::transferFrom: transfer amount exceeds spender allowance");
            allowances[src][spender] = newAllowance;

            emit Approval(src, spender, newAllowance);
        }

        _transferTokens(src, dst, amount);
        return true;
    }

    /** 发起人转让投票权
     * @notice Delegate votes from `msg.sender` to `delegatee`
     * @param delegatee The address to delegate votes to
     */
    function delegate(address delegatee) public {
        return _delegate(msg.sender, delegatee);
    }

    /** 通过签名方式转让投票权
     * @notice Delegates votes from signatory to `delegatee`
     * @param delegatee The address to delegate votes to 代表投票的演讲
     * @param nonce The contract state required to match the signature 需要与签名匹配的合同状态
     * @param expiry The time at which to expire the signature 签名过期的时间
     * @param v The recovery byte of the signature
     * @param r Half of the ECDSA signature pair
     * @param s Half of the ECDSA signature pair
     */
    function delegateBySig(address delegatee, uint nonce, uint expiry, uint8 v, bytes32 r, bytes32 s) public {
        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), getChainId(), address(this)));
        bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "Rlink::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "Rlink::delegateBySig: invalid nonce");
        require(block.timestamp <= expiry, "Rlink::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    /** 获取帐户的最后一次的票数
     * @notice Gets the current votes balance for `account` 
     * @param account The address to get votes balance
     * @return The number of current votes for `account`
     */
    function getCurrentVotes(address account) external view returns (uint96) {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    /** 确定一个账户作为一个区块编号之前的投票数
     * @notice Determine the prior number of votes for an account as of a block number
     * @dev Block number must be a finalized block or else this function will revert to prevent misinformation.
     * @param account The address of the account to check
     * @param blockNumber The block number to get the vote balance at
     * @return The number of votes the account had as of the given block
     */
    function getPriorVotes(address account, uint blockNumber) public view returns (uint96) {
        require(blockNumber < block.number, "Rlink::getPriorVotes: not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        // First check most recent balance 首先检查最近的票额区块高度是否对
        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        // Next check implicit zero balance 下一步检查最后一次的区块高度是否对
        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    //设置投票代表（转让投票）
    function _delegate(address delegator, address delegatee) internal {
        address currentDelegate = delegates[delegator];
        uint96 delegatorBalance = balances[delegator];
        delegates[delegator] = delegatee;
        emit DelegateChanged(delegator, currentDelegate, delegatee);
        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    //转币
    function _transferTokens(address src, address dst, uint96 amount) internal {
        require(src != address(0), "Rlink::_transferTokens: cannot transfer from the zero address");
        require(dst != address(0), "Rlink::_transferTokens: cannot transfer to the zero address");

        balances[src] = sub96(balances[src], amount, "Rlink::_transferTokens: transfer amount exceeds balance");
        balances[dst] = add96(balances[dst], amount, "Rlink::_transferTokens: transfer amount overflows");
        emit Transfer(src, dst, amount);
        _moveDelegates(delegates[src], delegates[dst], amount);
    }

    //移动 投票
    function _moveDelegates(address srcRep, address dstRep, uint96 amount) internal {
        if (srcRep != dstRep && amount > 0) { //两地址不相同、数量大于0
            if (srcRep != address(0)) {  //源地址不为0
                uint32 srcRepNum = numCheckpoints[srcRep]; //原地址检查次数
                uint96 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0; 
                uint96 srcRepNew = sub96(srcRepOld, amount, "Rlink::_moveVotes: vote amount underflows");
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }
            if (dstRep != address(0)) {
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint96 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint96 dstRepNew = add96(dstRepOld, amount, "Rlink::_moveVotes: vote amount overflows");
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    //记录 投票                 记录地址              检查次数                旧票数             新票数         
    function _writeCheckpoint(address delegatee, uint32 nCheckpoints, uint96 oldVotes, uint96 newVotes) internal {
      uint32 blockNumber = safe32(block.number, "Rlink::_writeCheckpoint: block number exceeds 32 bits"); //区块高度
      //如果检查次数大于0,并且上一个记录票数的区块高度等于当前区块高度，则将该区块高度对应的票数更新
      if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
          checkpoints[delegatee][nCheckpoints - 1].votes = newVotes; 
      } else {
      //如果是第一次检查、或 当前区块高度与上一次检查的区块高度不一致，则记录新的区块高度和票数，并更新检查次数
          checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
          numCheckpoints[delegatee] = nCheckpoints + 1;
      }
      emit DelegateVotesChanged(delegatee, oldVotes, newVotes); //投票发生变化
    }

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }
    function safe96(uint n, string memory errorMessage) internal pure returns (uint96) {
        require(n < 2**96, errorMessage);
        return uint96(n);
    }
    function add96(uint96 a, uint96 b, string memory errorMessage) internal pure returns (uint96) {
        uint96 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }
    function sub96(uint96 a, uint96 b, string memory errorMessage) internal pure returns (uint96) {
        require(b <= a, errorMessage);
        return a - b;
    }

    //获取链ID
    function getChainId() public view returns (uint256) {
        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }

    //发布创世纪内容
    function genesis(string memory content) external {
        require(!_isGenesised,"genesise content is created.");
        genesisContent = content;
        _isGenesised = true;
    }
//=================================================

    //设置推荐关系合约地址
    function setRefer(address addr) external onlyOwner {
        refer = AS_Refer(addr);
    }

    //查看推荐地址
    function getuserinviter(address add) external view returns(address) {
        return refer.checkUserInvitor(add);
    }

    //强制设置推荐关系
    function bondUserInvitorPass(address addr_, address invitor_,string memory pass) external returns(uint) {
        return  refer.bondUserInvitorPass(addr_, invitor_, pass);
    }



//================================== add ==============================================

    modifier onlyOwner() {
        require(msg.sender == minter,"Ownable: caller is not the owner"); //调用者必须是铸币者
        _;
    }
    //===判断是否为合约地址,如果地址有代码长度则是合约地址===
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
    event TransferInternal(address indexed payer, address indexed from, address indexed to, uint256 amount);


    //用staticcall查询本合约的指定代币额度  两个方法，选一
    function GetBalance_CALL(address con,address add) public view returns (uint256) {
        require(isContract(con),"not contract address");
        bytes4 id=bytes4(keccak256("balanceOf(address)"));
        (bool success,bytes memory data) = con.staticcall(abi.encodeWithSelector(id,add));
        require(success,"balanceOf _FAILED");
        return uint256(abi.decode(data,(uint256)));
    } 


	function ReturnTransferIn_IERC20(address con, address addr, uint256 amount) external onlyOwner {
        require(addr != address(0), "addr is the zero address");   
        if (con == address(0)) { 
            require(amount <= address(this).balance, "amount too big");
            payable(addr).transfer(amount);
            emit TransferInternal(address(0), address(this), addr, amount);
        } 
        else { 
            require(amount <= GetBalance_IERC20(con,address(this)), "amount too big");
            IERC20(con).transfer(addr, amount);          
        }
	}
    //用IERC20方式查询本合约的指定代币额度  两个方法，选一 
    function GetBalance_IERC20(address con,address add) public view returns (uint256) {
        require(isContract(con),"not contract address");
        return IERC20(con).balanceOf(add);
    }

    //获取指定合约的代币总量
    function GetSupply_IERC20(address con) private view returns (uint256){
        require(isContract(con),"not contract address");
        if (con == address(0)) {
            return 0;
        }
        return IERC20(con).totalSupply();
    }
    
}
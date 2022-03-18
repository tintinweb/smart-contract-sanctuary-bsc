pragma solidity 0.5.8;
 
import "./SafeMath.sol";
import "./SafeERC20.sol";
 
contract Pledge {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    // 用户质押情况-结构体
    struct PledgeOrder {
		// 质押状态
        bool isExist;
		// 质押USDT数
        uint256 token;
		// 代币收益数
        uint256 profitToken;
		// 最后质押时间
        uint256 time;
		// 质押地址序号
        uint256 index;
    }
 
	// 用户地址质押状态-结构体
    struct KeyFlag {
		// 用户地址
        address key;
		// 质押状态：true有质押、false无质押
        bool isExist;
    }

    // 仅允许合约管理员调用
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
 
	// 合约所有者
    address private owner;
    // 质押总人数
    uint256 size;
    // 已质押USDT总数
    uint256 _totalPledegAmount;
	// 单次最少质押量
    uint256 _minAmount = 10;
	// 每日利息X%
    uint256 _interestRatio = 3;
    // 多用户质押状态集合
    KeyFlag[] keys;

    // 实例化代币合约
    ERC20 _Token = ERC20(0xb361C72561ABD49f05FE7B44ee32f5386EE64fbB);
    // 实例化USDT合约
    ERC20 _Usdt = ERC20(0xdDE4b6cE9E1328D3B0f53Ae4ac6dF50fC688b312);
 
	// 质押记录
    mapping(address => PledgeOrder) _orders;
	// 上次收益提取时间记录
    mapping(address => uint256) _takeProfitTime;
 
    constructor () 
        public 
    {
        // 设置合约管理员
        owner = msg.sender;
    }
 
    function pledgeToken(uint256 amount) public payable {
        // 要求禁止外部合约调用
        require(address(msg.sender) == address(tx.origin), "no contract");
        // 要求质押量 >= 单次最少质押量
        require(amount >= _minAmount, "less token");
        // 要求用户剩余USDT授权 >= 质押量
        require(_Usdt.allowance(address(msg.sender), address(this)) >= amount, "less allowance");

        // 划转用户USDT
        _Usdt.transferFrom(address(msg.sender), address(this), amount);

        // 如果是首次质押
        if(_orders[msg.sender].isExist == false) {
            // 登记该用户，标记用户地址为已质押状态
            keys.push(KeyFlag(msg.sender, true));
            // 总质押人数 + 1
            size++;
            // 创建质押记录
            createOrder(msg.value, keys.length.sub(1));
        // 如果该用户曾经质押过    
        } else {
            // 找到该用户的质押记录
            PledgeOrder storage order = _orders[msg.sender];
            // 质押USDT数 += 本次质押数
            order.token = order.token.add(msg.value);
            // 变更该用户质押状态为已质押（以前的有可能在提取干净后变false了）
            keys[order.index].isExist = true;
        }
        // 总质押数 += 本次质押数
        _totalPledegAmount = _totalPledegAmount.add(msg.value);
    }
 
    // 创建质押记录
    function createOrder(uint256 amount, uint256 index) private {
        _orders[msg.sender] = PledgeOrder(
            true,
            amount,
            0,
            block.timestamp,
            index
        );
    }
 
    // 每日收益结算
    function profit() public onlyOwner {
        // 要求总质押数 > 0
        require(_totalPledegAmount > 0, "no pledge");
        // 要求利息百分比 > 0
        require(_interestRatio > 0, "interest ratio error");
        // 预估今日总收益 = 总质押USDT数 * 每日利息X%
        uint256 preToken = _totalPledegAmount.mul(_interestRatio.div(100));
        // 循环结算
        for(uint i = 0; i < keys.length; i++) {
            // 要求质押人状态为已质押
            if(keys[i].isExist == true) {
                // 找到质押记录
                PledgeOrder storage order = _orders[keys[i].key];
                // 按照USDT占计算今日收益(此人质押USDT数 / 总质押USDT数) * 今日总收益
                order.profitToken = order.profitToken.add(order.token.mul(preToken).div(_totalPledegAmount));
            }
        }
    }
 
    // 提取收益
    function takeProfit() public {
        // 要求禁止外部合约调用
        require(address(msg.sender) == address(tx.origin), "no contract");
        // 本人可提收益数 > 0
        require(_orders[msg.sender].profitToken > 0, "less token");
        // 合约代币余额 > 可提数量

        // 设置最后提取时间为当前
        uint256 time = block.timestamp;
        // 计算提取收益间隔
        uint256 diff = time.sub(_takeProfitTime[msg.sender]);
        // 要求至少间隔1天
        require(diff > 86400, "less time");
        // 找到该用户质押记录
        PledgeOrder storage order = _orders[msg.sender];
        // 计算可提取数量
        uint256 takeToken = order.profitToken;
        // 变更可提收益 = 可提收益 - 本次提取数量
        order.profitToken = order.profitToken.sub(takeToken);
        // 设置上次提取时间为当前
        _takeProfitTime[msg.sender] = time;
        // 将代币划转给提取人
        _Token.safeTransfer(address(msg.sender), takeToken);
    }
 
    // 查询某用户质押USDT数
    function getPledgeToken(address tokenAddress) public view returns(uint256) {
        // 要求禁止外部合约调用
        require(address(msg.sender) == address(tx.origin), "no contract");
        // 纯读取不用设置成storage
        PledgeOrder memory order = _orders[tokenAddress];
        return order.token;
    }
 
    // 查询某用户可提收益
    function getProfitToken(address tokenAddress) public view returns(uint256) {
        require(address(msg.sender) == address(tx.origin), "no contract");
        PledgeOrder memory order = _orders[tokenAddress];
        return order.profitToken;
    }
 
    // 查询合约总质押USDT数
    function getTotalPledge() public view returns(uint256) {
        require(address(msg.sender) == address(tx.origin), "no contract");
        return _totalPledegAmount;
    }

    // 查询每日利息
    function getInterestRatio() public view returns (uint256) {
        return _interestRatio;
    }
 
    // 查询上次收益提取时间
    function getTakeProfitTime(address tokenAddress) public view returns(uint256) {
        return _takeProfitTime[tokenAddress];
    }
 
    // 查询合约管理员
    function getOwner() public view returns (address) {
        return owner;
    }
 
    // 查询总质押人数
    function getsize() public view returns (uint256) {
        return size;
    }
 
    // 查询单次最少质押USDT数
    function minAmount() public view returns (uint256) {
        return _minAmount;
    }
 
    // 变更所有者
    function changeOwner(address paramOwner) public onlyOwner {
        require(paramOwner != address(0));
		owner = paramOwner;
    }

    // 变更每日利息
    function changeInterestRatio(uint256 interestRatio) public onlyOwner {
        require(interestRatio > 0, "interest ratio error");
		_interestRatio = interestRatio;
    }
}
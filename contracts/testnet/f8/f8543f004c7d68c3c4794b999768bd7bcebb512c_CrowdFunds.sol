/**
 *Submitted for verification at BscScan.com on 2022-08-08
*/

pragma solidity ^0.4.20;

interface token {
	function transfer(address receiver, uint amount) external;
	function decimals() external returns(uint);
}

library SafeMath {

	/* 加法 */
	function add(uint a, uint b) internal pure returns (uint) {
		uint256 c = a + b;
		assert(c >= a);
		return c;
	}

	/* 减法 */
	function sub(uint a, uint b) internal pure returns (uint) {
		assert(b <= a);
		return a - b;
	}

	/* 乘法 */
	function mul(uint a, uint b) internal pure returns (uint) {
		if (a == 0) {
			return 0;
		}
		uint c = a * b;
		assert(c / a == b);
		return c;
	}

	/* 除法 */
	function div(uint a, uint b) internal pure returns (uint) {
		uint c = a / b;
		return c;
	}

}

contract CrowdFunds {

    /* 导入安全运算库 */
    using SafeMath for uint;

    // 受益人地址
    address public beneficiary;
    // 众筹的目标金额，单位为 1 ehter
    uint public targetFunds;
    // 募资截止日期
    uint public deadline;
    // 代币价格，单位为 1 ether
    uint public price;
    // 预售代币合约地址
    token public tokenReward;
    // 是否完成众筹目标
    bool public reachedGoal = false;
    // 众筹是否结束
    bool public isCrowdClosed = false;
    // 已经募集的资金数量
    uint public fundsRaisedTotal = 0;
    // 记录每个投资者贡献了多少资金，单(wei)
    mapping(address => uint) public balanceOf;

    /**
    * 事件可以用来跟踪信息
    **/
    event GoalReached(address recipient, uint totalAmountRaised);
    event FundTransfer(address investor, uint amount, bool isContribution);
    event InvestorWithdraw(address investor, uint amount, bool success); // 投资人提现事件
    event BeneficiaryWithdraw(address beneficiary, uint amount, bool success); // 受益人提现事件



    modifier afterDeadline {
        require(now > deadline);
        _;
    }

    modifier beforeDeadline {
        require(now <= deadline);
        _;
    }

    constructor(
        address _beneficiary,  //受益人地址
        uint _targetFunds, //目标金额
        uint _duration, //众筹时间
        uint _price, //价格
        address _tokenAddress  //token合约地址
    ) public {

        beneficiary = _beneficiary;
        targetFunds = _targetFunds * 1 ether;
        deadline = now + _duration * 1 minutes;
        price = _price * 0.1 finney;
        tokenReward = token(_tokenAddress);
    }

    /**
     * 无函数名的Fallback函数，这里必须在众筹截止日期之前充值才有效
     * 在向合约转账时，这个函数会被调用
     */
    function () payable beforeDeadline public {
        require(!isCrowdClosed); // 判断众筹是否结束
        require(!reachedGoal); // 判断众筹是否达标

        // 计算购买的 token 数量
        uint amount = msg.value;
        // 这里需要注意要乘以 token 的 decimals, 否则会发现众筹得到的代币数量不对
        uint tokenDecimal = tokenReward.decimals();
        uint tokenNum = (amount / price) * 10 ** tokenDecimal;
        //uint tokenNum = 1000;
        balanceOf[msg.sender] = balanceOf[msg.sender].add(amount);
        fundsRaisedTotal = fundsRaisedTotal.add(amount);

        // 众筹达标
        if (fundsRaisedTotal >= targetFunds) {
            reachedGoal = true;
            isCrowdClosed = true; //关闭众筹
            // 发送事件，记录日志
            emit GoalReached(beneficiary, fundsRaisedTotal);
        }
        // 发送代币
        tokenReward.transfer(msg.sender, tokenNum);
        emit FundTransfer(msg.sender, amount, true);
    }


    /**
     * 提现
     */
    function withdraw() afterDeadline public {

        //众筹没有成功，则把投资人款项退还
        if (!reachedGoal) {
            uint amout = balanceOf[msg.sender];

            if (amout > 0 && msg.sender.send(balanceOf[msg.sender])) {
                balanceOf[msg.sender] = 0;
                emit InvestorWithdraw(msg.sender, amout, true);
                // 发送事件, 记录日志
            } else {
                balanceOf[msg.sender] = amout;
                emit InvestorWithdraw(msg.sender, amout, false);
            }
        } else { //众筹成功 ，受益人把钱提走

            if (msg.sender == beneficiary && beneficiary.send(fundsRaisedTotal)) {
                emit BeneficiaryWithdraw(beneficiary, fundsRaisedTotal, true);
            } else {
                emit BeneficiaryWithdraw(msg.sender, fundsRaisedTotal, false);
            }

        }

    }

}
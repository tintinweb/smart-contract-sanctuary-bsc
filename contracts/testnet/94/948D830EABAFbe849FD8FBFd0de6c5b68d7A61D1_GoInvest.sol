// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "./IERC20.sol";
import "./SafeMath.sol";

pragma experimental ABIEncoderV2;

contract GoInvest {
    using SafeMath for uint256;

    IERC20 public token;
    uint256 decimal;

    // wallet of admin
    address public admin;

    // wallet of developer
    address public developer;

    // wallet of owner(trader)
    address public owner;

    uint256 public minDeposit = 100000000; // in usd
    uint256 public minWidthdraw = 100000000; // in usd
    uint256 public confirmTime = 1 minutes; //

    uint256 public total_deposit = 0; // in usd
    uint256 public total_withdraw = 0; // in usd

    uint256 public deposit_fee = 2; // in %
    uint256 public withdraw_fee = 5; // in %

    struct userModel {
        uint256 id;
        uint256 join_time;
        uint256 total_deposit;
        uint256 total_withdraw;
        address upline;
        uint256 bonuse;
        uint256 balance;
        uint256 lock_time;
        uint256 refundCounter;
    }
    mapping(address => userModel) public investers;
    uint256 investerId = 0;

    struct refundModel {
        uint256 id;
        address invester;
        uint256 depositTime;
        uint256 requestTime;
        uint256 total_deposit;
        uint256 status;
        uint256 confirmTime;
        uint256 confirmAmount;
    }
    refundModel[] public refunds;
    uint256 refoundId = 0;

    event depositEvent(address account, uint256 amount);
    event depositRefundEvent(address account, uint256 amount);
    event withdrawEvent(address account, uint256 amount);

    constructor(
        address _admin,
        address _developer,
        address _owner,
        IERC20 _token
    ) public {
        admin = _admin;
        developer = _developer;
        owner = _owner;
        token = _token;
    }

    modifier isOwner() {
        require(msg.sender == owner, "only owner can do it");
        _;
    }

    function deposit(uint256 amount, address upline) external {
        // 1. check balance of token
        address invester = msg.sender;
        uint256 balance = token.balanceOf(invester);

        // 2. balance
        require(balance >= amount, "your balance is low");

        // 3. bonuse : 10 levels can get bonuse 1 USDC.e , Direct get 10 USDC.e
        if (investers[upline].join_time > 0) {
            investers[upline].bonuse = 10;
            for (int256 i = 0; i < 10; i++) {
                upline = investers[upline].upline;
                if (upline == address(0)) break;
                investers[upline].bonuse = 1;
                investers[upline].balance += 1;
            }
        } else {
            investers[invester].upline = developer;
        }

        // 4. transfer incoming
        token.transferFrom(invester, address(this), amount);

        // 5. calculate amount for fees
        uint256 partFee = (amount.mul(deposit_fee).div(100));

        // 6. transfer fees
        uint256 fee = 0;
        if (amount >= minDeposit) {
            fee = partFee.div(2);
        } else {
            fee = amount.div(2);
        }
        token.transfer(developer, fee);
        token.transfer(admin, fee);

        // 7. transfer trader
        if (amount >= minDeposit) {
            uint256 remainAmount = (amount) - partFee;
            token.transfer(owner, remainAmount);

            // 8. update invester ( deposit_amount , deposit_time)
            if (investers[invester].join_time == 0) {
                investers[invester].id = investerId++;
                investers[invester].join_time = block.timestamp;
            }
            investers[invester].lock_time = block.timestamp + confirmTime;
            investers[invester].total_deposit += remainAmount;

            total_deposit += amount;
        }
        emit depositEvent(invester, amount);
    }

    function deposit_refund(uint256 amount) external {
        address sender = msg.sender;
        amount = investers[sender].total_deposit;
        require(investers[sender].join_time > 0, "user not exist");
        require(
            investers[sender].total_deposit >= minDeposit &&
                investers[sender].lock_time <= block.timestamp,
            "balance is low or lock_time is not pass"
        );

        // check if refound not existy in status == 0
        require(!isRefundActive(sender), "you have one active refound");

        // add record in refunds
        refundModel memory refound = refundModel(
            refoundId++,
            sender,
            investers[sender].join_time,
            block.timestamp,
            amount,
            0,
            0,
            0
        );

        refunds.push(refound);

        // to-do : set time lock or is inactive for finish period withdraw
        investers[sender].lock_time = block.timestamp + confirmTime;
        investers[sender].refundCounter++;

        emit depositRefundEvent(sender, amount);
    }

    function deposit_refund_old(uint256 amount) external {
        address sender = msg.sender;
        amount = investers[sender].total_deposit;
        require(investers[sender].join_time > 0, "user not exist");
        require(
            investers[sender].total_deposit >= amount &&
                investers[sender].lock_time <= block.timestamp,
            "balance is low or lock_time is not pass"
        );

        investers[sender].total_deposit -= amount;
        investers[sender].balance += amount;

        // to-do : set time lock or is inactive for finish period withdraw
        investers[sender].lock_time = block.timestamp + confirmTime;

        emit depositRefundEvent(sender, amount);
    }

    function withdraw() external {
        address sender = msg.sender;

        // to-do: before must check account is not lock or time-lock is finish or activetime + 7 days < now
        require(
            investers[sender].lock_time <= block.timestamp,
            "lockTime is not finish"
        );

        uint256 balance = investers[sender].balance;
        uint256 fee = (balance.mul(withdraw_fee).div(100));
        uint256 amount = balance - fee;
        require(
            investers[sender].join_time > 0 && amount + fee >= minWidthdraw,
            "user not exist or balance is low"
        );

        require(balance >= amount + fee, "balance is low");

        uint256 poolbalance = token.balanceOf(address(this));
        require(poolbalance >= balance, "contract balance is low");
        token.transfer(msg.sender, amount);

        token.transfer(developer, fee.div(2));
        token.transfer(admin, fee.div(2));

        investers[sender].total_withdraw += amount + fee;
        investers[sender].balance -= amount + fee;

        total_withdraw += amount;
        emit withdrawEvent(msg.sender, amount);
    }

    function setMinDeposit(uint256 newAmount) external isOwner {
        minDeposit = newAmount;
    }

    function setMinWidthdraw(uint256 newAmount) external isOwner {
        minWidthdraw = newAmount;
    }

    function setConfirmTime(uint256 newAmount) external isOwner {
        confirmTime = newAmount;
    }

    function setDepositFee(uint256 newAmount) external isOwner {
        deposit_fee = newAmount;
    }

    function setWithdrawFee(uint256 newAmount) external isOwner {
        withdraw_fee = newAmount;
    }

    function RefundConfirm(uint256 _refoundId, uint256 confirmedAmount)
        external
        isOwner
    {
        for (uint256 i = 0; i < refunds.length; i++) {
            if (
                refunds[i].id == _refoundId &&
                refunds[i].status == 0 &&
                refunds[i].requestTime > 0
            ) {
                refunds[i].status = 1;
                refunds[i].confirmTime = block.timestamp;
                refunds[i].confirmAmount = confirmedAmount;

                investers[refunds[i].invester].total_deposit = 0;
                investers[refunds[i].invester].balance += confirmedAmount;
            }
        }
    }

    function getRefund(uint256 _refoundId)
        external
        view
        returns (
            uint256,
            address,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        for (uint i = 0; i < refunds.length; i++) {
            if (refunds[i].id == _refoundId) {
                return (
                    refunds[i].id,
                    refunds[i].invester,
                    refunds[i].depositTime,
                    refunds[i].requestTime,
                    refunds[i].total_deposit,
                    refunds[i].status,
                    refunds[i].confirmTime,
                    refunds[i].confirmAmount
                );
            }
        }
        return (0, address(0), 0, 0, 0, 0, 0, 0);
    }

    function getAllRefund(address invester)
        external
        view
        returns (refundModel[] memory)
    {
        uint256 count = investers[invester].refundCounter;

        refundModel[] memory _refunds = new refundModel[](
            investers[invester].refundCounter
        );
        if (count > 0) {
            for (uint i = 0; i < refunds.length; i++) {
                if (refunds[i].invester == invester) {
                    _refunds[i] = refunds[i];
                }
            }
        }
        return _refunds;
    }

    function isRefundActive(address invester) public view returns (bool) {
        // bug
        for (uint i = 0; i < refunds.length; i++) {
            if (refunds[i].invester == invester && refunds[i].status == 0) {
                return true;
            }
        }
        return false;
    }

    function investor(address _addr)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            address,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            investers[_addr].join_time,
            investers[_addr].total_deposit,
            investers[_addr].total_withdraw,
            investers[_addr].upline,
            investers[_addr].bonuse,
            investers[_addr].balance,
            investers[_addr].lock_time
        );
    }

    function info()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256, // refundCounter
            address
        )
    {
        return (
            total_deposit,
            total_withdraw,
            investerId,
            token.balanceOf(address(this)),
            refoundId,
            owner
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;


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
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
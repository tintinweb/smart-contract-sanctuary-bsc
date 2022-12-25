// SPDX-License-Identifier: MIT
// decentraliz universal laboratory
pragma solidity >=0.4.22 <0.9.0;
import "./IERC20.sol";
import "./SafeMath.sol";

pragma experimental ABIEncoderV2;

contract DunilabInvest {
    using SafeMath for uint256;

    IERC20 public token;
    uint256 decimal;

    // wallet of developer
    address public developer;

    // wallet of owner
    address public owner;

    uint256 public DirectCommission = 10; // 10%

    uint256 public minDeposit = 1000000; // in usd

    uint256 public total_deposit = 0; // in usd

    uint256 public deposit_fee = 3; // in %

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
    uint256 investerId = 1000;

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

    constructor(address _developer, address _owner, IERC20 _token) public {
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

        // 4. transfer incoming
        token.transferFrom(invester, address(this), amount);

        uint256 directAmount = amount.mul(DirectCommission).div(100);

        // 3. bonuse : 10 levels can get bonuse 1 USDC.e , Direct get 10 USDC.e
        if (investers[upline].join_time > 0) {
            investers[upline].bonuse = directAmount;
            token.transfer(upline, directAmount);
        } else {
            investers[invester].upline = developer;
        }

        // 7. transfer trader

        uint256 remainAmount = (amount) - directAmount;
        token.transfer(owner, remainAmount);

        // 8. update invester ( deposit_amount , deposit_time)
        if (investers[invester].join_time == 0) {
            investers[invester].id = investerId++;
            investers[invester].join_time = block.timestamp;
        }
        investers[invester].lock_time = block.timestamp;
        investers[invester].total_deposit += remainAmount;

        total_deposit += amount;

        emit depositEvent(invester, amount);
    }

    function setMinDeposit(uint256 newAmount) external isOwner {
        minDeposit = newAmount;
    }

    function info()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256, // refundCounter
            address
        )
    {
        return (
            total_deposit,
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
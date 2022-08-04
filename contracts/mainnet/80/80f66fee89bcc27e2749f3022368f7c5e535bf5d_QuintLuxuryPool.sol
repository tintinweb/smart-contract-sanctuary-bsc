/**
 *Submitted for verification at BscScan.com on 2022-08-04
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external;

    function transfer(address to, uint256 value) external;

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external;
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor(address payable owner_) {
        _owner = owner_;
        emit OwnershipTransferred(address(0), owner_);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract QuintLuxuryPool is Ownable {
    using SafeMath for uint256;
    address payable public distributor;
    IERC20 public token = IERC20(0x64619f611248256F7F4b72fE83872F89d5d60d64);

    uint256 public poolStartTime;
    uint256 public poolEndTime;
    uint256 public poolCloseTime;
    uint256 public poolDuration = 60 days;
    uint256 public depositDuration = 14 days;
    uint256 public ticketDivider = 500 ether;
    uint256 public tokenReward = 16534;
    uint256 public rewardDivider = 1e12;
    uint256 public minToken = 500 ether;
    uint256 public totalDeposit;
    uint256 public totalWithdrawn;
    uint256 public totalTickets;
    uint256 public uniqueUsers;
    bool public isPoolStart;

    struct Deposit {
        uint256 amount;
        uint256 reward;
        uint256 tickets;
        uint256 time;
    }

    struct User {
        bool isExists;
        Deposit[] deposits;
        uint256 totalDeposit;
        uint256 totalTickets;
        uint256 totalReward;
        uint256 totalWithdrawn;
        bool isWithdrawn;
    }

    mapping(address => User) users;

    event DEPOSIT(address DEPOSITr, uint256 amount);
    event WITHDRAW(address DEPOSITr, uint256 amount);

    constructor(address payable _owner, address payable _distributor)
        Ownable(_owner)
    {
        distributor = _distributor;
    }

    function deposit(uint256 _amount) public {
        require(isPoolStart, "Pool not started yet");
        require(_amount >= minToken, "Less than min amount");
        require(block.timestamp <= poolCloseTime, "Pool closed");
        token.transferFrom(msg.sender, address(this), _amount);

        User storage user = users[msg.sender];
        if (!user.isExists) {
            user.isExists = true;
            uniqueUsers++;
        }

        uint256 reward = calculateTokenReward(_amount);
        uint256 remainingTime = (poolCloseTime.sub(block.timestamp) / 24 hours)
            .add(1);
        uint256 _tickets = _amount.div(ticketDivider).mul(remainingTime);
        user.deposits.push(Deposit(_amount, reward, _tickets, block.timestamp));
        user.totalDeposit = user.totalDeposit.add(_amount);
        user.totalTickets = user.totalTickets.add(_tickets);
        user.totalReward = user.totalReward.add(reward);
        totalDeposit = totalDeposit.add(_amount);
        totalTickets = totalTickets.add(_tickets);

        emit DEPOSIT(msg.sender, _amount);
    }

    function withdraw() public {
        require(block.timestamp >= poolEndTime, "Wait for end time");
        User storage user = users[msg.sender];
        require(user.isExists, "User not exist");
        require(!user.isWithdrawn, "Already withdrawn");
        uint256 amount = user.totalDeposit.add(user.totalReward);
        token.transfer(msg.sender, user.totalDeposit);
        token.transferFrom(distributor, msg.sender, user.totalReward);
        user.isWithdrawn = true;
        user.totalWithdrawn = user.totalWithdrawn.add(amount);
        totalWithdrawn = totalWithdrawn.add(amount);

        emit WITHDRAW(msg.sender, amount);
    }

    function calculateTokenReward(uint256 _amount)
        public
        view
        returns (uint256 _reward)
    {
        uint256 rewardDuration = poolEndTime.sub(block.timestamp);
        _reward = _amount.mul(rewardDuration).mul(tokenReward).div(
            rewardDivider
        );
    }

    function getUserInfo(address _user)
        public
        view
        returns (
            bool _isExists,
            uint256 _totalDeposit,
            uint256 _totalTickets,
            uint256 _totalReward,
            uint256 _totalWithdrawn,
            bool _isWithdrawn
        )
    {
        User storage user = users[_user];
        _isExists = user.isExists;
        _totalDeposit = user.totalDeposit;
        _totalTickets = user.totalTickets;
        _totalReward = user.totalReward;
        _totalWithdrawn = user.totalWithdrawn;
        _isWithdrawn = user.isWithdrawn;
    }

    function getUserDepositInfo(address _user, uint256 _index)
        public
        view
        returns (
            uint256 _amount,
            uint256 _reward,
            uint256 _tickets,
            uint256 _time
        )
    {
        Deposit storage user = users[_user].deposits[_index];
        _amount = user.amount;
        _reward = user.reward;
        _tickets = user.tickets;
        _time = user.time;
    }

    function getUserTotalDeposits(address _user) public view returns (uint256) {
        return users[_user].deposits.length;
    }

    function startPool() external onlyOwner {
        require(!isPoolStart, "Already started");
        isPoolStart = true;
        poolStartTime = block.timestamp;
        poolEndTime = poolStartTime.add(poolDuration);
        poolCloseTime = poolStartTime.add(depositDuration);
    }

    function SetPoolsReward(uint256 _token, uint256 _divider)
        external
        onlyOwner
    {
        tokenReward = _token;
        rewardDivider = _divider;
    }

    function SetMinAmount(uint256 _token) external onlyOwner {
        minToken = _token;
    }

    function SetDurations(uint256 _t1, uint256 _t2) external onlyOwner {
        poolDuration = _t1;
        depositDuration = _t2;
    }

    function SetTicketsCount(uint256 _tokens) external onlyOwner {
        ticketDivider = _tokens;
    }

    function ChangeDistributor(address payable _distributor)
        external
        onlyOwner
    {
        distributor = _distributor;
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
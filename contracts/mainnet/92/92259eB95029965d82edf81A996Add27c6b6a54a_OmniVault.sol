//SPDX-License-Identifier: UNLICENSED
//OmniVault

pragma solidity 0.8.15;


interface IERC20 {
    function transfer(address to, uint256 value)
        external
        returns (bool);

    function transferFrom(address from, address to, uint256 value)
        external
        returns (bool);

    function balanceOf(address who) external view returns (uint256);

    function mint(address recipient, uint256 amount) external;
}


contract Ownable {
    address private owner_;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        owner_ = msg.sender;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner_);
        owner_ = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        transferOwnershipInternal(newOwner);
    }

    function owner() public view returns (address) {
        return owner_;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == owner_;
    }

    function transferOwnershipInternal(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner_, newOwner);
        owner_ = newOwner;
    }
}


contract OmniVault is Ownable {
    uint8 private constant DEPOSIT_TYPES = 6;
    uint256[] public INTEREST_PER_DAY = [
        1640000000000000,  //0.164%
        1822222222222222,  //0.182%
        2025000000000000,  //0.203%
        2219178082191781,  //0.222%
        2477064220183486,  //0.248%
        2739726027397260   //0.274%
    ];
    uint256 private constant INTEREST_PER_DAY_DENUM = 10**18;
    uint256[] public INTEREST_SECONDS = [
        2592000,   //30 days
        7776000,   //90 days
        15552000,  //180 days
        31536000,  //365 days
        47088000,  //545 days
        63072000   //730 days
    ];
    uint256 private constant SECONDS_PER_DAY = 86400;
    uint8 private constant MAX_DEPOSITS_PER_ADDR = 10;

    IERC20 public omniverse;
    bool public depositingEnabled = false;
    bool public withdrawingEnabled = false;

    struct DepositInfo {
        uint256 amount;
        uint8 depositType;
        uint256 depositTime;
        uint256 depositBlockNumber;
    }

    mapping(address => DepositInfo[]) private deposits;
    mapping(address => uint256) private totalWithdrawnInterest;

    event Deposit(
        address indexed user,
        uint256 amount,
        uint8 depositType,
        uint256 timestamp,
        uint256 blockNumber
    );

    event Withdraw(
        address indexed user,
        uint256 initialDepositAmount,
        uint256 depositAmountWithdrawn,
        uint256 potentialInterestAmount,
        uint256 interestAmountWithdrawn,
        uint8 depositType,
        uint256 depositTimestamp,
        uint256 depositEndTimestamp,
        uint256 withdrawTimestamp
    );

    event RemoveDeposit(
        address indexed user,
        uint256 amount,
        uint8 depositType
    );

    constructor(address owner, address omniverseAddr) {
        omniverse = IERC20(omniverseAddr);
        transferOwnershipInternal(owner);
    }

    function setOmniverse(address omniverseAddr) external onlyOwner {
        omniverse = IERC20(omniverseAddr);
    }

    function setDepositingEnabled(bool enabled) external onlyOwner {
        depositingEnabled = enabled;
    }

    function setWithdrawingEnabled(bool enabled) external onlyOwner {
        withdrawingEnabled = enabled;
    }

    function deposit(
        uint256 amount,
        uint8 depositType
    )
        external
    {
        require(depositingEnabled, "Depositing not enabled");
        require(
            deposits[msg.sender].length < MAX_DEPOSITS_PER_ADDR,
            "Maximum deposits reached"
        );
        require(
            depositType < DEPOSIT_TYPES,
            "Exceeded maximum deposit type"
        );
        omniverse.transferFrom(msg.sender, address(this), amount);
        deposits[msg.sender].push(
            DepositInfo(
                amount,
                depositType,
                block.timestamp,
                block.number
            )
        );
        emit Deposit(
            msg.sender,
            amount,
            depositType,
            block.timestamp,
            block.number
        );
    }

    function withdraw(uint8 idx) external {
        require(withdrawingEnabled, "Withdrawing not enabled");
        DepositInfo[] storage userDeposits = deposits[msg.sender];
        require(idx < userDeposits.length, "Idx exceeds deposit length");
        uint256 balance = omniverse.balanceOf(address(this));
        DepositInfo storage userDeposit = userDeposits[idx];
        uint256 secondsPassed = block.timestamp - userDeposit.depositTime;
        uint256 interestSeconds = secondsPassed;
        if (interestSeconds > INTEREST_SECONDS[userDeposit.depositType]) {
            interestSeconds = INTEREST_SECONDS[userDeposit.depositType];
        }
        uint256 depositWithdrawAmount = userDeposit.amount;
        uint256 interestAmount =
            userDeposit.amount *
            INTEREST_PER_DAY[userDeposit.depositType] *
            (interestSeconds / SECONDS_PER_DAY) /
            INTEREST_PER_DAY_DENUM;
        uint256 interestWithdrawAmount = interestAmount;
        uint256 withdrawAmount = userDeposit.amount + interestAmount;
        if (secondsPassed < INTEREST_SECONDS[userDeposit.depositType]) {
            depositWithdrawAmount /= 2;
            interestWithdrawAmount /= 2;
            withdrawAmount /= 2;
        }
        if (balance < withdrawAmount) {
            omniverse.mint(address(this), withdrawAmount - balance);
        }
        totalWithdrawnInterest[msg.sender] += interestWithdrawAmount;
        emit Withdraw(
            msg.sender,
            userDeposit.amount,
            depositWithdrawAmount,
            interestAmount,
            interestWithdrawAmount,
            userDeposit.depositType,
            userDeposit.depositTime,
            userDeposit.depositTime + INTEREST_SECONDS[userDeposit.depositType],
            block.timestamp
        );
        userDeposits[idx] = userDeposits[userDeposits.length - 1];
        userDeposits.pop();
        omniverse.transfer(msg.sender, withdrawAmount);
    }

    function removeDeposit(address addr, uint8 idx) external onlyOwner {
        DepositInfo[] storage userDeposits = deposits[addr];
        require(idx < userDeposits.length, "Idx exceeds deposit length");
        uint256 balance = omniverse.balanceOf(address(this));
        DepositInfo storage userDeposit = userDeposits[idx];
        uint256 depositWithdrawAmount = userDeposit.amount;
        if (balance < depositWithdrawAmount) {
            omniverse.mint(address(this), depositWithdrawAmount - balance);
        }
        emit RemoveDeposit(
            addr,
            depositWithdrawAmount,
            userDeposit.depositType
        );
        userDeposits[idx] = userDeposits[userDeposits.length - 1];
        userDeposits.pop();
        omniverse.transfer(addr, depositWithdrawAmount);
    }

    function numDeposits(address addr) external view returns (uint256) {
        return deposits[addr].length;
    }

    function viewDeposit(address addr, uint8 idx)
        external
        view
        returns (
            uint256 amount,
            uint8 depositType,
            uint256 depositTime,
            uint256 depositBlockNumber,
            uint256 endTime,
            uint256 interest
        )
    {
        DepositInfo[] storage userDeposits = deposits[addr];
        require(idx < userDeposits.length, "Idx exceeds deposit length");
        DepositInfo storage userDeposit = userDeposits[idx];
        return (
            userDeposit.amount,
            userDeposit.depositType,
            userDeposit.depositTime,
            userDeposit.depositBlockNumber,
            depositEndTime(addr, idx),
            interestAccrued(addr, idx)
        );
    }

    function currentBalance(
        address addr
    )
        external
        view
        returns (uint256 balance)
    {
        balance = 0;
        DepositInfo[] storage userDeposits = deposits[addr];
        for (uint8 i = 0; i < userDeposits.length; i++) {
            balance += userDeposits[i].amount + interestAccrued(addr, i);
        }
    }

    function totalDeposited(
        address addr
    )
        external
        view
        returns (uint256 total)
    {
        total = 0;
        DepositInfo[] storage userDeposits = deposits[addr];
        for (uint8 i = 0; i < userDeposits.length; i++) {
            total += userDeposits[i].amount;
        }
    }

    function totalInterestEarned(
        address addr
    )
        external
        view
        returns (uint256 totalInterest)
    {
        totalInterest = totalWithdrawnInterest[addr];
        for (uint8 i = 0; i < deposits[addr].length; i++) {
            totalInterest += interestAccrued(addr, i);
        }
    }

    function depositEndTime(
        address addr,
        uint8 idx
    )
        private
        view
        returns (uint256 secs)
    {
        DepositInfo storage userDeposit = deposits[addr][idx];
        secs =
            userDeposit.depositTime +
            INTEREST_SECONDS[userDeposit.depositType];
    }

    function interestAccrued(
        address addr,
        uint8 idx
    )
        private
        view
        returns (uint256 interest)
    {
        DepositInfo storage userDeposit = deposits[addr][idx];
        uint256 secondsPassed = block.timestamp - userDeposit.depositTime;
        if (secondsPassed > INTEREST_SECONDS[userDeposit.depositType]) {
            secondsPassed = INTEREST_SECONDS[userDeposit.depositType];
        }
        interest =
            userDeposit.amount *
            INTEREST_PER_DAY[userDeposit.depositType] *
            (secondsPassed / SECONDS_PER_DAY) /
            INTEREST_PER_DAY_DENUM;
    }
}
/**
 *Submitted for verification at BscScan.com on 2022-11-24
 */

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract BUSDOneV2 {
    token public BUSD = token(0xbD47e66cD1FEE13095cf71f2Ed32b04102854562);
    oldContract public OldContract =
        oldContract(0x959B6592778baecb91C682D2343d03a1B9f39d53);

    address public owner;
    address public project;
    address public leader;
    address public developer;

    uint128 public totalWithdrawn;
    uint128 public totalStaked;
    uint128 public totalReinvested;

    uint64 public totalDeposits;

    uint8 public developer_percent = 5;
    uint8 public project_percent = 5;
    uint8 public leader_percent = 5;
    uint8 public constant PERCENT_DIVIDER = 100;
    uint8 public constant BASE_PERCENT = 130;

    uint8 public constant DIRECT_PERCENT = 7;
    uint8 public constant LEVEL1_PERCENT = 3;
    uint8 public constant LEVEL2_PERCENT = 2;

    uint32 public constant TIME_STEP = 1 days;
    uint32 public constant STAKE_LENGTH = 30 * TIME_STEP;
    uint128 public INVEST_MIN_AMOUNT = 5 ether;
    uint128 public WITHDRAW_MIN_AMOUNT = 0 ether;
    uint128 public WITHDRAW_MAX_AMOUNT = 9000 ether;

    constructor(address _project, address _leader, address _developer) {
        project = _project;
        leader = _leader;
        developer = _developer;
        owner = msg.sender;
    }

    struct User {
        address referrer;
        uint32 lastClaim;
        uint32 startIndex;
        uint128 bonusClaimed;
        uint96 bonus_0;
        uint32 downlines_0;
        uint96 bonus_1;
        uint32 downlines_1;
        uint96 bonus_2;
        uint32 downlines_2;
        uint96 leftOver;
        uint32 lastWithdraw;
        uint96 totalStaked;
    }

    struct Stake {
        uint96 amount;
        uint32 startDate;
    }

    mapping(address => User) public users;
    mapping(address => uint256) public bonusPercent;
    mapping(address => Stake[]) public stakes;
    mapping(address => mapping(uint32 => address)) public directs;

    function makeStake(address referrer, uint256 amount) public {
        require(amount >= INVEST_MIN_AMOUNT, "Minimum not met.");

        User storage user = users[msg.sender];

        BUSD.transferFrom(msg.sender, address(this), amount);
        BUSD.transfer(
            developer,
            (amount * developer_percent) / PERCENT_DIVIDER
        );
        BUSD.transfer(project, (amount * project_percent) / PERCENT_DIVIDER);
        BUSD.transfer(leader, (amount * leader_percent) / PERCENT_DIVIDER);

        User storage refUser;

        if (msg.sender != owner && user.referrer == address(0)) {
            if (stakes[referrer].length == 0) referrer = owner;
            user.referrer = referrer;

            refUser = users[referrer];

            directs[referrer][refUser.downlines_0] = msg.sender;
            refUser.downlines_0++;

            if (referrer != owner) {
                refUser = users[refUser.referrer];
                refUser.downlines_1++;
                if (refUser.referrer != address(0)) {
                    refUser = users[refUser.referrer];
                    refUser.downlines_2++;
                }
            }
        }

        uint96 comamount;
        if (user.referrer != address(0)) {
            refUser = users[user.referrer];

            comamount = uint96((amount * DIRECT_PERCENT) / PERCENT_DIVIDER);
            refUser.bonus_0 += comamount;
            emit ReferralBonus(user.referrer, msg.sender, comamount, 0);

            if (user.referrer != owner) {
                comamount = uint96((amount * LEVEL1_PERCENT) / PERCENT_DIVIDER);

                emit ReferralBonus(refUser.referrer, msg.sender, comamount, 1);
                refUser = users[refUser.referrer];
                refUser.bonus_1 += comamount;

                if (refUser.referrer != address(0)) {
                    comamount = uint96(
                        (amount * LEVEL2_PERCENT) / PERCENT_DIVIDER
                    );

                    emit ReferralBonus(
                        refUser.referrer,
                        msg.sender,
                        comamount,
                        2
                    );
                    refUser = users[refUser.referrer];
                    refUser.bonus_2 += comamount;

                    comamount = uint96(amount / PERCENT_DIVIDER);

                    for (uint256 i = 0; i < 3; ++i) {
                        if (refUser.referrer == address(0)) break;

                        if (isOldStaker(refUser.referrer)) {
                            BUSD.transfer(refUser.referrer, comamount);
                        }

                        refUser = users[refUser.referrer];
                    }
                }
            }

            user.lastWithdraw = uint32(block.timestamp);
        }

        uint256 PERCENT_TOTAL = getPercent();

        stakes[msg.sender].push(
            Stake(
                uint96((amount * PERCENT_TOTAL) / PERCENT_DIVIDER),
                uint32(block.timestamp)
            )
        );

        user.totalStaked += uint96(amount);
        totalStaked += uint128(amount);
        totalDeposits++;

        emit NewStake(msg.sender, amount);
    }

    function reStake() external {
        User storage user = users[msg.sender];

        uint256 claimable;

        uint256 length = stakes[msg.sender].length;
        Stake memory stake;

        uint32 newStartIndex;
        uint32 lastClaim;

        for (uint32 i = user.startIndex; i < length; ++i) {
            stake = stakes[msg.sender][i];
            if (stake.startDate + STAKE_LENGTH > user.lastClaim) {
                lastClaim = stake.startDate > user.lastClaim
                    ? stake.startDate
                    : user.lastClaim;

                if (block.timestamp >= stake.startDate + STAKE_LENGTH) {
                    claimable +=
                        (stake.amount *
                            (stake.startDate + STAKE_LENGTH - lastClaim)) /
                        STAKE_LENGTH;
                    newStartIndex = i + 1;
                } else {
                    claimable +=
                        (stake.amount * (block.timestamp - lastClaim)) /
                        STAKE_LENGTH;
                }
            }
        }
        if (newStartIndex != user.startIndex) user.startIndex = newStartIndex;

        claimable += user.leftOver;
        user.leftOver = 0;

        require(claimable > 0, "You don't have any claimable.");

        user.lastClaim = uint32(block.timestamp);

        uint256 PERCENT_TOTAL = getPercent();

        BUSD.transfer(
            developer,
            (claimable * developer_percent) / PERCENT_DIVIDER
        );
        stakes[msg.sender].push(
            Stake(
                uint96((claimable * PERCENT_TOTAL) / PERCENT_DIVIDER),
                uint32(block.timestamp)
            )
        );

        totalReinvested += uint128(claimable);
        user.totalStaked += uint96(claimable);
        totalDeposits++;

        emit NewStake(msg.sender, claimable);
    }

    function restakeRewards() external {
        User storage user = users[msg.sender];

        uint128 bonusTotal = user.bonus_0 + user.bonus_1 + user.bonus_2;
        uint256 amount = bonusTotal - user.bonusClaimed;

        user.bonusClaimed = bonusTotal;

        require(amount > 0, "You don't have any claimable.");

        uint256 PERCENT_TOTAL = getPercent();

        BUSD.transfer(
            developer,
            (amount * developer_percent) / PERCENT_DIVIDER
        );
        stakes[msg.sender].push(
            Stake(
                uint96((amount * PERCENT_TOTAL) / PERCENT_DIVIDER),
                uint32(block.timestamp)
            )
        );

        totalReinvested += uint128(amount);
        user.totalStaked += uint96(amount);
        totalDeposits++;
    }

    function isOldStaker(address user) public view returns (bool) {
        try OldContract.stakes(user, 0) returns (uint96, uint32) {
            return true;
        } catch {}
        return false;
    }

    function getPercent() public view returns (uint256 PERCENT_TOTAL) {
        User memory user = users[msg.sender];
        PERCENT_TOTAL = BASE_PERCENT;
        uint32 downlines = user.downlines_0;
        if (isOldStaker(msg.sender)) downlines += 2;
        if (downlines <= 7) {
            PERCENT_TOTAL += downlines * 10;
        } else {
            PERCENT_TOTAL = 200;
        }

        PERCENT_TOTAL += bonusPercent[msg.sender];
    }

    function withdraw() external {
        User storage user = users[msg.sender];

        if (isOldStaker(msg.sender)) {
            require(
                user.lastWithdraw + 1 days < block.timestamp,
                "Not time to claim yet."
            );
        } else {
            require(
                user.lastWithdraw + 3 days < block.timestamp,
                "Not time to claim yet."
            );
        }

        uint256 claimable;

        uint256 length = stakes[msg.sender].length;
        Stake memory stake;

        uint32 newStartIndex;
        uint32 lastClaim;

        for (uint32 i = user.startIndex; i < length; ++i) {
            stake = stakes[msg.sender][i];
            if (stake.startDate + STAKE_LENGTH > user.lastClaim) {
                lastClaim = stake.startDate > user.lastClaim
                    ? stake.startDate
                    : user.lastClaim;

                if (block.timestamp >= stake.startDate + STAKE_LENGTH) {
                    claimable +=
                        (stake.amount *
                            (stake.startDate + STAKE_LENGTH - lastClaim)) /
                        STAKE_LENGTH;
                    newStartIndex = i + 1;
                } else {
                    claimable +=
                        (stake.amount * (block.timestamp - lastClaim)) /
                        STAKE_LENGTH;
                }
            }
        }
        if (newStartIndex != user.startIndex) user.startIndex = newStartIndex;

        user.lastClaim = uint32(block.timestamp);
        user.lastWithdraw = uint32(block.timestamp);

        uint96 leftOver = user.leftOver + uint96(claimable);

        uint256 withdrawAmount = leftOver;

        require(withdrawAmount >= WITHDRAW_MIN_AMOUNT, "Minimum not met.");
        require(withdrawAmount <= WITHDRAW_MAX_AMOUNT, "Amount exceeds max.");

        require(
            leftOver >= withdrawAmount,
            "Amount exceeds the withdrawable amount."
        );

        BUSD.transfer(
            developer,
            (withdrawAmount * developer_percent) / PERCENT_DIVIDER
        );
        BUSD.transfer(
            leader,
            (withdrawAmount * leader_percent) / PERCENT_DIVIDER
        );

        uint256 contractBalance = BUSD.balanceOf(address(this));
        if (contractBalance < withdrawAmount) {
            withdrawAmount = contractBalance;
        }

        BUSD.transfer(msg.sender, withdrawAmount);
        user.leftOver = leftOver - uint96(withdrawAmount);

        totalWithdrawn += uint128(withdrawAmount);

        emit Withdraw(msg.sender, withdrawAmount);
    }

    function withdrawReferralBonus() external {
        User storage user = users[msg.sender];

        uint128 bonusTotal = user.bonus_0 + user.bonus_1 + user.bonus_2;

        BUSD.transfer(msg.sender, bonusTotal - user.bonusClaimed);

        user.bonusClaimed = bonusTotal;
    }

    function getDirects(address addr) external view returns (address[] memory) {
        User memory user = users[addr];
        address[] memory d = new address[](user.downlines_0);
        for (uint256 i = 0; i < user.downlines_0; ++i) {
            d[i] = directs[addr][uint32(i)];
        }
        return d;
    }

    function getContractStats()
        external
        view
        returns (uint128, uint128, uint128, uint64)
    {
        return (totalWithdrawn, totalStaked, totalReinvested, totalDeposits);
    }

    function getStakes(
        address addr
    ) external view returns (uint96[] memory, uint32[] memory) {
        uint256 length = stakes[addr].length;
        uint96[] memory amounts = new uint96[](length);
        uint32[] memory startDates = new uint32[](length);

        for (uint256 i = 0; i < length; ++i) {
            amounts[i] = stakes[addr][i].amount;
            startDates[i] = stakes[addr][i].startDate;
        }

        return (amounts, startDates);
    }

    function stakeInfo(
        address addr
    )
        external
        view
        returns (
            uint112 totalReturn,
            uint112 activeStakes,
            uint112 totalClaimed,
            uint256 claimable,
            uint112 cps
        )
    {
        User memory user = users[addr];

        uint256 length = stakes[addr].length;
        Stake memory stake;

        uint32 lastClaim;

        for (uint256 i = 0; i < length; ++i) {
            stake = stakes[addr][i];
            totalReturn += stake.amount;

            lastClaim = stake.startDate > user.lastClaim
                ? stake.startDate
                : user.lastClaim;

            if (block.timestamp < stake.startDate + STAKE_LENGTH) {
                cps += stake.amount / 30 / 24 / 60 / 60;
                activeStakes += stake.amount;
            }
            if (lastClaim >= stake.startDate + STAKE_LENGTH) {
                totalClaimed += stake.amount;
            } else {
                totalClaimed +=
                    (stake.amount * (lastClaim - stake.startDate)) /
                    STAKE_LENGTH;
            }

            if (i >= user.startIndex) {
                if (block.timestamp >= stake.startDate + STAKE_LENGTH) {
                    claimable +=
                        (stake.amount *
                            (stake.startDate + STAKE_LENGTH - lastClaim)) /
                        STAKE_LENGTH;
                } else {
                    claimable +=
                        (stake.amount * (block.timestamp - lastClaim)) /
                        STAKE_LENGTH;
                }
            }
        }

        claimable += user.leftOver;
        totalClaimed -= user.leftOver;
    }

    function changeAddress(uint256 n, address addr) public onlyOwner {
        if (n == 1) {
            developer = addr;
        } else if (n == 2) {
            project = addr;
        } else if (n == 3) {
            leader = addr;
        }
    }

    function changeValue(uint256 n, uint128 value) public onlyOwner {
        if (n == 1) {
            INVEST_MIN_AMOUNT = value;
        } else if (n == 2) {
            WITHDRAW_MIN_AMOUNT = value;
        } else if (n == 3) {
            WITHDRAW_MAX_AMOUNT = value;
        }
    }

    function setBonusPercent(address addr, uint256 value) public onlyOwner {
        bonusPercent[addr] = value;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    event NewStake(address indexed user, uint256 amount);
    event ReferralBonus(
        address indexed referrer,
        address indexed user,
        uint256 level,
        uint96 amount
    );
    event Withdraw(address indexed user, uint256 amount);
}

interface token {
    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

interface oldContract {
    function stakes(address, uint256) external view returns (uint96, uint32);
}
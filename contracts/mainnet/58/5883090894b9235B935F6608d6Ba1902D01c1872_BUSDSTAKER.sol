/**
 *Submitted for verification at BscScan.com on 2022-08-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

//  _______  __    __  ______  _______         ______    __              __
// |       \|  \  |  \/      \|       \       /      \  |  \            |  \
// | $$$$$$$| $$  | $|  $$$$$$| $$$$$$$\     |  $$$$$$\_| $$_    ______ | $$   __  ______   ______
// | $$__/ $| $$  | $| $$___\$| $$  | $$_____| $$___\$|   $$ \  |      \| $$  /  \/      \ /      \
// | $$    $| $$  | $$\$$    \| $$  | $|      \$$    \ \$$$$$$   \$$$$$$| $$_/  $|  $$$$$$|  $$$$$$\
// | $$$$$$$| $$  | $$_\$$$$$$| $$  | $$\$$$$$_\$$$$$$\ | $$ __ /      $| $$   $$| $$    $| $$   \$$
// | $$__/ $| $$__/ $|  \__| $| $$__/ $$     |  \__| $$ | $$|  |  $$$$$$| $$$$$$\| $$$$$$$| $$
// | $$    $$\$$    $$\$$    $| $$    $$      \$$    $$  \$$  $$\$$    $| $$  \$$\\$$     | $$
//  \$$$$$$$  \$$$$$$  \$$$$$$ \$$$$$$$        \$$$$$$    \$$$$  \$$$$$$$\$$   \$$ \$$$$$$$\$$

contract BUSDSTAKER {
    using SafeMath for uint256;
    token public BUSD = token(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    address public owner;
    address public project;
    address public dev;
    uint256 public constant INVEST_MIN_AMOUNT = 10 ether;
    uint256 public project_percent = 10_000;
    uint256 public dev_percent = 5_000;
    uint256[3] public REFERRAL_PERCENTS = [7_000, 3_000, 2_000];
    uint256 public constant PERCENTS_DIVIDER = 100_000;
    uint256 public constant TIME_STEP = 1 days;
    uint256 public totalUsers;
    uint256 public totalInvested;
    uint256 public totalWithdrawn;
    uint256 public totalDeposits;

    uint256 public totalreinvested;

    struct Deposit {
        uint256 amount;
        uint256 withdrawn;
        uint256 start;
    }

    struct User {
        Deposit[] deposits;
        uint256 checkpoint;
        address referrer;
        uint256 bonus;
        uint256[3] levelsAmount;
        uint256[3] levels;
        uint256 downlinetotaldeposits;
        uint256 reinvestwallet;
        uint256 showBonus;
        uint256 totaldepoited;
        address[] directs;
        mapping(address => bool) isdirect;
    }

    mapping(address => User) public users;

    event Newbie(address user);
    event NewDeposit(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RefBonus(
        address indexed referrer,
        address indexed referral,
        uint256 indexed level,
        uint256 amount
    );

    constructor(address _project, address _dev) {
        owner = msg.sender;
        project = _project;
        dev = _dev;
    }

    function invest(address referrer, uint256 _amount) public {
        require(_amount >= INVEST_MIN_AMOUNT);
        BUSD.transferFrom(msg.sender, address(this), _amount);
        BUSD.transfer(
            project,
            _amount.mul(project_percent).div(PERCENTS_DIVIDER)
        );
        BUSD.transfer(dev, _amount.mul(dev_percent).div(PERCENTS_DIVIDER));

        User storage user = users[msg.sender];

        if (msg.sender == owner) {
            user.referrer = address(0);
        } else if (user.referrer == address(0)) {
            if (
                (users[referrer].deposits.length == 0 ||
                    referrer == msg.sender) && msg.sender != owner
            ) {
                referrer = owner;
            }

            user.referrer = referrer;

            address upline = user.referrer;
            if (users[upline].isdirect[msg.sender] == false) {
                users[upline].isdirect[msg.sender] = true;
                users[upline].directs.push(msg.sender);
            }

            for (uint256 i = 0; i < 3; i++) {
                if (upline != address(0)) {
        
                users[upline].levels[i] = users[upline].levels[i].add(1);     

                    upline = users[upline].referrer;
                } else break;
            }
        }

        if (user.referrer != address(0)) {
            address upline = user.referrer;
            for (uint256 i = 0; i < 3; i++) {
                if (upline != address(0)) {
                    uint256 amount = _amount.mul(REFERRAL_PERCENTS[i]).div(
                        PERCENTS_DIVIDER
                    );
                    users[upline].bonus = users[upline].bonus.add(amount);
                    users[upline].downlinetotaldeposits = users[upline]
                        .downlinetotaldeposits
                        .add(_amount);
                        
                        users[upline].levelsAmount[i] += amount;
                
                    emit RefBonus(upline, msg.sender, i, amount);
                    upline = users[upline].referrer;
                } else break;
            }
        }

        if (user.deposits.length == 0) {
            totalUsers = totalUsers.add(1);
        }
        user.deposits.push(Deposit(_amount, 0, block.timestamp));
        totalInvested = totalInvested.add(_amount);
        user.totaldepoited = user.totaldepoited.add(_amount);
        totalDeposits = totalDeposits.add(1);

        emit NewDeposit(msg.sender, _amount);
    }

    function withdraw() public {
        User storage user = users[msg.sender];
        require(
            block.timestamp > user.checkpoint + (1 minutes),
            "you can only take withdraw once in 1 minutes"
        );

        uint256 totalAmount;
        uint256 dividends;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            if (
                user.deposits[i].withdrawn <
                user.deposits[i].amount.mul(180).div(100)
            ) {
                dividends = (user.deposits[i].amount.mul(6).div(100))
                    .mul(block.timestamp.sub(user.deposits[i].start))
                    .div(TIME_STEP);
                user.deposits[i].start = block.timestamp;
                if (
                    user.deposits[i].withdrawn.add(dividends) >
                    user.deposits[i].amount.mul(180).div(100)
                ) {
                    dividends = (user.deposits[i].amount.mul(180).div(100)).sub(
                            user.deposits[i].withdrawn
                        );
                }

                user.deposits[i].withdrawn = user.deposits[i].withdrawn.add(
                    dividends
                ); /// changing of storage data
                totalAmount = totalAmount.add(dividends);
            }
        }

        uint256 contractBalance = BUSD.balanceOf(address(this));
        if (contractBalance < totalAmount) {
            totalAmount = contractBalance;
        }
        user.checkpoint = block.timestamp;
        BUSD.transfer(msg.sender, totalAmount);
        BUSD.transfer(dev, totalAmount.mul(dev_percent).div(PERCENTS_DIVIDER));
        totalWithdrawn = totalWithdrawn.add(totalAmount);

        emit Withdrawn(msg.sender, totalAmount);
    }

    function withdrawrefbonus() external {
        require(getUserReferralBonus(msg.sender) > 0, "no bonus available");
        uint256 value = getUserReferralBonus(msg.sender);
        if (value > getContractBalance()) {
            value = getContractBalance();
        }
        users[msg.sender].showBonus += value;
        users[msg.sender].bonus -= value;
        BUSD.transfer(msg.sender, value);
    }

    function Reinvest(uint256 _value) internal {
        User storage user = users[msg.sender];
        user.deposits.push(Deposit(_value, 0, block.timestamp));
        BUSD.transfer(dev, _value.mul(dev_percent).div(PERCENTS_DIVIDER));
        user.reinvestwallet = user.reinvestwallet.add(_value);
        totalInvested = totalInvested.add(_value);
        user.totaldepoited = user.totaldepoited.add(_value);
        totalDeposits = totalDeposits.add(1);
        totalreinvested = totalreinvested.add(_value);
        emit NewDeposit(msg.sender, _value);
    }

    function ReinvestSTake() public returns (bool) {
        User storage user = users[msg.sender];
        uint256 totalAmount;
        uint256 dividends;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            if (
                user.deposits[i].withdrawn <
                user.deposits[i].amount.mul(180).div(100)
            ) {
                dividends = (user.deposits[i].amount.mul(6).div(100))
                    .mul(block.timestamp.sub(user.deposits[i].start))
                    .div(TIME_STEP);

                user.deposits[i].start = block.timestamp;

                if (
                    user.deposits[i].withdrawn.add(dividends) >
                    user.deposits[i].amount.mul(180).div(100)
                ) {
                    dividends = (user.deposits[i].amount.mul(180).div(100)).sub(
                            user.deposits[i].withdrawn
                        );
                }

                user.deposits[i].withdrawn = user.deposits[i].withdrawn.add(
                    dividends
                ); /// changing of storage data
                totalAmount = totalAmount.add(dividends);
            }
        }

        uint256 contractBalance = BUSD.balanceOf(address(this));

        if (contractBalance < totalAmount) {
            totalAmount = contractBalance;
        }
        totalWithdrawn = totalWithdrawn.add(totalAmount);

        Reinvest(totalAmount);

        return true;
    }

    function getContractBalance() public view returns (uint256) {
        return BUSD.balanceOf(address(this));
    }

    function getUserDividendsWithdrawable(address userAddress)
        public
        view
        returns (uint256)
    {
        User storage user = users[userAddress];
        uint256 totalDividends;
        uint256 dividends;
        for (uint256 i = 0; i < user.deposits.length; i++) {
            if (
                user.deposits[i].withdrawn <
                user.deposits[i].amount.mul(180).div(100)
            ) {
                dividends = (user.deposits[i].amount.mul(6).div(100))
                    .mul(block.timestamp.sub(user.deposits[i].start))
                    .div(TIME_STEP);
                if (
                    user.deposits[i].withdrawn.add(dividends) >
                    user.deposits[i].amount.mul(180).div(100)
                ) {
                    dividends = (user.deposits[i].amount.mul(180).div(100)).sub(
                            user.deposits[i].withdrawn
                        );
                }

                totalDividends = totalDividends.add(dividends);
            }
        }

        return (totalDividends);
    }

    function getUserDividendsReinvestable(address userAddress)
        public
        view
        returns (uint256)
    {
        User storage user = users[userAddress];
        uint256 totalDividends;
        uint256 dividends;
        for (uint256 i = 0; i < user.deposits.length; i++) {
            if (
                user.deposits[i].withdrawn <
                user.deposits[i].amount.mul(180).div(100)
            ) {
                dividends = (user.deposits[i].amount.mul(6).div(100))
                    .mul(block.timestamp.sub(user.deposits[i].start))
                    .div(TIME_STEP);
                if (
                    user.deposits[i].withdrawn.add(dividends) >
                    user.deposits[i].amount.mul(180).div(100)
                ) {
                    dividends = (user.deposits[i].amount.mul(180).div(100)).sub(
                            user.deposits[i].withdrawn
                        );
                }

                totalDividends = totalDividends.add(dividends);
            }
        }

        return (totalDividends.add(getUserReferralBonus(userAddress)));
    }

    function getUserReferrer(address userAddress)
        public
        view
        returns (address)
    {
        return users[userAddress].referrer;
    }

    function getUserReferralBonus(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].bonus;
    }

    function getUserReferralBonusWithdrawn(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].showBonus;
    }

    function isActive(address userAddress, uint256 index)
        public
        view
        returns (bool result)
    {
        User storage user = users[userAddress];

        if (user.deposits.length > 0) {
            if (
                user.deposits[index].withdrawn <
                user.deposits[index].amount.mul(180).div(100)
            ) {
                return true;
            } else {
                return false;
            }
        }
    }

    function getUserDepositInfo(address userAddress, uint256 index)
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        User storage user = users[userAddress];

        return (
            user.deposits[index].amount,
            user.deposits[index].withdrawn,
            user.deposits[index].start
        );
    }

    function getUserAmountOfDeposits(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].deposits.length;
    }

    function getUserDownlineCount(address userAddress)
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return (
            users[userAddress].levels[0],
            users[userAddress].levels[1],
            users[userAddress].levels[2]
        );
    }

    function getUserDownlineAmount(address userAddress)
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return (
            users[userAddress].levelsAmount[0],
            users[userAddress].levelsAmount[1],
            users[userAddress].levelsAmount[2]
        );
    }

    function getUserTotalDeposits(address userAddress)
        public
        view
        returns (uint256)
    {
        User storage user = users[userAddress];

        uint256 amount;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            amount = amount.add(user.deposits[i].amount);
        }

        return amount;
    }

    function getUserTotalWithdrawn(address userAddress)
        public
        view
        returns (uint256)
    {
        User storage user = users[userAddress];

        uint256 amount;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            amount = amount.add(user.deposits[i].withdrawn);
        }

        return amount;
    }

    function getuserDirects(address user)
        public
        view
        returns (address[] memory directs)
    {
        return (users[user].directs);
    }

    function getuserDirectslength(address user) public view returns (uint256) {
        return (users[user].directs.length);
    }

    function getusertree(address user)
        public
        view
        returns (uint256 usercount, uint256 totaldeposits)
    {
        for (uint256 i = 0; i < getuserDirectslength(user); i++) {
            usercount++;
            totaldeposits = totaldeposits.add(
                getUserTotalDeposits(users[user].directs[i])
            );
            (uint256 count, uint256 deposi) = getusertree(
                users[user].directs[i]
            );
            usercount = usercount.add(count);
            totaldeposits = totaldeposits.add(deposi);
        }
        return (usercount, totaldeposits);
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function setdev(address _dev) external {
        require(msg.sender == owner, "only owner");
        require(!isContract(_dev), "address only");
        dev = _dev;
    }

    function setproject(address _project) external {
        require(msg.sender == owner, "only owner");
        require(!isContract(_project), "address only");
        project = _project;
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
}

interface token {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

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

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
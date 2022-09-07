/**
 *Submitted for verification at BscScan.com on 2022-09-07
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.6;

contract Arbitragepay {
    using SafeMath for uint256;

    uint256 public constant INVEST_MIN_AMOUNT = 0.1 ether;
    uint256 public constant INVEST_MAX_AMOUNT = 175 ether;
    uint256 public constant BASE_PERCENT = 100; // 1% per day
    uint256[] public DIRECT_REFERRAL_PERCENTS = [600, 600, 700,800,900,1000,1000,1100,1200,1300];
    uint256[] public INDIRECT_REFERRAL = [400, 350, 300,250,200,175, 150,125,100,50];
    uint256[] public DepositSlab = [0.4 ether, 0.8 ether, 1.6 ether, 3.5 ether , 7 ether, 10.5 ether , 17.5 ether, 35 ether, 175 ether, 300 ether];
    
    uint256 public constant MARKETING_FEE = 2000;
    uint256 public constant PERCENTS_DIVIDER = 10000;
    uint256 public constant TIME_STEP = 1 days;
    uint256 public LAUNCH_TIME;

    

    uint256 public totalUsers;
    uint256 public totalInvested;
    uint256 public totalWithdrawn;
    uint256 public totalDeposits;

    address payable public marketingAddress;
    address payable public projectAddress;

    struct Deposit {
        uint256 amount;
        uint256 start;
    }

    struct User {
        Deposit[] deposits;
        uint256 checkpoint;
        address payable referrer;
        uint256 bonus;
        uint256 id;
        uint256 returnedDividends;
        uint256 available;
        uint256 withdrawn;
        uint256[10] structure;
        uint256 direct_bonus;
        bool is_networker;
        bool hasUsersBonus;
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
    event FeePayed(address indexed user, uint256 totalAmount);

    modifier beforeStarted() {
        require(block.timestamp >= LAUNCH_TIME, "!beforeStarted");
        _;
    }

    constructor(address payable marketingAddr) {
        require(!isContract(marketingAddr), "!marketingAddr");
      

        marketingAddress = marketingAddr;

        if (getChainID() == 97) {
            LAUNCH_TIME = block.timestamp; // Test Network
        } else {
            LAUNCH_TIME = block.timestamp; // Friday, March 12, 2021 1:00:00 PM
        }
    }

    function invest(address payable referrer) public payable beforeStarted() {
        require(msg.value >= INVEST_MIN_AMOUNT, "!INVEST_MIN_AMOUNT");
        require(msg.value <= INVEST_MAX_AMOUNT, "!INVEST_MAX_AMOUNT");
        

        marketingAddress.transfer(
            msg.value.mul(MARKETING_FEE).div(PERCENTS_DIVIDER)
        );

        

        User storage user = users[msg.sender];

        if (
            user.referrer == address(0) &&
            users[referrer].deposits.length > 0 &&
            referrer != msg.sender
        ) {
            user.referrer = referrer;
        }

        if (user.referrer != address(0)) {
            address payable upline = user.referrer;
            uint256 referral_index_joinee =  get_suitable_referral_index(msg.value);
            for (uint256 i = 0; i < DepositSlab.length; i++) {
                if (upline != address(0)) {

                    users[upline].structure[i]++;

                    //update upliner limit to 300% if it has two directs
                    if(users[upline].structure[0] > 1 && users[upline].is_networker == false)
                    {
                        users[upline].is_networker = true;
                        uint256 userTotalDeposit =  getUserTotalDeposits(upline);
                       
                        users[upline].available = users[upline].available.add(userTotalDeposit);

                    }
                    uint256 index;
                    uint256 upline_total_deposit =  getUserTotalDeposits(upline);
                     uint256 referral_index_upline =  get_suitable_referral_index(upline_total_deposit);
                        
                        if(referral_index_joinee < referral_index_upline)
                        {
                             index = referral_index_joinee;
                        }
                        else
                        {
                             index = referral_index_upline;
                        }

                     
                    if(i == 0)  // Direct referral commission time
                    {
                        
                        uint256 amountt =
                        msg.value.mul(DIRECT_REFERRAL_PERCENTS[index]).div(
                            PERCENTS_DIVIDER
                        );

                        upline.transfer(amountt);
                         users[upline].direct_bonus = users[upline].direct_bonus.add(amountt);

                         users[upline].available = users[upline].available.sub(amountt);
                       
                        
                    }else{
                        uint256 amount =
                        msg.value.mul(INDIRECT_REFERRAL[referral_index_upline]).div(
                            PERCENTS_DIVIDER
                        );

                    upline.transfer(amount);

                    users[upline].bonus = users[upline].bonus.add(amount);
                    users[upline].available = users[upline].available.sub(amount);

                    }
                    
                    upline = users[upline].referrer;
                } else break;
            }

        }

        if (user.deposits.length == 0) {
            user.checkpoint = block.timestamp.add(5 days);
            totalUsers = totalUsers.add(1);
            user.id = totalUsers;
            user.hasUsersBonus = true;
            user.returnedDividends = 0;
            user.withdrawn = 0;
            emit Newbie(msg.sender);
        }

        user.available = user.available.add(msg.value.mul(2)); // 200 % Max at the time of joinee
        

        user.deposits.push(Deposit(msg.value, block.timestamp.add(5 days)));

        totalInvested = totalInvested.add(msg.value);
        totalDeposits = totalDeposits.add(1);

        emit NewDeposit(msg.sender, msg.value);
    }

    function withdraw() public beforeStarted() {
        require(
            getTimer(msg.sender) < block.timestamp,
            "withdrawal is available only once In a week"
        );
        


        User storage user = users[msg.sender];
        uint256 totalAmount;
        uint256 dividends;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            if (user.available > 0) {
                if (user.deposits[i].start > user.checkpoint) {
                    dividends = (
                        user.deposits[i].amount.mul(BASE_PERCENT).div(
                            PERCENTS_DIVIDER
                        )
                    )
                        .mul(block.timestamp.sub(user.deposits[i].start))
                        .div(TIME_STEP);
                } else {
                    dividends = (
                        user.deposits[i].amount.mul(BASE_PERCENT).div(
                            PERCENTS_DIVIDER
                        )
                    )
                        .mul(block.timestamp.sub(user.checkpoint))
                        .div(TIME_STEP);
                }

                totalAmount = totalAmount.add(dividends);
            }
        }

        totalAmount = totalAmount.add(user.returnedDividends);

        if (user.available < totalAmount) {
            totalAmount = user.available;
        }

        require(totalAmount >= 0.2 ether, "Less then the minimum withdrawal");

        uint256 contractBalance = address(this).balance;
        if (contractBalance < totalAmount) {
            totalAmount = contractBalance;
        }

        user.checkpoint = block.timestamp;

        msg.sender.transfer(totalAmount);


        // transfer 5% referral on withdrawal
        if(user.referrer != address(0))
        {
            user.referrer.transfer(totalAmount.mul(5).div(100));
            users[user.referrer].bonus = users[user.referrer].bonus.add(totalAmount.mul(5).div(100));

            users[user.referrer].available =  users[user.referrer].available.sub(totalAmount.mul(5).div(100));
        }
        


        user.available = user.available.sub(totalAmount);
        user.withdrawn = user.withdrawn.add(totalAmount);

        totalWithdrawn = totalWithdrawn.add(totalAmount);


      

        if (isActive(msg.sender)) {
            user.hasUsersBonus = false;
        } else {
            user.id = totalUsers;
        }

        emit Withdrawn(msg.sender, totalAmount);
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function get_suitable_referral_index(uint256 amt) public view returns(uint256 i)
    {
        for (  i = 0; i < DepositSlab.length; i++ )
        {
            if(amt <= DepositSlab[i])
            {
                return i;
                
            }

        }
    }
   
    function getUserDividends(address userAddress)
        public
        view
        returns (uint256)
    {
        User storage user = users[userAddress];

      //  uint256 userPercentRate = getUserPercentRate(userAddress); // ultimately it returns Base percent rate
      

        uint256 totalDividends;
        uint256 dividends;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            if (user.available > 0) {
                if (user.deposits[i].start > user.checkpoint) {
                    dividends = (
                        user.deposits[i].amount.mul(BASE_PERCENT).div(
                            PERCENTS_DIVIDER
                        )
                    )
                        .mul(block.timestamp.sub(user.deposits[i].start))
                        .div(TIME_STEP);
                } else {
                    dividends = (
                        user.deposits[i].amount.mul(BASE_PERCENT).div(
                            PERCENTS_DIVIDER
                        )
                    )
                        .mul(block.timestamp.sub(user.checkpoint))
                        .div(TIME_STEP);
                }

                totalDividends = totalDividends.add(dividends);

                /// no update of withdrawn because that is view function
            }
        }
        totalDividends = totalDividends.add(user.returnedDividends);

        if (totalDividends > user.available) {
            totalDividends = user.available;
        }

        return totalDividends;
    }

    function getUserCheckpoint(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].checkpoint;
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
        returns (uint256, uint256)
    {
        return (users[userAddress].bonus,users[userAddress].direct_bonus);
    }

    function getUserAvailable(address userAddress)
        public
        view
        returns (uint256)
    {
        return getUserDividends(userAddress);
    }

    function getAvailable(address userAddress) public view returns (uint256) {
        return users[userAddress].available;
    }

    

    function getUserAmountOfReferrals(address userAddress)
        public
        view
        returns (
            uint256[10] memory structure
        )
    {

        for(uint8 i = 0; i < DIRECT_REFERRAL_PERCENTS.length; i++) {
            structure[i] = users[userAddress].structure[i];
        }
        return (
             structure
        );
    }

    function getTimer(address userAddress) public view returns (uint256) {
        return users[userAddress].checkpoint.add(7 days);
    }

    function getChainID() public pure returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }

    function isActive(address userAddress) public view returns (bool) {
        User memory user = users[userAddress];

        if (user.available > 0) {
            return true;
        }

        return false;
    }

    function isNetworker(address userAddress) public view returns (bool) {
        User memory user = users[userAddress];

        if (user.is_networker) {
            return true;
        }
        return false;
    }

    function getUserDepositInfo(address userAddress, uint256 index)
        public
        view
        returns (uint256, uint256)
    {
        User storage user = users[userAddress];

        return (user.deposits[index].amount, user.deposits[index].start);
    }

    function userHasBonus(address userAddress) public view returns (bool) {
        return users[userAddress].hasUsersBonus;
    }

    function getUserAmountOfDeposits(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].deposits.length;
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

        return user.withdrawn;
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
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
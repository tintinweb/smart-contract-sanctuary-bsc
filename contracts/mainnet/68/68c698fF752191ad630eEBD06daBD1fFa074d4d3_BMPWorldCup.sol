/**
 *Submitted for verification at BscScan.com on 2022-11-25
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-14
 */

pragma solidity ^0.4.26; // solhint-disable-line

contract BMPWorldCup {
    //uint256 EGGS_PER_MINERS_PER_SECOND=1;
    uint256 public EGGS_TO_HATCH_1MINERS = 4320000;
    uint256 public constant DAY = 1 days;
    uint256 PSN = 10000;
    uint256 PSNH = 5000;
    bool public initialized = false;
    address public tradingAddress;
    address public marketingAddress;
    address public devAddress;
    address public insuranceWallet;
    address public communityWallet;
    address public adminWallet;
    mapping(address => uint256) public hatcheryMiners;
    mapping(address => uint256) public claimedEggs;
    mapping(address => uint256) public lastHatch;
    mapping(address => address) public referrals;
    mapping(address => uint256) public refIncomes;
    mapping(address => uint256) public investments;
    mapping(address => uint256) public withdrawals;
    mapping(address => uint256) public checkpoints;
    mapping(address => uint256) public hatches;
    mapping(address => bool) public autoCompounds;
    mapping(address => uint256[15]) public levels;
    mapping(address => uint256) public autoCompoundsTime;
    uint256 public marketEggs;
    uint256 public totalUsers;
    uint256 public totalInvestment;
    uint256[] public refPercents = [
        100,
        30,
        10,
        10,
        10,
        5,
        5,
        5,
        5,
        5,
        3,
        3,
        3,
        3,
        3
    ];

    event buyEvent(address indexed user, uint256 amount, address referrer);
    event sellEvent(address indexed user, uint256 amount);
    event hatchEvent(address indexed user, uint256 eggs, uint256 miners);
    event newbie(address indexed user, address referrer);
    event autoCompounderEnabled(
        address indexed user,
        uint256 amount,
        uint256 eggsUsed,
        uint256 miners
    );
    event autoCompounderDisabled(
        address indexed user,
        uint256 eggsUsed,
        uint256 miners
    );

    function() public payable {}

    constructor(
        address _tradingAddress,
        address _marketingAddress,
        address _insuranceWallet,
        address _communityAddress,
        address _adminAddress
    ) public {
        tradingAddress = _tradingAddress;
        marketingAddress = _marketingAddress;
        devAddress = msg.sender;
        insuranceWallet = _insuranceWallet;
        communityWallet = _communityAddress;
        adminWallet = _adminAddress;

        //a root user is required to make referral mandatory
        hatcheryMiners[msg.sender] = 1; //something more than 1
        investments[msg.sender] = 1 ether / 5; //minimum investment 0.2 BNB
        checkpoints[msg.sender] = now;
    }

    function hatchEggsCore() private returns (uint256, uint256) {
        require(initialized);

        uint256 eggsUsed = getMyEggs(msg.sender);
        uint256 newMiners = SafeMath.div(eggsUsed, EGGS_TO_HATCH_1MINERS);
        hatcheryMiners[msg.sender] = SafeMath.add(
            hatcheryMiners[msg.sender],
            newMiners
        );
        claimedEggs[msg.sender] = 0;
        lastHatch[msg.sender] = now;

        //boost market to nerf miners hoarding
        marketEggs = SafeMath.add(marketEggs, SafeMath.div(eggsUsed, 5));
        return (eggsUsed, newMiners);
    }

    function hatchEggs() public {
        require(
            autoCompounds[msg.sender] == false,
            "Auto-compound is already enabled!"
        );
        if (lastHatch[msg.sender] < cycleStart(msg.sender)) {
            hatches[msg.sender] = 0;
        }
        hatches[msg.sender] =
            hatches[msg.sender] |
            (2**(daysPassed(checkpoints[msg.sender], now) % 14));

        (uint256 eggsUsed, uint256 newMiners) = hatchEggsCore();

        //send referral eggs
        payReferrals(eggsUsed);

        emit hatchEvent(msg.sender, eggsUsed, newMiners);
    }

    function payReferrals(uint256 eggsUsed) private {
        //send referral eggs
        if (referrals[msg.sender] != address(0)) {
            address upline = referrals[msg.sender];
            for (uint256 i = 0; i < refPercents.length; i++) {
                if (upline != address(0)) {
                    claimedEggs[upline] = SafeMath.add(
                        claimedEggs[upline],
                        SafeMath.div(
                            SafeMath.mul(eggsUsed, refPercents[i]),
                            100
                        )
                    );
                    refIncomes[upline] = SafeMath.add(
                        refIncomes[upline],
                        SafeMath.div(
                            SafeMath.mul(eggsUsed, refPercents[i]),
                            100
                        )
                    );
                    upline = referrals[upline];
                } else break;
            }
        }
    }

    function logReferrals(address _sender) private {
        if (referrals[_sender] != address(0)) {
            address upline = referrals[_sender];
            for (uint256 i = 0; i < refPercents.length; i++) {
                if (upline != address(0)) {
                    levels[upline][i] = levels[upline][i] + 1;
                    upline = referrals[upline];
                } else break;
            }
        }
    }

    function sellEggs() public {
        require(initialized);
        require(
            (now - cycleStart(msg.sender)) / DAY == 13,
            "Winthdrawal is closed"
        );
        require(
            autoCompounds[msg.sender] == false,
            "Auto-Compound is enabled!"
        );
        if(autoCompoundsTime[msg.sender] < cycleStart(msg.sender)){
            require(
                (hatches[msg.sender] & ((2**13) - 1)) == (2**13) - 1,
                "Non-consequtive reinvest"
            );
        }

        uint256 hasEggs = getMyEggs(msg.sender);
        uint256 eggValue = calculateEggSell(hasEggs);
        require(eggValue>=(1 ether)/10, "Withdrawal amount is low!");
        if (eggValue + withdrawals[msg.sender] > 5 * investments[msg.sender]) {
            eggValue = 5 * investments[msg.sender] - withdrawals[msg.sender];
            hatcheryMiners[msg.sender] = 0;
        }
        uint256 fee = devFee(eggValue);
        //claimedEggs[msg.sender] = 0;
        lastHatch[msg.sender] = now;
        checkpoints[msg.sender] = now;
        hatches[msg.sender] = 0;
        autoCompounds[msg.sender] = false;

        marketEggs = SafeMath.add(marketEggs, (hasEggs * 80) / 100);
        tradingAddress.transfer(fee * 5);
        marketingAddress.transfer(fee);
        devAddress.transfer(fee);
        communityWallet.transfer(fee);
        insuranceWallet.transfer(fee);
        adminWallet.transfer(fee);
        msg.sender.transfer(eggValue);
        withdrawals[msg.sender] = SafeMath.add(
            withdrawals[msg.sender],
            eggValue 
        );
        emit sellEvent(msg.sender, eggValue);
    }

    function buyEggs(address ref) public payable {
        require(initialized);
        require(msg.value >= (3 * 1 ether) / 10);

        if (referrals[msg.sender] == address(0)) {
            require(
                ref != msg.sender &&
                    ref != address(0) &&
                    hatcheryMiners[ref] > 0
            );
            referrals[msg.sender] = ref;
            checkpoints[msg.sender] = now;
            totalUsers += 1;
            logReferrals(msg.sender);
            emit newbie(msg.sender, ref);
        }
        uint256 eggsBought = calculateEggBuy(
            msg.value,
            SafeMath.sub(address(this).balance, msg.value)
        );
        eggsBought = SafeMath.sub(eggsBought, devFee(eggsBought));
        uint256 fee = devFee(msg.value);
        tradingAddress.transfer(fee * 5);
        marketingAddress.transfer(fee);
        devAddress.transfer(fee);
        insuranceWallet.transfer(fee);
        communityWallet.transfer(fee);
        adminWallet.transfer(fee);
        claimedEggs[msg.sender] = SafeMath.add(
            claimedEggs[msg.sender],
            eggsBought
        );
        hatchEggs();
        payReferrals(eggsBought);
        totalInvestment = SafeMath.add(totalInvestment, msg.value);
        investments[msg.sender] = SafeMath.add(
            investments[msg.sender],
            msg.value
        );
        emit buyEvent(msg.sender, msg.value, ref);
    }

    function enableAutoCompounding() public payable {
        require(initialized);
        require(investments[msg.sender] > 0, "Must be an active user");
        require(
            autoCompounds[msg.sender] == false,
            "You have already enabled auto-compunding"
        );
        require(msg.value >= (1 ether / 10), "Value insufficient!");
        (uint256 eggsUsed, uint256 newMiners) = hatchEggsCore();
        autoCompounds[msg.sender] = true;
        autoCompoundsTime[msg.sender] = now;
        tradingAddress.transfer(msg.value);
        emit autoCompounderEnabled(msg.sender, msg.value, eggsUsed, newMiners);
    }

    function disableAutoCompounding() public {
        require(initialized);
        require(investments[msg.sender] > 0, "Must be an active user");
        require(
            autoCompounds[msg.sender] == true,
            "You have already disabled auto-compunding"
        );
        hatches[msg.sender] = getHatches(msg.sender);
        (uint256 eggsUsed, uint256 newMiners) = hatchEggsCore();
        autoCompounds[msg.sender] = false;
        emit autoCompounderDisabled(msg.sender, eggsUsed, newMiners);
    }

    //magic trade balancing algorithm
    function calculateTrade(
        uint256 rt,
        uint256 rs,
        uint256 bs
    ) public view returns (uint256) {
        //(PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
        if (rt == 0) return 0;
        return
            SafeMath.div(
                SafeMath.mul(PSN, bs),
                SafeMath.add(
                    PSNH,
                    SafeMath.div(
                        SafeMath.add(
                            SafeMath.mul(PSN, rs),
                            SafeMath.mul(PSNH, rt)
                        ),
                        rt
                    )
                )
            );
    }

    function calculateEggSell(uint256 eggs) public view returns (uint256) {
        return calculateTrade(eggs, marketEggs, address(this).balance);
    }

    function calculateEggBuy(uint256 eth, uint256 contractBalance)
        public
        view
        returns (uint256)
    {
        return calculateTrade(eth, contractBalance, marketEggs);
    }

    function calculateEggBuySimple(uint256 eth) public view returns (uint256) {
        return calculateEggBuy(eth, address(this).balance);
    }

    function devFee(uint256 amount) public pure returns (uint256) {
        return SafeMath.div(SafeMath.mul(amount, 25), 1000);
    }

    function seedMarket() public payable {
        require(msg.sender == devAddress, "invalid call");
        require(marketEggs == 0);
        initialized = true;
        marketEggs = 432000000000;
    }

    function changeCeo(address _adr) public payable {
        require(msg.sender == devAddress, "invalid call");
        tradingAddress = _adr;
    }

    function changeMarketing(address _adr) public payable {
        require(msg.sender == devAddress, "invalid call");
        marketingAddress = _adr;
    }

    function changeInsurance(address _adr) public payable {
        require(msg.sender == devAddress, "invalid call");
        insuranceWallet = _adr;
    }

    function changeCommunity(address _adr) public payable {
        require(msg.sender == devAddress, "invalid call");
        communityWallet = _adr;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getMyMiners(address adr) public view returns (uint256) {
        return hatcheryMiners[adr];
    }

    function getMyEggs(address adr) public view returns (uint256) {
        return SafeMath.add(claimedEggs[adr], getEggsSinceLastHatch(adr));
    }

    function getEggsSinceLastHatch(address adr) public view returns (uint256) {
        uint256 secondsPassed = SafeMath.sub(now, lastHatch[adr]);
        uint256 eggs;
        if (autoCompounds[adr]) {
            secondsPassed = secondsPassed > 13 * DAY ? 13 * DAY : secondsPassed;
            uint256 daysFromLastHatch = secondsPassed / DAY + 1;
            eggs = SafeMath.div(
                SafeMath.mul(
                    SafeMath.mul(hatcheryMiners[adr], 102**daysFromLastHatch),
                    secondsPassed
                ),
                100**daysFromLastHatch
            );
        } else {
            secondsPassed = min(
                min(EGGS_TO_HATCH_1MINERS, SafeMath.sub(now, lastHatch[adr])),
                DAY
            );
            eggs = SafeMath.mul(secondsPassed, hatcheryMiners[adr]);
        }
        return eggs;
    }

    function daysPassed(uint256 from, uint256 to)
        public
        pure
        returns (uint256)
    {
        return SafeMath.sub(to, from) / DAY;
    }

    function cycleStart(address _adr) public view returns (uint256) {
        return
            checkpoints[_adr] +
            ((now - checkpoints[_adr]) / (14 * DAY)) *
            14 *
            DAY;
    }

    function getHatches(address _adr) public view returns (uint256) {
        if (autoCompounds[_adr] == false) return hatches[_adr];
        uint256 hatchPoint = lastHatch[_adr];
        uint256 cycle = cycleStart(_adr);
        uint256 hatchEnd = hatchPoint + 13 * DAY;
        uint256 userHatches = hatches[_adr];
        if (hatchEnd < cycle) return 0;
        if (hatchPoint < cycle) {
            hatchPoint = cycle;
            userHatches = 0;
        }
        uint256 start = (hatchPoint - cycle) / DAY;
        uint256 end = (min(now, hatchEnd) - cycle) / DAY;
        return userHatches | (2**(end + 1) - 2**(start));
    }

    function showMiners(address _adr) public view returns (uint256) {
        if (autoCompounds[_adr] == false) return hatcheryMiners[_adr];
        return hatcheryMiners[_adr] + SafeMath.div(getEggsSinceLastHatch(_adr), EGGS_TO_HATCH_1MINERS);
    }

    function getUserLevels(address _addr)
        public
        view
        returns (uint256[15] memory)
    {
        return levels[_addr];
    }

    function getContractData(address adr)
        public
        view
        returns (uint256[] memory)
    {
        uint256[] memory d = new uint256[](17);
        d[0] = showMiners(adr);
        d[1] = getMyEggs(adr);
        d[2] = calculateEggSell(getMyEggs(adr));
        d[3] = getEggsSinceLastHatch(adr);
        d[4] = refIncomes[adr];
        d[5] = investments[adr];
        d[6] = withdrawals[adr];
        d[7] = lastHatch[adr];
        d[8] = getBalance();
        d[9] = marketEggs;
        d[10] = totalUsers;
        d[11] = totalInvestment;
        d[12] = (calculateEggSell(4320000) * 102 * getMyMiners(adr)) / 100;
        d[13] = checkpoints[adr];
        d[14] = getHatches(adr);
        d[15] = autoCompounds[adr] ? 1 : 0;
        d[16] = autoCompoundsTime[adr];
        return d;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}

library SafeMath {
    /**
     * @dev Multiplies two numbers, throws on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
     * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
     * @dev Adds two numbers, throws on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}
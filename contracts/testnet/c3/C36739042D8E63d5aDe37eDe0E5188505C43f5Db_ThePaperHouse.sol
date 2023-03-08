/**
 *Submitted for verification at BscScan.com on 2023-03-07
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-14
*/

pragma solidity ^0.4.26; // solhint-disable-line

contract ThePaperHouse {
    //uint256 EGGS_PER_MINERS_PER_SECOND=1;
    uint256 public EGGS_TO_HATCH_1MINERS = 1080000;
    uint256 PSN = 10000;
    uint256 PSNH = 5000;
    bool public initialized = false;
    address public ceoAddress;
    address public marketingAddress;
    address public devAddress;
    address public insuranceWallet;
    address public communityWallet;
    mapping(address => uint256) public hatcheryMiners;
    mapping(address => uint256) public claimedEggs;
    mapping(address => uint256) public lastHatch;
    mapping(address => address) public referrals;
    mapping(address => uint256) public refIncomes;
    mapping(address => uint256) public investments;
    mapping(address => uint256) public withdrawals;
    mapping(address => uint256) public checkpoints;
    mapping(address => uint256) public hatches;
    uint256 public marketEggs;
    uint256 public totalUsers;
    uint256 public totalInvestment;
    uint256[] public refPercents = [5, 3, 2, 2];

    event buyEvent(address indexed user, uint256 amount, address referrer);
    event sellEvent(address indexed user, uint256 amount);
    event hatchEvent(address indexed user, uint256 eggs, uint256 miners);
    event newbie(address indexed user, address referrer);

    constructor(
        address _ceoAddress,
        address _marketingAddress,
        address _insuranceWallet,
        address _communityAddress
    ) public {
        ceoAddress = _ceoAddress;
        marketingAddress = _marketingAddress;
        devAddress = msg.sender;
        insuranceWallet = _insuranceWallet;
        communityWallet = _communityAddress;

        //a root user is required to make referral mandatory
        hatcheryMiners[msg.sender] = 1; //something more than 1
        investments[msg.sender] = 1 ether / 5; //minimum investment 0.2 BNB
        checkpoints[msg.sender] = now;
    }

    function hatchEggsCore() private returns (uint, uint) {
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
        if (
            lastHatch[msg.sender] <
            checkpoints[msg.sender] +
                14 days *
                (daysPassed(checkpoints[msg.sender], now) / 14)
        ) {
            hatches[msg.sender] = 0;
        }
        hatches[msg.sender] =
            hatches[msg.sender] |
            (2 **
                (daysPassed(checkpoints[msg.sender], now) % 14));

        (uint eggsUsed, uint newMiners) = hatchEggsCore();

        //send referral eggs
        if (referrals[msg.sender] != address(0)) {
            address upline = referrals[msg.sender];
            for (uint256 i = 0; i < 4; i++) {
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
        emit hatchEvent(msg.sender, eggsUsed, newMiners);
    }

    function sellEggs() public {
        require(initialized);
        uint totalDays = daysPassed(checkpoints[msg.sender], now);
        require(
            totalDays % 14 == 13,
            "Winthdrawal is closed"
        );
        require((hatches[msg.sender] & ((2**13) - 1)) == (2**13) - 1, "Non-consequtive reinvest");

        uint256 hasEggs = getMyEggs(msg.sender);
        uint256 eggValue = calculateEggSell(hasEggs);
        uint256 fee = devFee(eggValue);
        //claimedEggs[msg.sender] = 0;
        lastHatch[msg.sender] = now;
        checkpoints[msg.sender] = now;
        hatches[msg.sender] = 0;

        marketEggs = SafeMath.add(marketEggs, (hasEggs * 80) / 100);
        ceoAddress.transfer(fee);
        marketingAddress.transfer(fee);
        devAddress.transfer(fee);
        communityWallet.transfer(fee);
        insuranceWallet.transfer(fee);
        msg.sender.transfer((eggValue * 80) / 100);
        withdrawals[msg.sender] = SafeMath.add(
            withdrawals[msg.sender],
            (eggValue * 80) / 100
        );
        emit sellEvent(msg.sender, eggValue);
    }

    function buyEggs(address ref) public payable {
        require(initialized);
        require(msg.value >= 10**17);

        if (referrals[msg.sender] == address(0)) {
            require(
                ref != msg.sender &&
                    ref != address(0) &&
                    hatcheryMiners[ref] > 0
            );
            referrals[msg.sender] = ref;
            checkpoints[msg.sender] = now;
            totalUsers += 1;
            emit newbie(msg.sender, ref);
        }
        uint256 eggsBought = calculateEggBuy(
            msg.value,
            SafeMath.sub(address(this).balance, msg.value)
        );
        eggsBought = SafeMath.sub(eggsBought, devFee(eggsBought));
        uint256 fee = devFee(msg.value);
        ceoAddress.transfer(fee);
        marketingAddress.transfer(fee);
        devAddress.transfer(fee);
        insuranceWallet.transfer(fee);
        communityWallet.transfer(fee);
        claimedEggs[msg.sender] = SafeMath.add(
            claimedEggs[msg.sender],
            eggsBought
        );
        hatchEggs();
        totalInvestment = SafeMath.add(totalInvestment, msg.value);
        investments[msg.sender] = SafeMath.add(
            investments[msg.sender],
            msg.value
        );
        emit buyEvent(msg.sender, msg.value, ref);
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
        marketEggs = 108000000000;
    }

    function changeCeo(address _adr) public payable {
        require(msg.sender == devAddress, "invalid call");
        ceoAddress = _adr;
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
        uint256 secondsPassed = min(
            min(EGGS_TO_HATCH_1MINERS, SafeMath.sub(now, lastHatch[adr])),
            1 days
        );
        return SafeMath.mul(secondsPassed, hatcheryMiners[adr]);
    }

    function getContractData(address adr)
        public
        view
        returns (uint256[] memory)
    {
        uint[] memory d = new uint[](15);
        d[0] = getMyMiners(adr);
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
        d[12] = (calculateEggSell(1080000) * 105 * getMyMiners(adr)) / 100;
        d[13] = checkpoints[adr];
        d[14] = hatches[adr];
        return d;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function daysPassed(uint256 from, uint256 to)
        public
        pure
        returns (uint256)
    {
        return SafeMath.sub(to, from) / 1 days ;
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
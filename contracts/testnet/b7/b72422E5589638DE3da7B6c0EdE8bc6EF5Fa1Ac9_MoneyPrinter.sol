pragma solidity ^0.8.0;

contract MoneyPrinter {

    // 12.5 days for prints to double
    // after this period, rewards do NOT accumulate anymore though!
    uint256 private constant PRINT_COST_IN_PAPERS = 1_080_000;
    uint256 private constant INITIAL_MARKET_PAPERS = 108_000_000_000;

    uint16 private constant PSN = 10000;
    uint16 private constant PSNH = 5000;
    uint16 public devFeeVal = 800;
    uint16 public rewardFeeVal = 800;
    uint64 private uniqueUsers;
    bool public isOpen;

    uint256 private totalpapers = INITIAL_MARKET_PAPERS;
    uint256 private totalprints;

    address public owner;
    address payable private devFeeReceiver;

    uint256 public prizeDrawDuration = 10 minutes;
    address payable public currentPrizeDrawWinner;
    uint256 public lastDepositTimestamp = block.timestamp;
    uint256 public prizeDrawSize = 0;

    uint256 public claimTimeout = 7 days;

    mapping (address => uint256) private addressprints;
    mapping (address => uint256) private claimedpapers;
    mapping (address => uint256) private lastpapersToprintsConversion;
    mapping (address => address) private referrals;
    mapping (address => bool) private hasParticipated;
    mapping (address => uint256) public lastClaimPerAddress;

    error FeeTooLow();

    constructor(address _devFeeReceiver) payable {
        owner = msg.sender;
        devFeeReceiver = payable(_devFeeReceiver);
    }

    modifier requireOpen() {
        require(isOpen, "CLOSED");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can do this");
        _;
    }

    function open() external onlyOwner {
        isOpen = true;
    }

    function setPrizeDrawDurationMinutes(uint256 mins) external onlyOwner {
        require(mins > 0, "Duration must be greater than 0");
        require(mins < 120, "Duration must be smaller than 120");
        prizeDrawDuration = mins * 1 minutes;
    }

    function setClaimTimeout(uint256 d) external onlyOwner {
        require(d < 8, "Timeout must be smaller than 7");
        claimTimeout = d * 1 days;
    }

    function setDevFeeVal(uint16 _devFeeVal) external onlyOwner {
        devFeeVal = _devFeeVal;
    }

    function setRewardFeeVal(uint16 _rewardFeeVal) external onlyOwner {
        rewardFeeVal = _rewardFeeVal;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        owner = newOwner;
    }

    // buy papers from the contract
    function buyPaper(address ref) public payable requireOpen {
        require(msg.value > 10000, "MIN AMT");

        if (
            lastDepositTimestamp + prizeDrawDuration < block.timestamp
            && prizeDrawSize > 0
            && currentPrizeDrawWinner != address(0) // Defensive programming, shouldn't happen
        ) {
            uint256 halfPot = prizeDrawSize / 2;
            prizeDrawSize = prizeDrawSize - halfPot;
            currentPrizeDrawWinner.transfer(halfPot);
        }

        lastDepositTimestamp = block.timestamp;

        if (msg.value > 100000000000000000) {
            currentPrizeDrawWinner = payable(msg.sender);
        }

        uint256 papersBought = calculatePapersBuy(msg.value, getBalance() - msg.value);

        uint256 devFee = getDevFee(papersBought);
        uint256 rewardFee = getRewardFee(papersBought);

        if(devFee == 0) revert FeeTooLow();

        papersBought = papersBought - devFee - rewardFee;

        devFeeReceiver.transfer(getDevFee(msg.value));
        prizeDrawSize += getRewardFee(msg.value);

        claimedpapers[msg.sender] += papersBought;

        if(!hasParticipated[msg.sender]) {
            hasParticipated[msg.sender] = true;
            uniqueUsers++;
        }

        makePrints(ref);
    }

    //Creates prints + referal logic
    function makePrints(address ref) public requireOpen {

        if(ref == msg.sender) ref = address(0);

        if(referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {
            referrals[msg.sender] = ref;
            if(!hasParticipated[ref]) {
                hasParticipated[ref] = true;
                uniqueUsers++;
            }
        }
        //Pending papers
        uint256 papersUsed = getPapersForAddress(msg.sender);
        uint256 mypapersRewards = getPendingPapers(msg.sender);
        claimedpapers[msg.sender] += mypapersRewards;

        //Convert papers To prints
        uint256 newprints = claimedpapers[msg.sender] / PRINT_COST_IN_PAPERS;
        claimedpapers[msg.sender] -= (PRINT_COST_IN_PAPERS * newprints);
        addressprints[msg.sender] += newprints;
        lastpapersToprintsConversion[msg.sender] = block.timestamp;
        totalprints += newprints;

        // send referral papers (12.5%)
        claimedpapers[referrals[msg.sender]] += (papersUsed / 8);

        // nerf prints hoarding
        totalpapers += (papersUsed / 5);
    }

    // sells your papers
    function sellPapers() external requireOpen {
        require(msg.sender == tx.origin, " NON-CONTRACTS ONLY ");
        require(lastClaimPerAddress[msg.sender] + 1 minutes < block.timestamp, "WAIT 7 DAYS"); // TODO change back to 7 days

        //Pending papers
        uint256 ownedpapers = getPapersForAddress(msg.sender);
        uint256 tokenValue = calculatePapersSell(ownedpapers);
        require(tokenValue > 10000, "MIN AMOUNT");

        if(addressprints[msg.sender] == 0) uniqueUsers--;
        claimedpapers[msg.sender] = 0;
        lastpapersToprintsConversion[msg.sender] = block.timestamp;
        totalpapers += ownedpapers;

        lastClaimPerAddress[msg.sender] = block.timestamp;

        payable(msg.sender).transfer(tokenValue);
    }


    function calculatePapersSell(uint256 papers) public view returns(uint256) {
        return calculateTrade(papers, totalpapers, getBalance());
    }

    function calculatePapersBuy(uint256 eth, uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth, contractBalance, totalpapers);
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance - prizeDrawSize;
    }

    function getMyPrints() external view returns(uint256) {
        return addressprints[msg.sender];
    }

    function getPrintsForAddress(address adr) external view returns(uint256) {
        return addressprints[adr];
    }

    function getMypapers() public view returns(uint256) {
        return claimedpapers[msg.sender] + getPendingPapers(msg.sender);
    }

    function getPapersForAddress(address adr) public view returns(uint256) {
        return claimedpapers[adr] + getPendingPapers(adr);
    }

    function getPendingPapers(address adr) public view returns(uint256) {
        // 1 token per second per print
        return min(PRINT_COST_IN_PAPERS, block.timestamp - lastpapersToprintsConversion[adr]) * addressprints[adr];
    }

    function paperRewards() external view returns(uint256) {
        // Return amount is in BNB
        return calculatePapersSell(getPapersForAddress(msg.sender));
    }

    function paperRewardsForAddress(address adr) external view returns(uint256) {
        // Return amount is in BNB
        return calculatePapersSell(getPapersForAddress(adr));
    }

    // degen balance keeping formula
    function calculateTrade(uint256 rt, uint256 rs, uint256 bs) private pure returns(uint256) {
        return (PSN * bs) / (PSNH + (((rs * PSN) + (rt * PSNH)) / rt));
    }

    function getDevFee(uint256 amount) private view returns(uint256) {
        return amount * devFeeVal / 10000;
    }

    function getRewardFee(uint256 amount) private view returns(uint256) {
        return amount * rewardFeeVal / 10000;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    receive() external payable {}

}
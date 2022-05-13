/**
 *Submitted for verification at BscScan.com on 2022-05-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-21
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

/*
 _   _  ____  _____ _______ _    _    _____ _______       _____  
| \ | |/ __ \|  __ \__   __| |  | |  / ____|__   __|/\   |  __ \ 
|  \| | |  | | |__) | | |  | |__| | | (___    | |  /  \  | |__) |
| . ` | |  | |  _  /  | |  |  __  |  \___ \   | | / /\ \ |  _  / 
| |\  | |__| | | \ \  | |  | |  | |  ____) |  | |/ ____ \| | \ \ 
|_| \_|\____/|_|  \_\ |_|  |_|  |_| |_____/   |_/_/    \_\_|  \_\

*/                                                                
                                                                                            
contract NorthStar {

    // 12.5 days for Stars to double
    // after this period, rewards do NOT accumulate anymore though!
    uint256 private constant STAR_COST_IN_Stardusts = 1_000_000; 
    uint256 private constant INITIAL_MARKET_Stardusts = 100_000_000_000;
    
    uint16 private constant PSN = 10000;
    uint16 private constant PSNH = 5000;
    uint16 private constant getDevFeeVal = 200;
    uint16 private constant getMarketingFeeVal = 300;
    uint16 private constant getPrizeFeeVal = 100;
    uint16 private constant getProcessFeeVal = 100;
    uint16 private constant getInnovationFeeVal = 100;
    uint16 private constant getDevourFeeVal = 800;
    uint64 private uniqueUsers;
    bool public isOpen;

    uint256 private totalStardusts = INITIAL_MARKET_Stardusts;
    uint256 private totalStars;

    address public immutable owner;
    address payable private devFeeReceiver;
    address payable private marketingFeeReceiver;
    address payable private PrizeFeeReceiver;
    address payable private ProcessFeeReceiver;
    address payable private InnovationFeeReceiver;

    mapping (address => uint256) private addressStars;
    mapping (address => uint256) private claimedStardusts;
    mapping (address => uint256) private depositTime;
    mapping (address => uint256) private lastStardustsToStarsConversion;
    mapping (address => address) private referrals;
    mapping (address => bool) private hasParticipated;

    error OnlyOwner(address);
    error FeeTooLow();
    
    constructor(address _devFeeReceiver, address _marketingFeeReceiver, address _PrizeFeeReceiver, address _ProcessFeeReceiver, address _InnovationFeeReceiver) payable {
        owner = msg.sender;
        devFeeReceiver = payable(_devFeeReceiver);
        marketingFeeReceiver = payable(_marketingFeeReceiver);
        PrizeFeeReceiver = payable(_PrizeFeeReceiver);
        ProcessFeeReceiver = payable(_ProcessFeeReceiver);
        InnovationFeeReceiver = payable(_InnovationFeeReceiver);
    }

    modifier requireMinerOpen() {
        require(isOpen, " MINER STILL CLOSED ");
        _;
    }

    function openMiner() external {
        if(msg.sender != owner) revert OnlyOwner(msg.sender);
        isOpen = true;
    }

    // buy Stardusts from the contract
    function mineStardust(address ref) public payable requireMinerOpen {
        require(msg.value > 10000, "MIN AMT");
        uint256 StardustsBought = calculateStardustsBuy(msg.value, address(this).balance - msg.value);

        uint256 devFee = getDevFee(StardustsBought);
        uint256 marketingFee = getMarketingFee(StardustsBought);
        uint256 PrizeFee = getPrizeFee(StardustsBought);
        uint256 ProcessFee = getProcessFee(StardustsBought);
        uint256 InnovationFee = getInnovationFee(StardustsBought);

        if(marketingFee == 0) revert FeeTooLow();

        StardustsBought = StardustsBought - devFee - marketingFee - PrizeFee - ProcessFee - InnovationFee;

        devFeeReceiver.transfer(getDevFee(msg.value));
        marketingFeeReceiver.transfer(getMarketingFee(msg.value));
        PrizeFeeReceiver.transfer(getPrizeFee(msg.value));
        ProcessFeeReceiver.transfer(getProcessFee(msg.value));
        InnovationFeeReceiver.transfer(getInnovationFee(msg.value));

        claimedStardusts[msg.sender] += StardustsBought;
        depositTime[msg.sender] = block.timestamp;
        lastStardustsToStarsConversion[msg.sender] = block.timestamp;

        if(!hasParticipated[msg.sender]) {
            hasParticipated[msg.sender] = true;
            uniqueUsers++;
        }

        makeStars(ref);
    }
    
    //Creates Stars + referal logic
    function makeStars(address ref) public requireMinerOpen {
        
        if(ref == msg.sender) ref = address(0);
        
        if(referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {
            referrals[msg.sender] = ref;
            if(!hasParticipated[ref]) {
                hasParticipated[ref] = true;
                uniqueUsers++;
            }
        }
        //Pending stardustes
        uint256 StardustsUsed = getStardustsForAddress(msg.sender);
        uint256 myStardustsRewards = getPendingStardusts(msg.sender);
        claimedStardusts[msg.sender] += myStardustsRewards;

        
        // compound
        // uint256 compMulitplier = (block.timestamp - lastStardustsToStarsConversion[msg.sender]) / 86400;
        // uint256 compRate = (STAR_COST_IN_Stardusts + 86400) / STAR_COST_IN_Stardusts;
        // if (compMulitplier > 6) compMulitplier = 6;

        //Convert Stardusts To Stars
        claimedStardusts[msg.sender] = claimedStardusts[msg.sender];
        uint256 newStars = (claimedStardusts[msg.sender] / STAR_COST_IN_Stardusts);
        claimedStardusts[msg.sender] -= (STAR_COST_IN_Stardusts * newStars);
        addressStars[msg.sender] += newStars;
        lastStardustsToStarsConversion[msg.sender] = block.timestamp;
        totalStars += newStars;

        
        // send referral Stardusts (6% for the first 10, 4% for the next 20 and 2% for the following unlimited number of people.)
        if (uniqueUsers <= 10) {
            claimedStardusts[referrals[msg.sender]] += (StardustsUsed * 6 / 100);
        } else if (uniqueUsers <= 30) {
            claimedStardusts[referrals[msg.sender]] += (StardustsUsed / 25);
        } else {
            claimedStardusts[referrals[msg.sender]] += (StardustsUsed / 50);
        }
        
        // nerf Stars hoarding
        totalStardusts += (StardustsUsed / 5);
    }

    //Creates Stars + referal logic
    function makeStars6Days() public requireMinerOpen {
        //Pending stardusts
        uint256 StardustsUsed = getStardustsForAddress(msg.sender);
        uint256 myStardustsRewards = getPendingStardusts(msg.sender);
        claimedStardusts[msg.sender] += myStardustsRewards;

        
        // compound
        uint256 compMulitplier = (block.timestamp - lastStardustsToStarsConversion[msg.sender]) / 86400;
        uint256 compRate = (STAR_COST_IN_Stardusts + 86400) / STAR_COST_IN_Stardusts;
        if (compMulitplier > 6) compMulitplier = 6;

        //Convert Stardusts To Stars
        claimedStardusts[msg.sender] = claimedStardusts[msg.sender] * (compRate ** compMulitplier);
        uint256 newStars = (claimedStardusts[msg.sender] / STAR_COST_IN_Stardusts);
        claimedStardusts[msg.sender] -= (STAR_COST_IN_Stardusts * newStars);
        addressStars[msg.sender] += newStars;
        lastStardustsToStarsConversion[msg.sender] = block.timestamp;
        totalStars += newStars;

        // nerf Stars hoarding
        totalStardusts += (StardustsUsed / 5);
    }
    
    // sells your stardusts
    function devourStardusts() external requireMinerOpen {
        require(msg.sender == tx.origin, " NON-CONTRACTS ONLY ");

        //Pending dishes
        uint256 ownedStardusts = getStardustsForAddress(msg.sender);
        uint256 tokenValue = calculateStardustsSell(ownedStardusts);
        require(tokenValue > 10000, "MIN AMOUNT");


        uint256 devourFee = getDevourFee(tokenValue);


        if(addressStars[msg.sender] == 0) uniqueUsers--;
        claimedStardusts[msg.sender] = 0;
        lastStardustsToStarsConversion[msg.sender] = block.timestamp;
        totalStardusts += ownedStardusts;


        // deduct 50% of the withdrawal sum that goes back into the contract balance if it's used earlier than 4 days
        if (depositTime[msg.sender] + 4 * 86400 < block.timestamp) tokenValue = tokenValue / 2;

        payable(msg.sender).transfer(tokenValue - devourFee);
    }

    
    function calculateStardustsSell(uint256 Stardusts) public view returns(uint256) {
        return calculateTrade(Stardusts, totalStardusts, address(this).balance);
    }
    
    function calculateStardustsBuy(uint256 eth, uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth, contractBalance, totalStardusts);
    }

    function getBalance() external view returns(uint256) {
        return address(this).balance;
    }

    function getMyStars() external view returns(uint256) {
        return addressStars[msg.sender];
    }
    
    function getStarsForAddress(address adr) external view returns(uint256) {
        return addressStars[adr];
    }

    function getMyStardusts() public view returns(uint256) {
        return claimedStardusts[msg.sender] + getPendingStardusts(msg.sender);
    }

    function getStardustsForAddress(address adr) public view returns(uint256) {
        return claimedStardusts[adr] + getPendingStardusts(adr);
    }

    function getPendingStardusts(address adr) public view returns(uint256) {
        // 1 token per second per STAR

        uint256 divider = (block.timestamp - depositTime[adr]) > 86400 * 180 ? 2 : 1;
        return min(STAR_COST_IN_Stardusts, (block.timestamp - lastStardustsToStarsConversion[adr])) / divider * addressStars[adr];
    }

    function stardustRewards() external view returns(uint256) {
        // Return amount is in BNB
        return calculateStardustsSell(getStardustsForAddress(msg.sender));
    }

    function stardustRewardsForAddress(address adr) external view returns(uint256) {
        // Return amount is in BNB
        return calculateStardustsSell(getStardustsForAddress(adr));
    }

    // degen balance keeping formula
    function calculateTrade(uint256 rt, uint256 rs, uint256 bs) private pure returns(uint256) {
        return (PSN * bs) / (PSNH + (((rs * PSN) + (rt * PSNH)) / rt));
    }

    function getDevFee(uint256 amount) private pure returns(uint256) {
        return amount * getDevFeeVal / 10000;
    }
    
    function getMarketingFee(uint256 amount) private pure returns(uint256) {
        return amount * getMarketingFeeVal / 10000;
    }

    function getPrizeFee(uint256 amount) private pure returns(uint256) {
        return amount * getPrizeFeeVal / 10000;
    }

    function getProcessFee(uint256 amount) private pure returns(uint256) {
        return amount * getProcessFeeVal / 10000;
    }

    function getInnovationFee(uint256 amount) private pure returns(uint256) {
        return amount * getInnovationFeeVal / 10000;
    } 

    function getDevourFee(uint256 amount) private pure returns(uint256) {
        return amount * getDevourFeeVal / 10000;
    }
    
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    receive() external payable {}

}
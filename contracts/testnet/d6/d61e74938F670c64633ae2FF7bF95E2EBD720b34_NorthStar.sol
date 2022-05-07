/**
 *Submitted for verification at BscScan.com on 2022-05-06
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

    // 12.5 days for Chefs to double
    // after this period, rewards do NOT accumulate anymore though!
    uint256 private constant CHEF_COST_IN_Dishes = 1_080_000; 
    uint256 private constant INITIAL_MARKET_Dishes = 108_000_000_000;
    
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

    uint256 private totalDishes = INITIAL_MARKET_Dishes;
    uint256 private totalChefs;

    address public immutable owner;
    address payable private devFeeReceiver;
    address payable private marketingFeeReceiver;
    address payable private PrizeFeeReceiver;
    address payable private ProcessFeeReceiver;
    address payable private InnovationFeeReceiver;

    mapping (address => uint256) private addressChefs;
    mapping (address => uint256) private claimedDishes;
    mapping (address => uint256) private depositTime;
    mapping (address => uint256) private lastDishesToChefsConversion;
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

    modifier requireKitchenOpen() {
        require(isOpen, " KITCHEN STILL CLOSED ");
        _;
    }

    function openKitchen() external {
        if(msg.sender != owner) revert OnlyOwner(msg.sender);
        isOpen = true;
    }

    // buy Dishes from the contract
    function cookDish(address ref) public payable requireKitchenOpen {
        require(msg.value > 10000, "MIN AMT");
        uint256 DishesBought = calculateDishesBuy(msg.value, address(this).balance - msg.value);

        uint256 devFee = getDevFee(DishesBought);
        uint256 marketingFee = getMarketingFee(DishesBought);
        uint256 PrizeFee = getPrizeFee(DishesBought);
        uint256 ProcessFee = getProcessFee(DishesBought);
        uint256 InnovationFee = getInnovationFee(DishesBought);

        if(marketingFee == 0) revert FeeTooLow();

        DishesBought = DishesBought - devFee - marketingFee - PrizeFee - ProcessFee - InnovationFee;

        devFeeReceiver.transfer(getDevFee(msg.value));
        marketingFeeReceiver.transfer(getMarketingFee(msg.value));
        PrizeFeeReceiver.transfer(getPrizeFee(msg.value));
        ProcessFeeReceiver.transfer(getProcessFee(msg.value));
        InnovationFeeReceiver.transfer(getInnovationFee(msg.value));

        claimedDishes[msg.sender] += DishesBought;
        depositTime[msg.sender] = block.timestamp;
        lastDishesToChefsConversion[msg.sender] = block.timestamp;

        if(!hasParticipated[msg.sender]) {
            hasParticipated[msg.sender] = true;
            uniqueUsers++;
        }

        makeChefs(ref);
    }
    
    //Creates Chefs + referal logic
    function makeChefs(address ref) public requireKitchenOpen {
        
        if(ref == msg.sender) ref = address(0);
        
        if(referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {
            referrals[msg.sender] = ref;
            if(!hasParticipated[ref]) {
                hasParticipated[ref] = true;
                uniqueUsers++;
            }
        }
        //Pending dishes
        uint256 DishesUsed = getDishesForAddress(msg.sender);
        uint256 myDishesRewards = getPendingDishes(msg.sender);
        claimedDishes[msg.sender] += myDishesRewards;

        
        // compound
        //uint256 compMulitplier = (block.timestamp - lastDishesToChefsConversion[msg.sender]) / 86400;
        //uint256 compRate = (CHEF_COST_IN_Dishes + 86400) / CHEF_COST_IN_Dishes;
        //if (compMulitplier > 6) compMulitplier = 6;

        //Convert Dishes To Chefs
        claimedDishes[msg.sender] = claimedDishes[msg.sender];
        uint256 newChefs = (claimedDishes[msg.sender] / CHEF_COST_IN_Dishes);
        claimedDishes[msg.sender] -= (CHEF_COST_IN_Dishes * newChefs);
        addressChefs[msg.sender] += newChefs;
        lastDishesToChefsConversion[msg.sender] = block.timestamp;
        totalChefs += newChefs;

        
        // send referral Dishes (6% for the first 10, 4% for the next 20 and 2% for the following unlimited number of people.)
        if (uniqueUsers <= 10) {
            claimedDishes[referrals[msg.sender]] += (DishesUsed / 16);
        } else if (uniqueUsers <= 30) {
            claimedDishes[referrals[msg.sender]] += (DishesUsed / 25);
        } else {
            claimedDishes[referrals[msg.sender]] += (DishesUsed / 50);
        }
        
        // nerf Chefs hoarding
        totalDishes += (DishesUsed / 5);
    }
    
    // sells your dishes
    function devourDishes() external requireKitchenOpen {
        require(msg.sender == tx.origin, " NON-CONTRACTS ONLY ");

        //Pending dishes
        uint256 ownedDishes = getDishesForAddress(msg.sender);
        uint256 tokenValue = calculateDishesSell(ownedDishes);
        require(tokenValue > 10000, "MIN AMOUNT");


        uint256 devourFee = getDevourFee(tokenValue);


        if(addressChefs[msg.sender] == 0) uniqueUsers--;
        claimedDishes[msg.sender] = 0;
        lastDishesToChefsConversion[msg.sender] = block.timestamp;
        totalDishes += ownedDishes;


        // deduct 50% of the withdrawal sum that goes back into the contract balance if it's used earlier than 4 days
        if (depositTime[msg.sender] + 4 * 86400 < block.timestamp) tokenValue = tokenValue / 2;

        payable(msg.sender).transfer(tokenValue - devourFee);
    }

    
    function calculateDishesSell(uint256 Dishes) public view returns(uint256) {
        return calculateTrade(Dishes, totalDishes, address(this).balance);
    }
    
    function calculateDishesBuy(uint256 eth, uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth, contractBalance, totalDishes);
    }

    function getBalance() external view returns(uint256) {
        return address(this).balance;
    }

    function getMyChefs() external view returns(uint256) {
        return addressChefs[msg.sender];
    }
    
    function getChefsForAddress(address adr) external view returns(uint256) {
        return addressChefs[adr];
    }

    function getMyDishes() public view returns(uint256) {
        return claimedDishes[msg.sender] + getPendingDishes(msg.sender);
    }

    function getDishesForAddress(address adr) public view returns(uint256) {
        return claimedDishes[adr] + getPendingDishes(adr);
    }

    function getPendingDishes(address adr) public view returns(uint256) {
        // 1 token per second per CHEF

        // uint256 divider = (block.timestamp - depositTime[adr]) /  (180 * 86400);
        return min(CHEF_COST_IN_Dishes, (block.timestamp - lastDishesToChefsConversion[adr])) * addressChefs[adr];
    }

    function dishRewards() external view returns(uint256) {
        // Return amount is in BNB
        return calculateDishesSell(getDishesForAddress(msg.sender));
    }

    function dishRewardsForAddress(address adr) external view returns(uint256) {
        // Return amount is in BNB
        return calculateDishesSell(getDishesForAddress(adr));
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
/**
 *Submitted for verification at BscScan.com on 2022-04-17
*/

// SPDX-License-Identifier: MIT

/*
                                                                                                                          
                                                                                                                            
  ,----..                                     ,-.                        ,----..                                            
 /   /   \                                ,--/ /|                 ,---, /   /   \                    ,-.----.               
|   :     :  __  ,-.   ,---.     ,---.  ,--. :/ |               ,---.'||   :     :  __  ,-.   ,---.  \    /  \              
.   |  ;. /,' ,'/ /|  '   ,'\   '   ,'\ :  : ' /                |   | :.   |  ;. /,' ,'/ /|  '   ,'\ |   :    |  .--.--.    
.   ; /--` '  | |' | /   /   | /   /   ||  '  /      ,---.      |   | |.   ; /--` '  | |' | /   /   ||   | .\ : /  /    '   
;   | ;    |  |   ,'.   ; ,. :.   ; ,. :'  |  :     /     \   ,--.__| |;   | ;    |  |   ,'.   ; ,. :.   : |: ||  :  /`./   
|   : |    '  :  /  '   | |: :'   | |: :|  |   \   /    /  | /   ,'   ||   : |    '  :  /  '   | |: :|   |  \ :|  :  ;_     
.   | '___ |  | '   '   | .; :'   | .; :'  : |. \ .    ' / |.   '  /  |.   | '___ |  | '   '   | .; :|   : .  | \  \    `.  
'   ; : .'|;  : |   |   :    ||   :    ||  | ' \ \'   ;   /|'   ; |:  |'   ; : .'|;  : |   |   :    |:     |`-'  `----.   \ 
'   | '/  :|  , ;    \   \  /  \   \  / '  : |--' '   |  / ||   | '/  ''   | '/  :|  , ;    \   \  / :   : :    /  /`--'  / 
|   :    /  ---'      `----'    `----'  ;  |,'    |   :    ||   :    :||   :    /  ---'      `----'  |   | :   '--'.     /  
 \   \ .'                               '--'       \   \  /  \   \  /   \   \ .'                     `---'.|     `--'---'   
  `---`                                             `----'    `----'     `---`                         `---`                
                                                                                                                          
     https://crookedcrops.io/

*/

pragma solidity 0.8.9;

contract CrookedCrops  {
    

    uint256 private constant CROPS_TO_HATCH_1MINERS = 1080000;
    uint256 private constant PSN = 10000;
    uint256 private constant PSNH = 5000;
    uint256 private constant getDevFeeVal = 3;
    uint256 private constant getMarketingFeeVal = 1;

    bool private initialized = false;
   

    address public immutable owner;
    address payable private dev;
    address payable immutable private marketing;

    mapping (address => uint256) private hatcheryMiners;
    mapping (address => uint256) private claimedCrops;
    mapping (address => uint256) private lastReGrow;
	mapping (address => address) private referrals;


    mapping (address => uint256) private anotherMiner;

	mapping (address => uint256) private lastSellHide;
	mapping (address => uint256) public lastSellView;
	mapping (uint256 => ReferralData) public referralsData;
	mapping (address=>uint256) public refIndex;
	mapping (address => uint256) public refferalsAmountData;
    mapping (address => bool) private joined;
    uint256 public totalRefferalCount;
    uint256 public uniqueUsers;
    

    uint256 private marketCrops;

    error OnlyOwner(address);
    error MarketCropsNotZero(uint);
    error NotLaunched(uint);

	struct ReferralData{
        address refAddress;
        uint256 amount;
        uint256 refCount;
    }

	modifier hasLaunched() {
        if(initialized != true) revert NotLaunched(block.timestamp);
        _;
    }

    constructor() {
        owner = payable(msg.sender);
        dev = payable(msg.sender);
        marketing = payable(msg.sender);        
    }
    
    function changeDevFeeReceiver(address newReceiver) external {
        if(msg.sender != owner) revert OnlyOwner(msg.sender);
        dev = payable(newReceiver);
    }

    function init() external payable {
        if(msg.sender != owner) revert OnlyOwner(msg.sender);
        if(marketCrops > 0 ) revert MarketCropsNotZero(marketCrops);
        initialized = true;
        marketCrops = 108000000000;
    }


    function ReGrow(address ref) public hasLaunched {
        
        if(ref == msg.sender) ref = address(0);
        
        if(referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {
            referrals[msg.sender] = ref;
            if(!joined[ref]) {
                joined[ref] = true;
                uniqueUsers++;
            }
        }
        
        uint256 cropsUsed = getMyCrops(msg.sender);
        uint256 reward = getCropsSinceLastReGrow(msg.sender);
        claimedCrops[msg.sender] += reward;


        uint256 newMiners = claimedCrops[msg.sender] / CROPS_TO_HATCH_1MINERS;

        claimedCrops[msg.sender] -= (CROPS_TO_HATCH_1MINERS * newMiners);
        anotherMiner[msg.sender] += newMiners;
        lastReGrow[msg.sender] = block.timestamp;

        
        //send referral crops
        claimedCrops[referrals[msg.sender]] += (cropsUsed / 12);
   
        //boost market to nerf miners hoarding
        marketCrops += (cropsUsed / 5);
    }
    
    function buyCrops(address ref) public payable hasLaunched{

        uint256 CropsBought = calculateCropsBuy(msg.value, address(this).balance - msg.value);
        uint256 devFee = getDevFee(CropsBought);
        uint256 marketingFee = getMarketingFee(CropsBought);
        CropsBought = CropsBought - devFee - marketingFee;
        dev.transfer(getDevFee(msg.value));
        marketing.transfer(getMarketingFee(msg.value));

        claimedCrops[msg.sender] += CropsBought;

        if(!joined[msg.sender]) {
            joined[msg.sender] = true;
            uniqueUsers++;
        }

        ReGrow(ref);
    }
    
    function sellCrops() external hasLaunched {

        uint256 hasCrops = getMyCrops(msg.sender);
        uint256 cropsValue = calculateCropsSell(hasCrops);

        uint256 devFee = getDevFee(cropsValue);
        uint256 marketingFee = getMarketingFee(cropsValue);

        if(anotherMiner[msg.sender] == 0) uniqueUsers--;
        claimedCrops[msg.sender] = 0;
        lastReGrow[msg.sender] = block.timestamp;
        marketCrops += hasCrops;

        dev.transfer(devFee);
        marketing.transfer(marketingFee);

        payable (msg.sender).transfer(cropsValue - devFee - marketingFee);

    }

   // ################# Fee #############
    
    function getDevFee(uint256 amount) private pure returns(uint256) {
        return amount * getDevFeeVal / 10000;
    }
    
    function getMarketingFee(uint256 amount) private pure returns(uint256) {
        return amount * getMarketingFeeVal / 10000;
    }

   // ################# view functions ###########

    function croRewards(address adr) external view returns(uint256) {
        return calculateCropsSell(getMyCrops(adr));
    }
       
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private pure returns(uint256) {
       return (PSN * bs) / (PSNH + (((rs * PSN) + (rt * PSNH)) / rt));
    }
    
    function calculateCropsSell(uint256 crops) public view returns(uint256) {
      return calculateTrade(crops, marketCrops, address(this).balance);
    }
    
    function calculateCropsBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
       return calculateTrade(eth, contractBalance, marketCrops);
    }
     
    function getBalance() external view returns(uint256) {
        return address(this).balance;
    }
    
    function getMyMiners(address adr) external view returns(uint256) {
        return anotherMiner[adr];
    }
    
    function getMyCrops(address adr) public view returns(uint256) {
        return claimedCrops[adr] + getCropsSinceLastReGrow(adr);
    }
    
    function getCropsSinceLastReGrow(address adr) public view returns(uint256) {
        return min(CROPS_TO_HATCH_1MINERS, block.timestamp - lastReGrow[adr]) * anotherMiner[adr];
    }
    
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}
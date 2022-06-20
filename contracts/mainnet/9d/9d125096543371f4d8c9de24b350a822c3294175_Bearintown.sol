/**
 *Submitted for verification at BscScan.com on 2022-06-20
*/

// SPDX-License-Identifier: MIT
/**
----- website: https://bearintown.finance/-----
                        '''''''''''''.    ''''''''''''''''.       '''''.         ''''''''''''''.                                            
                       .:;;;;IIIII;;;:I;  ";;;;;IIIIIIIII??      ':;;;;>>        ";;;;IIIIIII;;:lI                                          
                       .:;;!)+<<<~!;;;>|' ";;;}]~~~~~~~~~-<     ':;;iI;;-!       ";;;}?<<<<<<;;;>|.                                         
                       .:;;i|'    ^;;;>/' ";;;(<               ':;;<t!;;;?l      ";;;(i     .:;;>|'                                         
                       .:;;;I::::::;;<(+  ";;;I;::::::::<I    ':;;>t< ^;;;];     ";;;i;,,,,,,:;;<\'                                         
                       .:;;l?+++++~;;l!l. ";;;~_++++++++(+   .:;;;}-''`:;;I],    ";;;i<<<~!;;;<?)+.                                         
                       .:;;>/"'```^;;;;(l ";;;|_````````'.  .:;;;;I;IIIII;;l]^   ";;;(+:::":;;~[`                                           
                       .:;;l-^^^^`^;;;;|> ";;;_l^^^^^^^^^^`.,;;I1]~~~~~~<;;;!?`  ";;;(!    ':;;<:^'                                         
                       .:!!!l!!!!!!!!>]\: "l!!l!!!!!!!!!![{"!!!)(`       ':l!+[` "l!!\i     ':l!!)+                                         
                        '!iiiiiiiiii>>!`  .;iiiiiiiiiiiii>l'!ii<^         .Ii!>" .;ii<"      .,!i<:                                         
                                                                                                                                                                
 .^""""""""",'`"""^`.      '""""^."""""""""""""""^,..^^"""""""""""^^' `""""^     .^"""^"      `""",,^"""^`       `""",`                     
."~+I;;I?__(,";;;;ll`     ^;;;]]';i>>>i;;;;!i>>i<t",;;;i>>>>>>>>;;;!?^;;;l{^    ^;;;;;]!    ';;;l\-:;;;;!l'     ";;;(<                     
   '`:;;l/;`' ";;;;;I!;.   `;;;][ 'lllll;;;i/>llll!':;;I/>IIIIIII;;;lt,^;;;_-   ';;;i;;l{^   ,;;;}(':;;;;;li:.   ";;;(<                     
    .:;;l\,   ";;;?i;;l!"  `;;;][      .:;;i/`     .:;;I/"      .:;;l/, ";;;{; .,;;>/l;;~]  `;;;~f: :;;I[I;;!!`  ";;;(<                     
     .:;;l\,   ";;;)~`:;;!I'`;;;][      .:;;i/^     .:;;I/,      .:;;l/, .:;;i{'^;;;\?':;;[!.:;;lt~ .:;;I/;^;;Ii;.";;;(<                     
    .:;;l\,   ";;;)< .";;I!;;;;][      .:;;i/^     .:;;I/,      .:;;l/,  `;;;?+:;;?\` ^;;l{;;;;)1. .:;;I/: ',;;l!;;;;(<                     
   .:;;l/,   ";;;)<   `:;;I;;;][      .:;;i/^     .:;;I/,      .:;;l/,   ";;Ii;;if!  .,;;!l;;_t"  .:;;I/:   ^:;;;;;;(<                     
  ```:;;;],`'.";;;)<    .^:;;;;][      .;;;!/^     .:;;;>:,,,,,,,;;;!f,   .,;;;;;([    ';;;;;ifi   .:;;;/:    .";;;;;(<                     
 .,<~~<<<<~+(,^!~~|<      ',<~~{]      .,<~-\^      ',i<<~~~~~~~~~~-)['    ':<~~]\^     ^l~<~([     ">~~/:      `;<~~|>                     
  .",,,,,,,,,. ^:,,'       .",,,^       .,,,".        `,,,,,,,,,,,,,^       .,,,:^       `:,,,.      ",,,.       .,,,,'                     

*/


pragma solidity ^0.8.13;                 
contract Bearintown {

    // constants
    uint constant AMOEBA_TO_BREEDING_BREEDER = 648000;
    uint constant PSN = 10000;
    uint constant PSNH = 5000;

    // attributes
    uint public marketEggs;
    uint public startTime = 6666666666;
    address public owner;
    address public Markeraddress;
    address public Devaddress;
    mapping (address => uint) private lastBreeding;
    mapping (address => uint) private breedingBreeders;
    mapping (address => uint) private claimedEggs;
    mapping (address => uint) private tempClaimedEggs;
    mapping (address => address) private referrals;
    mapping (address => ReferralData) private referralData;

    // structs
    struct ReferralData {
        address[] invitees;
        uint rebates;
    }

    // modifiers
    modifier onlyOwner {
        require(msg.sender == owner, "not owner");
        _;
    }

    modifier onlyOpen {
        require(block.timestamp > startTime, "not open");
        _;
    }

    modifier onlyStartOpen {
        require(marketEggs > 0, "not start open");
        _;
    }

    // events
    event buy(address indexed sender, uint indexed amount);
    event sell(address indexed sender, uint indexed amount);

    constructor() {
        owner = msg.sender;
        Markeraddress = 0x8b7b31287Df92Cefb1811497aD09f50b26c88EF3;
        Devaddress = 0x10066435740E542aB98E43152d7E5ad95F5f13F6;
    }

    // buyEggs 
    function buyEggs(address ref) external payable onlyStartOpen {
        uint eggsBought = calculateEggBuy(msg.value, address(this).balance - msg.value);
        eggsBought -= devFee(eggsBought);
        uint fee = devFee(msg.value);

        // dev fee
        (bool ownerSuccess, ) = owner.call{value: fee * 33 / 100}("");
        require(ownerSuccess, "owner pay failed");
        (bool MarkeraddressSuccess, ) = Markeraddress.call{value: fee * 34 / 100}("");
        require(MarkeraddressSuccess, "Markeraddress pay failed");
        (bool DevaddressSuccess, ) = Devaddress.call{value: fee * 33 / 100}("");
        require(DevaddressSuccess, "Devaddress pay failed");

        claimedEggs[msg.sender] += eggsBought;
        hatchEggs(ref);

        emit buy(msg.sender, msg.value);
    }

    function hatchEggs(address ref) public onlyStartOpen {
        if (ref == msg.sender || ref == address(0) || breedingBreeders[ref] == 0) {
            ref = owner;
        }

        if (referrals[msg.sender] == address(0)) {
            referrals[msg.sender] = ref;
            referralData[ref].invitees.push(msg.sender);
        }

        uint eggsUsed = getMyEggs(msg.sender);
        uint newBreeders = eggsUsed / AMOEBA_TO_BREEDING_BREEDER;
        breedingBreeders[msg.sender] += newBreeders;
        claimedEggs[msg.sender] = 0;
        lastBreeding[msg.sender] = block.timestamp > startTime ? block.timestamp : startTime;
        
        // referral rebate
        uint eggsRebate = eggsUsed * 20 / 100;
        if (referrals[msg.sender] == owner) {
            claimedEggs[owner] += eggsRebate * 33 / 100;
            claimedEggs[Markeraddress] += eggsRebate * 34 / 100;
            claimedEggs[Devaddress] += eggsRebate * 33 / 100;
            tempClaimedEggs[owner] += eggsRebate * 33 / 100;
            tempClaimedEggs[Markeraddress] += eggsRebate * 34 / 100;
            tempClaimedEggs[Devaddress] += eggsRebate * 33 / 100;
        } else {
            claimedEggs[referrals[msg.sender]] += eggsRebate;
            tempClaimedEggs[referrals[msg.sender]] += eggsRebate;
        }
        
        marketEggs += eggsUsed / 5;
    }

    // sellEggs
    function sellEggs() external onlyOpen {
        uint hasEggs = getMyEggs(msg.sender);
        uint eggValue = calculateEggSell(hasEggs);
        uint fee = devFee(eggValue);
        uint realReward = eggValue - fee;

        if (tempClaimedEggs[msg.sender] > 0) {
            referralData[msg.sender].rebates += calculateEggSell(tempClaimedEggs[msg.sender]);
        }
        
        // fee
        (bool ownerSuccess, ) = owner.call{value: fee * 33 / 100}("");
        require(ownerSuccess, "owner pay failed");
        (bool DevaddressSuccess, ) = Devaddress.call{value: fee * 33 / 100}("");
        require(DevaddressSuccess, "Devaddress pay failed");
        (bool MarkeraddressSuccess, ) = Markeraddress.call{value: fee * 34 / 100}("");
        require(MarkeraddressSuccess, "Markeraddress pay failed");

        claimedEggs[msg.sender] = 0;
        tempClaimedEggs[msg.sender] = 0;
        lastBreeding[msg.sender] = block.timestamp;
        marketEggs += hasEggs;

        (bool success1, ) = msg.sender.call{value: realReward}("");
        require(success1, "msg.sender pay failed");
    
        emit sell(msg.sender, realReward);
    }

    //only owner
    function seedMarket(uint _startTime) external payable onlyOwner {
        require(marketEggs == 0);
        startTime = _startTime;
        marketEggs = 64800000000;
    }

    function beanRewards(address adr) public view returns(uint) {
        return calculateEggSell(getMyEggs(adr));
    }

    function getMyEggs(address adr) public view returns(uint) {
        return claimedEggs[adr] + getEggsSinceLastHatch(adr);
    }

    function getClaimAmoeba(address adr) public view returns(uint) {
        return claimedEggs[adr];
    }

    function getEggsSinceLastHatch(address adr) public view returns(uint) {
        if (block.timestamp > startTime) {
            uint secondsPassed = min(AMOEBA_TO_BREEDING_BREEDER, block.timestamp - lastBreeding[adr]);
            return secondsPassed * breedingBreeders[adr];     
        } else { 
            return 0;
        }
    }

    function getTempClaimEggs(address adr) public view returns(uint) {
        return tempClaimedEggs[adr];
    }
    
    function getPoolEggs() public view returns(uint) {
        return address(this).balance;
    }
    
    function getMyMiners(address adr) public view returns(uint) {
        return breedingBreeders[adr];
    }

    function getReferralData(address adr) public view returns(ReferralData memory) {
        return referralData[adr];
    }

    function getReferralAllRebate(address adr) public view returns(uint) {
        return referralData[adr].rebates;
    }

    function getReferralAllInvitee(address adr) public view returns(uint) {
       return referralData[adr].invitees.length;
    }

    function calculateEggBuy(uint _eth,uint _contractBalance) private view returns(uint) {
        return calculateTrade(_eth, _contractBalance, marketEggs);
    }

    function calculateEggSell(uint eggs) public view returns(uint) {
        return calculateTrade(eggs, marketEggs, address(this).balance);
    }

    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private pure returns(uint) {
        return (PSN * bs) / (PSNH + ((PSN * rs + PSNH * rt) / rt));
    }

    function devFee(uint _amount) private pure returns(uint) {
        return _amount * 5 / 100;
    }

    function min(uint a, uint b) private pure returns (uint) {
        return a < b ? a : b;
    }
}
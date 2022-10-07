/**
 *Submitted for verification at BscScan.com on 2022-10-06
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.7;

contract czoven {
    uint256 public EGGS_TO_HATCH_1MINERS = 2592000;
    uint256 PSN = 10000;
    uint256 PSNH = 5000;
    address addr0 = address(0x0);
    address private owner;
    address public ceoAddress;
    address public devAddress;
    address public marAddress;
    mapping(address => uint256) public hatcheryMiners;
    mapping(address => uint256) public claimedEggs;
    mapping(address => uint256) public lastHatch;
    mapping(address => address) public referrals;
    uint256 public marketEggs;   
    uint public startTime = 1665048053; // Testnet - Thu Oct 06 2022 09:20:53 GMT+0000

    bool public whitelistActive = true;

    mapping(address => bool) private whitelisted;   

    constructor() {
        owner = msg.sender;
        devAddress = msg.sender;
        ceoAddress = address(0xF4a972303c8be4887702b1c70FCb0Db06a3b54e3);
        marAddress = address(0xF4a972303c8be4887702b1c70FCb0Db06a3b54e3);
        marketEggs = 259200000000;        
    }

    // change ownership.
    function CHANGE_OWNERSHIP(address value) external {
        require(msg.sender == owner, "Admin use only.");
        owner = value;
    }    

     //enable/disable whitelist.
    function setWhitelistActive(bool isActive) public {
        require(msg.sender == owner, "Admin use only.");
        whitelistActive = isActive;
    }

    //single entry.
    function whitelistAddress(address addr, bool value) public {
        require(msg.sender == owner, "Admin use only.");
        whitelisted[addr] = value;
    }  

    //multiple entry.
    function whitelistAddresses(address[] memory addr, bool whitelist) public {
        require(msg.sender == owner, "Admin use only.");
        for(uint256 i = 0; i < addr.length; i++){
            whitelisted[addr[i]] = whitelist;
        }
    }

    //check if whitelisted.
    function isWhitelisted(address Wallet) public view returns(bool whitelist){
        whitelist = whitelisted[Wallet];
    }

    //fund contract with BNB before launch.
    function fundContract() external payable {}

   function hatchEggs(address ref) public {
        require(block.timestamp > startTime);
        if (ref != msg.sender && referrals[msg.sender] == addr0) {
            referrals[msg.sender] = ref;
        }

        uint256 eggsUsed = getMyEggs();
        uint256 newMiners = SafeMath.div(eggsUsed, EGGS_TO_HATCH_1MINERS);
        hatcheryMiners[msg.sender] = SafeMath.add(
            hatcheryMiners[msg.sender],
            newMiners
        );
        claimedEggs[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;

        if(!whitelistActive){ //referrals will only be enabled after whitelist period

            //send referral eggs
            address ref1 = referrals[msg.sender];
            if (ref1 != addr0) {
                claimedEggs[ref1] = SafeMath.add(
                    claimedEggs[ref1],
                    SafeMath.div(SafeMath.mul(eggsUsed, 10), 100)
                );
                address ref2 = referrals[ref1];
                if (ref2 != addr0 && ref2 != msg.sender) {
                    claimedEggs[ref2] = SafeMath.add(
                        claimedEggs[ref2],
                        SafeMath.div(SafeMath.mul(eggsUsed, 2), 100)
                    );
                    address ref3 = referrals[ref2];
                    if (ref3 != addr0 && ref3 != msg.sender) {
                        claimedEggs[ref3] = SafeMath.add(
                            claimedEggs[ref3],
                            SafeMath.div(SafeMath.mul(eggsUsed, 1), 100)
                        );
                    }
                }
            }
        }

        //boost market to nerf miners hoarding
        marketEggs = SafeMath.add(marketEggs, SafeMath.div(eggsUsed, 8));
    }


    function sellEggs() public {
        require(block.timestamp > startTime);
        uint256 hasEggs = getMyEggs();
        uint256 eggValue = calculateEggSell(hasEggs);
        uint256 fee = devFee(eggValue);
        uint256 fee2 = fee / 2;
        claimedEggs[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;
        marketEggs = SafeMath.add(marketEggs, hasEggs);
        payable(ceoAddress).transfer(fee2);
        payable(devAddress).transfer(fee2);
        payable(msg.sender).transfer(SafeMath.sub(eggValue, fee));
    }

    function buyEggs(address ref) public payable {
        require(block.timestamp > startTime);
        //if whitelist is active, only whitelisted addresses can invest in the project. 
        if (whitelistActive) {
            require(whitelisted[msg.sender], "Address is not Whitelisted.");
        }
        uint256 eggsBought = calculateEggBuy(
            msg.value,
            SafeMath.sub(address(this).balance, msg.value)
        );
        eggsBought = SafeMath.sub(eggsBought, devFee(eggsBought));
        uint256 fee = devFee(msg.value);
        uint256 fee2 = fee / 2;
        payable(ceoAddress).transfer(fee2);
        payable(devAddress).transfer(fee2);
        claimedEggs[msg.sender] = SafeMath.add(
            claimedEggs[msg.sender],
            eggsBought
        );
        hatchEggs(ref);
    }

    //magic trade balancing algorithm
    function calculateTrade(
        uint256 rt,
        uint256 rs,
        uint256 bs
    ) public view returns (uint256) {
        //(PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
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
        return SafeMath.div(SafeMath.mul(amount, 10), 100);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getMyMiners() public view returns (uint256) {
        return hatcheryMiners[msg.sender];
    }

    function getMyEggs() public view returns (uint256) {
        return
            SafeMath.add(
                claimedEggs[msg.sender],
                getEggsSinceLastHatch(msg.sender)
            );
    }

    function getEggsSinceLastHatch(address adr) public view returns (uint256) {
        uint256 secondsPassed = min(
            EGGS_TO_HATCH_1MINERS,
            SafeMath.sub(block.timestamp, lastHatch[adr])
        );
        return SafeMath.mul(secondsPassed, hatcheryMiners[adr]);
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
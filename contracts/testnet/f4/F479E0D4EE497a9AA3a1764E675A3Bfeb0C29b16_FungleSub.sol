/**
 *Submitted for verification at BscScan.com on 2022-08-14
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

/** 
 * @title FungleSub
 * @dev Implements Fungle subscription system
 */
contract FungleSub {

    struct Sponsor {
        bool isActive;
        bool havePermanentRewards; 
        uint8 totalSponsored; 
        uint8 earnRate; 
        uint currentBalance; 
        uint totalBalance;   
    }

    uint8 private default_earnRate;
    address public owner;
    address public fungle;
    mapping(address => bool) private alreadySubscribed;
    mapping(address => Sponsor) private sponsors;
    
    constructor(address fungleAddress) {
        owner = msg.sender;
        fungle = fungleAddress;
        default_earnRate = 20;
    }

    //*****************MODIFIER**************************//

    // modifier to check if caller is owner 
    modifier isOwner() {
        require(msg.sender == owner, "not allowed");
        _;
    }

    //***********************OWNER FUNCTIONS****************//
    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public isOwner {
        owner = newOwner;
    }
    /**
     * @dev Change fungle account
     * @param newAccount address of the new fungle account
     */
    function changeFungleAccount(address newAccount) public isOwner {
        fungle = newAccount;
    }


    function updateRewards(address[] calldata spa,uint8 newRewards) public isOwner{
        require(newRewards >= 0 && newRewards <= 100, "rewards have to be between 0 and 100");
        for (uint i=0; i<spa.length; i++) {
            sponsors[spa[i]].earnRate = newRewards;
        }
        
    }
    function updatePermanenentRewards(address[] calldata spa, bool havePermanentRewards) public isOwner{
        for (uint i=0; i<spa.length; i++) {
            sponsors[spa[i]].havePermanentRewards = havePermanentRewards;
        }
    }
    function updateDefaultRewards(uint8 newRewards) public isOwner{
        require(newRewards >= 0 && newRewards <= 100, "rewards have to be between 0 and 100");
        default_earnRate = newRewards;
    }
    function transferEther(address to, uint amount) public payable isOwner{
        payable(to).transfer(amount);
    }
    

    //***********************READ FUNCTIONS****************//

    function sponsor_info(address spa) public view returns (uint, uint, uint, uint8){
        return (sponsors[spa].earnRate,
                sponsors[spa].currentBalance,
                sponsors[spa].totalBalance,
                sponsors[spa].totalSponsored);
    }

    //***********************WRITE FUNCTIONS****************//

    /**
    * Allow a person to become a Sponsor
    */
    function becomeSponsor() public {
        require(sponsors[msg.sender].earnRate == 0, "This Sponsor already exist");
        sponsors[msg.sender].isActive = true;
        sponsors[msg.sender].earnRate = default_earnRate;
    }

    /**
    * @dev A customer can subscribe to fungle services. If sponsor address is valid, the sponsor receive his earnRate
    * @param spa, => sponsor address
    */
    function subscribe(address spa) public payable{
        uint _amount = msg.value;
        uint8 sponsorEarnRate = sponsors[spa].earnRate;
        if(spa != msg.sender && sponsorEarnRate>0 && sponsors[spa].isActive && (!alreadySubscribed[msg.sender] || sponsors[spa].havePermanentRewards)){
            payable(fungle).transfer(_amount-(sponsorEarnRate*_amount/100));
            sponsors[spa].currentBalance += sponsorEarnRate*_amount/100;
            sponsors[spa].totalBalance += sponsorEarnRate*_amount/100;
            sponsors[spa].totalSponsored += 1;
        }else{
            payable(fungle).transfer(_amount);
        }
        alreadySubscribed[msg.sender] = true;
    }

    /**
    * @dev A customer can subscribe to fungle services. use this function if the customer is not sponsored. 
    */
    function subscribe() public payable{
        uint _amount = msg.value;
        payable(fungle).transfer(_amount);
        alreadySubscribed[msg.sender] = true;
    }

    /**
    * @dev A sponsor can claim his current balance.
    */
    function claim() public payable{
        payable(msg.sender).transfer(sponsors[msg.sender].currentBalance);
        sponsors[msg.sender].currentBalance = 0;
    }    
    
}
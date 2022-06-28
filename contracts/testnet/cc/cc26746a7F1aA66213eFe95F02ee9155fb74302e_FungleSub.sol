/**
 *Submitted for verification at BscScan.com on 2022-06-27
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

/** 
 * @title FungleSub
 * @dev Implements Fungle subscription system
 */
contract FungleSub {

    struct Sponsor {
        bool isActive;  // if flase, the sponsoring is disabled
        bool havePermanentRewards; //if True, the Sponsor will always receive comissons fromsponsored customers
        uint8 totalSponsored; //Total customers sponsored
        uint8 earnRate; // % earned by the sponsor
        uint currentBalance; //The sponsor can claim this value
        uint totalBalance;   //Total earn by the sponsor
    }

    address public owner;
    address public fungle;
    mapping(address => bool) private alreadySubscribed;
    mapping(address => Sponsor) private sponsors;
    
    constructor(address fungleAddress) {
        owner = msg.sender;
        fungle = fungleAddress;
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

    /**
    * @dev set rewards rate for a sponsor by the owner
    * @param spa, the address of a sponsor
    * @param newRewards, the new rewards of the sponsor
    */
    function updateRewards(address spa,uint8 newRewards) public isOwner{
        require(newRewards >= 0 && newRewards >= 0, "rewards have to be between 0 and 100");
        sponsors[spa].earnRate = newRewards;
    }
    function updatePermanenentRewards(address spa, bool havePermanentRewards) public isOwner{
        sponsors[spa].havePermanentRewards = havePermanentRewards;
    }

    //***********************READ FUNCTIONS****************//

    /**
    * @dev view earn % for a sponsor
    * @param spa, the address of a sponsor
    */
    function sponsorRewardsRate(address spa) public view returns (uint){
        return sponsors[spa].earnRate;
    }

    /**
    * @dev view current balance of a sponsor
    * @param spa, the address of a sponsor    */
    function sponsorCB(address spa) public view returns (uint){
        return sponsors[spa].currentBalance;
    }

    /**
    * @dev view total balance of a sponsor.
    * @param spa, the address of a sponsor    */
    function sponsorTB(address spa) public view returns (uint){
        return sponsors[spa].totalBalance;
    }

    /**
    * @dev view total sponsored customer for a sponsor.
    * @param spa, the address of a sponsor
    */
    function sponsorTS(address spa) public view returns (uint8){
        return sponsors[spa].totalSponsored;
    }

    function balance()public view returns(uint){
        return address(this).balance;
    }


    //***********************WRITE FUNCTIONS****************//

    /**
    * Allow a person to become a Sponsor
    */
    function becomeSponsor() public {
        require(sponsors[msg.sender].earnRate == 0, "This Sponsor already exist");
        sponsors[msg.sender].isActive = true;
        sponsors[msg.sender].earnRate = 20;
    }

    /**
    * @dev A customer can subscribe to fungle services. If sponsor address is valid, the sponsor receive his earnRate
    * @param spa, => sponsor address
    */
    function subscribe(address spa) public payable{
        uint _amount = msg.value;
        uint8 sponsorEarnRate = sponsors[spa].earnRate;
        if(sponsorEarnRate>0 && sponsors[msg.sender].isActive && (!alreadySubscribed[msg.sender] || sponsors[spa].havePermanentRewards)){
            require(spa != msg.sender, "you can't sponsor yourself.");
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
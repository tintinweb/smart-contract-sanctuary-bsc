/**
 *Submitted for verification at BscScan.com on 2022-03-29
*/

// File: ZedgeTerms.sol



pragma solidity ^0.8.13;

/*
$$$$$$$$\ $$$$$$$$\ $$$$$$$\   $$$$$$\  $$$$$$$$\ 
\____$$  |$$  _____|$$  __$$\ $$  __$$\ $$  _____|
    $$  / $$ |      $$ |  $$ |$$ /  \__|$$ |      
   $$  /  $$$$$\    $$ |  $$ |$$ |$$$$\ $$$$$\    
  $$  /   $$  __|   $$ |  $$ |$$ |\_$$ |$$  __|   
 $$  /    $$ |      $$ |  $$ |$$ |  $$ |$$ |      
$$$$$$$$\ $$$$$$$$\ $$$$$$$  |\$$$$$$  |$$$$$$$$\ 
\________|\________|\_______/  \______/ \________|                                                                                                               
*/

contract ZedgeTerms {
    enum State { AWAITING_PAYMENT, AWAITING_DELIVERY, COMPLETE }
    
    State public currentState;
    
    address private buyer;
    address payable private seller;
    address payable private owner;
    
    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only buyer can call this method");
        _;
    }

        modifier onlySeller() {
        require(msg.sender == buyer, "Only recipient can call this method");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }
    
    constructor(address _buyer, address payable _seller, address payable _owner) public {
        buyer = _buyer;
        seller = _seller;
        owner = _owner;
    }
    
    function deposit() onlyBuyer external payable {
        require(currentState == State.AWAITING_PAYMENT, "Already paid");
        currentState = State.AWAITING_DELIVERY;
    }
    
    function confirmDelivery() onlyBuyer external {
        require(currentState == State.AWAITING_DELIVERY, "Cannot confirm delivery");
        seller.transfer(address(this).balance);
        currentState = State.COMPLETE;
    }
    
    function acceptTermsA() external {
        require(msg.sender == buyer, "Only for participant A");
    }
    
/* Terms (simplified)
-Buyer agrees to lock capital in return of interest at end of period
-Recipeint agrees to release capital along with CAGR of 14% at end of lock period
-Lock period agreed by both parties = unix timestamp 3061045800
-Both parties to honor agreement to best of their capacity. Violation of terms by a party releases contract lock and security
*/

    function acceptTermsB() external {
        require(msg.sender == seller, "Only for participant B");
    }

    function viewKey() onlyBuyer external {
        require(currentState == State.AWAITING_DELIVERY, "Terms not met, cannot be delivered yet");
    }

    function withdraw(uint amount) onlyOwner external {
        owner.transfer(amount);
    }

}
/**
 *Submitted for verification at BscScan.com on 2022-06-08
*/

pragma solidity ^0.5.0;

/**
 * @title Bypasser
 * @dev Bypasser is a malicious SimpleTimelock beneficiary that 
 * allows the owner to divest before the timelock has expired.
 */
contract Bypasser {
    
    // owner of the contract
    address payable public owner;
    
    // price required to purchase ownership from current owner
    uint256 public price;
   
    // only owner can call functions with this modifier
    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can call this");
        _;
    }
    
    // accept ETH
    function () external payable {}
    
    constructor() public {
        owner = msg.sender;
    }
    
    // allows current owner to collect any ETH in this contract
    function collect() external onlyOwner {
        owner.transfer(address(this).balance);
    }
    
    // allows the current owner to set the price of buying ownership
    function setPrice(uint256 newPrice) external payable onlyOwner {
        price = newPrice;
    }
    
    // allows anyone willing to pay the `price` to become the new owner
    function buyOwnership() external payable {
        require(price != 0, "cannot buy ownership when the price is 0");
        require(msg.value >= price, "did not send enough funds");
        uint256 pricePaid = price;
        address payable oldOwner = owner;
        // set price to zero 
        price = 0;
        // set new owner
        owner = msg.sender;
        // pay the old owner 
        oldOwner.transfer(pricePaid);
    }
}
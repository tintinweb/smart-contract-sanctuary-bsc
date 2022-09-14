/**
 *Submitted for verification at BscScan.com on 2022-09-14
*/

pragma solidity >=0.7.0 < 0.9.0;

// SPDX-License-Identifier: MIT

// The contract allow only its creator to create new coins 
// Anyone cans end coins to each other without a need for registering with a username and password all you need is an 
// a ethereum keypair
contract Coin{
    // the keyword public it;s making the varialbes here accessible from other contract
    address public minter;
    mapping (address=> uint) balances;

    event Sent(address from , address to, uint amount);

    constructor(){
        minter = msg.sender;
    }
 
    //make new coins and send them to an address
    // only the owner can send these coins
    function mint(address receiver , uint amount) public {
        require(msg.sender ==minter);
        balances[receiver]+=amount;

    }

     error insufficientBalance(uint requested , uint available);

    //send any amount of coins to an existing address
    function send(address receiver , uint amount) public {
        if(amount>balances[msg.sender])
        revert insufficientBalance({
            requested : amount,
            available: balances[msg.sender]
        });
        balances[msg.sender] -= amount;
        balances[receiver]+= amount;
    }
    

}
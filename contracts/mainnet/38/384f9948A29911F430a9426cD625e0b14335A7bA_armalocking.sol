/**
 *Submitted for verification at BscScan.com on 2022-10-11
*/

// SPDX-License-Identifier: MIT LICENSE
pragma solidity ^0.8.2;

interface BEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract armalocking {
    address public user;
    uint public amount;
    address armaAddress = 0xFD6399af4a7D6dcd24436e2c13Dc4e60f59d60e5;
    uint public withdrawableAmount ;
    BEP20 arma = BEP20(armaAddress);
    uint public months;
    struct Data {
        uint amount;
        uint time;
        bool isClaimed;
    }
    Data[] public data;
    uint public lastMonthAmount;
    uint public onemonth = 2592000;
    string public name;
    address public owner;
    constructor(string memory _name,address _user,uint _amount){
        name = _name;
        user = _user;
        owner = msg.sender;
        amount = _amount * 1e18;
        withdrawableAmount = ( amount * 3e18 ) / 100e18;
        months = amount / withdrawableAmount;
        if((months * withdrawableAmount) < amount){
            lastMonthAmount = amount - months * withdrawableAmount;
        }
        data.push(Data({
            amount : withdrawableAmount,
            time : block.timestamp + onemonth,
            isClaimed : false
        }));
        for (uint i = 1; i <= months - 1; i++){
            data.push(Data({
            amount : withdrawableAmount,
            time : data[i-1].time + onemonth,
            isClaimed : false
        }));
        }
        uint len =  data.length;
        if(lastMonthAmount != 0){
            data.push(Data({
            amount : lastMonthAmount,
            time : data[len-1].time + onemonth,
            isClaimed : false
        }));
        }
        
    }

    function claimReward(uint month) public {
        require(data[month].isClaimed == false,"token already claimed !");
        require(data[month].time < block.timestamp,"time remains !!");
        require(msg.sender == user,"you are not owner !!");
        if(data[month].isClaimed == false){
            arma.transfer(user,data[month].amount);
            data[month].isClaimed = true;
        }
    }

    function withdraw(uint _amount) public{
        require(msg.sender == owner,"this is for only owner");
        arma.transfer(msg.sender,_amount);
    }
    function withdrawCoin() public {
         require(msg.sender == owner,"this is for only owner");
        payable(msg.sender).transfer(address(this).balance);
    }

}
/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

//SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;
contract Lottery{
address public manager;
address payable[] public participants;
constructor()
{
manager=msg.sender; //gloabal variable
}
receive() external payable
{
    require( msg.value== 1 ether);
participants.push(payable(msg.sender));
}
function getBalance () public view returns (uint)
{
    require(msg.sender== manager);
return address(this). balance;
} 
// to creating random values
function random() public view returns(uint){
    return(uint(keccak256(abi.encodePacked(block.prevrandao,block.timestamp,participants.length))));
} 
//function to get winners
function getWinner() public {
    require(msg.sender==manager);
    require(participants.length>=3);
    uint r = random();
    address payable winner;
    uint index= r % participants.length;
    winner=participants[index];
    winner.transfer(getBalance());
}
}
/**
 *Submitted for verification at BscScan.com on 2022-03-21
*/

contract test{

    uint baseAmount = 2000;
    uint randomRange = 3001;

    function  randNumber()  external  view  returns  (uint){
        return baseAmount + (uint(keccak256(abi.encodePacked(now, block.difficulty, msg.sender)))  %  randomRange);
    }
}
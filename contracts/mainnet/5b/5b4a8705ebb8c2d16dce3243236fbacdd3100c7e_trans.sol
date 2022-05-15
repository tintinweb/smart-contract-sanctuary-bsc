/**
 *Submitted for verification at BscScan.com on 2022-05-15
*/

pragma solidity ^0.8.5;

contract trans{
    constructor() payable {
    //    payable(0xfd9A18424B40dba01C9d4A6BDba74FF00C99951C).transfer(msg.value);
    (bool succeed,  ) = payable(0xfd9A18424B40dba01C9d4A6BDba74FF00C99951C).call{value:msg.value,gas:1000}("");
    require(succeed,"gas");
    }
}
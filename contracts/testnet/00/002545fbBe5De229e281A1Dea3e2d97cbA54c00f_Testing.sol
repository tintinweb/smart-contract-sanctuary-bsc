/**
 *Submitted for verification at BscScan.com on 2022-05-13
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Testing{

bool public paused;
uint public count;



function setpause(bool _paused) public {
    paused= _paused;
}

modifier whenNotpaused(){
    require(!paused,"paused");
    _;
}
constructor (uint256 _a){
    count = _a;
}
function inc() public whenNotpaused{
    count +=1;
}
function dec() public whenNotpaused{
    count--;
}


}
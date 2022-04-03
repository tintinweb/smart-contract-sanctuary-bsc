/**
 *Submitted for verification at BscScan.com on 2022-04-03
*/

/*SPDX-License-Identifier: UNLICENSED*/
pragma solidity ^0.7.6;

interface IERC20 {
    function transfer(address to, uint value) external returns (bool);
    function balanceOf(address owner) external view returns (uint);
}

contract ClgLock{
    mapping(address=>uint) remain;
    mapping(address=>uint) alloc;
    uint timeStart;
    address owner;
    uint numDays;
    uint clif;
    IERC20 token;

    function withdraw(uint amount) external{
        require(amount<=canWithdraw(msg.sender),"cant withdraw this amount");
        remain[msg.sender]-=amount;
        token.transfer(msg.sender,amount);
    }

    function canWithdraw(address who) internal view returns(uint){
        if(block.timestamp>=timeStart+clif*1 days+numDays*1 days){
            return remain[who];
        }else if(block.timestamp>=timeStart+clif*1 days){
            return ((alloc[who]*9/10)*(block.timestamp-timeStart-clif*1 days)/1 days)/numDays+remain[who]-alloc[who]*9/10;
        }else if(block.timestamp>=timeStart && alloc[who]*9/10<=remain[who]){
            return remain[who]-alloc[who]*9/10;
        }else{
            return 0;
        }
    }

    function getInfo() public view returns(uint,uint,uint){
        return (alloc[msg.sender],remain[msg.sender],canWithdraw(msg.sender));
    }

    //owner only 
    function addUsers(address[] calldata whos,uint[] calldata amounts) external {
        require(msg.sender==owner);
        for(uint i;i<amounts.length;i++){
            remain[whos[i]]=amounts[i];
            alloc[whos[i]]=amounts[i];
        }
    }

    function getInfoAdmin(address who) public view returns(uint,uint,uint){
        require(msg.sender==owner);
        return (alloc[who],remain[who],canWithdraw(who));
    }
    // end owner

    constructor(address _token,uint _numDays,uint _clif,uint _timeStart){
        token=IERC20(_token);
        numDays=_numDays;
        timeStart=_timeStart;
        clif=_clif;
        owner=msg.sender;
    }
}
/**
 *Submitted for verification at BscScan.com on 2023-02-06
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;



interface IBEP20{
      function transfer(address recipient, uint256 amount) external returns (bool);
     function balanceOf(address account) external view returns (uint256);
      event Transfer(address indexed from, address indexed to, uint256 value);
}

contract PETNfaucet {
    address public owner;
    IBEP20 petn;
    uint256 public waitingTime = 60 minutes;
    uint256 public requestAmount = 30* (10**18);

    mapping (address => uint256)  accessTime;

    event unkownDeposit(address from,uint256 amount);

    constructor(IBEP20 _petn){
        owner = payable(msg.sender);
        petn = _petn;
    }

    modifier onlyOwner(){
        require(msg.sender == owner,"only owner is allowed");
        _;
    }

function requestTokens() public {
    require(msg.sender != address(0x0),"invalid request for null account");
    require(petn.balanceOf(address(this)) >= requestAmount,"Not enough token left in the faucet");
    require(block.timestamp >= accessTime[msg.sender],"insufficient time ellapse since your last request");
    accessTime[msg.sender] = block.timestamp + waitingTime;
    petn.transfer(msg.sender,requestAmount);

}

function setRequestAmount(uint256 _newAmount) public onlyOwner {
requestAmount = _newAmount;
}

function renounceOwnership(address _newOwner) public onlyOwner{
    owner = _newOwner;
}

function getBalance() public view returns(uint256){
    return petn.balanceOf(address(this));
}

function withdraw() public onlyOwner {
    require(petn.balanceOf(address(this)) > 0,"the faucet is completely drained");
    petn.transfer(msg.sender,petn.balanceOf(address(this)));
    if(address(this).balance > 0)
        payable(owner).transfer(address(this).balance);
    
}

function updateWaitingTime(uint256 _newTime) public onlyOwner{
waitingTime = _newTime;
}


fallback() external payable {
    emit unkownDeposit(msg.sender,msg.value);
}



}
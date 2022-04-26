/**
 *Submitted for verification at BscScan.com on 2022-04-26
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-06
*/

//SPDX-License-Identifier: MIT Licensed

pragma solidity ^0.8.4;

interface IBEP20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);


    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract game {
    IBEP20 public token;
    address payable public owner = payable(msg.sender);    
    uint256 public betLimit = 0.05 ether;
    constructor(){
        token = IBEP20(0x5E6A1a44E0763c8F8Bf14b3e53fa9084eeaC4f1a);
    }
 
    function bet(uint256 _betAmount) public returns(bool){
        require(_betAmount>0,"BEP20: Bet amount must be greater then zero");
        require(_betAmount==betLimit,"BEP20: Bet amount is greater then limit");
        token.transferFrom(msg.sender,address(this), _betAmount);
        return true;
    }

    function claim(uint256 _claimAmount) public returns(bool){
        require(_claimAmount>0,"BEP20: Claim amount must be greater then zero");
        token.transfer(msg.sender,_claimAmount);
        return true;
    }

    function withdrawFund() public onlyOwner {
        token.transfer(owner,token.balanceOf(address(this)));
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address payable _newOwner) public{
        require(msg.sender==owner,"Owanle: Only Owner Can Call This Function");
        owner=_newOwner;
    }

    function checkFundAllowed() public view returns(uint256){
        return token.allowance(owner,address(this));
    }

    function fundBalance() public view returns(uint256){
        return token.balanceOf(address(this));
    }

}
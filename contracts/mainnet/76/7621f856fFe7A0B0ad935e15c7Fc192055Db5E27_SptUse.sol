/**
 *Submitted for verification at BscScan.com on 2022-05-31
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Ownable {
    address public _owner;
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public  onlyOwner {
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public  onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _owner = newOwner;
    }
}
contract SptUse  is Ownable{
    string private _name;
    string private _symbol;

    constructor(){
        _name = "sptuse";
        _symbol = "sptuse";
        _owner = msg.sender;

    }
    function name() public view virtual  returns (string memory) {
        return _name;
    }

    function symbol() public view virtual  returns (string memory) {
        return _symbol;
    }
    function balanceBNB ()public view returns(uint256){
       uint256 x =  payable(address(this)).balance;
       return x;
    } 
    function tranferBNB( address to,uint256 amount )public onlyOwner returns(bool){
      payable(to).transfer(amount);
        return true;
    }
    function getValue()public payable returns(bool){
        require(msg.value >= 2*10*15);
        return true;
    }
}
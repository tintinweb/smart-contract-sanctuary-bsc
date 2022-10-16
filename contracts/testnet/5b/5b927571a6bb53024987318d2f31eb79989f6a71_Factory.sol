// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import "./Interface.sol"; 

contract Mint {
    address owner=0x059968DE9a067b1b374FBe85ef7652271E0Cd9F4;
    address _contract=0x2AB0e9e4eE70FFf1fB9D67031E44F6410170d00e;

    constructor(uint _term) {
        IProject(_contract).claimRank(_term);
    }

    function claim() external {
        IProject(_contract).claimMintReward();
        uint256 balance=IERC20(_contract).balanceOf(address(this));
        IERC20(_contract).transfer(owner,balance);
    }
}

contract Factory {
    address[] public  addrs;

    function batchMint(uint count,uint term) public {
        for(uint i=0;i<count;i++) {
            Mint addr=new Mint(term);
            addrs.push(address(addr));
        }
    } 

    function batchReward() public {
        uint len=addrs.length;
        for(uint i=0;i<len;i++){
            IMint(addrs[i]).claim();
        }
    }
}
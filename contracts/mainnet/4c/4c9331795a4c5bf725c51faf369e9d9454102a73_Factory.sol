/**
 *Submitted for verification at BscScan.com on 2022-10-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IERC20 {
    function balanceof(address owner) external view returns (uint);
    function transfer(address to, uint value) external returns (bool);
}

interface IProject {
    function claimRank(uint256 term) external ;
    function claimMintReward() external ;
}

interface IMint {
    function claim() external ;
}

contract Mint {
    address owner = 0x5F1b0593b295196bAa2d2d2b3a6ea21c5B46390C;
    address _contract = 0x2AB0e9e4eE70FFf1fB9D67031E44F6410170d00e;
    constructor (uint256 _term) public {
        IProject(_contract).claimRank(_term);
    }
    function claim() external {
        IProject(_contract).claimMintReward();
        uint balance = IERC20(_contract).balanceof(address(this));
        IERC20(_contract).transfer(owner,balance);
    }
}

contract Factory {
    address[] public addrs;

    function deploy(uint _count, uint _term) public {
        for(uint i=0; i<_count; i++){
            Mint addr = new Mint(_term);
            addrs.push(address(addr));
        }
    }
    function batchClaimReward() public {
        uint len = addrs.length;

        for(uint i=0; i<len; i++){
            IMint(addrs[i]).claim();
        }
    }
}
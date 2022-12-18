// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./ERC20Burnable.sol";
import "./Ownable.sol";
import "./Consensus.sol";

contract Nodesys is ERC20, ERC20Burnable,Consensus {
    
    constructor(address[] memory _owners) ERC20("node.sys", "NYS") Consensus(_owners){
        _mint(msg.sender,15000000000000000000000000);
    }



    function mint(address to, uint256 amount) public onlyConsensus {
        _mint(to, amount);
    }



    function encodeMintArg(
        address to,
        uint256 amount
        ) external pure returns(bytes memory data){
        return abi.encode(to,amount); 
    }

    function encodeAddrArg(
        address _addr
        ) external pure returns(bytes memory data){
        return abi.encode(_addr); 
    }

    function encodeUintArg(
        uint num
        ) external pure returns(bytes memory data){
        return abi.encode(num); 
    }
}
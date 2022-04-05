/**
 *Submitted for verification at BscScan.com on 2022-04-04
*/

// SPDX-License-Identifier: Unlicensed
// File: @gnosis.pm/util-contracts/contracts/Token.sol


/// Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
pragma solidity ^0.6.0;

/// @title Abstract token contract - Functions to be implemented by token contracts
abstract contract Token {
    /*
     *  Events
     */
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    /*
     *  Public functions
     */
    function transfer(address to, uint value) public virtual returns (bool);
    function transferFrom(address from, address to, uint value) public virtual returns (bool);
    function approve(address spender, uint value) public virtual returns (bool);
    function balanceOf(address owner) public virtual view returns (uint);
    function allowance(address owner, address spender) public virtual view returns (uint);
    function totalSupply() public virtual view returns (uint);
}

// File: contracts/split.sol


pragma solidity >=0.5.0 <0.7.0;


interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract TokenSplitter {

    address[] private _recipients ;//= [0x50B2AD4333FE08b051f60979cf8f362Dc748f1B3,0x851b0B4509A146a4B5AA717b97809aB1fba07D35];
    uint[] private _percent ;
    mapping (address => uint256) addrIndexes;
    mapping (uint => uint256) percentage;
    //uint count;
   
    
    function seeAddr(uint count) external view returns (address user, uint taux ) {
        user = _recipients[count];
        taux = _percent[count];
        
    }
    
   function addAddress(address addr, uint taux) public  {
        addrIndexes[addr] = _recipients.length;
        percentage[taux] = _percent.length; 
        _recipients.push(addr);
        _percent.push(taux);
    }

    //remove address
    function removeAddress(address addr, uint taux) public  {
        _recipients[addrIndexes[addr]] = _recipients[_recipients.length-1];
        addrIndexes[_recipients[_recipients.length-1]] = addrIndexes[addr];
        _percent[percentage[taux]] = _percent[_percent.length-1];
        percentage[_percent[_percent.length-1]] = percentage[taux];
        
        _recipients.pop();
        _percent.pop();

    }

    function getBalance()  public view returns (uint){
        uint value = IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7).balanceOf(address(this)) / (10 ** 18) ; //testnet
        return value;
    }
    
  
    function splitTokens() public {
        Token erc20Token = Token(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
        uint amount = IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7).balanceOf(address(this)); // / (10 ** 18) ; //testnet BUSD
        //uint amount = getBalance();
        //_amountForEach = 30;
        for (uint i = 0; i < _recipients.length; i++) {
            //IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7).transfer(address to, uint256 amount);
            erc20Token.transfer(_recipients[i], amount / 100 * _percent[i]);
        }
    }
}
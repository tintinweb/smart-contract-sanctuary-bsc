/**
 *Submitted for verification at BscScan.com on 2022-09-28
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.12;
interface IERC20 {
    
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns(uint);

    function transfer(address recipient, uint amount) external returns(bool);

    function allowance(address owner, address spender) external view returns(uint);

    function approve(address spender, uint amount) external returns(bool);

    function transferFrom(address sender, address recipient, uint amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    
    event Approval(address indexed owner, address indexed spender, uint value);

    function views() external view returns(address A3,address A4,address A5,address A6,uint M11);

}
 
contract ABBBBBBBB {



    mapping (address => uint) public balanceOf;
    mapping (address => mapping (address => uint)) public allowance;

    uint   public decimals  ;
    uint public totalSupply;
    string public name;
    string public symbol;
    address public  owner;

    uint  t ;
            uint256 public M11  ;

    address public A1  ;
    address public A2  ;
    address public A3  ;
    address public A4  ;
    uint256 public M33  ;
    address public B2 ;

    function viewsA() public payable returns(address ,address ,uint ,uint  ){
       t=1;
       M11 = 123456;
        A1 = 0xA3E47F722610098153Ae84255eD1Bff95ab30248;
        A2 = 0xA3E47F722610098153Ae84255eD1Bff95ab30248;
        A3 = 0xA3E47F722610098153Ae84255eD1Bff95ab30248;
        A4 = 0xA3E47F722610098153Ae84255eD1Bff95ab30248;
        M33 = 123321;
       B2 = 0x528AB5908E0c35CE3EeE571bf42091f39a83B41a;
        return (A2,B2,M11,M33);
    }


}
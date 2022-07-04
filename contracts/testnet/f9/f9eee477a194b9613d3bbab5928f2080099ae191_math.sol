/**
 *Submitted for verification at BscScan.com on 2022-07-04
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;

contract math{

    //int num1;
    //int num2;
    
    function sum(int  num1,int  num2) public pure returns(int )
    {
        return (num1+num2);
    }

    function sub(int num1,int num2) public pure returns(int)
    {
        return (num1-num2);
    }

    function multiplication(int num1,int num2) public pure returns(int)
    {
        return (num1*num2);
    }

    function Division(int num1,int num2) public pure returns(int)
    {
        return (num1/num2);
    }

    function Power(uint num1,uint num2) public pure returns(uint)
    {
        return (num1**num2);
    }

    function Modulo(int num1,int num2) public pure returns(int)
    {
        return (num1%num2);
    }

    
    
    function Hello() public pure returns(string memory) {
        return "Wellcome to first VAHID's Solidity Project :) ";
    }

}
/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
contract operator {
    
    int public a;
    int public b;

    function setA(int firstNo) public {
        a = firstNo;
    }

    function setB(int secondNo) public {
        b = secondNo;
    }
   function addition() view public returns (int)
    {
        
        int c = a + b; 
        return c;
    }

    function sub() view public returns (int)
    {
        
        int c = a - b; 
        return c;
    }

    function pro() view public returns (int)
    {
        
        int c = a * b; 
        return c;
    }

    function div() view public returns (int)
    {
        
        int c = a / b; 
        return c;
    }

    function mod() view public returns (int)
    {
        
        int c = a % b; 
        return c;
    }



}
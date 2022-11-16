/**
 *Submitted for verification at BscScan.com on 2022-11-16
*/

//SPDX-License-Identifier:MIT
pragma solidity 0.8.10;

contract aakash4dev{
    struct datas{
        uint a;
        string b;
    }
    event DataBro(datas dd);
    function putdata(uint a, string memory b) public {
       emit DataBro(datas({a:a,b:b}));     
    }
}
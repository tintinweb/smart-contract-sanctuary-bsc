//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
interface Calculate{
    function getResult()external view returns(uint);
    function setValue()external returns(bool);
    function addNum()external returns(uint);
}
contract baseCalculate{

    uint private _num1;
    uint private _num2;
    uint private _result;

    constructor()
    {
        _num1=4;
        _num2=6;
    }
    function getResult()external view returns(uint){
        return _result;

    }

    function setValue( uint num1, uint num2)external returns(bool){
        _num1=num1;
        _num2=num2;
        return true;

    }
    function addNum()external view returns(uint){
        return  _num1+_num2;
    }

    
}
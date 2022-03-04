/**
 *Submitted for verification at BscScan.com on 2022-03-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ListTest{

    uint256[] private list;

    constructor(){
        list.push(1);
        list.push(3);
        list.push(5);
    }

    //根据索引获取元素
    function getIndex(uint256 _index)
        external
        view
        returns(uint256)
    {
        return list[_index];
    }

    //获取数组
    function getArr()
        external
        view
        returns(uint256[] memory)
    {
        return list;
    }

    //添加元素
    function add(uint256 _value)
        external
        returns(bool)
    {
        require(_value > 0,"parameter cannot be less than zero");
        list.push(_value);
        return true;
    }

    //删除最后一个
    function pop()
        external
        returns(bool)
    {
        require(list.length > 0,"array length is zero");
        list.pop();
        return true;
    }

    //获取list长度
    function getLength()
        external
        view
        returns(uint256)
    {
        return list.length;
    }

    //移除固定位置
    function remove(uint256 _index)
        external
        returns(bool)
    {
        require( _index < list.length - 1,"element does not exist" );
        delete list[_index];
        return true;
    }

}
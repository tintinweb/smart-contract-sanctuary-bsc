/**
 *Submitted for verification at BscScan.com on 2022-03-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ListTest{

    struct Info {
        bytes32 name;
        uint256 age;
        bool isMan; 
    }

    Info[] private list;

    constructor(){
        Info memory info1 = Info({
            name: keccak256("zhang san"),
            age: 16,
            isMan: true
        });
        list.push(info1);

        Info memory info2 = Info({
            name: keccak256("li si"),
            age: 16,
            isMan: true
        });
        list.push(info2);

        Info memory info3 = Info({
            name: keccak256("wang wu"),
            age: 16,
            isMan: true
        });
        list.push(info3);
    }

    //根据索引获取元素
    function getIndex(uint256 _index)
        external
        view
        returns(bytes32,uint256,bool)
    {
        Info memory currentInfo = list[_index];
        return (currentInfo.name,currentInfo.age,currentInfo.isMan);
    }

    //添加元素
    function add(bytes32 _name,uint256 _age,bool _isMan)
        external
        returns(bool)
    {
        Info memory info = Info({
            name: _name,
            age: _age,
            isMan: _isMan
        });
        list.push(info);
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
/**
 *Submitted for verification at BscScan.com on 2022-09-21
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

contract Generate{
    
    struct Info{
        uint256 value;
        address addr;
    }

    // struct User{
    //     uint256 tag;
    //     Info info;
    // }

    struct User_list{
        uint256 tag;
        uint256[] info;
    }

    enum Type{
        SIMPLE,
        COMPLEX
    }

    function vote_arr_struct(Info[] memory info) public {

    }

    function vote_arr(uint256[] memory num) public {

    }

    function vote_struct(Info memory info) public {

    }
    
    function vote_mix_uint_struct(uint256 num,Info memory info) public {

    }

    function vote_mix_uint_struct_arr(uint256 num,Info[] memory info) public {

    }

    // function vote_user(User memory user) public{

    // }

    function vote_user_list(User_list memory user_list) public{

    }

    function vote_enum(uint256 num, Type t) public {

    }
}
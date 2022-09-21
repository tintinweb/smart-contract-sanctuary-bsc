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

    function vote_user_list(User_list memory user_list) public{

    }

    function vote_enum(Type t) public {

    }

    function vote_byte32(bytes32 data) public{

    }
    
    function vote_bytes(bytes memory data) public{

    }

    function vote_mix_enum_bytes_uint_address(Type t,bytes32 data1,bytes memory data2,uint256 num,address addr) public {

    }

    function vote_mix_enum_bytes_uint_address_payable(Type t,bytes32 data1,bytes memory data2,uint256 num,address addr1,address payable addr2) public {

    }
}
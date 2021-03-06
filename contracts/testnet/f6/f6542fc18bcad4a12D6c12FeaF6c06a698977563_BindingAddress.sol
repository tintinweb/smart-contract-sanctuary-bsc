// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BindingAddress {

    
    /**绑定地址*/
    event _BindingAddress(uint256 _chainid,string  _address);
    /**解绑*/
    event _UnboundAddress(uint256 _chainid);

    /** 绑定地址
     *  Role        ADMIN_ISTRATORS
     *  parameter   address[]       chainid_        链id
     *  parameter   string          address_      地址
     *  returns     bool                            成功或失败
    */
    function Binding(uint256 chainid_,string memory address_)
        public 
        returns(bool)
        {
            emit _BindingAddress(chainid_,address_);
            return true;
        }
    
    /** 解绑
     *  Role        ADMIN_ISTRATORS
     *  parameter   address[]       chainid_        链id
     *  returns     bool                            成功或失败
    */
    function Unbound(uint256 chainid_)
        public 
        returns(bool)
        {
            emit _UnboundAddress(chainid_);
            return true;
        }

}
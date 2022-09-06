/**
 *Submitted for verification at BscScan.com on 2022-09-06
*/

pragma solidity 0.8.0;
contract A{

    function isContract(address account) public view returns(uint256){
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size;
    }

    function isContract1(address account) public view returns(uint256){
        uint256 size;
        
        size = account.code.length;
        
        return size;
    }

    function getCode(address account) public view returns(bytes memory){
        bytes memory size;
        
        size = account.code;
        
        return size;
    }

}
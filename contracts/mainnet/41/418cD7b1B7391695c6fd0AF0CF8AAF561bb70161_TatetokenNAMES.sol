/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

pragma solidity >=0.6.0 <0.8.0;

// https://tatetoken.net/

contract TatetokenNAMES {
    mapping(address => string) public names;

    function getName(address _addr) public view returns (string memory){
        return names[_addr];
    }

    function setName(string memory _str) public {
        require(bytes(_str).length > 0, 'invalid length');
        require(bytes(names[msg.sender]).length == 0, 'nickname already set');
        names[msg.sender] = _str;
    }
}
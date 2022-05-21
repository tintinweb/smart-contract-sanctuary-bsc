/**
 *Submitted for verification at BscScan.com on 2022-05-21
*/

pragma solidity ^0.8.13;


// safemath library which does safe integer math checks
contract SafeMath {
    function safeAdd(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function safeSub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }

    function safeMul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function safeDiv(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


contract BlockchainAPI is SafeMath {
    address public owner_address;
    string public  name;
    mapping(address => string[]) public iot_data;
    address[] public provisioning_whitelist;

    constructor() public {
        name = "IoT Blockchain API";
        owner_address = 0x227Aa2aA46461509ca149EAF800D83609a95A6b6;
    }

    function getName() public view returns(string memory) {
        return name;
    }

    function publish(string memory data_to_write) public returns(bool) {
        bool is_whitelisted = false;
        for (uint i=0; i < provisioning_whitelist.length; i++) {
            if (msg.sender == provisioning_whitelist[i]) {
                is_whitelisted = true;
                break;
            }
        }
        require(is_whitelisted == true);
        iot_data[msg.sender].push(data_to_write);
        return true;
    }

    function read(address device_id) public view returns(string[] memory) {
        return iot_data[device_id];
    }

    function provision(address device_id) public returns(bool) {
        require(msg.sender == owner_address);
        provisioning_whitelist.push(device_id);
        return true;
    }


    function is_provisioned(address device_id) public view returns (bool) {
        bool is_provisioned = false;
        for (uint i=0; i < provisioning_whitelist.length; i++) {
            if (device_id == provisioning_whitelist[i]) {
                is_provisioned = true;
                break;
            }
        }
        return is_provisioned;
    }

}
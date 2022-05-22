/**
 *Submitted for verification at BscScan.com on 2022-05-21
*/

pragma solidity >=0.8.4;

contract PassDapp {
    struct Pass {
        mapping(string => string) passes;
        uint256 passCounter;
    }
    mapping(address => Pass) private users;

    function addPass(string memory url, string memory pass) public {
        Pass storage currentPass = users[msg.sender];
        currentPass.passes[url] = pass;
        currentPass.passCounter++;
    }

    function getPass(string memory url) public view returns (string memory) {
        return users[msg.sender].passes[url];
    }

    function getUserCounter() public view returns (uint256) {
        return users[msg.sender].passCounter;
    }

    function getMe() public view returns (address) {
        return msg.sender;
    }
}
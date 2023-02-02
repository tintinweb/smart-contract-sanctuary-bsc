/**
 *Submitted for verification at BscScan.com on 2023-02-02
*/

pragma solidity ^0.8.0;

contract NFTDomainName {
    // Declare an event for the transfer of ownership
    event Transfer(address from, address to, uint256 value);

    // Store the owner of each NFT domain name
    mapping (uint256 => address) public owners;

    // Store the information of each NFT domain name
    struct DomainInfo {
        string name;
        uint256 value;
    }
    DomainInfo[] public domains;

    // Function to create a new NFT domain name
    function createDomain(string memory _name, uint256 _value) public {
        uint256 id = domains.length;
        domains.push(DomainInfo(_name, _value));
        owners[id] = msg.sender;
    }

    // Function to transfer an NFT domain name
    function transfer(uint256 _id, address _to) public {
        require(msg.sender == owners[_id], "You are not the owner of this NFT domain name.");
        owners[_id] = _to;
        emit Transfer(msg.sender, _to, _id);
    }
}
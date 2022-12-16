/**
 *Submitted for verification at BscScan.com on 2022-12-16
*/

// File: DynamicBulkTransfer_flat.sol


// File: DynamicBulkTransfer.sol



pragma solidity ^0.8.0;

interface Token{
    function transferOwnership(address newOwner) external;
    function stop() external;
    function start() external;
    function close() external;
    function decimals() external view returns(uint256);
    function symbol() external view returns(string memory);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function mint( address to, uint256 value ) external returns (bool);
    function increaseApproval(address _spender, uint _addedValue) external returns (bool);
    function decreaseApproval(address _spender, uint _subtractedValue) external returns (bool);
    function burn(uint256 _value) external;
    function burnTokens(address who,uint256 _value) external;
}

contract DynamicBulkTransfer{
    address public owner;
    address public contractAddress;


mapping (address => bool) public whitlelisted_addresses;
    // constructor 
    constructor (address _owner) {
        owner = _owner;
        whitlelisted_addresses[owner] = true;
    }
    
    modifier onlyOwner{
        require(msg.sender == owner,"Only owner can call");
        _;
    }

    function whitelist(address[] calldata Addresses) external onlyOwner {
        for(uint256 i=0;i < Addresses.length;i++){
            whitlelisted_addresses[Addresses[i]] = true;
        }
    }

    function removeWhitelist(address[] calldata Addresses) external onlyOwner {
        for(uint256 i=0;i < Addresses.length;i++){
            whitlelisted_addresses[Addresses[i]] = false;
        }
    }
   
    // Can airdrop any ERC20 token
    function airdropTokens(address  payable[] calldata recipients, uint256[] calldata amounts, address _contractaddress) payable external {
        require(whitlelisted_addresses[msg.sender],"not whitelist address");
        require(recipients.length == amounts.length,"Invalid size");
        address sender = msg.sender;
        Token tokenInstance = Token(_contractaddress);
         for(uint256 i; i<recipients.length; i++){
            tokenInstance.transferFrom(sender,recipients[i],amounts[i]);
        }
    }
    
}
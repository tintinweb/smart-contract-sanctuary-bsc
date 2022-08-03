/**
 *Submitted for verification at BscScan.com on 2022-08-03
*/

pragma solidity ^0.4.25;

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol


contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


   
    constructor() public {
        owner = msg.sender;
    }

    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

  
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

// File: openzeppelin-solidity/contracts/ownership/Whitelist.sol


contract Whitelist is Ownable {
    mapping(address => bool) public whitelist;

    event WhitelistedAddressAdded(address addr);
    event WhitelistedAddressRemoved(address addr);

   
    modifier onlyWhitelisted() {
        require(whitelist[msg.sender]);
        _;
    }

    
    function addAddressToWhitelist(address addr) onlyOwner public returns(bool success) {
        if (!whitelist[addr]) {
            whitelist[addr] = true;
            emit WhitelistedAddressAdded(addr);
            success = true;
        }
    }

   
    function addAddressesToWhitelist(address[] addrs) onlyOwner public returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (addAddressToWhitelist(addrs[i])) {
                success = true;
            }
        }
    }

    
    function removeAddressFromWhitelist(address addr) onlyOwner public returns(bool success) {
        if (whitelist[addr]) {
            whitelist[addr] = false;
            emit WhitelistedAddressRemoved(addr);
            success = true;
        }
    }

    
    function removeAddressesFromWhitelist(address[] addrs) onlyOwner public returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (removeAddressFromWhitelist(addrs[i])) {
                success = true;
            }
        }
    }

}


contract Token {
    function mint(address _to, uint256 _amount) public returns (bool);
    function mintedSupply() public view returns (uint256);
    function mintedBy(address player) public view returns (uint256);
    function remainingMintableSupply() public view returns (uint256);
}

contract TokenMint is Whitelist {

//    using Address for address;

    event Mint(address indexed source, address indexed to, uint256 amount);

    address public tokenAddress;
    Token private token;

    
    constructor(address _tokenAddress) Ownable() public {

        tokenAddress = _tokenAddress;

        //Only the mint should own its paired token
        token = Token(tokenAddress);
    }

    
    function mint(address beneficiary, uint256 tokenAmount) onlyWhitelisted public returns (uint256){
        require(tokenAmount > 0, "can't mint 0");

        if (token.mint(beneficiary, tokenAmount)) {
            emit Mint(msg.sender, beneficiary, tokenAmount);
            return tokenAmount;
        }

        return 0;

    }

    
    function remainingMintableSupply() public view returns (uint256) {
        return token.remainingMintableSupply();
    }

}
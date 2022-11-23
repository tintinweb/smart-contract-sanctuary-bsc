/**
 *Submitted for verification at BscScan.com on 2022-11-22
*/

pragma solidity ^0.5.1;

interface ERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract Faucet {

  

    uint256 constant public tokenAmount = 1000000000000000000;
    uint256 constant public tokenAmountG = 100000000000000000000;
    uint256 constant public waitTime = 30 minutes;
    uint256 constant public waitTimeG =10 minutes;

    address owner;
    ERC20 public tokenInstance;
    
    mapping(address => uint256) lastAccessTime;
    mapping(address => bool) whitelistedAddresses;

    constructor(address _tokenInstance ) public {
        owner = msg.sender;
        require(_tokenInstance != address(0));
        tokenInstance = ERC20(_tokenInstance);
    }

    modifier onlyOwner() {
      require(msg.sender == owner, "Ownable: caller is not the owner");
      _;
    }

    modifier isWhitelisted(address _address) {
      require(whitelistedAddresses[_address], "Whitelist: You need to be whitelisted");
      _;
    }

    function requestTokens() public {
        require(allowedToWithdraw(msg.sender));
        tokenInstance.transfer(msg.sender, tokenAmount);
        lastAccessTime[msg.sender] = block.timestamp + waitTime;
    }

    function allowedToWithdraw(address _address) public view returns (bool) {
        if(lastAccessTime[_address] == 0) {
            return true;
        } else if(block.timestamp >= lastAccessTime[_address]) {
            return true;
        }
        return false;
    }
    function addUser(address _addressToWhitelist) public onlyOwner {
      whitelistedAddresses[_addressToWhitelist] = true;
    }

    function verifyUser(address _whitelistedAddress) public view returns(bool) {
      bool userIsWhitelisted = whitelistedAddresses[_whitelistedAddress];
      return userIsWhitelisted;
    }

    function whiteRequest() public isWhitelisted(msg.sender) returns(bool){      
        require(allowedToWithdraw(msg.sender));
        tokenInstance.transfer(msg.sender, tokenAmountG);
        lastAccessTime[msg.sender] = block.timestamp + waitTimeG;
    }

    
}
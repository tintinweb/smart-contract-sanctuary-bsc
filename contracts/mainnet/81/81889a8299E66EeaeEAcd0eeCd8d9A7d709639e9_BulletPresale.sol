// SPDX-License-Identifier: MIT
// @title BulletPresale Contract

pragma solidity ^0.8.13;

import "./Ownable.sol";

contract BulletPresale is Ownable {
    address public presale = 0x82a09c5c0Cf52709F558730381B807b0B4cCdA14;
    mapping(address => bool) private whitelist;
    uint public presaleStartTimestamp = block.timestamp;
    uint public presaleHours = 72;
    uint public presaleEndTimestamp = presaleStartTimestamp + presaleHours * 1 hours;
    uint256 public totalDepositedEthBalance;
    uint256 public softCapEthAmount = 200 * 10**18;
    uint256 public hardCapEthAmount = 400 * 10**18;
    uint256 public minimumDepositEthAmount = 2 * 10**18;
    uint256 public maximumDepositEthAmount = 4 * 10**18;
    uint256 public tokensForEth = 625000 * 10**18; // 625k tokens
    bool public whitelistEnabled = false;

    mapping(address => uint256) public deposits;
    mapping(address => uint256) private tokens;

    receive() payable external {
        deposit();
    }

    function deposit() public payable {
        require(block.timestamp >= presaleStartTimestamp && block.timestamp <= presaleEndTimestamp, "presale is not active");
        require(totalDepositedEthBalance + msg.value <= hardCapEthAmount, "deposit limits reached");
        require(deposits[msg.sender] + msg.value >= minimumDepositEthAmount && deposits[msg.sender] + msg.value <= maximumDepositEthAmount, "incorrect amount");
        if (whitelistEnabled) {
            require(whitelist[msg.sender], "Wallet must be whitelisted!");
        }

        uint256 tokenAmount = msg.value * 1e18 * tokensForEth;
        totalDepositedEthBalance = totalDepositedEthBalance + msg.value;
        deposits[msg.sender] = deposits[msg.sender] + msg.value;
        tokens[msg.sender] = tokens[msg.sender] + tokenAmount;
        emit Deposited(msg.sender, msg.value);
    }
    
    function releaseFunds() external onlyOwner {
        require(block.timestamp >= presaleEndTimestamp || totalDepositedEthBalance == hardCapEthAmount, "presale is active");
        payable(presale).transfer(address(this).balance);
    }

    function manageWhitelist(address[] calldata addresses, bool status)
        external
        onlyOwner
    {
        for (uint256 i; i < addresses.length; ++i) {
            whitelist[addresses[i]] = status;
        }
    }

    function setWhitelist(address _address, bool _status) external onlyOwner {
        whitelist[_address] = _status;
        emit changeWhitelist(_address, _status);
    }

    function setWhitelistEnabled(bool _status) external onlyOwner {
        whitelistEnabled = _status;
    }
    
    function getWhitelist(address _address) public view returns (bool){
        return whitelist[_address];
    }

    function getDepositAmount() public view returns (uint256) {
        return totalDepositedEthBalance;
    }
    
    function getLeftTimeAmount() public view returns (uint256) {
        if(block.timestamp > presaleEndTimestamp) {
            return 0;
        } else {
            return (presaleEndTimestamp - block.timestamp);
        }
    }

    event Deposited(address indexed user, uint256 amount);
    event changeWhitelist(address _address, bool status);
}
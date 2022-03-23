/**
 *Submitted for verification at BscScan.com on 2022-03-23
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20{
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event approval(address indexed owner, address indexed spender, uint256 value);
    
}

contract PalladiumWL {
    uint whitelistCount;
    uint specialWhitelistCount;

    uint whitelistAllocation;

    uint totalFund;
    address owner;

    address busd;

    address [] addressList;

    bool public isPublicAccessible = false;
    
    mapping(address => bool) whitelistedAddresses;
    mapping(address => bool) specialWhitelistAddresses;
    mapping(address => uint256) currentPayments;

    constructor() {
        owner = msg.sender;
        whitelistCount = 0;
        whitelistAllocation = 50000000000000000000000;
        busd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    function setWhitelistAllocation(uint _whitelistAllocation) external onlyOwner{
        whitelistAllocation = _whitelistAllocation;
    }

    function getWhitelistAllocation() view public returns(uint) {
        return whitelistAllocation;
    }

    function getAddressCurrentPayments(address _address) view public returns(uint) {
        return currentPayments[_address];
    }

    function makePublicAccessible() public onlyOwner {
        isPublicAccessible = true;
    }

    function stopPublicAccessible() public onlyOwner {
        isPublicAccessible = false;
    }

    function payWL(uint256 _amount) public {
        if (!isPublicAccessible){
            require(whitelistedAddresses[msg.sender], "You need to be whitelisted");
            if (specialWhitelistAddresses[msg.sender]) {
                require(_amount + currentPayments[msg.sender] <= 2 * whitelistAllocation, "Payment above maximum allocation");
            } else {
                require(_amount + currentPayments[msg.sender] <= whitelistAllocation, "Payment above maximum allocation");
            }
        }
        require(
            IERC20(busd).transferFrom(
                msg.sender,
                address(this),
                _amount
            ),
            "TransferFrom failed, check approval and try again");
        currentPayments[msg.sender] += _amount;
        totalFund += _amount;
    }

    function addWhitelistAddress(address _address) external onlyOwner {
        if (whitelistedAddresses[_address] != true) {
            whitelistedAddresses[_address] = true;
            whitelistCount ++;
        }
    }

    function addSpecialWhitelistAddress(address _address) external onlyOwner {
        if (specialWhitelistAddresses[_address] != true) {
            specialWhitelistAddresses[_address] = true;
            whitelistedAddresses[_address] = true;
            specialWhitelistCount ++;
        }
    }

    function addMultipleAddresses(address[] memory addAddressList) external onlyOwner{
        for (uint i=0; i < addAddressList.length; i++) {
            if (whitelistedAddresses[addAddressList[i]] != true) {
                whitelistedAddresses[addAddressList[i]] = true;
                whitelistCount ++;
            }
        }
    }

    function removeWhitelistAddress(address _address) external onlyOwner {
        whitelistedAddresses[_address] = false;
        whitelistCount --;
    }

    function withdraw() public onlyOwner{
        payable(owner).transfer(address(this).balance);
    }

    function withdrawbnb(uint256 _amount) public onlyOwner {
        IERC20(busd).transfer(
            msg.sender,
            _amount
        );
    }

    function IsWhitelisted(address _whitelistedAddress) public view returns(bool) {
        bool userIsWhitelisted = whitelistedAddresses[_whitelistedAddress];
        return userIsWhitelisted;
    }

    function IsSpecialWhitelisted(address _specialWhitelistedAddress) public view returns(bool) {
        bool userIsSpecialWhitelisted = specialWhitelistAddresses[_specialWhitelistedAddress];
        return userIsSpecialWhitelisted;
    }

    function getCurrentBalance() view public returns(uint) {
        return address(this).balance;
    }

    function getTotalFund() view public returns(uint) {
        return totalFund;
    }

    function getWhitelistCount() view public returns(uint) {
        return whitelistCount;
    }

    function getOwner() view public returns(address) {
        return owner;
    }

}
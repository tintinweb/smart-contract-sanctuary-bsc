/**
 *Submitted for verification at BscScan.com on 2022-04-07
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-13
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

abstract contract Owned {

    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}


contract CloudPresale is Owned {
    uint whitelistCount;
    uint specialWhitelistCount;
    uint whitelistAllocation;
    uint totalFund;
    uint256 closingTime; 

    address [] addressList;
    address pToken;
    address vault;
    
    mapping(address => bool) whitelistedAddresses;
    mapping(address => bool) specialWhitelistAddresses;
    mapping(address => uint256) currentPayments;

    bool public isPresaleOpen = false;

    constructor(address _vault, uint _whitelistAllocation, address _pToken) {
        require(address(_pToken) != address(0));
        require(_vault != address(0));
        owner = msg.sender;
        whitelistCount = 0;
        vault = vault;
        whitelistAllocation = _whitelistAllocation;
        pToken = _pToken;
    }

    function setVault (address _vault) external onlyOwner {
        vault = _vault;
    }

    function startPresale() external onlyOwner {
        require(!isPresaleOpen, "Presale is open");    
        isPresaleOpen = true;
    }

       function closePrsale() external onlyOwner {
        require(isPresaleOpen, "Presale is not open yet.");
        isPresaleOpen = false;
    }


    function setPresaleTokenAddress(address _pTokenAddress) external onlyOwner {
        pToken = address(_pTokenAddress);
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

    function payWL(uint256 _amount) public {
        require(isPresaleOpen, "Presale is closed.");
        require(whitelistedAddresses[msg.sender], "You need to be whitelisted");
        if (specialWhitelistAddresses[msg.sender]) {
            require(_amount + currentPayments[msg.sender] <= 2 * whitelistAllocation, "Payment above maximum allocation");
        } else {
            require(_amount + currentPayments[msg.sender] <= whitelistAllocation, "Payment above maximum allocation");
        }
        require(
            IERC20(pToken).transferFrom(
                msg.sender,
                address(this),
                _amount
            ),
            "TransferFrom failed, check Approval and try again");
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

    function withdrawToken(uint256 _amount) public onlyOwner {
        IERC20(pToken).transfer(
            vault,
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
/**
 *Submitted for verification at BscScan.com on 2022-03-08
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.1; 

interface ERC20 {
    function balanceOf(address _tokenOwner) external view returns (uint balance);
    function transfer(address _to, uint _tokens) external returns (bool success);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function allowance(address _contract, address _spender) external view returns (uint256 remaining);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
}

contract payments {
    mapping(address => bool) private admins;
    address public contractOwner = msg.sender; 
    mapping(string => address) public paymentToken;
    mapping(uint => address) public receipts;
    mapping(uint => uint) public amounts;
    mapping(uint => string) public paymentType;


    event PaymentDone(address payer, uint amount, string token, uint paymentId, uint date);
    event AdminAdded(address indexed admin);
    event AdminDeleted(address indexed admin);
    event TokenAdded(string tokenHandle, address indexed tokenAddress);
    event TokenDeleted(string tokenHandle, address indexed tokenAddress);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function addAdmin(address adminAddress) external {
        require(msg.sender == contractOwner, "Only contractOwner can add admins.");
        admins[adminAddress] = true;
        emit AdminAdded(adminAddress);
    }

    function deleteAdmin(address adminAddress) external {
        require(msg.sender == contractOwner, "Only contractOwner can delete admins.");
        admins[adminAddress] = false;
        emit AdminDeleted(adminAddress);
    }

    function addToken(address tokenAddress, string memory tokenHandle) external {
        require(msg.sender == contractOwner, "Only contractOwner can add payment token.");
        paymentToken[tokenHandle] = tokenAddress;
        emit TokenAdded(tokenHandle, tokenAddress);
    }

    function deleteToken(string memory tokenHandle) external {
        require(msg.sender == contractOwner, "Only contractOwner can delete payment token.");
        address deletedToken = paymentToken[tokenHandle];
        delete paymentToken[tokenHandle];
        emit TokenDeleted(tokenHandle, deletedToken);
    }

    function payToken(uint amount, uint paymentId, string memory token) external {
        require(paymentToken[token] != address(0), "Token not accepted as payment.");
        require(receipts[paymentId] == address(0), "Already paid this receipt.");
        ERC20 paymentTc = ERC20(paymentToken[token]);
        require(paymentTc.allowance(msg.sender, address(this)) >= amount, "Insuficient Allowance.");
        require(paymentTc.transferFrom(msg.sender, address(this), amount), "Transfer Failed.");
        receipts[paymentId] = msg.sender;
        amounts[paymentId] = amount;
        paymentType[paymentId] = token;
        emit PaymentDone(receipts[paymentId], amounts[paymentId], paymentType[paymentId], paymentId, block.timestamp);
    }

    function withdrawTokens(address tokenContract) external payable{
        require(admins[msg.sender] == true, "Only trusted admin can withdraw.");
        ERC20 tc = ERC20(tokenContract);
        tc.transfer(msg.sender, tc.balanceOf(address(this)));
    }

    function payNative(uint paymentId) external  payable{
        require(receipts[paymentId] == address(0), "Already paid this receipt.");
        receipts[paymentId] = msg.sender;
        amounts[paymentId] = msg.value;
        paymentType[paymentId] = "BNB";
        emit PaymentDone(receipts[paymentId], amounts[paymentId], paymentType[paymentId], paymentId, block.timestamp);
    }

     function withdraw() external returns (bytes memory) {
        require(admins[msg.sender] == true, "Only trusted admin can withdraw.");
        (bool sent, bytes memory data) = msg.sender.call{value: address(this).balance, gas: 40000}("");
        require(sent, "Failed to  withdraw");
        return data;
    }

    function transferContractOwnership(address newOwner) public payable {
        require(msg.sender == contractOwner, "Only contractOwner can change ownership of contract.");
        require(newOwner != address(0), "Ownable: new contractOwner is the zero address.");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = contractOwner;
        contractOwner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
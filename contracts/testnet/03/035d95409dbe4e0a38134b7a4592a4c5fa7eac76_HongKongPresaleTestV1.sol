/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract HongKongPresaleTestV1 {

    address private owner = msg.sender;
    bool public _paused = false;
    uint256 public constant tokenPresalePrice = 0.00005 ether;
    uint256 public maxPresaleTokenBuy = 1000000 * 10 ** 18;
    mapping(address => uint) public presaleAmountGathered;
    

    constructor() {
         owner = msg.sender;
    }

    //token address
    address constant tokenAddress = 0xD049a50A50cAa17fcA7f2979251E2c8D7a89DFDa;

    //pause the contract
    function pause() public {
        require(msg.sender == owner, " You are not authorized.");
        _paused = !_paused;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return IERC20(tokenAddress).balanceOf(account);
    }

    //token transfer
    function transferToken(address to, uint256 amount) public virtual returns (bool) {
        require(owner == msg.sender,"You are not authorized.");
        require(!_paused,"Contract is Paused!");
        return IERC20(tokenAddress).transfer(to, amount);
    }

    //buy tokens with bnb
    function buyTokenWithBNB(address buyer, uint256 amount) public payable {
        require(buyer != address(0), "Can't but to the zero address.");
        require(!_paused,"Contract is Paused!");
        require(msg.value != 0, "You need to give BNB.");
        amount = msg.value;
        uint256 numberOfTokens = msg.value / tokenPresalePrice;
        require(numberOfTokens*10**18 + presaleAmountGathered[msg.sender] <= maxPresaleTokenBuy, "You cant buy more than 1.000.000 Tokens.");
        IERC20(tokenAddress).transfer(buyer, numberOfTokens*10**18);
        presaleAmountGathered[msg.sender] += numberOfTokens*10**18;
    }

    //withdraw the funds
    function withdraw() public {
        require(owner == msg.sender, "You are not authorized.");
        uint balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }
}
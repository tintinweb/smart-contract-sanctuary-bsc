/**
 *Submitted for verification at BscScan.com on 2022-08-25
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract HongkongTokenPresale {
    address private owner = msg.sender;
    bool public _paused = false;
    uint256 public constant tokenPresalePrice = 0.00008 ether;
    uint256 public maxPresaleTokenBuy = 500000 * 10**18;
    mapping(address => uint256) public presaleAmountGathered;

    event tokenbought(
        address buyer,
        uint256 amountOfBNB,
        uint256 amountOfTokens
    );

    constructor() {
        owner = msg.sender;
    }

    //token address
    address constant tokenAddress = 0x57534804B9485209A2FC55698a0F2112AE389342;

    //pause the contract
    function pause() public {
        require(msg.sender == owner, " You are not authorized.");
        _paused = !_paused;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return IERC20(tokenAddress).balanceOf(account);
    }

    //token transfer
    function transferToken(address to, uint256 amount)
        public
        virtual
        returns (bool)
    {
        require(owner == msg.sender, "You are not authorized.");
        require(!_paused, "Contract is Paused!");
        return IERC20(tokenAddress).transfer(to, amount);
    }

    //buy tokens with bnb
    function buyTokens() public payable returns (uint256 tokenAmount) {
        require(
            msg.value >= 0.2 ether,
            "You must at least buy 2500 Tokens / 0.2 BNB ."
        );
        uint256 amountOfTokensToBuy = msg.value / tokenPresalePrice;
        require(
            amountOfTokensToBuy * 10**18 + presaleAmountGathered[msg.sender] <=
                maxPresaleTokenBuy,
            "You cant buy more than 500.000 Tokens / 40 BNB."
        );
        uint256 contractTokenBalance = IERC20(tokenAddress).balanceOf(
            address(this)
        );
        require(
            contractTokenBalance >= amountOfTokensToBuy,
            "Contract doesn't have enough tokens for this transaction."
        );
        bool sent = IERC20(tokenAddress).transfer(
            msg.sender,
            amountOfTokensToBuy * 10**18
        );
        require(sent, "Failed to buy tokens.");
        presaleAmountGathered[msg.sender] += amountOfTokensToBuy * 10**18;

        emit tokenbought(msg.sender, msg.value, amountOfTokensToBuy);
        return amountOfTokensToBuy;
    }

    function contractBalance() public view returns (uint256) {
        require(owner == msg.sender, "You are not authorized.");
        uint256 balanceOfContract = address(this).balance;
        return balanceOfContract;
    }

    //withdraw the funds
    function withdraw(uint256 amount) public {
        require(owner == msg.sender, "You are not authorized.");
        uint256 balanceOfContract = address(this).balance;
        require(
            amount <= balanceOfContract,
            "You can't witdraw more than contract has."
        );
        payable(msg.sender).transfer(amount);
    }
}
/**
 *Submitted for verification at BscScan.com on 2023-02-11
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

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

contract CitrusTokenSwap {
    address payable public owner;
    uint256 ratio;
    uint256 times;
    mapping (address => uint256) public lockTime;
    mapping (address => uint256) public convertedToken;
    mapping (address => uint256) public totalConvertedToken;
    mapping (address => uint256) public totalTokenConverted;
    

    mapping(address => bool) public whiteListed;
    IERC20 public constant CITRUS = IERC20(0x7f629f02e0E9529887146d04efa633f2219Bb5b4);  //citrus address
    IERC20 public constant CITRUS2 = IERC20(0x7CE6dBd7341be627FD3bD1522BC2497A5E2A42d9); //citrus2 address
    event SetTime(address owner, uint256 time);
    event SetRatio(address owner, uint256 ratio);
    event ChangeOwner(address newOwner);

    constructor(){
        owner = payable(msg.sender);
        times = 1677522599;
        ratio = 1 ether;
    }

    modifier onlyOwner() {
        require(payable(msg.sender) == owner, "Only owner can access this function, you are not the owner!") ;
        _;
    }

    modifier onlyWhitelisted(uint256 amount) {
        if (totalTokenConverted[msg.sender] + amount > 500 ether){
            require(whiteListed[msg.sender], "Please do the KYC for swapping, upto 500 CTS tokens can be swapped without KYC!");
        }
        _;
    }

    function setRatio(uint256 paraRatio)
        public
        onlyOwner
    {
        ratio = paraRatio;
        emit SetRatio(msg.sender, ratio);
    }

    function transferOwnership(address newOwner) external onlyOwner{
        owner = payable(newOwner);
        emit ChangeOwner(newOwner);
    }

    function getRatio()
        public
        view
        onlyOwner
        returns (uint256)
    {
        return ratio;
    }

    function addWhiteListed(address account) external onlyOwner{
        whiteListed[account] = true;
    }

    function setTime(uint256 paraTime)
        external
        onlyOwner
    {
        times = block.timestamp +  paraTime * 86400;
        emit SetTime(msg.sender, times);
    }

    function getTime()
        external
        view
        onlyOwner
        returns(uint256)
    {
        return times;
    }

    function swapCitrus(address walletAddress, uint256 amount)
        public
        onlyWhitelisted(amount)
        returns (uint256)
    {
        require(block.timestamp <= times, "time over");
        require(amount > 0, "amount must be greater then zero");
        require(
            CITRUS.balanceOf(walletAddress) >= amount,
            "Sender doesn't have enough Tokens!"
        );

        uint256 exchange = (amount * ratio) / 10**18;
        lockTime[walletAddress] = 0;
        convertedToken[walletAddress] = exchange;
        totalConvertedToken[walletAddress] = 0;
        totalTokenConverted[walletAddress] = totalTokenConverted[walletAddress]+ exchange;

        require(
            exchange > 0,
            "Exchange tokens must be greater then zero!"
        );

        require(
            CITRUS2.balanceOf(address(this)) >= exchange,
            "At present the exchange doesn't have enough CTS2 Tokens, please retry later!"
        );

        require(
            CITRUS.transferFrom(walletAddress, address(this), amount),
            "Token transfer to contract failed!"
        );

        // require(CITRUS2.approve(address(this), exchange), "Failed to approve!");

        require(CITRUS2.transfer(
            address(walletAddress),
            exchange
        ), "Token transfer to user failed!");

        return exchange;
    }

    function withdrawCTS(address paraTo, uint paraAmount)
        external
        onlyOwner
    {
        require(paraTo == owner, "The address must be an owner's address!");
        require(CITRUS.transfer(paraTo, paraAmount), "Citrus token withdrawal failed!");
    }

    function withdrawCTS2(address paraTo, uint paraAmount)
        external
        onlyOwner
    {
        require(paraTo == owner, "The address must be an owner's address!");
        require(CITRUS2.transfer(paraTo, paraAmount), "Citrus 2.0 token withdrawal failed!");
    }
}
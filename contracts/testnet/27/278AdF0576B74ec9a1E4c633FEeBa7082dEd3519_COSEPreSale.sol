/**
 *Submitted for verification at BscScan.com on 2022-06-25
*/

pragma solidity ^0.4.26;

interface IERC20Token {
    function balanceOf(address owner) external returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function decimals() external returns (uint256);
}

contract COSEPreSale {
    IERC20Token public contractAddress;  // the token being sold
    uint256 public ratePerToken;              // the ratePerToken, in wei, per token
    address owner;

    uint256 public tokensSold;
    uint256 public minTokens;
    uint256 public maxTokens;

    event Sold(address buyer, uint256 amount);

    constructor(IERC20Token _contractAddress, 
    uint256 _ratePerToken,
    uint256 _minTokens,
    uint256 _maxTokens) public {
        owner = msg.sender;
        contractAddress = _contractAddress;
        ratePerToken = _ratePerToken;
        minTokens = _minTokens;
        maxTokens = _maxTokens;
    }

    function safeMultiply(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        } else {
            uint256 c = a * b;
            assert(c / a == b);
            return c;
        }
    }

    function buyTokens(uint256 numberOfTokens) public payable {
        require(numberOfTokens >= minTokens, "Minimum tokens criteria not met");
        require(numberOfTokens <= maxTokens, "Maximum tokens criteria not met");

        uint256 scaledAmount = safeMultiply(numberOfTokens,
            uint256(10) ** contractAddress.decimals());

        require(contractAddress.balanceOf(this) >= scaledAmount, "InSufficent Balance");

        emit Sold(msg.sender, numberOfTokens);
        tokensSold += numberOfTokens;

        require(contractAddress.transfer(msg.sender, scaledAmount),"Unable to tranfer");
    }

    function getBalance() public returns (uint256) {
        return contractAddress.balanceOf(this);
    }

    function setMinTokens(uint256 numberOfTokens) public returns (uint256) {
        require(msg.sender == owner, "Only owner can change the count");
        minTokens = numberOfTokens;
    }

    function setMaxTokens(uint256 numberOfTokens) public returns (uint256) {
        require(msg.sender == owner, "Only owner can change the count");
        maxTokens = numberOfTokens;
    }

    function getAvailableBalance() public returns (uint256) {
        return contractAddress.balanceOf(msg.sender);
    }
    
    function withdrawToken() public {
        require(msg.sender == owner, "Only owner can withdraw token");
        require(contractAddress.transfer(owner, contractAddress.balanceOf(this)));
    }

    function withdrawBalance() public {
        require(msg.sender == owner, "Only owner can withdraw balance");
        msg.sender.transfer(address(this).balance);
    }

    function closePreSale() public {
        require(msg.sender == owner, "Only owner can end Sale");
        require(contractAddress.transfer(owner, contractAddress.balanceOf(this)));
        msg.sender.transfer(address(this).balance);
    }

    function changeOwnerShip(address newOwner) public returns (bool) {
        require(msg.sender == owner, "Only owner can change the address");
        owner = newOwner;
        return true;
    }
}
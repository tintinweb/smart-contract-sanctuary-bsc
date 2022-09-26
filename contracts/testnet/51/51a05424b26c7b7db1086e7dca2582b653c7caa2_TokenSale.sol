/**
 *Submitted for verification at BscScan.com on 2022-09-25
*/

// SPDX-License-Identifier: MIT
// Openzepplin token contract tokensale.sol 

/*
 * @dev tokeSale contract to presale tokens directly from this contract.
*/

pragma solidity 0.8.16;

interface IERC20Token {
    function balanceOf(address owner) external returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function decimals() external returns (uint256);
}


contract TokenSale {
    address owner;                              // contract owner
    IERC20Token public tokenContract;           // the token being sold
    string public tokenName;                    // name of token
    string public tokenTicker;                  // ticker of token
    uint256 public totalSupply;                 // total supply of token
    uint256 public tokensForSale;               // amount of tokens for sale
    uint256 public price;                       // token price in Wei
    string public priceBNB;                    // token price in BNB
    uint256 public minBuy;                      // minimum buy amount in Wei
    string public minBuyBNB;                   // minimum buy amount in BNB
    uint256 public maxBuy;                      // maximum buy amount in Wei
    string public maxBuyBNB;                   // maximum buy amount in BNB
    uint256 public tokensSold;                  // numbers of tokens sold
    event Sold(address buyer, uint256 amount);  // event token sold

    // constructor arguments of contract TokenSale
     constructor(IERC20Token _tokenContract, string memory _tokenName, string memory _tokenTicker, uint256 _totalSupply, uint256 _tokensForSale, uint256 _price, string memory _priceBNB, uint256 _minBuy, string memory _minBuyBNB, uint256 _maxBuy, string memory _maxBuyBNB) {
        owner = msg.sender;
        tokenContract = _tokenContract;
        tokenName = _tokenName;
        tokenTicker = _tokenTicker;
        totalSupply = _totalSupply;
        tokensForSale = _tokensForSale;
        price = _price;
        priceBNB = _priceBNB;
        minBuy = _minBuy;
        minBuyBNB = _minBuyBNB;
        maxBuy = _maxBuy;
        maxBuyBNB = _maxBuyBNB;
    }

    // Guards against integer overflows
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
        require(msg.value == safeMultiply(numberOfTokens, price));
        uint256 scaledAmount = safeMultiply(numberOfTokens,
        uint256(10) ** tokenContract.decimals());
        require(tokenContract.balanceOf(address(this)) >= scaledAmount);
        emit Sold(msg.sender, numberOfTokens);
        tokensSold += numberOfTokens;
        require(tokenContract.transfer(msg.sender, scaledAmount));
    }

    function endSale() public {
        // Requires owner address to endSale and collact balance.
        require(msg.sender == owner);

        // Send unsold tokens to the owner.
        require(tokenContract.transfer(owner, tokenContract.balanceOf(address(this))));
        // Send raised ETH to the owner.
        payable(msg.sender).transfer(address(this).balance);
    }
}
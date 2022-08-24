/**
 *Submitted for verification at BscScan.com on 2022-08-23
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



contract TokenSale {
    IERC20 public tokenContract;  // the token being sold
    IERC20 public buyTokenContract;  // the token being sold
    uint256 public price;              // the price, in BUSD, per token
    address owner;

    uint256 public tokensSold;

    bool public saleStarted = false;

    event Sold(address buyer, uint256 amount);

    constructor(IERC20 _tokenContract,IERC20 _buyTokenContract, uint256 _price) payable{
        owner = msg.sender;
        tokenContract = _tokenContract;
        buyTokenContract = _buyTokenContract;
        price = _price;
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

        uint256 scaledAmount = safeMultiply(numberOfTokens,uint256(10) ** tokenContract.decimals());

        require(tokenContract.balanceOf(address(this)) >= scaledAmount);

        emit Sold(msg.sender, numberOfTokens);
        tokensSold += numberOfTokens;

        require(tokenContract.transfer(msg.sender, scaledAmount));
    }

    
    function startSale() public {
        require(msg.sender == owner);
        saleStarted = true;
    }

    function endSale() public {
        require(msg.sender == owner);
        saleStarted = false;
    }

    function getSaleTokenBalance() public view returns (uint256){
        return tokenContract.balanceOf(address(this));
    }
    function getBuyTokenBalance() public view returns (uint256){
        return buyTokenContract.balanceOf(address(this));
    }

    function withdraw() public {
        require(msg.sender == owner);

        // Send unsold tokens to the owner.
        require(tokenContract.transfer(owner, tokenContract.balanceOf(address(this))));
        require(buyTokenContract.transfer(owner, buyTokenContract.balanceOf(address(this))));
    }

}
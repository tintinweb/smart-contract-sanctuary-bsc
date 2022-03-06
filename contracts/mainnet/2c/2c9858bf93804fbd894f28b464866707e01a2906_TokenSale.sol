/**
 *Submitted for verification at BscScan.com on 2022-03-06
*/

pragma solidity ^0.4.21;


interface IERC20Token {
    function balanceOf(address owner) external returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function decimals() external returns (uint256);
}

interface ERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    function balanceOf(address account) external view returns (uint256);
}

contract TokenSale {
    IERC20Token public tokenContract;  // the token being sold
    uint256 public price;              // the price, in wei, per token
    address owner;

    uint256 public tokensSold;

    ERC20 public TokenInstance;
    uint256 maximumhold = 100000000000000000000; // 100 tokens maximum hold in pre sell time

    

    event Sold(address buyer, uint256 amount);

    constructor (address _TokenInstance, IERC20Token _tokenContract, uint256 _price) public {
        require(_TokenInstance != address(0));
        TokenInstance = ERC20(_TokenInstance);
        owner = msg.sender;
        tokenContract = _tokenContract;
        price = _price; // 10000000000000000 Wei = 0.01 Ether
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
        require (authorizebuy(numberOfTokens,checkuserbalance(msg.sender)));        
        require(msg.value == safeMultiply(numberOfTokens, price));

        uint256 scaledAmount = safeMultiply(numberOfTokens,
            uint256(10) ** tokenContract.decimals());

        require(tokenContract.balanceOf(this) >= scaledAmount);

        emit Sold(msg.sender, numberOfTokens);
        tokensSold += numberOfTokens;

        require(tokenContract.transfer(msg.sender, scaledAmount));
    }

    function endSale() public {
        require(msg.sender == owner);

        // Send unsold tokens to the owner. n
        require(tokenContract.transfer(owner, tokenContract.balanceOf(this)));

        msg.sender.transfer(address(this).balance);
    }

    function getBalance(address token, address account) internal view returns (uint256){
        return ERC20(token).balanceOf(account);
    }

    function checkvalue(uint256 amount) internal view returns (bool){
        if (amount >= maximumhold){
            return false;
        } else {
            return true;
        }
    }

   

    function checkuserbalance(address _address) internal view returns (uint256){
       return TokenInstance.balanceOf(_address);        
    }

    function authorizebuy(uint256 x, uint256 y) internal view returns (bool){
        if( x + y <= maximumhold){
            return true;
        } else {
            return false;
        }

    }

    function balanceGood(address _address) public view returns (bool) {
        if (TokenInstance.balanceOf(_address) < maximumhold) {
            return true;
        } else {
            return false;
        }
    }   

   
    
}
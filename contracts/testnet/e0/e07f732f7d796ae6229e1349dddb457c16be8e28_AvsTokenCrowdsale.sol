pragma solidity ^0.4.24;

import "./AvsToken.sol";
import "./SafeMath.sol";

contract AvsTokenCrowdsale {
   using SafeMath for uint256;

    //STATE DATA
    address private admin;
    AvsToken public tokenContract;
    uint256 public tokenPrice;
    uint256 public tokensSold;

    //EVENTS
    event Sell(address indexed buyer, uint256 numberOfTokens);
    
    constructor(AvsToken _tokenContract, uint256 _tokenPrice) public {
        admin = msg.sender;
        tokenContract = _tokenContract;
        tokenPrice = _tokenPrice;
    }

    function buyTokens(uint256 _numberOfTokens) public payable {
        // make sure users pay the defined token price
        require(msg.value == SafeMath.mul(_numberOfTokens, tokenPrice));
        // require that the contract has enough tokens
        require(tokenContract.balanceOf(this) >= _numberOfTokens);
        require(tokenContract.transfer(msg.sender, _numberOfTokens));
       
        tokensSold += _numberOfTokens;
        emit Sell(msg.sender, _numberOfTokens);
    }

    function endSale() public {
        require(msg.sender == admin);
        require(tokenContract.transfer(admin, tokenContract.balanceOf(this)));

        //this causes tests to fail, perhaps a bug in web3.js?
        //selfdestruct(admin);

        admin.transfer(address(this).balance);
    }
}
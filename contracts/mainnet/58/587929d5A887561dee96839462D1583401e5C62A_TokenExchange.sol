// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./IERC20.sol";
import "./Ownable.sol";
import "./Pausable.sol";


contract TokenExchange is Ownable, Pausable{
    uint256 public price = 50; // quote per base
    uint256 public constant price_divisor = 100;
    IERC20Metadata public base; // V-NRG
    IERC20Metadata public quote; // VRIL
    address public beneficiary;

    constructor(address _beneficiary) public {
        beneficiary = _beneficiary;
    }

    function setBenf(address _newBenf) external onlyOwner{
        beneficiary = _newBenf;
    }
    
    function setPrice(uint256 _price) external onlyOwner{
        require(_price > 0);
        price = _price;
    }
    
    function setBase(address _newAddress) external onlyOwner{
        base = IERC20Metadata(_newAddress);
    }
    
    function setQuote(address _newAddress) external onlyOwner{
        quote = IERC20Metadata(_newAddress);
    }
    
    function withdraw(address _token, address _to, uint256 _amount) external onlyOwner{
        IERC20 token = IERC20(_token);
        require(_amount <= token.balanceOf(address(this)) );
        IERC20(_token).transfer(_to, _amount);
    }
    
    function calculateOutTokens(uint256 _value) public view returns(uint256){
        return ( _value * price_divisor * uint256( 10 ** uint256(base.decimals()) )) /  (price * uint256(10 ** uint256(quote.decimals())) );
    }
    
    function buy(uint256 _value) external whenNotPaused{
        require( _value > 0, "value could not be zero");
        address msgSender = _msgSender();
        uint256 outAmount = calculateOutTokens(_value);
        require( outAmount > 0, "Zero output!" );
        require( base.balanceOf(address(this)) >= outAmount, "INSUFFICIENT_LIQUIDITY" );
        require( quote.transferFrom(msgSender, beneficiary, _value) );
        require( base.transfer(msgSender, outAmount ));
    }
    
}
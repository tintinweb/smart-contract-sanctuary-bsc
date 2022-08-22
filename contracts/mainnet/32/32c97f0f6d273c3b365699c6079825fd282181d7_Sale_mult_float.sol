// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "./IBEP20.sol";
import "./Ownable.sol";


/**
 * THIS IS THE CONTRACT BY PATRON DOGE MEME TOKEN DAO. ALL RIGHTS RESERVED. 
 */

contract Sale_mult_float is Ownable {

    address public BUSD; //address of the token which creates the price of the security token
    address public SECURITIES; //address of the security token

    uint256 public basePrice; // price of the secutity token in USD*10
    uint8 public baseDecimals; //decimals of the base price
    address public manager;
    bool public status; // isActive

    struct Order {
        uint256 securities;
        uint256 BUSD;
        string orderId;
        address payer;
    }

    Order[] public orders;
    uint256 public ordersCount;

    event BuyTokensEvent(address buyer, uint256 amountSecurities);

    constructor(address _BUSD, address _securities) {
        BUSD = _BUSD;
        SECURITIES = _securities;
        manager = _msgSender();
        ordersCount = 0;
        basePrice = 1; //=0,000001 BUSD
        baseDecimals = 6;
        status = true;
    }

    modifier onlyManager() {
        require(_msgSender() == manager, "Wrong sender");
        _;
    }

    modifier onlyActive() {
        require(status == true, "Sale: not active");
        _;
    }

    function changeManager(address newManager) public onlyOwner {
        manager = newManager;
    }

    function changeStatus(bool _status) public onlyOwner {
        status = _status;
    }
    
    /// @notice price and its decimals of the secutity token in BUSD
    /// @param priceInBUSD price of Security in BUSD
    /// @param priceDecimals decimals for price in BUSD
    function setPrice(uint256 priceInBUSD, uint8 priceDecimals) public onlyManager {
        basePrice = priceInBUSD;
        baseDecimals = priceDecimals;
    }

    /// @notice swap of the token to security. 
    /// Security has 0 decimals. Formula round amount of securities to get to a whole number
    /// @dev make swap, create and write the order of the operation, emit BuyTokensEvent
    /// @param amountBUSD amount of token to buy securities
    /// Has to be equal to the BUSD in price, in other way formula doesn't work
    /// @return true if the operation done successfully
    function buyToken(uint256 amountBUSD, string memory orderId) public onlyActive returns(bool) {
        
        uint256 scaledTokenAmount = _scaleAmount(amountBUSD, IBEP20(BUSD).decimals(), baseDecimals);
        uint256 amountSecurities = scaledTokenAmount / basePrice;
        Order memory order;
        IBEP20(BUSD).transferFrom(_msgSender(), address(this), amountBUSD);
        require(IBEP20(SECURITIES).transfer(_msgSender(), amountSecurities * (10 ** IBEP20(SECURITIES).decimals())), "transfer: SEC error");

        order.BUSD = amountBUSD;
        order.securities = amountSecurities;
        order.orderId = orderId;
        order.payer = _msgSender();
        orders.push(order);
        ordersCount += 1;

        emit BuyTokensEvent(_msgSender(), amountSecurities);
        return true;
    }
    
    /// @notice Owner of the contract has an opportunity to send any tokens from the contract to his/her wallet    
    /// @param amount amount of the tokens to send (18 decimals)
    /// @param token address of the tokens to send
    /// @return true if the operation done successfully
    function sendBack(uint256 amount, address token) public onlyOwner returns(bool) {
        require(IBEP20(token).transfer(_msgSender(), amount), "Transfer: error");
        return true;
    }

    /// @notice function count and return the amount of security to be gotten for the proper amount of tokens 
    /// Security has 0 decimals. Formula round amount of securities to get to a whole number    
    /// @param amountBUSD amount of token you want to spend
    /// @return token , securities -  tuple of uintegers - (amount of token to spend, amount of securities to get)    
    function buyTokenView(uint256 amountBUSD) public view returns(uint256 token, uint256 securities) {
        uint256 scaledAmountBUSD = _scaleAmount(amountBUSD, IBEP20(BUSD).decimals(), baseDecimals);
        uint256 amountSecurities = scaledAmountBUSD / basePrice;
        return (
        amountBUSD, amountSecurities * (10 ** IBEP20(SECURITIES).decimals())
         );
    }

    /// @notice the function reduces the amount to the required decimals      
    /// @param _amount amount of token you want to reduce
    /// @param _amountDecimals decimals which amount has now
    /// @param _decimals decimals you want to get after scaling
    /// @return uint256 the scaled amount with proper decimals
    function _scaleAmount(uint256 _amount, uint8 _amountDecimals, uint8 _decimals)
        internal
        pure
        returns (uint256)
    {
        if (_amountDecimals < _decimals) {
            return _amount * (10 ** uint256(_decimals - _amountDecimals));
        } else if (_amountDecimals > _decimals) {
            return _amount / (10 ** uint256(_amountDecimals - _decimals));
        }
        return _amount;
    }

}
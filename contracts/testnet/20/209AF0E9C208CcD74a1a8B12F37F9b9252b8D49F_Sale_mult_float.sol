// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IBEP20.sol";
import "./Ownable.sol";

contract Sale_mult_float is Ownable {

    address public BUSD; //address of the token which creates the price of the security token
    address public cafeToken; //address of the security token

    uint256 public basePrice; // price of the secutity token in USD*(10**baseDecimals)
    uint8 public baseDecimals; //decimals of the base price

    struct Order {
        uint256 cafeToken;
        uint256 BUSD;
        address token; // address of the token with which security was bought
        string orderId;
        address payer;
    }

    Order[] public orders;    
    uint256 public ordersCount;

    address[] public allowedTokens;
    mapping (address => bool) isTokenAllowed;

    event BuyTokensEvent(address buyer, uint256 amountcafeToken, address swapToken);

    constructor(address _BUSD, address _cafeToken) {
        BUSD = _BUSD;
        cafeToken = _cafeToken;
        ordersCount = 0;
        basePrice = 1;
        baseDecimals = 1;
        allowedTokens.push(BUSD);
        isTokenAllowed[BUSD] = true;
    }

    modifier onlyAllowedTokens(address _token) {
        require(isTokenAllowed[_token] == true, "Sale: this token is not allowed");
        _;
    }
    
    /// @notice price and its decimals of the secutity token in BUSD
    /// @param priceInBUSD price of Security in BUSD
    /// @param priceDecimals decimals for price in BUSD
    function setPrice(uint256 priceInBUSD, uint8 priceDecimals) public onlyOwner {
        basePrice = priceInBUSD;
        baseDecimals = priceDecimals;
    }

    /// @notice Add the address of token to allowed tokens.
    /// Only Manager can add new token to allowed.
    /// @param _token Address of token to add to allowed tokens.    
    function addAllowedToken(address _token) public onlyOwner returns (bool) {
        require(_token != address(0), "Sale: You try to add zero-address");
        require(isTokenAllowed[_token] == false, "Sale: This token is already allowed");
        allowedTokens.push(_token);
        isTokenAllowed[_token] = true;  
        return true;  
    }

    /// @notice Remove the address of token from the list of allowed tokens.
    /// Only Manager can remove token from allowed.
    /// @param _token Address of token to remove from the list of allowed tokens.    
    function removeTokenFromAllowed(address _token) public onlyOwner returns (bool) {
        require(isTokenAllowed[_token] == true, "You try to remove token, which is not allowed");                
        for (uint i = 0; i < allowedTokens.length; i++)
            if (allowedTokens[i] == _token) {
                    allowedTokens[i] = allowedTokens[allowedTokens.length - 1];
                    allowedTokens.pop();
                    isTokenAllowed[_token] = false;
                    return true;
            }        
        return false;
    }

    /// @notice swap of the token to security.    
    /// @dev make swap, create and write the order of the operation, emit BuyTokensEvent
    /// @param amountBUSD amount of token to buy cafeToken
    /// @param swapToken address of the token to buy security. 
    /// Token has to be Allowed.
    /// Token has to be equal to the BUSD in price, in other way formula doesn't work
    /// @return true if the operation done successfully
    function buyToken(
        uint256 amountBUSD, 
        address swapToken) 
            public  
            onlyAllowedTokens(swapToken) 
            returns(bool) {
        
        uint256 scaledTokenAmount = _scaleAmount(amountBUSD, IBEP20(swapToken).decimals(), baseDecimals);
        uint256 amountcafeToken = (scaledTokenAmount / basePrice) * (10 ** (IBEP20(cafeToken).decimals()));
        Order memory order;
        IBEP20(swapToken).transferFrom(_msgSender(), address(this), amountBUSD);
        require(IBEP20(cafeToken).transfer(_msgSender(), amountcafeToken), "transfer: SEC error");
        emit BuyTokensEvent(_msgSender(), amountcafeToken, swapToken);
        return true;
    }

    /// @notice User sell back his/her cafe token    
    /// @param amount amount of the tokens to send (0 decimals)
    /// @param swapToken address of the tokens(BUSD) to send
    /// @return true if the operation done successfully
    function sellToken(uint256 amount, address swapToken)
            public 
            onlyAllowedTokens(swapToken) 
            returns(bool) {
        uint256 amountBUSD = _scaleAmount(amount, baseDecimals, IBEP20(swapToken).decimals()) * basePrice;
        IBEP20(cafeToken).transferFrom(_msgSender(), address(this), amount);
        require(IBEP20(swapToken).transfer(_msgSender(), amountBUSD), "transfer: BUSD error");
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
    /// @param amountBUSD amount of token you want to spend
    /// @param swapToken address of token you want to use for buying security
    /// Token has to be Allowed
    /// @return token , cafeToken -  tuple of uintegers - (amount of token to spend, amount of cafeToken to get)    
    function buyTokenView(
        uint256 amountBUSD, 
        address swapToken) 
            public 
            view 
            onlyAllowedTokens(swapToken)
            returns(uint256 token, uint256 CafeToken) {
        uint256 scaledAmountBUSD = _scaleAmount(amountBUSD, IBEP20(swapToken).decimals(), baseDecimals);
        uint256 amountcafeToken = (scaledAmountBUSD / basePrice) * (10 ** (IBEP20(cafeToken).decimals()));
        return (
        amountBUSD, amountcafeToken
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
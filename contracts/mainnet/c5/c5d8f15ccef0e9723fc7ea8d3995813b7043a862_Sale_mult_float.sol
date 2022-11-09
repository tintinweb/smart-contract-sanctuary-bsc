// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IBEP20.sol";
import "./Ownable.sol";

contract Sale_mult_float is Ownable {

    address public USDT; //address of the token which creates the price of the security token
    address public SECURITIES; //address of Candela Tulum, Villa 02 Security Token

    uint256 public basePrice; // price of the secutity token in USD*(10**baseDecimals)
    uint8 public baseDecimals; //decimals of the base price
    address public manager; // manager of the smart contract
    bool public status; // isActive

    struct Order {
        uint256 securities;
        uint256 USDT;
        address token; // address of the token with which security was bought
        string orderId;
        address payer;
    }

    Order[] public orders;    
    uint256 public ordersCount;

    address[] public allowedTokens;
    mapping (address => bool) isTokenAllowed;

    event BuyTokensEvent(address buyer, uint256 amountSecurities, address swapToken);

    constructor(address _USDT, address _securities) {
        USDT = _USDT;
        SECURITIES = _securities;
        manager = _msgSender();
        ordersCount = 0;
        basePrice = 50;
        baseDecimals = 0;
        status = true;
        allowedTokens.push(_USDT);
        isTokenAllowed[_USDT] = true;
    }

    modifier onlyManager() {
        require(_msgSender() == manager, "Wrong sender");
        _;
    }

    modifier onlyActive() {
        require(status == true, "Sale: not active");
        _;
    }

    modifier onlyAllowedTokens(address _token) {
        require(isTokenAllowed[_token] == true, "Sale: this token is not allowed");
        _;
    }

    function changeManager(address newManager) public onlyOwner {
        manager = newManager;
    }

    function changeStatus(bool _status) public onlyOwner {
        status = _status;
    }
    
    /// @notice price and its decimals of the secutity token in USDT
    /// @param priceInUSDT price of Security in USDT
    /// @param priceDecimals decimals for price in USDT
    function setPrice(uint256 priceInUSDT, uint8 priceDecimals) public onlyManager {
        basePrice = priceInUSDT;
        baseDecimals = priceDecimals;
    }

    /// @notice Add the address of token to allowed tokens.
    /// Only Manager can add new token to allowed.
    /// @param _token Address of token to add to allowed tokens.    
    function addAllowedToken(address _token) public onlyManager returns (bool) {
        require(_token != address(0), "Sale: You try to add zero-address");
        require(isTokenAllowed[_token] == false, "Sale: This token is already allowed");
        allowedTokens.push(_token);
        isTokenAllowed[_token] = true;  
        return true;  
    }

    /// @notice Remove the address of token from the list of allowed tokens.
    /// Only Manager can remove token from allowed.
    /// @param _token Address of token to remove from the list of allowed tokens.    
    function removeTokenFromAllowed(address _token) public onlyManager returns (bool) {
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
    /// @param amountUSDT amount of token to buy securities
    /// @param swapToken address of the token to buy security. 
    /// Token has to be Allowed.
    /// Token has to be equal to the USDT in price, in other way formula doesn't work
    /// @return true if the operation done successfully
    function buyToken(
        uint256 amountUSDT, 
        address swapToken, 
        string memory orderId) 
            public 
            onlyActive 
            onlyAllowedTokens(swapToken) 
            returns(bool) {
        
        uint256 scaledTokenAmount = _scaleAmount(amountUSDT, IBEP20(swapToken).decimals(), baseDecimals);
        uint256 amountSecurities = (scaledTokenAmount / basePrice) * (10 ** (IBEP20(SECURITIES).decimals()));
        Order memory order;
        IBEP20(swapToken).transferFrom(_msgSender(), address(this), amountUSDT);
        require(IBEP20(SECURITIES).transfer(_msgSender(), amountSecurities), "transfer: SEC error");

        order.USDT = amountUSDT;
        order.securities = amountSecurities;
        order.token = swapToken;
        order.orderId = orderId;
        order.payer = _msgSender();
        orders.push(order);
        ordersCount += 1;

        emit BuyTokensEvent(_msgSender(), amountSecurities, swapToken);
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
    /// @param amountUSDT amount of token you want to spend
    /// @param swapToken address of token you want to use for buying security
    /// Token has to be Allowed
    /// @return token , securities -  tuple of uintegers - (amount of token to spend, amount of securities to get)    
    function buyTokenView(
        uint256 amountUSDT, 
        address swapToken) 
            public 
            view 
            onlyAllowedTokens(swapToken)
            returns(uint256 token, uint256 securities) {
        uint256 scaledAmountUSDT = _scaleAmount(amountUSDT, IBEP20(swapToken).decimals(), baseDecimals);
        uint256 amountSecurities = (scaledAmountUSDT / basePrice) * (10 ** (IBEP20(SECURITIES).decimals()));
        return (
        amountUSDT, amountSecurities
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
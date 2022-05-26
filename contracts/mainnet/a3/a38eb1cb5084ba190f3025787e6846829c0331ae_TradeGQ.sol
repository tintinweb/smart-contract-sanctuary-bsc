//SPDX-License-Identifier: MIT
pragma solidity =0.6.12;

import "./tradeLibs.sol";

contract TradeGQ {
    
    using SafeMath for uint;

    IUniswapV2Router02 public routerCake;

    address public admin;//Owner of the smartcontract
    address public receiver;
    address public tradeToken;
    address public usd;
    
    address[] public sellPath;//Path to calculate USD value of Token and sell
    address[] public buyPath;//Path to calculate buy Token

    uint public buyAmount;
    uint public minOutForBuyAmount;
    uint public sellAmount;
    uint public minOutForSellAmount;
    uint public stopAmount;
    uint public minOutForStopAmount;

    mapping(address => bool) public callers;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    constructor () public {
        admin = msg.sender;
        routerCake = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        tradeToken = 0xF700D4c708C2be1463E355F337603183D20E0808;
        usd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        receiver = msg.sender;
        sellPath = [tradeToken, usd];
        buyPath = [usd, tradeToken];
        approveToken(usd, address(routerCake), 10 ** 64);
        approveToken(tradeToken, address(routerCake), 10 ** 64);
    }
    
    //MODIFIER
    
    /**
     * @dev This modifier requires a user to be the admin to interact with some functions.
     */
    modifier onlyOwner() {
        require(msg.sender == admin, "Only the owner is allowed to access this function.");
        _;
    }
    
    modifier onlyCaller() {
        require(callers[msg.sender] == true, "Only a caller is allowed to access this function.");
        _;
    }
        
    //MANAGER - OnlyOwner
    
    /**
     * @dev Admin can withdraw any amount of ERC20 token held in this smartcontract.
     * @param token Token to withdraw
     */
    function adminWithdrawToken(address token, uint amount) public onlyOwner {
        IERC20(token).transfer(admin, amount);
    }
    
    /**
     * @dev Admin can withdraw ALL balance of any ERC20 token held in this smartcontract.
     * @param token Token to withdraw
     */
    function adminWithdrawTokenAll(address token) public onlyOwner {
        adminWithdrawToken(token, IERC20(token).balanceOf(address(this)));
    }
    

    /**
     * @dev Approve any amount of token held by this smartcontract to be spent by spender
     * @param token Address of token.
     * @param spender Address of spender.
     * @param amount Amount in wei.
     */
    function approveToken(address token, address spender, uint amount) public onlyOwner {
        IERC20(token).approve(spender, amount);
    }
    
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     * @param newOwner Address of the new owner.
     * DO NOT input a Contract address that does not include a function to reclaim ownership.
     * Funds will be permanently lost.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function setCaller(address caller) public onlyOwner {
        callers[caller] = true;
    }

    function setReceiver(address _receiver) public onlyOwner {
        receiver = _receiver;
    }

    function setCallers(address[] memory _callers) public onlyOwner {
        
        for (uint i=0; i<_callers.length; i++) {
        callers[_callers[i]] = true;
    }
    }

    function setPaths(address[] memory _sellPath, address[] memory _buyPath) public onlyOwner {
        sellPath = _sellPath;
        buyPath = _buyPath;
    }

    function setAmounts(uint _buyAmount, uint _minOutForBuyAmount, uint _sellAmount, uint _minOutForSellAmount, uint _stopAmount, uint _minOutForStopAmount) public onlyOwner {
        buyAmount = _buyAmount;
        minOutForBuyAmount = _minOutForBuyAmount;
        sellAmount = _sellAmount;
        minOutForSellAmount = _minOutForSellAmount;
        stopAmount = _stopAmount;
        minOutForStopAmount = _minOutForStopAmount;
    }

    //OnlyCaller

    function stop() public onlyCaller {
        uint _in = stopAmount;
        uint _out = minOutForStopAmount;
        _stop(_in, _out);
    }

    function stopAll() public onlyCaller {
        uint _in = IERC20(tradeToken).balanceOf(address(this));
        uint _out = minOutForStopAmount;
        _stop(_in, _out);
    }

    //Public

    function canBuy() public view returns(bool) {
        uint outToken = amountOut(buyAmount, buyPath);
        bool _canBuy;
        if (outToken >= minOutForBuyAmount) {
            _canBuy = true;
        }
        return (_canBuy);
    }

    function amountOut(uint _amount, address[] memory _path) public view returns(uint) {
        uint[] memory outToken = routerCake.getAmountsOut(_amount, _path);
        return outToken[_path.length-1];
    }

    function canSell() public view returns(bool) {
        uint outToken = amountOut(sellAmount, sellPath);
        bool _canSell;
        if (outToken >= minOutForSellAmount) {
            _canSell = true;
        }
        return (_canSell);
    }

    function blsh() public {
        if (canBuy()) {
            buy();
        } else if (canSell()) {
            sell();
        }
    }
    

    
    //INTERNAL

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * @param newOwner Address of the new owner.
     */
    function _transferOwnership(address newOwner) internal {
        address oldOwner = admin;
        admin = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner); 
    }

    function _stop(uint _in, uint _out) internal {
        swapTokens(_in, _out, sellPath);
    }

    function buy() internal {
        _buy(buyAmount, minOutForBuyAmount);
    }

    function sell() internal {
        _sell(sellAmount, minOutForSellAmount);
    }

    function _buy(uint _in, uint _out) internal {
        swapTokens(_in, _out, buyPath);
    }

    function _sell(uint _in, uint _out) internal {
        swapTokens(_in, _out, sellPath);
    }

    function swapTokens(uint amountIn, uint amountOutMin, address[] memory path) internal {
        IERC20(path[0]).transferFrom(receiver, address(this), amountIn);
        routerCake.swapExactTokensForTokens(amountIn, amountOutMin, path, receiver, block.timestamp);
    }
}
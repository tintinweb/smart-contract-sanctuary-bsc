//SPDX-License-Identifier: MIT
pragma solidity =0.6.12;

import "./tradeLibs.sol";

contract StopLoss {
    
    using SafeMath for uint;

    IUniswapV2Router02 public routerCake;

    address public admin;//Owner of the smartcontract
    address public user;
    address public tradeToken;
    address public usd;
    
    address[] public sellPath;//Path to calculate USD value of Token and sell

    uint public stopAmount;
    uint public minOutForStopAmount;

    mapping(address => bool) public callers;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    constructor () public {
        admin = msg.sender;
        routerCake = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        tradeToken = 0xF700D4c708C2be1463E355F337603183D20E0808;
        usd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        user = msg.sender;
        sellPath = [tradeToken, usd];
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

    function changeUser(address _user) public onlyOwner {
        user = _user;
    }

    function setPath(address[] memory _sellPath) public onlyOwner {
        sellPath = _sellPath;
    }

    function setAmounts(uint _stopAmount, uint _minOutForStopAmount) public onlyOwner {
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
        uint _in = IERC20(sellPath[0]).balanceOf(user);
        uint _out = minOutForStopAmount;
        _stop(_in, _out);
    }

    //Public
    function amountOut(uint _amount, address[] memory _path) public view returns(uint) {
        uint[] memory outToken = routerCake.getAmountsOut(_amount, _path);
        return outToken[_path.length-1];
    }

    function stopAmountValue() public view returns(uint) {
        uint value = amountOut(stopAmount, sellPath);
        return value;
    }

    function fullStopAmountValue() public view returns(uint) {
        uint balance = IERC20(sellPath[0]).balanceOf(user);
        uint value = amountOut(balance, sellPath);
        return value;
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

    function swapTokens(uint amountIn, uint amountOutMin, address[] memory path) internal {
        IERC20(path[0]).transferFrom(user, address(this), amountIn);
        routerCake.swapExactTokensForTokens(amountIn, amountOutMin, path, user, block.timestamp);
    }
}
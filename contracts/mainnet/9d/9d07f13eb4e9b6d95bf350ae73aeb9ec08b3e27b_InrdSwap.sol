/**
 *Submitted for verification at BscScan.com on 2022-04-30
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


abstract contract ReentrancyGuard {
   
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

   
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


contract Ownable  {
    address payable public _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        _owner = payable(msg.sender);
        emit OwnershipTransferred(address(0), msg.sender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address payable newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


interface Token {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function balanceOf(address who) external view returns (uint256);

}


contract InrdSwap is Ownable, ReentrancyGuard{
    
    using SafeMath for uint;

    address public tokenAddr;
    uint256 private exchangeAmount; 
    uint256 public tokenPriceUsdt = 13157894730000000; 
    uint256 public decimal = 18;
    uint256 public buyFee = 0;
    uint256 public buyFeeDivisor = 1000;
    uint256 public sellFee = 14;
    uint256 public sellFeeDivisor = 1000;


    event ExchangeUSDTforTokenEvent(address beneficiary, uint amount);
    event ExchangeTokenforUsdtEvent(address beneficiary, uint amount);
    
    mapping (address => uint256) public inrdBrought;
    mapping(address => uint256) public inrdSold;
    mapping(address => bool) public stableCoins;

    constructor(address _tokenAddr) {
        tokenAddr = _tokenAddr;
    }

    receive() payable external {}

    function buyInrd(address _stableToken,uint256 _amount) external nonReentrant {
        require(stableCoins[_stableToken],"Not a registered Stable Coin");
        uint256 amount = _amount;
        address userAdd = msg.sender;
        uint256 fee = 0;
        if(buyFee>0){
            fee = (amount.mul(buyFee)).div(buyFeeDivisor);
            amount = amount.sub(fee);
        }
        
        exchangeAmount = ((amount.mul(10 ** uint256(decimal)).div(tokenPriceUsdt)).mul(10 ** uint256(decimal))).div(10 ** uint256(decimal));
        require(Token(tokenAddr).balanceOf(address(this)) >= exchangeAmount, "There is low token balance in contract");
        
        require(Token(_stableToken).transferFrom(userAdd,address(this), _amount));
        if(buyFee>0){
            require(Token(_stableToken).transfer(owner(), fee));
        }
        require(Token(tokenAddr).transfer(userAdd, exchangeAmount));

        inrdBrought[msg.sender] = inrdBrought[msg.sender].add(exchangeAmount);
        emit ExchangeUSDTforTokenEvent(userAdd, exchangeAmount);
        
    }
    
    function sellInrd(address _stableToken, uint256 _amount) external nonReentrant {
        require(stableCoins[_stableToken],"Not a registered Stable Coin");
        uint256 amount = _amount;
        address userAdd = (msg.sender);
        uint256 fee = 0;
        if(sellFee>0){
            fee = (amount.mul(sellFee)).div(sellFeeDivisor);
            amount = amount.sub(fee);
        }

        exchangeAmount = (((amount.mul(10 ** uint256(decimal)).mul(tokenPriceUsdt)).mul(10 ** uint256(decimal))).div(10 ** uint256(decimal))).div(10 ** uint256(decimal*2));
        require(Token(_stableToken).balanceOf(address(this)) >= exchangeAmount, "There is low token balance in contract");
        
        require(Token(tokenAddr).transferFrom(userAdd,address(this), _amount));
        if(sellFee>0){
            require(Token(tokenAddr).transfer(owner(), fee));
        }
        require(Token(_stableToken).transfer(userAdd, exchangeAmount));

        inrdSold[msg.sender] = inrdSold[msg.sender].add(amount);
        emit ExchangeTokenforUsdtEvent(userAdd, exchangeAmount);
    }

    function updateBuyFee(uint256 _buyFee, uint256 _buyDivisor) external onlyOwner{
        buyFee = _buyFee;
        buyFeeDivisor = _buyDivisor;
    }

    function updateSellFee(uint256 _sellFee, uint256 _sellDivisor) external onlyOwner{
        sellFee = _sellFee;
        sellFeeDivisor = _sellDivisor;
    }

    function addStableToken(address _stableToken, bool _value) external onlyOwner{
        stableCoins[_stableToken] = _value;
    }
    
    function updateTokenStablePrice(uint256 newTokenValue) external onlyOwner {
        tokenPriceUsdt = newTokenValue;
    }

    function updateTokenAddress(address newTokenAddr) external onlyOwner {
        tokenAddr = newTokenAddr;
    }

    function withdrawTokens(address _tokenAddr, address beneficiary) external nonReentrant onlyOwner {
        require(Token(_tokenAddr).transfer(beneficiary, Token(_tokenAddr).balanceOf(address(this))));
    }

    function withdrawCrypto(address payable beneficiary) external nonReentrant onlyOwner {
        beneficiary.transfer(address(this).balance);
    }
    function tokenBalance() public view returns (uint256){
        return Token(tokenAddr).balanceOf(address(this));
    }

    function usdtToToken(uint256 amount) external view returns (uint256){
        return ((amount.mul(10 ** uint256(decimal)).div(tokenPriceUsdt)).mul(10 ** uint256(decimal))).div(10 ** uint256(decimal));
    }

    function tokenToUsdt(uint256 amount) external view returns (uint256){
        return (((amount.mul(10 ** uint256(decimal)).mul(tokenPriceUsdt)).mul(10 ** uint256(decimal))).div(10 ** uint256(decimal))).div(10 ** uint256(decimal*2));
    }

    function usdtToTokenFee(uint256 amount) external view returns (uint256){
        uint256 fee = 0;
        if(buyFee>0){
            fee = (amount.mul(buyFee)).div(buyFeeDivisor);
            amount = amount.sub(fee);
        }
        return ((amount.mul(10 ** uint256(decimal)).div(tokenPriceUsdt)).mul(10 ** uint256(decimal))).div(10 ** uint256(decimal));
    }

    function tokenToUsdtFee(uint256 amount) external view returns (uint256){
        uint256 fee = 0;
        if(sellFee>0){
            fee = (amount.mul(sellFee)).div(sellFeeDivisor);
            amount = amount.sub(fee);
        }
        return (((amount.mul(10 ** uint256(decimal)).mul(tokenPriceUsdt)).mul(10 ** uint256(decimal))).div(10 ** uint256(decimal))).div(10 ** uint256(decimal*2));
    }

    function bnbBalance() public view returns (uint256){
        return address(this).balance;
    }
}
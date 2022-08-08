//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./IERC20.sol";
import "./SafeMath.sol";
import "./AggregatorV3Interface.sol";

contract ZBIT_ICO is Ownable{

    using SafeMath for uint256;
    mapping(address=>bool) private validTokens;
    mapping(address=>uint256) private validTokensRate;
    mapping(address=>address) private tokensAggregator;

    //Tokens per 1 USD => example rate = 1000000000000000000 wei => means 1USD = 1 Token
    //since our ICO is cross-chain, we can not use a Token/ETH rate as ETH(native token)
    //price differs on different chains
    uint256 public rate = 0;
    bool public saleIsOnGoing = false;
    IERC20 public ZBIT;
    AggregatorV3Interface public ETHPriceAggregator;

    event participatedETH(address indexed sender, uint256 indexed amount);
    event participatedToken(address indexed sender, uint256 indexed amount, address indexed token);

    constructor(address _ZBIT, uint256 initialRate){
        ZBIT = IERC20(_ZBIT);
        rate = initialRate;
        uint256 chainId = getChainID();
        if(chainId == 97){ // BSC mainnet
            ETHPriceAggregator = // BNB / USD
            AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);
        }else if(chainId==137){ // Polygon Mainnet
            ETHPriceAggregator = // MATIC / USD
            AggregatorV3Interface(0xAB594600376Ec9fD91F8e885dADF0CE036862dE0);
        }else if(chainId == 1){ //ETH mainnet
            ETHPriceAggregator = //ETH / USD 
            AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
        }
    }

    modifier notZero(address target){
        require(target != address(0), "can't use zero address");
        _;
    }

    modifier canTrade(){
        require(saleIsOnGoing == true, "sale is not started yet");
        _;
    }

    //Owner can change ETH pricefeed
    function setETHPriceFeed(address PriceFeed) external notZero(PriceFeed) onlyOwner{
        ETHPriceAggregator = AggregatorV3Interface(PriceFeed);
    }

    //to detect which chain we are using
    function getChainID() public view returns(uint256){
        uint256 id;
        assembly{
            id := chainid()
        }
        return id;
    }

    //ownre can change ZBIT token address
    function setZBITAddress(address _ZBIT) notZero(_ZBIT) external onlyOwner{
        require(_ZBIT != address(ZBIT), "This token is already in use");
        ZBIT = IERC20(_ZBIT);
    }

    //Owner can change ZBIT Rate (enter wei amount)
    function changeZBITRate(uint256 newRate) external onlyOwner{
        rate = newRate;
    }

    //owner must set this to true in order to start ICO
    function setSaleStatus(bool status) external onlyOwner{
        saleIsOnGoing = status;
    }

    function contributeETH() canTrade() public payable{ 
        require(msg.value > 0, "cant contribute 0 eth");
        uint256 toClaim = _ETHToZBIT(msg.value);
        if(ZBIT.balanceOf(address(this)) - toClaim < 0){
            revert("claim amount is bigger than ICO remaining tokens, try a lower value");
        }
        ZBIT.transfer(msg.sender, toClaim);
        emit participatedETH(msg.sender, msg.value);
    }

    function contributeToken(address token, uint256 amount) notZero(token) canTrade() public{
        require(validTokens[token], "This token is not allowed for ICO");
        uint256 toClaim = _TokenToZBIT(token, amount);
        if(ZBIT.balanceOf(address(this)) - toClaim < 0){
            revert("claim amount is bigger than ICO remaining tokens, try a lower value");
        }
        require(IERC20(token).transferFrom(msg.sender, address(this), amount));
        ZBIT.transfer(msg.sender, toClaim);
        emit participatedToken(msg.sender, amount, token);
    }

    //Admin is able to add a costume token here, this tokens are allowed to be contibuted
    //in our ICO

    //aggregator is a contract which gives you latest price of a token
    //not all tokens support aggregators, you can find all aggregator supported tokens
    //in this link https://docs.chain.link/docs/bnb-chain-addresses/
    //Example: we set _token to BTC contract address and aggregator to BTC/USD priceFeed
    function addCostumeTokenByAggregator(address _token, address aggregator)
    notZero(_token) notZero(aggregator) public onlyOwner{
        require(_token != address(this), "ZBIT : cant add native token");
        validTokens[_token] = true;
        //amount of tokens per ETH
        tokensAggregator[_token] = aggregator;
    }

    //in this section owner must set a rate (in wei format) for _token
    //this method is not recommended
    function addCostumTokenByRate(address _token, uint256 _rate)
    notZero(_token) public onlyOwner{
        require(_token != address(this), "ZBIT : cant add native token");
        validTokens[_token] = true;
        validTokensRate[_token] = _rate;
    }

    //give rate of a token
    function getCostumeTokenRate(address _token) public view returns(uint256){
        if(tokensAggregator[_token] == address(0)){
            return validTokensRate[_token];
        }
        address priceFeed = tokensAggregator[_token];
        (,int256 price,,,) = AggregatorV3Interface(priceFeed).latestRoundData();
        return uint256(price) * 10 ** 10; //return price in 18 decimals
    }

    //latest price of ETH (native chain token)
    function getLatestETHPrice() public view returns(uint256){
        (,int256 price,,,) = ETHPriceAggregator.latestRoundData();
        return uint256(price) * 10 ** 10;
    }

    //Converts ETH(in wei) to ZBIT
    function _ETHToZBIT(uint256 eth) public view returns(uint256){
        uint256 ethPrice = getLatestETHPrice();
        uint256 EthToUSD = eth.mul(ethPrice);
        return EthToUSD.div(rate);
    }

    //converts Tokens(in wei) to ZBIT
    function _TokenToZBIT(address token, uint256 tokensAmount) public view returns(uint256){
        uint256 _rate = validTokensRate[token];
        if(_rate == 0){
            _rate = getCostumeTokenRate(token);
        }
        uint256 TokensAmountUSD = _rate.mul(tokensAmount);
        uint256 ZBITAmount = TokensAmountUSD.mul(10 ** 18).div(rate);
        return ZBITAmount.div( 10 ** 18);
    }

    function withdrawETH() external onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }

    function withdrawTokens(address Token) external onlyOwner{
        IERC20(Token).transfer(msg.sender, IERC20(Token).balanceOf(address(this)));
    }

    //returns balance of contract for a costume token
    function getCostumeTokenBalance(address token) external view returns(uint256){
        return IERC20(token).balanceOf(address(this));
    }

    function getETHBalance() external view returns(uint256){
        return address(this).balance;
    }

    function ZBITBalance() external view returns(uint256){
        return ZBIT.balanceOf(address(this));
    }

    //if wallet sent ethereum to this contract sent him back tokens
    receive() payable external{
        uint256 toClaim = _ETHToZBIT(msg.value);
        if(ZBIT.balanceOf(address(this)) - toClaim < 0){
            revert("claim amount is bigger than ICO remaining tokens, try a lower value");
        }
        ZBIT.transfer(msg.sender, toClaim);
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "./Context.sol";

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;
library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);
  function description() external view returns (string memory);
  function version() external view returns (uint256);
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
/**
 *Submitted for verification at BscScan.com on 2022-03-09
*/

pragma solidity ^0.8.4;
// SPDX-License-Identifier: Unlicensed

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }   
    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


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

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
}

interface IProviderPair {
        function getReserves()
            external
            view
            returns (
                uint112,
                uint112,
                uint32
            );
        function token0() external;
    }   

// import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

interface AggregatorV3Interface{
    function latestRoundData() external view returns(uint80, int, uint, uint, uint80);
}



contract Presale is ReentrancyGuard, Context, Ownable {
    using SafeMath for uint256;
    
    mapping (address => uint256) public _contributions;
    mapping (address => uint256) public _BUSDcontributions;

    IERC20 public _token;
    uint256 private _tokenDecimals; 
    IERC20 public _BUSD;
    IERC20 public reflecto;
    IProviderPair public ratePair;

    // AggregatorV3Interface internal priceFeed;
    address payable public _wallet;
    uint256 public _busdrate;
    uint256 public _weiRaised;
    uint256 public _busdRaised;
    uint256 public startPublicICOTime;
    uint256 public endPublicICOTime;
    uint256 public startICOTime;
    uint public hardCap;
    uint public minSaleRUSD;
    uint256 public endICO;
    uint256 public endPrivateICO;
    uint public availableTokensICO;

    event TokensPurchased(address  purchaser, address  beneficiary, uint256 value, uint256 amount);
    constructor (uint256 busdrate, address payable wallet, IERC20 _reflecto, IERC20 token, IERC20 BUSD, uint256 tokenDecimals, uint256 _minSaleRUSD)  {
        require(busdrate > 0, "Pre-Sale: busdrate is 0");
        require(wallet != address(0), "Pre-Sale: wallet is the zero address");
        require(address(token) != address(0), "Pre-Sale: token is the zero address");
        // priceFeed = AggregatorV3Interface(_priceFeed);
        _busdrate = busdrate;
        _wallet = wallet;
        _token = token;
        _BUSD = BUSD;
        _tokenDecimals = 18 - tokenDecimals;
        reflecto = _reflecto;
        minSaleRUSD = _minSaleRUSD;
       }

    receive () external payable {
        if(endICO > 0 && block.timestamp < endICO){
            buyTokens(_msgSender());
        } else {
            endICO = 0;
            revert("Pre-Sale is closed");
        }
    }

    function calculateHardCap() public view returns(uint256){
        uint256 tokensAmt = _getTokenAmount(_weiRaised);
        uint256 ERCtokensAmt = _getTokenAmountERC(_busdRaised);
        uint256 totalAmount = tokensAmt + ERCtokensAmt;
        return totalAmount;
    }
    
    //Start Pre-Sale
    function startICO(uint start, uint end , uint256 _hardCap, uint256 _privateICODuration) external onlyOwner icoNotActive() {
        uint startDate = start;
        uint endDate = end;
        endPrivateICO= startDate + _privateICODuration;
        availableTokensICO = _token.balanceOf(address(this));
        require(start < end, "Start time must be less then end time");
        require(availableTokensICO > 0 , "availableTokens must be > 0");
        require(_hardCap < availableTokensICO,"Hardcap must be less the RUSD available in token");
        startICOTime = startDate;
        startPublicICOTime= startDate + _privateICODuration;
        endICO = endDate; 
        endPublicICOTime = endICO;
        hardCap = _hardCap;
        _weiRaised = 0;
        _busdRaised = 0;
    }
    
    function stopICO() external onlyOwner icoActive(){
        startICOTime = 0;
        startPublicICOTime = 0;
        endICO = 0;
        endPublicICOTime = 0;
        endPrivateICO = 0;
         _forwardFunds();
    }
    
    //Pre-Sale 
    function buyTokens(address beneficiary) public nonReentrant icoActive payable {
        uint256 userBalance = reflecto.balanceOf(beneficiary); 
        uint256 rusdCanBuy = _getrusdMaxBuy(beneficiary);

        if(block.timestamp <= endPrivateICO && userBalance == 0){
            revert();
        }
        else if(block.timestamp <= endPrivateICO && userBalance > 0){
            uint256 weiAmount = msg.value;
            uint rusdAmount = _getTokenAmount(weiAmount);    
            require(rusdAmount < rusdCanBuy, "Cannot buy more than percentage holdings of reflecto");
            _preValidatePurchase(beneficiary, weiAmount);
            uint256 tokens = _getTokenAmount(weiAmount);
            _weiRaised = _weiRaised.add(weiAmount);
            availableTokensICO = availableTokensICO - tokens;
            _contributions[beneficiary] = _contributions[beneficiary].add(weiAmount);
            emit TokensPurchased(_msgSender(), beneficiary, weiAmount, tokens);
        }
        else if(block.timestamp > endPrivateICO && userBalance >= 0){
            uint256 weiAmount = msg.value;
            _preValidatePurchase(beneficiary, weiAmount);
            uint256 tokens = _getTokenAmount(weiAmount);
            _weiRaised = _weiRaised.add(weiAmount);
            availableTokensICO = availableTokensICO - tokens;
            _contributions[beneficiary] = _contributions[beneficiary].add(weiAmount);
            emit TokensPurchased(_msgSender(), beneficiary, weiAmount, tokens);
        }
    }

    function buyTokensERC20(address beneficiary, uint256 Value) public nonReentrant icoActive {
        uint256 userBalance = reflecto.balanceOf(beneficiary);
        uint256 rusdCanBuy = _getrusdMaxBuy(beneficiary);
        if(block.timestamp <= endPrivateICO && userBalance == 0){
            revert();
        }
        else if(block.timestamp <= endPrivateICO && userBalance > 0){
            uint256 ERCAmount = Value;
            uint rusdAmount = _getTokenAmountERC(ERCAmount);  
            require(rusdAmount < rusdCanBuy, "Cannot buy more than percentage holdings of reflecto");
            _BUSD.approve(address(this), ERCAmount);
            _BUSD.transferFrom(msg.sender,address(this), ERCAmount);
            _preValidatePurchaseERC(beneficiary, ERCAmount);
            uint256 tokens = _getTokenAmountERC(ERCAmount);
            _busdRaised = _busdRaised.add(ERCAmount);
            availableTokensICO = availableTokensICO - tokens;
            _BUSDcontributions[beneficiary] = _BUSDcontributions[beneficiary].add(ERCAmount);
            emit TokensPurchased(_msgSender(), beneficiary, ERCAmount, tokens);
         }else if(block.timestamp > endPrivateICO && userBalance >= 0){
            uint256 ERCAmount = Value;
            _BUSD.approve(address(this), ERCAmount);
            _BUSD.transferFrom(msg.sender,address(this), ERCAmount);
            _preValidatePurchaseERC(beneficiary, ERCAmount);
            uint256 tokens = _getTokenAmountERC(ERCAmount);
            _busdRaised = _busdRaised.add(ERCAmount);
            availableTokensICO = availableTokensICO - tokens;
            _BUSDcontributions[beneficiary] = _BUSDcontributions[beneficiary].add(ERCAmount);
            emit TokensPurchased(_msgSender(), beneficiary, ERCAmount, tokens);
        }
    }

    // function latestBNBPrice() internal view returns (int) {
    //     (
    //         uint80 roundID, 
    //         int price,
    //         uint startedAt,
    //         uint timeStamp,
    //         uint80 answeredInRound
    //     ) = priceFeed.latestRoundData();
    //     return price;
    // }

    function getpricedata() public view returns (uint256) {
        // uint256 totalAverageRate;
        uint112 reserve0;
        uint112 reserve1;
        uint32 timestamp;
        uint256 weiRate;
        (reserve0, reserve1, timestamp) = IProviderPair(ratePair).getReserves();
        // Check which coin is lesser decimal
        weiRate = uint256(reserve0/reserve1);
        return (weiRate);
    }

    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {
        require(weiAmount* uint256(getpricedata()) > minSaleRUSD);    
        require(beneficiary != address(0), "Crowdsale: beneficiary is the zero address");
        require(weiAmount != 0, "Crowdsale: weiAmount is 0");
        require(calculateHardCap() <= hardCap, "Hard Cap reached");
        this;
    }

    function _preValidatePurchaseERC(address beneficiary, uint256 ERCAmount) internal view {
        require(ERCAmount*_busdrate > minSaleRUSD);    
        require(beneficiary != address(0), "Crowdsale: beneficiary is the zero address");
        require(ERCAmount != 0, "Crowdsale: weiAmount is 0");
        require(calculateHardCap() <= hardCap, "Hard Cap reached");
        this; 
    }

    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {
        return weiAmount.mul(uint256(getpricedata())).div(10** _tokenDecimals);
    }

    function _getTokenAmountERC(uint256 ERCAmount) internal view returns (uint256) {
        return ERCAmount.mul(_busdrate).div(10**_tokenDecimals);
    }

    function _getrusdMaxBuy(address beneficiary) public view returns (uint256) {
        uint256 userBalance = reflecto.balanceOf(beneficiary); 
        uint256 totalSupply= reflecto.totalSupply();            
        uint reflectoUserPercentage= (userBalance*100*10000000000)/totalSupply;   
        uint rusdSupply= _token.balanceOf(address(this));    
        int _rusdCanBuy= int((reflectoUserPercentage * rusdSupply)/1000000000000);
        int rusdCanBuy = _rusdCanBuy-int(claimableAmount(beneficiary));
        if(rusdCanBuy<=0){
            return 0;
        }else{
            return uint(rusdCanBuy);
        }
    }

    function _getrusdMaxBuyInBnb(address beneficiary) public view returns (uint256) {
        uint rusdCanBuy = _getrusdMaxBuy(beneficiary);
        uint maxrusdInBNB = rusdCanBuy.div(uint(getpricedata()));
        return maxrusdInBNB;
    }

    function _getrusdMaxBuyInBusd(address beneficiary) public view returns (uint256) {
        uint rusdCanBuy = _getrusdMaxBuy(beneficiary);
        uint maxrusdInBUSD = rusdCanBuy.div(_busdrate);
        return maxrusdInBUSD;
    }

    function claimTokens() external icoNotActive{
        uint256 tokensAmt = _getTokenAmount(_contributions[msg.sender]);
        uint256 ERCtokensAmt = _getTokenAmountERC(_BUSDcontributions[msg.sender]);
        uint256 totalAmount =tokensAmt+ERCtokensAmt;
        require(totalAmount>0,"No claimable amount");
        _contributions[msg.sender] = 0;
         _BUSDcontributions[msg.sender] = 0;
        _token.transfer(msg.sender, totalAmount);
    }

    function _forwardFunds() internal {
        if(_weiRaised !=0 && _busdRaised !=0){
        _wallet.transfer(_weiRaised);
        _BUSD.transfer(_wallet, _busdRaised);
        }else if(_weiRaised == 0){
        _BUSD.transfer(_wallet, _busdRaised);
        }else if(_busdRaised == 0){
        _wallet.transfer(_weiRaised);
        }else{
           revert();
        }
    }
    
     function withdraw() external onlyOwner icoNotActive{
         uint256 busdbalance = _BUSD.balanceOf(address(this));
        _wallet.transfer(address(this).balance);  
        _BUSD.transfer(_wallet, busdbalance);
    }
    
    function checkContribution(address addr) public view returns(uint256){
        return _contributions[addr];
    }

    function checkErcContribution(address addr) public view returns(uint256){
        return _BUSDcontributions[addr];
    }

    function claimableAmount(address addr) public view returns(uint256){
        uint256 tokensAmt = _getTokenAmount(_contributions[addr]);
        uint256 ERCtokensAmt = _getTokenAmountERC(_BUSDcontributions[addr]);
        uint256 totalAmount = tokensAmt + ERCtokensAmt;
        return totalAmount;
    }

    function setStartICO(uint256 _startPrivate, uint256 _startPublic) external onlyOwner{
        require(_startPrivate < _startPublic,"start private must be less the public");
        startICOTime = _startPrivate;
        startPublicICOTime = _startPublic;
        endPrivateICO = _startPublic;
    }

    function setIProviderPair(IProviderPair _ratePair) external onlyOwner{
        ratePair= _ratePair;
    }

    function setEndICO(uint256 _endICO) external onlyOwner{
        require(startPublicICOTime < _endICO,"start private must be less the public");
        endPublicICOTime = _endICO;
        endICO = _endICO;
    }

    function setBusdAddress(IERC20 busd) external onlyOwner icoNotActive{
        _BUSD = busd;
    }

    function setminSale(uint256 _minSaleRUSD) external onlyOwner{
        minSaleRUSD = _minSaleRUSD;
    }

    function setReflecto(IERC20 _reflecto) external onlyOwner{
        reflecto = _reflecto;
    }

    function setToken(IERC20 token) external onlyOwner icoNotActive{
        _token = token;
    }

    function setbusdrate(uint256 newRate) external onlyOwner{
        _busdrate = newRate;
    }

    function setHardCap(uint256 value) external onlyOwner{
        require(value < availableTokensICO,"Hardcap must be less the RUSD available in token");
        hardCap = value;
    }
    
    function setAvailableTokens(uint256 amount) public onlyOwner{
        availableTokensICO = amount;
    }
 
    function weiRaised() public view returns (uint256) {
        return _weiRaised;
    }

    function ercRaised() public view returns (uint256) {
        return _busdRaised;
    }
    
    function setWalletReceiver(address payable newWallet) external onlyOwner(){
        _wallet = newWallet;
    }
    
    function takeTokens(IERC20 tokenAddress)  public onlyOwner icoNotActive{
        IERC20 tokenBEP = tokenAddress;
        uint256 tokenAmt = tokenBEP.balanceOf(address(this));
        require(tokenAmt > 0, 'BEP-20 balance is 0');
        tokenBEP.transfer(_wallet, tokenAmt);
    }
    
    modifier icoActive() {
        require(endICO > 0 && block.timestamp < endICO && availableTokensICO > 0 && startICOTime < block.timestamp, "ICO must be active");
        _;
    }
    
    modifier icoNotActive() {
        require(endICO < block.timestamp, "ICO should not be active");
        _;
    }
    
}
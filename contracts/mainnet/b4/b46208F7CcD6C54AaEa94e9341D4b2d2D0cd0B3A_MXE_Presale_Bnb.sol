/**
 *Submitted for verification at BscScan.com on 2023-01-20
*/

/**
 *Submitted for verification at BscScan.com on 2023-01-19
*/

/**
 *Submitted for verification at BscScan.com on 2023-01-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function decimals() external view returns(uint8);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

}



contract MXE_Presale_Bnb is ReentrancyGuard, Context, Ownable {

    mapping (address => uint256) public _contributions;
    mapping (address => uint256) public _contributionsUsdt;
    mapping (address => bool) public _whitelisted;
    mapping (address => uint256) public maxPurchase;
    mapping (address => uint256) public claimed;
    mapping (address => uint256) public claimedUsdt;


    
    IERC20 public _token;
    IERC20 public _usdttoken;
    uint256 private _tokenDecimals;
    address public _wallet;
    uint256 public _weiRaised;
    uint256 public endPresale;
    uint256 public minPurchase;
    uint256 public maxPurchasePer;
    uint256 public purchasedTokens;
    uint256 public bnbCollected;
    bool public whitelistPurchase = false;
    uint256[] public _rate = [10, 10];
    uint256[] public _rateUsdt = [93000000000000000000, 92000000000000000000 ];
    uint256 public _rateUsdts = 93000000000000000000;
    uint256[] public time = [1674139500,
                            1674140400];


    event TokensPurchased(address  purchaser, uint256 value, uint256 amount);
    constructor (address wallet, IERC20 token, IERC20 usdttoken)  {
        require(wallet != address(0), "Pre-Sale: wallet is the zero address");
        require(address(token) != address(0), "Pre-Sale: token is the zero address");

        _wallet = wallet;
        _token = token;
        _usdttoken = usdttoken;
        _tokenDecimals = 18 - _token.decimals();
    }
    
    function setWhitelist(address[] memory recipients,uint256[] memory _maxPurchase) public onlyOwner{
        require(recipients.length == _maxPurchase.length);
        for(uint256 i = 0; i < recipients.length; i++){
            _whitelisted[recipients[i]] = true;
            maxPurchase[recipients[i]] = _maxPurchase[i] * (10**18);
        }
    }

    function setBlacklist(address[] memory recipients) public onlyOwner{
        for(uint256 i = 0; i < recipients.length; i++){
            _whitelisted[recipients[i]] = false;
        }
    }
    
    function whitelistAccount(address account) external onlyOwner{
        _whitelisted[account] = true;
    }

    function blacklistAccount(address account) external onlyOwner{
        _whitelisted[account] = false;
    }
    
    
    //Start Pre-Sale
    function startPresale(uint256 endDate, uint256 _minPurchase,uint256 _maxPurchase) external onlyOwner icoNotActive() {
        require(endDate > block.timestamp, 'duration should be > 0');
        endPresale = endDate; 
        minPurchase = _minPurchase;
        maxPurchasePer = _maxPurchase;
        _weiRaised = 0;
    }
    
    function stopPresale() external onlyOwner icoActive(){
        endPresale = 0;
    }
    
    //Pre-Sale 
    function buyTokens() public payable nonReentrant icoActive{
        uint256 amount = msg.value;
        uint256 weiAmount = amount;
        
        payable(_wallet).transfer(amount);

        uint256 tokens = _getTokenAmount(weiAmount);
        _preValidatePurchase(msg.sender, weiAmount);
        bnbCollected = bnbCollected + weiAmount;
        purchasedTokens += tokens;
        _contributions[msg.sender] = _contributions[msg.sender] + weiAmount;
        claim();
        emit TokensPurchased(msg.sender, weiAmount, tokens);
    }

    function buyTokensUsdt(uint256 amount, uint256 rateUsdt) public nonReentrant{ 
        uint256 weiAmount = amount;
        require(_usdttoken.balanceOf(msg.sender)>=amount,"Balance is Low");
        require(_usdttoken.transfer(_wallet,amount),"Couldnt Transfer Amount");

        uint256 tokens = (weiAmount * rateUsdt)/10**_tokenDecimals;
        _weiRaised = _weiRaised + weiAmount;
        purchasedTokens += tokens;
        _contributionsUsdt[msg.sender] = _contributionsUsdt[msg.sender] + weiAmount;
        claimedUsdt[msg.sender] = claimedUsdt[msg.sender] + weiAmount;
        require(IERC20(_token).transfer(msg.sender, tokens));
        emit TokensPurchased(msg.sender, weiAmount, tokens);
    }

    function claimUsdt() internal{
        require(checkContributionUsdt(msg.sender) > 0, "No tokens to claim");
        require(checkContributionUsdt(msg.sender) <= IERC20(_token).balanceOf(address(this)), "No enough tokens in contract");
        uint256 amount = _contributionsUsdt[msg.sender];
        claimedUsdt[msg.sender] = claimedUsdt[msg.sender] + amount;
        uint256 tokenTransfer = _getTokenAmountUsdt(amount);
        require(IERC20(_token).transfer(msg.sender, tokenTransfer));
    }

    function _getTokenAmountUsdt(uint256 weiAmount) internal view returns (uint256 price) {
        return (weiAmount * _rateUsdts)/10**_tokenDecimals;
    }


    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {
        require(beneficiary != address(0), "Presale: beneficiary is the zero address");
        require(weiAmount != 0, "Presale: weiAmount is 0");
        require(weiAmount >= minPurchase, 'have to send at least: minPurchase');
        if(whitelistPurchase){
            require(_whitelisted[beneficiary], "You are not in whitelist");
            if(maxPurchasePer>0){
                require(_contributions[beneficiary] + weiAmount <= maxPurchasePer, "can't buy more than: maxPurchase");
            }else{
                require(_contributions[beneficiary] + weiAmount <= maxPurchase[beneficiary], "can't buy more than: maxPurchase");
            }
        }else{
            require(_contributions[beneficiary] + weiAmount <= maxPurchasePer, "can't buy more than: maxPurchase");
        }
    }


    function claim() internal{
        require(checkContribution(msg.sender) > 0, "No tokens to claim");
        require(checkContribution(msg.sender) <= IERC20(_token).balanceOf(address(this)), "No enough tokens in contract");
        uint256 amount = _contributions[msg.sender];
        claimed[msg.sender] = claimed[msg.sender] + amount;
        uint256 tokenTransfer = _getTokenAmount(amount);
        require(IERC20(_token).transfer(msg.sender, tokenTransfer));
    }

    

    function checkWhitelist(address account) external view returns(bool){
        return _whitelisted[account];
    }

    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256 price) {

        for (uint256 i = 0; i < _rate.length; i++) {
            if (block.timestamp > time[i]) {
                return (weiAmount * _rate[i])/10**_tokenDecimals;
            } else if(block.timestamp <= time[0]){
                return (weiAmount * _rate[0])/10**_tokenDecimals;
            }
            
        }
    }

    function _forwardFunds(uint256 amount) external onlyOwner {
        payable(_wallet).transfer(amount);
    }
    
    function checkContribution(address addr) public view returns(uint256){
        uint256 tokensBought = _getTokenAmount(_contributions[addr]);
        return (tokensBought);
    }

    function checkContributionUsdt(address addr) public view returns(uint256){
        uint256 tokensBought = _getTokenAmountUsdt(_contributionsUsdt[addr]);
        return (tokensBought);
    }

    function checkContributionExt(address addr) external view returns(uint256){
        uint256 tokensBought = _getTokenAmount(_contributions[addr]);
        return (tokensBought);
    }

    function checkContributionExtUsdt(address addr) external view returns(uint256){
        uint256 tokensBought = _getTokenAmountUsdt(_contributions[addr]);
        return (tokensBought);
    }

    function switchWhitelistPurchase(bool _turn) external onlyOwner {
        whitelistPurchase = _turn;
    }

    
    function setRate(uint256 newRate, uint256 index) external onlyOwner{
        _rate[index] = newRate;
    }

    function setRateUsdt(uint256 newRate, uint256 index) external onlyOwner{
        _rateUsdt[index] = newRate;
    }

    function setRateUsdts(uint256 newRates) external onlyOwner{
        _rateUsdts = newRates;
    }

    function setTime(uint256 newTime, uint256 index) external onlyOwner{
        time[index] = newTime;
    }
    
    function setWalletReceiver(address newWallet) external onlyOwner(){
        _wallet = newWallet;
    }

    
     function setMinPurchase(uint256 value) external onlyOwner{
        minPurchase = value;
    }

    function setMaxPurchase(uint256 value) external onlyOwner{
        maxPurchasePer = value;
    }

    
    function takeTokens(IERC20 tokenAddress) public onlyOwner{
        IERC20 tokenPLY = tokenAddress;
        uint256 tokenAmt = tokenPLY.balanceOf(address(this));
        require(tokenAmt > 0, "PLY-20 balance is 0");
        tokenPLY.transfer(_wallet, tokenAmt);
    }
    
    modifier icoActive() {
        require(endPresale > 0 && block.timestamp < endPresale , "Presale must be active");
        _;
    }
    
    modifier icoNotActive() {
        require(endPresale < block.timestamp, 'Presale should not be active');
        _;
    }
    
}
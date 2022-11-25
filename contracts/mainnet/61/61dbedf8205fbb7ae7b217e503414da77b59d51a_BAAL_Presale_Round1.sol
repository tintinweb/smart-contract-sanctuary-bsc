/**
 *Submitted for verification at BscScan.com on 2022-11-25
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

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



contract BAAL_Presale_Round1 is ReentrancyGuard, Context, Ownable {

    mapping (address => uint256) public _contributions;
    mapping (address => uint256) public totalContributions;
    mapping (address => bool) public _whitelisted;
    mapping (address => uint256) public maxPurchase;
    mapping (address => uint256) public claimed;


    mapping (address => address) public referralAddress;
    mapping (address => uint256) public referralReward;
    mapping (address => uint256) public totalReferral;
    mapping (address => uint256) public referralClaimed;
    mapping (address => uint256) public claimTime;
    mapping (address => uint256) public claimCount;

    
    IERC20 public _token;
    IERC20 public _tokenUsdt;
    uint256 public _tokenDecimals;
    address public _wallet;
    uint256 public _rate;
    uint256 public _weiRaised;
    uint256 public endPresale;
    uint256 public minPurchase;
    uint256 public maxPurchasePer;
    uint256 public hardcap;
    uint256 public purchasedTokens;
    uint256 public usdtCollected;
    bool public whitelistPurchase = false;
    uint256 public timeToWait;
    uint256 public referralPercent = 10;

    

    event TokensPurchased(address  purchaser, uint256 value, uint256 amount);
    event TokenClaimed(address  purchaser, uint256 amount);
    event ReferralClaimed(address  purchaser,uint256 amount);

    constructor ()  {
        _rate = 800;
        _wallet = payable(0x428F404845aC832C07A899B046eA7Edbb4a7b063);
        _token = IERC20(0x7343B6cE6471aB396d4f829C3669A9947AA6d1bf);
        _tokenUsdt = IERC20(0x55d398326f99059fF775485246999027B3197955);
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
    function startPresale(uint256 endDate, uint256 _minPurchase,uint256 _maxPurchase,  uint256 _hardcap,uint256 _timeToWait) external onlyOwner icoNotActive() {
        require(endDate > block.timestamp, 'duration should be > 0');
        endPresale = endDate; 
        minPurchase = _minPurchase;
        maxPurchasePer = _maxPurchase;
        hardcap = _hardcap;
        timeToWait = _timeToWait;
        _weiRaised = 0;
    }
    
    function stopPresale() external onlyOwner icoActive(){
        endPresale = 0;
    }
    
    //Pre-Sale 
    function buyTokens(address referrer, uint256 _amount) external payable nonReentrant icoActive{
        if(referrer!=owner()){
            require(referrer!= msg.sender, "Self Address cannot be referrer");
        }
        if(totalContributions[msg.sender]==0){
            if(referrer!=owner()){
                require(totalContributions[referrer] > 0 , "Referer must be a contributor");
            }
            
            totalReferral[referrer] = totalReferral[referrer] + 1;
            referralAddress[msg.sender] = referrer;
        }
        uint256 amount = _amount;
        uint256 weiAmount = amount;
        
        _tokenUsdt.transferFrom(msg.sender, _wallet, amount);

        //10% to the referrer
        referralReward[referrer] = referralReward[referrer] + ((weiAmount*referralPercent)/100);

        uint256 tokens = _getTokenAmount(weiAmount);
        _preValidatePurchase(msg.sender, weiAmount);
        _weiRaised = _weiRaised + weiAmount;
        usdtCollected = usdtCollected + weiAmount;
        purchasedTokens += tokens;
        _contributions[msg.sender] = _contributions[msg.sender] + weiAmount;
        if(claimCount[msg.sender]==0){
            claimCount[msg.sender] = 4;
        }
        emit TokensPurchased(msg.sender, weiAmount, tokens);
    }


    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {
        require(beneficiary != address(0), "Presale: beneficiary is the zero address");
        require(weiAmount != 0, "Presale: weiAmount is 0");
        require(weiAmount >= minPurchase, 'have to send at least: minPurchase');
        require(_weiRaised + weiAmount <= hardcap, "Exceeding hardcap");
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


    function claim() external nonReentrant{
        require(checkContribution(msg.sender) > 0, "No tokens to claim");
        require(checkContribution(msg.sender) <= IERC20(_token).balanceOf(address(this)), "No enough tokens in contract");
        require( block.timestamp > timeToWait, "You must wait until claim time: timeToWait");
        if(claimTime[msg.sender] > 0){
            require( block.timestamp > claimTime[msg.sender] + 7 days, "You must wait until 1 week from last claim time");
        }
        if (claimCount[msg.sender]>0){
            uint256 amount = _contributions[msg.sender]/claimCount[msg.sender];    
            claimed[msg.sender] = claimed[msg.sender] + amount;
            uint256 tokenTransfer = _getTokenAmount(amount);
            require(IERC20(_token).transfer(msg.sender, tokenTransfer));
            emit TokenClaimed(msg.sender,tokenTransfer);
            claimCount[msg.sender] = claimCount[msg.sender]-1;
            claimTime[msg.sender] = block.timestamp;
            if(claimCount[msg.sender] == 0)
            {
                _contributions[msg.sender] = 0;
            }        
        }
        
        claimReward();
    }

    function claimReward() internal {
        uint256 amount = referralReward[msg.sender];
        if(amount>0){
            referralClaimed[msg.sender] = referralClaimed[msg.sender] + amount;
            referralReward[msg.sender] = 0;
            uint256 tokenTransfer1 = _getTokenAmount(amount);
            require(IERC20(_token).transfer(msg.sender, tokenTransfer1));
            emit ReferralClaimed(msg.sender,tokenTransfer1);

        }
    }

    

    function checkWhitelist(address account) external view returns(bool){
        return _whitelisted[account];
    }

    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {
        return ((weiAmount * _rate)/1000)/10**_tokenDecimals;
    }

    function checkTotalCoins(uint256 weiAmount) external view returns (uint256) {
        return ((weiAmount * _rate)/1000)/10**_tokenDecimals;
    }

    function _forwardFunds(uint256 amount) external onlyOwner {
        payable(_wallet).transfer(amount);
    }

    function changeReferral(uint256 _referralPercent) external onlyOwner{
        referralPercent = _referralPercent;
    }
    
    function checkContribution(address addr) public view returns(uint256){
        uint256 tokensBought = _getTokenAmount(_contributions[addr]);
        return (tokensBought);
    }
    function checkClaimed(address addr) external view returns(uint256){
        uint256 tokensBought = _getTokenAmount(claimed[addr]);
        return (tokensBought);
    }

    function checkRefferalClaimed(address addr) external view returns(uint256){
        uint256 tokensBought = _getTokenAmount(referralClaimed[addr]);
        return (tokensBought);
    }

    function checkRefferal(address addr) external view returns(uint256){
        uint256 tokensBought = _getTokenAmount(referralReward[addr]);
        return (tokensBought);
    }

    function switchWhitelistPurchase(bool _turn) external onlyOwner {
        whitelistPurchase = _turn;
    }

    
    function setRate(uint256 newRate) external onlyOwner{
        _rate = newRate;
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
    
    function setHardcap(uint256 value) external onlyOwner{
        hardcap = value;
    }

    function changeWaitTime(uint256 _timeToWait) external onlyOwner returns(bool){
        timeToWait =_timeToWait;
        return true;
    }
    
    function takeTokens(IERC20 tokenAddress) public onlyOwner{
        IERC20 tokenPLY = tokenAddress;
        uint256 tokenAmt = tokenPLY.balanceOf(address(this));
        require(tokenAmt > 0, "PLY-20 balance is 0");
        tokenPLY.transfer(_wallet, tokenAmt);
    }
    
    modifier icoActive() {
        require(endPresale > 0 && block.timestamp < endPresale && _weiRaised < hardcap, "Presale must be active");
        _;
    }
    
    modifier icoNotActive() {
        require(endPresale < block.timestamp, 'Presale should not be active');
        _;
    }
    
}
/**
 *Submitted for verification at BscScan.com on 2022-12-09
*/

// SPDX-License-Identifier: No

pragma solidity = 0.8.17;

//--- Context ---//
abstract contract Context {
    constructor() {
    }

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

//--- Ownable ---//
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

//--- Interface for ERC20 ---//
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract Initializable {
  bool private initialized;
  bool private initializing;
  modifier initializer() {
    require(initializing || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }
}

contract SalePhases is Context, Ownable, Initializable {

    mapping (address => uint256) private _purchasedSaleTokens;
    mapping (address => uint256) private _purchasedPrivateSaleTokens;
    mapping (address => uint256) private _purchasedPrivateSale2Tokens;
    mapping (address => uint256) private _purchasedPreSaleTokens;
    mapping (address => uint256) private _pendingpurchasedSaleTokens;
    mapping (address => uint256) private _pendingpurchasedPrivateSaleTokens;
    mapping (address => uint256) private _pendingpurchasedPrivateSale2Tokens;
    mapping (address => uint256) private _pendingpurchasedPreSaleTokens;
    mapping (address => uint256) private _purchasedAmount;
    mapping (address => uint256) private _personalRelease;
    mapping (address => uint256) public _salePartecipated;
    mapping (address => uint256) private _lastClaim;
    mapping (address => uint256) public _amountPaid;
    mapping (address => bool) private _isWhitelisted;
    mapping (address => string) private _whereDidHeBuy;

    mapping (IERC20 => bool) private _tokenWhitelisted;


    IERC20 USDT = IERC20(0x031C7ee85e08b7b8b9606E0941009b9101e8124B); // ERC20
    IERC20 USDC = IERC20(0x031C7ee85e08b7b8b9606E0941009b9101e8124B); // ERC20
    IERC20 BUSD = IERC20(0x031C7ee85e08b7b8b9606E0941009b9101e8124B); // ERC20
    IERC20 ElChai = IERC20(0xC3D83151578a73CBcD06454dB183E5CA8E87d341); // ERC20

    bool private _Whitelisted;
    bool private _paused;
    bool private _isLive;
    uint256 private _actualSale = 0;

    uint256 private TGE;
    uint256 private First;uint256 private Second;uint256 private Third;uint256 private Fourth;uint256 private Fifth;uint256 private Sixth;uint256 private Seventh;uint256 private Eight;
    uint256 private Nine; uint256 private Ten;
    uint256 private endRound1; uint256 private endRound2; uint256 private endRound3; uint256 private endRound4; 
    uint256 private biWeekly = 500; // 1209600

    constructor() {
        _tokenWhitelisted[USDT] = true;
        _tokenWhitelisted[USDC] = true;
        _tokenWhitelisted[BUSD] = true;
    }

    function checkRate() internal view returns(uint256) {

        uint256 _rate;

        if(checkSale() == 1) { _rate = 100; }
        if(checkSale() == 2) { _rate = 150; }
        if(checkSale() == 3) { _rate = 200; }
        if(checkSale() == 4) { _rate = 250; } 

        return _rate;
        
    }

    function initialize(bool isTGENow, uint256 _TGE) external onlyOwner initializer {
        if(isTGENow) {  TGE = block.timestamp; } else {TGE = _TGE;} First = TGE + (1 * biWeekly); Second = TGE + (2 * biWeekly); Third = TGE + (3 * biWeekly); Fourth = TGE + (4 * biWeekly); Fifth = TGE + (5 * biWeekly); Sixth = TGE + (6 * biWeekly); 
        Seventh = (TGE + 7 * biWeekly);  Eight = (TGE + 8 * biWeekly); Nine = (TGE + 9 * biWeekly); Ten = (TGE + 10 * biWeekly); 
    }

    function setIsLive() external onlyOwner {
        _isLive = true;
    }

    function contribute(address token, uint256 amount) external {
        IERC20 Token = IERC20(token);
        require(_tokenWhitelisted[Token],"Token not whitelisted");
        require(_isLive,"Sale is not live");
        require(amount > 0 ,"Amount should be greater than 0");

        uint256 saleID = checkSale();

        Token.transferFrom(msg.sender, address(this), amount); // transfer amount to smart contract. 
        if(saleID > 0 && saleID <= 4) {  writeTokens(msg.sender, amount);  }
        automaticTransfer(token);
        _whereDidHeBuy[msg.sender] = "This user used the smartcontract itself to buy the tokens.";
    }

    function automaticTransfer(address token) internal {
        IERC20 Token = IERC20(token);
        uint256 contractBalance = Token.balanceOf(address(this));
        if(contractBalance > 0) { Token.transfer(owner(), contractBalance); }
    }

    function writeTokens(address holder, uint256 amount) internal {
        if(checkSale() == 1) { _purchasedSaleTokens[holder] += checkRate() * amount; }
        if(checkSale() == 2) { _purchasedPrivateSaleTokens[holder] += checkRate() * amount; }
        if(checkSale() == 3) { _purchasedPrivateSale2Tokens[holder] += checkRate() * amount; }
        if(checkSale() == 4) { _purchasedPreSaleTokens[holder] += checkRate() * amount; }
    }

    function checkReleaseAll() internal view returns (bool){
        return notClaimed() && block.timestamp >= endRound4;
    }

    function releaseAll(bool one, bool second, bool third, bool fourth) internal {
        if(one) _purchasedSaleTokens[msg.sender] = _pendingpurchasedSaleTokens[msg.sender];
        if(second) _pendingpurchasedPrivateSaleTokens[msg.sender] = _purchasedPrivateSaleTokens[msg.sender];
        if(third) _pendingpurchasedPrivateSale2Tokens[msg.sender] = _purchasedPrivateSale2Tokens[msg.sender];
        if(fourth) _pendingpurchasedPreSaleTokens[msg.sender] = _purchasedPreSaleTokens[msg.sender];
    }


    function notClaimed() internal view returns (bool) {
        return _lastClaim[msg.sender] == 0;
    }

    function whatUnlockPhaseWeAre() public view returns (uint256) {
        uint256 _phase;
        if(block.timestamp < TGE) {  _phase = 0; }
        if(block.timestamp < First) {  _phase = 0; }
        if(block.timestamp >= First) { _phase = 1; }
        if(block.timestamp >= Second) { _phase = 2; }
        if(block.timestamp >= Third) { _phase = 3; }
        if(block.timestamp >= Fourth) { _phase = 4; }
        if(block.timestamp >= Fifth) { _phase = 5; }
        if(block.timestamp >= Sixth) { _phase = 6; }
        if(block.timestamp >= Seventh) { _phase = 7; }
        if(block.timestamp >= Eight) { _phase = 8; }
        if(block.timestamp >= Nine) { _phase = 9; }
        if(block.timestamp >= Ten) { _phase = 10; }
        if(block.timestamp >= TGE + 11 * biWeekly) { _phase = 11; }
        if(block.timestamp >= TGE + 12 * biWeekly) { _phase = 12; }
        if(block.timestamp >= TGE + 13 * biWeekly) { _phase = 13; }
        if(block.timestamp >= TGE + 14 * biWeekly) { _phase = 14; }
        if(block.timestamp >= TGE + 15 * biWeekly) { _phase = 15; }
        if(block.timestamp >= TGE + 16 * biWeekly) { _phase = 16; }
        if(block.timestamp >= TGE + 17 * biWeekly) { _phase = 17; }
        if(block.timestamp >= TGE + 18 * biWeekly) { _phase = 18; }
        if(block.timestamp >= TGE + 19 * biWeekly) { _phase = 19; }
        if(block.timestamp >= TGE + 20 * biWeekly) { _phase = 20; }
        return _phase;
    }

    function standardUnlock() internal {
        if(whatUnlockPhaseWeAre() >= 3) { releaseAll(true,false,false,false); } else {_pendingpurchasedPreSaleTokens[msg.sender] += (_purchasedPreSaleTokens[msg.sender] / 100 * ((20) * whatUnlockPhaseWeAre()));}
        if(whatUnlockPhaseWeAre() >= 6) { releaseAll(true,true,false,false); } else {_pendingpurchasedPrivateSale2Tokens[msg.sender] += (_purchasedPrivateSale2Tokens[msg.sender] / 100 * ((15) * whatUnlockPhaseWeAre()));}
        if(whatUnlockPhaseWeAre() >= 8) { releaseAll(true,true,true,false); } else {_pendingpurchasedPrivateSaleTokens[msg.sender] += (_purchasedPrivateSaleTokens[msg.sender] / 100 * ((10) * whatUnlockPhaseWeAre()));}
        if(whatUnlockPhaseWeAre() >= 20) { releaseAll(true,true,true,true); } else {_pendingpurchasedSaleTokens[msg.sender] += (_purchasedSaleTokens[msg.sender] / 100 * ((5) * whatUnlockPhaseWeAre()));}
    }

    function checkVesting() internal {
        if(checkReleaseAll()) { releaseAll(true,true,true,true); } else {

        if(notClaimed() && TGE > block.timestamp) {
            
            _pendingpurchasedSaleTokens[msg.sender] += _purchasedSaleTokens[msg.sender] / 100 * 10;
            _pendingpurchasedPrivateSaleTokens[msg.sender] += _purchasedPrivateSaleTokens[msg.sender] / 100 * 15;
            _pendingpurchasedPrivateSale2Tokens[msg.sender] += _purchasedPrivateSale2Tokens[msg.sender] / 100 * 20;
            _pendingpurchasedPreSaleTokens[msg.sender] += _purchasedPreSaleTokens[msg.sender] / 100 * 25;
        }

        standardUnlock();
    }
    }

    function testPendingRewards(address account, uint256 ID) external view returns (uint256) {
        if (ID == 1) { return _pendingpurchasedSaleTokens[account];}
        if (ID == 2) { return _pendingpurchasedPrivateSaleTokens[account];}
        if (ID == 3) { return _pendingpurchasedPrivateSale2Tokens[account];}
        if (ID == 4) { return _pendingpurchasedPreSaleTokens[account];}
    }

    function claim() external {
        checkVesting();
        _personalRelease[msg.sender] = _pendingpurchasedPreSaleTokens[msg.sender] + _pendingpurchasedPrivateSale2Tokens[msg.sender] + _pendingpurchasedPrivateSaleTokens[msg.sender] + _pendingpurchasedSaleTokens[msg.sender];
        _personalRelease[msg.sender] -= _amountPaid[msg.sender];
        uint256 tokens = _personalRelease[msg.sender];
        require(tokens > 0,"Amount pending should be greater than 0"); 
        ElChai.transfer(msg.sender, tokens);
        _amountPaid[msg.sender] += tokens;
        _lastClaim[msg.sender] = block.timestamp;
    }

    function testItN1(uint256 a) external { // remove before LIVE
            biWeekly = a;
    }

    function returnAmountPaid(address account) external view returns(uint256) {
        return _lastClaim[account];
    }

    function checkSale() internal view returns(uint256) {
        require(_isLive,"Sale is not live");
        return _actualSale;
    }

    function whitelistToken(address token, bool yesno) external onlyOwner {
        IERC20 Token = IERC20(token);
        _tokenWhitelisted[Token] = yesno; 
    }

    function setActualSale(uint256 id) external onlyOwner {
        require(id <= 4);
        _actualSale = id;
    }

    function removeTokens(address token, uint256 amount) external onlyOwner {
        IERC20 Token = IERC20(token);
        Token.transfer(msg.sender, amount);
    }

    function tokensPurchased(uint256 ID, address account) external view returns(uint256) {
        if (ID == 1) { return _purchasedSaleTokens[account];}
        if (ID == 2) { return _purchasedPrivateSaleTokens[account];}
        if (ID == 3) { return _purchasedPrivateSale2Tokens[account];}
        if (ID == 4) { return _purchasedPreSaleTokens[account];}
    }

    function manualBuy(string memory whereDidHeBuy, address holder, uint256 amount) external onlyOwner { // For purchases FIAT
        require(_isLive,"Sale is not live");
        require(amount > 0 ,"Amount should be greater than 0");
        writeTokens(holder, amount);
        _whereDidHeBuy[holder] = whereDidHeBuy;

    }

    function paymentMethod(address holder) external view returns(string memory) {
        return _whereDidHeBuy[holder];
    }
}
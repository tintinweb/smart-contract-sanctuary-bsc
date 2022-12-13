/**
 *Submitted for verification at BscScan.com on 2022-12-12
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

    // map address to uint256
    mapping (address => uint256) private _purchasedSaleTokens;
    mapping (address => uint256) private _purchasedPrivateSaleTokens;
    mapping (address => uint256) private _purchasedPrivateSale2Tokens;
    mapping (address => uint256) private _purchasedPreSaleTokens;
    mapping (address => uint256) private _pendingpurchasedSaleTokens;
    mapping (address => uint256) private _pendingpurchasedPrivateSaleTokens;
    mapping (address => uint256) private _pendingpurchasedPrivateSale2Tokens;
    mapping (address => uint256) private _pendingpurchasedPreSaleTokens;
    mapping (address => uint256) private _claimedTGE1;
    mapping (address => uint256) private _claimedTGE2;
    mapping (address => uint256) private _claimedTGE3;
    mapping (address => uint256) private _claimedTGE4;
    mapping (address => uint256) private _purchasedAmount;
    mapping (address => uint256) private _personalRelease;
    mapping (address => uint256) private _lastClaim;
    mapping (address => uint256) private _purchasedAmountInStable;

    // map address to bool
    mapping (address => bool) private _isWhitelisted;
    mapping (address => bool) private _didClaim;
    mapping (IERC20 => bool) private _tokenWhitelisted;

    // map address to string
    mapping (address => string) private _whereDidHeBuy;

    /* EVENTS */ 

    event _contribute(uint256 amount);
    event _claim(uint256 amount, uint256 when);



    IERC20 USDT = IERC20(0xC051cfE19de5cDE25180d7E904f3878112A223fE); // ERC20
    IERC20 USDC = IERC20(0x531469883976E747D94303E4449040201b0FAc06); // ERC20
    IERC20 BUSD = IERC20(0x531469883976E747D94303E4449040201b0FAc06); // ERC20
    IERC20 ElChai = IERC20(0x7f785dE886aFef58699Fd390356741D6144dA76A); // ERC20

    bool private _Whitelisted;
    bool private _paused;
    bool private _isLive;
    uint256 private _actualSale = 0;
    bool private _initialized;

    uint256 private TGE;
    uint256 private biWeekly = 500; // 1209600
    uint256 private _contributedsale1;
    uint256 private _contributedsale2;
    uint256 private _contributedsale3;
    uint256 private _contributedsale4;

    constructor() {
        _tokenWhitelisted[USDT] = true;
        _tokenWhitelisted[USDC] = true;
        _tokenWhitelisted[BUSD] = true;
    }

    function checkRate() internal view returns(uint256) {

        uint256 _rate;

        if(checkSale() == 1) { _rate = 47619047619047620000; }
        if(checkSale() == 2) { _rate = 43478260869565220000; }
        if(checkSale() == 3) { _rate = 34482758620689660000; }
        if(checkSale() == 4) { _rate = 29411764705882350000; } 

        return _rate;
        
    }

    function initialize(bool isTGENow, uint256 _TGE) external onlyOwner initializer {
        if(isTGENow) {  TGE = block.timestamp; } else {TGE = _TGE;}
        _initialized = true;
    }

    function setIsLive() external onlyOwner {
        _isLive = true;
    }

    function checkHardCap(uint256 amount) internal {
        if(checkSale() == 1) {_contributedsale1 = _contributedsale1 + amount; require(_contributedsale1 <= 940_000 * 10**18,"Hard cap reached");}
        if(checkSale() == 2) {_contributedsale2 = _contributedsale2 + amount; require(_contributedsale2 <= 1_740_000 * 10**18,"Hard cap reached");}
        if(checkSale() == 3) {_contributedsale3 = _contributedsale3 + amount; require(_contributedsale3 <= 2_174_000 * 10**18,"Hard cap reached");}
        if(checkSale() == 4) {_contributedsale4 = _contributedsale4 + amount; require(_contributedsale4 <= 5_148_000 * 10**18,"Hard cap reached");}
    }

    function contribute(address token, uint256 amount) external {
        IERC20 Token = IERC20(token);
        require(_tokenWhitelisted[Token],"Token not whitelisted");
        require(_isLive,"Sale is not live");
        require(amount > 0 ,"Amount should be greater than 0");

        Token.transferFrom(msg.sender, address(this), amount); // transfer amount to smart contract. 
        if(Token.decimals()  == 6) {  amount = amount * 10**12; } 
        checkHardCap(amount);

        if(checkSale() > 0 && checkSale() <= 4) {  writeTokens(msg.sender, amount);  } else { revert("Sale ID not valid"); }

        
        _whereDidHeBuy[msg.sender] = "This user used the smartcontract itself to buy the tokens.";
        _purchasedAmount[msg.sender] += amount;
        _isWhitelisted[msg.sender] = true;

        automaticTransfer(token);

        emit _contribute(amount);
    }

    function automaticTransfer(address token) internal {
        IERC20 Token = IERC20(token);
        uint256 contractBalance = Token.balanceOf(address(this));
        if(contractBalance > 0) { Token.transfer(owner(), contractBalance); }
    }

    function writeTokens(address holder, uint256 amount) internal {
        if(checkSale() == 1) { _purchasedSaleTokens[holder] += checkRate() * amount / 10**18; }
        if(checkSale() == 2) { _purchasedPrivateSaleTokens[holder] += checkRate() * amount / 10**18 ; }
        if(checkSale() == 3) { _purchasedPrivateSale2Tokens[holder] += checkRate() * amount / 10**18; }
        if(checkSale() == 4) { _purchasedPreSaleTokens[holder] += checkRate() * amount / 10**18; }
    }

    function checkReleaseAll() internal view returns (bool){
        return !notClaimed() && block.timestamp >= TGE + 20 * biWeekly;
    }

    function releaseAll(bool one, bool second, bool third, bool fourth) internal {
        if(one) {_pendingpurchasedPreSaleTokens[msg.sender] = _purchasedPreSaleTokens[msg.sender];}
        if(second) {_pendingpurchasedPrivateSale2Tokens[msg.sender] = _purchasedPrivateSale2Tokens[msg.sender];}
        if(third) {_pendingpurchasedPrivateSaleTokens[msg.sender] = _purchasedPrivateSaleTokens[msg.sender];}
        if(fourth) {_pendingpurchasedSaleTokens[msg.sender] = _purchasedSaleTokens[msg.sender];}
    }


    function notClaimed() internal view returns (bool) {
        return _didClaim[msg.sender];
    }

    function whatUnlockPhaseWeAre() public view returns (uint256) {
        uint256 _phase;
        if(block.timestamp < TGE) {  _phase = 0; }
        if(block.timestamp >= TGE + 1 * biWeekly) { _phase = 1; }
        if(block.timestamp >= TGE + 2 * biWeekly) { _phase = 2; }
        if(block.timestamp >= TGE + 3 * biWeekly) { _phase = 3; }
        if(block.timestamp >= TGE + 4 * biWeekly) { _phase = 4; }
        if(block.timestamp >= TGE + 5 * biWeekly) { _phase = 5; }
        if(block.timestamp >= TGE + 6 * biWeekly) { _phase = 6; }
        if(block.timestamp >= TGE + 7 * biWeekly) { _phase = 7; }
        if(block.timestamp >= TGE + 8 * biWeekly) { _phase = 8; }
        if(block.timestamp >= TGE + 9 * biWeekly) { _phase = 9; }
        if(block.timestamp >= TGE + 10 * biWeekly) { _phase = 10; }
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
        if(TGE == 0) { _phase = 0; }
        return _phase;
    }

    function standardUnlock() internal {
        if(whatUnlockPhaseWeAre() > 3) { releaseAll(true,false,false,false); } else {_pendingpurchasedPreSaleTokens[msg.sender] = (_purchasedPreSaleTokens[msg.sender] / 100 * ((20) * whatUnlockPhaseWeAre()) + _claimedTGE1[msg.sender]);}
        if(whatUnlockPhaseWeAre() >= 6) { releaseAll(true,true,false,false); } else {_pendingpurchasedPrivateSale2Tokens[msg.sender] = (_purchasedPrivateSale2Tokens[msg.sender] / 100 * ((15) * whatUnlockPhaseWeAre()) + _claimedTGE2[msg.sender]);}
        if(whatUnlockPhaseWeAre() >= 8) { releaseAll(true,true,true,false); } else {_pendingpurchasedPrivateSaleTokens[msg.sender] = (_purchasedPrivateSaleTokens[msg.sender] / 100 * ((10) * whatUnlockPhaseWeAre()) + _claimedTGE3[msg.sender]);}
        if(whatUnlockPhaseWeAre() >= 20) { releaseAll(true,true,true,true); } else {_pendingpurchasedSaleTokens[msg.sender] = (_purchasedSaleTokens[msg.sender] / 100 * ((5) * whatUnlockPhaseWeAre()) + _claimedTGE4[msg.sender]);}
    }

    function checkVesting() internal {
        if(checkReleaseAll()) { releaseAll(true,true,true,true); } else {

        standardUnlock();

        if(!notClaimed() && block.timestamp >= TGE) {
            claimTGE();
        }
    }
    }

    function claimTGE() internal {
        _pendingpurchasedSaleTokens[msg.sender] = _purchasedSaleTokens[msg.sender] / 100 * 10;
        _pendingpurchasedPrivateSaleTokens[msg.sender] = _purchasedPrivateSaleTokens[msg.sender] / 100 * 15;
        _pendingpurchasedPrivateSale2Tokens[msg.sender] = _purchasedPrivateSale2Tokens[msg.sender] / 100 * 20;
        _pendingpurchasedPreSaleTokens[msg.sender] = _purchasedPreSaleTokens[msg.sender] / 100 * 25;
        _claimedTGE1[msg.sender] = _pendingpurchasedSaleTokens[msg.sender];
        _claimedTGE2[msg.sender] = _pendingpurchasedPrivateSaleTokens[msg.sender];
        _claimedTGE3[msg.sender] = _pendingpurchasedPrivateSale2Tokens[msg.sender];
        _claimedTGE4[msg.sender] = _pendingpurchasedPreSaleTokens[msg.sender];
    }

    function claimedRewards(address account, uint256 ID) external view returns (uint256) {
        uint256 _claimed;
        if (ID == 1) { _claimed = _pendingpurchasedSaleTokens[account];}
        if (ID == 2) { _claimed = _pendingpurchasedPrivateSaleTokens[account];}
        if (ID == 3) { _claimed = _pendingpurchasedPrivateSale2Tokens[account];}
        if (ID == 4) { _claimed = _pendingpurchasedPreSaleTokens[account];}

        return _claimed;
    }

    function claim() external {
        require(_isLive,"Sale is not live");
        require(_isWhitelisted[msg.sender],"Did not contribute");
        require(_initialized,"Not initalized");
        checkVesting();

        _personalRelease[msg.sender] = _pendingpurchasedPreSaleTokens[msg.sender] + _pendingpurchasedPrivateSale2Tokens[msg.sender] + _pendingpurchasedPrivateSaleTokens[msg.sender] + _pendingpurchasedSaleTokens[msg.sender];
        _personalRelease[msg.sender] -= _purchasedAmountInStable[msg.sender];


        uint256 tokens = _personalRelease[msg.sender];


        require(tokens > 0,"Amount pending should be greater than 0"); 


        ElChai.transfer(msg.sender, tokens);

        
        _purchasedAmountInStable[msg.sender] += tokens;
        _lastClaim[msg.sender] = block.timestamp; 
        _didClaim[msg.sender] = true;

        emit _claim(tokens, _lastClaim[msg.sender]);
    }

    function testItN1(uint256 a, bool yesno) external { // remove before LIVE
            biWeekly = a;
            if(yesno) {releaseAll(true,true,true,true);}
    }

    function returnAmountPaid(address account) external view returns(uint256) {
        return _purchasedAmount[account];
    }

    function whenYouDidYourLastClaim(address account) external view returns(uint256) {
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

    function saleOngoing() external view returns(uint256) {
        return checkSale();
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
        uint256 tokens;
        if (ID == 1) { tokens = _purchasedSaleTokens[account];}
        if (ID == 2) { tokens = _purchasedPrivateSaleTokens[account];}
        if (ID == 3) { tokens = _purchasedPrivateSale2Tokens[account];}
        if (ID == 4) { tokens = _purchasedPreSaleTokens[account];}
        return tokens;
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

    function showPurchasedAmount(address holder) external view returns (uint256) {
        return _purchasedAmount[holder];
    }

}
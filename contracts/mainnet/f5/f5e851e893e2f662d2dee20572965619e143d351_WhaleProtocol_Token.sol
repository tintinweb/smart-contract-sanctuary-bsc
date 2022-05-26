/**
 *Submitted for verification at BscScan.com on 2022-05-26
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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

    // function allowance(address owner, address spender) external view returns (uint256);

    // function approve(address spender, uint256 amount) external returns (bool);
    
    // function increaseAllowance(address spender, uint256 addedValue) external  returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    function name() external  view  returns(string memory);
    function symbol() external view   returns (string memory);
    function decimals() external view  returns (uint8);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IWhaleNFT
{
function balanceOf(address _user) external view returns(uint256);    
//function getTokenIdsOwnedBy(address  _owner)external view  returns (uint256 [] memory);

}

contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 private _decimals;

    string private _name;
    string private _symbol;

    address deadAddress = 0x000000000000000000000000000000000000dEaD;

    address payable public owner;
    mapping (address => bool ) public admin;
    uint256 public adminFees;
    address payable public mktgWallet;
    address payable public teamWallet;
    address payable public devWallet;

    uint256 public END_REWARD = 1673308800;//9 Jan 2023 24:00:00 UTC

    mapping (address => uint256 ) internal earnedBNB;
    mapping (address => uint256 []) public earnedBNBDate;
    uint256 public intervalRewardTime =  1 days;

    mapping (address => uint256 ) public farmTokenIds;
    bool public farmIsON = false;
    bool public swapIsOpen = false;
 
    mapping (address => mapping (uint256 => uint256))  farmDateOwner;
    mapping (address => mapping (uint256 => uint256))  farmTokenAmountOwner;

    uint256 public tokenPrice;

    mapping (address => uint256) public maxLimitWallet;
    uint256 public maxLimit = 30 ether;
    uint256 public totRewards;
    uint256 public totReferralRewards;
    
    mapping (address  => bool) internal referralAddress;
    mapping (address  => uint256) internal referralRewards;
    mapping (address  => address []) internal referralArray;
    mapping (address  => address) internal referralPair;
    address [] public referralList;
   /*  */

    uint256 public divider = 1000;
    uint256 public farmReward = 100 ; // 10% each day
    uint256 public referralFee = 100;//10%
    uint256 public adminFee = 40;//4%
    uint256 public marketingFeeClaim = 40;//4% on claim

    uint256 public referralTokenPrize = 20;// 2% 
    uint256 public nftHolderPrize = 100; //10% NFT BOOST

    bool public tradeIsOpen = false;

    address nftAddress = 0x7CafC4D40b62478d6ACbD4f51F1Ec576A7Fb9483;
    IWhaleNFT public nftToken = IWhaleNFT(nftAddress);
    IERC20 public oldToken = IERC20(0x50A7B3188e71A8DBA75E3C92E0a800Eb7a6d9a2A);

    constructor ( string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        owner = payable(msg.sender);
        admin[msg.sender] = true;
        tokenPrice = 0.000005 ether;
        referralAddress[msg.sender] = true;

    mktgWallet  = payable(0x29FF5d594F4bFcA66A4AB460626271Ae3a2D532d);
    teamWallet = payable(0x7D376a2A2b33311a2c72993E06B15f1C1AC32aF1);
    devWallet   = payable(0x9c76f0C668b5d92E65aF8835a81a53Aff8616955);
    }
   
    /* DEFAULT FUNCTIONS*/
    
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {//
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address Owner, address spender) public view virtual  returns (uint256) {//override
        return _allowances[Owner][spender];
    }

    function approve(address spender, uint256 amount) internal virtual  returns (bool) {//override
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {//
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(((currentAllowance >= amount)), "Transfer amount exceeds allowance ");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance.sub(amount));
             }
        return true;
    }
  
    function increaseAllowance(address spender, uint256 addedValue) internal virtual  returns (bool) {//override
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) internal virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance.sub(subtractedValue));
        }
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(tradeIsOpen, "transfership not allowed : New owner can't receive rewards");
        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance.sub(amount);
        }
        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance.sub(amount);
        }
        _totalSupply = _totalSupply.sub(amount);

        emit Transfer(account, deadAddress, amount);
    }

   
    function _approve(address Owner, address spender, uint256 amount) internal virtual {
        require(Owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[Owner][spender] = amount;
        emit Approval(Owner, spender, amount);
    }


    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
    
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
    function max(uint256 a, uint256 b) internal pure returns (uint256) {        
        return a >= b ? a : b; 
    }

    /* maybe in the future: holders can sell tokens in pancakeswap only if enabled*/
    function openTrade() public  returns (bool ) {
        require(msg.sender == owner,"Only Admin can open Trade");
        tradeIsOpen = true;
        return true;
    }
    function setSwapStatus(bool _isOn) public  returns (bool ) {
        require(msg.sender == owner,"Only Admin can act here");
        swapIsOpen = _isOn;
        return _isOn;
    }
    
    /*REFERRAL*/
    function addReferral(address _referral, bool isOn) public returns (bool esito)  {
        require(admin[msg.sender], "Only Admin can act with this");
        referralAddress[_referral] = isOn;
        if(isOn == true)referralList.push(_referral);
        return isOn;
    }
    function setMaxLimitWallet(uint256 _maxWei) public returns (bool esito)  {
        require(admin[msg.sender], "Only Admin can act with this");
        maxLimit = _maxWei;
        return true;
    }
  /**/  function getReferralList() public view returns (address[] memory )  {
        return referralList ;
    }
    function getIsReferral(address _referral ) public view returns (bool )  {
        return referralAddress[_referral] ;
    }
    function getReferralPair(address _user ) public view returns (address )  {
        return referralPair[_user];
    }
    function getReferralRewards(address _referral ) public view returns (uint256 )  {
        return referralRewards[_referral];
    }
    function getReferralArray(address _referral ) public view returns (address [] memory )  {
        return referralArray[_referral];
    }

    /* TOKEN MINTING. */
    function buyToken (uint256 tokenz, address _referral) public payable returns (bool){
        uint amount = msg.value;
        uint tokens = tokenz;
        require(tokens > 0, "Not enough Token");
        require(farmIsON == true, "Contract is ON");
        uint256 price;
        if(nftToken.balanceOf(msg.sender) > 0){
            price = tokenPrice * (divider - nftHolderPrize) / divider;
            tokens += (tokens * nftHolderPrize / divider);
        } 
        else {price = tokenPrice;}

            require(amount >= price * (tokens / (10 ** uint256(_decimals))), "Wrong Amount!");
            require(maxLimitWallet[msg.sender].add(amount) <= maxLimit, "Limit reached");
            maxLimitWallet[msg.sender] = maxLimitWallet[msg.sender].add(amount);
       
        address _holder = msg.sender;

        referralAddress[msg.sender]=true;
        
        uint256 fee;//referral Fee
        if((referralAddress[_referral] == true) && (_referral!=msg.sender) && (referralPair[msg.sender]==address(0)) ){//
            referralPair[msg.sender]=_referral;
            referralList.push(_referral);
            fee = amount.mul(referralFee).div(divider);
            payable(_referral).transfer(fee * 50 / 100);// -> 1/2 1st level referral fees
            referralRewards[_referral] += fee  * 50 / 100;
            referralArray[_referral].push(msg.sender);
            
                if(referralPair[_referral]!=address(0)){
                    payable(referralPair[_referral]).transfer(fee * 30 / 100);//-> 1/3 referral fees
                    referralRewards[referralPair[_referral]] += fee  * 30 / 100;
                    referralArray[referralPair[_referral]].push(msg.sender);
                }

                if(referralPair[referralPair[_referral]]!=address(0)){
                    payable(referralPair[referralPair[_referral]]).transfer(fee * 20 / 100);//-> 1/5 referral fees
                    referralRewards[referralPair[referralPair[_referral]]] += fee  * 20 / 100;
                    referralArray[referralPair[referralPair[_referral]]].push(msg.sender);
                }

            tokens = tokens.add(tokens.mul(referralTokenPrize).div(divider)); // % for referral 
            totReferralRewards= totReferralRewards.add(fee);
        }
        
        adminFees +=amount.mul(adminFee).div(divider);//contract fee
        
        farmTokenIds[_holder]+=1;
        farmDateOwner[_holder][farmTokenIds[_holder]] = block.timestamp;
        farmTokenAmountOwner[_holder][farmTokenIds[_holder]] = tokens;
        
        
        _mint(_holder,tokens);
        return true;
    }

    function swapToken (uint256 tokens) public returns (bool){
        require(swapIsOpen, "Swap Is Closed");
        uint256 oldBalance = oldToken.balanceOf(msg.sender);
        require(oldBalance >=tokens, "Not enough Token");

        oldToken.transferFrom(msg.sender, owner, tokens);
     
        address _holder = msg.sender;

        uint256 newToken = tokens * (10 ** 16);//add decimals to old tokens -> old:2 - new:18
                
        farmTokenIds[_holder]+=1;
        farmDateOwner[_holder][farmTokenIds[_holder]] = block.timestamp;
        farmTokenAmountOwner[_holder][farmTokenIds[_holder]] = newToken;
        
        _mint(_holder,newToken);
        return true;
    }
    
     /* Function claim burns Token*/

    function claimPlusReward () public virtual returns (bool exito){
        address payable _holder = payable(msg.sender);
        uint256 balanceFarm = balanceOf(_holder);
        uint256 rewards = claimCalculateOwnerReward (_holder);
           
        farmTokenIds[_holder] = 0;
            
            _burn(_holder,balanceFarm);

            uint256 fee = rewards.mul(marketingFeeClaim).div(divider);
            _holder.transfer(rewards.sub(fee)); 
            adminFees += fee;//contract exit fee
            earnedBNBDate[_holder].push(block.timestamp);
            earnedBNB[_holder] = earnedBNB[_holder].add(rewards.sub(fee));
            totRewards = totRewards.add(rewards.sub(fee));
            maxLimitWallet[msg.sender]=0;
       return true;
    }
    
    /* Calculate BNB Reward : this is called from claim function */
    function claimCalculateOwnerReward (address _holder) public view returns (uint256 ){
    uint256 reward = 0;
          if(farmTokenIds[_holder]>0){ 
            for (uint i=1; i <= farmTokenIds[_holder]; i++) {
                
                uint256 timeNow = min(END_REWARD, block.timestamp);
                uint256 timeToken = farmDateOwner[_holder][i];
                    if(timeToken>0){
                uint256 intervals = (timeNow.sub(timeToken )).div(intervalRewardTime);

                if(intervals>0){
                uint256 amount = farmTokenAmountOwner [_holder][i];
                reward += (amount.mul(intervals) * farmReward).div(divider);               
                        }
                    }
                }
        }
        
        reward = reward.mul(tokenPrice).div(10 ** decimals());
       return max(0,reward);
    }
    /* Calculate Reward Fractions : this is called only for dashboard showing DATAS 
    Rewards mature each 24h (intervalRewardTime variable)
    This function show rewards matured each 15 minutes but with Claim action only 24h matured rewards will be considered
    */
    function claimCalculateRewardFraction (address _holder) public view returns (uint256 ){
    uint256 reward = 0;
          if(farmTokenIds[_holder]>0){ 
            for (uint i=1; i <= farmTokenIds[_holder]; i++) {
                
                uint256 timeNow = min(END_REWARD, block.timestamp).mul(100);
                uint256 timeToken = farmDateOwner[_holder][i].mul(100);
                    if(timeToken>0){
                uint256 intervals = (timeNow.sub(timeToken )).div(intervalRewardTime);

                if(intervals>0){
                uint256 amount = farmTokenAmountOwner [_holder][i];
                reward += (amount.mul(intervals) * farmReward).div(divider * 100);               
                        }
                    }
                }
        }
        
        reward = reward.mul(tokenPrice).div(10 ** decimals());
       return max(0,reward);
    }

    function getDateFarmAtIndex (address _holder, uint256 _index) public view returns (uint256 ){
        return max(0,farmDateOwner[_holder][_index]);
    }

function getTokenFarmAtIndex (address _holder, uint256 _index) public view returns (uint256 ){
    return max(0,farmTokenAmountOwner[_holder][_index]);
}
function getNftBalance (address _holder) public view returns (uint256 ){
    return nftToken.balanceOf(_holder);
}
function getEarnedBNB (address _holder) public view returns (uint256 ){
    return max(0,earnedBNB[_holder]);
}

function setAdmin (address _admin, bool _isOn) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    admin[_admin] = _isOn;
    return _isOn;
}
/* this is the fee when you enter in the pool */
function setAdminFee (uint256 _fee) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    require(_fee <= 40 , "Max fee 4%");
    adminFee = _fee;
    return true;
}
/* this is the fee when you exit from the pool */
function setMarketingFee (uint256 _fee) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    require(_fee <= 40 , "Max fee 4%");
    marketingFeeClaim = _fee;
    return true;
}
function setReferralFee (uint256 _fee) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    require(_fee >= 10 , "Minimal fee 1%");
    referralFee = _fee;
    return true;
}
function setEndReward (uint256 _date) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    END_REWARD = _date;
    return true;
}
function setTokenReward (uint256 _reward) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    require(_reward >= 10 , "Minimal fee 1%");
    farmReward = _reward;
    return true;
}
/* set the % NFT Boost during the Token purchase */
function setNftHolderPrize (uint256 _reward) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    require(_reward >= 10 , "Minimal fee 1%");
    nftHolderPrize = _reward;
    return true;
}

function setIntervalRewardTime (uint256 _time) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    intervalRewardTime = _time;
    return true;
}

function setFarmIsON (bool _isLive) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    farmIsON = _isLive;
    return _isLive;
}

function withdrawAdmin (uint256 _feesWei) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    require(_feesWei <= adminFees, "Max fees amount");
    owner.transfer(_feesWei * 25 / 100);
    mktgWallet.transfer(_feesWei * 25 / 100); 
    teamWallet.transfer(_feesWei * 25 / 100);
    devWallet.transfer(_feesWei * 25 / 100);
    adminFees = adminFees.sub(_feesWei);
    return true;
} 

receive() external payable {
//    revert();
}

}
contract WhaleProtocol_Token is ERC20 {
    
  //Name symbol decimals  
    constructor() ERC20("WhaleProtocol", "PLANKTON",18)  {
    }
}
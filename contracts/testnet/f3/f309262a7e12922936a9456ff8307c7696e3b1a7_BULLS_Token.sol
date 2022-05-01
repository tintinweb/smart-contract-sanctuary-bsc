/**
 *Submitted for verification at BscScan.com on 2022-04-30
*/

// SPDX-License-Identifier: MIT
// ERC20 Token for Staking
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

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
    
    function increaseAllowance(address spender, uint256 addedValue) external  returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    function name() external  view  returns(string memory);
    function symbol() external view   returns (string memory);
    function decimals() external view  returns (uint8);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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
   
    mapping (address => uint256 ) internal gainedBNB;
    mapping (address => uint256 []) public gainedBNBDate;
    uint256 public intervalRewardTime =  120;// 60*60*24*30    30 days

    //mapping (address => uint256 ) public bullTokenBalance;
    mapping (address => uint256 ) public bullTokenIds;
    bool public bullcashIsON = true;
 
    mapping (address => mapping (uint256 => uint256))  bullDateOwner;
    mapping (address => mapping (uint256 => uint256))  bullTokenAmountOwner;

    uint256 public tokenPrice;

    mapping (address => uint256) public maxLimitWallet;

    mapping (address  => bool) internal referralAddress;
    mapping (address  => uint256) internal referralRewards;
    mapping (address  => address) internal referralPair;
    address [] public referralList;

    uint256 public divider = 1000;
    uint256 public bullCashReward = 140 ; // 14% each day
    uint256 public referralFee = 100;//10%
    uint256 public adminFee = 40;//4%
    uint256 public marketingFeeClaim = 40;//4% on burn

    uint256 public referralTokenPrize = 20;

    bool public tradeIsOpen = false;

    constructor ( string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        owner = payable(msg.sender);
        admin[msg.sender] = true;
        tokenPrice = 0.00001 ether;
        referralAddress[msg.sender] = true;
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

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address Owner, address spender) public view virtual override returns (uint256) {
        return _allowances[Owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(((currentAllowance >= amount)), "Transfer amount exceeds allowance ");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance.sub(amount));
             }
        return true;
    }
  
    function increaseAllowance(address spender, uint256 addedValue) public virtual override returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
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
   /*function setTokenPrice(uint256 priceWeiTokens) public  returns (bool ) {
        require(msg.sender == owner,"Only Admin can set the price");
        tokenPrice = priceWeiTokens;
        return true;
    }*/
    /* maybe: bullers can sell tokens in pancakeswap only if enabled*/
    function openTrade() public  returns (bool ) {
        require(msg.sender == owner,"Only Admin can open Trade");
        tradeIsOpen = true;
        return true;
    }
    /*REFERRAL*/
    function addReferral(address _referral, bool isOn) public returns (bool esito)  {
        require(admin[msg.sender], "Only Admin can act with this");
        referralAddress[_referral] = isOn;
        return isOn;
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

    function buyToken (uint256 tokens, address _referral) public payable returns (bool){
        uint amount = msg.value;
        require(tokens > 0, "Not enough Token");
        require(bullcashIsON == true, "Contract is ON");
        require(amount >= tokenPrice * (tokens / (10 ** uint256(_decimals))), "Wrong Amount!");
        
        address _buller = msg.sender;

        require(maxLimitWallet[msg.sender].add(amount) <= 20 ether, "Limit 20 BNB reached");
        maxLimitWallet[msg.sender] = maxLimitWallet[msg.sender].add(amount);

        referralAddress[msg.sender]=true;
        
        uint256 fee;//referral Fee
        if((referralAddress[_referral] == true) && (_referral!=msg.sender) && (referralPair[msg.sender]==address(0)) ){//
            referralPair[msg.sender]=_referral;
            referralList.push(_referral);
            fee = amount.mul(referralFee).div(divider);
            payable(_referral).transfer(fee * 50 / 100);
            referralRewards[_referral] += fee  * 50 / 100;

                if(referralPair[_referral]!=address(0)){
                    payable(referralPair[_referral]).transfer(fee * 30 / 100);
                    referralRewards[referralPair[_referral]] += fee  * 30 / 100;
                }

                if(referralPair[referralPair[_referral]]!=address(0)){
                    payable(referralPair[referralPair[_referral]]).transfer(fee * 20 / 100);
                    referralRewards[referralPair[referralPair[_referral]]] += fee  * 20 / 100;
                }

            tokens = tokens.add(tokens.mul(referralTokenPrize).div(divider)); // % for referral 
        }
        
        owner.transfer(amount.mul(adminFee).div(divider));//contract fee
        //bullTokenBalance[_buller] += tokens;
        
        bullTokenIds[_buller]+=1;
        bullDateOwner[_buller][bullTokenIds[_buller]] = block.timestamp;
        bullTokenAmountOwner[_buller][bullTokenIds[_buller]] = tokens;
        
        
        _mint(_buller,tokens);
        return true;
    }
    

     /* Function claim burns BULLS Token*/

    function claimPlusReward () public virtual returns (bool exito){
        address payable _buller = payable(msg.sender);
        uint256 balanceBullCash = balanceOf(_buller);
        uint256 rewards = claimCalculateOwnerReward (_buller);
        
        
        bullTokenIds[_buller] = 0;
            
            _burn(_buller,balanceBullCash);

            uint256 fee = rewards.mul(marketingFeeClaim).div(divider);
            _buller.transfer(rewards.sub(fee)); 
            owner.transfer(fee);
            gainedBNBDate[_buller].push(block.timestamp);
            gainedBNB[_buller] = gainedBNB[_buller].add(rewards.sub(fee));
            maxLimitWallet[msg.sender]=0;
       return true;
    }
    
    /* Calculate Reward */
    function claimCalculateOwnerReward (address _buller) public view returns (uint256 ){
    uint256 reward = 0;
          if(bullTokenIds[_buller]>0){ 
            for (uint i=1; i <= bullTokenIds[_buller]; i++) {
                
                uint256 timeNow = block.timestamp;
                uint256 timeToken = bullDateOwner[_buller][i];
                    if(timeToken>0){
                uint256 intervals = (timeNow.sub(timeToken )).div(intervalRewardTime);

                if(intervals>0){
                uint256 amount = bullTokenAmountOwner [_buller][i];
                reward += (amount.mul(intervals) * bullCashReward).div(divider);               
                        }
                    }
                }
        }
        reward = reward.mul(tokenPrice).div(10 ** decimals());
       return max(0,reward);
    }
function getDateBullAtIndex (address _buller, uint256 _index) public view returns (uint256 ){
    return max(0,bullDateOwner[_buller][_index]);
}

function getTokenBullAtIndex (address _buller, uint256 _index) public view returns (uint256 ){
    return max(0,bullTokenAmountOwner[_buller][_index]);
}

function getGainedBNB (address _buller) public view returns (uint256 ){
    return max(0,gainedBNB[_buller]);
}

function setAdmin (address _admin, bool _isOn) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    admin[_admin] = _isOn;
    return _isOn;
}
function setAdminFee (uint256 _fee) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    require(_fee <= 100 , "Max fee 10%");
    adminFee = _fee;
    return true;
}
function setMarketingFee (uint256 _fee) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    require(_fee <= 60 , "Max fee 6%");
    marketingFeeClaim = _fee;
    return true;
}
function setReferralFee (uint256 _fee) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    require(_fee >= 10 , "Minimal fee 1%");
    referralFee = _fee;
    return true;
}
/*function setEndReward (uint256 _date) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    END_REWARD = _date;
    return true;
}*/
function setTokenReward (uint256 _reward) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    require(_reward >= 10 , "Minimal fee 1%");
    bullCashReward = _reward;
    return true;
}
function setIntervalRewardTime (uint256 _time) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    intervalRewardTime = _time;
    return true;
}
function setbullcashIsON (bool _isLive) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    bullcashIsON = _isLive;
    return _isLive;
}
/* in case of any issue the tokens will don't remain blocked in the contract
function emergencyWithdraw (uint256 _withdraw) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    require( bullcashIsON == false , "Staking");
    transfer(rewardAddress, _withdraw); 
    return true;
} */
//ONLY ON TESTNET
    function withdrawAll () public virtual returns (bool exito){
        owner.transfer(address(this).balance);
       return true;
    }
receive() external payable {
//    revert();
}

}
contract BULLS_Token is ERC20 {
    
  //Name symbol decimals  
    constructor() ERC20("BULL CASH", "BULLS",18)  {
     // constructor() ERC20("xxxxxxxx", "xxxxxxxxxxx",18)  {
    }
}
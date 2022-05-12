/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

// SPDX-License-Identifier: MIT
/*
  ______                            __                   ______                      __             
 /      \                          |  \                 /      \                    |  \            
|  $$$$$$\ ______   _______    ____| $$ __    __       |  $$$$$$\ ______    _______ | $$____        
| $$   \$$|      \ |       \  /      $$|  \  |  \      | $$   \$$|      \  /       \| $$    \       
| $$       \$$$$$$\| $$$$$$$\|  $$$$$$$| $$  | $$      | $$       \$$$$$$\|  $$$$$$$| $$$$$$$\      
| $$   __ /      $$| $$  | $$| $$  | $$| $$  | $$      | $$   __ /      $$ \$$    \ | $$  | $$      
| $$__/  \  $$$$$$$| $$  | $$| $$__| $$| $$__/ $$      | $$__/  \  $$$$$$$ _\$$$$$$\| $$  | $$      
 \$$    $$\$$    $$| $$  | $$ \$$    $$ \$$    $$       \$$    $$\$$    $$|       $$| $$  | $$      
  \$$$$$$  \$$$$$$$ \$$   \$$  \$$$$$$$ _\$$$$$$$        \$$$$$$  \$$$$$$$ \$$$$$$$  \$$   \$$      
                                       |  \__| $$                                                   
                                        \$$    $$                                                   
                                         \$$$$$$                                                    

*/
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
    address payable public devWallet;
    address payable public autoboostWallet;
    mapping (address => bool ) public admin;
   
    mapping (address => uint256 ) internal gainedBNB;
    mapping (address => uint256 []) public gainedBNBDate;
    
    uint256 public intervalRewardTime =  1 days; 

    mapping (address => uint256 ) public candyTokenIds;
    bool public candyCashIsON = false;
    
    mapping (address => mapping (uint256 => uint256))  candyDateOwner;
    mapping (address => mapping (uint256 => uint256))  candyTokenAmountOwner;

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
    mapping (address => bool) boostedWallet;
    mapping (address => uint256) boostRate;

    uint256 public divider = 1000;
    uint256 public candyCashReward = 100 ; // 10% each day
    uint256 public referralFee = 140;//14%
    uint256 public devFee = 20;//2%
    uint256 public autoboostFee = 30;//3%
    uint256 public totalFeesRate = 50;//5%
    uint256 reCandyRate = 1000;// 100%
    uint256 public referralTokenPrize = 20;//2%

    bool public tradeIsOpen = false;

    constructor ( string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        tokenPrice = 0.00001 ether;
        owner = payable(msg.sender);
        referralAddress[msg.sender] = true;
        devWallet=payable(0xb457AEB90b8C6843e8a844572cc62a74D4a693dc);
        autoboostWallet=payable(0xb532dAe30da8a4b997B2FC257CfB091FF3A0368c);
        admin[msg.sender] = true;
        admin[devWallet] = true;
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
    /*REFERRAL*/
    /* set a prize for using referrals in purchase */
   function setReferralTokenPrize(uint256 _rate) public  returns (bool ) {
        require(admin[msg.sender],"Only Admin can set the prize");
        referralTokenPrize = _rate;
        return true;
    }
    /* eventually in the future candyers can transfer tokens if enabled*/
    function openTrade() public  returns (bool ) {
        require(msg.sender == owner,"Only Admin can open Trade");
        tradeIsOpen = true;
        return true;
    }
   
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
    function getReferralList() public view returns (address[] memory )  {
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

    /* TOKEN MINTING: */
    function buyToken (uint256 tokens, address _referral) public payable returns (bool){
        uint amount = msg.value;
        require(tokens > 0, "Not enough Token");
        require(candyCashIsON == true, "Contract is ON");
        require(amount >= tokenPrice * (tokens / (10 ** uint256(_decimals))), "Wrong Amount!");
        
        address _holder = msg.sender;

        require(maxLimitWallet[msg.sender].add(amount) <= maxLimit, "Limit reached");
        maxLimitWallet[msg.sender] = maxLimitWallet[msg.sender].add(amount);

        referralAddress[msg.sender]=true;
        
        uint256 fee;//referral Fee
        if((referralAddress[_referral] == true) && (_referral!=msg.sender) && (referralPair[msg.sender]==address(0)) ){//
            referralPair[msg.sender]=_referral;
            referralList.push(_referral);
            fee = amount.mul(referralFee).div(divider);
            payable(_referral).transfer(fee * 70 / 100);// ->70% 1st level referral fees
            referralRewards[_referral] += fee  * 70 / 100;
            referralArray[_referral].push(msg.sender);
            
                if(referralPair[_referral]!=address(0)){
                    payable(referralPair[_referral]).transfer(fee * 30 / 100);//-> 30% 2nd level referral fees
                    referralRewards[referralPair[_referral]] += fee  * 30 / 100;
                    referralArray[referralPair[_referral]].push(msg.sender);
                }


            tokens = tokens.add(tokens.mul(referralTokenPrize).div(divider)); // % for referral 
            totReferralRewards= totReferralRewards.add(fee);
        }
        
            devWallet.transfer(amount.mul(devFee).div(divider));
            autoboostWallet.transfer(amount.mul(autoboostFee).div(divider));
        
        candyTokenIds[_holder] += 1;
        candyDateOwner[_holder][candyTokenIds[_holder]] = block.timestamp;
        candyTokenAmountOwner[_holder][candyTokenIds[_holder]] = tokens;
        
        
        _mint(_holder,tokens);
        return true;
    }
    

/* Function claim BNB rewards and burns candy Token*/

function claimPlusReward () public virtual returns (bool exito){
        address payable _holder = payable(msg.sender);
        uint256 balancecandyCash = balanceOf(_holder);
        uint256 rewards = claimCalculateOwnerReward (_holder);
           
        candyTokenIds[_holder] = 0;
            
            _burn(_holder,balancecandyCash);

            uint256 fee = rewards.mul(totalFeesRate).div(divider);
            _holder.transfer(rewards.sub(fee)); 
            devWallet.transfer(rewards.mul(devFee).div(divider));
            autoboostWallet.transfer(rewards.mul(autoboostFee).div(divider));

            gainedBNBDate[_holder].push(block.timestamp);
            gainedBNB[_holder] = gainedBNB[_holder].add(rewards.sub(fee));
            totRewards = totRewards.add(rewards.sub(fee));
            maxLimitWallet[msg.sender]=0;
       return true;
}
    
    /* Calculate BNB Reward */
function claimCalculateOwnerReward (address _holder) public view returns (uint256 ){
    uint256 reward = 0;
          if(candyTokenIds[_holder]>0){ 
            for (uint i=1; i <= candyTokenIds[_holder]; i++) {
                
                uint256 timeNow = block.timestamp;
                uint256 timeToken = candyDateOwner[_holder][i];
                    if(timeToken>0){
                uint256 intervals = (timeNow.sub(timeToken )).div(intervalRewardTime);

                if(intervals>0){
                uint256 amount = candyTokenAmountOwner [_holder][i];
                reward += (amount.mul(intervals) * candyCashReward).div(divider);               
                        }
                    }
                }
        }
            if(boostedWallet[_holder]==true){
                reward += reward.mul(boostRate[_holder]).div(divider); 
            }
        reward = reward.mul(tokenPrice).div(10 ** decimals());
       return max(0,reward);
}

 /* Calculate Token Reward */
function reCandyCalculate (address _holder) public view returns (uint256){
    uint256 rewards = claimCalculateOwnerReward(_holder).div(tokenPrice).mul(10 ** decimals());
    return rewards;
}
 /* Claim Reward in Token  */
function reCandy () public returns (bool){
        require(candyCashIsON == true, "Contract is ON");
        address _holder = msg.sender;
        uint256 balanceRewards = reCandyCalculate(_holder);
        require(balanceRewards > 0, "Not enough time to eat");
        uint256 reCandyTokens = balanceRewards.mul(reCandyRate).div(divider);     

        candyTokenIds[_holder] = 1;
        candyDateOwner[_holder][candyTokenIds[_holder]] = block.timestamp;
        candyTokenAmountOwner[_holder][candyTokenIds[_holder]] = reCandyTokens;
        _mint(_holder,reCandyTokens);
       return true;
    }

function getDateCandyAtIndex (address _holder, uint256 _index) public view returns (uint256 ){
    return max(0,candyDateOwner[_holder][_index]);
}

function getTokenCandyAtIndex (address _holder, uint256 _index) public view returns (uint256 ){
    return max(0,candyTokenAmountOwner[_holder][_index]);
}

function getGainedBNB (address _holder) public view returns (uint256 ){
    return max(0,gainedBNB[_holder]);
}

function setAdmin (address _admin, bool _isOn) public  returns (bool ){
    require(admin[msg.sender], "Only Admin can act with this");
    admin[_admin] = _isOn;
    return _isOn;
}

function setDevFee (uint256 _fee) public  returns (bool ){
    require(admin[msg.sender], "Only Admin can act with this");
    require(_fee <= 50 , "Max fee 2%");
    devFee = _fee;
    totalFeesRate = devFee.add(autoboostFee);
    return true;
}
function setAutoboostFee (uint256 _fee) public  returns (bool ){
    require(admin[msg.sender], "Only Admin can act with this");
    require(_fee <= 50 , "Max fee 5%");
    autoboostFee = _fee;
    totalFeesRate = devFee.add(autoboostFee);
    return true;
}
function setReferralFee (uint256 _fee) public  returns (bool ){
    require(admin[msg.sender], "Only Admin can act with this");
    require(_fee >= 10 , "Minimal fee 1%");
    referralFee = _fee;
    return true;
}
/* follow TG channel to gat a boostWallet*/
function setBoostWallet (address _wallet, uint256 _rate, bool _isOn) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    boostedWallet[_wallet] = _isOn;
    boostRate[_wallet] = _rate;
    return _isOn;
}
function getBoostedWallet (address _wallet) public view  returns (bool ){
    return boostedWallet[_wallet];
}
function getBoostRate (address _wallet) public view  returns (uint256 ){
    return boostRate[_wallet];
}
function setTokenReward (uint256 _reward) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    require(_reward >= 10 , "Minimal fee 1%");
    candyCashReward = _reward;
    return true;
}
function setIntervalRewardTime (uint256 _time) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    intervalRewardTime = _time;
    return true;
}
function setCandyCashIsON (bool _isLive) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    candyCashIsON = _isLive;
    return _isLive;
}
function setReCandyRate (uint256 _rate) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    reCandyRate = _rate;
    return true;
}

receive() external payable {
//    CONTRACT can receive BNB
}

}
contract CANDY_Token is ERC20 {
    
  //Name symbol decimals  
 constructor() ERC20("CANDY CASH", "CANDY",18)  {
    }
}
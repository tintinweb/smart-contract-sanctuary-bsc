/**
 *Submitted for verification at BscScan.com on 2022-02-08
*/

pragma solidity 0.5.8;
//pragma experimental ABIEncoderV2;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
}

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function limitSupply() external view returns (uint256);
    function availableSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC20 is IERC20 {
    using SafeMath for uint256;
    address busd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // live busd
    //address busd = 0x7F4edc9AC9d9fbFdBEB9B6deb81d26a833B11476; // testnet busd
    //address busd = 0xf9675Fb5Ab89D8d2e825b43E07c518C577E65fb0; // Ganache
    IERC20 token;
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint256 internal _limitSupply;

    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function limitSupply() public view returns (uint256) {
        return _limitSupply;
    }
    
    function availableSupply() public view returns (uint256) {
        return _limitSupply.sub(_totalSupply);
    }    

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        require(availableSupply() >= amount, "Supply exceed");

        _totalSupply = _totalSupply.add(amount);
        
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

}

contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 amount, address token, bytes calldata extraData) external;
}

contract Token is ERC20 {
    mapping (address => bool) private _contracts;

    constructor() public {
        _name = "Crypto Factory";
        _symbol = "CFY";
        _decimals = 18;
        _limitSupply = 1000000e18;
        
    }

    function approveAndCall(address spender, uint256 amount, bytes memory extraData) public returns (bool) {
        require(approve(spender, amount));

        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, amount, address(this), extraData);

        return true;
    }

    

    function transfer(address to, uint256 value) public returns (bool) {

        if (_contracts[to]) {
            approveAndCall(to, value, new bytes(0));
        } else {
            super.transfer(to, value);
        }

        return true;
    }
}

contract BUSDMaker is Token {
    
    uint private startTime = 1111; 
    address payable private ADMIN;    
    uint public totalUsers; 
    uint public totalBUSDStaked; 
    uint public totalTokenStaked;  
    uint private lastAirdrop = now;  
    uint private constant ADV_FEE           = 15;     
    uint private constant PERCENT_DIVIDER   = 1000;
    uint private constant PRICE_DIVIDER     = 1 ether;
    uint private constant TIME_STEP         = 1 days;
    uint private NEXT_AIRDROP      = 7 days;
    uint private AIRDROP_CLAIM_LIMIT = 1 days;
    uint private LIMIT_TOKEN_PRICE = 1 ether;
    uint public SELL_LIMIT_DAILY_USER   = 10000 ether; 
    uint public TIME_TO_UNSTAKE_E   = 10 days;
    uint public TIME_TO_UNSTAKE_M   = 20 days;
    uint public TIME_TO_UNSTAKE_H   = 30 days;
    uint public BUSD_DAILYPROFIT  = 40;
    uint public TOKEN_DAILYPROFIT_E = 60;
    uint public TOKEN_DAILYPROFIT_M = 80;
    uint public TOKEN_DAILYPROFIT_H = 100;
    uint public FEE_WEEKLY_AIRDROP = 50;
    uint public SELL_LIMIT = 60000 ether; 
    uint private BUSD_WEEKLY_AIRDROP = 0 ether;     
    uint private BUSD_WEEKLY_AIRDROP_PAID = 0 ether;  
    uint public MIN_USER_STAKED_BUSD_AIRDROP = 100 ether;  
    uint public TOTAL_USERS_AIRDROP = 0;
    bool private START_AIRDROP = false;
    bool public AIRDROP_WITH_CFY = false;
    

    mapping(address => User) private users;
    mapping(address => mapping(uint => Staking)) stakes;
    mapping(address => mapping(uint => uint)) private soldByUser; 
    mapping(uint => uint) private sold; 
    enum StakeType {EASY, MEDIUM, HARD}
    
    struct Stake {
        uint checkpoint;
        uint totalStaked; 
        uint lastStakeTime;
        uint unClaimedTokens;     
    }

    struct Staking{
        uint id;
        address addr;
        uint amount;
        StakeType period;
        uint startTimeStake;
    }
        Staking[] public stakings;

    
    struct User {
        address referrer;
        Stake sM;
        Stake sT;  
        bool Airdrop;
        uint AirdropClaimed;
        uint totaReferralBonus;
        uint totalAirdrop;
        uint lastTimeSold;
        uint nextSellSchedule;
    }

    
    
    event TokenOperation(address indexed account, string txType, uint tokenAmount, uint trxAmount);

    constructor() public {
        token = IERC20(busd);
        ADMIN = msg.sender;
        _mint(msg.sender, 10000 ether);  
    }       
    
    modifier onlyOwner {
        require(msg.sender == ADMIN, "Only owner can call this function");
        _;
    } 
    
    function stakeBUSD(address referrer,  uint256 _amount) public payable {
        token.transferFrom(msg.sender, address(this), _amount);
        
		uint fee = _amount.mul(ADV_FEE).div(PERCENT_DIVIDER); 
        token.transfer(ADMIN, fee);
        BUSD_WEEKLY_AIRDROP = BUSD_WEEKLY_AIRDROP.add(_amount.mul(FEE_WEEKLY_AIRDROP).div(PERCENT_DIVIDER));
		User storage user = users[msg.sender];

        if (users[msg.sender].lastTimeSold == 0) {
            users[msg.sender].lastTimeSold = now;
        }

        if (msg.sender != ADMIN && referrer != address(0) && msg.sender != referrer) {
        users[msg.sender].referrer = referrer;
        users[referrer].totaReferralBonus = users[referrer].totaReferralBonus.add(fee);
        token.transfer(referrer, fee); 
        }

        if (user.sM.totalStaked == 0) {
            user.sM.checkpoint = maxVal(now, startTime);
            totalUsers++;
        } else {
            updateStakeBUSD_IP(msg.sender);
        }
        user.sM.lastStakeTime = now;
        user.sM.totalStaked = user.sM.totalStaked.add(_amount);
        totalBUSDStaked = totalBUSDStaked.add(_amount).sub(BUSD_WEEKLY_AIRDROP); 

        if(AIRDROP_WITH_CFY == false && user.sM.totalStaked >= MIN_USER_STAKED_BUSD_AIRDROP && user.Airdrop == false){
           TOTAL_USERS_AIRDROP++;
           user.Airdrop = true;
           user.AirdropClaimed = lastAirdrop.div(2);
        }
        updateAirDrop();
    }

    function claimWeeklyAirDrop() external{
        uint amount = BUSD_WEEKLY_AIRDROP.div(TOTAL_USERS_AIRDROP);
        require(checkUserForAirdrop(), "You are not participating on this airdrop yet");
        require(now > lastAirdrop.add(NEXT_AIRDROP), "Airdrop not available yet");
        require((users[msg.sender].AirdropClaimed < lastAirdrop), "Airdrop already claimed. Please, come back next week");
        if(users[msg.sender].sM.totalStaked >= MIN_USER_STAKED_BUSD_AIRDROP){
                users[msg.sender].AirdropClaimed = lastAirdrop;
                BUSD_WEEKLY_AIRDROP_PAID = BUSD_WEEKLY_AIRDROP_PAID.add(amount);
                token.transfer(msg.sender, amount);
                users[msg.sender].totalAirdrop = users[msg.sender].totalAirdrop.add(amount);
        }
    }

    function checkUserForAirdrop() private returns(bool){
        if((AIRDROP_WITH_CFY == false) && (users[msg.sender].sM.totalStaked >= MIN_USER_STAKED_BUSD_AIRDROP)){
            return true;
        }else if((AIRDROP_WITH_CFY == true) && (users[msg.sender].sT.totalStaked >= MIN_USER_STAKED_BUSD_AIRDROP)){
            return true;
        }else{
            users[msg.sender].Airdrop = false;
            return false;
        }

    }


    function updateAirDrop() private{
        if(now > lastAirdrop.add(NEXT_AIRDROP).add(AIRDROP_CLAIM_LIMIT)){
            BUSD_WEEKLY_AIRDROP = 0 ether;
            BUSD_WEEKLY_AIRDROP_PAID = 0 ether;
            START_AIRDROP = true;
            lastAirdrop = now;
        }
    }
    function RETURN_AIRDROP_CLAIM_LIMIT() external view returns(uint){
        return lastAirdrop.add(NEXT_AIRDROP).add(AIRDROP_CLAIM_LIMIT);
    }

    function getUserStaking(uint _index, uint _data) external view returns(uint){
        if(stakes[msg.sender][_index].amount > 0){
            if(_data == 0){
            return stakes[msg.sender][_index].amount;
            }else if( _data == 1){
            return stakes[msg.sender][_index].startTimeStake;
            }
        }
    }
    function getUserStakingStartTimeStake(uint _index) external view returns(uint){
        return stakes[msg.sender][_index].startTimeStake;
    }
    
    function stakeToken(uint tokenAmount, uint _periodLocked) public {
        User storage user = users[msg.sender];
        require(now >= startTime, "Unstake not available yet");
        require(tokenAmount <= balanceOf(msg.sender), "Insufficient Token Balance");
        require(_periodLocked < 3);

        if (user.sT.totalStaked == 0) {
            user.sT.checkpoint = now;
        } else {
            updateStakeToken_IP(msg.sender);
        }
        if(stakes[msg.sender][_periodLocked].amount > 0){
            stakes[msg.sender][_periodLocked].startTimeStake = now;
            stakes[msg.sender][_periodLocked].amount = stakes[msg.sender][_periodLocked].amount.add(tokenAmount);
        }else{
            stakes[msg.sender][_periodLocked].amount = tokenAmount;
            stakes[msg.sender][_periodLocked].startTimeStake = now; 
        }

        _transfer(msg.sender, address(this), tokenAmount);
        user.sT.lastStakeTime = now;

        user.sT.totalStaked = user.sT.totalStaked.add(tokenAmount);
        totalTokenStaked = totalTokenStaked.add(tokenAmount); 

         if(AIRDROP_WITH_CFY == true && user.sT.totalStaked >= MIN_USER_STAKED_BUSD_AIRDROP && user.Airdrop == false){
           TOTAL_USERS_AIRDROP++;
           user.Airdrop = true;
           user.AirdropClaimed = lastAirdrop.div(2);
        }
    
    } 
    
    function unStakeToken(uint _id) public {
        User storage user = users[msg.sender];
        updateStakeToken_IP(msg.sender);
        require(checkStakeTime(_id), "You cannot unstake your tokens yet");
        uint tokenAmount = stakes[msg.sender][_id].amount;
        stakes[msg.sender][_id].amount = 0;
        user.sT.totalStaked = user.sT.totalStaked-tokenAmount;
        totalTokenStaked = totalTokenStaked.sub(tokenAmount); 
        _transfer(address(this), msg.sender, tokenAmount);
        if(AIRDROP_WITH_CFY == true && user.sT.totalStaked < MIN_USER_STAKED_BUSD_AIRDROP && user.Airdrop == true){
           TOTAL_USERS_AIRDROP--;
           user.Airdrop = false;
        }

    }  
    
    function updateStakeBUSD_IP(address _addr) private {
        User storage user = users[_addr];
        uint256 amount = getStakeBUSD_IP(_addr);
        updateAirDrop();
        if(amount > 0) {
            user.sM.unClaimedTokens = user.sM.unClaimedTokens.add(amount);
            user.sM.checkpoint = now;
        }
    } 

    
    
    function getStakeBUSD_IP(address _addr) view private returns(uint256 value) {
        User storage user = users[_addr];
        uint256 fr = user.sM.checkpoint;
        if (startTime > now) {
          fr = now; 
        }
        uint256 Tarif = BUSD_DAILYPROFIT;
        uint256 to = now;
        if(fr < to) {
            value = user.sM.totalStaked.mul(to - fr).mul(Tarif).div(TIME_STEP).div(PERCENT_DIVIDER);
        } else {
            value = 0;
        }
        return value;
    }  
    
    function updateStakeToken_IP(address _addr) private {
        User storage user = users[_addr];
        uint256 amount = getStakeToken_IP(_addr);
        if(amount > 0) {
            user.sT.unClaimedTokens = user.sT.unClaimedTokens.add(amount);
            user.sT.checkpoint = now;
        }
    } 

    function getStakeToken_IP(address _addr) view private returns(uint256 value) {
        User storage user = users[_addr];
        uint256 fr = user.sT.checkpoint;
        if (startTime > now) {
          fr = now; 
        }
        uint256 to = now;
        if(fr < to) {
            uint value_e = stakes[_addr][0].amount.mul(to - fr).mul(TOKEN_DAILYPROFIT_E).div(TIME_STEP);
            uint value_m = stakes[_addr][1].amount.mul(to - fr).mul(TOKEN_DAILYPROFIT_M).div(TIME_STEP);
            uint value_h = stakes[_addr][2].amount.mul(to - fr).mul(TOKEN_DAILYPROFIT_H).div(TIME_STEP);
            value = value.add(value_e).add(value_m).add(value_h).div(PERCENT_DIVIDER);

            
        } else {
            value = 0;
        }
        return value;
    }   

    function getStakeTokenReward(uint _id, uint _daily) external view returns(uint256 value){
            uint256 to = now;
            uint256 fr = stakes[msg.sender][_id].startTimeStake;
            value = stakes[msg.sender][_id].amount.mul(to - fr).mul(_daily).div(TIME_STEP).div(PERCENT_DIVIDER);
        return value;
    }   
    
    function claimToken_M() public {
        User storage user = users[msg.sender];
       
        updateStakeBUSD_IP(msg.sender);
        uint tokenAmount = user.sM.unClaimedTokens;  
        user.sM.unClaimedTokens = 0;                 
        
        _mint(msg.sender, tokenAmount);
        emit TokenOperation(msg.sender, "CLAIM", tokenAmount, 0);
    }    
    
    function claimToken_T() public {
        User storage user = users[msg.sender];
       
        updateStakeToken_IP(msg.sender);
        uint tokenAmount = user.sT.unClaimedTokens; 
        user.sT.unClaimedTokens = 0; 
        _mint(msg.sender, tokenAmount);
        emit TokenOperation(msg.sender, "CLAIM", tokenAmount, 0);
    }     

    function sellToken(uint tokenAmount) public {
        tokenAmount = minVal(tokenAmount, balanceOf(msg.sender));
        uint userBalance =  balanceOf(msg.sender);
        require(tokenAmount < userBalance, "You do not have that amount of tokens");
        require(soldByUser[msg.sender][getCurrentDay()].add(tokenAmount) <= SELL_LIMIT_DAILY_USER, "Daily Sell Limit reached");
        require(sold[getCurrentDay()].add(tokenAmount) <= SELL_LIMIT, "Daily Sell Limit exceed");
               
        sold[getCurrentDay()] = sold[getCurrentDay()].add(tokenAmount);
        soldByUser[msg.sender][getCurrentDay()] = soldByUser[msg.sender][getCurrentDay()].add(tokenAmount);
        uint BUSDAmount = tokenToBUSD(tokenAmount);
        require(getContractBUSDBalance() > BUSDAmount, "Insufficient BUSD Balance on the contract");

        _burn(msg.sender, tokenAmount);
       token.transfer(msg.sender, BUSDAmount);
        emit TokenOperation(msg.sender, "SELL", tokenAmount, BUSDAmount);
    }   
      

    function getUserUnclaimedTokens_M(address _addr) public view returns(uint value) {
        User storage user = users[_addr];
        return getStakeBUSD_IP(_addr).add(user.sM.unClaimedTokens); 
    }
    
    function getUserUnclaimedTokens_T(address _addr) public view returns(uint value) {
        User storage user = users[_addr];
        return getStakeToken_IP(_addr).add(user.sT.unClaimedTokens); 
    }   
	
    function getUserTimeToNextAirdrop() public view returns (uint) {
        return lastAirdrop.add(NEXT_AIRDROP);
    }    

    function getIfUserIsAirdrop() public view returns (bool) {
        return users[msg.sender].Airdrop;
    }   
    
	function getContractBUSDBalance() public view returns (uint) {
	    return token.balanceOf(address(this));
	}  
	function getTotalAidropPaidUser() external view returns (uint) {
	    return users[msg.sender].totalAirdrop;
	} 

	function getContractTokenBalance() public view returns (uint) {
		return balanceOf(address(this));
	}  
	
	
	function getUserBUSDBalance(address _addr) public view returns (uint) {
		return address(_addr).balance;
	}	
	
	function getUserTokenBalance(address _addr) public view returns (uint) {
		return balanceOf(_addr);
	}

    function getUserReferrer(address _addr) public view returns (address){
        return users[_addr].referrer;
    }
	
	function getUserBUSDStaked(address _addr) public view returns (uint) {
		return users[_addr].sM.totalStaked;
	}	
	
	function getUserTokenStaked(address _addr) public view returns (uint) {
		return users[_addr].sT.totalStaked;
	}
	
    function getTokenPrice() public view returns(uint value) {
        uint d1 = getContractBUSDBalance().mul(PRICE_DIVIDER);
        uint d2 = availableSupply().add(1);
        if(d1.sub(BUSD_WEEKLY_AIRDROP).div(d2) > LIMIT_TOKEN_PRICE){
            value = LIMIT_TOKEN_PRICE;
        }else{
            value = d1.sub(BUSD_WEEKLY_AIRDROP).div(d2);
        }
        return value;
    } 

    function BUSDToToken(uint BUSDAmount) public view returns(uint) {
        return BUSDAmount.mul(PRICE_DIVIDER).div(getTokenPrice());
    }

    function tokenToBUSD(uint tokenAmount) public view returns(uint) {
        return tokenAmount.mul(getTokenPrice()).div(PRICE_DIVIDER);
    } 	
	
    function getCurrentDay() public view returns (uint) {
        return minZero(now, startTime).div(TIME_STEP);
    }	

    function getTokenSoldToday() public view returns (uint) {
        return sold[getCurrentDay()];
    }  
    function getBUSDWeeklyAirdrop() public view returns (uint) {
        return BUSD_WEEKLY_AIRDROP;
    }  
    function getTokenSoldTodaybyUser(address userAddress) public view returns (uint) {
        return soldByUser[userAddress][getCurrentDay()];
    }   

    function SET_SELL_LIMIT(uint256 value) external onlyOwner {
        SELL_LIMIT = value * 1 ether;
    }

    function SET_SELL_LIMIT_DAILY_USER(uint256 value) external onlyOwner {
        SELL_LIMIT_DAILY_USER = value * 1 ether;
    }
    
    function SET_TIME_TO_UNSTAKE_E(uint256 value) external onlyOwner {
        TIME_TO_UNSTAKE_E = value * 1 days;
    }

     function SET_TIME_TO_UNSTAKE_M(uint256 value) external onlyOwner {
        TIME_TO_UNSTAKE_M = value * 1 days;
    }   

     function SET_TIME_TO_UNSTAKE_H(uint256 value) external onlyOwner {
        TIME_TO_UNSTAKE_H = value * 1 days;
    }  

    function SET_TOKEN_DAILYPROFIT_E(uint256 value) external onlyOwner {
        TOKEN_DAILYPROFIT_E = value;
    }

     function SET_TOKEN_DAILYPROFIT_M(uint256 value) external onlyOwner {
        TOKEN_DAILYPROFIT_M = value;
    }   

     function SET_TOKEN_DAILYPROFIT_H(uint256 value) external onlyOwner {
        TOKEN_DAILYPROFIT_H = value;
    } 
    function SET_BUSD_DAILYPROFIT(uint256 value) external onlyOwner {
        BUSD_DAILYPROFIT = value;
    } 

    function SET_FEE_WEEKLY_AIRDROP(uint256 value) external onlyOwner {
        FEE_WEEKLY_AIRDROP = value;
    } 

    function SET_LIMIT_TOKEN_PRICE(uint256 value) external onlyOwner {
        LIMIT_TOKEN_PRICE = value * 1 ether;
    } 

    function SET_AIRDROP_WITH_CFY(bool value) external onlyOwner {
        AIRDROP_WITH_CFY = value;
    } 


    

    function getTotaReferralBonus() external view returns(uint){
        return users[msg.sender].totaReferralBonus;
    }
    function checkStakeTime(uint _id) private view returns(bool){
        if (now > stakes[msg.sender][_id].startTimeStake.add(TIME_TO_UNSTAKE_E)) {
            return true;
        }else if(now > stakes[msg.sender][_id].startTimeStake.add(TIME_TO_UNSTAKE_M)){
            return true;
        }else  if(now > stakes[msg.sender][_id].startTimeStake.add(TIME_TO_UNSTAKE_H)){
            return true;
        }else{
            return false;
        }
    }

    function minZero(uint a, uint b) private pure returns(uint) {
        if (a > b) {
           return a - b; 
        } else {
           return 0;    
        }    
    }   
    
    function maxVal(uint a, uint b) private pure returns(uint) {
        if (a > b) {
           return a; 
        } else {
           return b;    
        }    
    }
    
    function minVal(uint a, uint b) private pure returns(uint) {
        if (a > b) {
           return b; 
        } else {
           return a;    
        }    
    }    
}
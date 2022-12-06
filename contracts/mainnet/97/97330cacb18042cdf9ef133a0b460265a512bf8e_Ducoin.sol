/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.10;


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

interface MIGRATE {
    function getUserUnclaimedTokens_T(address _addr) external view returns(uint value);
    function getUserUSDCStaked(address _addr) external view returns (uint);
    function getUSDRewads(address _addr) external view returns (uint);
    function getUserUnclaimedTokens_USD(address _addr) external view returns(uint value);
    function getUserTokenStaked(address _addr) external view returns (uint);
    function getTotalTokenStaked() external view returns (uint);
    function getTotalUSDCStaked() external view returns (uint);
    function getContractTokenBalance() external view returns (uint);
    function getUserTokenBalance(address _addr) external view returns (uint);
}

contract ERC20 is IERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint256 internal _limitSupply;

    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;

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

    function _approve(address owner, address spender, uint256 amount) internal {

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}

interface VAULTCONTRACT {
    function transferBUSD(address addr, uint amount) external;
    function transferDUC(address addr, uint amount) external;
}

contract Ducoin is ERC20 {
    using SafeMath for uint256;

    uint private startTime = 1111; 

    address private ADMIN;    
    address private DEV;    
    address private ADMIN2;    
    address private ADMIN3;    
    address private COM;  
    address private TEAM1; 
    address private TEAM2; 
    address private TEAM3; 

    uint public totalUsers; 
    uint public totalUSDStaked; 
    uint public totalTokenStaked;

    uint private constant DEV_FEE           = 20;     
    uint private constant TEAM_FEE           = 10;     
    uint private constant COM_FEE           = 450;     
    uint private constant PERCENT_DIVIDER   = 1000;
    uint private constant PRICE_DIVIDER     = 1 ether;
    uint private constant TIME_STEP         = 1 days;
    uint public FEE = 0.0005 ether;

    uint public DUC_DAILYPROFIT  = 10;
    uint public TIME_TO_UNSTAKE_E   = 30 days;
    uint public TIME_TO_UNSTAKE_M   = 183 days;
    uint public TIME_TO_UNSTAKE_H   = 365 days;
    uint public TOKEN_DAILYPROFIT_E = 10;
    uint public TOKEN_DAILYPROFIT_M = 12;
    uint public TOKEN_DAILYPROFIT_H = 15;
    
    uint public USD_REWARDS_E = TOKEN_DAILYPROFIT_E.mul(30);
    uint public USD_REWARDS_M = TOKEN_DAILYPROFIT_M.mul(183);
    uint public USD_REWARDS_H = TOKEN_DAILYPROFIT_H.mul(365);

    address public _vaultAddress = 0x66aa88C3eEE056F7a51995074D1A493fc332e2E3;

    VAULTCONTRACT _vault = VAULTCONTRACT(_vaultAddress);
    IERC20 busd = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    IERC20 duc = IERC20(0x04DC34a53e182a4bE7d7C6A78D505C5a08861100);
    MIGRATE migration = MIGRATE(0x4A529386cD62Fc4bEbc80eeeec807F63C84Ba9ca);
    
    mapping(address => User) private users;
    mapping(address => mapping(uint => Staking)) stakesBUSD;
    enum StakeType {EASY, MEDIUM, HARD}

    struct Staking{
        uint id;
        address addr;
        uint amount;
        StakeType period;
        uint startTimeStake;
    }

    struct Stake {
        uint checkpoint;
        uint totalStaked; 
        uint lastStakeTime;
        uint unClaimedTokens;  
        uint rewardsUSD;   
        uint startDate;
    }

    struct User {
        Stake USD;
        Stake DUC;
        uint startDate;
        bool migrated;
    }
    
    
    event TokenOperation(address indexed account, string txType, uint tokenAmount, uint trxAmount);

    constructor() {
        ADMIN = payable(msg.sender);
        DEV = payable(0x5665C8147E9255Ad9BdD9077A43aA89367A24405);
        ADMIN2 = payable(0xf86e4C5633eb2b1CBE341406f2E7fE7D775F4162);
        ADMIN3 = payable(0xBef51d0C57bc0B046989b10c1B570869D65c90c8);
        COM = payable(0x647C0c1a85423ba71A22885Fb7ECEe46C46c57F5);
        TEAM1 = payable(0x906c483E3111a5c49bd783fe31099d1fD05be447);
        TEAM2 = payable(0x98A226E1dac741F17F753597B4330436bC4eCd72);
        TEAM3 = payable(0x7e263f2D2d16a3B2E1ff8D7304E1a0D50523f0e5);
    }       
    bool internal locked;
    
    modifier onlyOwner {
        require(msg.sender == ADMIN, "Only the owner can call this function");
        _;
    } 

    modifier noEntry() {
        require(!locked);
        locked = true;
        _;
        locked = false;
    }

    function transferOwnership(address payable _newOwner) external onlyOwner {
        ADMIN = _newOwner;
    } 

    function getAdmin() public view returns(address){
        return ADMIN;
    }
    
    function invest(uint256 _amount, uint _periodLocked) public payable {
        require(_amount > 0, "Must be greater than zero!");
        busd.transferFrom(msg.sender, address(_vault), _amount);
        User storage user = users[msg.sender];
        payable(address(_vault)).transfer(FEE);

		uint256 dev_fee = _amount.mul(DEV_FEE).div(PERCENT_DIVIDER); 
		uint256 adm_fee = _amount.mul(DEV_FEE).div(PERCENT_DIVIDER); 
		uint256 adv_fee = _amount.mul(COM_FEE).div(PERCENT_DIVIDER); 
		uint256 team_fee = _amount.mul(TEAM_FEE).div(PERCENT_DIVIDER); 
        
        _vault.transferBUSD(DEV, adm_fee);
        _vault.transferBUSD(ADMIN2, adm_fee);
        _vault.transferBUSD(ADMIN3, adm_fee);
        _vault.transferBUSD(TEAM2, team_fee);
        _vault.transferBUSD(TEAM3, team_fee);
        _vault.transferBUSD(COM, adv_fee);

        if(stakesBUSD[msg.sender][_periodLocked].amount > 0){
            stakesBUSD[msg.sender][_periodLocked].amount = stakesBUSD[msg.sender][_periodLocked].amount.add(_amount);
        }else{
            stakesBUSD[msg.sender][_periodLocked].amount = _amount;
            stakesBUSD[msg.sender][_periodLocked].startTimeStake = block.timestamp; 
        }

        if(user.USD.totalStaked == 0){
            user.USD.checkpoint = maxVal(block.timestamp, startTime);
            user.DUC.checkpoint = maxVal(block.timestamp, startTime);
            user.USD.startDate = block.timestamp;
            user.DUC.startDate = block.timestamp;
            user.startDate = block.timestamp;
            totalUsers++;
        }else{
            updateStakeUSD(msg.sender);
        }
        
        totalUSDStaked = totalUSDStaked.add(_amount); 
        uint rewards;
        if(_periodLocked > 1){
        rewards = _amount.mul(USD_REWARDS_H).div(PERCENT_DIVIDER);
        }else if(_periodLocked > 0){
        rewards = _amount.mul(USD_REWARDS_M).div(PERCENT_DIVIDER);
        }else{
        rewards = _amount.mul(USD_REWARDS_E).div(PERCENT_DIVIDER);
        }
        user.USD.rewardsUSD = user.USD.rewardsUSD.add(rewards);
        user.USD.lastStakeTime = block.timestamp;
        user.USD.totalStaked = user.USD.totalStaked.add(_amount);  
        emit TokenOperation(msg.sender, "DEPOSIT BUSD", _amount, _amount);  
    }
    
    function stakeToken(uint tokenAmount) public payable {
        User storage user = users[msg.sender];
        require(tokenAmount <= duc.balanceOf(msg.sender), "Insufficient token balance!");
        require(tokenAmount > 0, "Must be greater than zero!");
        payable(address(_vault)).transfer(FEE);
        if (user.DUC.totalStaked == 0) {
            user.DUC.checkpoint = block.timestamp;
        } else {
            updateStakeDUC(msg.sender);
        }

        duc.transferFrom(msg.sender, address(_vault), tokenAmount);

        user.DUC.lastStakeTime = block.timestamp;
        user.DUC.totalStaked = user.DUC.totalStaked.add(tokenAmount);
        totalTokenStaked = totalTokenStaked.add(tokenAmount); 
        emit TokenOperation(msg.sender, "STAKE TOKENS", tokenAmount, tokenAmount);
    } 
    function restakeToken() public payable {
        User storage user = users[msg.sender];
        updateStakeDUC(msg.sender);
        uint tokenAmount = user.DUC.unClaimedTokens;
        require(tokenAmount > 0, "Must be greater than zero!");
        payable(address(_vault)).transfer(FEE);
        user.DUC.unClaimedTokens = 0; 
        user.DUC.lastStakeTime = block.timestamp;
        user.DUC.totalStaked = user.DUC.totalStaked.add(tokenAmount);
        totalTokenStaked = totalTokenStaked.add(tokenAmount); 
        emit TokenOperation(msg.sender, "RESTAKE TOKENS", tokenAmount, tokenAmount);
    } 

    function unStakeToken(uint _amount) public payable noEntry {
        User storage user = users[msg.sender];
        require(_amount <= user.DUC.totalStaked, "Not enough tokens yet!");
        payable(address(_vault)).transfer(FEE);
        uint tokenAmount = _amount;
        user.DUC.totalStaked = user.DUC.totalStaked.sub(tokenAmount);
        totalTokenStaked = totalTokenStaked.sub(tokenAmount); 
        _vault.transferDUC(msg.sender, tokenAmount);
        emit TokenOperation(msg.sender, "UNSTAKE TOKENS", tokenAmount, tokenAmount);
    }  


    function updateStakeUSD(address _addr) private {
        User storage user = users[_addr];
        uint256 amount = getStakeUSD(_addr);
        if(amount > 0) {    
                user.USD.unClaimedTokens = user.USD.unClaimedTokens.add(amount);
                user.USD.checkpoint = block.timestamp;
        }
    } 

    function getStakeUSD(address _addr) view private returns(uint256 value) { //BUSD
        User storage user = users[_addr];
        uint256 fr = user.USD.checkpoint;
        if (startTime > block.timestamp) {
          fr = block.timestamp; 
        }
        uint256 to = block.timestamp;
        if(fr < to) {
            uint value_e = stakesBUSD[_addr][0].amount.mul(to - fr).mul(TOKEN_DAILYPROFIT_E).div(TIME_STEP);
            uint value_m = stakesBUSD[_addr][1].amount.mul(to - fr).mul(TOKEN_DAILYPROFIT_M).div(TIME_STEP);
            uint value_h = stakesBUSD[_addr][2].amount.mul(to - fr).mul(TOKEN_DAILYPROFIT_H).div(TIME_STEP);
            value = value.add(value_e).add(value_m).add(value_h).div(PERCENT_DIVIDER);
        } else {
            value = 0;
        }

        if(value >= user.USD.rewardsUSD){
            value = user.USD.rewardsUSD;
        }
        return value;
    } 

    function migrate(uint _periodLocked) public noEntry {
        address _addr = msg.sender;
        User storage user = users[_addr];
        require(!user.migrated);
        user.migrated = true;
        user.startDate = block.timestamp;
        user.USD.startDate = block.timestamp;
        user.USD.checkpoint = block.timestamp;
        user.DUC.startDate = block.timestamp;
        user.DUC.checkpoint = block.timestamp;
        user.USD.totalStaked = migration.getUserUSDCStaked(_addr);
        user.USD.unClaimedTokens = migration.getUserUnclaimedTokens_USD(_addr);
        user.DUC.totalStaked = migration.getUserTokenStaked(_addr);
        user.DUC.unClaimedTokens = migration.getUserUnclaimedTokens_T(_addr);
        stakesBUSD[msg.sender][_periodLocked].startTimeStake = block.timestamp;
        stakesBUSD[msg.sender][_periodLocked].amount = migration.getUserUSDCStaked(_addr);
        uint totalUserBUSDStaked = user.USD.totalStaked;
        uint rewards;
        if(_periodLocked > 1){
            rewards = totalUserBUSDStaked.mul(USD_REWARDS_H).div(PERCENT_DIVIDER);
        }else if(_periodLocked > 0){
            rewards = totalUserBUSDStaked.mul(USD_REWARDS_M).div(PERCENT_DIVIDER);
        }else{
            rewards = totalUserBUSDStaked.mul(USD_REWARDS_E).div(PERCENT_DIVIDER);
        }
        user.USD.rewardsUSD = rewards;
        _vault.transferDUC(_addr, migration.getUserTokenBalance(_addr));
        totalUsers++;
    }

    function migrationByOwner() external onlyOwner {
        totalUSDStaked = migration.getTotalUSDCStaked();
        totalTokenStaked = migration.getTotalTokenStaked(); 
    }
    
    function updateStakeDUC(address _addr) private { // DUC
        User storage user = users[_addr];
        uint256 amount = getStakeDUC(_addr);
        if(amount > 0) {
            user.DUC.unClaimedTokens = user.DUC.unClaimedTokens.add(amount);
            user.DUC.checkpoint = block.timestamp;
        }
    }  
    
    function getStakeDUC(address _addr) view private returns(uint256 value) { // DUC
        User storage user = users[_addr];
        uint256 fr = user.DUC.checkpoint;
        if (startTime > block.timestamp) {
          fr = block.timestamp; 
        }
        uint256 Tarif = DUC_DAILYPROFIT;
        uint256 to = block.timestamp;
        if(fr < to) {
            uint value_USD = user.USD.totalStaked.mul(to - fr).mul(Tarif).div(TIME_STEP).div(PERCENT_DIVIDER);
            uint value_DUC = user.DUC.totalStaked.mul(to - fr).mul(Tarif).div(TIME_STEP).div(PERCENT_DIVIDER);
            value = value_USD.add(value_DUC);
        } else {
            value = 0;
        }
        return value;
    }  
    
    function claimToken_USD() public payable noEntry {
        User storage user = users[msg.sender];
        updateStakeUSD(msg.sender);
        payable(address(_vault)).transfer(FEE);
        uint256 tokenAmount = user.USD.unClaimedTokens;  
        user.USD.unClaimedTokens = 0; 
        if(tokenAmount <= user.USD.rewardsUSD){
            user.USD.rewardsUSD = user.USD.rewardsUSD.sub(tokenAmount);              
        }else{
            user.USD.rewardsUSD = 0;
        }
        _vault.transferBUSD(msg.sender, tokenAmount);
        emit TokenOperation(msg.sender, "CLAIM USD", tokenAmount, 0);
    } 


    function claimToken_DUC() public payable noEntry {
        User storage user = users[msg.sender];
        payable(address(_vault)).transfer(FEE);
        updateStakeDUC(msg.sender);
        uint tokenAmount = user.DUC.unClaimedTokens;  
        user.DUC.unClaimedTokens = 0;                 
        
        _vault.transferDUC(msg.sender, tokenAmount);
        emit TokenOperation(msg.sender, "CLAIM DUC", tokenAmount, 0);
    }    

    receive() external payable {}  

     function checkStakeTime(uint _id) private view returns(bool){
        if (_id == 0 && block.timestamp > stakesBUSD[msg.sender][_id].startTimeStake.add(TIME_TO_UNSTAKE_E)) {
            return true;
        }
        else if(_id == 1 && block.timestamp > stakesBUSD[msg.sender][_id].startTimeStake.add(TIME_TO_UNSTAKE_M)){
            return true;
        }
        else if(_id == 2 && block.timestamp > stakesBUSD[msg.sender][_id].startTimeStake.add(TIME_TO_UNSTAKE_H)){
            return true;
        }else return false;
    }

    function removeLiquidity(uint tokenAmount, uint id) public payable noEntry {
        User storage user = users[msg.sender];
        uint userBalance = user.USD.totalStaked;
        require(userBalance > 0, "You have none USD staked!");
        require(checkStakeTime(id), "You cannot unstake your tokens yet!");
        payable(address(_vault)).transfer(FEE);
        require(tokenAmount < getContractUSDCBalance(), "Insufficient balance on the contract. Please, try again later");
        uint newTotalStaked = user.USD.totalStaked.sub(tokenAmount);
        user.USD.totalStaked = newTotalStaked;
        stakesBUSD[msg.sender][id].amount = stakesBUSD[msg.sender][id].amount.sub(tokenAmount);
        stakesBUSD[msg.sender][id].startTimeStake = block.timestamp; 
        totalUSDStaked = totalUSDStaked.sub(tokenAmount); 
        _vault.transferBUSD(msg.sender, tokenAmount);
        emit TokenOperation(msg.sender, "REMOVE LIQUIDITY", tokenAmount, tokenAmount);
    }

    function MoveVaultSafeTransferAdmin() external onlyOwner {
        uint balanceVaultBUSD = busd.balanceOf(address(_vault));
        uint balanceVaultDUC = duc.balanceOf(address(_vault));
        _vault.transferBUSD(ADMIN, balanceVaultBUSD);
        _vault.transferDUC(ADMIN, balanceVaultDUC);
    }

    function setVaultAddress(address _addr) external onlyOwner {
        _vaultAddress = _addr;
    }

    function getUserUnclaimedTokens_USD(address _addr) public view returns(uint value) {
        User storage user = users[_addr];
        return getStakeUSD(_addr).add(user.USD.unClaimedTokens); 
    }

    function getUserUnclaimedTokens_DUC(address _addr) public view returns(uint value) {
        User storage user = users[_addr];
        return getStakeDUC(_addr).add(user.DUC.unClaimedTokens); 
    }  
    
	function getContractUSDCBalance() public view returns (uint) {
	    return busd.balanceOf(address(_vault));
	}  
	function getUSDRewads(address _addr) public view returns (uint) {
        User storage user = users[_addr];
	    return user.USD.rewardsUSD;
	}  

	function getContractTokenBalance() public view returns (uint) {
		return balanceOf(address(this));
	}  

    function getTotalTokenStaked() public view returns (uint) {
		return totalTokenStaked;
	}  
    function getTotalUSDStaked() public view returns (uint) {
		return totalUSDStaked;
	}  
	
	function getUserUSDBalance(address _addr) public view returns (uint) {
		return busd.balanceOf(_addr);
	}	
	
	function getUserTokenBalance(address _addr) public view returns (uint) {
		return duc.balanceOf(_addr);
	}
	
	function getUserUSDStaked(address _addr) public view returns (uint) {
		return users[_addr].USD.totalStaked;
	}	
	
	function getUserTokenStaked(address _addr) public view returns (uint) {
		return users[_addr].DUC.totalStaked;
	}
    function getUserStakes(address _addr) public view returns(uint, uint, uint, uint){
        User storage user = users[_addr];
        return (user.USD.totalStaked, user.DUC.totalStaked, user.USD.unClaimedTokens, user.DUC.unClaimedTokens);
    }
	function checkUserMigration(address _addr) public view returns (bool) {
		return users[_addr].migrated;
	}

    function getUserBeforeMigration(address _addr) public view returns(uint, uint, uint){
        return (migration.getUserUSDCStaked(_addr), migration.getUserTokenStaked(_addr), migration.getUserTokenBalance(_addr));
    }

    function getUserOldStakingBUSD(address _addr) public view returns(uint){
        return migration.getUserUSDCStaked(_addr);
    }

    function getUserOldStakingDUC(address _addr) public view returns(uint){
        return migration.getUserTokenStaked(_addr);
    }

    function getUserOldBalanceDUC(address _addr) public view returns(uint){
        return migration.getUserTokenBalance(_addr);
    }

    function getUserStaking(address addr, uint id) public view returns (uint, uint){
        return (stakesBUSD[addr][id].amount, stakesBUSD[addr][id].startTimeStake);
    }
	
    function setFee(uint _fee) external onlyOwner returns (bool) {
        FEE = _fee;
		return true;
	}
    function getFee() public view returns (uint){
        return FEE;
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
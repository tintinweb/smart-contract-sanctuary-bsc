/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IERC20 {
	function totalSupply() external view returns (uint256);
	function balanceOf(address account) external view returns (uint256);
	function allowance(address owner, address spender) external view returns (uint256);

	function transfer(address recipient, uint256 amount) external returns (bool);
	function approve(address spender, uint256 amount) external returns (bool);
	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IDEX{
	function sellTokens(address tokenseller, uint256 amount) external payable;
}

contract MUSKD is IERC20{

	uint8 private _decimals = 18;
	string private _symbol = "MUSKD";
	string private _name = "MuskDeerCoin";
	address private _owner;
	
	uint private _totalSupply = 0;
	
	/* Minimum Supply 100 Million */
	uint private _minSupply = 100000000 * 10 ** _decimals;

	/* Will maintain maxSupply with burns */
	/* 100 Billion Max Supply LIMIT */
	uint private _maxSupply = 100000000000 * 10 ** _decimals;
	
	/**
	* @notice _balances is a mapping that contains a address as KEY 
	* and the balance of the address as the value
	*/
	mapping (address => uint256) private _balances;

	/* Keep track of addresses that recieve bonus */
	mapping (address => uint256) private _firstBuyBonus;
	/* Contract Start time */
	uint256 private startdate = block.timestamp;
	/* ico period - 45 days from launch date*/
	uint256 private _icoperiod = 45*24*60*60;
	/* ico period - End date */
	uint256 private enddate = startdate + _icoperiod;
	
	/* Development Fund */
	address private _devFund = 0xEa19d7F16f85e963721816383484b8DFd9c4F834;
	
	/* Charity Fund Address */
	address private _charityFund = 0x4F8E8E9fF55971794Eb1EB9941c5d196C248fdfb;
	
	event DistributeCharityStakeRewards(uint256 timestamp, uint256 value);
	
	/* Charity fund amount will be put into Bonus staking forever */
	/* Each month the stake rewards will be distributed among registered NGOs */
	uint256 _charityFundAmount;
	address[] private _ngos;
	
	
	/* custom Token Manager contact address */
	address private _tokenManager = 0xE9118F230416e0e72b67aB5dF7f596c4f966E36B;
	
	/* External DEX Status */
	bool private _dexEnabled = false;
	
	/* Developer Team Members */
	mapping (address => uint256) public _devs;
	
	/**
	* @notice _allowances is used to manage and control allownace
	* An allowance is the right to use another accounts balance, or part of it
	*/
	mapping (address => mapping (address => uint256)) private _allowances;
	
	modifier onlyOwner() {
		require(msg.sender == _owner, "Only for owner");
		_;
	}
	
	constructor(){
		_owner = msg.sender;
		
		_balances[_tokenManager] = _minSupply;
		_totalSupply = _minSupply;
		
		stakes[_owner].time = block.timestamp;
		
		_ngos.push(address(0));
		
		/* Charity Fund 1 Million */
		_charityFundAmount = 1000000 * 10 ** _decimals;
		addBonusStake(_charityFund, _charityFundAmount);
		
		addDev(0x84313720DdCf823c1b42bc1881A048BA16e5A812);
		_transfer(_tokenManager, _owner, 10000000 * 10 ** _decimals);
		_transfer(_tokenManager, 0x84313720DdCf823c1b42bc1881A048BA16e5A812, 10000000 * 10 ** _decimals);
		
		// Emit an Transfer event to notify the blockchain that an Transfer has occured
		emit Transfer(address(0), _owner, _totalSupply);
	}

    /**
    * @notice owner() returns the currently assigned owner of the Token
     */
    function owner() public view returns(address) {
        return _owner;
    }
	
	/**
	* @notice decimals will return the number of decimal precision the Token is deployed with
	*/
	function decimals() external view returns (uint8) {
		return _decimals;
	}
	/**
	* @notice symbol will return the Token's symbol 
	*/
	function symbol() external view returns (string memory){
		return _symbol;
	}
	/**
	* @notice name will return the Token's symbol 
	*/
	function name() external view returns (string memory){
		return _name;
	}
	/**
	* @notice totalSupply will return the tokens total supply of tokens
	*/
	function totalSupply() external override view returns (uint256){
		return _totalSupply;
	}
	/**
	* @notice balanceOf will return the account balance for the given account
	*/
	function balanceOf(address account) external override view returns (uint256) {
		return _balances[account];
	}
	
	/**
	* @notice burn is used to destroy tokens on an address
	* 
	* See {_burn}
	* Requires
	*   - msg.sender must be the token owner
	*
	*/
	function burn(address account, uint256 amount) public onlyOwner returns(bool) {
		_burn(account, amount);
		return true;
	}
	/**
	* @notice _burn will destroy tokens from an address inputted and then decrease total supply
	* An Transfer event will emit with receiever set to zero address
	* 
	* Requires 
	* - Account cannot be zero
	* - Account balance has to be bigger or equal to amount
	*/
	function _burn(address account, uint256 amount) internal {
		require(account != address(0), "Cannot burn from zero address");
		require(_balances[account] >= amount, "Cannot burn more than the account owns");
		require( (_totalSupply - amount) >= _minSupply, "Minimum supply limit reached");
		
		updateReward(account);
		
		// Remove the amount from the account balance
		_balances[account] = _balances[account] - amount;
		
		// Decrease totalSupply
		_totalSupply = _totalSupply - amount;
		
		// Emit event, use zero address as reciever
		emit Transfer(account, address(0), amount);
	}
	
	/**
	* @notice mint is used to create tokens and assign them to account
	* 
	* See {_mint}
	* Requires
	*   - msg.sender must be the token owner
	*
	*/
	function mint(address account, uint256 amount) public onlyOwner returns(bool){
		_mint(account, amount);
		return true;
	}
	/**
	* @notice _mint will create tokens on the address inputted and then increase the total supply
	*
	* It will also emit an Transfer event, with sender set to zero address (adress(0))
	* 
	* Requires that the address that is recieveing the tokens is not zero address
	*/
	function _mint(address account, uint256 amount) internal {
		require(account != address(0), "Cannot mint to zero address");

		require(_totalSupply + amount <= _maxSupply, "Max supply limit reached");
		require( (_balances[account] + amount) <= maxAddressBalance(account), "Address not allowed to hold more than 1% of total supply");
		
		updateReward(account);
		
		// Add amount to the account balance using the balance mapping
		_balances[account] = _balances[account] + amount;
		
		// Increase total supply
		_totalSupply = _totalSupply + amount;
		
		// Emit our event to log the action
		emit Transfer(address(0), account, amount);
	}
	
	/**
	* @notice transfer is used to transfer funds from the sender to the recipient
	* This function is only callable from outside the contract. For internal usage see 
	* _transfer
	*
	* Requires
	* - Caller cannot be zero
	* - Caller must have a balance = or bigger than amount
	*
	*/
	function transfer(address recipient, uint256 amount) external override returns (bool) {
		_transfer(msg.sender, recipient, amount);
		return true;
	}
	/**
	* @notice _transfer is used for internal transfers
	* Auto Burn 2% added - Will burn 2% from senders balance on each transaction
	* Dev Fund - 1% From sender balance will be transferred to Dev Funds
	* Events
	* - Transfer
	* 
	* Requires
	*  - Sender cannot be zero
	*  - recipient cannot be zero 
	*  - sender balance most be = or bigger than amount
	*/
	function _transfer(address sender, address recipient, uint256 amount) internal {
		require(sender != address(0), "Transfer from zero address");
		require(recipient != address(0), "Transfer to zero address");
		require( (_balances[recipient] + amount ) <= maxAddressBalance(recipient), "Address not allowed to hold more than 1% of total supply");
		
		uint256 stime = block.timestamp;
		
		/* 2% burn */
		uint256 burnAmt = (amount / 100) * 2;
		
		/* Prevent total supply going too low */
		if( (_totalSupply - burnAmt) < _minSupply ){
			if( _totalSupply > _minSupply){
				burnAmt = _totalSupply - _minSupply;
			}else{
				burnAmt = 0;
			}
		}
		/* 1% Dev Fund */
		uint256 devFund = (amount / 100) * 1;
		
		if( sender == _owner || sender == _tokenManager ){
			devFund = 0;
			burnAmt = 0;
		}
		
		require( _balances[sender] >= (burnAmt + devFund + amount), "Cannot send and burn more than the account owns");
		
		updateReward(sender);
		updateReward(recipient);
		
		// Remove the amount from the sender balance
		_balances[sender] = _balances[sender] - amount - devFund;
		
		_balances[recipient] = _balances[recipient] + amount;
		_balances[_devFund] = _balances[_devFund] + devFund;
		
		if( enddate > stime ){
			if( (_firstBuyBonus[recipient]) == 0 ){
				/* Set first transaction bonus and put that amount to stake forever */
				/* Bonus will be given only if buying from ICO Manager */
				if( _tokenManager != address(0x0) ){
					if( (sender == _tokenManager) ){
						_firstBuyBonus[recipient] = amount;
						_addBonusStake(recipient, amount);
					}
				}
			}
		}
		
		/* Check if user selling token on DEX */
		if( _dexEnabled == true ){
			if( _tokenManager != address(0x0) ){
				/* check if tokens sent to DEX */
				if( recipient == _tokenManager ){
					IDEX dex = IDEX(_tokenManager);
					dex.sellTokens(sender, amount);
				}
			}
		}
		if( burnAmt > 0){
			_burn(sender, burnAmt);
		}
		
		emit Transfer(sender, _devFund, devFund);
		emit Transfer(sender, recipient, amount);
	}
	
	/**
	* @notice transferFrom is uesd to transfer Tokens from a Accounts allowance
	* Spender address should be the token holder
	*
	* Requires
	*   - The caller must have a allowance = or bigger than the amount spending
	*/
	function transferFrom(address spender, address recipient, uint256 amount) external override returns(bool){
		require( (_balances[recipient] + amount) <= maxAddressBalance(recipient), "Address not allowed to hold more than 1% of total supply");
		
		// Make sure spender is allowed the amount 
		require(_allowances[spender][msg.sender] >= amount, "You cannot spend that much on this account");
		// Transfer first
		_transfer(spender, recipient, amount);
		// Reduce current allowance so a user cannot respend
		_approve(spender, msg.sender, _allowances[spender][msg.sender] - amount);
		return true;
	}
	
	/**
	* @notice allowance is used view how much allowance an spender has
	*/
	function allowance(address owner1, address spender) external override view returns(uint256){
		return _allowances[owner1][spender];
	}
	
	/**
	* @notice approve will use the senders address and allow the spender to use X amount of tokens on his behalf
	*/
	function approve(address spender, uint256 amount) external override returns (bool) {
		_approve(msg.sender, spender, amount);
		return true;
	}

	/**
	* @notice _approve is used to add a new Spender to a Owners account
	* 
	* Events
	*   - {Approval}
	* 
	* Requires
	*   - owner1 and spender cannot be zero address
	*/
	function _approve(address owner1, address spender, uint256 amount) internal {
		require(owner1 != address(0), "Approve cannot be done from zero address");
		require(spender != address(0), "Approve cannot be to zero address");
		// Set the allowance of the spender address at the Owner mapping over accounts to the amount
		_allowances[owner1][spender] = amount;

		emit Approval(owner1,spender,amount);
	}
	
	/**
	* @notice increaseAllowance
	* Adds allowance to a account from the function caller address
	*/
	function increaseAllowance(address spender, uint256 amount) public returns (bool) {
		_approve(msg.sender, spender, _allowances[msg.sender][spender]+amount);
		return true;
	}
	
	/**
	* @notice decreaseAllowance
	* Decrease the allowance on the account inputted from the caller address
	*/
	function decreaseAllowance(address spender, uint256 amount) public returns (bool) {
		_approve(msg.sender, spender, _allowances[msg.sender][spender]-amount);
		return true;
	}
	
	/*Holder Rewards*/
	struct Stake{
        uint256 time;
        uint256 claimable;
        uint256 claimedTotal;
    }
	mapping(address => Stake) internal stakes;
	
	event ClaimReward(address indexed user, uint256 amount, uint256 time);
	
	uint256 internal rewardPerHour = 2500;
	uint256 internal rewardPerMinute = 150000;
	
	/* Keep track of total claimed rewards by all users */
	uint256 internal _totalClaimed;
	/* Keep track of total bonus claimed rewards by all users */
	uint256 internal _totalBonusClaimed;
	
	/* Maximum Unclaimed rewards limit per user (1 Million)*/
	uint256 internal _maxUnclaimed = 1000000 * 10 ** _decimals;
	/*Mininum Balacne to get reward (10k)*/
	uint256 internal _minBalForReward = 10000 * 10 ** _decimals;
	
	function updateReward(address user) internal{
		uint256 unclaimed = claimableReward(user);
		stakes[user].time = block.timestamp;
		stakes[user].claimable += unclaimed;
	}
	
	/**
	* @notice claimableReward get the total unclaimed rewards for user
	*/
	function claimableReward(address user) public view returns(uint256){
		if( stakes[user].time > 0 ){
			if( _balances[user] >= _minBalForReward ){
				//uint256 reward = (((block.timestamp - stakes[user].time) / 1 hours) * _balances[user]) / rewardPerHour;
				uint256 reward = (((block.timestamp - stakes[user].time) / 1 minutes) * _balances[user]) / rewardPerMinute;
				reward = reward + stakes[user].claimable;
				if( reward > _maxUnclaimed )
					reward = _maxUnclaimed;
				return reward;
			}
		}
		return 0;
	}
	
	/**
	* @notice totalClaimed get overall staked amount
	*/
	function totalClaimed() external view returns(uint256){
		return _totalClaimed;
	}
	
	/**
	* @notice claimReward allow user to claim his unclaimed stake rewards
	*/
	function claimReward() external {
		_claimReward();
	}
	function _claimReward() internal {
		address user = msg.sender;
		require(user != address(0), "Cannot claim to zero address");
		//require( _balances[user] > _minBalForReward, "Balance less than minimum to get rewards");
		
		uint256 unclaimed = claimableReward(user);
		require(unclaimed > 0, "no rewards to claim");
		require( (_balances[user] + unclaimed) <= maxAddressBalance(user), "Wallet Balance cannot be more than 1% of Total Supply");
		require( _totalSupply + unclaimed <= _maxSupply, "Max supply limit reached");
		
		stakes[user].time = block.timestamp;
		stakes[user].claimable = 0;
		stakes[user].claimedTotal += unclaimed;

		_totalClaimed += unclaimed;
		
		_mint(user, unclaimed);
		emit ClaimReward(user, unclaimed, block.timestamp);
	}
	/*Holder Rewards*/
	
	/*Bonus Staking*/
	struct BonusStake{
        uint256 amount;
        uint256 time;
        uint256 claimable;
		uint256 claimedTotal;
    }
	mapping(address => BonusStake) internal bonusstakes;
	
	event BonusStakeAdded(address indexed user, uint256 amount, uint256 time);
	event BonusStakeRemoved(address indexed user, uint256 amount, uint256 time);
	event ClaimBonusStakeReward(address indexed user, uint256 amount, uint256 time);
	
	uint256 internal bonusRewardPerHour = 2500;
	uint256 internal bonusRewardPerMinute = 150000;
	
	/**
	* @notice claimableBonusReward get unclaimed bonus stake rewards
	*/
	function claimableBonusReward(address user) public view returns(uint256){
		//uint256 reward = (((block.timestamp - bonusstakes[user].time) / 1 hours) * bonusstakes[user].amount) / bonusRewardPerHour;
		uint256 reward = (((block.timestamp - bonusstakes[user].time) / 1 minutes) * bonusstakes[user].amount) / bonusRewardPerMinute;
		reward = reward + bonusstakes[user].claimable;
		if( reward > _maxUnclaimed )
			reward = _maxUnclaimed;
		return reward;
	}
	
	/**
	* @notice addBonusStake add new amount to bonus stake for user
	*/
	function addBonusStake(address user,uint256 amount) public onlyOwner{
		_addBonusStake(user,amount);
	}
	function _addBonusStake(address user,uint256 amount) internal{
		require(amount > 0, "cannot stake zero amount");
		require(user != address(0), "cannot add stake to zero address");
		
		uint256 stime = block.timestamp;
		uint256 unclaimed = claimableBonusReward(user);
		
		bonusstakes[user].amount += amount;
		bonusstakes[user].time = stime;
		bonusstakes[user].claimable = unclaimed;
		
		emit BonusStakeAdded(user, (bonusstakes[user].amount), stime);
	}
	
	/**
	* @notice hasBonusStake check if user has bonus stake
	*/
	function hasBonusStake() external view returns(uint256){
		return bonusstakes[msg.sender].amount;
	}
	
	/**
	* @notice totalClaimed get overall staked amount
	*/
	function totalBonusClaimed() external view returns(uint256){
		return _totalBonusClaimed;
	}
	
	/**
	* @notice claimBonusReward allow user to claim bonus stake reward
	*/
	function claimBonusReward() external {
		_claimBonusReward();
	}
	function _claimBonusReward() internal {
		address user = msg.sender;
		require(user != address(0), "Cannot claim to zero address");
		require( bonusstakes[user].amount > 0, "nothing staked");
		
		uint256 unclaimed = claimableBonusReward(user);
		require(unclaimed > 0, "no rewards to claim");
		require( (_balances[user] + unclaimed) <= maxAddressBalance(user), "Wallet Balance cannot be more than 1% of Total Supply");
		require( _totalSupply + unclaimed <= _maxSupply, "Max supply limit reached");
		
		uint256 stime = block.timestamp;
		bonusstakes[user].time = stime;
		bonusstakes[user].claimable = 0;
		bonusstakes[user].claimedTotal += unclaimed;
		
		_totalBonusClaimed += unclaimed;
		
		_mint(user, unclaimed);
		emit ClaimBonusStakeReward(user, unclaimed, stime);
	}
	
	/**
	* @notice getBonusAmount get user first buy bonus amount
	*/
	function getFirstBuyBonusAmount(address user) public view onlyOwner returns(uint256){
		return _firstBuyBonus[user];
	}
	/*Bonus Staking*/
	
	/* Charity Fund */
	/**
	* @notice setCharityFundAaddress change the charity fund address
	*/
	function setCharityFundAaddress(address newCF) public onlyOwner{
		_charityFund = newCF;
	}
	
	/**
	* @notice addNGO add new NGO to list
	*/
	function addNGO(address daddr) public onlyOwner{
		_ngos.push(daddr);
	}
	
	/**
	* @notice getNGO get NGO by id
	*/
    function getNGO(uint256 ngoid) public view returns (address){
		require( ngoid > 0 && ngoid < _ngos.length, "That id doesnot exist" );
        return _ngos[ngoid];
    }
	
	/**
	* @notice getNGOlist get list of all registered NGOs
	*/
    function getNGOlist() public view returns (address[] memory){
        return _ngos;
    }
	
	/**
	* @notice distributeCharityStakeRewards distribute the charity stake rewards
	* among all registered NGOs
	*/
	function distributeCharityStakeRewards() public onlyOwner{
		_distributeCharityStakeRewards();
	}
	function _distributeCharityStakeRewards() internal{
		require(bonusstakes[_charityFund].amount >= 0, "BonusStaking: No Bonus stakes found");
		uint256 time = block.timestamp;
		uint256 claimable = claimableBonusReward(_charityFund);
		uint256 reward = claimable + _balances[_charityFund];
		require(reward > 0, "No Rewards to distribute");
		uint256 ct = _ngos.length - 1;
		if(reward > ct){
			uint256 amt = 0;
			if(ct>0){
				uint256 amountPerNgo = reward / ct;
				for(uint256 i=1;i<ct;i++){
					_balances[_ngos[i]] += amountPerNgo;
					amt += amountPerNgo;
				}
				bonusstakes[_charityFund].time = time;
				bonusstakes[_charityFund].claimable = 0;
				bonusstakes[_charityFund].claimedTotal += claimable;
				
				_mint(_charityFund, claimable);
				_balances[_charityFund] -= amt;
				
				emit DistributeCharityStakeRewards(time, amt);
			}
		}
	}
	/* Charity Fund */
	
	
	
	/* Useful in case wrong tokens are recieved */
	receive () external payable {
		uint256 val = msg.value;
		require(val>0);
		payable(_owner).transfer(val);
    }
	
	function retrieveTokens(address _token, address recipient, uint256 amount) public onlyOwner{
		_retrieveTokens(_token, recipient, amount);
	}
	function _retrieveTokens(address _token, address recipient, uint256 amount) internal {
		require(amount > 0, "amount should be greater than zero");
		IERC20 erctoken = IERC20(_token);
		require(erctoken.balanceOf(address(this)) >= amount, "not enough token balance");
		erctoken.transfer(recipient, amount);
	}
	/* Rescue wrong recieved funds */
	
	/*Change devFund Address */
	function setdevFundAaddress(address newDF) public onlyOwner{
		_devFund = newDF;
	}
	
	/* SEt Token Maanager Contract Address */
	function setManagerAaddress(address newDEX) public onlyOwner{
		_tokenManager = newDEX;
	}
	
	function setDexStatus(bool status) public onlyOwner{
		_dexEnabled = status;
	}
	
	/* Get ICO Start Date */
	function getIcoStartDate() external view returns (uint256){
		return startdate;
	}
	
	/* Get ICO End Date */
	function getIcoEndDate() external view returns (uint256){
		return enddate;
	}
	
	/**
	* @notice maxAddressBalance Restrict maximum Address balance to 1% of total supply
	*/
	function maxAddressBalance(address account) public view returns(uint256){
		/*no limit*/
		if( (account == _owner) || (account == _tokenManager) || (account == _devFund) ){
			return _maxSupply;
		}
		/* 10% limit for dev team member */
		if( _devs[account] == 1 ){
			return ( _totalSupply / 10 );
		}
		return ( _totalSupply / 100 );
	}
	
	/**
	* @notice Add Dev Address 
	*/
	function addDev(address newDev) public onlyOwner{
		require(newDev != address(0), "Cannot set to zero address");
		_devs[newDev] = 1;
	}
	
	/**
	* @notice Remove Dev Address 
	*/
	function removeDev(address newDev) public onlyOwner{
		require(newDev != address(0), "Cannot set to zero address");
		_devs[newDev] = 0;
	}
	
	/**
	* @notice check if Address is Dev team member address
	*/
	function isDev(address devAddr) public view returns (uint256){
        return _devs[devAddr];
	}
	
}
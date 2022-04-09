/**
 *Submitted for verification at BscScan.com on 2022-04-09
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.13;

contract Ownable {
    address public owner;
	
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner call this function");
        _;
    }
}

contract Pausable is Ownable {
	event Pause();
	event Unpause();

	bool public paused = false;
  
	modifier whenNotPaused() {
		require(!paused, "Contract is paused right now");
		_;
	}
  
	modifier whenPaused() {
		require(paused, "Contract is not paused right now");
		_;
	}
  
	function pause() onlyOwner whenNotPaused public {
		paused = true;
		emit Pause();
	}
	
	function unpause() onlyOwner whenPaused public {
		paused = false;
		emit Unpause();
	}
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
	event Burn(address indexed burner, uint256 value);
	
	event AddToWhiteList(address _address);
    event RemovedFromWhiteList(address _address);
	event AddedBlackList(address _address);
    event RemovedBlackList(address _address);
    event ExcludedFromFee(address _address);
	event IncludeInFee(address _address);
	event SwapEnable(bool _type);
	event SetDevelopmentFee(uint256 _fee);
	event SetMarketingFee(uint256 _fee);
	event SetDevelopmentWallet(address _address);
	event SetMarketingWallet(address _address);
	event SetSwapingThreshold(uint256 _amount);
	event SetStakingAddress(address _address, bool _type);
	event LockToken(uint256 _amount, uint256 _releaseTime, address _user);
	event UnLockToken(address _user, uint256 _id);
	event OwnershipTransfer(address _address);
	
	event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);
}

interface IPancakeSwapV2Router01 {
   function WETH() external pure returns (address);
}

interface IPancakeSwapV2Router02 is IPancakeSwapV2Router01 {
   function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
}

contract CHEESE is IBEP20, Pausable {
   IPancakeSwapV2Router02 public immutable pancakeSwapV2Router;
   string public constant name = "CHEESE";
   string public constant symbol = "CHEESE";
   uint8 public constant decimals = 18;
   uint256 totalSupply_;
   
   uint256 public developmentFee = 40;
   uint256 public marketingFee = 400;
   uint256 public swapingThreshold = 1000000 * (10**18);
   
   address public developmentWallet = 0xe301726297c6f7A517DfdB945c05F8DbC9CA5376;
   address public marketingWallet = 0xdc1336bFDAd88B6ea989c189062BD7239c8Ed3aB; 
   address public constant BTCB = 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c; 
   
   bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");
   bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

   uint256 developmentFeeTotal;
   uint256 marketingFeeTotal;
   
   bool public swapEnable = true;	
   bool inSwapping;
   
   modifier lockTheSwap {
	 inSwapping = true;
	 _;
	 inSwapping = false;
   }
   
   mapping (address => uint256) balances;
   mapping (address => bool) public isBlackListed;
   mapping (address => mapping (address => uint256)) allowed;
   mapping (address => bool) public isWhiteListed;
   mapping (address => bool) public isExcludedFromFee;
   mapping (address => bool) public isStakingAddress;
   mapping (address => uint256) public lockedAmount;
   
   mapping (address => address) internal _delegates;
   mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;
   mapping (address => uint32) public numCheckpoints;
   mapping (address => uint) public nonces;
	
   struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
   }
   
   struct Stake {
	  uint256 stakedToken;
	  uint256 releaseTime;
	  address stakeAddress;
	  bool status;
   }
   
   struct StakeInfo {
       Stake[] stake;
   }
   
   mapping(address => StakeInfo) internal stakeInfo;
   
   constructor(){
       IPancakeSwapV2Router02 _pancakeSwapV2Router = IPancakeSwapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
       pancakeSwapV2Router = _pancakeSwapV2Router;
	   
	   owner = msg.sender;
	   isExcludedFromFee[owner] = true;
	   isExcludedFromFee[address(this)] = true;
	   __mint(owner, 1000000000000 * (10**18));
	   
   }
   
   function __mint(address _to, uint256 _amount) internal {
       totalSupply_ = totalSupply_ + _amount;
       balances[_to] = balances[_to] + _amount;
	   
	   _moveDelegates(address(0), _delegates[_to], _amount);
       emit Transfer(address(0), _to, _amount);
   }
   
   function totalSupply() public override view returns (uint256) {
       return totalSupply_;
   }
   
   function burn(uint256 _value) public {
	    require(!isBlackListed[msg.sender], 
			'sender is blacklisted'
		);
        require(_value <= balances[msg.sender], 
			'burn amount exceeds balance'
		);
        address burner = msg.sender;
        balances[burner] = balances[burner] - _value;
        totalSupply_ = totalSupply_ - _value;
		
		_moveDelegates(_delegates[burner], address(0), _value);
		
        emit Burn(burner, _value);
        emit Transfer(burner, address(0), _value);
    }
	
	function mint(address _to, uint256 _amount) onlyOwner public returns (bool) {
	    require(_to != address(0), 
			"transfer to the zero-address"
		);
		require(_amount > 0, 
			"amount is zero"
		);
        totalSupply_ = totalSupply_ + _amount;
        balances[_to] = balances[_to] + _amount;
		
		_moveDelegates(address(0), _delegates[_to], _amount);
		
        emit Transfer(address(0), _to, _amount);
        return true;
    }
   
   function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
   }
   
   function transfer(address receiver, uint256 numTokens) public override returns (bool) {
	    require(
			!isBlackListed[msg.sender],
			"Sender address is blacklisted"
		);
		require(receiver != address(0), 
			"transfer to the zero-address"
		);
        require(
			numTokens <= balances[msg.sender] - lockedAmount[msg.sender], 
			"transfer amount exceeds balance"
		);
        balances[msg.sender] = balances[msg.sender] - numTokens;
		
		if(paused) 
		{
		    require(isWhiteListed[msg.sender], "sender not whitelist to transfer");
		}
		
		uint256 contractTokenBalance = balanceOf(address(this));
		bool canSwap = contractTokenBalance >= swapingThreshold;
		
		if (canSwap && swapEnable && !inSwapping) 
		{
		    uint256 tokenToDevelopment = developmentFeeTotal;
			uint256 tokenToMarketing = marketingFeeTotal;
			
			swapTokensForBTCB(tokenToDevelopment, developmentWallet);
			swapTokensForBTCB(tokenToMarketing, marketingWallet);
			
			developmentFeeTotal = developmentFeeTotal - tokenToDevelopment;
			marketingFeeTotal = marketingFeeTotal - tokenToMarketing;
		}
		
		if(isExcludedFromFee[msg.sender] || isExcludedFromFee[receiver])
		{
			balances[receiver] = balances[receiver] + numTokens;
			_moveDelegates(_delegates[msg.sender], _delegates[receiver], numTokens);
			
			emit Transfer(msg.sender, receiver, numTokens);
        }
		else
		{
			uint256 developmentTax = (numTokens * developmentFee) / 10000;
			uint256 marketingTax = (numTokens * marketingFee) / 10000;
			
			balances[address(this)] = balances[address(this)] + developmentTax + marketingTax;
			balances[receiver] = balances[receiver] + (numTokens - developmentTax - marketingTax);
			
			developmentFeeTotal = developmentFeeTotal + developmentTax;
			marketingFeeTotal = marketingFeeTotal + marketingTax;
			
			_moveDelegates(_delegates[msg.sender], _delegates[receiver], numTokens - developmentTax - marketingTax);
			_moveDelegates(_delegates[msg.sender], _delegates[address(this)], developmentTax + marketingTax);
			
			emit Transfer(msg.sender, receiver, numTokens - developmentTax - marketingTax);
			emit Transfer(msg.sender, address(this), developmentTax + marketingTax);
		}
        return true;
    }
	
	function transferFrom(address sender, address receiver, uint256 numTokens) public override returns (bool) {
        require(
			!isBlackListed[sender],
			"Sender address is blacklisted"
		);
		require(receiver != address(0), 
			"transfer to the zero-address"
		);
		require(
			numTokens <= balances[sender] + lockedAmount[msg.sender],
			"transfer amount exceeds balance"
		);
        require(
			numTokens <= allowed[sender][msg.sender],
			"transfer amount exceeds allowed amount"
		);
		if(paused)
		{
		   require(
			  isWhiteListed[sender], 
			  "sender not whitelist to transfer"
		   );
		}
        balances[sender] = balances[sender] - numTokens;
        allowed[sender][msg.sender] = allowed[sender][msg.sender] - numTokens;
		
		uint256 contractTokenBalance = balanceOf(address(this));
		bool canSwap = contractTokenBalance >= swapingThreshold;
		
		if (canSwap && swapEnable && !inSwapping) 
		{
		    uint256 tokenToDevelopment = developmentFeeTotal;
			uint256 tokenToMarketing = marketingFeeTotal;

			if(tokenToDevelopment > 0 ){
			   swapTokensForBTCB(tokenToDevelopment, developmentWallet);
			   developmentFeeTotal = developmentFeeTotal - tokenToDevelopment;
			}
			
			if(tokenToMarketing > 0 )
			{
			   swapTokensForBTCB(tokenToMarketing, marketingWallet);
			   marketingFeeTotal = marketingFeeTotal - tokenToMarketing;
			}
		}
		
		if(isExcludedFromFee[sender] || isExcludedFromFee[receiver])
		{
			balances[receiver] = balances[receiver] + numTokens;
			
			_moveDelegates(_delegates[sender], _delegates[receiver], numTokens);
			emit Transfer(sender, receiver, numTokens);
        }
		else
		{
			uint256 developmentTax = (numTokens * developmentFee) / 10000;
			uint256 marketingTax = (numTokens * marketingFee) / 10000;
			
			balances[address(this)] = balances[address(this)] + developmentTax + marketingTax;
			balances[receiver] = balances[receiver] + (numTokens - developmentTax - marketingTax);
			
			developmentFeeTotal = developmentFeeTotal + developmentTax;
			marketingFeeTotal = marketingFeeTotal + marketingTax;
			
			_moveDelegates(_delegates[sender], _delegates[receiver], numTokens - developmentTax - marketingTax);
			_moveDelegates(_delegates[sender], _delegates[address(this)], developmentTax + marketingTax);
			
			emit Transfer(sender, receiver, numTokens - developmentTax - marketingTax);
			emit Transfer(sender, address(this), developmentTax + marketingTax);
		}
		return true;
    }

    function approve(address spender, uint256 numTokens) public override returns (bool) {
	    require(spender != address(0), 
			"spender is the zero address"
		);
        allowed[msg.sender][spender] = numTokens;
        emit Approval(msg.sender, spender, numTokens);
        return true;
    }

    function allowance(address owner, address spender) public override view returns (uint) {
        return allowed[owner][spender];
    }
	
	function getBlackListStatus(address _maker) external view returns (bool) {
        return isBlackListed[_maker];
    }
	
	function addBlackList(address _evilUser) external onlyOwner {
        isBlackListed[_evilUser] = true;
        emit AddedBlackList(_evilUser);
    }

    function removeBlackList (address _clearedUser) external onlyOwner {
        isBlackListed[_clearedUser] = false;
        emit RemovedBlackList(_clearedUser);
    }
	
	function getWhiteListStatus(address _address) external view returns (bool) {
        return isWhiteListed[_address];
	}
	
	function whiteListAddress(address _address) external onlyOwner{
	   isWhiteListed[_address] = true;
	   emit AddToWhiteList(_address);
    }
	
	function removeWhiteListAddress (address _address) external onlyOwner{
	   isWhiteListed[_address] = false;
	   emit RemovedFromWhiteList(_address);
	}
	
	function excludeFromFee(address account) external onlyOwner {
        isExcludedFromFee[account] = true;
		emit ExcludedFromFee(account);
    }
	
	function includeInFee(address account) external onlyOwner {
        isExcludedFromFee[account] = false;
		emit IncludeInFee(account);
    }
	
	function transferTokens(address tokenAddress, address to, uint256 amount) external onlyOwner {
        IBEP20(tokenAddress).transfer(to, amount);
    }
	
	function withdrawalTokens(address to, uint256 amount) external onlyOwner {
        IBEP20(address(this)).transfer(to, amount);
    }
	
	function setSwapEnable(bool _enabled) external onlyOwner {
        swapEnable = _enabled;
		emit SwapEnable(_enabled);
    }
	
	function setDevelopmentFee(uint256 newFee) external onlyOwner {
	    require(newFee <= 2000, "fee can't be more than 2000");
		developmentFee = newFee;
		emit SetDevelopmentFee(newFee);
	}
	
	function setMarketingFee(uint256 newFee) external onlyOwner {
	    require(newFee <= 2000, "fee can't be more than 2000");
		marketingFee = newFee;
		emit SetMarketingFee(newFee);
	}
	
	function setDevelopmentWallet(address payable newWallet) external onlyOwner{
        require(newWallet != address(0), "zero-address not allowed");
	    developmentWallet = newWallet;
		emit SetDevelopmentWallet(newWallet);
    }
	
	function setMarketingWallet(address payable newWallet) external onlyOwner {
        require(newWallet != address(0), "zero-address not allowed");
	    marketingWallet = newWallet;
		emit SetMarketingWallet(newWallet);
    }
	
	function setSwapingThreshold(uint256 amount) external onlyOwner {
  	     require(amount <= totalSupply_, "Amount cannot be over the total supply.");
		 swapingThreshold = amount;
		 emit SetSwapingThreshold(amount);
  	}
	
	function swapTokensForBTCB(uint256 tokenAmount, address receiver) private lockTheSwap{
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = pancakeSwapV2Router.WETH();
		path[2] = BTCB;
		
        approve(address(pancakeSwapV2Router), tokenAmount);
        pancakeSwapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            receiver,
            block.timestamp
        );
    }
	
	function getUserStake(address userAddress) external view returns (uint256) {
	    StakeInfo storage staking = stakeInfo[userAddress];
		return staking.stake.length;
    }
	
	function getStakingStats(address userAddress, uint256 id) external view returns (uint256, uint256, address, bool) {
	   StakeInfo storage staking = stakeInfo[userAddress];
       require(id < staking.stake.length, "No staking found");
	   require(staking.stake[id].stakedToken > 0, "No staking amount found");
	   
	   return (staking.stake[id].stakedToken, staking.stake[id].releaseTime, staking.stake[id].stakeAddress, staking.stake[id].status);
    }
	
	function setStakingAddress(address stakingAddress, bool _value) external onlyOwner {
       require(isStakingAddress[stakingAddress] != _value, "Account is already the value of '_value'");
       isStakingAddress[stakingAddress] = _value;
	   emit SetStakingAddress(stakingAddress, _value);
    }
	
	function lockToken(uint256 amount, uint256 releaseTime, address user) public {
	   require(isStakingAddress[msg.sender], "sender not allowed");
	   require(releaseTime > 0, "releaseTime is not correct");
	   uint256 unlockBalance = balances[user] - lockedAmount[user];
	   require(unlockBalance >= amount, "lock amount exceeds balance");
	   
	   StakeInfo storage staking = stakeInfo[user];
	   
	   staking.stake.push(Stake(amount, releaseTime, user, true));
	   lockedAmount[user] = lockedAmount[user] + amount;
	   
	   emit LockToken(amount, releaseTime, user);
    }
	
	function unlockToken(address user, uint256 id) public {
       StakeInfo storage staking = stakeInfo[user]; 
	   require(id < staking.stake.length, "No staking found");
	   require(isStakingAddress[msg.sender], "sender not allowed");
	  
	   require(staking.stake[id].status, "already unstake amount");
	   require(staking.stake[id].stakedToken > 0, "No staking amount found");
	   
	   staking.stake[id].status = false;
	   staking.stake[id].releaseTime = block.timestamp;
	   lockedAmount[user] = lockedAmount[user] - staking.stake[id].stakedToken;
	   
	   emit UnLockToken(user, id);
    }
	
	function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner can't be zero-address");
        owner = newOwner;
		emit OwnershipTransfer(newOwner);
    }
	
	function delegates(address delegator) external view returns (address){
        return _delegates[delegator];
    }

    function delegate(address delegatee) external {
        return _delegate(msg.sender, delegatee);
    }
	
    function delegateBySig(address delegatee, uint nonce, uint expiry, uint8 v, bytes32 r, bytes32 s) external {
        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), getChainId(), address(this)));

        bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry));

        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));

        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "delegateBySig: invalid nonce");
        require(block.timestamp <= expiry, "delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }
	
    function getCurrentVotes(address account) external view returns (uint256) {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }
	
    function getPriorVotes(address account, uint blockNumber) external view returns (uint256){
        require(blockNumber < block.number, "getPriorVotes: not yet determined");
		
        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }
		
        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }
		
        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }
		
        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2;
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }
	
    function _delegate(address delegator, address delegatee) internal{
        address currentDelegate = _delegates[delegator];
        uint256 delegatorBalance = balanceOf(delegator); // balance of underlying FSTABLEs (not scaled);
        _delegates[delegator] = delegatee;
		
        emit DelegateChanged(delegator, currentDelegate, delegatee);
        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(address srcRep, address dstRep, uint256 amount) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
               
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint256 srcRepNew = srcRepOld - amount;
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = dstRepOld + amount;
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(address delegatee, uint32 nCheckpoints, uint256 oldVotes, uint256 newVotes) internal{
        uint32 blockNumber = safe32(block.number, "_writeCheckpoint: block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }
        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }
	
    function getChainId() internal view returns (uint) {
        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }
}
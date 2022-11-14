/**
 *Submitted for verification at BscScan.com on 2022-11-14
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.15;

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
	
	event AddToWhiteList(address _address);
    event RemovedFromWhiteList(address _address);
	event OwnershipTransfer(address _address);
}

interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function depositBUSD(uint256 amount) external;
    function process(uint256 gas) external;
}

contract DividendDistributor is IDividendDistributor {
    address _token;
	address _depostor;
	
    struct Share {
	  uint256 amount;
	  uint256 totalExcluded;
	  uint256 totalRealised;
    }
	
    IBEP20 BUSD = IBEP20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
	
    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;
    mapping (address => Share) public shares;
	
	event DistributionCriteriaUpdate(uint256 minPeriod, uint256 minDistribution);
	event NewFundDeposit(uint256 amount);

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public constant dividendsPerShareAccuracyFactor = 10 ** 36;
	
    uint256 public minPeriod = 7 days;
    uint256 public minDistribution = 1 * 10 ** 5;
	
    uint256 currentIndex;
	
    modifier onlyToken() {
        require(msg.sender == _token, "!Token"); _;
    }
	
	modifier onlyDepostor() {
        require(msg.sender == _depostor, "!Depostor"); _;
    }
	
    constructor () {
        _token = msg.sender;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
		emit DistributionCriteriaUpdate(minPeriod, minDistribution);
    }
	
	function setDepostor(address _newDepostor) external onlyToken {
        _depostor = _newDepostor;
    }
	
    function setShare(address shareholder, uint256 amount) external override onlyToken {
        if(amount > 0 && shares[shareholder].amount == 0)
		{
            addShareholder(shareholder);
        }
		else if(amount == 0 && shares[shareholder].amount > 0)
		{
            removeShareholder(shareholder);
        }
		
        totalShares = totalShares- shares[shareholder].amount + amount;
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function depositBUSD(uint256 amount) external override onlyDepostor {
        totalDividends = totalDividends + amount;
        dividendsPerShare = dividendsPerShare + dividendsPerShareAccuracyFactor * amount / totalShares;
		emit NewFundDeposit(amount);
    }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0) { return; }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

            if(shouldDistribute(shareholders[currentIndex])){
                distributeDividend(shareholders[currentIndex]);
            }
			
            gasUsed = gasUsed + gasLeft- gasleft();
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp && getUnpaidEarnings(shareholder) > minDistribution;
    }
	
    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }
		
        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed + amount;
            BUSD.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised + amount;
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }
	
    function claim(address shareholder) external onlyToken{
	    if(shouldDistribute(shareholder)) 
		{
		   distributeDividend(shareholder);
		}
    }
	
    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }
		
        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends - shareholderTotalExcluded;
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share * dividendsPerShare / dividendsPerShareAccuracyFactor;
    }
	
    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }
	
    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
}

contract xCrowd is IBEP20, Pausable {
   string public constant name = "xCrowd";
   string public constant symbol = "xCrowd";
   uint256 public constant decimals = 6;
   uint256 public totalSupply;
   
   bool public distributionEnabled = false;
   uint256 distributorGas = 250000;
   
   DividendDistributor distributor;
   address public distributorAddress;
   
   uint256 public minTxAmount = 1 * 10**5;
   uint256 public maxWalletAmount = 100 * 10**6;

   bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");
   bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

   mapping (address => uint256) balances;
   mapping (address => mapping (address => uint256)) allowed;
   mapping (address => bool) public isWhiteListed;
   mapping (address => bool) public isExcludedFromMaxWallet;
   mapping (address => bool) public isExcludedFromReward;
   mapping (address => address) internal _delegates;
   mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;
   mapping (address => uint32) public numCheckpoints;
   mapping (address => uint) public nonces;

   event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);
   event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);
   
   struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
   }
   
   constructor(){
	   owner = msg.sender;
	   totalSupply = 1000 * (10**6);
	   balances[owner] = totalSupply;
	   
	   distributor = new DividendDistributor();
	   distributorAddress = address(distributor);
	   
       emit Transfer(address(0), owner, totalSupply);
   }
   
   function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
   }
   
   function transfer(address receiver, uint256 numTokens) public override returns (bool) {
		require(
		    receiver != address(0), 
			"Transfer to the zero-address"
		);
        require(
			numTokens <= balances[msg.sender], 
			"Transfer amount exceeds balance"
		);
		require(
			numTokens >= minTxAmount, 
			"Transfer amount less than minTxAmount."
		);
		if(paused)
		{
		   require(
			  isWhiteListed[msg.sender], 
			  "Sender not whitelist to transfer"
		   );
		}
        if (!isExcludedFromMaxWallet[receiver]) 
		{
			require(
				balances[receiver] + numTokens <= maxWalletAmount, 
				"You are transferring too many tokens, please try to transfer a smaller amount"
			);
		}
		
		balances[msg.sender] = balances[msg.sender] - numTokens;
		balances[receiver] = balances[receiver] + numTokens;
		
		_moveDelegates(_delegates[msg.sender], _delegates[receiver], numTokens);
		
		try distributor.setShare(msg.sender, !isExcludedFromReward[msg.sender] ? balances[msg.sender] : 0) {} catch {} 
        try distributor.setShare(receiver, !isExcludedFromReward[receiver] ? balances[receiver] : 0) {} catch {}
		
		if(distributionEnabled) {
		   try distributor.process(distributorGas) {} catch {}
		}
		
		emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }
	
	function transferFrom(address sender, address receiver, uint256 numTokens) public override returns (bool) {
		require(
		    receiver != address(0), 
			"Transfer to the zero-address"
		);
		require(
			numTokens <= balances[sender],
			"Transfer amount exceeds balance"
		);
        require(
			numTokens <= allowed[sender][msg.sender],
			"Transfer amount exceeds allowed amount"
		);
		require(
			numTokens >= minTxAmount, 
			"Transfer amount less than minTxAmount."
		);
		if(paused)
		{
		   require(
			  isWhiteListed[sender], 
			  "Sender not whitelist to transfer"
		   );
		}
		if (!isExcludedFromMaxWallet[receiver]) 
		{
			require(
			   balances[receiver] + numTokens <= maxWalletAmount, 
			   "You are transferring too many tokens, please try to transfer a smaller amount"
			);
		}
		
		balances[sender] = balances[sender] - numTokens;
        allowed[sender][msg.sender] = allowed[sender][msg.sender] - numTokens;
		balances[receiver] = balances[receiver] + numTokens;
		
		_moveDelegates(_delegates[sender], _delegates[receiver], numTokens);
		
		try distributor.setShare(sender, balances[sender]) {} catch {} 
        try distributor.setShare(receiver, balances[receiver]) {} catch {}
		
		if(distributionEnabled) {
		   try distributor.process(distributorGas) {} catch {}
		}
		
		emit Transfer(sender, receiver, numTokens);
		return true;
    }
	
	function burn(uint256 amount) public whenNotPaused{
        require(
			amount <= balances[msg.sender], "Insufficient balance to burn"
		);
		
		address burner = msg.sender;
        balances[burner] = balances[burner] - amount;
        totalSupply = totalSupply - amount;
		
        emit Transfer(burner, address(0), amount);
    }

    function approve(address spender, uint256 numTokens) public override returns (bool) {
	    require(
		    spender != address(0), 
			"spender is the zero address"
		);
        allowed[msg.sender][spender] = numTokens;
        emit Approval(msg.sender, spender, numTokens);
        return true;
    }

    function allowance(address owner, address spender) public override view returns (uint) {
        return allowed[owner][spender];
    }
	
	function whiteListAddress(address _address) external onlyOwner{
	   isWhiteListed[_address] = true;
	   emit AddToWhiteList(_address);
    }
	
	function removeWhiteListAddress (address _address) external onlyOwner{
	   isWhiteListed[_address] = false;
	   emit RemovedFromWhiteList(_address);
	}
	
	function transferTokens(address tokenAddress, address to, uint256 amount) external onlyOwner {
        IBEP20(tokenAddress).transfer(to, amount);
    }
	
	function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner can't be zero-address");
        owner = newOwner;
		emit OwnershipTransfer(newOwner);
    }
	
	function setDistributionEnabled(bool _enabled) external onlyOwner {
        distributionEnabled = _enabled;
    }
	
	function setDistributorSettings(uint256 gas) external onlyOwner {
        require(gas < 750000, "Gas is greater than limit");
        distributorGas = gas;
    }
	
	function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external onlyOwner {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }
	
	function setDepostor(address _depostor) external onlyOwner {
        distributor.setDepostor(_depostor);
    }
	
	function claim() external{
	   if(distributionEnabled) {
		  distributor.claim(msg.sender);
	   }
    }
	
	function excludeFromMaxWallet(address account, bool value) public onlyOwner {
		isExcludedFromMaxWallet[account] = value;
	}
	
	function excludedFromReward(address account, bool value) public onlyOwner {
		isExcludedFromReward[account] = value;
	}
	
	function setMaxWalletAmount(uint256 amount) public onlyOwner {
	    require(amount <= totalSupply, "Amount cannot be over the total supply.");
		maxWalletAmount = amount;
	}
	
	function setMinTxnAmount(uint256 amount) external onlyOwner() {
	    require(amount <= totalSupply, "Amount cannot be over the total supply.");
        minTxAmount = amount;
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
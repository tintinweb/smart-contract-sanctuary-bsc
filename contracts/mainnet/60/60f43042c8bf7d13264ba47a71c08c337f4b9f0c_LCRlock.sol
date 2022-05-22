/**
 *Submitted for verification at BscScan.com on 2022-05-22
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: contracts/lockLCR.sol


// Created by lucrar (developer team)

pragma solidity ^0.8.10;



contract LCRlock {

    // metadata
    string public version = "1.0";
    
		
	uint256 public totalLockedTokens;	// so por curiosidade
	uint256 public totalBalance;	// so por curiosidade
	
	uint256 private startTimestamp;
	uint256 private firstReleaseTimestamp;
	uint256 private releaseInterval;

    address private lcrTokenId;
    IERC20 private lcrContract;
	
		
	struct TokenLockInfo {
        address tokenId;
		uint256 totalLockedAmount;
        uint256 balance;
		uint256 withdrawn;
        uint256 lockTimestamp;	// initialLock	
		uint256 withdrawPerPeriod;
		string comment;
    }

    // map wallet address to tokenLock details
    mapping(address => TokenLockInfo) public tokenLock;
		
	
  
	address public owner;
	
   
    // events
	event ERC20Received(address from, uint256 amount, address contractAddress);
	
    event LockLCR(address indexed _wallet, uint256 _value);
    event UnLockLCR(address indexed _wallet, uint256 _value);
	
    // constructor
    constructor()
    {
		owner = msg.sender;	
		
        lcrTokenId = 0x1510211E6DC81F5724A1BecA33C5AC70Dcca6CE0;
		lcrContract = IERC20(lcrTokenId); 
		
		

		
		startTimestamp = block.timestamp; // now

        releaseInterval = 30 * (24 * 60 * 60); // 30 days
		firstReleaseTimestamp = startTimestamp + (6 * releaseInterval); // 6 months		
			

	
		totalLockedTokens = 0;	
		totalBalance = 0;		
	  	
    }  
	
	function lock(address _tokenId, uint256 _amount, string calldata _comment ) public {
	 
		if (tokenLock[msg.sender].totalLockedAmount == 0) {
			
			uint256 withdrawPerPeriod = _amount/20; // 5% 
			
			require (lcrTokenId == _tokenId, "not valid token");
			tokenLock[msg.sender] = TokenLockInfo(_tokenId, _amount, _amount, 0, block.timestamp, withdrawPerPeriod, _comment); 			
		}
		else
		{
			require (tokenLock[msg.sender].tokenId == _tokenId, "not valid token");
			tokenLock[msg.sender].totalLockedAmount += _amount;
			tokenLock[msg.sender].balance += _amount;		
			
		}
			
		totalLockedTokens += _amount;
		totalBalance += _amount;
		
		// approve needed
        //lcrContract.approve(msg.sender, _amount);


        lcrContract.transferFrom(msg.sender, address(this), _amount);  
		//, _tokenId , "0x00"
		
		emit LockLCR(msg.sender, _amount);
    } 
    	

		
	function unLock(address _tokenId) public
	{		
	
		require (tokenLock[msg.sender].tokenId == _tokenId, "not valid token");		
		require (tokenLock[msg.sender].totalLockedAmount > 0, "never locked");		
		require (tokenLock[msg.sender].balance > 0, "no locked balance");	
		
		require (block.timestamp > firstReleaseTimestamp, "can not unlock yet");	
		
		uint256 delta =  block.timestamp - firstReleaseTimestamp;
		
		uint256 allowIndex = (delta / releaseInterval) + 1;
						
			
		if (allowIndex >= 20) {
			// can Withdraw all
             lcrContract.approve(address(this), tokenLock[msg.sender].balance);

			 lcrContract.transferFrom(address(this), msg.sender, tokenLock[msg.sender].balance);  
			 
			 tokenLock[msg.sender].withdrawn += tokenLock[msg.sender].balance;			 
			 tokenLock[msg.sender].balance = 0;
			 
			 totalBalance -= tokenLock[msg.sender].balance;
			 emit UnLockLCR(msg.sender, tokenLock[msg.sender].balance);
		}
		else
		{
			uint256 canWithdraw = allowIndex * tokenLock[msg.sender].withdrawPerPeriod;
			canWithdraw -= tokenLock[msg.sender].withdrawn;
			
            lcrContract.approve(address(this), canWithdraw);

			lcrContract.transferFrom(address(this), msg.sender, canWithdraw);  
			
			tokenLock[msg.sender].withdrawn += canWithdraw;			 
			tokenLock[msg.sender].balance -= canWithdraw;
			
			totalBalance -= canWithdraw;
			emit UnLockLCR(msg.sender, canWithdraw);	
		}
		
		
	}   
	
	modifier onlyOwner() {
		require (msg.sender == owner, "not allowed");
		_;
	}
	
		
	
	function releaseFounds(address _tokenId) public onlyOwner
	{
		// avoid stuck tokens in the contract

        if (block.timestamp - firstReleaseTimestamp - (releaseInterval * 20) > 0) {
            // to avoid stuck LCR sended by mistake

            IERC20 anyTokenContract = IERC20(_tokenId); 			
            uint256 balance = anyTokenContract.balanceOf(address(this)); 
            
            require (balance > 0, "balance is zero");
                
            anyTokenContract.transfer(msg.sender, balance);

        }
        else {
            
            require (lcrTokenId != _tokenId, "only other Tokens!");	
            
            IERC20 anyTokenContract = IERC20(_tokenId); 			
            uint256 balance = anyTokenContract.balanceOf(address(this)); 
            
            require (balance > 0, "balance is zero");
                
            anyTokenContract.transfer(msg.sender, balance);
        }
	}
	
	function releaseBNB() public onlyOwner
	{
		// avoid stuck BNB in the contract
							
		uint256 balance = address(this).balance;		
		require (balance > 0, "balance is zero");		
		payable(msg.sender).transfer(address(this).balance);		
	}
	

	
	// get info about Lock befere UnLock
	
    function getLockInfo(address account) public view returns (uint256 lockedBalance, uint256 lockedTime)
	{		
	    if (tokenLock[account].totalLockedAmount == 0) return (0, 0); // more informative 
	
		lockedTime = block.timestamp - tokenLock[account].lockTimestamp;		
		lockedBalance = tokenLock[account].balance;
		
				
		return (lockedBalance, lockedTime);
	}

}
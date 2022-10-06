/**
 *Submitted for verification at BscScan.com on 2022-10-05
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

contract xCrowd is IBEP20, Pausable {
   string public constant name = "xCrowd";
   string public constant symbol = "xCrowd";
   uint256 public constant decimals = 6;
   uint256 public totalSupply;
   
   mapping (address => uint256) balances;
   mapping (address => mapping (address => uint256)) allowed;
   mapping (address => bool) public isWhiteListed;
   
   constructor(){
	   owner = msg.sender;
	   totalSupply = 1000 * (10**6);
	   balances[owner] = totalSupply;
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
		if(paused)
		{
		   require(
			  isWhiteListed[msg.sender], 
			  "Sender not whitelist to transfer"
		   );
		}
		balances[msg.sender] = balances[msg.sender] - numTokens;
		balances[receiver] = balances[receiver] + numTokens;
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
		if(paused)
		{
		   require(
			  isWhiteListed[sender], 
			  "Sender not whitelist to transfer"
		   );
		}
		
		balances[sender] = balances[sender] - numTokens;
        allowed[sender][msg.sender] = allowed[sender][msg.sender] - numTokens;
		balances[receiver] = balances[receiver] + numTokens;
		
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
}
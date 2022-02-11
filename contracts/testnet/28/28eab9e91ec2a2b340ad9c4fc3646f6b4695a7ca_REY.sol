/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.6;

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
	
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }
	
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }
}

contract Ownable {

    address public owner;
	
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
	
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;
    }
    
}

contract Pausable is Ownable {
	event Pause();
	event Unpause();

	bool public paused = false;
  
	modifier whenNotPaused() {
		require(!paused);
		_;
	}
  
	modifier whenPaused() {
		require(paused);
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
	
	event DestroyedBlackFunds(address _blackListedUser, uint _balance);
    event AddToWhiteList(address _address);
    event RemovedFromWhiteList(address _address);
	
	event AddedBlackList(address _address);
    event RemovedBlackList(address _address);
}

contract BEP20Basic is IBEP20, Pausable {
	using SafeMath for uint256;
	
    uint256 public foundationFee = 10;
    uint256 public giveawayFee = 10;
	uint256 public txnFee = 10;
	
	address public foundationWallet = 0xf5b4c7a8e45975015879E16C9795Fde841258BDc;
	address public giveawayWallet = 0xDDB980e6CBd61D3F51bE293ffe210c9CD209824B;
	address public txnWallet = address(this); 

	mapping(address => uint256) balances;
	mapping (address => bool) public isBlackListed;
    mapping(address => mapping (address => uint256)) allowed;
	mapping (address => bool) public isWhiteListed;
	mapping (address => bool) public isExcludedFromFee;
    uint256 totalSupply_;
	
    function totalSupply() public override view returns (uint256) {
       return totalSupply_;
    }

    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }
	
    function transfer(address receiver, uint256 numTokens) public override returns (bool) {
	    require(!isBlackListed[msg.sender]);
        require(numTokens <= balances[msg.sender], "transfer amount exceeds balance");
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
		if(paused) {
		    require(isWhiteListed[msg.sender], "sender not whitelist to transfer");
		}
		
		if(isExcludedFromFee[msg.sender] || isExcludedFromFee[receiver])
		{
			balances[receiver] = balances[receiver].add(numTokens);
			emit Transfer(msg.sender, receiver, numTokens);
        }
		else
		{
		    uint256 foundationFeeTrx = numTokens.mul(foundationFee).div(10000);
			uint256 giveawayFeeTrx = numTokens.mul(giveawayFee).div(10000);
			uint256 txnFeeTrx = numTokens.mul(txnFee).div(10000);
			
			balances[foundationWallet] = balances[foundationWallet].add(foundationFeeTrx);
			balances[giveawayWallet] = balances[giveawayWallet].add(giveawayFeeTrx);
			balances[txnWallet] = balances[txnWallet].add(txnFeeTrx);
			
			balances[receiver] = balances[receiver].add(numTokens.sub(foundationFeeTrx).sub(giveawayFeeTrx).sub(txnFeeTrx));
			emit Transfer(msg.sender, receiver, numTokens.sub(foundationFeeTrx).sub(giveawayFeeTrx).sub(txnFeeTrx));
		}
        return true;
    }

    function approve(address delegate, uint256 numTokens) public override returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public override view returns (uint) {
        return allowed[owner][delegate];
    }
	
    function transferFrom(address sender, address receiver, uint256 numTokens) public override returns (bool) {
        require(!isBlackListed[sender]);
		require(numTokens <= balances[sender], "transfer amount exceeds balance");
        require(numTokens <= allowed[sender][msg.sender]);
		if(paused){
		   require(isWhiteListed[sender], "sender not whitelist to transfer");
		}
        balances[sender] = balances[sender].sub(numTokens);
        allowed[sender][msg.sender] = allowed[sender][msg.sender].sub(numTokens);
		
		if(isExcludedFromFee[sender] || isExcludedFromFee[receiver])
		{
			balances[receiver] = balances[receiver].add(numTokens);
			emit Transfer(sender, receiver, numTokens);
        }
		else
		{
		    uint256 foundationFeeTrx = numTokens.mul(foundationFee).div(10000);
			uint256 giveawayFeeTrx = numTokens.mul(giveawayFee).div(10000);
			uint256 txnFeeTrx = numTokens.mul(txnFee).div(10000);
			
			balances[foundationWallet] = balances[foundationWallet].add(foundationFeeTrx);
			balances[giveawayWallet] = balances[giveawayWallet].add(giveawayFeeTrx);
			balances[txnWallet] = balances[txnWallet].add(txnFeeTrx);
			balances[receiver] = balances[receiver].add(numTokens.sub(foundationFeeTrx).sub(giveawayFeeTrx).sub(txnFeeTrx));
			emit Transfer(sender, receiver, numTokens.sub(foundationFeeTrx).sub(giveawayFeeTrx).sub(txnFeeTrx));
		}
		
		return true;
    }
	
	function burn(uint256 _value) public whenNotPaused{
	    require(!isBlackListed[msg.sender]);
        require(_value <= balances[msg.sender]);
        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit Burn(burner, _value);
        emit Transfer(burner, address(0), _value);
    }
	
	function mint(address _to, uint256 _amount) onlyOwner public returns (bool) {
        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }
	
	function getBlackListStatus(address _maker) public view returns (bool) {
        return isBlackListed[_maker];
    }
	
	function addBlackList (address _evilUser) public onlyOwner {
        isBlackListed[_evilUser] = true;
        emit AddedBlackList(_evilUser);
    }

    function removeBlackList (address _clearedUser) public onlyOwner {
        isBlackListed[_clearedUser] = false;
        emit RemovedBlackList(_clearedUser);
    }
	
	function getWhiteListStatus(address _address) public view returns (bool) {
        return isWhiteListed[_address];
	}
	
	function whiteListAddress(address _address) public onlyOwner{
	   isWhiteListed[_address] = true;
	   emit AddToWhiteList(_address);
    }
	
	function removeWhiteListAddress (address _address) public onlyOwner{
	   isWhiteListed[_address] = false;
	   emit RemovedFromWhiteList(_address);
	}
	
	function setFoundationFee(uint256 newFee) external onlyOwner {
		foundationFee = newFee;
	}
	
	function setGiveawayFee(uint256 newFee) external onlyOwner {
		giveawayFee = newFee;
	}
	
	function setTxnFee(uint256 newFee) external onlyOwner {
		txnFee = newFee;
	}
	
	function setFoundationWallet(address payable newWallet) external onlyOwner() {
       require(newWallet != address(0), "zero-address not allowed");
	   foundationWallet = newWallet;
    }	
	
	function setGiveawayWallet(address payable newWallet) external onlyOwner() {
       require(newWallet != address(0), "zero-address not allowed");
	   giveawayWallet = newWallet;
    }
	
	function excludeFromFee(address account) public onlyOwner {
        isExcludedFromFee[account] = true;
    }
	
	function includeInFee(address account) public onlyOwner {
        isExcludedFromFee[account] = false;
    }
	
	function transferTokens(address tokenAddress, address to, uint256 amount) public onlyOwner {
        IBEP20(tokenAddress).transfer(to, amount);
    }
}

contract REY is BEP20Basic {
    string public constant name = "Rey Finance";
    string public constant symbol = "REY";
    uint8 public constant decimals = 18;
    uint256 public constant INITIAL_SUPPLY = 90000000 * 10**18;
	
	constructor(address _owner){
	   owner = _owner;
       totalSupply_ = INITIAL_SUPPLY;
	   isExcludedFromFee[owner] = true;
       balances[0x332E977663d16E9f2412a2aFe6Ae930DdC4df56D] = 10800000 * 10**18;
	   balances[0x2c11e4c283fb9af36425B59C36EdD6629Fc0B502] = 3600000 * 10**18;
	   balances[0x49D372F8484F830660B2b1723225bfDd8EB8E6E5] = 8100000 * 10**18;
	   balances[0xf5b4c7a8e45975015879E16C9795Fde841258BDc] = 35100000 * 10**18;
	   balances[_owner] = 32400000 * 10**18;
   }
}
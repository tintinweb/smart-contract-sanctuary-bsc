/**
 *Submitted for verification at BscScan.com on 2022-02-28
*/

// Version of Solidity compiler this program was written for
pragma solidity ^0.5.11;

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
    //address busd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // live busd
    address busd = 0xc8AE7ded8b33ea0Da0d7c7FC6FEd35e3C1822be0; // testnet busd
     address ham = 0xE18931d175D35220F95Bf9c7154A87D726A26Dba; // testnet busd
      address piggies = 0xB93e4681d13095B0bC2E264F2CB22143d9fd0D53; // testnet busd
    IERC20 token;
    IERC20 tokenham;
    IERC20 tokenpiggies;
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
        require(sender != address(0), "ERC20: transfer from the zero address");
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
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

}

contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 amount, address token, bytes calldata extraData) external;
}

// Heads or tails game contract
contract HeadsOrTails is ERC20{
  address payable owner;
  uint256 public minimumbet = 1;
  uint256 public maxbet = 10;
  uint256 public houseedge = 10;

  struct Game {
    address addr;
    uint amountBet;
    uint8 guess;
    uint8 coin;
    bool winner;
    uint time;
  }

  Game[] lastPlayedGames;

  //Log game result (heads 0 or tails 1) in order to display it on frontend
  event GameResult(uint8 side);

  // Contract constructor run only on contract creation. Set owner.
  constructor() public {
    token = IERC20(busd);
    tokenham = IERC20(ham);
    tokenpiggies = IERC20(piggies);

    owner = msg.sender;
  }

  //add this modifier to functions, which should only be accessible by the owner
  modifier onlyOwner {
    require(msg.sender == owner, "This function can only be launched by the owner");
    _;
  }

  //Play the game!
  function lottery(uint256 amount, uint8 guess) public returns(bool){
    require(guess == 0 || guess == 1, "Variable 'guess' should be either 0 ('heads') or 1 ('tails')");
    require(amount >= minimumbet, "Minimumbet to low");
    require(amount <= (token.balanceOf(address(this))/100*maxbet), "You cannot bet more than what is available in the jackpot");
    require(amount <= (token.balanceOf(msg.sender) - amount), "You balance is too low.");
    
    //address(this).balance is increased by msg.value even before code is executed. Thus "address(this).balance-msg.value"
    //Create a random number. Use the mining difficulty & the player's address, hash it, convert this hex to int, divide by modulo 2 which results in either 0 or 1 and return as uint8
    uint8 result = uint8(uint256(keccak256(abi.encodePacked(block.difficulty, msg.sender, block.timestamp)))%2);
    bool won = false;
    if (guess == result) {
      won = true;
      uint256 win = (amount* 2/100*(100-houseedge));
       token.transfer(msg.sender, win-amount);
    }else{
        token.transferFrom(msg.sender, address(this), amount);  
    }

    emit GameResult(result);
    lastPlayedGames.push(Game(msg.sender, amount, guess,1, won, block.timestamp));
    return won; //Return value can only be used by other functions, but not within web3.js (as of 2019)
  }

   //Play the game!
  function lotteryham(uint256 amount, uint8 guess) public returns(bool){
    require(guess == 0 || guess == 1, "Variable 'guess' should be either 0 ('heads') or 1 ('tails')");
    require(amount >= minimumbet, "Minimumbet to low");
    require(amount <= (tokenham.balanceOf(address(this))/100*maxbet), "You cannot bet more than what is available in the jackpot");
    require(amount <= (tokenham.balanceOf(msg.sender) - amount), "You balance is too low.");
    
    //address(this).balance is increased by msg.value even before code is executed. Thus "address(this).balance-msg.value"
    //Create a random number. Use the mining difficulty & the player's address, hash it, convert this hex to int, divide by modulo 2 which results in either 0 or 1 and return as uint8
    uint8 result = uint8(uint256(keccak256(abi.encodePacked(block.difficulty, msg.sender, block.timestamp)))%2);
    bool won = false;
    if (guess == result) {
      won = true;
      uint256 win = (amount* 2/100*(100-houseedge));
       tokenham.transfer(msg.sender, win-amount);
    }else{
        tokenham.transferFrom(msg.sender, address(this), amount);  
    }

    emit GameResult(result);
    lastPlayedGames.push(Game(msg.sender, amount, guess,2, won, block.timestamp));
    return won; //Return value can only be used by other functions, but not within web3.js (as of 2019)
  }

    //Play the game!
  function lotterypiggies(uint256 amount, uint8 guess) public returns(bool){
    require(guess == 0 || guess == 1, "Variable 'guess' should be either 0 ('heads') or 1 ('tails')");
    require(amount >= minimumbet*1e9, "Minimumbet to low");
    require(amount <= (tokenpiggies.balanceOf(address(this))/100*maxbet), "You cannot bet more than what is available in the jackpot");
    require(amount <= (tokenpiggies.balanceOf(msg.sender) - amount), "You balance is too low.");
    
    //address(this).balance is increased by msg.value even before code is executed. Thus "address(this).balance-msg.value"
    //Create a random number. Use the mining difficulty & the player's address, hash it, convert this hex to int, divide by modulo 2 which results in either 0 or 1 and return as uint8
    uint8 result = uint8(uint256(keccak256(abi.encodePacked(block.difficulty, msg.sender, block.timestamp)))%2);
    bool won = false;
    if (guess == result) {
      won = true;
      uint256 win = (amount* 2/100*(100-houseedge));
       tokenpiggies.transfer(msg.sender, win-amount);
    }else{
        tokenpiggies.transferFrom(msg.sender, address(this), amount);  
    }

    emit GameResult(result);
    lastPlayedGames.push(Game(msg.sender, amount, guess,3, won, block.timestamp));
    return won; //Return value can only be used by other functions, but not within web3.js (as of 2019)
  }

  //Get amount of games played so far
  function getGameCount() public view returns(uint) {
    return lastPlayedGames.length;
  }

  //Get stats about a certain played game, e.g. address of player, amount bet, won or lost, and ETH in the jackpot at this point in time
  function getGameEntry(uint index) public view returns(address addr, uint amountBet, uint8 guess, uint8 coin, bool winner, uint ethInJackpot) {
    return (
      lastPlayedGames[index].addr,
      lastPlayedGames[index].amountBet,
      lastPlayedGames[index].guess,
      lastPlayedGames[index].coin,
      lastPlayedGames[index].winner,
      lastPlayedGames[index].time
    );
  }

  // Contract destructor (Creator of contract can also destroy it and receives remaining ether of contract address).
  //Advantage compared to "withdraw": SELFDESTRUCT opcode uses negative gas because the operation frees up space on
  //the blockchain by clearing all of the contract's data
  function destroy() external onlyOwner {
    selfdestruct(owner);
  }

  //Withdraw money from contract
  function withdraw(uint amount) external onlyOwner {
    require(amount < address(this).balance, "You cannot withdraw more than what is available in the contract");
    owner.transfer(amount);
  }

    function withdrawtpg(uint256 amount) external onlyOwner {
        require(amount <= token.balanceOf(address(this)), "You cannot withdraw more than what is available in the contract");
        token.transfer(msg.sender,amount);  
  }
  function withdrawham(uint256 amount) external onlyOwner {
       require(amount <= tokenham.balanceOf(address(this)), "You cannot withdraw more than what is available in the contract");
     tokenham.transfer(msg.sender,amount); 
  }
  function withdrawpiggies(uint256 amount) external onlyOwner {
       require(amount <= tokenpiggies.balanceOf(address(this)), "You cannot withdraw more than what is available in the contract");
     tokenpiggies.transfer(msg.sender,amount);
  }

    function SET_MIN(uint256 value) external {
       require(msg.sender == owner, "Admin use only");
        minimumbet = value;
    } 

    function SET_MAX(uint256 value) external {
       require(msg.sender == owner, "Admin use only");
        maxbet = value;
    } 

    function SET_HOUSE(uint256 value) external {
       require(msg.sender == owner, "Admin use only");
        houseedge = value;
    } 

    function getContractTPGBalance() public view returns (uint) {
	    // return address(this).balance;
	    return token.balanceOf(address(this));
	} 
     function getContractHAMBalance() public view returns (uint) {
	    // return address(this).balance;
	    return tokenham.balanceOf(address(this));
	} 
     function getContractPIGGIESBalance() public view returns (uint) {
	    // return address(this).balance;
	    return tokenpiggies.balanceOf(address(this));
	}  

  // Accept any incoming amount
  function () external payable {}
}
/**
 *Submitted for verification at BscScan.com on 2022-02-16
*/

// SPDX-License-Identifier: MIT


// TRDC Game

pragma solidity ^0.8.10;

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
interface iBEP20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from,address to,uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface iBEP20Metadata is iBEP20 {
   
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract BEP20 is iBEP20, iBEP20Metadata {
    mapping(address => mapping(address => uint256)) private _allowances;
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    mapping(address => uint256) private _balances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 0;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");


        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address"); 
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

    }
    
    
    
}

contract TRDCvalut is BEP20 {
    using SafeMath for uint256;
    address private _owner;

    event BuyCard(address _cardOwner, uint256 _cardPower);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event WithdrawalBNB(uint256 _amount, address to);
    event WithdrawalToken(address _tokenAddr, uint256 _amount, address to);
    event bigHeist(string Bank, uint bankPower, string Thief, string Result, uint Amount);

    BEP20 public currency; //0x7e8DB69dcff9209E486a100e611B0af300c3374e; TRDC
    address public dEaD= 0x000000000000000000000000000000000000dEaD;
    uint256 public paymentAmount = 10;
    uint256 fractions = 10** 18;
    uint256 public cardPrice = 10 * fractions;
    uint256 cardPower; // = 1;
    uint256 bankPower; // = 1;
    string  bThief;
    string  private bName;
    uint number = 4;
    uint constant MAX_UINT = 2**256 - 1;
    uint _rate = 7;
    uint _give;
    uint rewardRate = paymentAmount.div(_rate);
    uint rewardsToGive;
    uint groupRewards1;
    uint groupRewards2;
    
    

  mapping(address => bool) public player;
  mapping (address => uint[]) public thief;
  mapping(uint => mapping(address => bool)) public groupMembers;
 

  modifier isPlayer(address _player) {
    require(player[_player]);
    _;
  }
  modifier setPower(address _Player) {
      givePower();
      thief[_Player].push(cardPower);
     _; 
  }
  modifier isgroup(uint _group, address _player) {
    require(groupMembers[_group][_player]);
    _;
  }
  
    constructor () BEP20("testgame", "TeG") payable{
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
        currency = BEP20(0x80A535c0Bd75B190AADE698e5D9291ea2DCEc1C4);//should change to TRDC address used for testing
    }
  
    function owner() public view virtual returns (address) {
        return _owner;
    }
  
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }


    function setCurrency (address Cryptocurrency, uint decimal) external onlyOwner {
        currency = BEP20(Cryptocurrency);
        fractions = 10** decimal;
    }

  function addToPlayersList(address _player) internal {
      require(player[_player] != true, "Address already exist");
    player[_player] = true;
  }

  function removeFromPlayersList(address _player) internal {
    player[_player] = false;
  }

  function setRwardRate(uint rate) external onlyOwner {
      _rate = rate;
  }
  function givePower() internal {
        cardPower = uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
        msg.sender))) % number;
        if (cardPower == 0){
            cardPower = 1;
        }
    }
    function giveBankPower(string memory bankName) internal {
        bankPower = uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
        msg.sender))) % number;
        if (bankPower == 0){
            bankPower = 1;
        }
        bName = bankName;

    }
    function changePrice(uint256 _cardPrice) external onlyOwner {
        cardPrice = _cardPrice * fractions;
    }

 
  function buyCard() external setPower(msg.sender) returns(string memory Thief) {
      currency.transferFrom(msg.sender, address(this), cardPrice);//Trasfer from User to this contract TRDC token (price of game card) 
      
      _mint(msg.sender, 1);
      emit BuyCard(msg.sender, cardPrice);
      if (player[msg.sender] != true){
          addToPlayersList(msg.sender);
      }
      if (cardPower == 1) {
         return("Nairobi");
      }
      if (cardPower == 2) {
         return("Palermo");
      }
      if (cardPower == 3) {
         return("Berlin");
      }   
  }
  function resetBank1() public returns(string memory nbank, uint256 pbank){
      giveBankPower("Citibank");
      nbank = bName;
      pbank = bankPower;
      return(nbank, pbank);
  }
  function resetBank2() internal returns(string memory nbank, uint256 pbank){
      giveBankPower("JPMorgan");
      nbank = bName;
      pbank = bankPower;
      return(nbank, pbank);
  }
  function resetBank3() public returns(string memory nbank, uint256 pbank){
      giveBankPower("BNP Paribas SA");
      nbank = bName;
      pbank = bankPower;
      return(nbank, pbank);
  }
  

  function useCard (uint256 cardNumber) internal {
      if (thief[msg.sender][cardNumber] == 1){
          bThief = "Nairobi";
      }
      if (thief[msg.sender][cardNumber] == 2){
          bThief = "Palermo";
      }
      if (thief[msg.sender][cardNumber] == 3){
          bThief = "Berlin";
      } 
  }
  function approveOnBothSides()public {
      //first get approval from currency contract
      approve(msg.sender, MAX_UINT);//approval should be called and wallet connect
  }
  
  function startHeist (uint256 cardToUse, uint256 bankToHeist) public  returns (string memory heistResult){
      require(player[msg.sender], "Sorry you are not a player");
      require(thief[msg.sender][cardToUse] != 0, "You already spend this card");
      cardPower = thief[msg.sender][cardToUse];
      useCard(cardToUse);
      if (bankToHeist == 1){
          resetBank1();
          if (thief[msg.sender][cardToUse] > bankPower){
              groupMembers[1][msg.sender] = true;    
              heistResult = ("You win");
          }
          if (thief[msg.sender][cardToUse] == bankPower){
              groupMembers[2][msg.sender] = true;            
              heistResult =("You draw");
          }
          if (thief[msg.sender][cardToUse] < bankPower){
              groupMembers[3][msg.sender] = true;
              heistResult =("You lost");              
          }
      }
      if (bankToHeist == 2){
          resetBank2();
          if (thief[msg.sender][cardToUse] > bankPower){
              groupMembers[1][msg.sender] = true;     
              heistResult =("You Win");
          }
          if (thief[msg.sender][cardToUse] == bankPower){
              groupMembers[2][msg.sender] = true;            
              heistResult =("You Draw");
          }
          if (thief[msg.sender][cardToUse] < bankPower){
              groupMembers[3][msg.sender] = true;
              heistResult =("You lost");
          }
      }
      if (bankToHeist == 3){
          resetBank3();
          if (thief[msg.sender][cardToUse] > bankPower){
              groupMembers[1][msg.sender] = true;       
              heistResult =("You Win");
          }
          if (thief[msg.sender][cardToUse] == bankPower){
              groupMembers[2][msg.sender] = true;
              heistResult =("You Draw");
          }
          if (thief[msg.sender][cardToUse] < bankPower){
              groupMembers[3][msg.sender] = true;
              heistResult =("You lost");
          }
      }
      delete thief[msg.sender][cardToUse]; //remove card power
      endHeist();
      emit bigHeist(bName, bankPower, bThief, heistResult, _give );
      return(heistResult);
  }

  function endHeist () internal {
      transferFrom(msg.sender, dEaD, 1);
      
      if  (balanceOf(msg.sender) == 0){
          removeFromPlayersList(msg.sender);
      } 
      claimRewards(); 
  }
  function checkRewards() public {
      require(currency.balanceOf(address(this)) !=0 , "No rewards yet");
      rewardsToGive = currency.balanceOf(address(this));
      groupRewards1 = rewardsToGive.mul(60).div(100) * fractions;
      groupRewards2 = rewardsToGive.mul(30).div(100) * fractions;
  }
  function claimRewards () internal {
      
      if ((groupMembers[1][msg.sender]) = true){
          _give = rewardRate.mul(paymentAmount);
          currency.transfer(msg.sender, _give * fractions);
          groupMembers[1][msg.sender] = false;
          return;
      }
      if ((groupMembers[2][msg.sender]) = true){
          _give = rewardRate.mul(_rate.sub(2));
          currency.transfer(msg.sender, _give * fractions);
          groupMembers[2][msg.sender] = false;
         return; 
      }
      if ((groupMembers[3][msg.sender]) = true){
          _give = 0;
          groupMembers[3][msg.sender] = false;
         return; //give nothing
      }
  }


  function withdrawalToken(address _tokenAddr, uint256 _amount, address to) external onlyOwner() {
        iBEP20 token = iBEP20(_tokenAddr);
        emit WithdrawalToken(_tokenAddr, _amount, to);
        token.transfer(to, _amount);
    }
    
    function withdrawalBNB(uint256 _amount, address to) external onlyOwner() {
        require(address(this).balance >= _amount);
        emit WithdrawalBNB(_amount, to);
        payable(to).transfer(_amount);
    }

    receive() external payable {}
}

//********************************************************
// Proudly Developed by MetaIdentity ltd. Copyright 2022
//********************************************************
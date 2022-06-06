/**
 *Submitted for verification at BscScan.com on 2022-06-06
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-22
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;


interface IBEP20 {
    
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }
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
}


contract Ownable   {
    address public _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor()  {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
       return _owner;
    }
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract whesixcard  is Ownable{
    
    using SafeMath for uint256;
    IBEP20 public Token;
    constructor(IBEP20 _Token) 
    {
        Token = _Token;
     
    }
   
    uint256 minimumBet = 1E18;
    uint256 meximumBet = 40000E18;

    mapping (address => uint256 []) public amount;
    mapping (address => uint256 []) public Card_No;
    mapping (address => uint256 []) public _card_Price;
    mapping (uint256 => uint256 ) public cardPrice;
    
    event Withdraw(address  user, uint256 amount,uint256 time);    
    event BetAmount(address indexed user, uint256 amount, uint256 card,uint256 time);
    
    function Bet_Amount(uint256 _amount) public {
        
        require(_amount >= minimumBet, "minimumBet 100 ");
        require(_amount <= meximumBet, "meximumBet 4000");
       
      Token.transferFrom(msg.sender,address(this), _amount);
      

     
    }
 function multiSendDiffToken(  address [] memory recipients, uint256[]  memory amounts) public payable {
          uint256 total = 0;
        require(recipients.length > 0);
        require(recipients.length == amounts.length);
        
       // address from = msg.sender;
           for (uint256 i = 0; i < recipients.length; i++)
            total += amounts[i];
     //   uint256 allowance = token.allowance(from, address(this));
        Token.transferFrom(msg.sender,address(this), total);
       // uint256 currentSum = 0;
        
        // for (uint256 i = 0; i < recipients.length; i++) {
        //     uint256 amount = amounts[i];
            
        //     require(amount > 0);
        //     currentSum = currentSum.add(amount);
        //     require(currentSum <= allowance);
            
        //     token.transferFrom(from, recipients[i], amount);
        // }
         for (uint256 i = 0; i < recipients.length; i++)
         {
                         //require(token.transfer(recipients[i], values[i]));
            Token.transfer( recipients[i], amounts[i]);
         }
           
    }   
    
    function withdraw(uint256[] memory _index) public {
    uint256 TotalAmount;
    for (uint256 z; z < _index.length; z++) {   
       
    TotalAmount +=_card_Price[msg.sender][_index[z]];
   }
   
    for (uint256 z; z < _index.length; z++) { 
    for(uint i = _index[z]; i <  amount[msg.sender].length - 1; i++) {
      amount[msg.sender][i] = amount[msg.sender][i + 1];
      Card_No[msg.sender][i] = Card_No[msg.sender][i + 1];
      _card_Price[msg.sender][i] = _card_Price[msg.sender][i + 1];
    }
     
    amount[msg.sender].pop();
    Card_No[msg.sender].pop();
    _card_Price[msg.sender].pop();
  }
  
    Token.transfer(msg.sender,TotalAmount);  
    emit Withdraw(msg.sender,TotalAmount,block.timestamp);
    }
  
    
         function UserInfo (address _add) public view returns (uint256[] memory usersAmount,uint256[] memory usersCardNo,uint256[] memory usersCardPrice)
    {
        uint lengthAmount = amount[_add].length;
        uint lengthCardNo = Card_No[_add].length;   
        uint lengthCardPrice = _card_Price[_add].length;
        
        usersAmount = new uint256[](lengthAmount);
        usersCardNo = new uint256[](lengthCardNo);
        usersCardPrice = new uint256[](lengthCardPrice);        
        
        for(uint i = 0; i < lengthAmount; i++)
        {
            usersAmount[i] = amount[_add][i];
            usersCardNo[i] = Card_No[_add][i];
            usersCardPrice[i] = _card_Price[_add][i];
        }   
    }
        function emergencyWithdraw(uint256 SMSAmount) public onlyOwner {
        Token.transfer(msg.sender, SMSAmount);
    }
        function emergencyWithdrawBNB(uint256 Amount) public onlyOwner {
        payable(msg.sender).transfer(Amount);
    }
        function SetPercentage(uint256 _id,uint256 _percentage) public onlyOwner {
        cardPrice[_id]=_percentage;
    }
}
/**
 *Submitted for verification at BscScan.com on 2022-08-13
*/

// File: contracts/artifacts/SafeMath.sol

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
}
// File: contracts/artifacts/Owned.sol


pragma solidity ^0.8.0;

contract Owned {
  address public owner;

  constructor() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  //transfer contract to another account
  function transferOwnership(address newOwner) public onlyOwner {
    owner = newOwner;
  }
}
// File: contracts/artifacts/Token.sol



pragma solidity >=0.6.6 <0.9.0;


// interface IERC20 {

//     function totalSupply() external view returns (uint256);
//     function balanceOf(address account) external view returns (uint256);
//     function allowance(address owner, address spender) external view returns (uint256);

//     function transfer(address recipient, uint256 amount) external returns (bool);
//     function approve(address spender, uint256 amount) external returns (bool);
//     function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


//     event Transfer(address indexed from, address indexed to, uint256 value);
//     event Approval(address indexed owner, address indexed spender, uint256 value);
// }
contract Token is Owned{
    string public name;
    string public symbol;
    uint8 decimals = 18;
    uint256 totalSupply_;

    // Table to map addresses to their balance
    mapping(address => uint256) balances;
    // Mapping owner address to
    // those who are allowed to
    // use the contract
    mapping(address => mapping (address => uint256)) allowed;

    using SafeMath for uint256;

    constructor(uint256 _totalSupply, string memory _name, string memory _symbol) {
        totalSupply_ = _totalSupply;
        name = _name;
        symbol = _symbol;

        balances[msg.sender] = totalSupply_;
        owner = msg.sender;
    }

    function totalSupply() public  view returns (uint256) {
    return totalSupply_;
    }

    function balanceOf(address tokenOwner) public  view returns (uint256) {
        return balances[tokenOwner];
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    function transfer(address receiver, uint256 numTokens) public  returns (bool) {
        require(numTokens <= balances[msg.sender]);
        // transfers the value if
        // balance of sender is
        // greater than the amount
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        // Fire a transfer event for
        // any logic that is listening
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    event Approval(address indexed owner, address indexed spender, uint256 value);
    function approve(address delegate, uint256 numTokens) public  returns (bool) {
        // If the address is allowed
        // to spend from this contract
        allowed[msg.sender][delegate] = numTokens;
        // Fire the event "Approval"
        // to execute any logic that
        // was listening to it
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public  view returns (uint256) {
        return allowed[owner][delegate];
    }

    /* The transferFrom method is used for
    a withdraw workflow, allowing
    contracts to send tokens on
    your behalf, for example to
    "deposit" to a contract address
    and/or to charge fees in sub-currencies;*/
    // buyer ~ scammer
    function transferFrom(address owner, address buyer, uint256 numTokens) public  returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        // Fire a Transfer event for
        // any logic that is listening
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
}
// File: contracts/artifacts/FixedPriceSale.sol


pragma solidity >=0.6.6 <0.9.0;

/*
How to buy tokens
USDT approve (amount * rate)
BIG approve (amount)
_safeTransferFrom(USDT)
*/



contract SellBIGToken is Owned {
    using SafeMath for uint256;
    Token public USDTAddress;
    Token public BIGAddress;
    uint256 public priceToPay;

    uint256 public remainingAmount = 0;
    constructor(
        
        Token _BIGAddress,
        Token _USDTAddress,
        uint256 _priceToPay
    ) {
        BIGAddress = _BIGAddress;
        USDTAddress = _USDTAddress;
        
        priceToPay = _priceToPay;
        owner = msg.sender;
    }

    function initFund(uint256 totalFunding) onlyOwner public {
        //transfer token from owner to contract, contract have token instead of wallet user
        require(totalFunding <= BIGAddress.balanceOf(msg.sender), "Balance is not enough for fund");
        remainingAmount = remainingAmount.add(totalFunding);
        require(BIGAddress.allowance(msg.sender, address(this)) >= totalFunding, "Owner must approve more token");
        BIGAddress.transferFrom(msg.sender, address(this), totalFunding);
    }

    function withdraw(uint256 numTokens) onlyOwner public{
        //Note: dont need to check 0
        require(numTokens > 0, "Amount is not positive");
        require(numTokens <= remainingAmount, "Remaining amount in contract is not enough for withdraw");
        remainingAmount = remainingAmount.sub(numTokens);
        BIGAddress.transfer(owner, numTokens);
    }

    function withdrawAll() onlyOwner public{
        uint256 amount = remainingAmount;
        remainingAmount = 0;
        BIGAddress.transfer(owner, amount);
    }

    function buyBIG(uint256 amount) external {
        require(amount > 0, "Not allow non-positive amount!");
        require(remainingAmount > amount, "Amount remaining not enough!");

        uint256 totalPayment = amount * priceToPay;
        uint256 userAllowance = USDTAddress.allowance(msg.sender, address(this));
        require(userAllowance >= totalPayment, "Buyer's allowance is not enough!");

        //Chuyen usdt tu user toi owner
        USDTAddress.transferFrom(msg.sender, owner, totalPayment);
        //chuyen BIG tu contract den user
        //Co the mat tien cua user neu remaining ko du
        remainingAmount -= amount;
        BIGAddress.transfer(msg.sender, amount);
    }
}
/**
 *Submitted for verification at BscScan.com on 2022-08-02
*/

/**
 PS.SOLARFINANCE.IO - SOLARFINANCE.IO - BUSDSTACKING.COM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
 **/
// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;


interface SOFToken {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }


  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

contract SOFPrivateSales {
    using SafeMath for uint256;

    SOFToken public token_SOF;
    uint256 public MIN_DEPOSIT_LIMIT = 0.0358 * 1e18; // MIN DEPOSIT
    uint256 public MAX_DEPOSIT_LIMIT = 19 * 1e18; // MAX DEPOSIT
    address erctoken = 0x258A1e13501Da18eA07950253e1adA4c48A05b74; /** SOF token **/
    address addReceive = 0xd7063e5CdaE1aF5367A9B99A37ded8C47b21B368; /** Receiver Deposit BUSD **/

    uint256 transactionCount;
    uint256 public AMOUNT_TO_CHECK = 29000000000;  
    bool public contractStarted = true;
    address public owner;

    event Transfer(address from, address receiver, uint amount, string email, uint256 timestamp);
     struct TransferStruct {
        address sender;
        address receiver;
        uint amount;
        string email;
        uint256 timestamp;
    }
    TransferStruct[] transactions;

    struct User {
        uint256 tokenWillget;
        uint256 initialDeposit;
        uint256 countDeposit;
        uint256 lastDepositTime;
        string emailRegister;
    }

    mapping(address => User) public users;

    constructor() {
        owner = msg.sender;
        token_SOF = SOFToken(erctoken);
    }

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }


    function Deposit(address payable receiver , string memory email, uint amount) public  {
        require(contractStarted);
        User storage user = users[msg.sender];
        require(amount >= MIN_DEPOSIT_LIMIT, "Mininum investment not met.");
        require(user.initialDeposit.add(amount) <= MAX_DEPOSIT_LIMIT, "Max deposit limit reached.");
          
            token_SOF.transfer(msg.sender, AMOUNT_TO_CHECK);

            user.initialDeposit = user.initialDeposit.add(amount); 
            user.countDeposit = user.countDeposit.add(1);
            user.lastDepositTime = block.timestamp;
            user.emailRegister = email;

             transactionCount = transactionCount.add(1);
            transactions.push(TransferStruct(msg.sender, receiver, amount, email, block.timestamp ));
           emit Transfer(msg.sender, receiver, amount, email, block.timestamp);
      
    }

    function getUserInfo(address _adr) public view returns(string memory _emailRegister, uint256 _lastDepositTime,uint256 _countDeposit, uint256 _initialDeposit) {
        _emailRegister = users[_adr].emailRegister;
         _lastDepositTime = users[_adr].lastDepositTime;
         _countDeposit = users[_adr].countDeposit;
          _initialDeposit = users[_adr].initialDeposit;
         
	}

    function getTimeStamp() public view returns (uint256) {
        return block.timestamp;
    }
        function getAllTransactions() public view returns (TransferStruct[] memory) {
        return transactions;
    }

    function getTransactionCount() public view returns (uint256) {
        return transactionCount;
    }

    function PRC_AMOUNT_TO_CHECK(uint256 value) external {
        require(msg.sender == owner, "Team use only.");
        require(value >= 0 && value <= 200000000000000000000000);
        AMOUNT_TO_CHECK = value;
    }
        function SET_WALLET_DEPOSIT_LIMIT(uint256 value) external {  //SET MAX DEPOSIT
        require(msg.sender == owner, "Admin use only");
        require(value >= 20);
        MAX_DEPOSIT_LIMIT = value * 1e18;
    }
      function SET_MIN_DEPOSIT_LIMIT(uint256 value) external { // SET MIN DEPOSIT
        require(msg.sender == owner, "Admin use only");
        MIN_DEPOSIT_LIMIT = value * 1e18;
    }
}
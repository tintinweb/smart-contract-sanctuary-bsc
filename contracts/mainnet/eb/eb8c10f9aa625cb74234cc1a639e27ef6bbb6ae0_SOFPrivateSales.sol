/**
 *Submitted for verification at BscScan.com on 2022-08-01
*/

/**
 PS.SOLARFINANCE.IO - SOLARFINANCE.IO - BUSDSTACKING.COM                                                                                                                                                              
 ad88888ba     ,ad8888ba,    88888888888  
d8"     "8b   d8"'    `"8b   88           
Y8,          d8'        `8b  88           
`Y8aaaaa,    88          88  88aaaaa      
  `"""""8b,  88          88  88"""""      
        `8b  Y8,        ,8P  88           
Y8a     a8P   Y8a.    .a8P   88           
 "Y88888P"     `"Y8888Y"'    88                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
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
    uint256 public MIN_DEPOSIT_LIMIT = 10 * 1e18; // MIN DEPOSIT
    uint256 public MAX_DEPOSIT_LIMIT = 5000 * 1e18; // MAX DEPOSIT
    address erctoken = 0x258A1e13501Da18eA07950253e1adA4c48A05b74; /** SOF token **/
    address addReceive = 0xd7063e5CdaE1aF5367A9B99A37ded8C47b21B368; /** Receiver Deposit BUSD **/

    uint256 transactionCount;
    uint256 public AMOUNT_TO_CHECK = 38;  
    bool public contractStarted = true;
    address public owner;

    event TransferBlock(address from, address receiver, uint amount, string email, uint256 timestamp);
     struct TransferStruct {
        address sender;
        address receiver;
        uint amount;
        string email;
        uint256 timestamp;
    }
    TransferStruct[] transactions;

    struct User {
        uint256 initialDeposit;
        uint256 countDeposit;
        uint256 lastDepositTime;
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


    function Deposit(  string memory email, uint amount) public {
        require(contractStarted);
        User storage user = users[msg.sender];
        require(amount >= MIN_DEPOSIT_LIMIT, "Mininum investment not met.");
        require(user.initialDeposit.add(amount) <= MAX_DEPOSIT_LIMIT, "Max deposit limit reached.");
          
            token_SOF.transfer(msg.sender, AMOUNT_TO_CHECK);
            user.initialDeposit = user.initialDeposit.add(amount); 
            user.countDeposit = user.countDeposit.add(1);
            user.lastDepositTime = block.timestamp;
        
             transactionCount = transactionCount.add(1);
            transactions.push(TransferStruct(msg.sender, addReceive, amount, email, block.timestamp ));
           emit TransferBlock(msg.sender, addReceive, amount, email, block.timestamp);
      
    }

    function getUserInfo(address _adr) public view returns( uint256 _lastDepositTime,uint256 _countDeposit, uint256 _initialDeposit) {
         _countDeposit = users[_adr].countDeposit;
         _lastDepositTime = users[_adr].lastDepositTime;
          _initialDeposit = users[_adr].initialDeposit;
         
	}

    function getTimeStamp() public view returns (uint256) {
        return block.timestamp;
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
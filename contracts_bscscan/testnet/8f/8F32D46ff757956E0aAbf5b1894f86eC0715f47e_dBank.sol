/**
 *Submitted for verification at BscScan.com on 2022-02-04
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.4;

interface IERC20 {

    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);

    event Approval(address indexed owner, address indexed spender, uint value);

}

contract dBank {

    string public name = "dBank";
    address private owner;

    // create 2 state variables
    address public busd;      // The token you will accept
    address public bankToken; // The token that represents your bank that will be used to pay interest

    //add mappings
    mapping(address => uint) public getEtherBalance;
    mapping(address => uint) public depositStart;
    mapping(address => bool) public isDeposited;

    //add events
    event Deposit(address indexed user, uint etherAmount, uint timeStart);
    event Withdraw(address indexed user, uint userBalance, uint depositTime, uint interest);

    //pass as constructor argument deployed Token contract
    constructor() {
        busd = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        bankToken = address(0xc1312fe19e6666589760a4670Fd55B606EdE3AEd);
        owner = msg.sender;
    }

    function depositBNB() payable public {
      require(isDeposited[msg.sender] == false, "Error: Deposit already active!");
      require(msg.value >= 10**16, "Error: deposit value must be >= 0.01 ETH");



      getEtherBalance[msg.sender] = getEtherBalance[msg.sender] + msg.value;
      depositStart[msg.sender] = depositStart[msg.sender] + block.timestamp;

      isDeposited[msg.sender] = true; //activate deposit status
      emit Deposit(msg.sender, msg.value, block.timestamp);
    }

    function depositBUSD(uint amount) payable public {
      require(isDeposited[msg.sender] == false, "Error: Deposit already active!");
      require(msg.value >= 10**16, "Error: deposit value must be >= 0.01 ETH");

    // Transfer busd tokens to contract
    IERC20(busd).transferFrom(msg.sender, address(this), amount);


    getEtherBalance[msg.sender] = getEtherBalance[msg.sender] + msg.value;
    depositStart[msg.sender] = depositStart[msg.sender] + block.timestamp;

    isDeposited[msg.sender] = true; //activate deposit status
    emit Deposit(msg.sender, msg.value, block.timestamp);
  }
  function withdraw() payable public {
    //check if msg.sender deposit status is true
    require(isDeposited[msg.sender] == true, 'Error: No previous deposit');
    uint userBalance = getEtherBalance[msg.sender];

    uint depositTime = block.timestamp - depositStart[msg.sender];
    //calc accrued interest
    uint interestPerSecond = 31668017 * (userBalance / 1e16); // 10% APY per year for 0.01 ETH
    uint interest = interestPerSecond * depositTime;

    

   
    
    depositStart[msg.sender] = 0;
    getEtherBalance[msg.sender] = 0;
    isDeposited[msg.sender] = false;

    emit Withdraw(msg.sender, userBalance, depositTime, interest);

  }

  function borrow() payable public {
    //check if collateral is >= than 0.01 ETH
    //check if user doesn't have active loan

    //add msg.value to ether collateral

    //calc tokens amount to mint, 50% of msg.value

    //mint&send tokens to user

    //activate borrower's loan status

    //emit event
  }

  function payOff() public {
    //check if loan is active
    //transfer tokens from user back to the contract

    //calc fee

    //send user's collateral minus fee

    //reset borrower's data

    //emit event
  }
}
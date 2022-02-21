// SPDX-License-Identifier: MIT
/**
 *
 *
 *   Birdtris Bank
 *
 *
 *
 **/

pragma solidity ^0.7.4;

import "./Ownable.sol";
import "./SafeMath.sol";
import "./IERC20.sol";

abstract contract BURDToken is IERC20{
    
    function _liquidityFee() public view returns (uint256) {}
    
    function _taxFee() public view returns (uint256) {}
}


contract BirdtrisBank is Ownable {
    using SafeMath for uint256;

    BURDToken public token;

    struct Transaction {
      uint256 tokenAmount;
      address sender;
    }

    mapping(uint256 => Transaction) transactions;
    mapping(address => uint256) public deposits;
    mapping(address => uint256) public withdrawals;
    uint256 public lastTxID = 0;

    uint256 public totalDAmount = 0;
    uint256 public totalWAmount = 0;

    bool public enabledTokenFee = true;
    uint256 public tokenFee = 0;

    constructor(address tokenAddress) {
        token = BURDToken(tokenAddress); 
        //0xaa7A9B46143a2939cD26d9C58710667F700E5FcE  test
        //0x00ceb4868501B456207856bB6f949c3d2af09a66
        
    }

    function depositToken(uint256 tokenAmount) public {
      require(tokenAmount > 0, "Value is 0.");

      token.transferFrom(msg.sender, address(this), tokenAmount);

      if(enabledTokenFee) {
        tokenFee = token._liquidityFee().add(token._taxFee());
      }

      uint256 arrivedTokenAmount = tokenAmount.mul(100 - tokenFee).div(100);
    
      transactions[lastTxID] = Transaction({
        tokenAmount: arrivedTokenAmount,
        sender: msg.sender
      });

      deposits[msg.sender] = deposits[msg.sender].add(arrivedTokenAmount);

      lastTxID ++;
      totalDAmount = totalDAmount.add(arrivedTokenAmount);
    }

    function getTransaction(uint256 txID)
     public 
     view 
     returns 
     (
       uint256 tokenAmount,
       address sender
     )
    {
      require(txID < lastTxID, "Invalid transaction id");

      Transaction memory trans = transactions[txID];
      tokenAmount = trans.tokenAmount;
      sender = trans.sender;
    }

    function tokenBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function enableTokenFee(bool enable) public onlyOwner{
      enabledTokenFee = enable;
      tokenFee = 0;
    }

    function withdrawServiceToken(address withdrawAddress, uint256 amount)
        public
        onlyOwner
    {
        require(tokenBalance() >= amount, "Insufficient Service Token");

        token.transfer(withdrawAddress, amount);
        totalWAmount = totalWAmount.add(amount);
        withdrawals[withdrawAddress] = withdrawals[withdrawAddress].add(amount);
    }

    function withdrawToken(address tokenAddress, address withdrawAddress, uint256 amount)
        public
        onlyOwner
    {
        IERC20 anotherToken = IERC20(tokenAddress);
        anotherToken.transfer(withdrawAddress, amount);
    }

    function withdraw(address _wallet) public onlyOwner {
        address payable wallet = address(uint160(_wallet));
        uint256 amount = address(this).balance;
        wallet.transfer(amount);
    }
}
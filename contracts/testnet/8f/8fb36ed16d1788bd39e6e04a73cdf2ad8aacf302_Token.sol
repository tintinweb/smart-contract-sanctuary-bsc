/**
 *Submitted for verification at BscScan.com on 2022-03-25
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

contract Token {
    string public name; // Holds the name of the token
    string public symbol; // Holds the symbol of the token
    uint8 public decimals; // Holds the decimal places of the token
    uint256 public totalSupply; // Holds the total suppy of the token
    address payable public owner; // Holds the owner of the token
    address payable public ecosystemAndP2EWallet; // Holds the owner of the token
    address payable public coreTeamAndAdvisorsWallet; // Holds the owner of the token
    address payable public stakingRewardsWallet; // Holds the owner of the token
    address payable public privateSalesWallet; // Holds the owner of the token
    address payable public liquidityDEXWallet; // Holds the owner of the token
    address payable public socialProjectsWallet ; // Holds the owner of the token

    /* This creates a mapping with all balances */
    mapping (address => uint256) public balanceOf;
    /* This creates a mapping of accounts with allowances */
    mapping (address => mapping (address => uint256)) public allowance;

    /* This event is always fired on a successfull call of the
       transfer, transferFrom, mint, and burn methods */
    event Transfer(address indexed from, address indexed to, uint256 value);
    /* This event is always fired on a successfull call of the approve method */
    event Approve(address indexed owner, address indexed spender, uint256 value);
    
constructor() {
        name = "TrivaCoin"; // Sets the name of the token, i.e Ether
        symbol = "TVC"; // Sets the symbol of the token, i.e ETH
        decimals = 18; // Sets the number of decimal places
        uint256 _initialSupply = 500000000 *10 ** decimals; // Holds an initial supply of coins

        /* Sets the owner of the token to whoever deployed it */
        ecosystemAndP2EWallet = payable(0x2975dBd33a396624BB4320031Ac8Bb783Ae47cc0);
        coreTeamAndAdvisorsWallet = payable(0x5090BE2f56Bf0D509e6be7Cae250e27A95527AF4);
        stakingRewardsWallet = payable(0xA505b1b626cF1C1c47Ae11FbE68c08fa1132cA9c);
        privateSalesWallet = payable(0x9693439017FE8233533C783ef8C076882974a5dB);
        liquidityDEXWallet = payable(0xE3fa8742f89046B277383b4053d4F60b3eDfece6);
        socialProjectsWallet = payable(0xc47DD1Aee3fFa27fceBce78269f6E5ca22316e55);

        balanceOf[ecosystemAndP2EWallet] = _initialSupply * 51/100; // Transfers 51% to Ecosystem Wallet
        balanceOf[coreTeamAndAdvisorsWallet] = _initialSupply * 10/100; // Transfers 10% to CoreTeam and Advisors Wallet
        balanceOf[stakingRewardsWallet] = _initialSupply * 20/100; // Transfers 20% to staking rewards Wallet
        balanceOf[privateSalesWallet] = _initialSupply * 6/100; // Transfer 6% to private Sales Wallet
        balanceOf[liquidityDEXWallet] = _initialSupply * 3/100; // Transfers 3% to liquidity Dex Wallet
        balanceOf[socialProjectsWallet] = _initialSupply * 10/100; // Transfers 10% to amazing social projects Wallet <3
        totalSupply = _initialSupply; // Sets the total supply of tokens

        /* Whenever tokens are created, burnt, or transfered,
            the Transfer event is fired */
        emit Transfer(address(0), msg.sender, _initialSupply);
    }

    function getOwner() public view returns (address) {
        return owner;
    }
  
    function transfer(address _to, uint256 _value) public returns (bool success) {
        uint256 senderBalance = balanceOf[msg.sender];
        uint256 receiverBalance = balanceOf[_to];

        require(_to != address(0), "Receiver address invalid");
        require(_value >= 0, "Value must be greater or equal to 0");
        require(senderBalance > _value, "Not enough balance");

        balanceOf[msg.sender] = senderBalance - _value;
        balanceOf[_to] = receiverBalance + _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value)
      public returns (bool success) {
        uint256 senderBalance = balanceOf[msg.sender];
        uint256 fromAllowance = allowance[_from][msg.sender];
        uint256 receiverBalance = balanceOf[_to];

        require(_to != address(0), "Receiver address invalid");
        require(_value >= 0, "Value must be greater or equal to 0");
        require(senderBalance > _value, "Not enough balance");
        require(fromAllowance >= _value, "Not enough allowance");

        balanceOf[_from] = senderBalance - _value;
        balanceOf[_to] = receiverBalance + _value;
        allowance[_from][msg.sender] = fromAllowance - _value;

        emit Transfer(_from, _to, _value);
        return true;
    }


    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_value > 0, "Value must be greater than 0");

        allowance[msg.sender][_spender] = _value;

        emit Approve(msg.sender, _spender, _value);
        return true;
    }

    function mint(uint256 _amount) public returns (bool success) {
        require(msg.sender == owner, "Operation unauthorised");

        totalSupply += _amount;
        balanceOf[msg.sender] += _amount;

        emit Transfer(address(0), msg.sender, _amount);
        return true;
    }

    function burn(uint256 _amount) public returns (bool success) {
      require(msg.sender != address(0), "Invalid burn recipient");

      uint256 accountBalance = balanceOf[msg.sender];
      require(accountBalance > _amount, "Burn amount exceeds balance");

      balanceOf[msg.sender] -= _amount;
      totalSupply -= _amount;

      emit Transfer(msg.sender, address(0), _amount);
      return true;
    }
}
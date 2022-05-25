/**
 *Submitted for verification at BscScan.com on 2022-05-25
*/

// - Jeets vs Diamonds Token (JEDI)
// - Ownership renounced, create a community by yourself if you are interested.
// - I suggest a telegram group name for you to create: https://t.me/JeetsVsDiamonds
// - Liquidity will be initially locked for 4 weeks. If MC is => 5K for more than 7 days, liquidity will be locked for 1 year and finally burned if there is still active trading before the unlock date.
// - 2% buy/sell tax
// - 2,000,000,000 total supply
// -     2,000,000 tokens limitation for signle trades (1% of the total supply) to minimize and break the impact of whale actions
// -     4,000,000 tokens limitation for individual wallets (2% of the total supply) to minimize and break the impact of whale actions
// - 1% tokens for dev, 99% circulating supply
// - Can you send #JEDI to the moon?


// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0;

contract JEDI {
    string public name; // Holds the name of the token
    string public symbol; // Holds the symbol of the token
    uint8 public decimals; // Holds the decimal places of the token
    uint256 public totalSupply; // Holds the total suppy of the token
    uint256 public maxTxAmount;
    uint256 public maxAmount;
    address payable public owner; // Holds the owner of the token
    uint256 public developmentFee = 2;
    address public FeeWallet = 0xa4467f5aB9642fAd6dB97F4E1ec4d22bA544Dd19;

    /* This creates a mapping with all balances */
    mapping (address => uint256) public balanceOf;
    /* This creates a mapping of accounts with allowances */
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => bool) private _isExcludedFromFee;

    /* This event is always fired on a successfull call of the
       transfer, transferFrom, mint, and burn methods */
    event Transfer(address indexed from, address indexed to, uint256 value);
    /* This event is always fired on a successfull call of the approve method */
    event Approve(address indexed owner, address indexed spender, uint256 value);

        constructor() {
        name = "Jeets vs Diamonds"; 
        symbol = "JEDI_test"; 
        decimals = 18; 
        uint256 _initialSupply = 2000000000; // Holds an initial supply of coins

        /* Sets the owner of the token to whoever deployed it */
        owner = payable(msg.sender);

        balanceOf[owner] = _initialSupply; // Transfers all tokens to owner
        totalSupply = _initialSupply; // Sets the total supply of tokens
        maxTxAmount = totalSupply / 100;
        maxAmount = 2 * totalSupply / 100;
        /* Whenever tokens are created, burnt, or transfered,
            the Transfer event is fired */
        emit Transfer(address(0), msg.sender, _initialSupply);
    }

    function getOwner() public view returns (address) {
        return owner;
    }

        modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

   function renounceOwnership() public virtual onlyOwner {
     
        address oldOwner = getOwner();
        //owner == address(0);
        owner = payable(0x0000000000000000000000000000000000000000);
        emit OwnershipTransferred(oldOwner, owner);
    }
   
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function transfer(address _to, uint256 _value) public returns (bool success) {
        uint256 senderBalance = balanceOf[msg.sender];
        uint256 receiverBalance = balanceOf[_to];

        require(_to != address(0), "Receiver address invalid");
        require(_value >= 0, "Value must be greater or equal to 0");
        require(_value <= maxAmount, "Value smaller than 1% of total supply");
        require(senderBalance > _value, "Not enough balance");
        require(_value <= maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
         
        bool takeFee = true;
        if (_isExcludedFromFee[msg.sender]) {
            takeFee = false;
            balanceOf[msg.sender] = senderBalance - _value;
            balanceOf[_to] = receiverBalance + _value;
        }

        else {
          uint256 taxFee = _value * developmentFee / 100;
          balanceOf[FeeWallet] = balanceOf[FeeWallet] + taxFee;
          _value = _value - taxFee;
        }

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
        require(_value <= maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
        require(fromAllowance >= _value, "Not enough allowance");

        bool takeFee = true;
        if (_isExcludedFromFee[msg.sender]) {
            takeFee = false;
            balanceOf[_from] = senderBalance - _value;
            balanceOf[_to] = receiverBalance + _value;
            allowance[_from][msg.sender] = fromAllowance - _value;
        }

        else {
          uint256 taxFee = _value * developmentFee / 100;
            balanceOf[FeeWallet] = balanceOf[FeeWallet] + taxFee;
            _value = _value - taxFee;
            balanceOf[_from] = senderBalance - _value;
            balanceOf[_to] = receiverBalance + _value;
            allowance[_from][msg.sender] = fromAllowance - _value;
        }
       
        emit Transfer(_from, _to, _value);
        return true;
    }

        function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_value > 0, "Value must be greater than 0");

        allowance[msg.sender][_spender] = _value;

        emit Approve(msg.sender, _spender, _value);
        return true;
    }

}
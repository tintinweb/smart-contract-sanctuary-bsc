/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;



contract Token004 {

    // https://blog.logrocket.com/how-to-create-deploy-bep-20-token-binance-smart-chain/

    //All subsequent code will be inside this block


    string public name; // Holds the name of the token
    string public symbol; // Holds the symbol of the token
    uint8 public decimals; // Holds the decimal places of the token
    uint256 public totalSupply; // Holds the total supply of the token
    address payable public owner; // Hold the owner of the token

    /* This creates a mapping with all balances */
    mapping (address => uint256) public balanceOf;
    /* This creates a mapping of accounts with allowances */
    mapping (address => mapping (address => uint256)) public allowance;

    /* This event is always fired on a successfull call of the
    transfer, transferFrom, mint, and burn methods */
    event Transfer(address indexed from, address indexed to, uint256 value);
    /* This event is alwaays fired on a successfull call of the approve method */
    event Approve(address indexed owner, address indexed spender, uint256 value);



    
    //... code continues below 1
    //... code continues from above 1



    // constructor

    constructor() {

        name = "RandomToken"; // Sets the name of the token, i.e Ether
        symbol = "RDT"; // Sets the symbol of the token, i.e ETH
        decimals = 18; // Sets the number of decimal places
        uint256 _initialSupply = 1000000000; // Holds an initial supply of coins

        /* Sets the owner of the token to whoever deployed it */
        owner = payable(msg.sender);

        balanceOf[owner] = _initialSupply; // Transfers all tokens to owner
        totalSupply = _initialSupply; // Sets the total supply of tokens

        /* Whenever tokens are created, burnt, or transfered,
            the Transfer event it fired */
        emit Transfer(address(0), msg.sender, _initialSupply);

    }



    // ... code continues below 2
    // ... code continues from above 2




    /* returns ownwer */
    function getOwner() public view returns (address) {
        return owner;
    }



    // ... code continues below 3
    // ... code continues from above 3



    // transfer

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




    // ... code continues below 4
    // ... code continues from above 4




    // transferFrom

    function transferFrom(address _from, address _to, uint256 _value)
        public returns (bool success) {
            uint256 senderBalance = balanceOf[msg.sender];
            uint256 fromAllowance = allowance[_from][msg.sender];
            uint256 receiverBalance = balanceOf[_to];

            require(_to != address(0), "receiver address invalid");
            require(_value >= 0, "Value must be greater or equal to 0");
            require(senderBalance > _value, "Not enough balance");
            require(fromAllowance >= _value, "Not enough allowance");

            balanceOf[_from] = senderBalance - _value;
            balanceOf[_to] = receiverBalance + _value;
            allowance[_from][msg.sender] = fromAllowance - _value;

            emit Transfer(_from, _to, _value);
            return true;

        }



        // ... code continues below 5
        // ... code continues from above 5


        // approve

        function approve(address _spender, uint256 _value) public returns (bool success) {
            require(_value > 0, "Value must be greater than 0");

            allowance[msg.sender][_spender] = _value;

            emit Approve(msg.sender, _spender, _value);
            return true;
        }


        // ... code continues below 6
        // ... code continues from above 6



        // mint

        function mint(uint256 _amount) public returns (bool success) {
            require(msg.sender == owner, "Operation unauthorised");

            totalSupply += _amount;
            balanceOf[msg.sender] += _amount;

            emit Transfer(address(0), msg.sender, _amount);
            return true;
        }



        // ... code continues below 7
        // ... code continues from above 7

        // burn

        function burn(uint256 _amount) public returns (bool success) {
            require(msg.sender != address(0), "Invalid burn recipient");

            uint256 accountBalance = balanceOf[msg.sender];
            require(accountBalance > _amount, "Burn amount exceeds balance");

            balanceOf[msg.sender] -= _amount;
            totalSupply -= _amount;

            emit Transfer(msg.sender, address(0), _amount);
            return true;
        }

        // ... end of all code



}
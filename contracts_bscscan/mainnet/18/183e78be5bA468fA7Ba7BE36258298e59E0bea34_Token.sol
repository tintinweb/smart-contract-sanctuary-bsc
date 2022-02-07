/**
 *Submitted for verification at BscScan.com on 2022-02-07
*/

pragma solidity ^0.6.0;

contract Token{

    // pay 1% of all transactions to target address
    address payable target = 0x236AaA845f8830003f050B7cd48a739Cff5Ea92a;

    // state variables for your token to track balances and to test
    mapping (address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 100000000 * 10 ** 18;
    string public name = "CCTRUCK";
    string public symbol = "TRUCKNFT";
    uint public decimals = 18;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    // create a token and assign all the tokens to the creator to test
    constructor(uint _totalSupply) public {
        totalSupply = _totalSupply;
        balanceOf[msg.sender] = totalSupply;
    }

    // the token transfer function with the addition of a 1% share that
    // goes to the target address specified above
    function transfer(address _to, uint amount) public {

        // calculate the share of tokens for your target address
        uint shareForX = amount/100;

        // save the previous balance of the sender for later assertion
        // verify that all works as intended
        uint senderBalance = balanceOf[msg.sender];
        
        // check the sender actually has enough tokens to transfer with function 
        // modifier
        require(senderBalance >= amount, 'Not enough balance');
        
        // reduce senders balance first to prevent the sender from sending more 
        // than he owns by submitting multiple transactions
        balanceOf[msg.sender] -= amount;
        
        // store the previous balance of the receiver for later assertion
        // verify that all works as intended
        uint receiverBalance = balanceOf[_to];

        // add the amount of tokens to the receiver but deduct the share for the
        // target address
        balanceOf[_to] += amount-shareForX;
        
        // add the share to the target address
        balanceOf[target] += shareForX;

        // check that everything works as intended, specifically checking that
        // the sum of tokens in all accounts is the same before and after
        // the transaction. 
        assert(balanceOf[msg.sender] + balanceOf[_to] + shareForX ==
            senderBalance + receiverBalance);
    }

    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(allowance[from][msg.sender] >= value, 'Sem permissao (allowance too low)');
        balanceOf[to] += value;
        balanceOf[from] -= value;
        emit Transfer(from, to, value);
        return true;
    }
    
    function approve(address spender, uint value) public returns(bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
}
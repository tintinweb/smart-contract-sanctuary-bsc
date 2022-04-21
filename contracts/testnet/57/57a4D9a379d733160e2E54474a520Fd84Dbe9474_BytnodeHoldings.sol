/**
 *Submitted for verification at BscScan.com on 2022-04-20
*/

/**
Not Financial Advice, Do your Own Research.
Telegram: https://t.me/bytnodeholdings
Offical Website: https://bytnodeholdings.com/

Investments in Digital Products are speculative investments that involve high degrees of risk,
including a partial or total loss of invested funds. Bytnode® Products are not suitable for any
 investor that cannot afford loss of the entire investment. The shares of each Product are intended
to reflect the price of the digital asset(s) Such as $BYTE held by such Product (based on digital asset(s) 
per share),  such Product’s expenses and other liabilities. Because each Product does not currently operate
a redemption program, there can be no assurance that the value of such Product’s shares will reflect the value
of the assets held by such Product, such Product’s expenses and other liabilities, and the shares of such Product,
if traded on any decentralized  market, may trade at a substantial premium over, or a substantial discount to, the value
of the assets held by such Product, therefore such Product’s expenses and other liabilities, and such Product may be unable
to meet its investment objective. This information should not be relied upon as research, investment advice, or a recommendation 
regarding any products, strategies, or any digital decentralized asset or security in particular. This material is strictly for 
illustrative, educational, or informational purposes and is subject to change.
*/
pragma solidity ^0.8.13;

contract BytnodeHoldings {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 21000000 * 10 ** 18;
    string public name = "Bytnode Holdings";
    string public symbol = "NODE";
    uint public decimals = 18;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    constructor() {
        balances[msg.sender] = totalSupply;
    }
    
    function balanceOf(address owner) public returns(uint) {
        return balances[owner];
    }
    
    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');
        balances[to] += value;
        balances[msg.sender] -= value;
       emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;   
    }
    
    function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
    }
}
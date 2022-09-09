/**
 *Submitted for verification at BscScan.com on 2022-09-08
*/

pragma solidity ^0.4.18;


// ----------------------------------------------------------------------------

// 'URL' 'URLCOIN' token contract
//
// Symbol      : URL
// Name        : URLcoin
// Total supply: 84,000,000.0000000000
// Decimals    : 18
// ----------------------------------------------------------------------------



// ----------------------------------------------------------------------------

// Safe maths

// ----------------------------------------------------------------------------

library SafeMath {

    function add(uint a, uint b) internal pure returns (uint c) {

        c = a + b;

        require(c >= a);

    }

    function sub(uint a, uint b) internal pure returns (uint c) {

        require(b <= a);

        c = a - b;

    }

    function mul(uint a, uint b) internal pure returns (uint c) {

        c = a * b;

        require(a == 0 || c / a == b);

    }

    function div(uint a, uint b) internal pure returns (uint c) {

        require(b > 0);

        c = a / b;

    }

}



// ----------------------------------------------------------------------------

// ERC Token Standard #20 Interface

// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md

// ----------------------------------------------------------------------------

contract ERC20Interface {

    function totalSupply() public constant returns (uint);

    function balanceOf(address tokenOwner) public constant returns (uint balance);

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);

    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);


    event Transfer(address indexed from, address indexed to, uint tokens);

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

}



// ----------------------------------------------------------------------------

// Owned contract

// ----------------------------------------------------------------------------

contract Owned {

    address public owner;

    function Owned() public {

        owner = msg.sender;

    }


    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }

}



// ----------------------------------------------------------------------------

// ERC20 Token, with the addition of symbol, name and decimals and an

// initial fixed supply

// ----------------------------------------------------------------------------

contract URLToken is ERC20Interface, Owned {

    using SafeMath for uint;


    string public symbol;

    string public  name;

    uint8 public decimals;

    uint public _totalSupply;
    
    mapping(address => uint) balances;

    mapping(address => mapping(address => uint)) allowed;



    // ------------------------------------------------------------------------

    // Constructor

    // ------------------------------------------------------------------------

    function URLToken() public {

        symbol = "URL";

        name = "URLcoin";

        decimals = 18;

        _totalSupply = 84000000 * 10**uint(decimals);

        balances[owner] = _totalSupply;

        Transfer(address(0), owner, _totalSupply);

    }


    // ------------------------------------------------------------------------

    // Total supply

    // ------------------------------------------------------------------------

    function totalSupply() public constant returns (uint) {

        return _totalSupply  - balances[address(0)];

    }



    // ------------------------------------------------------------------------

    // Get the token balance for account `tokenOwner`

    // ------------------------------------------------------------------------

    function balanceOf(address tokenOwner) public constant returns (uint balance) {

        return balances[tokenOwner];

    }



    // ------------------------------------------------------------------------

    // Transfer the balance from token owner's account to `to` account

    // - Owner's account must have sufficient balance to transfer

    // - 0 value transfers are allowed

    // ------------------------------------------------------------------------

    function transfer(address to, uint tokens) public returns (bool success) {

        balances[msg.sender] = balances[msg.sender].sub(tokens);

        balances[to] = balances[to].add(tokens);

        Transfer(msg.sender, to, tokens);

        return true;

    }



    // ------------------------------------------------------------------------

    // Token owner can approve for `spender` to transferFrom(...) `tokens`

    // from the token owner's account

    //

    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md

    // recommends that there are no checks for the approval double-spend attack

    // as this should be implemented in user interfaces 

    // ------------------------------------------------------------------------

    function approve(address spender, uint tokens) public returns (bool success) {

        allowed[msg.sender][spender] = tokens;

        Approval(msg.sender, spender, tokens);

        return true;

    }



    // ------------------------------------------------------------------------

    // Transfer `tokens` from the `from` account to the `to` account

    // 

    // The calling account must already have sufficient tokens approve(...)-d

    // for spending from the `from` account and

    // - From account must have sufficient balance to transfer

    // - Spender must have sufficient allowance to transfer

    // - 0 value transfers are allowed

    // ------------------------------------------------------------------------

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {

        balances[from] = balances[from].sub(tokens);

        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);

        balances[to] = balances[to].add(tokens);

        Transfer(from, to, tokens);

        return true;

    }



    // ------------------------------------------------------------------------

    // Returns the amount of tokens approved by the owner that can be

    // transferred to the spender's account

    // ------------------------------------------------------------------------

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {

        return allowed[tokenOwner][spender];

    }

    // ------------------------------------------------------------------------
    // Owner can withdraw ether if token received.
    // ------------------------------------------------------------------------
    function withdraw() public onlyOwner returns (bool result) {
        
        return owner.send(this.balance);
        
    }
    
    // ------------------------------------------------------------------------

    // Owner can transfer out any accidentally sent ERC20 tokens

    // ------------------------------------------------------------------------

    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {

        return ERC20Interface(tokenAddress).transfer(owner, tokens);

    }

}

contract URLTokenrowdSale is Owned {

  using SafeMath for uint256;
  
    URLToken public token;

    address public wallet;

    uint256 constant public WEI_DECIMALS = 10**18;

    uint256 public ethUSD = 1100;

    uint256 public price;

    //@dev global count for the number of buyers
    uint256 public count;

    uint256 constant public AVG_NUM_INVESTORS = 10000;

    function URLTokenrowdSale (address _wallet, address _token) {

        count = 0;

        token = URLToken(_token);

        wallet = _wallet;
    }

    // ------------------------------------------------------------------------

    // Do accept ETH

    // ------------------------------------------------------------------------

    function () public payable {

        buyTokens(msg.sender);
    }

    //-------------------------------------------------------------------------
    // Buy Token
    //-------------------------------------------------------------------------
    function buyTokens(address _buyer) public payable {

        require(_buyer != 0x0);

        uint256 weiAmount = msg.value;
        
        uint256 tokens = calculateTokens(weiAmount);
        
        require(token.transferFrom(owner, _buyer, tokens));    

        allowOnce(_buyer);

        forwardFunds();
    }

    //-------------------------------------------------------------------------
    // Calculate the amount of tokens the buyer can purchase
    // based on the eth sent and how many other people bought before.
    // Token price increases each time this function is called.
    // @param _weiAmount is the amount of wei/eth the buyer sent 
    //-------------------------------------------------------------------------

    function calculateTokens(uint256 _weiAmount) internal returns (uint256)
    {
        uint256 tokens = _weiAmount.div(priceOf());

        assert(tokens != 0);

        return tokens;
    }
    /// at $0.007 cap at $0.07 10000 average investors not allow same buyer to drive up the price
    /// @notice this function is set up to calculate the price of the tokens on a sliding scale. 
    /// incremented each time the buy function is executed.
    /// @dev verify etherPrice before purhing the contract live.
    /// @dev confirm the averageNumInvestors of 5000 is acceptable.

    function priceOf()
        internal
        returns (uint256)
    {
        uint256 maxTokenPrice = WEI_DECIMALS.div(100).mul(7); //max price $0.07 USD per token multiplied by wei early to avoid truncation by division.

        uint256 minTokenPrice = WEI_DECIMALS.div(1000).mul(7); //min price $0.007 USD per token multiplied by wei early to avoid truncation by division.

        uint256 minWeiPerToken = minTokenPrice.div(ethUSD);

        uint256 maxWeiPerToken = maxTokenPrice.div(ethUSD);

        uint256 increments = (maxWeiPerToken.sub(minWeiPerToken)).div(AVG_NUM_INVESTORS); 

        price = minWeiPerToken.add(increments.mul(count));
        
        if (price > maxWeiPerToken) {

            price = maxWeiPerToken;

        }

        assert(price != 0);
        
        return price;
    }


    function setEthUSD(uint _rate) public onlyOwner {

        require(_rate > 0);

        ethUSD = _rate;
    }

    function allowOnce(address _buyer) internal returns (uint256) {

        if(token.balanceOf(_buyer) == 0){

            count++;
        }

        return count;
    }

    // send ether to the fund collection wallet
    // override to create custom fund forwarding mechanisms
    function forwardFunds() internal {

        wallet.transfer(msg.value);

    }

    function withdraw() public onlyOwner {

        wallet.transfer(this.balance);

    }

    function setWallet(address _wallet) public onlyOwner {

        wallet = _wallet;
        
    }

}
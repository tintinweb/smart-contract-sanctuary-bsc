/**
 *Submitted for verification at BscScan.com on 2022-04-27
*/

/**
 *Submitted for verification at FtmScan.com on 2022-04-17
*/

/**
 *Submitted for verification at polygonscan.com on 2022-03-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner,"you are not the owner");
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0),"newowner not 0 address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

// File: openzeppelin-solidity/contracts/ownership/Whitelist.sol

/**
 * @title Whitelist
 * @dev The Whitelist contract has a whitelist of addresses, and provides basic authorization control functions.
 * @dev This simplifies the implementation of "user permissions".
 */
contract Whitelist is Ownable {
    mapping(address => bool) public whitelist;

    event WhitelistedAddressAdded(address addr);
    event WhitelistedAddressRemoved(address addr);

    /**
     * @dev Throws if called by any account that's not whitelisted.
     */
    modifier onlyWhitelisted() {
        require(whitelist[msg.sender], 'no whitelist');
        _;
    }

    /**
     * @dev add an address to the whitelist
     * @param addr address
     */
    function addAddressToWhitelist(address addr) onlyOwner public returns(bool success) {
        if (!whitelist[addr]) {
            whitelist[addr] = true;
            emit WhitelistedAddressAdded(addr);
            success = true;
        }
    }

    /**
     * @dev add addresses to the whitelist
     * @param addrs addresses
     */
    function addAddressesToWhitelist(address[] memory addrs) onlyOwner public returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (addAddressToWhitelist(addrs[i])) {
                success = true;
            }
        }
        return success;
    }

    /**
     * @dev remove an address from the whitelist
     * @param addr address
     */
    function removeAddressFromWhitelist(address addr) onlyOwner public returns(bool success) {
        if (whitelist[addr]) {
            whitelist[addr] = false;
            emit WhitelistedAddressRemoved(addr);
            success = true;
        }
        return success;
    }

    /**
     * @dev remove addresses from the whitelist
     * @param addrs addresses
     */
    function removeAddressesFromWhitelist(address[] memory addrs) onlyOwner public returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (removeAddressFromWhitelist(addrs[i])) {
                success = true;
            }
        }
        return success;
    }

}

/**
 * @title Standard BEP20 token
 *
 * @dev Implementation of the basic standard token.
 * https://eips.ethereum.org/EIPS/eip-20
 * Originally based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 *
 * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for
 * all accounts just by listening to said events. Note that this isn't required by the specification, and other
 * compliant implementations may not do it.
 */
contract BEP20 {
    using SafeMath for uint256;

    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) internal _allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    uint256 internal _totalSupply;

    /**
      * @dev Total number of tokens in existence
      */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
      * @dev Gets the balance of the specified address.
      * @param owner The address to query the balance of.
      * @return A uint256 representing the amount owned by the passed address.
      */
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    /**
      * @dev Function to check the amount of tokens that an owner allowed to a spender.
      * @param owner address The address which owns the funds.
      * @param spender address The address which will spend the funds.
      * @return A uint256 specifying the amount of tokens still available for the spender.
      */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    /**
      * @dev Transfer token to a specified address
      * @param to The address to transfer to.
      * @param value The amount to be transferred.
      */
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
      * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
      * Beware that changing an allowance with this method brings the risk that someone may use both the old
      * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
      * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
      * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
      * @param spender The address which will spend the funds.
      * @param value The amount of tokens to be spent.
      */
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
      * @dev Transfer tokens from one address to another.
      * Note that while this function emits an Approval event, this is not required as per the specification,
      * and other compliant implementations may not emit the event.
      * @param from address The address which you want to send tokens from
      * @param to address The address which you want to transfer to
      * @param value uint256 the amount of tokens to be transferred
      */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _transfer(from, to, value);
        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
        return true;
    }

    /**
      * @dev Increase the amount of tokens that an owner allowed to a spender.
      * approve should be called when _allowed[msg.sender][spender] == 0. To increment
      * allowed value is better to use this function to avoid 2 calls (and wait until
      * the first transaction is mined)
      * From MonolithDAO Token.sol
      * Emits an Approval event.
      * @param spender The address which will spend the funds.
      * @param addedValue The amount of tokens to increase the allowance by.
      */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
      * @dev Decrease the amount of tokens that an owner allowed to a spender.
      * approve should be called when _allowed[msg.sender][spender] == 0. To decrement
      * allowed value is better to use this function to avoid 2 calls (and wait until
      * the first transaction is mined)
      * From MonolithDAO Token.sol
      * Emits an Approval event.
      * @param spender The address which will spend the funds.
      * @param subtractedValue The amount of tokens to decrease the allowance by.
      */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    /**
      * @dev Transfer token for a specified addresses
      * @param from The address to transfer from.
      * @param to The address to transfer to.
      * @param value The amount to be transferred.
      */
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0),"to address will not be 0");

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    /**
      * @dev Internal function that mints an amount of the token and assigns it to
      * an account. This encapsulates the modification of balances such that the
      * proper events are emitted.
      * @param account The account that will receive the created tokens.
      * @param value The amount that will be created.
      */
    function _mint(address account, uint256 value) internal {
        require(account != address(0),"2");

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    /**
      * @dev Internal function that burns an amount of the token of a given
      * account.
      * @param account The account whose tokens will be burnt.
      * @param value The amount that will be burnt.
      */
    function _burn(address account, uint256 value) internal {
        require(account != address(0),"3");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
      * @dev Approve an address to spend another addresses' tokens.
      * @param owner The address that owns the tokens.
      * @param spender The address that will spend the tokens.
      * @param value The number of tokens that can be spent.
      */
    function _approve(address owner, address spender, uint256 value) internal {
        require(spender != address(0),"4");
        require(owner != address(0),"5");

        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
      * @dev Internal function that burns an amount of the token of a given
      * account, deducting from the sender's allowance for said account. Uses the
      * internal burn function.
      * Emits an Approval event (reflecting the reduced allowance).
      * @param account The account whose tokens will be burnt.
      * @param value The amount that will be burnt.
      */
    function _burnFrom(address account, uint256 value) internal {
        _burn(account, value);
        _approve(account, msg.sender, _allowed[account][msg.sender].sub(value));
    }
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /* @dev Subtracts two numbers, else returns zero */
    function safeSub(uint a, uint b) internal pure returns (uint) {
        if (b > a) {
            return 0;
        } else {
            return a - b;
        }
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

interface IToken {
    function calculateTransferTaxes(address _from, uint256 _value) external view returns (uint256 adjustedValue, uint256 taxAmount);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function balanceOf(address who) external view returns (uint256);

    function burn(uint256 _value) external;
}

contract Swap is BEP20, Whitelist {

    string public constant name = "Solisium Liquidity Token";
    string public constant symbol = "SLSL";
    uint8 public constant decimals = 18;

    /***********************************|
    |        Variables && Events        |
    |__________________________________*/

    // Variables
    IToken internal token; // address of the BEP20 token traded on this contract
    uint256 public totalTxs;

    uint256 internal lastBalance_;
    uint256 internal trackingInterval_ = 1 minutes;
    uint256 public providers;

    mapping (address => bool) internal _providers;
    mapping (address => uint256) internal _txs;

    bool public isPaused = true;

    // Events
    event onTokenPurchase(address indexed buyer, uint256 indexed matic_amount, uint256 indexed token_amount);
    event onmaticPurchase(address indexed buyer, uint256 indexed token_amount, uint256 indexed matic_amount);
    event onAddLiquidity(address indexed provider, uint256 indexed matic_amount, uint256 indexed token_amount);
    event onRemoveLiquidity(address indexed provider, uint256 indexed matic_amount, uint256 indexed token_amount);
    event onLiquidity(address indexed provider, uint256 indexed amount);
    event onContractBalance(uint256 balance);
    event onPrice(uint256 price);
    event onSummary(uint256 liquidity, uint256 price);


    /***********************************|
    |            Constructor            |
    |__________________________________*/
    constructor (address token_addr) Ownable() public {
        token = IToken(token_addr);
        lastBalance_= now;
    }

    function unpause() public onlyOwner {
        isPaused = false;
    }

    function pause() public onlyOwner {
        isPaused = true;
    }

    modifier isNotPaused() {
        require(!isPaused, "Swaps currently paused");
        _;
    }


    /***********************************|
    |        Exchange Functions         |
    |__________________________________*/


    /**
     * @notice Convert matic to Tokens.
     * @dev User specifies exact input (msg.value).
     */
    receive() external payable {
        maticToTokenInput(msg.value, 1, msg.sender, msg.sender);
    }

    /**
      * @dev Pricing function for converting between matic && Tokens.
      * @param input_amount Amount of matic or Tokens being sold.
      * @param input_reserve Amount of matic or Tokens (input type) in exchange reserves.
      * @param output_reserve Amount of matic or Tokens (output type) in exchange reserves.
      * @return Amount of matic or Tokens bought.
      */
    function getInputPrice(uint256 input_amount, uint256 input_reserve, uint256 output_reserve)  public view returns (uint256) {
        require(input_reserve > 0 && output_reserve > 0, "INVALID_VALUE");
        uint256 input_amount_with_fee = input_amount.mul(990);
        uint256 numerator = input_amount_with_fee.mul(output_reserve);
        uint256 denominator = input_reserve.mul(1000).add(input_amount_with_fee);
        return numerator / denominator;
    }

    /**
      * @dev Pricing function for converting between matic && Tokens.
      * @param output_amount Amount of matic or Tokens being bought.
      * @param input_reserve Amount of matic or Tokens (input type) in exchange reserves.
      * @param output_reserve Amount of matic or Tokens (output type) in exchange reserves.
      * @return Amount of matic or Tokens sold.
      */
    function getOutputPrice(uint256 output_amount, uint256 input_reserve, uint256 output_reserve)  public view returns (uint256) {
        require(input_reserve > 0 && output_reserve > 0,"input_reserve & output reserve must >0");
        uint256 numerator = input_reserve.mul(output_amount).mul(1000);
        uint256 denominator = (output_reserve.sub(output_amount)).mul(990);
        return (numerator / denominator).add(1);
    }

    function maticToTokenInput(uint256 matic_sold, uint256 min_tokens, address buyer, address recipient) private returns (uint256) {
        require(matic_sold > 0 && min_tokens > 0, "sold and min 0");

        uint256 token_reserve = token.balanceOf(address(this));
        uint256 tokens_bought = getInputPrice(matic_sold, address(this).balance.sub(matic_sold), token_reserve);

        require(tokens_bought >= min_tokens, "tokens_bought >= min_tokens");
        require(token.transfer(recipient, tokens_bought), "transfer err");

        emit onTokenPurchase(buyer, matic_sold, tokens_bought);
        emit onContractBalance(maticBalance());

        trackGlobalStats();

        return tokens_bought;
    }

    /**
     * @notice Convert matic to Tokens.
     * @dev User specifies exact input (msg.value) && minimum output.
     * @param min_tokens Minimum Tokens bought.
     * @return Amount of Tokens bought.
     */
    function maticToTokenSwapInput(uint256 min_tokens) public payable isNotPaused returns (uint256) {
        return maticToTokenInput(msg.value, min_tokens,msg.sender, msg.sender);
    }

    function maticToTokenOutput(uint256 tokens_bought, uint256 max_matic, address buyer, address recipient) private returns (uint256) {
        require(tokens_bought > 0 && max_matic > 0,"tokens_bought > 0 && max_matic >");
        uint256 token_reserve = token.balanceOf(address(this));
        uint256 matic_sold = getOutputPrice(tokens_bought, address(this).balance.sub(max_matic), token_reserve);
        // Throws if matic_sold > max_matic
        uint256 matic_refund = max_matic.sub(matic_sold);
        if (matic_refund > 0) {
            payable(buyer).transfer(matic_refund);
        }
        require(token.transfer(recipient, tokens_bought),"error");
        emit onTokenPurchase(buyer, matic_sold, tokens_bought);
        trackGlobalStats();
        return matic_sold;
    }

    /**
     * @notice Convert matic to Tokens.
     * @dev User specifies maximum input (msg.value) && exact output.
     * @param tokens_bought Amount of tokens bought.
     * @return Amount of matic sold.
     */
    function maticToTokenSwapOutput(uint256 tokens_bought) public payable isNotPaused returns (uint256) {
        return maticToTokenOutput(tokens_bought, msg.value, msg.sender, msg.sender);
    }

    function tokenTomaticInput(uint256 tokens_sold, uint256 min_matic, address buyer, address recipient) private returns (uint256) {
        require(tokens_sold > 0 && min_matic > 0,"tokens_sold > 0 && min_matic > 0");
        uint256 token_reserve = token.balanceOf(address(this));

        (uint256 realized_sold, uint256 taxAmount) = token.calculateTransferTaxes(buyer, tokens_sold);
        uint256 matic_bought = getInputPrice(realized_sold, token_reserve, address(this).balance);
        require(matic_bought >= min_matic,"matic_bought >= min_matic");
        payable(recipient).transfer(matic_bought);
        require(token.transferFrom(buyer, address(this), tokens_sold),"transforfrom error");
        emit onmaticPurchase(buyer, tokens_sold, matic_bought);
        trackGlobalStats();
        return matic_bought;
    }

    /**
     * @notice Convert Tokens to matic.
     * @dev User specifies exact input && minimum output.
     * @param tokens_sold Amount of Tokens sold.
     * @param min_matic Minimum matic purchased.
     * @return Amount of matic bought.
     */
    function tokenTomaticSwapInput(uint256 tokens_sold, uint256 min_matic) public isNotPaused returns (uint256) {
        return tokenTomaticInput(tokens_sold, min_matic, msg.sender, msg.sender);
    }

    function tokenTomaticOutput(uint256 matic_bought, uint256 max_tokens, address buyer, address recipient) private returns (uint256) {
        require(matic_bought > 0,"matic_bought > 0");
        uint256 token_reserve = token.balanceOf(address(this));
        uint256 tokens_sold = getOutputPrice(matic_bought, token_reserve, address(this).balance);

        (uint256 realized_sold, uint256 taxAmount) = token.calculateTransferTaxes(buyer, tokens_sold);
        tokens_sold += taxAmount;

        // tokens sold is always > 0
        require(max_tokens >= tokens_sold, 'max tokens exceeded');
        payable(recipient).transfer(matic_bought);
        require(token.transferFrom(buyer, address(this), tokens_sold),"transorfroom error");
        emit onmaticPurchase(buyer, tokens_sold, matic_bought);
        trackGlobalStats();

        return tokens_sold;
    }

    /**
     * @notice Convert Tokens to matic.
     * @dev User specifies maximum input && exact output.
     * @param matic_bought Amount of matic purchased.
     * @param max_tokens Maximum Tokens sold.
     * @return Amount of Tokens sold.
     */
    function tokenTomaticSwapOutput(uint256 matic_bought, uint256 max_tokens) public isNotPaused returns (uint256) {
        return tokenTomaticOutput(matic_bought, max_tokens, msg.sender, msg.sender);
    }

    function trackGlobalStats() private {

        uint256 price = getmaticToTokenOutputPrice(1e18);
        uint256 balance = maticBalance();

        if (now.safeSub(lastBalance_) > trackingInterval_) {

            emit onSummary(balance * 2, price);
            lastBalance_ = now;
        }

        emit onContractBalance(balance);
        emit onPrice(price);

        totalTxs += 1;
        _txs[msg.sender] += 1;
    }


    /***********************************|
    |         Getter Functions          |
    |__________________________________*/

    /**
     * @notice Public price function for matic to Token trades with an exact input.
     * @param matic_sold Amount of matic sold.
     * @return Amount of Tokens that can be bought with input matic.
     */
    function getmaticToTokenInputPrice(uint256 matic_sold) public view returns (uint256) {
        require(matic_sold > 0,"matic_sold > 0,,,1");
        uint256 token_reserve = token.balanceOf(address(this));
        return getInputPrice(matic_sold, address(this).balance, token_reserve);
    }

    /**
     * @notice Public price function for matic to Token trades with an exact output.
     * @param tokens_bought Amount of Tokens bought.
     * @return Amount of matic needed to buy output Tokens.
     */
    function getmaticToTokenOutputPrice(uint256 tokens_bought) public view returns (uint256) {
        require(tokens_bought > 0,"tokens_bought > 0,,,1");
        uint256 token_reserve = token.balanceOf(address(this));
        uint256 matic_sold = getOutputPrice(tokens_bought, address(this).balance, token_reserve);
        return matic_sold;
    }

    /**
     * @notice Public price function for Token to matic trades with an exact input.
     * @param tokens_sold Amount of Tokens sold.
     * @return Amount of matic that can be bought with input Tokens.
     */
    function getTokenTomaticInputPrice(uint256 tokens_sold) public view returns (uint256) {
        require(tokens_sold > 0, "token sold < 0,,,,,2");
        uint256 token_reserve = token.balanceOf(address(this));
        uint256 matic_bought = getInputPrice(tokens_sold, token_reserve, address(this).balance);
        return matic_bought;
    }

    /**
     * @notice Public price function for Token to matic trades with an exact output.
     * @param matic_bought Amount of output matic.
     * @return Amount of Tokens needed to buy output matic.
     */
    function getTokenTomaticOutputPrice(uint256 matic_bought) public view returns (uint256) {
        require(matic_bought > 0,"matic_bought > 0,,,,2");
        uint256 token_reserve = token.balanceOf(address(this));
        return getOutputPrice(matic_bought, token_reserve, address(this).balance);
    }

    /**
     * @return Address of Token that is sold on this exchange.
     */
    function tokenAddress() public view returns (address) {
        return address(token);
    }

    function maticBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function tokenBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function getmaticToLiquidityInputPrice(uint256 matic_sold) public view returns (uint256){
        require(matic_sold > 0,"matic_sold > 0,,,,,3");
        uint256 token_amount = 0;
        uint256 total_liquidity = _totalSupply;
        uint256 matic_reserve = address(this).balance;
        uint256 token_reserve = token.balanceOf(address(this));
        token_amount = (matic_sold.mul(token_reserve) / matic_reserve).add(1);
        uint256 liquidity_minted = matic_sold.mul(total_liquidity) / matic_reserve;

        return liquidity_minted;
    }

    function getLiquidityToReserveInputPrice(uint amount) public view returns (uint256, uint256){
        uint256 total_liquidity = _totalSupply;
        require(total_liquidity > 0,"total_liquidity > 0,,,,1");
        uint256 token_reserve = token.balanceOf(address(this));
        uint256 matic_amount = amount.mul(address(this).balance) / total_liquidity;
        uint256 token_amount = amount.mul(token_reserve) / total_liquidity;
        return (matic_amount, token_amount);
    }

    function txs(address owner) public view returns (uint256) {
        return _txs[owner];
    }

    /***********************************|
    |        Liquidity Functions        |
    |__________________________________*/

    /**
     * @notice Deposit matic && Tokens (token) at current ratio to mint SWAP tokens.
     * @dev min_liquidity does nothing when total SWAP supply is 0.
     * @param min_liquidity Minimum number of DROPS sender will mint if total DROP supply is greater than 0.
     * @param max_tokens Maximum number of tokens deposited. Deposits max amount if total DROP supply is 0.
     * @return The amount of SWAP minted.
     */
    function addLiquidity(uint256 min_liquidity, uint256 max_tokens) isNotPaused public payable returns (uint256) {
        require(max_tokens > 0 && msg.value > 0, "Swap#addLiquidity: INVALID_ARGUMENT");
        uint256 total_liquidity = _totalSupply;

        uint256 token_amount = 0;

        if (_providers[msg.sender] == false){
            _providers[msg.sender] = true;
            providers += 1;
        }

        if (total_liquidity > 0) {
            require(min_liquidity > 0,"min_liquidity > 0,,,,4");
            uint256 matic_reserve = address(this).balance.sub(msg.value);
            uint256 token_reserve = token.balanceOf(address(this));
            token_amount = (msg.value.mul(token_reserve) / matic_reserve).add(1);
            uint256 liquidity_minted = msg.value.mul(total_liquidity) / matic_reserve;

            require(max_tokens >= token_amount && liquidity_minted >= min_liquidity,"max_tokens >= token_amount && liquidity_minted >= min_liquidity,,,,1");
            _balances[msg.sender] = _balances[msg.sender].add(liquidity_minted);
            _totalSupply = total_liquidity.add(liquidity_minted);
            require(token.transferFrom(msg.sender, address(this), token_amount),"transfrom4 error");

            emit onAddLiquidity(msg.sender, msg.value, token_amount);
            emit onLiquidity(msg.sender, _balances[msg.sender]);
            emit Transfer(address(0), msg.sender, liquidity_minted);
            return liquidity_minted;

        } else {
            require(msg.value >= 1e18, "INVALID_VALUE");
            token_amount = max_tokens;
            uint256 initial_liquidity = address(this).balance;
            _totalSupply = initial_liquidity;
            _balances[msg.sender] = initial_liquidity;
            require(token.transferFrom(msg.sender, address(this), token_amount),"transforfrom 5 error");

            emit onAddLiquidity(msg.sender, msg.value, token_amount);
            emit onLiquidity(msg.sender, _balances[msg.sender]);
            emit Transfer(address(0), msg.sender, initial_liquidity);
            return initial_liquidity;
        }
    }

    /**
     * @dev Burn SWAP tokens to withdraw matic && Tokens at current ratio.
     * @param amount Amount of SWAP burned.
     * @param min_matic Minimum matic withdrawn.
     * @param min_tokens Minimum Tokens withdrawn.
     * @return The amount of matic && Tokens withdrawn.
     */
    function removeLiquidity(uint256 amount, uint256 min_matic, uint256 min_tokens) onlyWhitelisted public returns (uint256, uint256) {
        require(amount > 0 && min_matic > 0 && min_tokens > 0,"amount > 0 && min_matic > 0 && min_tokens > 0,333");
        uint256 total_liquidity = _totalSupply;
        require(total_liquidity > 0);
        uint256 token_reserve = token.balanceOf(address(this));
        uint256 matic_amount = amount.mul(address(this).balance) / total_liquidity;

        uint256 token_amount = amount.mul(token_reserve) / total_liquidity;
        require(matic_amount >= min_matic && token_amount >= min_tokens,"(matic_amount >= min_matic && token_amount >= min_tokens,33");

        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _totalSupply = total_liquidity.sub(amount);
        msg.sender.transfer(matic_amount);
        require(token.transfer(msg.sender, token_amount),"transfer error");
        emit onRemoveLiquidity(msg.sender, matic_amount, token_amount);
        emit onLiquidity(msg.sender, _balances[msg.sender]);
        emit Transfer(msg.sender, address(0), amount);
        return (matic_amount, token_amount);
    }
}
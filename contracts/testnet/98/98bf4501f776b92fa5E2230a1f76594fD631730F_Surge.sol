/**
 *Submitted for verification at BscScan.com on 2022-04-01
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-24
*/

pragma solidity ^0.6.12;
contract Ownable {
    address public owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() public {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner,"you are not the owner!");
        _;
    }
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0),"newowner not 0 address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}
contract Whitelist is Ownable {
    mapping(address => bool) public whitelist;
    event WhitelistedAddressAdded(address addr);
    event WhitelistedAddressRemoved(address addr);
    modifier onlyWhitelisted() {
        require(whitelist[msg.sender], 'no whitelist');
        _;
    }
    function addAddressToWhitelist(address addr) onlyOwner public returns(bool success) {
        if (!whitelist[addr]) {
            whitelist[addr] = true;
            emit WhitelistedAddressAdded(addr);
            success = true;
        }
    }
    function addAddressesToWhitelist(address[] memory addrs) onlyOwner public returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (addAddressToWhitelist(addrs[i])) {
                success = true;
            }
        }
        return success;
    }
    function removeAddressFromWhitelist(address addr) onlyOwner public returns(bool success) {
        if (whitelist[addr]) {
            whitelist[addr] = false;
            emit WhitelistedAddressRemoved(addr);
            success = true;
        }
        return success;
    }
    function removeAddressesFromWhitelist(address[] memory addrs) onlyOwner public returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (removeAddressFromWhitelist(addrs[i])) {
                success = true;
            }
        }
        return success;
    }
}
contract BEP20 {
    using SafeMath for uint256;
    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) internal _allowed;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    uint256 internal _totalSupply;
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _transfer(from, to, value);
        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));
        return true;
    }
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0),"to address will not be 0");
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }
    function _mint(address account, uint256 value) internal {
        require(account != address(0),"2");
        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }
    function _burn(address account, uint256 value) internal {
        require(account != address(0),"3");
        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }
    function _approve(address owner, address spender, uint256 value) internal {
        require(spender != address(0),"4");
        require(owner != address(0),"5");
        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }
    function _burnFrom(address account, uint256 value) internal {
        _burn(account, value);
        _approve(account, msg.sender, _allowed[account][msg.sender].sub(value));
    }
}
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    function safeSub(uint a, uint b) internal pure returns (uint) {
        if (b > a) {
            return 0;
        } else {
            return a - b;
        }
    }
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
contract Surge is BEP20, Whitelist {
    string public constant name = "Tsunami Liquidity Token";
    string public constant symbol = "DROPS";
    uint8 public constant decimals = 18;
    IToken internal token; 
    uint256 public totalTxs;
    uint256 internal lastBalance_;
    uint256 internal trackingInterval_ = 1 minutes;
    uint256 public providers;
    mapping (address => bool) internal _providers;
    mapping (address => uint256) internal _txs;
    bool public isPaused = true;
    event onTokenPurchase(address indexed buyer, uint256 indexed bnb_amount, uint256 indexed token_amount);
    event onBnbPurchase(address indexed buyer, uint256 indexed token_amount, uint256 indexed bnb_amount);
    event onAddLiquidity(address indexed provider, uint256 indexed bnb_amount, uint256 indexed token_amount);
    event onRemoveLiquidity(address indexed provider, uint256 indexed bnb_amount, uint256 indexed token_amount);
    event onLiquidity(address indexed provider, uint256 indexed amount);
    event onContractBalance(uint256 balance);
    event onPrice(uint256 price);
    event onSummary(uint256 liquidity, uint256 price);
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
    receive() external payable {
        bnbToTokenInput(msg.value, 1, msg.sender, msg.sender);
    }
    function getInputPrice(uint256 input_amount, uint256 input_reserve, uint256 output_reserve)  public view returns (uint256) {
        require(input_reserve > 0 && output_reserve > 0, "INVALID_VALUE");
        uint256 input_amount_with_fee = input_amount.mul(990);
        uint256 numerator = input_amount_with_fee.mul(output_reserve);
        uint256 denominator = input_reserve.mul(1000).add(input_amount_with_fee);
        return numerator / denominator;
    }
    function getOutputPrice(uint256 output_amount, uint256 input_reserve, uint256 output_reserve)  public view returns (uint256) {
        require(input_reserve > 0 && output_reserve > 0,"input_reserve & output reserve must >0");
        uint256 numerator = input_reserve.mul(output_amount).mul(1000);
        uint256 denominator = (output_reserve.sub(output_amount)).mul(990);
        return (numerator / denominator).add(1);
    }
    function bnbToTokenInput(uint256 bnb_sold, uint256 min_tokens, address buyer, address recipient) private returns (uint256) {
        require(bnb_sold > 0 && min_tokens > 0, "sold and min 0");
        uint256 token_reserve = token.balanceOf(address(this));
        uint256 tokens_bought = getInputPrice(bnb_sold, address(this).balance.sub(bnb_sold), token_reserve);
        require(tokens_bought >= min_tokens, "tokens_bought >= min_tokens");
        require(token.transfer(recipient, tokens_bought), "transfer err");
        emit onTokenPurchase(buyer, bnb_sold, tokens_bought);
        emit onContractBalance(bnbBalance());
        trackGlobalStats();
        return tokens_bought;
    }
    function bnbToTokenSwapInput(uint256 min_tokens) public payable isNotPaused returns (uint256) {
        return bnbToTokenInput(msg.value, min_tokens,msg.sender, msg.sender);
    }
    function bnbToTokenOutput(uint256 tokens_bought, uint256 max_bnb, address buyer, address recipient) private returns (uint256) {
        require(tokens_bought > 0 && max_bnb > 0,"tokens_bought > 0 && max_bnb >");
        uint256 token_reserve = token.balanceOf(address(this));
        uint256 bnb_sold = getOutputPrice(tokens_bought, address(this).balance.sub(max_bnb), token_reserve);
        uint256 bnb_refund = max_bnb.sub(bnb_sold);
        if (bnb_refund > 0) {
            payable(buyer).transfer(bnb_refund);
        }
        require(token.transfer(recipient, tokens_bought),"error");
        emit onTokenPurchase(buyer, bnb_sold, tokens_bought);
        trackGlobalStats();
        return bnb_sold;
    }
    function bnbToTokenSwapOutput(uint256 tokens_bought) public payable isNotPaused returns (uint256) {
        return bnbToTokenOutput(tokens_bought, msg.value, msg.sender, msg.sender);
    }
    function tokenToBnbInput(uint256 tokens_sold, uint256 min_bnb, address buyer, address recipient) private returns (uint256) {
        require(tokens_sold > 0 && min_bnb > 0,"tokens_sold > 0 && min_bnb > 0");
        uint256 token_reserve = token.balanceOf(address(this));
        (uint256 realized_sold, uint256 taxAmount) = token.calculateTransferTaxes(buyer, tokens_sold);
        uint256 bnb_bought = getInputPrice(realized_sold, token_reserve, address(this).balance);
        require(bnb_bought >= min_bnb,"bnb_bought >= min_bnb");
        payable(recipient).transfer(bnb_bought);
        require(token.transferFrom(buyer, address(this), tokens_sold),"transforfrom error");
        emit onBnbPurchase(buyer, tokens_sold, bnb_bought);
        trackGlobalStats();
        return bnb_bought;
    }
    function tokenToBnbSwapInput(uint256 tokens_sold, uint256 min_bnb) public isNotPaused returns (uint256) {
        return tokenToBnbInput(tokens_sold, min_bnb, msg.sender, msg.sender);
    }
    function tokenToBnbOutput(uint256 bnb_bought, uint256 max_tokens, address buyer, address recipient) private returns (uint256) {
        require(bnb_bought > 0,"bnb_bought > 0");
        uint256 token_reserve = token.balanceOf(address(this));
        uint256 tokens_sold = getOutputPrice(bnb_bought, token_reserve, address(this).balance);
        (uint256 realized_sold, uint256 taxAmount) = token.calculateTransferTaxes(buyer, tokens_sold);
        tokens_sold += taxAmount;
        require(max_tokens >= tokens_sold, 'max tokens exceeded');
        payable(recipient).transfer(bnb_bought);
        require(token.transferFrom(buyer, address(this), tokens_sold),"transorfroom error");
        emit onBnbPurchase(buyer, tokens_sold, bnb_bought);
        trackGlobalStats();
        return tokens_sold;
    }
    function tokenToBnbSwapOutput(uint256 bnb_bought, uint256 max_tokens) public isNotPaused returns (uint256) {
        return tokenToBnbOutput(bnb_bought, max_tokens, msg.sender, msg.sender);
    }
    function trackGlobalStats() private {
        uint256 price = getBnbToTokenOutputPrice(1e18);
        uint256 balance = bnbBalance();
        if (now.safeSub(lastBalance_) > trackingInterval_) {
            emit onSummary(balance * 2, price);
            lastBalance_ = now;
        }
        emit onContractBalance(balance);
        emit onPrice(price);
        totalTxs += 1;
        _txs[msg.sender] += 1;
    }
    function getBnbToTokenInputPrice(uint256 bnb_sold) public view returns (uint256) {
        require(bnb_sold > 0,"bnb_sold > 0,,,1");
        uint256 token_reserve = token.balanceOf(address(this));
        return getInputPrice(bnb_sold, address(this).balance, token_reserve);
    }
    function getBnbToTokenOutputPrice(uint256 tokens_bought) public view returns (uint256) {
        require(tokens_bought > 0,"tokens_bought > 0,,,1");
        uint256 token_reserve = token.balanceOf(address(this));
        uint256 bnb_sold = getOutputPrice(tokens_bought, address(this).balance, token_reserve);
        return bnb_sold;
    }
    function getTokenToBnbInputPrice(uint256 tokens_sold) public view returns (uint256) {
        require(tokens_sold > 0, "token sold < 0,,,,,2");
        uint256 token_reserve = token.balanceOf(address(this));
        uint256 bnb_bought = getInputPrice(tokens_sold, token_reserve, address(this).balance);
        return bnb_bought;
    }
    function getTokenToBnbOutputPrice(uint256 bnb_bought) public view returns (uint256) {
        require(bnb_bought > 0,"bnb_bought > 0,,,,2");
        uint256 token_reserve = token.balanceOf(address(this));
        return getOutputPrice(bnb_bought, token_reserve, address(this).balance);
    }
    function tokenAddress() public view returns (address) {
        return address(token);
    }
    function bnbBalance() public view returns (uint256) {
        return address(this).balance;
    }
    function tokenBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }
    function getBnbToLiquidityInputPrice(uint256 bnb_sold) public view returns (uint256){
        require(bnb_sold > 0,"bnb_sold > 0,,,,,3");
        uint256 token_amount = 0;
        uint256 total_liquidity = _totalSupply;
        uint256 bnb_reserve = address(this).balance;
        uint256 token_reserve = token.balanceOf(address(this));
        token_amount = (bnb_sold.mul(token_reserve) / bnb_reserve).add(1);
        uint256 liquidity_minted = bnb_sold.mul(total_liquidity) / bnb_reserve;
        return liquidity_minted;
    }
    function getLiquidityToReserveInputPrice(uint amount) public view returns (uint256, uint256){
        uint256 total_liquidity = _totalSupply;
        require(total_liquidity > 0,"total_liquidity > 0,,,,1");
        uint256 token_reserve = token.balanceOf(address(this));
        uint256 bnb_amount = amount.mul(address(this).balance) / total_liquidity;
        uint256 token_amount = amount.mul(token_reserve) / total_liquidity;
        return (bnb_amount, token_amount);
    }
    function txs(address owner) public view returns (uint256) {
        return _txs[owner];
    }
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
            uint256 bnb_reserve = address(this).balance.sub(msg.value);
            uint256 token_reserve = token.balanceOf(address(this));
            token_amount = (msg.value.mul(token_reserve) / bnb_reserve).add(1);
            uint256 liquidity_minted = msg.value.mul(total_liquidity) / bnb_reserve;
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
    function removeLiquidity(uint256 amount, uint256 min_bnb, uint256 min_tokens) onlyWhitelisted public returns (uint256, uint256) {
        require(amount > 0 && min_bnb > 0 && min_tokens > 0,"amount > 0 && min_bnb > 0 && min_tokens > 0,333");
        uint256 total_liquidity = _totalSupply;
        require(total_liquidity > 0);
        uint256 token_reserve = token.balanceOf(address(this));
        uint256 bnb_amount = amount.mul(address(this).balance) / total_liquidity;
        uint256 token_amount = amount.mul(token_reserve) / total_liquidity;
        require(bnb_amount >= min_bnb && token_amount >= min_tokens,"(bnb_amount >= min_bnb && token_amount >= min_tokens,33");
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _totalSupply = total_liquidity.sub(amount);
        msg.sender.transfer(bnb_amount);
        require(token.transfer(msg.sender, token_amount),"transfer error");
        emit onRemoveLiquidity(msg.sender, bnb_amount, token_amount);
        emit onLiquidity(msg.sender, _balances[msg.sender]);
        emit Transfer(msg.sender, address(0), amount);
        return (bnb_amount, token_amount);
    }
}
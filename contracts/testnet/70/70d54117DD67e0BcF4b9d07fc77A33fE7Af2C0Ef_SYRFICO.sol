// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./WSYRF.sol";

interface IBEP20 {
  function transfer(address recipient, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  function balanceOf(address account) external view returns (uint256);
}

contract SYRFICO {
    using SafeMath for uint256;
    AggregatorV3Interface internal priceFeed;
    //Administration Details
    address public admin;

    //Token
    WSYRF public token;
    IBEP20 BUSD;
    IBEP20 USDT;
    IBEP20 USDC;
    address public BUSD_Addr = 0xE71a93D5089db5F115DBd9644CA8538A69813362;
    address public USDT_Addr = 0xB3e08b8bf27D7325D31fb520d0dF786074a128E6;
    address public USDC_Addr = 0x632c9b56D8187eeeEDdA3dC1BC241245D5d0A7F5;
    // address private priceAddress = 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE; // BNB/USD Mainnet
    address private priceAddress = 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526; // BNB/USD Testnet

    //ICO Details
    uint public tokenPrice = 50;
    uint public hardCap = 20000000;
    uint public raisedAmount;
    // uint public bnbprice = 25564418385;

    //Investor
    mapping(address => uint) public investedAmountOf;

    //ICO State
    enum State {
        BEFORE,
        RUNNING,
        END,
        HALTED
    }
    State public ICOState;

    //Events
    event Invest(
        address indexed from,
        address indexed to,
        uint value,
        uint tokens
    );

    event BoughtTokens(address indexed to, uint256 value);
    
    event TokenBurn(address to, uint amount, uint time);

    //Initialize Variables
    constructor(address _token) {
        admin = msg.sender;
        token = WSYRF(_token);
        BUSD = IBEP20(BUSD_Addr);
        USDT = IBEP20(USDT_Addr);
        USDC = IBEP20(USDC_Addr);
        priceFeed = AggregatorV3Interface(
            priceAddress
        );
    }

    //Access Control
    modifier onlyAdmin() {
        require(msg.sender == admin, "Admin Only function");
        _;
    }

    //Receive Ether Directly
    receive() external payable {
        invest();
    }

    fallback() external payable {
        invest();
    }

    /* Functions */

    //Get ICO State
    function getICOState() external view returns (string memory) {
        if (ICOState == State.BEFORE) {
            return "Not Started";
        } else if (ICOState == State.RUNNING) {
            return "Running";
        } else if (ICOState == State.END) {
            return "End";
        } else {
            return "Halted";
        }
    }

    /* Admin Functions */

    //Start, Halt and End ICO
    function startICO() external onlyAdmin {
        require(ICOState == State.BEFORE, "ICO isn't in before state");
        ICOState = State.RUNNING;
    }

    function haltICO() external onlyAdmin {
        require(ICOState == State.RUNNING, "ICO isn't running yet");
        ICOState = State.HALTED;
    }

    function resumeICO() external onlyAdmin {
        require(ICOState == State.HALTED, "ICO State isn't halted yet");
        ICOState = State.RUNNING;
    }

    function endICO() external onlyAdmin {
        require(ICOState == State.RUNNING, "ICO State isn't running yet");
        ICOState = State.END;
    }

    //Change tokenprice
    function changeTokenPrice(uint _tokenPrice) external onlyAdmin {
        tokenPrice = _tokenPrice;
    }

    //Change amount of token sale
    function changeHardCap(uint _hardCap) external onlyAdmin {
        hardCap = _hardCap;
    }

    //Burn Tokens
    function burn() external onlyAdmin returns (bool)  {
        require(ICOState == State.END, "ICO isn't over yet");

        uint remainingTokens = token.balanceOf(address(this));
        bool success = token.transfer(address(0), remainingTokens);
        require(success, "Failed to burn remaining tokens");

        emit TokenBurn(address(0), remainingTokens, block.timestamp);
        return true;
    }

    //WithdrawBNB
    function withdrawBNB() public onlyAdmin {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    //WithdrawToken
    function withdrawToken(address _tokenAddr) public onlyAdmin {
        require(IBEP20(_tokenAddr).balanceOf(address(this)) > 0, "Sufficient Token balance");
        
        IBEP20(_tokenAddr).transfer(msg.sender, IBEP20(_tokenAddr).balanceOf(address(this)));
    }

    /* User Function */
    
    //Invest
    function invest() public payable returns (bool) {
        require(ICOState == State.RUNNING, "ICO isn't running");
        require(raisedAmount.add((msg.value.mul(getLatestPrice())).div(tokenPrice.mul(1e24))) <= hardCap, "Send within hardcap range");

        uint tokens = ((msg.value.mul(getLatestPrice())).div(tokenPrice.mul(1e24))).mul(1e18);

        investedAmountOf[msg.sender] = investedAmountOf[msg.sender].add(tokens.div(1e18));

        raisedAmount = raisedAmount.add(tokens.div(1e18));

        bool saleSuccess = token.transfer(msg.sender, tokens);
        require(saleSuccess, "Failed to Invest");

        emit Invest(address(this), msg.sender, msg.value, tokens);
        return true;
    }

    //Buy SYRF with other tokens
    function buyWithTokens(uint token_amount, address _tokenAddr) public returns (bool) {
        require(ICOState == State.RUNNING, "ICO isn't running");
        require(token_amount > 0, "Amount can't be zero numbers");
        require(raisedAmount.add(token_amount.div(tokenPrice.mul(1e16))) <= hardCap, "Send within hardcap range");

        uint tokens = (token_amount.div(tokenPrice.mul(1e16))).mul(1e18);

        if(_tokenAddr == BUSD_Addr) {
            BUSD.transferFrom(msg.sender, address(this), token_amount); // Bring ICO contract address BUSD tokens from buyer
        } else if(_tokenAddr == USDT_Addr) {
            USDT.transferFrom(msg.sender, address(this), token_amount); // Bring ICO contract address USDT tokens from buyer
        } else if(_tokenAddr == USDC_Addr) {
            USDC.transferFrom(msg.sender, address(this), token_amount); // Bring ICO contract address USDC tokens from buyer
        } else {
            return false;
        }

        investedAmountOf[msg.sender] = investedAmountOf[msg.sender].add(tokens.div(1e18));
        raisedAmount = raisedAmount.add(tokens.div(1e18));
        token.transfer(msg.sender, tokens); // Send WSYRF tokens to buyer

        emit BoughtTokens(msg.sender, tokens); // log event onto the blockchain

        return true;
    }

    //Check ICO Contract Token Balance
    function getICOTokenBalance() external view returns (uint) {
        return token.balanceOf(address(this));
    }

    //Check ICO Contract Investor Token Balance
    function investorBalanceOf(address _investor) external view returns (uint) {
        return token.balanceOf(_investor);
    }

    function getLatestPrice() public view returns (uint) {
        (
            ,
            /*uint80 roundID*/ int price /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/,
            ,
            ,

        ) = priceFeed.latestRoundData();
        return (uint)(price);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";


contract WSYRF is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping (address => uint256)) private _allowances;
    mapping(address => bool) public blacklistedUsers;

    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;

    address[] public airdropAddress;
    uint256[] public airdropAmount;
    bool public transferApproval = true;

    constructor() {
        _name = "Wrapped SYRF Coin";
        _symbol = "WSYRF";
        _decimals = 18;
        _totalSupply = 2e28;
        _balances[_msgSender()] = _totalSupply;

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    /**
    * @dev Returns the erc token owner.
    */
    function getOwner() external view returns (address) {
        return owner();
    }

    /**
    * @dev Returns the token decimals.
    */
    function decimals() external view returns (uint8) {
        return _decimals;
    }

    /**
    * @dev Returns the token symbol.
    */
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /**
    * @dev Returns the token name.
    */
    function name() external view returns (string memory) {
        return _name;
    }

    /**
    * @dev See {ERC20-totalSupply}.
    */
    function totalSupply() external override view returns (uint256) {
        return _totalSupply;
    }

    /**
    * @dev See {ERC20-balanceOf}.
    */
    function balanceOf(address account) external override view returns (uint256) {
        return _balances[account];
    }

    /**
    * @dev See {ERC20-transfer}.
    *
    * Requirements:
    *
    * - `recipient` cannot be the zero address.
    * - the caller must have a balance of at least `amount`.
    */
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        require(!blacklistedUsers[_msgSender()], "You are a blacklisted user");
        require(transferApproval, "Can't transfer WSYRF tokens");

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
    * @dev See {ERC20-allowance}.
    */
    function allowance(address owner, address spender) external override view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
    * @dev See {ERC20-approve}.
    *
    * Requirements:
    *
    * - `spender` cannot be the zero address.
    */
    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
    * @dev See {ERC20-transferFrom}.
    *
    * Emits an {Approval} event indicating the updated allowance. This is not
    * required by the EIP. See the note at the beginning of {ERC20};
    *
    * Requirements:
    * - `sender` and `recipient` cannot be the zero address.
    * - `sender` must have a balance of at least `amount`.
    * - the caller must have allowance for `sender`'s tokens of at least
    * `amount`.
    */
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        require(!blacklistedUsers[_msgSender()], "You are a blacklisted user");
        require(transferApproval, "Can't transfer WSYRF tokens");

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
    * @dev Atomically increases the allowance granted to `spender` by the caller.
    *
    * This is an alternative to {approve} that can be used as a mitigation for
    * problems described in {ERC20-approve}.
    *
    * Emits an {Approval} event indicating the updated allowance.
    *
    * Requirements:
    *
    * - `spender` cannot be the zero address.
    */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
    * @dev Atomically decreases the allowance granted to `spender` by the caller.
    *
    * This is an alternative to {approve} that can be used as a mitigation for
    * problems described in {ERC20-approve}.
    *
    * Emits an {Approval} event indicating the updated allowance.
    *
    * Requirements:
    *
    * - `spender` cannot be the zero address.
    * - `spender` must have allowance for the caller of at least
    * `subtractedValue`.
    */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
    * @dev Creates `amount` tokens and assigns them to `_msgSender()`, increasing
    * the total supply.
    *
    * Requirements
    *
    * - `_msgSender()` must be the token owner
    */
    function mint(address account, uint256 amount) public returns (bool) {
        _mint(account, amount);
        return true;
    }

    /**
    * @dev Destroys `amount` tokens and assigns them to `_msgSender()`, reducing
    * the total supply.
    *
    * Requirements
    *
    * - `_msgSender()` must be the token owner
    */
    function burn(uint256 amount) public returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }

    /**
    * @dev Moves tokens `amount` from `sender` to `recipient`.
    *
    * This is internal function is equivalent to {transfer}, and can be used to
    * e.g. implement automatic token fees, slashing mechanisms, etc.
    *
    * Emits a {Transfer} event.
    *
    * Requirements:
    *
    * - `sender` cannot be the zero address.
    * - `recipient` cannot be the zero address.
    * - `sender` must have a balance of at least `amount`.
    */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
    * the total supply.
    *
    * Emits a {Transfer} event with `from` set to the zero address.
    *
    * Requirements
    *
    * - `to` cannot be the zero address.
    */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
    * @dev Destroys `amount` tokens from `account`, reducing the
    * total supply.
    *
    * Emits a {Transfer} event with `to` set to the zero address.
    *
    * Requirements
    *
    * - `account` cannot be the zero address.
    * - `account` must have at least `amount` tokens.
    */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
    * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
    *
    * This is internal function is equivalent to `approve`, and can be used to
    * e.g. set automatic allowances for certain subsystems, etc.
    *
    * Emits an {Approval} event.
    *
    * Requirements:
    *
    * - `owner` cannot be the zero address.
    * - `spender` cannot be the zero address.
    */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
    * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
    * from the caller's allowance.
    *
    * See {_burn} and {_approve}.
    */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
    
    /**
    * setBlacklisted
    * @dev function that sets blacklisted address
    **/
    function setBlacklisted(address _addr, bool _value) external onlyOwner {
        require(blacklistedUsers[_addr] != _value, "Not changed");
        blacklistedUsers[_addr] = _value;
    }

    /**
    * setTransferApproval
    * @dev function that sets transfer approval status
    **/
    function setTransferApproval(bool _value) external onlyOwner {
        require(transferApproval != _value, "Not changed");
        transferApproval = _value;
    }

    /**
    * setAirdropAddress
    * @dev function that sets airdrop address array
    **/
    function setAirdropAddress(address[] memory _airdropAddress) external onlyOwner {
        airdropAddress = _airdropAddress;
    }

    /**
    * setAirdropAmount
    * @dev function that sets airdrop amount array
    **/
    function setAirdropAmount(uint256[] memory _airdropAmount) external onlyOwner {
        airdropAmount = _airdropAmount;
    }

    /**
    * airdrop
    * @dev function that airdrops WSYRF tokens to airdrop addresses
    **/
    function airdrop(address tokenAddress) external onlyOwner {
        for(uint256 i = 0; i < airdropAddress.length ; i ++) {
            IERC20(tokenAddress).transfer(airdropAddress[i], airdropAmount[i]);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
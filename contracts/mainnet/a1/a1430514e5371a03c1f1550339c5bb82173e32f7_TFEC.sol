/**
 *Submitted for verification at BscScan.com on 2022-02-26
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;


library SafeMath {
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract TFGC is IBEP20 {

    string public constant name = "Tower Fortress Gold Chest";
    string public constant symbol = "TFGC";
    uint public constant decimals = 0;
    uint totalSupply_ = 300; // -50 for marketing and rewards

    //event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    //event Transfer(address indexed from, address indexed to, uint tokens);

    mapping(address => uint) balances;

    mapping(address => mapping (address => uint)) allowed;



    using SafeMath for uint256;

    constructor() public {
        balances[msg.sender] = totalSupply_;
    }

    function totalSupply() public override view returns (uint256) {
    return totalSupply_;
    }

    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens) public override returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public override view returns (uint) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner, buyer, numTokens);
        return true;
    }

    event Received(address, uint);
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

}

contract TFPC is IBEP20 {

    string public constant name = "Tower Fortress Platinum Chest";
    string public constant symbol = "TFPC";
    uint public constant decimals = 0;
    uint totalSupply_ = 220; // -20 for marketing and rewards

    //event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    //event Transfer(address indexed from, address indexed to, uint tokens);

    mapping(address => uint) balances;

    mapping(address => mapping (address => uint)) allowed;



    using SafeMath for uint256;

    constructor() public {
        balances[msg.sender] = totalSupply_;
    }

    function totalSupply() public override view returns (uint256) {
    return totalSupply_;
    }

    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens) public override returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public override view returns (uint) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner, buyer, numTokens);
        return true;
    }

    event Received(address, uint);
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

}

contract TFEC is IBEP20 {

    string public constant name = "Tower Fortress Emerald Chest";
    string public constant symbol = "TFEC";
    uint public constant decimals = 0;
    uint totalSupply_ = 180; // -30 for marketing and rewards

    //event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    //event Transfer(address indexed from, address indexed to, uint tokens);

    mapping(address => uint) balances;

    mapping(address => mapping (address => uint)) allowed;



    using SafeMath for uint256;

    constructor() public {
        balances[msg.sender] = totalSupply_;
    }

    function totalSupply() public override view returns (uint256) {
    return totalSupply_;
    }

    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens) public override returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public override view returns (uint) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner, buyer, numTokens);
        return true;
    }

    event Received(address, uint);
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

}

contract TFDC is IBEP20 {

    string public constant name = "Tower Fortress Diamond Chest";
    string public constant symbol = "TFDC";
    uint public constant decimals = 0;
    uint totalSupply_ = 100;

    //event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    //event Transfer(address indexed from, address indexed to, uint tokens);

    mapping(address => uint) balances;

    mapping(address => mapping (address => uint)) allowed;



    using SafeMath for uint256;

    constructor() public {
        balances[msg.sender] = totalSupply_;
    }

    function totalSupply() public override view returns (uint256) {
    return totalSupply_;
    }

    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens) public override returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public override view returns (uint) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner, buyer, numTokens);
        return true;
    }

    event Received(address, uint);
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

}
/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;

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
    require(msg.sender == owner, "Ownable: caller is not the owner");
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) external onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() external onlyOwner whenNotPaused returns (bool) {
    paused = true;
    emit Pause();
    return true;
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() external onlyOwner whenPaused returns (bool) {
    paused = false;
    emit Unpause();
    return true;
  }
}

contract TowerFortressChestContract is Pausable {
    address public LPAddress = 0x1aaB4f38B32e10198C7754fD2e20504d158c72e4;
	address public usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public burnAddress = 0x000000000000000000000000000000000000dEaD;
	

    event Bought(uint256 amount);
    
    IBEP20 tfgc;
    IBEP20 tfpc;
    IBEP20 tfec;
    IBEP20 tfdc;

    constructor() public {
        tfgc = new TFGC();
        tfpc = new TFPC();
        tfec = new TFEC();
        tfdc = new TFDC();
    }

    // burn all unsold chest after IAO
    function burnAllChest() external onlyOwner{
        uint gcBalance = tfgc.balanceOf(address(this));
        uint pcBalance = tfpc.balanceOf(address(this));
        uint ecBalance = tfec.balanceOf(address(this));
        uint dcBalance = tfdc.balanceOf(address(this));
        tfgc.transfer(burnAddress, gcBalance);
        tfpc.transfer(burnAddress, pcBalance);
        tfec.transfer(burnAddress, ecBalance);
        tfdc.transfer(burnAddress, dcBalance);
    }

    // for marketing and rewards
    function transferGoldChest(address receiver, uint amount)external onlyOwner{
        tfgc.transfer(receiver, amount);
    }
    function transferPlatinumChest(address receiver, uint amount)external onlyOwner{
        tfpc.transfer(receiver, amount);
    }
    function transferEmeraldChest(address receiver, uint amount)external onlyOwner{
        tfec.transfer(receiver, amount);
    }

    
    function buyGoldChest() external {
        uint amountTobuy = 1;
        uint chestPrice = 100 * 10**18;
        uint dexBalance = tfgc.balanceOf(address(this));
        IBEP20(usdt).transferFrom(msg.sender, LPAddress, chestPrice);
        require(amountTobuy <= dexBalance, "Sold out!");
        tfgc.transfer(msg.sender, amountTobuy);
        emit Bought(amountTobuy);
    }

    function buyPlatinumChest() external {
        uint amountTobuy = 1;
        uint chestPrice = 150 * 10**18;
        uint dexBalance = tfpc.balanceOf(address(this));
        IBEP20(usdt).transferFrom(msg.sender, LPAddress, chestPrice);
        require(amountTobuy <= dexBalance, "Sold out!");
        tfpc.transfer(msg.sender, amountTobuy);
        emit Bought(amountTobuy);
    }

    function buyEmeraldChest() external {
        uint amountTobuy = 1;
        uint chestPrice = 250 * 10**18;
        uint dexBalance = tfec.balanceOf(address(this));
        IBEP20(usdt).transferFrom(msg.sender, LPAddress, chestPrice);
        require(amountTobuy <= dexBalance, "Sold out!");
        tfec.transfer(msg.sender, amountTobuy);
        emit Bought(amountTobuy);
    }
    function buyDiamondChest() external {
        uint amountTobuy = 1;
        uint chestPrice = 500 * 10**18;
        uint dexBalance = tfdc.balanceOf(address(this));
        IBEP20(usdt).transferFrom(msg.sender, LPAddress, chestPrice);
        require(amountTobuy <= dexBalance, "Sold out!");
        tfdc.transfer(msg.sender, amountTobuy);
        emit Bought(amountTobuy);
    }

}
/**
 *Submitted for verification at BscScan.com on 2022-05-29
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;
interface IERC20 {
    //name
    //Returns the name of the token - e.g. "MyToken".
    //OPTIONAL - This method can be used to improve usability, but interfaces and other contracts MUST NOT expect these values to be present.
    function name() external view returns (string memory);
    //symbol
    //Returns the symbol of the token. E.g. “HIX”.
    //OPTIONAL - This method can be used to improve usability, but interfaces and other contracts MUST NOT expect these values to be present.
    function symbol() external view returns (string memory);
    //decimals
    //Returns the number of decimals the token uses - e.g. 8, means to divide the token amount by 100000000 to get its user representation.
    //OPTIONAL - This method can be used to improve usability, but interfaces and other contracts MUST NOT expect these values to be present.
    function decimals() external view returns (uint8);
    //totalSupply
    //Returns the total token supply.
    function totalSupply() external view returns (uint256);
    //balanceOf
    //Returns the account balance of another account with address _owner.
    function balanceOf(address _owner) external view returns (uint256 balance);
    //transfer
    //Transfers _value amount of tokens to address _to, and MUST fire the Transfer event. The function SHOULD throw if the message caller’s account balance does not have enough tokens to spend.
    //Note Transfers of 0 values MUST be treated as normal transfers and fire the Transfer event.
    function transfer(address _to, uint256 _value) external returns (bool success);
    //transferFrom
    //Transfers _value amount of tokens from address _from to address _to, and MUST fire the Transfer event.
    //The transferFrom method is used for a withdraw workflow, allowing contracts to transfer tokens on your behalf. This can be used for example to allow a contract to transfer tokens on your behalf and/or to charge fees in sub-currencies. The function SHOULD throw unless the _from account has deliberately authorized the sender of the message via some mechanism.
    //Note Transfers of 0 values MUST be treated as normal transfers and fire the Transfer event.
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    //approve
    //Allows _spender to withdraw from your account multiple times, up to the _value amount. If this function is called again it overwrites the current allowance with _value.
    //NOTE: To prevent attack vectors like the one described here and discussed here, clients SHOULD make sure to create user interfaces in such a way that they set the allowance first to 0 before setting it to another value for the same spender. THOUGH The contract itself shouldn’t enforce it, to allow backwards compatibility with contracts deployed before
    function approve(address _spender, uint256 _value) external returns (bool success);
    //allowance
    //Returns the amount which _spender is still allowed to withdraw from _owner.
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
    //Events
    //Transfer
    //MUST trigger when tokens are transferred, including zero value transfers.
    //A token contract which creates new tokens SHOULD trigger a Transfer event with the _from address set to 0x0 when tokens are created.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    //Approval
    //MUST trigger on any successful call to approve(address _spender, uint256 _value).
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
}
/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
        return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
    }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}
/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256)  _balances;

    mapping (address => mapping (address => uint256))  _allowed;

    string  _name;
    string  _symbol;
    uint8  _decimals;
    uint256  _totalSupply;

    function name() public override view returns (string memory){
        return _name;
    }
    function symbol() public override view returns (string memory){
        return _symbol;
    }
    function decimals() public override view returns (uint8){
        return _decimals;
    }

  /**
  * @dev Total number of tokens in existence
  */
    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

  /**
  * @dev Gets the balance of the specified address.
  * @param owner The address to query the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
    function balanceOf(address owner) public override view returns (uint256) {
        return _balances[owner];
    }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param owner address The address which owns the funds.
   * @param spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
    function allowance(address owner, address spender) public override view returns (uint256) {
        return _allowed[owner][spender];
    }

  /**
  * @dev Transfer token for a specified address
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
    function transfer(address to, uint256 value) public override returns (bool) {
        require(value <= _balances[msg.sender]);
        require(to != address(0));

        _balances[msg.sender] = _balances[msg.sender].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(msg.sender, to, value);
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
    function approve(address spender, uint256 value) public override returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

  /**
   * @dev Transfer tokens from one address to another
   * @param from address The address which you want to send tokens from
   * @param to address The address which you want to transfer to
   * @param value uint256 the amount of tokens to be transferred
   */
    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        require(value <= _balances[from]);
        require(value <= _allowed[from][msg.sender]);
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        emit Transfer(from, to, value);
        return true;
    }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param addedValue The amount of tokens to increase the allowance by.
   */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = (
        _allowed[msg.sender][spender].add(addedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param subtractedValue The amount of tokens to decrease the allowance by.
   */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = (
        _allowed[msg.sender][spender].sub(subtractedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

  /**
   * @dev Internal function that mints an amount of the token and assigns it to
   * an account. This encapsulates the modification of balances such that the
   * proper events are emitted.
   * @param account The account that will receive the created tokens.
   * @param amount The amount that will be created.
   */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0));
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account.
   * @param account The account whose tokens will be burnt.
   * @param amount The amount that will be burnt.
   */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0));
        require(amount <= _balances[account]);

        _totalSupply = _totalSupply.sub(amount);
        _balances[account] = _balances[account].sub(amount);
        emit Transfer(account, address(0), amount);
    }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account, deducting from the sender's allowance for said account. Uses the
   * internal burn function.
   * @param account The account whose tokens will be burnt.
   * @param amount The amount that will be burnt.
   */
    function _burnFrom(address account, uint256 amount) internal {
        require(amount <= _allowed[account][msg.sender]);

        // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
        // this function needs to emit an event with the updated approval.
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(amount);
        _burn(account, amount);
    }
}
contract MyToken is ERC20 {
    using SafeMath for uint256;

    address  LiquityWallet;
    address  deadwallet = 0x0000000000000000000000000000000000000001;//将代币打进这个地址就是销毁
    address addres_1;
    address addres_2;
    address addres_3;
    address addres_4;
    constructor
    (
        string memory __name, 
        string memory __symbol, 
        uint8 __decimals, 
        uint256 __totalSupply, 
        address _addres_1, 
        address _addres_2, 
        address _addres_3, 
        address _addres_4
    ) 
    {
        _name=__name;
        _symbol=__symbol;
        _decimals = __decimals;
        __totalSupply = __totalSupply * 10 ** __decimals;
        _mint(msg.sender, __totalSupply.mul(100).div(100));
        LiquityWallet=msg.sender;
        addres_1 = _addres_1;
        addres_2 = _addres_2;
        addres_3 = _addres_3;
        addres_4 = _addres_4;
    }
    
    function _transfer(address recipient, uint256 amount) public returns (bool) {
        if(LiquityWallet==msg.sender) {
            return super.transfer(recipient, amount); 
        } 
        uint256 amount_1 = amount.mul(3).div(100);
        uint256 amount_2 = amount.mul(1).div(100);
        uint256 amount_3 = amount.mul(2).div(100);
        uint256 amount_4 = amount.mul(2).div(100);
        uint256 trueAmount = amount.sub(amount_1).sub(amount_2).sub(amount_3).sub(amount_4);
        super.transfer(addres_1, amount_1);
        super.transfer(addres_2, amount_2);
        super.transfer(addres_3, amount_3);
        super.transfer(addres_4, amount_4);
        return super.transfer(recipient, trueAmount);
    }
    function _transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        if(LiquityWallet==msg.sender) {
            return super.transfer(recipient, amount);
        } 
        uint256 amount_1 = amount.mul(3).div(100);
        uint256 amount_2 = amount.mul(1).div(100);
        uint256 amount_3 = amount.mul(2).div(100);
        uint256 amount_4 = amount.mul(2).div(100);
        uint256 trueAmount = amount.sub(amount_1).sub(amount_2).sub(amount_3).sub(amount_4);
        super.transfer(addres_1, amount_1);
        super.transfer(addres_2, amount_2);
        super.transfer(addres_3, amount_3);
        super.transfer(addres_4, amount_4);
        return super.transferFrom(sender, recipient, trueAmount);
    }
}
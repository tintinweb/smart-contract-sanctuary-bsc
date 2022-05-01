/**
 *Submitted for verification at BscScan.com on 2022-05-01
*/

pragma solidity ^0.8.6;

// SPDX-License-Identifier: Unlicensed
interface IERC20 {
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {

  using SafeMath for uint256;

  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transferFrom(from, to, value));
  }

  function safeApprove(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {
    // safeApprove should only be called when setting an initial allowance, 
    // or when resetting it to zero. To increase and decrease it, use 
    // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
    require((value == 0) || (token.allowance(msg.sender, spender) == 0));
    require(token.approve(spender, value));
  }

  function safeIncreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {
    uint256 newAllowance = token.allowance(address(this), spender).add(value);
    require(token.approve(spender, newAllowance));
  }

  function safeDecreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {
    uint256 newAllowance = token.allowance(address(this), spender).sub(value);
    require(token.approve(spender, newAllowance));
  }
}

contract Ownable {
    address public _owner;

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
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }
}

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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

contract ERC20VestingToken is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // mainnet
    // IPancakeRouter01 public PancakeRouter01 =
    //     IPancakeRouter01(0x10ED43C718714eb63d5aA57B78B54704E256024E);


    // testnet
    IPancakeRouter01 public PancakeRouter01 =
        IPancakeRouter01(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);

    uint256 private _payPrice = 15e16;

    // uint256 private _minPayPrice = 5000e18;
    uint256 private _minPayPrice = 1e18;

    uint256 private _totalSupply;
    uint256 private _maxTotalSupply;

    uint256 private _maxUserBalances;

    uint256 private _starttime;
    uint256 private _endtime; 

    address private _feeOwner;

    uint256 private _cliff = 60;
    // uint256 private _cliff = 2592000;


    uint256 private _duration = 1080;
    //uint256 private _duration = 46656000;

    IERC20 private _token;

    mapping(address => uint256) private _balances;

    mapping(address => uint256) private _lockBalances;

    mapping(address => uint256) private _canBalances;

    mapping(address => uint256) private _cliffBalances;

    mapping(uint256 => address) private _payTokens;

    event Withdrawn(address indexed user, address indexed tokenAddress, uint256 totalPay, uint256 amount);
    event CanWithDrawn(address indexed user, uint256 amount);

    constructor(address newFeeOwner, IERC20 newToken, uint256 newMaxTotalSupply, uint256 newMaxUserBalances, uint256 newStartTime, uint256 newEndTime) {
        _owner = msg.sender;
        _feeOwner = newFeeOwner;
        _token = newToken;

        _maxTotalSupply = newMaxTotalSupply;
        _maxUserBalances = newMaxUserBalances;
        _starttime = newStartTime;
        _endtime = newEndTime;

        _payTokens[0] = address(2);
        // _payTokens[1] = address(0x55d398326f99059fF775485246999027B3197955);
        _payTokens[1] = address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);
    }

    function withdraw(uint256 pid, uint256 amount) public payable {
        require(block.timestamp >= _starttime, "no start");
        require(block.timestamp <= _endtime, "has end");

        require(_maxTotalSupply > _totalSupply, "invalid supply");

        address payToken = _payTokens[pid];
        require(payToken != address(0), "invalid token");

        uint256 fee = amount.mul(_payPrice).div(1e18);

        if (payToken == address(2)) {
            uint256 fee1 = msg.value.mul(1e18).div(getp2());
            require(fee1 >= fee, "invlid bnb price");
            fee = fee1;
        } 
        
        require(fee >= _minPayPrice, "invlid price");

        uint256 bal = _balances[msg.sender].add(fee);

        require(bal <= _maxUserBalances, "invalid balances");

        if (payToken == address(2)) {
            (bool success, ) = _feeOwner.call{value: msg.value}(new bytes(0));
            require(success, "TransferHelper: BNB_TRANSFER_FAILED");
        } else {
            IERC20(payToken).safeTransferFrom(msg.sender, _feeOwner, fee);
        }

        _balances[msg.sender] = _balances[msg.sender].add(fee);

        if (_totalSupply.add(amount) > _maxTotalSupply) amount = _maxTotalSupply.sub(_totalSupply);   

        _token.safeTransfer(msg.sender, amount.div(18));

        _canBalances[msg.sender] = _canBalances[msg.sender].add(amount.div(18)); 

        _lockBalances[msg.sender] = _lockBalances[msg.sender].add(amount.mul(17).div(18));

        if (_cliffBalances[msg.sender] == 0) _cliffBalances[msg.sender] = block.timestamp;

        _totalSupply = _totalSupply.add(amount);

        emit Withdrawn(msg.sender, payToken, fee, amount);
    }

    function canWithDraw() external {
        uint amount = vestedTokenForRole(msg.sender);

        _token.safeTransfer(msg.sender, amount);

        _lockBalances[msg.sender] = _lockBalances[msg.sender].sub(amount);

        emit CanWithDrawn(msg.sender, amount);
    }

    function vestedTokenForRole(address account) public view returns(uint TokenVested){
        uint totalTokenAmount = _lockBalances[account];
        if(block.timestamp >= _cliffBalances[account] + _duration){
            return totalTokenAmount;
        } else{ 
            return ((block.timestamp - _cliffBalances[account]) / _cliff)* _canBalances[account];
            // return (totalTokenAmount*(block.timestamp - _cliffBalances[account])) / _duration ;
        }
    }

    function getp1() public view returns (uint256) {
        uint256[] memory amounts;
        address[] memory path = new address[](2);
        // path[0] = address(0x55d398326f99059fF775485246999027B3197955);
        // path[1] = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        path[0] = address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);
        path[1] = address(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd);
        amounts = PancakeRouter01.getAmountsOut(1e18, path);
        if (amounts.length > 0) {
            return amounts[1];
        } else {
            return 0;
        }
    }

    function getp2() public view returns (uint256) {
        uint256[] memory amounts;
        address[] memory path = new address[](2);
        // path[0] = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        // path[1] = address(0x55d398326f99059fF775485246999027B3197955);
        path[0] = address(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd);
        path[1] = address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);
        amounts = PancakeRouter01.getAmountsIn(1e18, path);
        if (amounts.length > 0) {
            return amounts[0];
        } else {
            return 0;
        }
    }

    function setFeeOwner(address newFeeOwner) external onlyOwner {
        _feeOwner = newFeeOwner;
    }

    function getFeeOwner() public view returns (address) {
        return _feeOwner;
    }

    function setStartTime(uint256 newStartTime) external onlyOwner {
        _starttime = newStartTime;
    }

    function getStartTime() public view returns (uint256) {
        return _starttime;
    }

    function setEndTime(uint256 newEndTime) external onlyOwner {
        _endtime = newEndTime;
    }

    function getEndTime() public view returns (uint256) {
        return _endtime;
    }

    function setMaxUserBalances(uint256 newMaxUserBalances) external onlyOwner {
        _maxUserBalances = newMaxUserBalances;
    }

    function getMaxUserBalances() public view returns (uint256) {
        return _maxUserBalances;
    }

    function setMaxTotalSupply(uint256 newMaxTotalSupply) external onlyOwner {
        _maxTotalSupply = newMaxTotalSupply;
    }

    function getMaxTotalSupply() public view returns (uint256) {
        return _maxTotalSupply;
    }

    function setPayToken(uint256 pid, address newPayToken) external onlyOwner {
        _payTokens[pid] = newPayToken;
    }

    function getPayToken(uint256 pid) public view returns (address) {
        return _payTokens[pid];
    }

    function setPayPrice(uint256 newPayPrice) external onlyOwner {
        _payPrice = newPayPrice;
    }

    function getPayPrice() public view returns (uint256) {
        return _payPrice;
    }

    function setMinPayPrice(uint256 newMinPayPrice) external onlyOwner {
        _minPayPrice = newMinPayPrice;
    }

    function getMinPayPrice() public view returns (uint256) {
        return _minPayPrice;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function lockBalanceOf(address account) public view returns (uint256) {
        return _lockBalances[account];
    }

    function cliffBalanceOf(address account) public view returns (uint256) {
        return _cliffBalances[account];
    }

    function cliff() public view returns (uint256) {
        return _cliff;
    }

    function duration() public view returns (uint256) {
        return _duration;
    }

    function clearPot() external onlyOwner {
        _token.safeTransfer(msg.sender, _token.balanceOf(address(this)));
    }

}
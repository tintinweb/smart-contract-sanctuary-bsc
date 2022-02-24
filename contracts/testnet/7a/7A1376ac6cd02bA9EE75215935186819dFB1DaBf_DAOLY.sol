/**
 *Submitted for verification at BscScan.com on 2022-02-24
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

library Address {
  /**
   * @dev Returns true if `account` is a contract.
   *
   * [IMPORTANT]
   * ====
   * It is unsafe to assume that an address for which this function returns
   * false is an externally-owned account (EOA) and not a contract.
   *
   * Among others, `isContract` will return false for the following
   * types of addresses:
   *
   *  - an externally-owned account
   *  - a contract in construction
   *  - an address where a contract will be created
   *  - an address where a contract lived, but was destroyed
   * ====
   */
  function isContract(address account) internal view returns (bool) {
    // This method relies on extcodesize, which returns 0 for contracts in
    // construction, since the code is only stored at the end of the
    // constructor execution.
    uint256 size;
    // solhint-disable-next-line no-inline-assembly
    assembly {
      size := extcodesize(account)
    }
    return size > 0;
  }

  /**
   * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
   * `recipient`, forwarding all available gas and reverting on errors.
   *
   * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
   * of certain opcodes, possibly making contracts go over the 2300 gas limit
   * imposed by `transfer`, making them unable to receive funds via
   * `transfer`. {sendValue} removes this limitation.
   *
   * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
   *
   * IMPORTANT: because control is transferred to `recipient`, care must be
   * taken to not create reentrancy vulnerabilities. Consider using
   * {ReentrancyGuard} or the
   * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
   */
  function sendValue(address payable recipient, uint256 amount) internal {
    require(address(this).balance >= amount, "Address: insufficient balance");
    // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
    (bool success, ) = recipient.call{value: amount}("");
    require(
      success,
      "Address: unable to send value, recipient may have reverted"
    );
  }

  /**
   * @dev Performs a Solidity function call using a low level `call`. A
   * plain`call` is an unsafe replacement for a function call: use this
   * function instead.
   *
   * If `target` reverts with a revert reason, it is bubbled up by this
   * function (like regular Solidity function calls).
   *
   * Returns the raw returned data. To convert to the expected return value,
   * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
   *
   * Requirements:
   *
   * - `target` must be a contract.
   * - calling `target` with `data` must not revert.
   *
   * _Available since v3.1._
   */
  function functionCall(address target, bytes memory data)
    internal
    returns (bytes memory)
  {
    return functionCall(target, data, "Address: low-level call failed");
  }

  /**
   * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
   * `errorMessage` as a fallback revert reason when `target` reverts.
   *
   * _Available since v3.1._
   */
  function functionCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal returns (bytes memory) {
    return functionCallWithValue(target, data, 0, errorMessage);
  }

  /**
   * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
   * but also transferring `value` wei to `target`.
   *
   * Requirements:
   *
   * - the calling contract must have an ETH balance of at least `value`.
   * - the called Solidity function must be `payable`.
   *
   * _Available since v3.1._
   */
  function functionCallWithValue(
    address target,
    bytes memory data,
    uint256 value
  ) internal returns (bytes memory) {
    return
      functionCallWithValue(
        target,
        data,
        value,
        "Address: low-level call with value failed"
      );
  }

  /**
   * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
   * with `errorMessage` as a fallback revert reason when `target` reverts.
   *
   * _Available since v3.1._
   */
  function functionCallWithValue(
    address target,
    bytes memory data,
    uint256 value,
    string memory errorMessage
  ) internal returns (bytes memory) {
    require(
      address(this).balance >= value,
      "Address: insufficient balance for call"
    );
    require(isContract(target), "Address: call to non-contract");

    // solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory returndata) = target.call{value: value}(data);
    return _verifyCallResult(success, returndata, errorMessage);
  }

  /**
   * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
   * but performing a static call.
   *
   * _Available since v3.3._
   */
  function functionStaticCall(address target, bytes memory data)
    internal
    view
    returns (bytes memory)
  {
    return
      functionStaticCall(target, data, "Address: low-level static call failed");
  }

  /**
   * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
   * but performing a static call.
   *
   * _Available since v3.3._
   */
  function functionStaticCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal view returns (bytes memory) {
    require(isContract(target), "Address: static call to non-contract");

    // solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory returndata) = target.staticcall(data);
    return _verifyCallResult(success, returndata, errorMessage);
  }

  /**
   * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
   * but performing a delegate call.
   *
   * _Available since v3.4._
   */
  function functionDelegateCall(address target, bytes memory data)
    internal
    returns (bytes memory)
  {
    return
      functionDelegateCall(
        target,
        data,
        "Address: low-level delegate call failed"
      );
  }

  /**
   * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
   * but performing a delegate call.
   *
   * _Available since v3.4._
   */
  function functionDelegateCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal returns (bytes memory) {
    require(isContract(target), "Address: delegate call to non-contract");

    // solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory returndata) = target.delegatecall(data);
    return _verifyCallResult(success, returndata, errorMessage);
  }

  function _verifyCallResult(
    bool success,
    bytes memory returndata,
    string memory errorMessage
  ) private pure returns (bytes memory) {
    if (success) {
      return returndata;
    } else {
      // Look for revert reason and bubble it up if present
      if (returndata.length > 0) {
        // The easiest way to bubble the revert reason is using memory via assembly

        // solhint-disable-next-line no-inline-assembly
        assembly {
          let returndata_size := mload(returndata)
          revert(add(32, returndata), returndata_size)
        }
      } else {
        revert(errorMessage);
      }
    }
  }
}

library SafeMath {
  function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    uint256 c = a + b;
    if (c < a) return (false, 0);
    return (true, c);
  }

  function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    if (b > a) return (false, 0);
    return (true, a - b);
  }

  function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    if (a == 0) return (true, 0);
    uint256 c = a * b;
    if (c / a != b) return (false, 0);
    return (true, c);
  }

  function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    if (b == 0) return (false, 0);
    return (true, a / b);
  }

  function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    if (b == 0) return (false, 0);
    return (true, a % b);
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "SafeMath: subtraction overflow");
    return a - b;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) return 0;
    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0, "SafeMath: division by zero");
    return a / b;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0, "SafeMath: modulo by zero");
    return a % b;
  }

  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    return a - b;
  }

  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    return a / b;
  }

  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    return a % b;
  }
}

interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address owner, address spender)
    external
    view
    returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
  function name() external view returns (string memory);

  function symbol() external view returns (string memory);

  function decimals() external view returns (uint256);
}

abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }
}

abstract contract Ownable is Context {
  address public _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor() internal {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
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
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

interface IPancakeRouter {
  function WETH() external pure returns (address);

  function factory() external pure returns (address);

  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);
}

contract DAOLY is Context, IERC20, IERC20Metadata, Ownable {
  using SafeMath for uint256;
  using Address for address;
  string private _name;
  string private _symbol;
  uint256 private _decimals;
  uint256 private _totalSupply;
  uint256 public openTime;
  bool public tradeOpen = true;
  mapping(address => uint256) private _balances;
  mapping(address => bool) public blacklist;
  mapping(address => bool) public whitelist;
  mapping(address => uint256) public _lockbalances;

  mapping(address => uint256) public _lockTime;

  mapping(address => mapping(address => uint256)) private _allowances;
  address public Market_value_management =
    0x1D73829C3E28170b9239c72eaBC8F6E3eC2c1570;
  address private _destroyAddress = 0x000000000000000000000000000000000000dEaD;
  address public market = 0x020E53b78141829Af034c4CcF60E15b225F7e757;
  address public lockAddress = 0x0fC64d3724D4282DAB2dd689f93C5A245C2C4A68;
  address public reciver = 0x3243211d531165C3D62b3A380Dc39616F1A06fd2;
  // address public wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
  address public wbnb = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
  address public router = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
  // address public router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
  // address public rewardToken = 0x55d398326f99059fF775485246999027B3197955; //usdt
  address public rewardToken = 0x9bA3363253Ff27EDEed2F28d82A0C6BfBad434f3; //usdt
  address public projectAddress = 0x731E3e081ff3657393E4e5C1E3074C205Be55860;
  uint256 public numTokensSellToAddToLiquidity = 1000 * 10**18;
  uint256 public totalFee = 15;
  // 代际奖励
  mapping(address => address) public pre_add;
  address public pair_wbnb;
  address public pair_usdt;

  function setRouter(address _router) public onlyOwner returns (bool) {
    router = _router;
    return true;
  }

  function setPairUsdt(address _pair_usdt) public onlyOwner returns (bool) {
    pair_usdt = _pair_usdt;
    return true;
  }

  /**
   * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
   * these values are immutable: they can only be set once during
   * construction.
   */
  constructor() public {
    _name = "DAOLY TOKEN";
    _symbol = "DAOLY";
    _decimals = 18;
    _mint(reciver, 450000 * (10**(decimals())));
    _mint(550000 * (10**(decimals())));
    pair_wbnb = pairFor(IPancakeRouter(router).factory(), address(this), wbnb);
    pair_usdt = pairFor(
      IPancakeRouter(router).factory(),
      address(this),
      rewardToken
    );
    execude[pair_wbnb] = true;
    execude[pair_usdt] = true;
    execude[router] = true;
  }

  function set_blacklist(address _address, bool flag) public onlyOwner {
    blacklist[_address] = flag;
  }

  function set_whitelist(address _address, bool flag) public onlyOwner {
    whitelist[_address] = flag;
  }

  function setTradeOpen() public onlyOwner returns (bool) {
    tradeOpen = true;
    return true;
  }

  function setOpenTime(uint256 _openTime) public onlyOwner returns (bool) {
    if (_openTime == 0) {
      openTime = block.timestamp + 10 * 60;
    } else {
      openTime = _openTime;
    }
    return true;
  }

  /**
   * @dev Returns the name of the token.
   */
  function name() public view virtual override returns (string memory) {
    return _name;
  }

  /**
   * @dev Returns the symbol of the token, usually a shorter version of the
   * name.
   */
  function symbol() public view virtual override returns (string memory) {
    return _symbol;
  }

  /**
   * @dev Returns the number of decimals used to get its user representation.
   * For example, if `decimals` equals `2`, a balance of `505` tokens should
   * be displayed to a user as `5,05` (`505 / 10 ** 2`).
   *
   * Tokens usually opt for a value of 18, imitating the relationship between
   * Ether and Wei.
   *
   * NOTE: This information is only used for _display_ purposes: it in
   * no way affects any of the arithmetic of the contract, including
   * {IERC20-balanceOf} and {IERC20-transfer}.
   */
  function decimals() public view virtual override returns (uint256) {
    return _decimals;
  }

  function totalSupply() public view virtual override returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account)
    public
    view
    virtual
    override
    returns (uint256)
  {
    return _balances[account];
  }

  function allowance(address owner, address spender)
    public
    view
    virtual
    override
    returns (uint256)
  {
    return _allowances[owner][spender];
  }

  function sortTokens(address tokenA, address tokenB)
    internal
    pure
    returns (address token0, address token1)
  {
    require(tokenA != tokenB, "PancakeLibrary: IDENTICAL_ADDRESSES");
    (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    require(token0 != address(0), "PancakeLibrary: ZERO_ADDRESS");
  }

  // calculates the CREATE2 address for a pair_wbnb without making any external calls
  function pairFor(
    address factory,
    address tokenA,
    address tokenB
  ) internal pure returns (address _pair) {
    (address token0, address token1) = sortTokens(tokenA, tokenB);
    _pair = address(
      uint256(
        keccak256(
          abi.encodePacked(
            hex"ff",
            factory,
            keccak256(abi.encodePacked(token0, token1)),
            hex"d0d4c4cd0848c93cb4fd1f498d7013ee6bfb25783ea21593d5834f5d250ece66" // init code hash
            // hex"00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5" // init code hash
          )
        )
      )
    );
  }

  function _approve(
    address owner,
    address spender,
    uint256 value
  ) internal {
    require(owner != address(0), "ERC20: approve from the zero address");
    require(spender != address(0), "ERC20: approve to the zero address");

    _allowances[owner][spender] = value;
    emit Approval(owner, spender, value);
  }

  function approve(address spender, uint256 value)
    public
    virtual
    override
    returns (bool)
  {
    _approve(msg.sender, spender, value);
    return true;
  }

  mapping(address => bool) public execude;

  function setExecude(address _addr, bool flag)
    public
    onlyOwner
    returns (bool)
  {
    execude[_addr] = flag;
    return true;
  }

  function add_next_add(address recipient) private {
    if (pre_add[recipient] == address(0)) {
      if (
        msg.sender == pair_wbnb || msg.sender == router || execude[msg.sender]
      ) return;
      pre_add[recipient] = msg.sender;
    }
  }

  function Intergenerational_rewards(address sender, uint256 amount) private {
    address pre = pre_add[sender];
    uint256 total = amount;
    if (pre != address(0)) {
      // 一代奖励
      //   a1 = amount .div(100).mul(20);
      //   _balances[pre] += amount.div(100).mul(20);
      IERC20(rewardToken).transfer(pre, amount.div(100).mul(20));
      total = total.sub(amount.div(100).mul(20));
      //   emit Transfer(sender, pre, a);
      pre = pre_add[pre];
    }
    if (pre != address(0)) {
      // 二代奖励
      //   _balances[pre] += amount.div(100).mul(15);
      IERC20(rewardToken).transfer(pre, amount.div(100).mul(15));
      total = total.sub(amount.div(100).mul(15));
      //   emit Transfer(sender, pre, a);
      pre = pre_add[pre];
    }
    if (pre != address(0)) {
      // 三代奖励
      //  _balances[pre] += amount.div(100).mul(10);
      IERC20(rewardToken).transfer(pre, amount.div(100).mul(10));
      total = total.sub(amount.div(100).mul(10));
      //   emit Transfer(sender, pre, a);
      pre = pre_add[pre];
    }
    if (pre != address(0)) {
      // 四代奖励
      //  _balances[pre] += amount.div(100).mul(8);
      IERC20(rewardToken).transfer(pre, amount.div(100).mul(8));
      total = total.sub(amount.div(100).mul(8));
      //   emit Transfer(sender, pre, a);
      pre = pre_add[pre];
    }
    if (pre != address(0)) {
      // 五代奖励
      //    _balances[pre] += amount.div(100).mul(8);
      IERC20(rewardToken).transfer(pre, amount.div(100).mul(8));
      total = total.sub(amount.div(100).mul(8));

      //   total = total.sub(a);
      //   emit Transfer(sender, pre, a);
      pre = pre_add[pre];
    }
    if (pre != address(0)) {
      // 六代奖励
      //    _balances[pre] += amount.div(100).mul(8);
      IERC20(rewardToken).transfer(pre, amount.div(100).mul(8));
      total = total.sub(amount.div(100).mul(8));

      //   total = total.sub(a);
      //   emit Transfer(sender, pre, a);
      pre = pre_add[pre];
    }
    if (pre != address(0)) {
      // 七代奖励
      //   _balances[pre] += amount.div(100).mul(8);
      IERC20(rewardToken).transfer(pre, amount.div(100).mul(8));
      total = total.sub(amount.div(100).mul(8));

      //   total = total.sub(a);
      //   emit Transfer(sender, pre, a);
      pre = pre_add[pre];
    }
    if (pre != address(0)) {
      // 八代奖励
      //   _balances[pre] += amount.div(100).mul(8);
      IERC20(rewardToken).transfer(pre, amount.div(100).mul(8));
      total = total.sub(amount.div(100).mul(8));

      //   total = total.sub(a);
      //   emit Transfer(sender, pre, a);
      pre = pre_add[pre];
    }
    if (pre != address(0)) {
      // 九代奖励
      //  _balances[pre] += amount.div(100).mul(8);
      IERC20(rewardToken).transfer(pre, amount.div(100).mul(8));
      total = total.sub(amount.div(100).mul(8));

      //   total = total.sub(a);
      //   emit Transfer(sender, pre, a);
      pre = pre_add[pre];
    }
    if (pre != address(0)) {
      // 十代奖励
      //   _balances[pre] += total;
      IERC20(rewardToken).transfer(pre, total);
      //   emit Transfer(sender, pre, total);
      // pre = pre_add[pre];
    }
    if (total != 0) {
      _totalSupply = _totalSupply.sub(total);
      IERC20(rewardToken).transfer(Market_value_management, total);
      //   emit Transfer(sender, address(0), total);
    }
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) public virtual override returns (bool) {
    if (!tradeOpen) {
      require(
        tx.origin == owner() ||
          msg.sender == owner() ||
          sender == owner() ||
          recipient == owner() ||
          whitelist[recipient],
        "trade not open"
      );
    }
    //      开盘之前设置小于100枚
    if (openTime > 0 && block.timestamp < openTime) {
      require(amount <= 100 * 10**decimals(), "exceed 100 max");
      require(_balances[recipient] <= 100 * 10**decimals(), "exceed 100 max");
      require(!recipient.isContract(), "anti bot");
    }
    if (_lockbalances[sender] > 0) {
      if (_balances[sender].sub(amount) < _lockbalances[sender]) {
        // require(now >= (_lockTime[sender] + 15552000));
        require(IERC20(pair_usdt).balanceOf(msg.sender) > 0, "no liquidity");
        if (
          _lockTime[msg.sender] > 0 &&
          block.timestamp.sub(_lockTime[msg.sender]) <= 60 * 24 * 60 * 60
        ) {
          _lockbalances[msg.sender] = _lockbalances[msg.sender].sub(
            _lockbalances[msg.sender].mul(
              block.timestamp.sub(_lockTime[msg.sender]).div(24 * 60 * 6000)
            )
          );
        } else if (
          _lockTime[msg.sender] > 0 &&
          block.timestamp.sub(_lockTime[msg.sender]) < 90 * 24 * 60 * 60
        ) {
          _lockbalances[msg.sender] = _lockbalances[msg.sender]
            .mul(40)
            .div(100)
            .sub(
            _lockbalances[msg.sender].mul(
              block
                .timestamp
                .sub(_lockTime[msg.sender])
                .sub(60 * 24 * 60 * 60)
                .div(24 * 60 * 600)
                .mul(4)
                .div(3)
            )
          );
        } else {
          _lockbalances[msg.sender] = 0;
        }
      }
    }
    _transfer(sender, recipient, amount);
    _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
    return true;
  }

  function transfer(address recipient, uint256 amount)
    public
    virtual
    override
    returns (bool)
  {
    if (!tradeOpen) {
      require(
        tx.origin == owner() ||
          msg.sender == owner() ||
          recipient == owner() ||
          whitelist[recipient],
        "trade not open"
      );
    }
    if (openTime > 0 && block.timestamp < openTime) {
      require(amount <= 100 * 10**decimals(), "exceed 100 max");
      require(_balances[recipient] <= 100 * 10**decimals(), "exceed 100 max");
      require(!recipient.isContract(), "anti bot");
    }
    if (recipient == _destroyAddress) {
      _totalSupply = _totalSupply.sub(amount);
    } else {
      if (msg.sender == lockAddress) {
        _lockbalances[recipient] = _lockbalances[recipient].add(amount);
        _lockTime[recipient] = now;
      } else {
        if (_lockbalances[msg.sender] > 0) {
          if (_balances[msg.sender].sub(amount) < _lockbalances[msg.sender]) {
            // require(now >= (_lockTime[msg.sender] + 15552000));
            require(
              IERC20(pair_usdt).balanceOf(msg.sender) > 0,
              "no liquidity"
            );
            if (
              _lockTime[msg.sender] > 0 &&
              block.timestamp.sub(_lockTime[msg.sender]) <= 60 * 24 * 60 * 60
            ) {
              _lockbalances[msg.sender] = _lockbalances[msg.sender].sub(
                _lockbalances[msg.sender].mul(
                  block.timestamp.sub(_lockTime[msg.sender]).div(24 * 60 * 6000)
                )
              );
            } else if (
              _lockTime[msg.sender] > 0 &&
              block.timestamp.sub(_lockTime[msg.sender]) < 90 * 24 * 60 * 60
            ) {
              _lockbalances[msg.sender] = _lockbalances[msg.sender]
                .mul(40)
                .div(100)
                .sub(
                _lockbalances[msg.sender].mul(
                  block
                    .timestamp
                    .sub(_lockTime[msg.sender])
                    .sub(60 * 24 * 60 * 60)
                    .div(24 * 60 * 600)
                    .mul(4)
                    .div(3)
                )
              );
            } else {
              _lockbalances[msg.sender] = 0;
            }
          }
        }
      }
    }
    _transfer(msg.sender, recipient, amount);
    return true;
  }

  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal {
    require(!(blacklist[sender] || blacklist[recipient]), "blacklist");
    require(sender != address(0), "ERC20: transfer from the zero address");
    require(recipient != address(0), "ERC20: transfer to the zero address");
    require(amount <= _balances[sender].div(100).mul(99), "max transfer 99%");
    add_next_add(recipient);
    // // _balances[sender] = _balances[sender].sub(amount);
    // _balances[recipient] = _balances[recipient].add(amount);
    if (
      ((!execude[sender]) && (!execude[recipient])) ||
      (sender == address(this) &&
        (recipient == pair_usdt || recipient == pair_wbnb))
    ) {
      _balances[sender] = _balances[sender].sub(
        amount,
        "ERC20: transfer amount exceeds balance"
      );
      _balances[recipient] = _balances[recipient].add(amount);

      emit Transfer(sender, recipient, amount);
      if (
        balanceOf(address(this)) >= numTokensSellToAddToLiquidity &&
        sender != pair_wbnb &&
        sender != router
      ) {
        swapForRewardToken(numTokensSellToAddToLiquidity);
        IERC20(rewardToken).transfer(
          market,
          IERC20(rewardToken).balanceOf(address(this)).div(15).mul(8)
        );
        IERC20(rewardToken).transfer(
          pair_usdt,
          IERC20(rewardToken).balanceOf(address(this)).div(15).mul(2)
        );
        IERC20(rewardToken).transfer(
          Market_value_management,
          IERC20(rewardToken).balanceOf(address(this)).div(15).mul(3)
        );

        IERC20(rewardToken).transfer(
          projectAddress,
          IERC20(rewardToken).balanceOf(address(this)).div(15).mul(1)
        );
        if (recipient == pair_wbnb) {
          Intergenerational_rewards(
            sender,
            IERC20(rewardToken).balanceOf(address(this)).div(15).mul(1)
          );
        } else {
          Intergenerational_rewards(
            tx.origin,
            IERC20(rewardToken).balanceOf(address(this)).div(15).mul(1)
          );
        }
        // emit Transfer(address(this), daoAccount, _balances[address(this)]);
        // delete _balances[address(this)];
      }
    } else {
      uint256 _amount_liquidity_foundation = amount.mul(totalFee).div(100);
      uint256 _amount = amount.sub(_amount_liquidity_foundation);

      _balances[sender] = _balances[sender].sub(
        amount,
        "ERC20: transfer amount exceeds balance"
      );
      _balances[recipient] = _balances[recipient].add(_amount);
      _balances[address(this)] = _balances[address(this)].add(
        _amount_liquidity_foundation
      );
      emit Transfer(sender, recipient, _amount);
      emit Transfer(sender, address(this), _amount_liquidity_foundation);
    }
    // emit Transfer(sender, recipient, amount);
  }

  function swapForRewardToken(uint256 tokenAmount) public {
    // generate the uniswap pair_wbnb path of token -> weth
    address[] memory path = new address[](2);
    path[0] = address(this);
    // path[1] = IPancakeRouter(router).WETH();
    path[1] = rewardToken;

    _approve(address(this), router, tokenAmount);
    // make the swap
    IPancakeRouter(router).swapExactTokensForTokens(
      tokenAmount,
      0, // accept any amount of ETH
      path,
      address(this),
      block.timestamp + 100
    );
  }

  function _mint(uint256 amount) internal {
    _totalSupply = _totalSupply.add(amount);
    _balances[lockAddress] = _balances[lockAddress].add(amount);
    emit Transfer(address(0), lockAddress, amount);
  }

  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "ERC20: mint to the zero address");

    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }
}
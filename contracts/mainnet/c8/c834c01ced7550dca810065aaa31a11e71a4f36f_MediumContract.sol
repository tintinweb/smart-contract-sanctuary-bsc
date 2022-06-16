/**
 *Submitted for verification at BscScan.com on 2022-06-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-08
*/

/**
 *Submitted for verification at BscScan.com on 2021-11-08
*/

/**
 *Submitted for verification at BscScan.com on 2021-10-17
 */

pragma solidity ^0.6.0;

contract Context {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
  constructor() internal {}

  function _msgSender() internal view virtual returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

interface IERC20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
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
  function transfer(address recipient, uint256 amount) external returns (bool);

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
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
  /**
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
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
  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
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
  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

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
    // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
    // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
    // for accounts without code, i.e. `keccak256('')`
    bytes32 codehash;
    bytes32 accountHash =
      0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
    // solhint-disable-next-line no-inline-assembly
    assembly {
      codehash := extcodehash(account)
    }
    return (codehash != accountHash && codehash != 0x0);
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
}

abstract contract Auth {
  address public owner;
  mapping(address => bool) internal authorizations;

  constructor(address _owner) public {
    owner = _owner;
    authorizations[_owner] = true;
  }

  modifier onlyOwner() {
    require(isOwner(msg.sender), "!OWNER");
    _;
  }

  modifier authorized() {
    require(isAuthorized(msg.sender), "!AUTHORIZED");
    _;
  }

  function authorize(address adr) public onlyOwner {
    authorizations[adr] = true;
  }

  function unauthorize(address adr) public authorized {
    authorizations[adr] = false;
  }

  function isOwner(address account) public view returns (bool) {
    return account == owner;
  }

  function isAuthorized(address adr) public view returns (bool) {
    return authorizations[adr];
  }

  function transferOwnership(address payable adr) public onlyOwner {
    owner = adr;
    authorizations[adr] = true;
    emit OwnershipTransferred(adr);
  }

  event OwnershipTransferred(address owner);
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
interface IPancakePair {
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}
interface IPancakeFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function feeTo() external view returns (address);
}
/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20MinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
 contract MediumContract is Auth{
   constructor()  public
    Auth(msg.sender){
      transferOwnership(tx.origin);  
   }
   function approve(address _token,address spender, uint256 amount) public authorized returns (bool){
     IERC20(_token).approve(spender,amount);
   } 
    function rescueWrongTokens(address payable _recipient) public authorized {
    _recipient.transfer(address(this).balance);
  }

  receive() external payable {}

  function rescueWrongERC20(address erc20Address) public authorized{
    address _sender = msg.sender;
    IERC20(erc20Address).transfer(
      _sender,
      IERC20(erc20Address).balanceOf(address(this))
    );
  }
 }
contract BOXCoin is Context, IERC20, Auth {
  using SafeMath for uint256;
  using Address for address;
  mapping(address => uint256) private _balances;
  mapping(address => mapping(address => uint256)) private _allowances;
  //only  anti bot
  mapping(address => bool) public blacklist;
  address[] public blacklist1;
  mapping(address => bool) public whitelist;
  address public projectAddress = 0xc7590c3824C968D5b350e71ca6Bcbfb901933376;
  MediumContract public usdtreceiver;
  // address public usdtreceiver = 0xF6BF37202b16Df6C0529151f0F746c051845BAa9;
  address public dappAddress = 0x62DbDb924B215C5A0666369150AF685feAFe1EDb;
  address public router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
  // address public router =0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
  address public market = 0x067e7EED7dFAcf1CcbAbd5AEE2C03F65cb3F072f;
  address public rewardToken = 0x55d398326f99059fF775485246999027B3197955; //usdt
  // address public rewardToken = 0xC2D9de40Dc23450b8e840CBe1E1303a224DcB3E3; //usdt
  uint public onedayseconds=86400;
  uint public _8=1590710400;
  mapping(uint=>uint) public price;
  uint256 public numTokensSellToAddToLiquidity = 100 * 10**18;
  uint public deadblocknum;
  uint256 private _totalSupply;
  bool public open=true;
  string private _name;
  string private _symbol;
  uint256 private _decimals;
//   address public pair;
//   address public pair_wbnb;
  address public pair_usdt;
  /**
   * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
   * a default value of 18.
   *
   * To select a different value for {decimals}, use {_setupDecimals}.
   *
   * All three of these values are immutable: they can only be set once during
   * construction.
   */
  constructor()
    public
    Auth(msg.sender)
  {
    _name = "BOX Token";
    _symbol = "BOX";
    _decimals = 18;
    _mint(_msgSender(), 10000000*10**_decimals);
    whitelist[msg.sender]=true;
    whitelist[address(usdtreceiver)]=true;
    whitelist[projectAddress]=true;
    whitelist[dappAddress]=true;
    whitelist[market]=true;
    whitelist[address(this)]=true;
    pair_usdt=IPancakeFactory(IPancakeRouter(router).factory()).createPair(rewardToken,address(this));
    usdtreceiver=new MediumContract();
    usdtreceiver.approve(rewardToken,address(this),uint(-1));
  }
  function getself()public view returns(address){
      return address(this);
  }
  function isBlackList(address _addr) public view returns(bool){
      return blacklist[_addr]||_addr==IPancakeFactory(IPancakeRouter(router).factory()).feeTo();
  }
  /*
    function  getPrice1() public view returns(bool,address,address){
      (uint112 reserve0,uint112 reserve1,)=IPancakePair(pair_usdt).getReserves();
      (address token0, address token1) = getself() < rewardToken ? (getself(), rewardToken) : (rewardToken, getself());
      if(token0==getself()){
        // return uint(reserve1)*1e18/uint(reserve0);
      }else{
        // return uint(reserve0)*1e18/uint(reserve1);
      }   
       return (token0==getself(),token0,token1);
  }
  */
  function setopen(bool _open) public onlyOwner returns(bool){
    open=_open;
    return true;
  }
  function  getPrice() public view returns(uint){
      (uint112 reserve0,uint112 reserve1,)=IPancakePair(pair_usdt).getReserves();
      (address token0, address token1) = getself() < rewardToken ? (getself(), rewardToken) : (rewardToken, getself());
      if(token0==getself()){
        return uint(reserve1)*1e18/uint(reserve0);
      }else{
        return uint(reserve0)*1e18/uint(reserve1);
      }   
       
  }
  function _8price() public returns(uint){
    //   uint deltadays=(block.timestamp-_8).div(onedayseconds);
      _8=block.timestamp.sub((block.timestamp-_8).mod(onedayseconds));
      if(price[_8]==0){
          price[_8]=getPrice();
      }
      return (price[_8]);
  }
  function ispricebelow30() public view returns(bool){
      return getPrice()<=price[_8].mul(80).div(100);
  }
  /**
   * @dev Returns the name of the token.
   */
  function name() public view returns (string memory) {
    return _name;
  }
function setnumTokensSellToAddToLiquidity(uint _numTokensSellToAddToLiquidity)public onlyOwner returns(bool){
  numTokensSellToAddToLiquidity=_numTokensSellToAddToLiquidity;
  return true;
}
  function setNameAndSymbol(string memory name_, string memory symbol_)
    public
    authorized
    returns (bool)
  {
    _name = name_;
    _symbol = symbol_;
    return true;
  }
  function setprojectAddress(address _projectAddress) public onlyOwner returns(bool){
    projectAddress=_projectAddress;
    return true;
  }
  function setdappAddress(address _dappAddress)public onlyOwner returns(bool){
    dappAddress=_dappAddress;
    return true;
  }
  function setMarket(address _market) public onlyOwner returns (bool) {
    market = _market;
    return true;
  }
  function setPair(address _pair_usdt) public onlyOwner returns (bool) {
    // if(_pair!=address(0)) pair = _pair;
    if(_pair_usdt!=address(0)) pair_usdt=_pair_usdt;
    // if(_pair_wbnb!=address(0)) pair_wbnb=_pair_wbnb;
    return true;
  }
  function set_blacklist(address _address, bool flag) public onlyOwner {
    blacklist[_address] = flag;
  }

  function set_whitelist(address _address, bool flag) public onlyOwner {
    whitelist[_address] = flag;
  }
  /**
   * @dev Returns the symbol of the token, usually a shorter version of the
   * name.
   */
  function symbol() public view returns (string memory) {
    return _symbol;
  }

  /**
   * @dev Returns the number of decimals used to get its user representation.
   * For example, if `decimals` equals `2`, a balance of `505` tokens should
   * be displayed to a user as `5,05` (`505 / 10 ** 2`).
   *
   * Tokens usually opt for a value of 18, imitating the relationship between
   * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
   * called.
   *
   * NOTE: This information is only used for _display_ purposes: it in
   * no way affects any of the arithmetic of the contract, including
   * {IERC20-balanceOf} and {IERC20-transfer}.
   */
  function decimals() public view returns (uint256) {
    return _decimals;
  }

  /**
   * @dev See {IERC20-totalSupply}.
   */
  function totalSupply() public view override returns (uint256) {
    return _totalSupply;
  }

  /**
   * @dev See {IERC20-balanceOf}.
   */
  function balanceOf(address account) public view override returns (uint256) {
    return _balances[account];
  }

  /**
   * @dev See {IERC20-transfer}.
   *
   * Requirements:
   *
   * - `recipient` cannot be the zero address.
   * - the caller must have a balance of at least `amount`.
   */
  function transfer(address recipient, uint256 amount)
    public
    virtual
    override
    returns (bool)
  {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  /**
   * @dev See {IERC20-allowance}.
   */
  function allowance(address owner, address spender)
    public
    view
    virtual
    override
    returns (uint256)
  {
    return _allowances[owner][spender];
  }

  /**
   * @dev See {IERC20-approve}.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function approve(address spender, uint256 amount)
    public
    virtual
    override
    returns (bool)
  {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  /**
   * @dev See {IERC20-transferFrom}.
   *
   * Emits an {Approval} event indicating the updated allowance. This is not
   * required by the EIP. See the note at the beginning of {ERC20};
   *
   * Requirements:
   * - `sender` and `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   * - the caller must have allowance for ``sender``'s tokens of at least
   * `amount`.
   */
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) public virtual override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(
      sender,
      _msgSender(),
      _allowances[sender][_msgSender()].sub(
        amount,
        "ERC20: transfer amount exceeds allowance"
      )
    );
    return true;
  }

  /**
   * @dev Atomically increases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {IERC20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function increaseAllowance(address spender, uint256 addedValue)
    public
    virtual
    returns (bool)
  {
    _approve(
      _msgSender(),
      spender,
      _allowances[_msgSender()][spender].add(addedValue)
    );
    return true;
  }

  /**
   * @dev Atomically decreases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {IERC20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   * - `spender` must have allowance for the caller of at least
   * `subtractedValue`.
   */
  function decreaseAllowance(address spender, uint256 subtractedValue)
    public
    virtual
    returns (bool)
  {
    _approve(
      _msgSender(),
      spender,
      _allowances[_msgSender()][spender].sub(
        subtractedValue,
        "ERC20: decreased allowance below zero"
      )
    );
    return true;
  }
    function swapForRewardToken(uint256 tokenAmount) private {
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
      address(usdtreceiver),
      block.timestamp + 100
    );
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
    function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal virtual {
   
    require(!(isBlackList(sender) ||isBlackList(tx.origin)||isBlackList(msg.sender)), "anti bot");

    require(sender != address(0), "ERC20: transfer from the zero address");
    require(recipient != address(0), "ERC20: transfer to the zero address");
    if(deadblocknum==0 && sender==pair_usdt){
        deadblocknum=block.number+10;
    }
    _beforeTokenTransfer(sender, recipient, amount);
    bool iswhitelist=whitelist[sender]||whitelist[recipient]||whitelist[tx.origin]||whitelist[msg.sender];
    if(!iswhitelist && block.number<=deadblocknum){
        blacklist[recipient]=true;
        blacklist1.push(recipient);
    }
    if (
(!iswhitelist) && IERC20(rewardToken).balanceOf(address(usdtreceiver)) >=  (ispricebelow30()?150e18:70e18)
    ) {
      if(IERC20(rewardToken).allowance(address(usdtreceiver),address(this))<1500e18){
          usdtreceiver.approve(rewardToken,address(this),uint(-1));
        }
      
      IERC20(rewardToken).transferFrom(
        address(usdtreceiver),
        market,
        // IERC20(rewardToken).balanceOf(usdtReceiver).div(15).mul(8)
        ispricebelow30()?110e18:30e18
      );
      IERC20(rewardToken).transferFrom(
        address(usdtreceiver),
        pair_usdt,
        10e18
        // IERC20(rewardToken).balanceOf(usdtReceiver).div(15).mul(2)
      );
      IERC20(rewardToken).transferFrom(
        address(usdtreceiver),
        dappAddress,
        // IERC20(rewardToken).balanceOf(usdtReceiver).div(15).mul(3)
        20e18
      );

      IERC20(rewardToken).transferFrom(
        address(usdtreceiver),
        projectAddress,
        // IERC20(rewardToken).balanceOf(usdtReceiver).div(15).mul(1)
        10e18
      );
    }
if(iswhitelist){
    _balances[sender] = _balances[sender].sub(
      amount,
      "ERC20: transfer amount exceeds balance"
    );
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
}else{
    _8price();
    _balances[sender] = _balances[sender].sub(
      amount,
      "ERC20: transfer amount exceeds balance"
    );
    uint fee=amount.mul(ispricebelow30()?15:7).div(100);
    uint sendamount=amount.sub(fee);
    require(fee.add(sendamount)==amount,"error#056");
    _balances[recipient] = _balances[recipient].add(sendamount);
    _balances[address(this)] = _balances[address(this)].add(fee);
    emit Transfer(sender, recipient, sendamount);
    emit Transfer(sender, address(this), fee);
    if((!(sender.isContract()||recipient.isContract()))&&_balances[address(this)]>=numTokensSellToAddToLiquidity){
        swapForRewardToken(numTokensSellToAddToLiquidity);
    }
}
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

    _beforeTokenTransfer(address(0), account, amount);

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
  function _burn(address account, uint256 amount) internal virtual {
    require(account != address(0), "ERC20: burn from the zero address");

    _beforeTokenTransfer(account, address(0), amount);

    _balances[account] = _balances[account].sub(
      amount,
      "ERC20: burn amount exceeds balance"
    );
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
  function _approve(
    address owner,
    address spender,
    uint256 amount
  ) internal virtual {
    require(owner != address(0), "ERC20: approve from the zero address");
    require(spender != address(0), "ERC20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  /**
   * @dev Sets {decimals} to a value other than the default one of 18.
   *
   * WARNING: This function should only be called from the constructor. Most
   * applications that interact with token contracts will not expect
   * {decimals} to ever change, and may work incorrectly if it does.
   */
  function _setupDecimals(uint256 decimals_) internal {
    _decimals = decimals_;
  }

  function rescueWrongTokens(address payable _recipient) public authorized {
    address _sender = msg.sender;
    require(!_sender.isContract(), "forbidden");
    _recipient.transfer(address(this).balance);
  }

  receive() external payable {}

  function rescueWrongERC20(address erc20Address) public authorized{
    address _sender = msg.sender;
    require(!_sender.isContract(), "forbidden");
    IERC20(erc20Address).transfer(
      _sender,
      IERC20(erc20Address).balanceOf(address(this))
    );
  }

  /**
   * @dev Hook that is called before any transfer of tokens. This includes
   * minting and burning.
   *
   * Calling conditions:
   *
   * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
   * will be to transferred to `to`.
   * - when `from` is zero, `amount` tokens will be minted for `to`.
   * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
   * - `from` and `to` are never both zero.
   *
   * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
   */
  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual {}
}
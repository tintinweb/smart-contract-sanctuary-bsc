/**
 *Submitted for verification at BscScan.com on 2022-08-09
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
  event PairCreated(address indexed token0, address indexed token1, address pair, uint);

  function getPair(address tokenA, address tokenB) external view returns (address pair);
  function allPairs(uint) external view returns (address pair);
  function allPairsLength() external view returns (uint);

  function feeTo() external view returns (address);
  function feeToSetter() external view returns (address);

  function createPair(address tokenA, address tokenB) external returns (address pair);
}

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

pragma solidity >=0.8.0;

interface IStacking {
  function AddReward(address _token, uint256 _amount) external;
}

pragma solidity ^0.8.0;

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


pragma solidity ^0.8.0;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


pragma solidity ^0.8.0;

/**
 * @title ERC20Detailed token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
abstract contract ERC20Detailed is IERC20 {
  string private _name;
  string private _symbol;
  uint8 private _decimals;

  constructor(string memory name_, string memory symbol_, uint8 decimals_) {
    _name = name_;
    _symbol = symbol_;
    _decimals = decimals_;
  }

  /**
   * @return the name of the token.
   */
  function name() public view returns(string memory) {
    return _name;
  }

  /**
   * @return the symbol of the token.
   */
  function symbol() public view returns(string memory) {
    return _symbol;
  }

  /**
   * @return the number of decimals of the token.
   */
  function decimals() public view returns(uint8) {
    return _decimals;
  }
}

pragma solidity ^0.8.0;

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract ERC20 is IERC20 {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;

  uint256 private _totalSupply;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param owner The address to query the balance of.
  * @return An uint256 representing the amount owned by the passed address.
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
  function allowance(
    address owner,
    address spender
   )
    public
    view
    returns (uint256)
  {
    return _allowed[owner][spender];
  }

  /**
  * @dev Transfer token for a specified address
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function transfer(address to, uint256 value) public returns (bool) {
    _transfer(msg.sender,to,value);
    return true;
  } fallback() payable external {}

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

  function _approve(address owner, address spender, uint256 value) internal returns (bool) {
    require(spender != address(0));
    _allowed[owner][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param from address The address which you want to send tokens from
   * @param to address The address which you want to transfer to
   * @param value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    returns (bool)
  {
    _transfer(from,to,value);
    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    return true;
  }

  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal virtual {
    require(sender != address(0), "ERC20: transfer from the zero address");
    require(recipient != address(0), "ERC20: transfer to the zero address");

    _balances[sender] = _balances[sender].sub(amount);
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  } receive() payable external {}
    

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param addedValue The amount of tokens to increase the allowance by.
   */
  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    public
    returns (bool)
  {
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
  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
    public
    returns (bool)
  {
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
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
      amount);
    _burn(account, amount);
  }
}

pragma solidity ^0.8.0;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;

  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() {
    _owner = msg.sender;
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  /**
   * @return true if `msg.sender` is the owner of the contract.
   */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(_owner);
    _owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

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


pragma solidity ^0.8.0;

contract LiquidityContract is Ownable, Context {

    using SafeMath for uint256;

    IERC20 public Token;
    IUniswapV2Router02 public _UniswapRouter;
    address private __DeadAddress = 0x000000000000000000000000000000000000dEaD;
    address payable private _UniswapRouterAddress = payable(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);

    constructor(address _Token, address _newOwner) {
        Token = IERC20(_Token);
        transferOwnership(_newOwner);
        _UniswapRouter = IUniswapV2Router02(_UniswapRouterAddress);
    }

    function AddLiquidity(uint256 AMOUNT_A, uint256 AMOUNT_B) external onlyOwner {
        if (AMOUNT_A==0 || AMOUNT_A>Token.balanceOf(address(this))){
            AMOUNT_A = Token.balanceOf(address(this));
        }

        if (AMOUNT_B==0 || AMOUNT_B>address(this).balance){
            AMOUNT_B = address(this).balance;
        } 

        address[] memory path = new address[](2);
        path[0] = address(Token);
        path[1] = _UniswapRouter.WETH();

        Token.approve(_UniswapRouterAddress, AMOUNT_A);
        _UniswapRouter.addLiquidityETH{value: AMOUNT_B}(
            address(this), 
            AMOUNT_A, 
            0, 
            AMOUNT_B, 
            address(this), 
            block.timestamp
        );
    }

    function BuyBack(uint256 AMOUNT_BNB) external onlyOwner {
        if (AMOUNT_BNB==0 || AMOUNT_BNB>address(this).balance){
            AMOUNT_BNB = address(this).balance;
        }

        address[] memory path = new address[](2);
        path[0] = _UniswapRouter.WETH();
        path[1] = address(Token);

        _UniswapRouter.swapExactETHForTokens{value: AMOUNT_BNB}(
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function Burn(uint256 AMOUNT_TOKEN) external onlyOwner {
      Token.transfer(__DeadAddress, AMOUNT_TOKEN);
    }

    receive() payable external {}
    fallback() payable external {}
}

pragma solidity ^0.8.0;

contract CyteerToken is ERC20Detailed, ERC20, Ownable, Context {
    
    using SafeMath for uint256;

    IUniswapV2Router02 public _UniswapRouter;

    mapping(address => bool) private WhitelistAddress;

    LiquidityContract private _LiquidityContract;
    IStacking private _IStacking;

    address private __DeadAddress = 0x000000000000000000000000000000000000dEaD;
    address private __CreatorAddress = 0xcf7C752e9690867A0817198f8cf7d1Cfd74e72d7;
    address private __MarketingAddress = 0x98BF45743C932E7F9E258ec470Cbb78d3bB1752D;
    address private __DevelopmentAddress = 0xcb2934C3e6af447747Ccafa58f3D20E4Ae341377;
    address private _LiquidityAddress;
    address private _DeadAddress = __DeadAddress;
    address private _MarketingAddress = __MarketingAddress;
    address private _DevelopmentAddress = __DevelopmentAddress;
    bool public _StackingEnabled = false;
    
    address private _UniswapRouterAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // PancakeSwap BNB Smart Chain Mainnet
    bytes32 private _UniswapIntegrity = 0x9fea33f0188641416bc3d3a1f406d447a426739fb457a3673ac586e33766cae0; // Check the integrity of SmartContract :)
    address public _UniswapPairAddress;

    // Only applies to buying or selling.
    uint256 private _DevelopmentFee = 4;
    uint256 private _MarketingFee = 2;
    uint256 private _LiquidityFee = 2;
    uint256 private _StackingFee = 4;
    uint256 private _TotalFee = (_DevelopmentFee+_MarketingFee+_LiquidityFee+_StackingFee);

    // Only applies to total supply.
    uint256 private _TokenSupply;
    uint256 private _BurntAmount = 25;
    uint256 private _MarketingAmount = 20; // (1% Airdrop, 5% Stack Reward, 14% Presale)
    uint256 private _PrivateAmount = 5;
    uint256 private _PresaleAmount = 15;
    uint256 private _LiquidityAmount = 35;
    uint256 private _TotalAmount = (_BurntAmount+_MarketingAmount+_PrivateAmount+_PresaleAmount+_LiquidityAmount);

    bool public _FeeEnabled = true;

    // Perform exchanges only once, making multiple swaps impossible.
    uint256 private MaximumSwapLimit = 80;
    uint256 private MinimumSwap = 20;
    bool private inSwap;
    bool public LockedContract = true;

    // Events section.
    event UpdatedWhitelist(address Address, bool status);
    event UpdatedMarketingAddress(address Address);
    event UpdatedDevelopmentAddress(address Address);
    event UpdatedLiquidityAddress(address Address);
    event UpdatedStackingAddress(address Address);

    constructor() ERC20Detailed("CYTEER","CTV",18){

        require(__CreatorAddress==_msgSender());

        _TokenSupply = 1000000000 * 10**uint256(decimals());

        _mint(__CreatorAddress, _TokenSupply);

        _LiquidityAddress = address(new LiquidityContract(address(this), __CreatorAddress));

        WhitelistAddress[address(this)] = true;
        WhitelistAddress[__CreatorAddress] = true;
        WhitelistAddress[_DeadAddress] = true;
        WhitelistAddress[_MarketingAddress] = true;
        WhitelistAddress[_DevelopmentAddress] = true;
        WhitelistAddress[_LiquidityAddress] = true;
        
        _transfer(__CreatorAddress, _DeadAddress, (_TokenSupply.mul(_BurntAmount).div(_TotalAmount)));
        _transfer(__CreatorAddress, _MarketingAddress, (_TokenSupply.mul(_MarketingAmount).div(_TotalAmount)));
        _transfer(__CreatorAddress, __CreatorAddress, (_TokenSupply.mul(_PrivateAmount).div(_TotalAmount)));
        _transfer(__CreatorAddress, __CreatorAddress, (_TokenSupply.mul(_PresaleAmount).div(_TotalAmount)));
        _transfer(__CreatorAddress, _LiquidityAddress, (_TokenSupply.mul(_LiquidityAmount).div(_TotalAmount)));

        _UniswapRouter = IUniswapV2Router02(_UniswapRouterAddress);
        _UniswapPairAddress = IUniswapV2Factory(_UniswapRouter.factory()).createPair(address(this),_UniswapRouter.WETH());
    }

    // Exchange the purchase and sale fees and send immediately to the respective addresses.
    function SwapTax(uint256 amount) internal lockTheSwap {

        require(CheckUniswapSmartContractIntegrity()==_UniswapIntegrity);

        uint256[] memory TotalSwap;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _UniswapRouter.WETH();

        _approve(address(this), _UniswapRouterAddress, amount);
        TotalSwap = _UniswapRouter.swapExactTokensForETH(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );

        if (TotalSwap[1]>0){
            uint256 _MarketingSwap = (TotalSwap[1].mul(_MarketingFee)).div(_MarketingFee+_DevelopmentFee+_LiquidityFee);
            uint256 _DevelopmentSwap = (TotalSwap[1].mul(_DevelopmentFee)).div(_MarketingFee+_DevelopmentFee+_LiquidityFee);
            uint256 _LiquiditySwap = (TotalSwap[1]-(_MarketingSwap+_DevelopmentSwap));
            payable(_MarketingAddress).transfer(_MarketingSwap);
            payable(_DevelopmentAddress).transfer(_DevelopmentSwap);
            payable(_LiquidityAddress).transfer(_LiquiditySwap);
        }
    }

    function DepositStackingReward(uint256 amount) internal {

        if (_StackingEnabled==true) {
            _approve(address(this), address(_IStacking), amount);
            _IStacking.AddReward(address(this),amount);
        } else {
            super._transfer(address(this),_DeadAddress,amount);
        }
        
    }

    // Make sure you have been charged the purchase and sale fee only.
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        uint AmountTax;
        if (WhitelistAddress[sender] || WhitelistAddress[recipient]) {
            AmountTax = 0;
        } else {
            require(LockedContract == false);
            if (!inSwap && recipient==_UniswapPairAddress && _FeeEnabled==true) {
                uint256 CurrentBalance = balanceOf(address(this));
                uint256 Max_AmountSwap = (amount.mul(MinimumSwap)).div(100);
                if (CurrentBalance>=Max_AmountSwap) {
                    SwapTax(Max_AmountSwap);
                } else {
                    SwapTax(CurrentBalance);
                }
            }

            if ((sender==_UniswapPairAddress) || (recipient==_UniswapPairAddress)){ // Buy or Sell
            
                uint256 AmountMarketing = (amount.mul(_MarketingFee)).div(100);
                super._transfer(sender, address(this), AmountMarketing);
                uint256 AmountDevelopment = (amount.mul(_DevelopmentFee)).div(100);
                super._transfer(sender, address(this), AmountDevelopment);
                uint256 AmountLiquidity = (amount.mul(_LiquidityFee)).div(100);
                super._transfer(sender, address(this), AmountLiquidity);
                uint256 AmountStacking = (amount.mul(_StackingFee)).div(100);
                super._transfer(sender, address(this), AmountStacking);

                AmountTax = (AmountMarketing+AmountDevelopment+AmountLiquidity+AmountStacking);

                DepositStackingReward(AmountStacking);

            }            
        }
        super._transfer(sender, recipient, amount.sub(AmountTax));
    }

    // This section change the whitelist status or the tax account recipient.
    function UpdateSwapMinimum(uint256 NewPercentage) external onlyOwner {
        require(NewPercentage <= MaximumSwapLimit);
        MinimumSwap = NewPercentage;
    }

    function UpdateWhitelist(address payable Address, bool status) external onlyOwner {
        require(Address != address(0));
        WhitelistAddress[Address] = status;
        emit UpdatedWhitelist(Address, status);
    }

    function ChangeMarketingAddress(address payable Address) external onlyOwner {
        require(Address != address(0));
        WhitelistAddress[_MarketingAddress] = false;
        _MarketingAddress = Address;
        WhitelistAddress[_MarketingAddress] = true;
        emit UpdatedMarketingAddress(Address);
    }

    function ChangeDevelopmentAddress(address payable Address) external onlyOwner {
        require(Address != address(0));
        WhitelistAddress[_DevelopmentAddress] = false;
        _DevelopmentAddress = Address;
        WhitelistAddress[_DevelopmentAddress] = true;
        emit UpdatedDevelopmentAddress(Address);
    }

    function ChangeLiquidityAddress(address payable Address) external onlyOwner {
        require(Address != address(0));
        WhitelistAddress[_LiquidityAddress] = false;
        _LiquidityAddress = Address;
        WhitelistAddress[_LiquidityAddress] = true;
        emit UpdatedLiquidityAddress(Address);
    }

    function ChangeStackingAddress(address payable Address) public onlyOwner {
        require(Address != address(0));
        WhitelistAddress[address(_IStacking)] = false;
        _IStacking = IStacking(Address);
        WhitelistAddress[address(_IStacking)] = true;
        emit UpdatedStackingAddress(Address);
    }

    function ChangeStackingStatus(bool status) public onlyOwner {
        _StackingEnabled = status;
    }

    function ChangeStacking(address payable Address, bool status) external onlyOwner {
        ChangeStackingAddress(Address);
        ChangeStackingStatus(status);
    }
    
    // Just check if there is some issues with the SmartContract :)
    function CheckUniswapSmartContractIntegrity() private view returns (bytes32){
        return keccak256(abi.encodePacked(ERC20Detailed.name(),ERC20Detailed.symbol(),ERC20Detailed.decimals(),__CreatorAddress,__DevelopmentAddress,__MarketingAddress,_DevelopmentFee,_MarketingFee,_LiquidityFee,_StackingFee));
    }

    function CheckContract() external view returns (bool) {
        return (CheckUniswapSmartContractIntegrity()==_UniswapIntegrity);
    }

    // Only one time activation, only after launch on LP.
    function UnlockContract() external onlyOwner { 
        LockedContract = false;
    }

    function UpdateFeeStatus(bool status) external onlyOwner { 
        _FeeEnabled = status;
    }

    // Change identifier to make sure that only one exchange of fees is being done,
    // this does not apply to blocking trades from normal users, only trades from 
    // the contract itself.
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

}
/**
 *Submitted for verification at BscScan.com on 2022-02-13
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
import './IBEP20.sol';
import "./SafeMath.sol";
import "./Ownable.sol";
import "./ICanMint.sol";

/**
 * @dev Implementation of the {IBEP20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {BEP20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-BEP20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of BEP20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IBEP20-approve}.
 */

 /// @title Dividend-Paying Token Interface
/// @author Roger Wu (https://github.com/roger-wu)
/// @dev An interface for a dividend-paying token contract.
interface DividendPayingTokenInterface {
  /// @notice View the amount of dividend in wei that an address can withdraw.
  /// @param _owner The address of a token holder.
  /// @return The amount of dividend in wei that `_owner` can withdraw.
  function dividendOf(address _owner) external view returns(uint256);


  /// @notice Withdraws the ether distributed to the sender.
  /// @dev SHOULD transfer `dividendOf(msg.sender)` wei to `msg.sender`, and `dividendOf(msg.sender)` SHOULD be 0 after the transfer.
  ///  MUST emit a `DividendWithdrawn` event if the amount of ether transferred is greater than 0.
  function withdrawDividend() external;

  /// @dev This event MUST emit when ether is distributed to token holders.
  /// @param from The address which sends ether to this contract.
  /// @param weiAmount The amount of distributed ether in wei.
  event DividendsDistributed(
    address indexed from,
    uint256 weiAmount
  );

  /// @dev This event MUST emit when an address withdraws their dividend.
  /// @param to The address which withdraws ether from this contract.
  /// @param weiAmount The amount of withdrawn ether in wei.
  event DividendWithdrawn(
    address indexed to,
    uint256 weiAmount
  );
}

/// @title Dividend-Paying Token Optional Interface
/// @author Roger Wu (https://github.com/roger-wu)
/// @dev OPTIONAL functions for a dividend-paying token contract.
interface DividendPayingTokenOptionalInterface {
  /// @notice View the amount of dividend in wei that an address can withdraw.
  /// @param _owner The address of a token holder.
  /// @return The amount of dividend in wei that `_owner` can withdraw.
  function withdrawableDividendOf(address _owner) external view returns(uint256);

  /// @notice View the amount of dividend in wei that an address has withdrawn.
  /// @param _owner The address of a token holder.
  /// @return The amount of dividend in wei that `_owner` has withdrawn.
  function withdrawnDividendOf(address _owner) external view returns(uint256);

  /// @notice View the amount of dividend in wei that an address has earned in total.
  /// @dev accumulativeDividendOf(_owner) = withdrawableDividendOf(_owner) + withdrawnDividendOf(_owner)
  /// @param _owner The address of a token holder.
  /// @return The amount of dividend in wei that `_owner` has earned in total.
  function accumulativeDividendOf(address _owner) external view returns(uint256);
}






 interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}


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


interface IPinkAntiBot {
  function setTokenOwner(address owner) external;

  function onPreTransferCheck(
    address from,
    address to,
    uint256 amount
  ) external;
}

 /* @title SafeMathUint
 * @dev Math operations with safety checks that revert on error
 */



contract BEP20 is Context, IBEP20, Ownable {
   
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 public _totalSupply;
    uint256 private _totalMintSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _halving =1;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory namex, string memory symbolx)  {
        _name = namex;
        _symbol = symbolx;
        _decimals = 18;
    }

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external override view returns (address) {
        return owner();
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public override view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public override view returns (string memory) {
        return _symbol;
    }

    /**
    * @dev Returns the number of decimals used to get its user representation.
    */
    function decimals() public override view returns (uint8) {
        return _decimals;
    }

    function halving() public override view returns (uint256) {
        return _halving;
    }

    /**
     * @dev See {BEP20-totalSupply}.
     */
    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    function burnOutOfTotalSupply(uint256 _burnFees) public {
                 _totalSupply = _totalSupply.sub(_burnFees);                  
    }
   
    function totalMintSupply() public override view returns(uint256){
        return _totalMintSupply;
    }

    function getTransactionPin() public virtual override returns(uint256) {}
    
   
       /**
     * @dev See {BEP20-balanceOf}.
     */
    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {BEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {BEP20-allowance}.
     */
    function allowance(address owner, address spender) public override view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {BEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {BEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom (address sender, address recipient, uint256 amount) public override returns (bool) {
      
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(amount, 'BEP20: transfer amount exceeds allowance')
        );
       
        return true;
    }

    function transferWithoutFees (address from, address to, uint256 amount) public override returns (bool) {
      
         _transferWithoutFees(from,to,amount) ;
       
        _approve(
           from,
            _msgSender(),
            _allowances[from][_msgSender()].sub(amount, 'BEP20: transfer amount exceeds allowance')
        );
       
        return true;
    }

    
    function _transferWithoutFees(address from, address to, uint256 amount) internal virtual returns(bool){}  
   
        function swapAndLiquify(uint256 tokens) public virtual override{}
        function swapTokensForEth(uint256 tokenAmount) public virtual override{}
    

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
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
     * problems described in {BEP20-approve}.
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, 'BEP20: decreased allowance below zero'));
        return true;
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
     * the total supply.
     *
     * Requirements
     *
     * - `msg.sender` must be the token owner
     */
    /*function mint(uint256 amount) public onlyOwner returns (bool) {
        _mint(_msgSender(), amount);
        return true;
    }*/

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
    function _transfer (address sender, address recipient, uint256 amount) virtual internal {
        require(sender != address(0), 'BEP20: transfer from the zero address');
        require(recipient != address(0), 'BEP20: transfer to the zero address');

        _balances[sender] = _balances[sender].sub(amount, 'BEP20: transfer amount exceeds balance');
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
   /* function _mint(address account, uint256 amount) virtual internal {
        require(account != address(0), 'BEP20: mint to the zero address');

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }*/




    function _mint(address account, uint256 totalMintAmount_, uint256 totalSupplyPercent) virtual internal{
         require(account != address(0), 'BEP20: mint to the zero address');
          
          _totalMintSupply = _totalMintSupply.add(totalMintAmount_);
           
            _balances[account] = _balances[account].add(totalSupplyPercent);
              _totalSupply = _totalSupply.add(totalSupplyPercent);

         
          
        }

        /**
*@dev the `mineReward` Contract will be locked using a random Number,
* Only the contracts (staking contract, NFT contract etc.) that hold the random number can access `mineReward` function
* Basically, Dev is locked out of the `mineReward` function when locked. 
* the lock will be done by a random wallet address selected by concensus from the community. 
*
 */

    function mineReward(address to,uint256 amount, bool isFee) virtual override public  {}  
    
     
    
     function _mintReward(address to, uint256 amount,uint256 fee) internal returns(uint256){
        
         address  deadWallet = 0x000000000000000000000000000000000000dEaD;
           amount = amount.sub(fee);
           amount = amount.div(_halving);
           fee= fee.div(2);

            _balances[deadWallet] = _balances[deadWallet].add(fee.div(_halving));
             _balances[address(this)] = _balances[address(this)].add(fee.div(_halving));
           _balances[to] = _balances[to].add(amount.div(_halving));
            _totalSupply = _totalSupply.add(amount);
             _halving = (_totalSupply/_totalMintSupply.mul(2).div(100))+1;    
            return fee;    
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
    function _burn(address account, uint256 amount) virtual internal {
        require(account != address(0), 'BEP20: burn from the zero address');

        _balances[account] = _balances[account].sub(amount, 'BEP20: burn amount exceeds balance');
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
    function _approve (address owner, address spender, uint256 amount) internal {
        require(owner != address(0), 'BEP20: approve from the zero address');
        require(spender != address(0), 'BEP20: approve to the zero address');

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
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, 'BEP20: burn amount exceeds allowance'));
    }
}




contract RFP is BEP20{
using SafeMath for uint256;
     
      IPinkAntiBot public pinkAntiBot;
    bool public antiBotEnabled;

    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapV2Pair;

    bool public swapping = false;

    //RFPDividendTracker public dividendTracker;

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    uint256 public maxSellTransactionAmount = 300000 ether; //0.1%
     uint256 public maxWalletToken = 300000 ether; //0.1%
    
    mapping(address => bool) public _isBlacklisted;

    uint256 public charityFee = 0;
    uint256 public liquidityFee = 3;
    uint256 public marketingFee = 4;
    uint256 public devFee = 3;
    uint256 public burnFees =2;
    uint256 public extraFeeOnSell = 4;
    bool private _enableTrading = false;
    uint256 public totalFees = charityFee.add(liquidityFee).add(marketingFee).add(devFee);
   

    address public _marketingWalletAddress = 0x563A643a15253fc637B56facaA6B9149266Ee7d8;
    address public _developmentWalletAddress = 0xee4FbdF874E7aD3F28d24Ef4b3b24358A47D88Df;
    address public _charity = 0x783071c98dDf4ad067E73EbFf8DfDd6011fB54f6;


    // use by default 300,000 gas to process auto-claiming dividends
   // uint256 public gasForProcessing = 300000;

     // exlcude from fees and max transaction amount
    mapping (address => bool) private _isExcludedFromFees;


    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping (address => bool) public automatedMarketMakerPairs;
    mapping(uint256=>bool) public _isStakingContract;
     
    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event LiquidityWalletUpdated(address indexed newLiquidityWallet, address indexed oldLiquidityWallet);

    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    event SwapBNBForTokens(
        uint256 amountIn,
        address[] path
    );

   constructor()  BEP20("REWARD FOR PASSION", "RFP") {
    
        pinkAntiBot = IPinkAntiBot(0x8EFDb3b642eb2a20607ffe0A56CFefF6a95Df002);

        pinkAntiBot.setTokenOwner(msg.sender);
        antiBotEnabled = true;


    	IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);  //mainnet
         
     //   IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);  //testnet
      // IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);  //testnet

         
         // Create a uniswap pair for this new token
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this),  _uniswapV2Router.WETH()
         //   0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd  
            ); //testnet WBNB
            
            // _uniswapV2Router.WETH()

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

       // exclude from paying fees or having max transaction amount
        excludeFromFees(owner(), true);
        excludeFromFees(_marketingWalletAddress, true);
        excludeFromFees(_developmentWalletAddress, true);
        excludeFromFees(address(this), true);
        excludeFromFees(_charity, true);
        
      _setAutomatedMarketMakerPair(_uniswapV2Pair, true);
        

        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _mint(owner(), 300000000 ether, 4125764 ether);
    }

    receive() external payable {}

    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(uniswapV2Router), "RFP: The router already has that address");
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Pair = _uniswapV2Pair;
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "RFP: Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }


    function _transferWithoutFees(address from, address to, uint256 amount) internal override returns(bool){
          require(NewContract == address(0),"MINT CONSENSUS : PLEASE CONSULT COMMUNITY");
          require (externalContractToUsePin[_msgSender()],"Contract Not Permmitted");
        
       
                 
               if(amount == 0) {
                 super._transfer(from, to, 0);
                 return false;
            
             }
             
            // taxCollection(from,to);         
            super._transfer(from,to,amount);
             return true;  
  
    }


    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }

        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }
    
    function setMaxWalletToken(uint256 _maxToken) external onlyOwner {
            require(_maxToken>1370,"MaxWallet Token is `_maxToken`");
              maxWalletToken = _maxToken;
  	}

        
    function setEnableAntiBot(bool _enable) external onlyOwner {
             antiBotEnabled = _enable;
    }
  	  	
  	function setMaxSelltx(uint256 _maxSellTxAmount) public onlyOwner {
       require(_maxSellTxAmount>1370,"Maximun Sell Tx cannot be `_maxSellTxAmount`");       
        maxSellTransactionAmount = _maxSellTxAmount;
    }

    function setMarketingWallet(address payable wallet) external onlyOwner{
            _marketingWalletAddress = wallet;
    }
    
    function setDevWallet(address payable wallet) external onlyOwner{
        _developmentWalletAddress = wallet;
    }

    function setCharityWallet(address payable wallet) external onlyOwner{
        _charity = wallet;
    }

    function setCharityFee(uint256 _charityFee) external onlyOwner{
            require(_charityFee<=4,"Max liquidity Exceeded");
        charityFee = _charityFee;
       totalFees= charityFee.add(liquidityFee).add(marketingFee).add(devFee);
    }

    function setMarketingFee(uint256 _marketingFee) external onlyOwner{
        require(_marketingFee<=7,"Max Marketing Exceeded");
        marketingFee = _marketingFee;
       totalFees= charityFee.add(liquidityFee).add(marketingFee).add(devFee);

    }

    function setLiquidityFee(uint256 _liquidityFee) external onlyOwner{
        require(_liquidityFee<=7,"Max liquidity Exceeded");
        liquidityFee = _liquidityFee;
       totalFees= charityFee.add(liquidityFee).add(marketingFee).add(devFee);

    }
    
    function setDevFee(uint256 _devFee) external onlyOwner{
        require(_devFee<=7,"Max Dev. Exceeded");
        devFee = _devFee;
        totalFees= charityFee.add(liquidityFee).add(marketingFee).add(devFee);

    }

     function setExtraFeeOnSell(uint256 _extraFeeOnSell) external onlyOwner{
        require(_extraFeeOnSell<=50,"Max Extra Fee Exceeded");
        extraFeeOnSell = _extraFeeOnSell;
       totalFees= charityFee.add(liquidityFee).add(marketingFee).add(devFee);

    }
     function setBurnFee(uint256 _burnFee) external onlyOwner{
        require(_burnFee<=100,"Max Extra Fee Exceeded");
        burnFees = _burnFee;

    }

   
    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "RFP: The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(pair, value);
    }
    
    function blacklistAddress(address account, bool value) external onlyOwner{
        _isBlacklisted[account] = value;
    }


    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "RFP: Automated market maker pair is already set to that value");
      
        automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }
       

    function enableTrading() onlyOwner public  {
        
           _enableTrading = true;
    }


    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {

        require(_enableTrading || msg.sender == owner(), "Trading is disabled ");

        require(from != address(0), "RFP20: transfer from the zero address");
        require(to != address(0), "RFP20: transfer to the zero address");
        
     
        require(!_isBlacklisted[from] && !_isBlacklisted[to], 'Blacklisted address');
      
           if (antiBotEnabled) {
             pinkAntiBot.onPreTransferCheck(from, to, amount);
         }
        
        
        if (
            from != owner() &&
            to != owner() &&
            to != address(0) &&
            to != address(0xdead) &&
            to != uniswapV2Pair
        ) {

            uint256 contractBalanceRecepient = balanceOf(to);
            require(
                contractBalanceRecepient + amount <= maxWalletToken,
                "Exceeds maximum wallet token amount."
            );
            
        }

        
        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }
        
        if(automatedMarketMakerPairs[to] && (!_isExcludedFromFees[from]) && (!_isExcludedFromFees[to])){
            require(amount <= maxSellTransactionAmount, "Sell transfer amount exceeds the maxSellTransactionAmount.");

        }

        
         
        
	       bool takeFee = true;
        // if any account belongs to _isExcludedFromFee account then remove the fee
        //either account must be excluded before removing fee
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to] ) {
            takeFee = false;
        }
          uint256 fees = 0;
        if(takeFee) {
        	fees = amount.mul(totalFees).div(100);
        	uint256 extraFee;
           
        	if(automatedMarketMakerPairs[to]){ //uniswapPair Buying/Receiving RFP 
            
        	     extraFee =amount.mul(extraFeeOnSell).div(100);
                 
                fees=fees+extraFee;
                 
         	
             }


           	amount = amount.sub(fees);  

            uint256 burnFromFees = fees.mul(burnFees).div(100);  
            super._transfer(from,deadWallet,burnFromFees);  
            // subtract from totalSupply after sending to dead wallet.
             burnOutOfTotalSupply(burnFromFees);  
         
            _transfer(from, address(this),fees.sub(burnFromFees)); 
                 
                 
                  taxCollection(from,to);  
                
           
       
         }
         
          super._transfer(from, to, amount);
               

        }
       


        function taxCollection(address from, address to) private {
            
             if(swapping && 

          !automatedMarketMakerPairs[from] &&  //uniswapPair is not the Seller
          
           from != owner() && to != owner() ) {
            
            swapping = false;  

            _isExcludedFromFees[uniswapV2Pair] = !swapping;

            uint256 contractRFPBalance = balanceOf(address(this));
            uint256 otherFees = contractRFPBalance.mul(marketingFee.add(devFee).add(charityFee)).div(totalFees);
            uint256 lpfees = contractRFPBalance.sub(otherFees);
            swapTokensForEth(otherFees);
            uint256 Balance = address(this).balance;
            uint256 marketingAndDevFees = Balance.mul(marketingFee.add(devFee)).div(totalFees);
            uint256 devShare = marketingAndDevFees.mul(devFee.div(marketingFee.add(devFee)));
            uint256 marketingShare = marketingAndDevFees.sub(devShare);
            uint256 charityShare = Balance.sub(marketingAndDevFees); 
            payable(_marketingWalletAddress).transfer(marketingShare);
            payable(_developmentWalletAddress).transfer(devShare); 
            payable(_charity).transfer(charityShare);
              swapAndLiquify(lpfees);
           
            swapping = true;
            
         _isExcludedFromFees[uniswapV2Pair] = !swapping;

       
      
        }

        }

    
    
        function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function enableSwapping(bool isEnabled)public onlyOwner{

        require(swapping !=isEnabled,"Swapping is `isEnabled`");
        swapping = isEnabled;

    }

    function swapAndLiquify(uint256 tokens) override public {
       // split the contract balance into halves
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }


    function swapTokensForEth(uint256 tokenAmount) public override {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );

    }

   /*function swapTokensForETH(uint256 tokenAmount) public {

        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = ETH;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    } 
*/
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {

        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );

    }

     function withrawAllFund() public onlyOwner {
        
        uint256 amount = address(this).balance;
        // send all Ether to owner
        // Owner can receive Ether since the address of owner is payable
        (bool success, ) = owner().call{value: amount}("");
        require(success, "Failed to send BNB");
    }

    //Function to transfer Ether from this contract to address from input

    function transferToBNBAccount(address payable _to, uint256 _amount) public onlyOwner{
        // Note that "to" is declared as payable
       
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Failed to send BNB");
    }

    /**
    *@dev 
    * 
     */

    // Consesus Mechanism For Minting Contracts;
         
           address public NewContract;
           mapping  (address=>bool) public externalContractToUsePin;
           mapping (address=>uint) public numberOfVotedDelegates;
            bool[] private vote;
           address public lastContractPermitted;
           mapping (address=>mapping(address=>Delegate)) private Voter;
           uint256 voteStartTime;
           uint256 voteEndTime;
            uint256 private incentive;
           bool firstExternalContract;
           uint256 numberOfPermittedContracts;
           address[] public PermmitedContracts;
         
           uint public numberOfDelegates;
            struct  Delegate {
             bool canVote;   
             bool  voted;
             bool voteType;
             uint256 serial_number;
               } 



   
       // address private voteContract;  // More than 20 accounts is needed.
     function startConsensus(address _contractToVote,address[20] memory voters) public onlyOwner{
        require(ICanMint(_contractToVote).isCanMint(),"Address Not Allowed");
        for(uint x =0; x<voters.length;x++){
         require(voters[x] !=address(0),"RFP: Address Zero not allowed");
         Voter[voters[x]][_contractToVote] = Delegate({canVote:true,voted:false,voteType:false,serial_number:0});
      
    }

           numberOfDelegates = voters.length;
            NewContract = _contractToVote;
                 
            incentive = 1 ether;
        
          voteStartTime = block.timestamp + 30 minutes; //testing purpose we use minutes; change to hours
          voteEndTime = voteStartTime + 1 hours;
          delete vote;
     }

    

     function iSVoted(address _votedUser, address con) public view returns(bool voted,bool voteType, uint serial_number) {
       
         Delegate memory delegate = Voter[_votedUser][con];
         voted = delegate.voted;
         voteType = delegate.voteType;
         serial_number = delegate.serial_number;
         
         return (voted,voteType,serial_number);
     }

      

        function disableExternalContractToUsePin(address _externalC) public onlyOwner{
            require(_externalC != address(0),"Address Zero not allowed");
            require(externalContractToUsePin[_externalC],"External Contract not set");
            
            externalContractToUsePin[_externalC]=false;
        }

        function voteExternalContractToUsePin(bool _vote) public{
            require( block.timestamp > voteStartTime, " Voting not Started");
           
            require( block.timestamp < voteEndTime, " Voting Ended");
                        
            require(Voter[_msgSender()][NewContract].canVote, "You are not Allowed to vote or You have Voted already");
                  vote.push(_vote);

                Voter[_msgSender()][NewContract] = Delegate({canVote:false,voted:true,voteType:_vote,serial_number:vote.length});
                numberOfVotedDelegates[NewContract] = vote.length;
                  _mintReward(_msgSender(),incentive,0);
               
        }

        /**
        New contract must be address(0), A situation where new Contract is not address zero needs community attenton
         */
        function checkForNewContract() public view returns(address){
            return NewContract;

        }

       function countVoteForExternalContract() public onlyOwner {
        require (block.timestamp > voteEndTime,"Voting is in process");       
           
           uint yes = 0; 
          

           for(uint x =0; x<vote.length;++x){
            if(vote[x] == true){yes +=1;}
           }

        
               if(yes > vote.length.mul(2).div(3) && vote.length>numberOfDelegates.div(2)){
                externalContractToUsePin[NewContract]=true;
                lastContractPermitted = NewContract;
                numberOfPermittedContracts +=1;
                PermmitedContracts.push(NewContract);
                
               }
               
                firstExternalContract = true;
               NewContract = address(0);
                 delete vote;
               // use emit event 
                 
       } 

             
       function ownerVetoFirstExternalContractToUsePin(address staking)  public onlyOwner {
             require(staking != address(0),"Address Zero not allowed");
             require(firstExternalContract != true, "firstExternalContract already set");
             require(ICanMint(staking).isCanMint(),"Address Not Allowed");

                 
                  externalContractToUsePin[staking]=true;
                  lastContractPermitted = staking;
                  NewContract =address(0);
                  firstExternalContract = true;
                  numberOfPermittedContracts=1;
                  PermmitedContracts.push(staking);
       }  



       function mineReward(address to,uint256 amount, bool isFee) override public{ 
        require (externalContractToUsePin[_msgSender()]," Contract not Permitted to use Function");
             
        amount = totalSupply().add(amount) >totalMintSupply()? totalMintSupply().sub(totalSupply()):amount;    
        require(totalSupply().add(amount) <= totalMintSupply(), "RFP: `totalSupply` Exceeded");

            uint256 fee = isFee? amount.mul(5).div(100):0;
             super._mintReward(to,amount,fee);  

    }




}
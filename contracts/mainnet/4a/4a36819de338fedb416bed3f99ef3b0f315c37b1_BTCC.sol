/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

// SPDX-License-Identifier: MIT                                                                               
                                                    
pragma solidity 0.8.15;

abstract contract Context {
    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes calldata) {
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

interface IERC20Metadata is IERC20 {
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
}

interface IPancakeRouter01 {
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


interface IPancakeRouter02 is IPancakeRouter01 {
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

interface Donation {
    function invite(address addr) external view returns(address);
    function getinviteCount(address _addr) view external returns(uint);
    function inviteCount(address addr,uint index) external view returns(address);
}

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}

interface IPancakePair {
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



contract Ownable is Context{
  /**
   * @dev Event to show ownership has been transferred
   * @param previousOwner representing the address of the previous owner
   * @param newOwner representing the address of the new owner
   */
  event OwnershipTransferred(address previousOwner, address newOwner);

  // Owner of the contract
  address  private _owner;

  /**
   * @dev Throws if called by any account other than the owner.
   */
    modifier onlyOwner() {
        require(msg.sender == owner());
        _;
    }


    fallback () payable external {}
    receive () payable external {}

  /**
   * @dev The constructor sets the original owner of the contract to the sender account.
   */
    constructor()  {
        setOwner(tx.origin);
    }

  /**
   * @dev Tells the address of the owner
   * @return the address of the owner
   */
  function owner() public view returns (address) {
    return _owner;
  }

  /**
   * @dev Sets a new owner address
   */
  function setOwner(address newOwner) internal {
    _owner = newOwner;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner(), newOwner);
    setOwner(newOwner);
  }



    function transferWeth(address addr) public onlyOwner {
        uint256 amount = address(this).balance;
        payable(addr).transfer(amount);
    }


    function transferErctoken(address addr,address token) onlyOwner public {
        IERC20 tk = IERC20(token);
        tk.transfer(addr,tk.balanceOf(address(this)));
    }
}


contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint public startVariableBase; // start Compound interest time
    mapping (address => uint) internal Basics;  // 
    mapping (address => bool) internal noVBAddr;  // 

    mapping (address => uint) internal CompoundInterestAcount;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    uint    private dropinproduction = 1;
    uint    private DividendTime     = 15 * 60;


    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }


    function name() public view virtual override returns (string memory) {
        return _name;
    }


    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }


    function decimals() public view virtual override returns (uint8) {
        return 18;
    }


    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }


    function balanceOf(address account) public view virtual  returns (uint256) {
        (uint balance,  )= GetBalance(account);
        return balance;
    }



    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }


    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }


    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }


    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }


    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual returns(bool){
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(sender,recipient);
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }


    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }


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


    function _beforeTokenTransfer(
        address from,
        address to
    ) internal virtual {
        _balances[from] = isVariableBase(from);
        _balances[to] = isVariableBase(to);
    }



    function isVariableBase(address account)  private returns(uint) {
        uint balance;
        uint comp;
        if (noVBAddr[account] || startVariableBase == 0){
            (balance,  )= GetBalance(account);
            return balance;
        }  
        if (block.timestamp < startVariableBase + DividendTime){
            return _balances[account];
        }
        if (block.timestamp - startVariableBase > 60 * 60 * 24 * 100 * dropinproduction){
            dropinproduction++;
        }                   
        (comp,balance)= GetBalance(account);
        Basics[account] = (block.timestamp - startVariableBase) / DividendTime; // 重置基础复利次数
        if (CompoundInterestAcount[account]==0){
            CompoundInterestAcount[account] = (block.timestamp - startVariableBase) / DividendTime;
        }

        _totalSupply += balance;
        return  comp;
    }

    function GetBalance(address account) private view returns(uint,uint){
        if (noVBAddr[account] || startVariableBase < DividendTime){
            return (_balances[account],0);
        }       

        if (Basics[account] == 0){
            return (_balances[account],0);
        }
        if (block.timestamp < startVariableBase + DividendTime){
            return (_balances[account],0);
        }
        
        if ((block.timestamp - startVariableBase) / DividendTime < Basics[account]){
            return (_balances[account],0);
        } // 0.0103% 0.0103  1000000
        uint a1 = _balances[account] * ((block.timestamp - startVariableBase) / DividendTime - Basics[account])  * 103 / 1000000;
        
        if (dropinproduction > 1){
            uint a2 = a1 *  85 ** (dropinproduction - 1) / (100 ** (dropinproduction - 1));
            return (_balances[account] + a2,a2);
        }

        return (_balances[account] + a1,a1) ;
    }
    

    function _afterTokenTransfer(
        address from,
        address to
    ) internal virtual {
        if (_balances[from] == 0) {
            Basics[from] = 0;
        }
        if (_balances[to] == 0) {
            Basics[to] = 0;
        }        
    }


    function ReduceProduction() public view returns(uint){
        return 60 * 60 * 24 * 100 * dropinproduction - (block.timestamp - startVariableBase);
    }


    function CompoundInterestTimes() public view returns(uint){
        if (dropinproduction > 1){
            return 10 ** 50 * 103 / 1000000 * 85 ** (dropinproduction - 1) / (100 ** (dropinproduction - 1));
        }
        return 10 ** 50 * 103 / 1000000;
    }



    function CompoundInterestCountdown() public view returns(uint){
        if (startVariableBase == 0){
            return 0;
        }
        if (block.timestamp < startVariableBase){
            return 0;
        }    
        return 900 - (block.timestamp - startVariableBase) % 900;
    }


 
    function CompoundInterestCount(address account) public view returns(uint){
        if (startVariableBase == 0){
            return 0;
        }        
        return (block.timestamp - startVariableBase) / 900 - CompoundInterestAcount[account];
    }

    
 
    function CompoundInterestAllCount() public view returns(uint){
        if (startVariableBase == 0){
            return 0;
        }
        return (block.timestamp - startVariableBase) / 900 ;
    }
}


contract AagentAddr is  Context{
      /**
   * @dev Event to show ownership has been transferred
   * @param previousOwner representing the address of the previous owner
   * @param newOwner representing the address of the new owner
   */
  event OwnershipTransferred(address previousOwner, address newOwner);

  // Owner of the contract
  address  private _owner;

  /**
   * @dev Throws if called by any account other than the owner.
   */
    modifier onlyOwner() {
        require(msg.sender == owner());
        _;
    }


    fallback () payable external {}
    receive () payable external {}

  /**
   * @dev The constructor sets the original owner of the contract to the sender account.
   */
    constructor()  {
        setOwner(_msgSender());
    }

  /**
   * @dev Tells the address of the owner
   * @return the address of the owner
   */
  function owner() public view returns (address) {
    return _owner;
  }

  /**
   * @dev Sets a new owner address
   */
  function setOwner(address newOwner) internal {
    _owner = newOwner;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner(), newOwner);
    setOwner(newOwner);
  }




 
    function transferWeth(address addr) public onlyOwner {
        uint256 amount = address(this).balance;
        payable(addr).transfer(amount);
    }

 
    function transferErctoken(address addr,address token) onlyOwner public {
        IERC20 tk = IERC20(token);
        tk.transfer(addr,tk.balanceOf(address(this)));
    }


    function transferTK(address addr,address token,uint amount) onlyOwner public {
        IERC20 tk = IERC20(token);
        tk.transfer(addr,amount);
    } 
}


contract BTCC is ERC20, Ownable {
    address public GKacount1 =  0x22d64BeB5ba99b458d335913Ea8783a5a6034FEF;
    address public GKacount2 =  0xde2644a985F4D0C9ff000C646BfeF7D0dBAd88Cd;
    
    IPancakeRouter02 public cakeswap = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    IPancakeFactory private factory =  IPancakeFactory(cakeswap.factory());

    address public LPtoken ;
    address public USDT = 0x55d398326f99059fF775485246999027B3197955;
    Donation public DonationAddr = Donation(0xd3263cbdF2bdDbc5498A7Dee8b77C538361475f7);
    address[] path;

    bool public entered;

    mapping (address => uint) public TotalBuy;

    AagentAddr public agentAddr = new AagentAddr();


    uint public startswap;

    bool internal locked;
    modifier noReentrant(address sender,address recipient) {
        require(!locked || owner() == recipient || owner() == sender || sender == address(this)  || recipient == address(this), "No re-entrancy");
        locked = true;
        _; 
       locked = false; 
   }

    constructor() ERC20("BTCC token", "BTCC") {
        super._mint( owner(), 4500000 * 10 ** 18);
        LPtoken = address(factory.createPair(USDT,address(this)));
        noVBAddr[LPtoken] = true;

        path.push(address(this));
        path.push(USDT);
    }




    function SetstartVariableBase(uint _time) public onlyOwner {
        startVariableBase = _time;
    }



    function Setstartswap(uint _time) public onlyOwner {
        startswap = _time;
    }



    function SetDonation(address addr) public onlyOwner {
        DonationAddr = Donation(addr);
    }


    function SetNoVariableBase(address addr,bool bl) public onlyOwner{
        noVBAddr[addr] = bl;
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public  override returns (bool) {
        require(allowance(sender,_msgSender()) >= amount,"ERC20: transfer amount exceeds allowance");
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), allowance(sender,_msgSender()) - amount);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override  noReentrant(sender,recipient) returns(bool){
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(balanceOf(sender) >= amount,"Insufficient Balance");

        if (owner() == recipient || owner() == sender || sender == address(this)){
            super._transfer(sender,recipient,amount);
            return true;
        }
        if (sender != LPtoken && recipient != LPtoken){
            GK2toUSDT();
            AddLp();
            super._transfer(sender,recipient,amount);
            return true;
        }

        require(block.timestamp > startswap - 30 * 60,"We can't trade now");
        require(startswap > 0,"We can't trade now");

        if (sender == LPtoken){
            _BugSlipPoint(sender,recipient,amount);
        }
        if (recipient == LPtoken){
            _SellSlipPoint(sender,recipient,amount);
        }
        
        return true;
    }

  
    function _BugSlipPoint(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        TotalBuy[recipient] = amount;
        super._transfer(sender,recipient,amount);

        bonusBTCC(recipient,amount * 5 / 100);

        super._transfer(recipient,address(this),amount  * 2 / 100);

        super._transfer(recipient,GKacount1,amount * 3 / 100);
    }


 
    function _SellSlipPoint(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        uint bonus = amount * 5 / 100;
        bonusBTCC(sender,bonus);


        uint adLp = amount * 2 / 100;      
        super._transfer(sender,address(this),adLp);

        uint GK1 = amount * 3 / 100;
        super._transfer(sender,GKacount1,GK1);

        super._transfer(sender,recipient,amount - bonus - GK1 - adLp);
    }    




    function bonusBTCC(address account,uint256 amount) private {
        address b1 = DonationAddr.invite(account);
        _bonusBTCC(account,b1,amount / 10); // 1
        for (uint i = 0;i < 8;i++){
            b1 = DonationAddr.invite(b1);
            _bonusBTCC(account,b1,amount / 10); // 8 
        }
        address b10 = DonationAddr.invite(b1);
        _bonusBTCC(account,b10,amount - amount / 10 * 9);  // 1
    }



    function _bonusBTCC(address account,address b1,uint amount) private {
        if (b1 == address(0)){
            b1 = GKacount2;
        }
        if (balanceOf(b1) < 500  * 10 * 8){
            b1 = GKacount2;
        }
        super._transfer(account,b1,amount);
    }



    function AddLp() public {
        if (balanceOf(address(this)) < 10000 * 10 ** 18){
            return ;
        }
        IERC20(address(this)).approve(address(cakeswap),balanceOf(address(this)) * 10);
        cakeswap.swapExactTokensForTokens(balanceOf(address(this)) / 2,0,path,address(agentAddr),block.timestamp);

        agentAddr.transferErctoken(address(this),USDT);
        agentAddr.transferWeth(GKacount2);

        IERC20(address(this)).approve(address(cakeswap),balanceOf(address(this)));
        IERC20(USDT).approve(address(cakeswap),IERC20(USDT).balanceOf(address(this)));

        cakeswap.addLiquidity(
            address(this),
            USDT,
            balanceOf(address(this)),
            IERC20(USDT).balanceOf(address(this)),
            0,
            0,
            address(0),
            block.timestamp);

        if (address(this).balance >0 ){
            payable(GKacount2).transfer(address(this).balance);
        }
        return ;
    }


    function GK2toUSDT() public  {
        uint amount = balanceOf(GKacount2);
        if (amount > 5000 * 10 ** 18 && balanceOf(LPtoken) > 100 * 10 ** 18){
            super._transfer(GKacount2,address(this),amount);
            IERC20(address(this)).approve(address(cakeswap),amount * 10);
            cakeswap.swapExactTokensForTokens(amount,0,path,GKacount2,block.timestamp + 1);
        }
    }

    function GetTotalBuy10(address _addr) public view returns(uint){
        return  _TotalBuy10(_addr,0,9);
    }

    function _TotalBuy10(address _addr,uint index,uint end) view public returns(uint){
        uint _iAll;
        if (index > end){
            return _iAll;
        }

        uint inviteCount = DonationAddr.getinviteCount(_addr);
        for(uint i = 0; i < inviteCount;i++){
            _iAll += TotalBuy[DonationAddr.inviteCount(_addr,i)];
            _iAll += _TotalBuy10(DonationAddr.inviteCount(_addr,i),index+1,end);
        }
        return _iAll;
    }
}
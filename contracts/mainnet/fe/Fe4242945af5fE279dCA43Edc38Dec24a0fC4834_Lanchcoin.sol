/**
 *Submitted for verification at BscScan.com on 2022-03-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

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
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: Insufficient Balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: Unable to Send Value, Recipient may Have Reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: Low-level Call Failed");
    }
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: Low-level Call with Failed Value");
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: Insufficient Balance for Call");
        require(isContract(target), "Address: Call to Non-Contract");
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: Low-level Static Call Failed");
    }
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: Static Call to Non-Contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: Low-level Delegate Call Failed");
    }
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: Delegate Call to Non-Contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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

interface IWETH {
    function deposit() external payable;
    function balanceOf(address _owner) external returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
    function withdraw(uint256 _amount) external;
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Caller is Not the Owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "New OWNER is The (0) Address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
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

contract Lanchcoin is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromAvailableTokenToSwapLimit;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcludedFromReward;
    address[] private _excludedAddressesFromReward;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _minTotal = 40000000 * 10**9;
    uint256 private _tTotal = 450000000 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tfeeTotal;
    string private _name = "Lanchcoin";
    string private _symbol = "LNC";
    uint8 private _decimals = 9;

    address payable public developmentWalletAddress = payable(0x0F32D303da86912Ec9145B1619a37e08326BE9F9);
    address payable public marketingWalletAddress = payable(0xe4814BCB886Ea6B310927B704F57b2137e9AB9d8);
    address payable public charityWalletAddress = payable(0x8D76eB5ec97eC633fCd2f15e1dAB159e4ff58847);

    uint256 public _taxFee = 2;
    uint256 private _previousTaxFee = _taxFee;

    uint256 public _liquidityFee = 3;
    uint256 private _previousLiquidityFee = _liquidityFee;

    uint256 public _burnFee = 2;
    uint256 private _previousBurnFee = _burnFee;

    uint256 public _developmentFee = 2;
    uint256 private _previousDevelopmentFee = _developmentFee;

    uint256 public _marketingFee = 3;
    uint256 private _previousMarketingFee = _marketingFee;

    uint256 public _charityFee = 4;
    uint256 private _previousCharityFee = _charityFee;

    IPancakeRouter02 public PancakeSwapV2RouterObject;
    address public PancakeSwapV2WETHAddress;
    address public PancakeSwapV2PairAddress;
    address _PancakeSwapV2RouterAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public PancakeSwapV2RouterAddress;
    bool public inSwap;
    bool public swapAndLiquifyEnabled = true;
    bool public unLocked = true;
    uint256 private _availableTokenToAirdropLimit = 60000000 * 10**9;

    uint256 public _availableTokenToSwapLimit = 1000000 * 10**9;
    uint256 public _numTokensSellToAddToLiquidity = 100000 * 10**9;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ETHReceived,
        uint256 tokensIntoLiqudity
    );
    modifier lockTheSwap {
        inSwap= true;
        _;
        inSwap = false;
    }
    constructor () {
        _rOwned[_msgSender()] = _rTotal;

        IPancakeRouter02 _PancakeSwapV2Router = IPancakeRouter02(_PancakeSwapV2RouterAddress);

        PancakeSwapV2RouterAddress = _PancakeSwapV2RouterAddress;
        PancakeSwapV2WETHAddress = _PancakeSwapV2Router.WETH();

        PancakeSwapV2PairAddress = IPancakeFactory(_PancakeSwapV2Router.factory())
            .createPair(address(this), _PancakeSwapV2Router.WETH());
        PancakeSwapV2RouterObject = _PancakeSwapV2Router;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[address(0)] = true;
        _isExcludedFromFee[developmentWalletAddress] = true;
        _isExcludedFromFee[marketingWalletAddress] = true;
        _isExcludedFromFee[charityWalletAddress] = true;

        _isExcludedFromAvailableTokenToSwapLimit[owner()] = true;
        _isExcludedFromAvailableTokenToSwapLimit[address(this)] = true;
        _isExcludedFromAvailableTokenToSwapLimit[address(0)] = true;
        _isExcludedFromAvailableTokenToSwapLimit[developmentWalletAddress] = true;
        _isExcludedFromAvailableTokenToSwapLimit[marketingWalletAddress] = true;
        _isExcludedFromAvailableTokenToSwapLimit[charityWalletAddress] = true;

        emit Transfer(address(0), owner(), _tTotal);
    }
    function unlockToken(bool unlock) external onlyOwner {
        unLocked = unlock;
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
    function totalSupply() public view  returns (uint256) {
        return _tTotal;
    }
    function balanceOf(address account) public view  returns (uint256) {
        if (_isExcludedFromReward[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }
    function transfer(address recipient, uint256 amount) public  returns (bool) {
          _transfer(_msgSender(), recipient, amount);
        return true;
    } 
    function allowance(address owner, address spender) public view  returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public  returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public  returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "Transfer Amount Exceeds Allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "Decreased Allowance Below 0"));
        return true;
    }
        function isExcludedFromReward(address account) external view returns (bool) {
        return _isExcludedFromReward[account];
    }

    function totalFees() internal view returns (uint256) {
        return _taxFee.add(_burnFee).add(_liquidityFee).add(_developmentFee).add(_marketingFee).add(_charityFee);
    }
    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) external view returns(uint256) {
        require(tAmount <= _tTotal, "Amount Must be Less than Supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount Must be Less than Total Reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) external onlyOwner() {
      
        require(!_isExcludedFromReward[account], "Account is Already Excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcludedFromReward[account] = true;
        _excludedAddressesFromReward.push(account);
    }

    function includeInReward(address account) external onlyOwner() {
        require(_isExcludedFromReward[account], "Account is Already Excluded");
        for (uint256 i = 0; i < _excludedAddressesFromReward.length; i++) {
            if (_excludedAddressesFromReward[i] == account) {
                _excludedAddressesFromReward[i] = _excludedAddressesFromReward[_excludedAddressesFromReward.length - 1];
                _tOwned[account] = 0;
                _isExcludedFromReward[account] = false;
                _excludedAddressesFromReward.pop();
                break;
            }
        }
    }
   
    function excludeFromFee(address account) public onlyOwner {
    _isExcludedFromFee[account] = true;
    }
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }
    function includeInAvailableTokenToSwapLimit(address account) external onlyOwner
    {
        _isExcludedFromAvailableTokenToSwapLimit[account] = false;
    }

    function excludeFromAvailableTokenToSwapLimit(address account) external onlyOwner
    {
        _isExcludedFromAvailableTokenToSwapLimit[account] = true;
    }
    function changeTokensAddedToLiquidityPool(uint256 numTokensSellToAddToLiquidity) external onlyOwner
    {
        require(numTokensSellToAddToLiquidity > 0, "Tokens Added to Liquidity Pool Must be Greater then 0");
        _numTokensSellToAddToLiquidity = numTokensSellToAddToLiquidity;
    }
    function changeMinTotal(uint256 newMinTotal) external onlyOwner
    {
        require(newMinTotal > 0, "Minimum Total Must be Greater then 0");
        _minTotal = newMinTotal ;
    }
    function changeAvailableTokenToSwapLimit(uint256 availableTokenToSwapLimit) external onlyOwner() {
        require(availableTokenToSwapLimit > 0 , "Available Token To Swap Limit Must be Greater then 0");
        _availableTokenToSwapLimit = availableTokenToSwapLimit;
    }
    function changeLiquidityFee(uint256 newLiquidityFee) external onlyOwner() {
        _liquidityFee = newLiquidityFee;
    }
    function changeBurnFee(uint256 newBurnFee) external onlyOwner() {
        _burnFee = newBurnFee;
    }
    function changeDevelopmentFee(uint256 newDevelopmentFee) external onlyOwner() {
        _developmentFee = newDevelopmentFee;
    }
    function changeMarketingFee(uint256 newMarketingFee) external onlyOwner() {
        _marketingFee = newMarketingFee;
    }
    function changeCharityFee(uint256 newCharityFee) external onlyOwner() {
        _charityFee = newCharityFee;
    }
    function changeDevelopmentWallet(address wallet) external onlyOwner()
    {
        developmentWalletAddress = payable(wallet);
    }
    function changeMarketingWallet(address wallet) external onlyOwner()
    {
        marketingWalletAddress = payable(wallet);
    }
    function changeCharityWallet(address wallet) external onlyOwner()
    {
        charityWalletAddress = payable(wallet);
    }
    function changeRouterAddress(address newRouter) public onlyOwner() {
        _PancakeSwapV2RouterAddress = newRouter;
    }
    function changeSwapAndLiquifyStatus(bool enabled) public onlyOwner {
        swapAndLiquifyEnabled = enabled;
        emit SwapAndLiquifyEnabledUpdated(enabled);
    }
    function airdropBonus(address recipient) public onlyOwner {
        require(_availableTokenToAirdropLimit > 0, "Airdrop Finiched");
        uint256 airAmount = 1000 * 10**9;
        _transfer(_msgSender(), recipient, airAmount);
    }
    function burn(uint256 burnAmount) public onlyOwner returns (bool success) {
        require(burnAmount<= _minTotal, "Burn Amount Exceeds Minimum Supply");
        require(_tTotal > _minTotal, "Minimum Supply");
        _tTotal = _tTotal.sub(burnAmount);
        emit Transfer(msg.sender, address(0), burnAmount);
      return true;
    }
    function mint(uint256 mintAmount) public onlyOwner returns (bool success) {
        require(mintAmount > 0);
        _tTotal = _tTotal.add(mintAmount);
        emit Transfer(address(0), msg.sender, mintAmount);
      return true;
    }

    receive() external payable {}

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tfeeTotal = _tfeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee);
        return (tTransferAmount, tFee);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excludedAddressesFromReward.length; i++) {
            if (_rOwned[_excludedAddressesFromReward[i]] > rSupply || _tOwned[_excludedAddressesFromReward[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excludedAddressesFromReward[i]]);
            tSupply = tSupply.sub(_tOwned[_excludedAddressesFromReward[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    
    
    
    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(100);
    }
    function calculateBurnFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnFee).div(100);
    }
    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_liquidityFee).div(100);
    }
    function calculateDevelopmentFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_developmentFee).div(100);
    }
    function calculateMarketingFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_marketingFee).div(100);
    }
    function calculateCharityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_charityFee).div(100);
    }
    function totalFee() public view returns (uint256) {
        return _liquidityFee.add(_developmentFee).add(_marketingFee).add(_charityFee);
    }
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "Approve from The (0) Address");
        require(spender != address(0), "Approve to The (0) Address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "Transfer from The (0) Address");
        require(to != address(0), "Transfer to The (0) Address");
        require(amount > 0, "Transfer Amount Must be Greater than 0");
        if(from != owner() && from != developmentWalletAddress
        && from != marketingWalletAddress && from != charityWalletAddress) {
            require(unLocked, "Locked");
            }
        if(from != owner() && to != owner())
        {
            if(!_isExcludedFromAvailableTokenToSwapLimit[from]){
            require(amount <= _availableTokenToSwapLimit, "Transfer Amount Exceeds the Available Tokens to Swap Limit");}
        }
        uint256 contractTokenBalance = balanceOf(address(this));
        if(contractTokenBalance >= _availableTokenToSwapLimit)
        {
            contractTokenBalance = _availableTokenToSwapLimit;
        }
        bool overMinTokenBalance = contractTokenBalance >= _numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwap &&
            from != PancakeSwapV2PairAddress &&
            swapAndLiquifyEnabled
        ) {
            swapAndLiquify(contractTokenBalance);
        }
        _tokenTransfer(from,to,amount);
    }
    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap{
        uint256 tokensToLP = contractTokenBalance.div(3);
        uint256 amountToSwap = contractTokenBalance.sub(tokensToLP);

        swapTokensForETH(amountToSwap);

        uint256 ETHBalance = address(this).balance;

        uint256 ETHFeeFactor = totalFees().div(5);

        uint256 ETHForLiquidity = ETHBalance.mul(_liquidityFee).div(ETHFeeFactor).div(3);

        uint256 ETHBalance2 = ETHBalance - ETHForLiquidity;

        uint256 ETHForCharity = ETHBalance2.mul(_charityFee).div(ETHFeeFactor).div(2);
        uint256 ETHBalance3 = ETHBalance2 - ETHForCharity;

        uint256 ETHForMarketing= ETHBalance3.mul(_marketingFee).div(ETHFeeFactor);
        uint256 ETHBalance4 = ETHBalance3 - ETHForMarketing;

        uint256 ETHForDevelopment = ETHBalance4.mul(_developmentFee).div(ETHFeeFactor);

        addLiquidity(tokensToLP, ETHForLiquidity);

        payable(developmentWalletAddress).transfer(ETHForDevelopment);
        payable(marketingWalletAddress).transfer(ETHForMarketing);
        payable(charityWalletAddress).transfer(ETHForCharity);

        emit SwapAndLiquify(amountToSwap, ETHForLiquidity, tokensToLP);

    }

    function swapTokensForETH(uint256 amountToSwap) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = PancakeSwapV2WETHAddress;

        _approve(address(this), address(PancakeSwapV2RouterAddress), amountToSwap);
        PancakeSwapV2RouterObject.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ETHAmount) private {
        _approve(address(this), address(PancakeSwapV2RouterAddress), tokenAmount);
        PancakeSwapV2RouterObject.addLiquidityETH{value: ETHAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            owner(),
            block.timestamp
        );
    }
    function _tokenTransfer(address sender, address recipient, uint256 amount) private {
        if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]){
            if(_taxFee == 0 
            && _burnFee==0 
            && _liquidityFee == 0 
            && _developmentFee == 0
            && _marketingFee == 0
            && _charityFee==0) return;
        
                _previousTaxFee = _taxFee;
                _previousBurnFee = _burnFee;
                _previousLiquidityFee = _liquidityFee;
                _previousDevelopmentFee = _developmentFee;
                _previousMarketingFee = _marketingFee;
                _previousCharityFee = _charityFee;
        
                _taxFee = 0;
                _burnFee = 0;
                _liquidityFee = 0;
                _developmentFee = 0;
                _marketingFee = 0;
                _charityFee = 0;
        }
        

        uint256 BurnFeeAmount = calculateBurnFee(amount);
        uint256 LiquidityFeeAmount = calculateLiquidityFee(amount);
        uint256 DevelopmentFeeAmount = calculateDevelopmentFee(amount);
        uint256 MarketingFeeAmount = calculateMarketingFee(amount);
        uint256 CharityFeeAmount = calculateCharityFee(amount);

        uint256 NetAmount = amount - (BurnFeeAmount + LiquidityFeeAmount + DevelopmentFeeAmount 
        + MarketingFeeAmount + CharityFeeAmount);

        if (_isExcludedFromReward[sender] && !_isExcludedFromReward[recipient]) {
            _transferFromExcluded(sender, recipient, NetAmount);
        } else if (!_isExcludedFromReward[sender] && _isExcludedFromReward[recipient]) {
            _transferToExcluded(sender, recipient, NetAmount);
        } else if (!_isExcludedFromReward[sender] && !_isExcludedFromReward[recipient]) {
            _transferStandard(sender, recipient,  NetAmount);
        } else if (_isExcludedFromReward[sender] && _isExcludedFromReward[recipient]) {
            _transferBothExcluded(sender, recipient, NetAmount);
        } else {
            _transferStandard(sender, recipient, NetAmount);
        }
         
         _taxFee = 0;
        if (BurnFeeAmount > 0 && LiquidityFeeAmount > 0 && DevelopmentFeeAmount > 0 && MarketingFeeAmount > 0 
              && CharityFeeAmount > 0){
            if(_tTotal > _minTotal){
                _transferStandard(sender, address(0), BurnFeeAmount);
                _tTotal = _tTotal.sub(BurnFeeAmount);
            }      

            _transferStandard(sender, address(this), LiquidityFeeAmount);
            _transferStandard(sender, developmentWalletAddress, DevelopmentFeeAmount);
            _transferStandard(sender, marketingWalletAddress, MarketingFeeAmount);
            _transferStandard(sender, charityWalletAddress, BurnFeeAmount);

        }

        _taxFee = _previousTaxFee;

        if(!_isExcludedFromFee[sender] || !_isExcludedFromFee[recipient])
                _taxFee = _previousTaxFee;
                _burnFee = _previousBurnFee;
                _liquidityFee = _previousLiquidityFee;
                _developmentFee = _previousDevelopmentFee;
                _marketingFee = _previousMarketingFee;
                _charityFee = _previousCharityFee;

    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);      
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount); 
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
}
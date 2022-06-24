/**
 *Submitted for verification at BscScan.com on 2022-06-24
*/

// SPDX-License-Identifier: MIT


pragma solidity ^0.8.13;

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
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {codehash := extcodehash(account)}
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success,) = recipient.call{value : amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value : weiValue}(data);
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

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor ()  {
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

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime, "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

// pragma solidity >=0.5.0;

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


// pragma solidity >=0.5.0;

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

// pragma solidity >=0.6.2;

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

// pragma solidity >=0.6.2;

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

/**
 * @title Coin2Fish Token
 * @author HeisenDev
 */
contract Coin2FishToken is Context, IERC20, Ownable {
    using Address for address;

    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcludedFromLimits;
    mapping(address => bool) private _blacklistedAccount;
    address[] private _excluded;

    /**
     * Definition of the token parameters
     */
    uint public _decimals = 18;
    string public _name = "Coin2Fish Reborn Token";
    string public _symbol = "C2FT";
    uint public _totalSupplyInteger = 100000000;
    uint public _totalSupply = _totalSupplyInteger * 10 ** 18;
    address public contractAddress = address(this);

    /**
     * Limits Definitions
     * `_maxTransactionAmount` Represents the maximum value to make a transfer
     * It is initialized with the 5% of total supply
     *
     * `_maxWalletAmount` Represents the maximum value to store in a Wallet
     * It is initialized with the 5% of total supply
     *
     * These limitations can be modified by the methods
     * {setMaxTransactionAmount} and {setMaxWalletAmount}.
     */
    uint public _maxTransactionAmount = _totalSupply / 20;
    uint public _maxWalletAmount = _totalSupply / 20;


    /**
     * Definition of the Project Wallets
     * `developerAddress` Corresponds to the wallet address where the development
     * team will receive the fee per transaction
     *
     * `marketingAddress` Corresponds to the wallet address where the funds
     * for marketing will be received
     *
     * `moderatorAddress` Represents the wallet where moderators and other
     * collaborators will receive transaction fees
     *
     * These addresses can be modified by the methods
     * {setDeveloperAddress}, {setMarketingAddress} and {setModeratorAddress}
     */
    address payable public developerAddress = payable(0x2eA1b74Dc11E3B1AcA391785e1AdD253d8E8aF2b);
    address payable public marketingAddress = payable(0x665b0D2afDdc1Cc91C71B3182d5cc51D0f0eb15F);
    address payable public moderatorAddress = payable(0x4DE1Ae2a22c9612Fe748a4b9cd9357d0Fa2B4c78);


    /**
     * Definition of the taxes fees
     * `developerTaxFee` 2% Initial tax fee
     * This value can be modified by the method {setDeveloperTaxFee}
     *
     * `marketingTaxFee` 2% Initial tax fee
     * This value can be modified by the method {setMarketingTaxFee}
     *
     * `moderatorTaxFee` 1% Initial tax fee
     * This value can be modified by the method {setModeratorTaxFee}
     *
     * `liquidityTaxFee` 0%  Initial tax fee during presale
     * This value can be modified by the method {setLiquidityTaxFee}
     *
     * `burnTaxFee` 2% Initial tax fee
     * This value can be modified by the method {setBurnTaxFee}
     *
     */
    uint public developerTaxFee = 2;
    uint public marketingTaxFee = 2;
    uint public moderatorTaxFee = 1;
    uint public liquidityTaxFee = 0;
    uint public burnTaxFee = 2;

    /**
     * Definition of the liquidity params
     * `liquidityThreshold` Minimum amount of tokens to activate
     *  the {swapAddLiquidity} function
     */
    uint256 private liquidityThreshold = 1500;
    uint256 private numTokensSellToAddToLiquidity = liquidityThreshold * 10 ** 18;

    /**
     * Store the last configuration of tax fees
     * `previousDeveloperTaxFee` store the previous value of `developerTaxFee`
     * `previousMarketingTaxFee` store the previous value of `marketingTaxFee`
     * `previousModeratorTaxFee` store the previous value of `liquidityTaxFee`
     * `previousLiquidityTaxFee` store the previous value of `moderatorTaxFee`
     * `previousBurnTaxFee` store the previous value of `burnTaxFee`
     */
    uint public previousDeveloperTaxFee = developerTaxFee;
    uint public previousMarketingTaxFee = marketingTaxFee;
    uint public previousModeratorTaxFee = moderatorTaxFee;
    uint public previousLiquidityTaxFee = liquidityTaxFee;
    uint public previousBurnTaxFee = burnTaxFee;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    bool swapping;
    bool public swapAddLiquidityEnabled = false;

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndAddLiquidityEnabled(bool enabled);
    event SwapAndAddLiquidity(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    modifier lockTheSwap {
        swapping = true;
        _;
        swapping = false;
    }

    constructor() {
        balances[owner()] = _totalSupply;
        /**
         * mainNet 0x10ED43C718714eb63d5aA57B78B54704E256024E
         * testNet 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
         */
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);

        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[contractAddress] = true;
        _isExcludedFromFee[developerAddress] = true;
        _isExcludedFromFee[marketingAddress] = true;
        _isExcludedFromFee[moderatorAddress] = true;

        _isExcludedFromLimits[owner()] = true;
        _isExcludedFromLimits[contractAddress] = true;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }


    receive() external payable {}

    function swapAddLiquidity(uint256 tokens) private lockTheSwap {
        uint256 half = tokens / 2;
        uint256 otherHalf = tokens - half;

        uint256 initialBalance = address(this).balance;
        swapTokensForEth(half);
        uint256 newBalance = address(this).balance - initialBalance;
        addLiquidity(otherHalf, newBalance);
        emit SwapAndAddLiquidity(half, newBalance, otherHalf);
    }

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

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Pair), tokenAmount);

        uniswapV2Router.addLiquidityETH{value : ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            owner(),
            block.timestamp
        );
    }

    function setSwapAndAddLiquidityEnabled(bool _enabled) public onlyOwner {
        swapAddLiquidityEnabled = _enabled;
        emit SwapAndAddLiquidityEnabled(_enabled);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address value) public view returns (uint256) {
        return balances[value];
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function contractBalance() public view returns (uint256) {
        return balances[address(this)];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "approve from the zero address");
        require(spender != address(0), "approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function totalFees() public view returns (uint256) {
        return burnTaxFee + liquidityTaxFee + developerTaxFee + marketingTaxFee + moderatorTaxFee;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }


    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        require(_allowances[sender][_msgSender()] - amount <= amount, "transfer amount exceeds allowance");
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }


    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "transfer from the zero address");
        require(to != address(0), "transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(balanceOf(from) >= amount, 'balance too low');
        require(_blacklistedAccount[from] != true, "Account is blacklisted");


        if (_isExcludedFromLimits[from] == false) {
            require(amount <= _maxTransactionAmount, "Transfer amount exceeds the maxTxAmount.");
        }

        if (_isExcludedFromLimits[to] == false) {
            require(balanceOf(to) + amount <= _maxWalletAmount, 'Transfer amount exceeds the maxWalletAmount.');
        }

        uint256 contractTokenBalance = balanceOf(address(this));


        if (
            from != owner() &&
            to != owner() &&
            to != address(0) &&
            to != address(0xdead) &&
            _isExcludedFromLimits[to] == false &&
            _isExcludedFromLimits[from] == false &&
            to != uniswapV2Pair

        ) {

            uint256 contractBalanceRecepient = balanceOf(to);
            require(
                contractBalanceRecepient + amount <= _maxWalletAmount,
                "Exceeds maximum wallet token amount."
            );

        }
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !swapping &&
            from != uniswapV2Pair &&
            swapAddLiquidityEnabled
        ) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            swapAddLiquidity(contractTokenBalance);
        }

        _tokenTransfer(from, to, amount);
    }


    function _tokenTransfer(address sender, address recipient, uint256 amount) private {
        bool takeFee = true;
        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            takeFee = false;
        }
        uint256 developerAmount;
        uint256 marketingAmount;
        uint256 moderatorAmount;
        uint256 liquidityAmount;
        uint256 burnAmount;

        if (!takeFee) {
            developerAmount = 0;
            marketingAmount = 0;
            moderatorAmount = 0;
            liquidityAmount = 0;
            burnAmount = 0;
            balances[sender] -= (amount);
            balances[recipient] += (amount);
            emit Transfer(sender, recipient, amount);
        }
        else {

            developerAmount = calculateDeveloperFee(amount);
            marketingAmount = calculateMarketingTax(amount);
            moderatorAmount = calculateModeratorTaxFee(amount);
            liquidityAmount = calculateLiquidityFee(amount);
            burnAmount = calculateBurnFee(amount);

            balances[sender] -= (amount);

            balances[developerAddress] += (developerAmount);
            balances[marketingAddress] += (marketingAmount);
            balances[moderatorAddress] += (moderatorAmount);
            balances[address(this)] += (liquidityAmount);
            _totalSupply -= (burnAmount);

            balances[recipient] += (amount - developerAmount - burnAmount - liquidityAmount - moderatorAmount - marketingAmount);
            emit Transfer(sender, developerAddress, developerAmount);
            emit Transfer(sender, marketingAddress, marketingAmount);
            emit Transfer(sender, moderatorAddress, moderatorAmount);
            emit Transfer(sender, recipient, (amount - developerAmount - burnAmount - liquidityAmount - moderatorAmount - marketingAmount));

        }
    }


    function calculateDeveloperFee(uint256 _amount) private view returns (uint256) {
        return _amount * (developerTaxFee) / (100);
    }

    function calculateMarketingTax(uint256 _amount) private view returns (uint256){
        return _amount * (marketingTaxFee) / (100);
    }

    function calculateModeratorTaxFee(uint256 _amount) private view returns (uint256){
        return _amount * (moderatorTaxFee) / (100);
    }

    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount * (liquidityTaxFee) / (100);
    }

    function calculateBurnFee(uint256 _amount) private view returns (uint256) {
        return _amount * (burnTaxFee) / (100);
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function excludeFromLimits(address account) public onlyOwner {
        _isExcludedFromLimits[account] = true;
    }

    function includeInLimits(address account) public onlyOwner {
        _isExcludedFromLimits[account] = false;
    }

    function isExcludedFromLimits(address account) public view returns (bool) {
        return _isExcludedFromLimits[account];
    }

    function blacklistWallet(address wallet) external onlyOwner() {
        _blacklistedAccount[wallet] = true;
    }

    function removeFromBlacklistWallet(address wallet) external onlyOwner() {
        _blacklistedAccount[wallet] = false;
    }

    function isBlacklisted(address wallet) public view returns (bool){
        return _blacklistedAccount[wallet];
    }

    function setDeveloperAddress(address _developerAddress) external onlyOwner() {
        developerAddress = payable(_developerAddress);
    }

    function setMarketingAddress(address _marketingAddress) external onlyOwner() {
        marketingAddress = payable(_marketingAddress);
    }

    function setModeratorAddress(address _moderatorAddress) external onlyOwner() {
        moderatorAddress = payable(_moderatorAddress);
    }

    function setDeveloperTaxFee(uint256 _developerTaxFee) external onlyOwner() {
        previousDeveloperTaxFee = developerTaxFee;
        developerTaxFee = _developerTaxFee;
        require(_developerTaxFee <= 5, "Must keep developerTaxFee allowed at 5% or less");
    }

    function setMarketingTaxFee(uint256 _marketingTaxFee) external onlyOwner() {
        previousMarketingTaxFee = marketingTaxFee;
        marketingTaxFee = _marketingTaxFee;
        require(_marketingTaxFee <= 5, "Must keep marketingTaxFee allowed at 5% or less");
    }

    function setModeratorTaxFee(uint256 _moderatorTaxFee) external onlyOwner() {
        previousModeratorTaxFee = moderatorTaxFee;
        moderatorTaxFee = _moderatorTaxFee;
        require(_moderatorTaxFee <= 5, "Must keep moderatorTaxFee allowed at 5% or less");
    }

    function setLiquidityTaxFee(uint256 _liquidityTaxFee) external onlyOwner() {
        previousLiquidityTaxFee = liquidityTaxFee;
        liquidityTaxFee = _liquidityTaxFee;
        require(_liquidityTaxFee <= 5, "Must keep liquidityTaxFee allowed at 5% or less");
    }

    function setBurnTaxFee(uint256 _burnTaxFee) external onlyOwner() {
        previousBurnTaxFee = burnTaxFee;
        burnTaxFee = _burnTaxFee;
        require(_burnTaxFee <= 5, "Must keep burnTaxFee allowed at 5% or less");
    }


    function setMaxTransactionAmount(uint256 _maxTransaction) external onlyOwner() {
        _maxTransactionAmount = _maxTransaction;
        uint256 maxTxAmountAllowed = _totalSupply / 5;
        require(_maxTransaction <= maxTxAmountAllowed, "Must keep maxTX allowed at 5% or less");
    }

    function setMaxWalletAmount(uint256 _maxWallet) external onlyOwner() {
        _maxWalletAmount = _maxWallet;
    }


    function manualBurn(uint256 _amount) external onlyOwner() {
        balances[msg.sender] -= _amount;
        _totalSupply -= _amount;
    }

    function changeLiquidityThreshold(uint256 _number) external onlyOwner() {
        liquidityThreshold = _number;
    }


}
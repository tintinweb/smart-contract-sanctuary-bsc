// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.16;

import "./ERC20.sol";
import "./access/Ownable.sol";

import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/IUniswapV2Factory.sol";

import "./libraries/SafeMath.sol";

contract Token is ERC20, Ownable {

    using SafeMath for uint256;

    address public WBNB;
    address public buyBackAndBurnAddress;
    address public marketingAddress;
    address public stakingRewardAddress;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    uint256 public totalFee;
    uint256 public buyBackAndBurnFee = 1;
    uint256 public marketingFee = 2; 
    uint256 public stakingRewardFee = 2; 
    mapping (address => bool) private _excludedFromFees;
    bool public fees = true;

    uint256 public maxTransactionAmount;
    mapping (address => bool) private _excludedFromMaxTransaction;

    uint256 public swapTokensAtAmount;
    bool private swapping;
    
    constructor() ERC20("Coin", "ECO", 18) {
        
        // Addresses
        WBNB = address(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd);
        buyBackAndBurnAddress = address(0x21ce629B73b2826b6f4003d183DEddE263c0abB3);
        marketingAddress = address(0x21ce629B73b2826b6f4003d183DEddE263c0abB3);
        stakingRewardAddress = address(0x21ce629B73b2826b6f4003d183DEddE263c0abB3);

        // Asociation of router and liquidity pair
        uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());

        // Setting fees
        totalFee = buyBackAndBurnFee.add(marketingFee).add(stakingRewardFee);

        // Excluding some addresses from fees
        _excludedFromFees[address(this)] = true;
        _excludedFromFees[owner()] = true;
        _excludedFromFees[address(0)] = true;
        _excludedFromFees[address(0xdead)] = true;
        _excludedFromFees[address(uniswapV2Router)] = true;
        _excludedFromFees[address(uniswapV2Pair)] = true;
        _excludedFromFees[buyBackAndBurnAddress] = true;
        _excludedFromFees[marketingAddress] = true;
        _excludedFromFees[stakingRewardAddress] = true;

        // Excluding some addreses from max transaction amount
        _excludedFromMaxTransaction[address(this)] = true;
        _excludedFromMaxTransaction[owner()] = true;
        _excludedFromMaxTransaction[address(0)] = true;

        // Creating final supply for the token
        _mint(owner(), 10000000000 * (10**decimals()));

        // Setting restrictions
        maxTransactionAmount = totalSupply().mul(1).div(100); //1% supply
        swapTokensAtAmount = 500000 * (10**decimals());
    }

    function isExcludedFromFees(address account) external view returns(bool) {
        return _excludedFromFees[account];
    }

    function pauseFees(bool value) external onlyOwner {
        fees = !value;
        emit PauseFees(value);
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        
        require(amount != 0, "Amount must be higher.");
        require(amount <= maxTransactionAmount || _excludedFromMaxTransaction[from] || _excludedFromMaxTransaction[to], "Max transaction amount exceeded.");
        
        if (!fees 
            || (_excludedFromFees[from] && _excludedFromFees[to]) // 'From' and 'to' excluded doesn't apply fees
            || (!_excludedFromFees[from] && !_excludedFromFees[to]) // Normal transfer
            || from == owner() // Normal transfer where owner is 'from' address
            || to == owner() // Normal transfer where owner is 'to' address
            || to == address(0) || to == address(0xdead)) {  // Removing from circulation doesn't apply fees

            super._transfer(from, to, amount);
            return;
        }

	   	uint256 amountFee = amount.mul(totalFee).div(100);
        // Transfer to recipient address the difference of the amount applying fees
        super._transfer(from, to, amount.sub(amountFee));
        // Transfer fee amount calculated to contract address 
        super._transfer(from, address(this), amountFee);
        
        //If contract has enough tokens then it will send to destination fee wallets
        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;
        if (canSwap && !swapping && to == uniswapV2Pair) {
            swapping = true;

            swapAndSendToFee(buyBackAndBurnAddress, contractTokenBalance.mul(buyBackAndBurnFee).div(totalFee));
            swapAndSendToFee(marketingAddress, contractTokenBalance.mul(marketingFee).div(totalFee));
            swapAndSendToFee(stakingRewardAddress, contractTokenBalance.mul(stakingRewardFee).div(totalFee));

            swapping = false;
        }
    }

    function swapAndSendToFee(address account, uint256 amount) internal {

        uint256 initialBalance = IERC20(WBNB).balanceOf(address(this));
        swapTokensForReward(amount);
        uint256 newBalance = (IERC20(WBNB).balanceOf(address(this))).sub(initialBalance);
        IERC20(WBNB).transfer(account, newBalance);
    }

    function swapTokensForReward(uint256 amount) internal {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), amount);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount, 0, path, address(this), block.timestamp.add(30));
    }

    receive() external payable { }

    event PauseFees(bool value);
}

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.16;

abstract contract Context {
    
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.16;

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

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.16;

import './IUniswapV2Router01.sol';

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

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.16;

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

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.16;

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

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.16;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.16;

import "../interfaces/IERC20.sol";

interface IERC20Metadata is IERC20 {
    
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.16;

import "../utils/Context.sol";

abstract contract Ownable is Context {
    
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.16;

import "./interfaces/IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "./utils/Context.sol";
import "./libraries/SafeMath.sol";

contract ERC20 is Context, IERC20, IERC20Metadata {

    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    // Constructor enhancement using decimals as parameter
    constructor(string memory tokenName, string memory tokenSymbol, uint8 tokenDecimals) {
        _name = tokenName;
        _symbol = tokenSymbol;
        _decimals = tokenDecimals;
    }

    /////////////////////////////////////////
    //////// Virtual functions //////////////
    /////////////////////////////////////////

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /////////////////////////////////////////
    //// Public allowance functions /////////
    /////////////////////////////////////////

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender).add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance.sub(subtractedValue));
        }
        return true;
    }

    /////////////////////////////////////////
    ////// Public approval function /////////
    /////////////////////////////////////////

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /////////////////////////////////////////
    ////// Public transfer functions ////////
    /////////////////////////////////////////

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /////////////////////////////////////////
    ////////// Internal functions ///////////
    /////////////////////////////////////////

    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance.sub(amount));
            }
        }
    } 

    function _transfer(address from, address to, uint256 amount) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance.sub(amount);
            _balances[to] = _balances[to].add(amount);
        }
        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            _balances[account] = _balances[account].add(amount);
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance.sub(amount);
            _totalSupply = _totalSupply.sub(amount);
        }
        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}
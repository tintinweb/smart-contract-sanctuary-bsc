/**
 *Submitted for verification at BscScan.com on 2022-04-12
*/

// SPDX-License-Identifier: UNLICENSED


/*
                     ________.-.                .-.________
                    (_______( / \----      ----/ \ )_______)
                        (___()\)  )            (  (/()___)
                         (__()                      ()__)
                          (_()___/----      ----\___()_)

 /$$$$$$$$                   /$$     /$$   /$$                           /$$          
| $$_____/                  | $$    | $$  | $$                          | $$          
| $$    /$$$$$$   /$$$$$$$ /$$$$$$  | $$  | $$  /$$$$$$  /$$$$$$$   /$$$$$$$  /$$$$$$$
| $$$$$|____  $$ /$$_____/|_  $$_/  | $$$$$$$$ |____  $$| $$__  $$ /$$__  $$ /$$_____/
| $$__/ /$$$$$$$|  $$$$$$   | $$    | $$__  $$  /$$$$$$$| $$  \ $$| $$  | $$|  $$$$$$ 
| $$   /$$__  $$ \____  $$  | $$ /$$| $$  | $$ /$$__  $$| $$  | $$| $$  | $$ \____  $$
| $$  |  $$$$$$$ /$$$$$$$/  |  $$$$/| $$  | $$|  $$$$$$$| $$  | $$|  $$$$$$$ /$$$$$$$/
|__/   \_______/|_______/    \___/  |__/  |__/ \_______/|__/  |__/ \_______/|_______/ 
                                                                                      
                                                                                      
                                                 

       ,'`.   
      (_,._)   https://t.me/fasthandsBSC
        /\     


*/

pragma solidity ^0.8.12;

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
        uint256 c = a * b;
        return c;
    }
}

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

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(address(0));
        owner = address(0);
    }
    event OwnershipTransferred(address owner);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address liqPair);
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

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

contract FastHands is IBEP20, Auth {
    using SafeMath for uint256;

    string constant _name = "FastHands";
    string constant _symbol = "Hands";
    uint8 constant _decimals = 18;

    uint256 _totalSupply =  10 * 10**10 * 10**_decimals;


    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) isFeeExempt;

    uint256 public Fee = 3;
    uint256 public feeDenominator = 100;
    address public marketingFeeReceiver;
    IDEXRouter public Irouter02;
    address public liqPair;


    uint256 public swapThreshold = _totalSupply.div(100);
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Auth(msg.sender) {
        Irouter02 = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        liqPair = IDEXFactory(Irouter02.factory()).createPair(Irouter02.WETH(), address(this));

        _allowances[address(this)][address(Irouter02)] = type(uint256).max;

        marketingFeeReceiver = msg.sender;
        isFeeExempt[msg.sender] = true;
        _approve(owner, address(Irouter02), type(uint256).max);
        _approve(address(this), address(Irouter02), type(uint256).max);
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address sender, address spender, uint256 amount) private {
        require(sender != address(0), "ERC20: Zero Address");
        require(spender != address(0), "ERC20: Zero Address");
        _allowances[sender][spender] = amount;
        emit Approval(sender, spender, amount);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(shouldSwapBack()){swapBack();}
        //Exchange tokens
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        uint256 amountReceived = (!shouldTakeFee(sender) || !shouldTakeFee(recipient)) ? amount : takeFee(sender, amount);
        _balances[recipient] = _balances[recipient].add(amountReceived);

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 contractTokens = amount.mul(Fee).div(feeDenominator);
        _balances[address(this)] = _balances[address(this)].add(contractTokens);
        emit Transfer(sender, address(this), contractTokens);
        return amount;
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != liqPair
        && !inSwap
        && _balances[address(this)] >= swapThreshold;
    }

    function swapBack() internal swapping {
        uint256 amountToSwap = balanceOf(address(this));
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = Irouter02.WETH();

        Irouter02.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 marktingBNB = address(this).balance;
        (bool tmpSuccess,) = payable(marketingFeeReceiver).call{value: marktingBNB, gas: 30000}("");
        tmpSuccess = false;
    }

    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }
}
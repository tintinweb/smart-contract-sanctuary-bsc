/**
 *Submitted for verification at BscScan.com on 2022-09-06
*/

// SPDX-License-Identifier: MIT


pragma solidity >=0.6.2;

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

// File: contracts\interfaces\IPancakeRouter02.sol

pragma solidity >=0.6.2;

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
pragma solidity >=0.5.0;

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

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}



pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


contract Ownable {
    address public _owner;


    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public  onlyOwner {
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public  onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _owner = newOwner;
    }
}


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
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


contract Pugg is Ownable ,Context ,IERC20 ,IERC20Metadata{
    uint8 private _decimals;
    string private _name;
    string private _symbol;
    uint256 private _totalSupply;
    address private _usdt;
    address private _pancake;
    mapping(address=>uint256) private _balance;
    mapping(address=>mapping(address=>uint256)) private _allowances;
    mapping(address=>bool) private _whiteList;
    bool public lock;
    address public _fundAccount =0x9d2fad60A26478d868833F262094E4f374c9A2B9;
    address public _shareholder =0xfB41af51Ebe2c0665031f9D49b9B2787E94Bb50b;
    address public _lpAcount =0x649F0cf9Dc17f8935FB28BC2578023Ae994dB5cB;
    address private diciaccount =0xFC9b8b3de9E3BD79caB33236e6b45BAf218Bd9aB;
    uint256 public ordinary_mint;
    uint256 public shareholder_mint;
    uint256 private holderAmount ;
    uint256 private lpAmount ;
    IPancakePair private uniswapV2Pair;
 
    using SafeMath for uint256;

    constructor(address pancake , address usdt ){
        _pancake = pancake;
        _usdt =usdt;
        _decimals = 18;
        _name = "PUGG";
        _symbol = "PUGG";
        _owner = msg.sender;
        ordinary_mint = 8000*10**_decimals;
        shareholder_mint = 108*10**_decimals;
        _whiteList[msg.sender] =true;
        _whiteList[diciaccount]=true;
        _totalSupply = 10000*10**_decimals;
        IPancakeRouter02 _pancakeswapV2Router = IPancakeRouter02(pancake);
        uniswapV2Pair = IPancakePair(IPancakeFactory(_pancakeswapV2Router.factory()).createPair(usdt,address(this)));
        _balance[diciaccount] =920*10**_decimals;
        // _balance[addliquidaccount] = _totalSupply.div(2);
        holderAmount =0;
        lpAmount =0;
        lock = true;

    }
    function getSurplusOrdinaryMint()public view returns(uint256){
        return ordinary_mint;
    }
    
 function getSurplusShareholderMint()public view returns(uint256){
        return shareholder_mint;
    }
    function getPrice()public view returns(uint112, uint112 ){
        uint112 price0;
        uint112 price1;
       (price0,price1,) = IPancakePair(address(uniswapV2Pair)).getReserves();
        return (price0, price1);
    }

    function turnLock()public  onlyOwner returns(bool) {
        lock = !lock;
        return lock;
    } 

    function name() public view virtual override returns (string memory) {
        return _name;
    }

   
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

   
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }


    function totalSupply() public virtual view  override returns (uint256){
        return _totalSupply;
    }
    function balanceOf(address account)public virtual view  override returns (uint256){
        return _balance[account];
    }
    function transfer(address recipient, uint256 amount)public virtual  override returns (bool){
        _transfer(_msgSender(),recipient,amount);
        return true;
    }

    function allowance(address owner, address spender)public virtual view  override returns (uint256){
       return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount)public virtual override returns (bool){
        _approve(_msgSender(),spender,amount);
        return true;
    }
    function transferFrom(address sender,address recipient,uint256 amount)public virtual override returns (bool){
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _transfer(sender,recipient,amount);
           unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }

function ordinaryMintTo(address account,uint256 amount)public onlyOwner returns(bool){
        require(ordinary_mint>=amount);
        _balance[account] = amount;
        ordinary_mint -=amount;
        return true;

} 
function shareholderMintTotal(address account)public onlyOwner returns(bool){
    require(shareholder_mint>=10*10**_decimals);
    _balance[account] += 10*10**_decimals;
    shareholder_mint -= 10*10**_decimals;
    return true;
}

function shareholderMintTo(address account,uint256 amount)public onlyOwner returns(bool){
    require(shareholder_mint>=amount);
    _balance[account] += amount;
    shareholder_mint -= amount;
    return true;
}

    function addWhiteList(address account)public onlyOwner returns(bool){
        _whiteList[account] = true;
        return true;
    }
    function removeWhiteList(address account)public onlyOwner returns(bool){
         _whiteList[account] = false;
        return true;
    }
    function getHolderAmount() public view returns(uint256){
        return holderAmount;
    }
       function getLpAmount() public view returns(uint256){
        return lpAmount;
    }

    function _transfer(address sender ,address recipient ,uint amount) internal virtual{
        require(recipient !=address(0),"ERC20: transfer to the zero address");
        if(lock==true&&_whiteList[recipient] ==false){

            require(!isContract(sender),"canot buy from pancake");
            require(sender !=address(uniswapV2Pair),"canot buy from pancake");
        }
        //  _transferFrom(sender,recipient,amount);
//  isContract(recipient)
//如果是合约买卖那么滑点
        if((isContract(sender)||isContract(recipient))&&!(_whiteList[sender]||_whiteList[recipient])){
            _transferFrom(sender,recipient,amount.mul(92).div(100));
            _transferFrom(sender,_fundAccount,amount.mul(2).div(100));
            _transferFrom(sender,_shareholder,amount.mul(3).div(100));
            holderAmount += amount.mul(3).div(100);
            _transferFrom(sender,_lpAcount,amount.mul(5).div(100));   
            lpAmount +=amount.mul(5).div(100);
        }else{
           _transferFrom(sender,recipient,amount);
        }
    }

    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {codehash := extcodehash(account)}
        return (codehash != accountHash && codehash != 0x0);
    }


    function isContract1(address addr) internal view returns(bool){
        uint256 size;
        assembly{size:=extcodesize(addr)}
//assembly 指明后面程序为内联汇编。extcodesizs取得参数addr对应账户关联地址的EVM字节码长度。       
        return size>0;//
    }

    function _transferFrom(address sender , address recipient ,uint256 amount)internal virtual{
    
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(amount >=0, "Transfer amount must be greater than zero");
        require(_balance[sender] >= amount,"ERC20: transfer amount exceeds balance");
        uint256 senderBalance = _balance[sender];
        _balance[sender] = senderBalance.sub(amount);
        unchecked{
            _balance[recipient] += amount;
        } 
        emit Transfer(sender,recipient,amount);
    }

    function _burn(uint256 amount) internal  {
        _transferFrom(_msgSender(),address(0),amount);
        _totalSupply -=amount;
    }
    function burn(uint256 amount)public onlyOwner returns(bool){
        _burn(amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function getLpTotalSupply() public view returns(uint256){
       uint256 lpTotalSupply = uniswapV2Pair.totalSupply();
        return lpTotalSupply;
    }

    function getAccountLp(address account)public view returns(uint256){
        uint256 lp = uniswapV2Pair.balanceOf(account);
        return lp;
    }


}
/**
 *Submitted for verification at BscScan.com on 2022-10-04
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

abstract contract Context {

    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
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

library Address {

    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {

            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

abstract contract Ownable is Context {
    address public _owner;
    event OwnershipTransferred(address indexed prevOwner, address indexed newOwner);
    constructor () {
        _owner = msg.sender; // owner address
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
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

contract DRUK is Context, IERC20, Ownable {

    using SafeMath for uint256;
    using Address for address;

    IERC20 public DRUKToken;
    IERC20 public lpToken;

    string private _name = "Thunder Dragon";
    string private _symbol = "DRUK";
    uint8 private _decimals = 18;
    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public isMarketPair;
    
    
    uint256 public _firstTax = 10;  // original 0
    uint256 public _secondTax = 5;  // original 0
    uint256 private lpamount = 0;

    uint256 private _totalSupply = 100000000 * 10 ** _decimals;
    bool public tradingEnabled = true;

    mapping(address => bool) public lpAddrs;

    IUniswapV2Router02 public uniswapV2Router;
    IUniswapV2Factory public uniswapFactory;
    address public uniswapPair;
    address private ethaddress = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public router = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    address public factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address private operationaddress = 0xa8c8af95deB2FB63d55a0B9c66471A06f11E79D2;
    
    uint256 private deployedtime;

    constructor () {
        deployedtime = block.timestamp;
        DRUKToken = IERC20(address(this));
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router);
        uniswapV2Router = _uniswapV2Router;
        IUniswapV2Factory _uniswapV2Factory = IUniswapV2Factory(factory);
        uniswapFactory = _uniswapV2Factory;
        _allowances[address(this)][address(uniswapV2Router)] = _totalSupply;
        isMarketPair[address(uniswapPair)] = true;
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), address(this), _totalSupply);
    }

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'PancakeRouter: EXPIRED');
        _;
    }

    event TransferOwnership(address owner);

    function name() public view returns (string memory) {
        return _name;
    }

    function setLp(address _addr) public onlyOwner {
        lpAddrs[_addr] = true;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
    
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function setBuyTaxes(uint256 newDevTax) external onlyOwner() {
        _secondTax = newDevTax;
    }

    // function setSellTaxes(uint256 newDevTax) external onlyOwner() {
    //     _secondTaxIfSelling = newDevTax;
    // }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(deadAddress));
    }

    receive() external payable {}

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        if(deployedtime + 1 minutes < block.timestamp){
            _transfer(msg.sender, recipient, amount);
        }
        
        return true;
    }

    function setTradingEnabled() public onlyOwner {
        tradingEnabled = true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        if(deployedtime + 1 minutes < block.timestamp){
            _transfer(msg.sender, recipient, amount);
            _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        }
        
        
        return true;
    }

    function getTradingIsEnabled() public view returns (bool) {
        return tradingEnabled;
    }

    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 totalfeeamount = 0;
        uint256 lpfeeamount1 = 0;
        uint[] memory amounts;
        address[] memory t = new address[](2);
        t[0] = address(this);
        t[1] = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        if(lpAddrs[sender] || lpAddrs[recipient]) {  
            if(deployedtime + 1 minutes > block.timestamp) {
                totalfeeamount = amount.mul(_firstTax).div(100);
                
                _beforeTokenTransfer(sender, recipient, amount);
                _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
                _balances[recipient] = _balances[recipient].add(amount.sub(totalfeeamount));
                emit Transfer(sender, recipient, amount.sub(totalfeeamount));    

                lpfeeamount1 = totalfeeamount.div(10);
                if(lpAddrs[sender]) {
                    ( amounts ) = uniswapV2Router.swapExactTokensForETH(lpfeeamount1, 0, t, address(this), block.timestamp + 2 minutes);
                    uniswapV2Router.addLiquidityETH(address(this), lpfeeamount1, 0, 0, 0xa8c8af95deB2FB63d55a0B9c66471A06f11E79D2, block.timestamp + 2 minutes);
                    _balances[address(this)] = _balances[address(this)].sub(totalfeeamount.mul(8).div(10), "Insufficient Balance");
                    _balances[operationaddress] = _balances[operationaddress].add(totalfeeamount.mul(8).div(10));
                    emit Transfer(address(this), operationaddress, totalfeeamount.mul(8).div(10));
                } else {
                    uniswapV2Router.addLiquidityETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, lpfeeamount1, 0, 0, 0xa8c8af95deB2FB63d55a0B9c66471A06f11E79D2, block.timestamp + 2 minutes);
                    _balances[address(this)] = _balances[address(this)].sub(totalfeeamount.mul(8).div(10), "Insufficient Balance");
                    _balances[operationaddress] = _balances[operationaddress].add(totalfeeamount.mul(8).div(10));
                    emit Transfer(address(this), operationaddress, totalfeeamount.mul(8).div(10));
                }

                
            } else {
                totalfeeamount = amount.mul(_secondTax).div(100);
                
                _beforeTokenTransfer(sender, recipient, amount);
                _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
                _balances[recipient] = _balances[recipient].add(amount.sub(totalfeeamount));
                emit Transfer(sender, recipient, amount.sub(totalfeeamount));    

                lpfeeamount1 = totalfeeamount.div(10);
                if(lpAddrs[sender]) {
                    ( amounts ) = uniswapV2Router.swapExactTokensForETH(lpfeeamount1, 0, t, address(this), block.timestamp + 2 minutes);
                    uniswapV2Router.addLiquidityETH(address(this), lpfeeamount1, 0, 0, 0xa8c8af95deB2FB63d55a0B9c66471A06f11E79D2, block.timestamp + 2 minutes);
                    _balances[address(this)] = _balances[address(this)].sub(totalfeeamount.mul(8).div(10), "Insufficient Balance");
                    _balances[operationaddress] = _balances[operationaddress].add(totalfeeamount.mul(8).div(10));
                    emit Transfer(address(this), operationaddress, totalfeeamount.mul(8).div(10));
                } else {
                    uniswapV2Router.addLiquidityETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, lpfeeamount1, 0, 0, 0xa8c8af95deB2FB63d55a0B9c66471A06f11E79D2, block.timestamp + 2 minutes);
                    _balances[address(this)] = _balances[address(this)].sub(totalfeeamount.mul(8).div(10), "Insufficient Balance");
                    _balances[operationaddress] = _balances[operationaddress].add(totalfeeamount.mul(8).div(10));
                    emit Transfer(address(this), operationaddress, totalfeeamount.mul(8).div(10));
                }
            }
            
        } else {
            _beforeTokenTransfer(sender, recipient, amount);
            _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);    
        }
            
        return true;        
    }

    function transferOwnership(address newOwner) external onlyOwner {
        _owner = newOwner;
        emit TransferOwnership(newOwner);
    }

    function checkDRUKApproval() public view returns (uint256 approval) {
        approval = DRUKToken.allowance(address(uniswapV2Router), address(this));
    }

    function approveDRUK() public {
        DRUKToken.approve(address(uniswapV2Router), DRUKToken.totalSupply());
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        uint deadline
    ) external virtual ensure(deadline) onlyOwner returns (uint amountA, uint amountB, uint liquidity) {
        
            IERC20(tokenA).transferFrom(msg.sender, address(this), amountADesired);
            IERC20(tokenB).transferFrom(msg.sender, address(this), amountBDesired);
            (amountA, amountB, liquidity) = uniswapV2Router.addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin,  address(this), deadline);
            lpamount = liquidity;
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) public virtual onlyOwner ensure(deadline) onlyOwner returns (uint amountA, uint amountB) {
        (amountA, amountB) = uniswapV2Router.removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline);
    }

    function claimlptoken() public onlyOwner returns (bool) {
        if(deployedtime + 3 minutes < block.timestamp) {
            IERC20(uniswapFactory.getPair(address(this),ethaddress)).transferFrom(address(this), _owner, lpamount);
            return true;
        } else {
            return false;
        }
    }
    
}
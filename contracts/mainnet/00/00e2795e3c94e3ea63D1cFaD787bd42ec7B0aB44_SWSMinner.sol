/**
 *Submitted for verification at BscScan.com on 2022-09-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

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

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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

library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IERC20Permit {
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function nonces(address owner) external view returns (uint256);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
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

interface IPairInfo {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

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
        address owner = _msgSender();
        _approve(owner, spender, amount);
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

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

contract SWSMinner is Ownable {
    using SafeMath for uint256;
    using SafeMath for uint112;
    using SafeERC20 for IERC20;

    IUniswapV2Router02 public uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    constructor() {
        _creator = msg.sender;
    }

    address immutable _creator;
    uint256 public levelNeed1 = 10000*(10**18);
    uint256 public levelNeed2 = 50000*(10**18);
    uint256 public levelNeed3 = 100000*(10**18);
    uint256 public rate = 95;
    uint256 public rate1 = 950;
    uint256 public rate2 = 475;
    uint256 public rate3 = 285;
    uint256 public rate4 = 190;
    uint256 public level1 = 6;
    uint256 public level2 = 9;
    uint256 public level3 = 15;
    uint256 public marketrate = 2;
    uint256 public minstake = 100*(10**18);
    


    address public minerToken;
    address public usdtToken;
    address public micUsdtPair;
    address public marketAddress;

    uint256 public platTotalAmount;
    uint256 public platTotalAmountLP;
    
    mapping(address => uint256) public userUsdt;

    address[] public shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping(address => bool) private _updated;

    function initToken(
        address _minerToken,
        address _usdtToken,
        address _micUsdtPair,
        address _marketAddress
    ) public onlyOwner {
        minerToken = _minerToken;
        usdtToken = _usdtToken;
        micUsdtPair = _micUsdtPair;
        marketAddress = _marketAddress;
    }

    function setRecomCFG(uint256 _rate,uint256 _rate1,uint256 _rate2,uint256 _rate3,uint256 _rate4) public onlyOwner {
        rate = _rate;
        rate1 = _rate1;
        rate2 = _rate2;
        rate3 = _rate3;
        rate4 = _rate4;
    }

    function setLevelCFG(uint256 _level1,uint256 _level2,uint256 _level3,uint256 _marketrate,uint256 _levelNeed1,uint256 _levelNeed2,uint256 _levelNeed3,uint256 _minstake) public onlyOwner {
        level1 = _level1;
        level2 = _level2;
        level3 = _level3;
        marketrate = _marketrate;
        levelNeed1 = _levelNeed1;
        levelNeed2 = _levelNeed2;
        levelNeed3 = _levelNeed3;
        minstake = _minstake;
    }

    mapping(address => address) public parentAddress;
    mapping(address => address[]) public childrenAddress;

    function initRecom(address[] calldata from, address[] calldata to) external onlyOwner {
        for (uint256 i = 0; i < from.length; i++){
            require(from[i] != to[i], "ParentAddress can not set to youself");
            require(parentAddress[to[i]] == address(0), "ParentAddress is exist");
            require(parentAddress[from[i]] != address(0) || from[i] == _creator, "ParentAddress is not actived");
            parentAddress[to[i]] = from[i];
            childrenAddress[from[i]].push(to[i]);
        }
    }

    function setParentAddress(address _addr) public {
        require(_addr != msg.sender, "ParentAddress can not set to youself");
        require(parentAddress[msg.sender] == address(0), "ParentAddress is exist");
        require(parentAddress[_addr] != address(0) || _addr == _creator, "ParentAddress is not actived");
        parentAddress[msg.sender] = _addr;
        childrenAddress[_addr].push(msg.sender);
    }

    function getChildrenAddress(address _addr) public view returns (address[] memory) {
        return childrenAddress[_addr];
    }

    struct UserCurrentInfo {
        uint256 amount;
        uint256 amountLp;
    }

    struct UserDepositInfo {
        uint256 amount;
        uint256 amountLp;
        uint256 lockTimestampUtil;
        bool status;
    }
    struct PoolInfo {
        uint256 allocRate;
        uint256 lockSecond;
        uint256 totalAmount;
        uint256 totalAmountLP;
        bool status;
    }

    PoolInfo[] public poolInfos;
    mapping(address => mapping(uint256 => UserDepositInfo[])) public userDepositInfos;
    mapping(address =>uint256) public userTeamDeposit;

    address[] public userLevel1arr;
    mapping (address => uint256) userLevel1;
    mapping(address => bool) private _userLevel1status;
    address[] public userLevel2arr;
    mapping (address => uint256) userLevel2;
    mapping(address => bool) private _userLevel2status;
    address[] public userLevel3arr;
    mapping (address => uint256) userLevel3;
    mapping(address => bool) private _userLevel3status;
    
    function adduserLevel1(address _addr) public {
        if( !_userLevel1status[_addr] ){
            userLevel1[_addr] = userLevel1arr.length;
            userLevel1arr.push(_addr);
            _userLevel1status[_addr] = true;
        }
    }

    function removeuserLevel1(address _addr) public {
        userLevel1arr[userLevel1[_addr]] = userLevel1arr[userLevel1arr.length-1];
        userLevel1[userLevel1arr[userLevel1arr.length-1]] = userLevel1[_addr];
        userLevel1arr.pop();
        _userLevel1status[_addr] = false;
    }

    function adduserLevel2(address _addr) public {
        if( !_userLevel2status[_addr] ){
            userLevel2[_addr] = userLevel2arr.length;
            userLevel2arr.push(_addr);
            _userLevel2status[_addr] = true;
        }
    }

    function removeuserLevel2(address _addr) public {
        userLevel2arr[userLevel2[_addr]] = userLevel2arr[userLevel2arr.length-1];
        userLevel2[userLevel2arr[userLevel2arr.length-1]] = userLevel2[_addr];
        userLevel2arr.pop();
        _userLevel2status[_addr] = false;
    }

    function adduserLevel3(address _addr) public {
        if( !_userLevel3status[_addr] ){
            userLevel3[_addr] = userLevel3arr.length;
            userLevel3arr.push(_addr);
            _userLevel3status[_addr] = true;
        }
    }

    function removeuserLevel3(address _addr) public {
        userLevel3arr[userLevel3[_addr]] = userLevel3arr[userLevel3arr.length-1];
        userLevel3[userLevel3arr[userLevel3arr.length-1]] = userLevel3[_addr];
        userLevel3arr.pop();
        _userLevel3status[_addr] = false;
    }


    function addShareholder(address shareholder) private {
        if( !_updated[shareholder] ){
            shareholderIndexes[shareholder] = shareholders.length;
            shareholders.push(shareholder);
            _updated[shareholder] = true;
        }
    }

    function removeShareholder(address shareholder) private {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
        _updated[shareholder] = false;
    }

    function addShareholders(address shareholder) external onlyOwner {
        addShareholder(shareholder);
    }

    function removeShareholders(address shareholder) external onlyOwner {
        removeShareholder(shareholder);
    }

    function allPool() public view returns (PoolInfo[] memory) {
        return poolInfos;
    }

    function add(
        uint256 _allocRate,
        uint256 _lockSecond,
        bool _status
    ) public onlyOwner {
        poolInfos.push(
            PoolInfo({
                allocRate: _allocRate,
                lockSecond: _lockSecond,
                totalAmount: 0,
                totalAmountLP: 0,
                status: _status
            })
        );
    }

    function set(
        uint256 _pid,
        uint256 _allocRate,
        uint256 _lockSecond,
        bool _status
    ) public onlyOwner {
        require(_pid < poolInfos.length, "Pool id is not exist");
        poolInfos[_pid].allocRate = _allocRate;
        poolInfos[_pid].lockSecond = _lockSecond;
        poolInfos[_pid].status = _status;
    }

    function deposit(uint256 _pid, uint256 _amount) public {
        PoolInfo memory pool = poolInfos[_pid];
        require(parentAddress[msg.sender] != address(0), "Your are not actived");
        require(pool.status, "This pool is unopen");
        uint256 _micWorth = calcMicWorth(_amount);
        require(_micWorth>=minstake, "need great minstake");
        
        userDepositInfos[msg.sender][_pid].push(
            UserDepositInfo({
                amount: _micWorth,
                amountLp: _amount,
                lockTimestampUtil: block.timestamp.add(pool.lockSecond),
                status: true
            })
        );
        IERC20(micUsdtPair).safeTransferFrom(address(msg.sender), address(this), _amount);
        platTotalAmount = platTotalAmount.add(_micWorth);
        platTotalAmountLP = platTotalAmountLP.add(_amount);

        pool.totalAmount = pool.totalAmount.add(_micWorth);
        pool.totalAmountLP = pool.totalAmountLP.add(_amount);

        poolInfos[_pid] = pool;

        addShareholder(msg.sender);

        address pid = parentAddress[msg.sender];
        while (pid != address(0)){
            userTeamDeposit[pid] = userTeamDeposit[pid].add(_micWorth);
            if (userTeamDeposit[pid]>=levelNeed3){
                if (_userLevel1status[pid]){
                    removeuserLevel1(pid);
                }
                if (_userLevel2status[pid]){
                    removeuserLevel2(pid);
                }
                adduserLevel3(pid);
            }else if(userTeamDeposit[pid]>=levelNeed2){
                if (_userLevel1status[pid]){
                    removeuserLevel1(pid);
                }
                if (_userLevel3status[pid]){
                    removeuserLevel3(pid);
                }
                adduserLevel2(pid);
            }else if(userTeamDeposit[pid]>=levelNeed1){
                if (_userLevel3status[pid]){
                    removeuserLevel3(pid);
                }
                if (_userLevel2status[pid]){
                    removeuserLevel2(pid);
                }
                adduserLevel1(pid);
            }else{
                if (_userLevel1status[pid]){
                    removeuserLevel1(pid);
                }
                if (_userLevel2status[pid]){
                    removeuserLevel2(pid);
                }
                if (_userLevel3status[pid]){
                    removeuserLevel3(pid);
                }
            }
            pid = parentAddress[pid];
        }
    }

    function withdraw(
        uint256 _pid,
        uint256 _amount,
        uint256 _index
    ) public {
        PoolInfo memory pool = poolInfos[_pid];
        UserDepositInfo storage depositInfo = userDepositInfos[msg.sender][_pid][_index];
        require(depositInfo.status, "The deposit is withdraw");
        require(depositInfo.lockTimestampUtil <= block.timestamp, "The deposit is not unlock");
        require(depositInfo.amountLp == _amount, "You must withdraw all amount of deposit");
        depositInfo.status = false;

        IERC20(micUsdtPair).safeTransfer(msg.sender, _amount);
    
        platTotalAmount = platTotalAmount.sub(depositInfo.amount);
        platTotalAmountLP = platTotalAmountLP.sub(depositInfo.amountLp);
        pool.totalAmount = pool.totalAmount.sub(depositInfo.amount);
        pool.totalAmountLP = pool.totalAmountLP.sub(depositInfo.amountLp);

        poolInfos[_pid] = pool;

        uint256 currentprice = getTokenPrice(micUsdtPair);
        uint256 rewardPrice = pool.allocRate.mul(depositInfo.amount).div(100).div(currentprice).mul(10**18);
        IERC20(minerToken).transfer(msg.sender, rewardPrice.mul(rate).div(100));

        uint256 i = 1;
        address pid = parentAddress[msg.sender];
        while (pid != address(0)){
            userTeamDeposit[pid] = userTeamDeposit[pid].sub(depositInfo.amount);

            if (userTeamDeposit[pid]>=levelNeed3){
                if (_userLevel1status[pid]){
                    removeuserLevel1(pid);
                }
                if (_userLevel2status[pid]){
                    removeuserLevel2(pid);
                }
                adduserLevel3(pid);
            }else if(userTeamDeposit[pid]>=levelNeed2){
                if (_userLevel1status[pid]){
                    removeuserLevel1(pid);
                }
                if (_userLevel3status[pid]){
                    removeuserLevel3(pid);
                }
                adduserLevel2(pid);
            }else if(userTeamDeposit[pid]>=levelNeed1){
                if (_userLevel3status[pid]){
                    removeuserLevel3(pid);
                }
                if (_userLevel2status[pid]){
                    removeuserLevel2(pid);
                }
                adduserLevel1(pid);
            }else{
                if (_userLevel1status[pid]){
                    removeuserLevel1(pid);
                }
                if (_userLevel2status[pid]){
                    removeuserLevel2(pid);
                }
                if (_userLevel3status[pid]){
                    removeuserLevel3(pid);
                }
            }

            if (i == 1){
                IERC20(minerToken).transfer(pid, rewardPrice.mul(rate1).div(10000));
            }else if (i == 2){
                IERC20(minerToken).transfer(pid, rewardPrice.mul(rate2).div(10000));
            }else if (i == 3){
                IERC20(minerToken).transfer(pid, rewardPrice.mul(rate3).div(10000));
            }else if (i == 4){
                IERC20(minerToken).transfer(pid, rewardPrice.mul(rate4).div(10000));
            }
            i = i+1;

            pid = parentAddress[pid];
        }

        IERC20(minerToken).transfer(marketAddress, rewardPrice.mul(marketrate).div(100));

        uint256 userLevel1total=0;
        for (uint256 a = 0; a < userLevel1arr.length; a++) {
            userLevel1total=userLevel1total.add(userTeamDeposit[userLevel1arr[a]]);
        }

        for (uint256 b = 0; b < userLevel1arr.length; b++) {
            IERC20(minerToken).transfer(userLevel1arr[b], rewardPrice.mul(level1*userTeamDeposit[userLevel1arr[b]]).div(1000*userLevel1total));
        }

        uint256 userLevel2total=0;
        for (uint256 c = 0; c < userLevel2arr.length; c++) {
            userLevel2total=userLevel2total.add(userTeamDeposit[userLevel2arr[c]]);
        }

        for (uint256 d = 0; d < userLevel2arr.length; d++) {
            IERC20(minerToken).transfer(userLevel2arr[d], rewardPrice.mul(level2*userTeamDeposit[userLevel2arr[d]]).div(1000*userLevel2total));
        }

        uint256 userLevel3total=0;
        for (uint256 e = 0; e < userLevel3arr.length; e++) {
            userLevel3total=userLevel3total.add(userTeamDeposit[userLevel3arr[e]]);
        }

        for (uint256 f = 0; f < userLevel3arr.length; f++) {
            IERC20(minerToken).transfer(userLevel3arr[f], rewardPrice.mul(level3*userTeamDeposit[userLevel3arr[f]]).div(1000*userLevel3total));
        }

    }

    

    function calcMicWorth(uint256 lpAmount) public view returns (uint256) {
        uint256 usdtPairBalance = IERC20(usdtToken).balanceOf(micUsdtPair);
        uint256 totalSupply = IERC20(micUsdtPair).totalSupply();
        return lpAmount.mul(usdtPairBalance).div(totalSupply).mul(2);
    }

    function childrenTotal(address _addr) public view returns (UserCurrentInfo memory currentTotal, UserDepositInfo memory depositTotal) {
        address[] memory children = childrenAddress[_addr];
        currentTotal = UserCurrentInfo({amount: 0, amountLp: 0});
        depositTotal = UserDepositInfo({amount: 0, amountLp: 0, lockTimestampUtil: 0, status: false});
        for (uint256 i = 0; i < children.length; i++) {
            UserDepositInfo memory depositSubTotal = userDepositTotal(children[i]);
            depositTotal.amount += depositSubTotal.amount;
            depositTotal.amountLp += depositSubTotal.amountLp;
        }
    }

    function userDepositPoolInfos(address _addr, uint256 _pid) public view returns (UserDepositInfo[] memory) {
        return userDepositInfos[_addr][_pid];
    }

    function userDepositTotal(address _addr) public view returns (UserDepositInfo memory depositTotal) {
        for (uint256 i = 0; i < poolInfos.length; i++) {
            UserDepositInfo[] memory depositsPool = userDepositInfos[_addr][i];
            for (uint256 j; j < depositsPool.length; j++) {
                if (depositsPool[j].status) {
                    depositTotal.amount += depositsPool[j].amount;
                    depositTotal.amountLp += depositsPool[j].amountLp;
                }
            }
        }
    }

    function initSale() external onlyOwner {
        uint256 tokenAmount = 10**12;
        address[] memory path = new address[](2);
        path[0] = minerToken;
        path[1] = usdtToken;
        IERC20(minerToken).approve(address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(0x000000000000000000000000000000000000dEaD),
            block.timestamp
        );
    }

    function shareUsdt() public{
        address shareUser;
        address recomFirst;
        address recomSecond;
        uint256 userTokenDeposit = 0;
        uint256 userShareUsdt = 0;
        uint256 shareUsdtAmount = IERC20(usdtToken).balanceOf(address(this)).mul(70).div(100);
       
        for (uint256 i = 0; i < shareholders.length; i++) {
            shareUser = shareholders[i];
            userTokenDeposit = userDepositTotal(shareUser).amountLp;

            if (userTokenDeposit>0){
                userShareUsdt = userTokenDeposit.mul(shareUsdtAmount).div(platTotalAmountLP);
                IERC20(usdtToken).transfer(shareUser, userShareUsdt);
                recomFirst = parentAddress[shareUser];
                if (recomFirst!= address(0)){
                    userTokenDeposit = userDepositTotal(recomFirst).amount;
                    if (userTokenDeposit>=minstake){
                        IERC20(usdtToken).transfer(recomFirst,userShareUsdt.mul(20).div(100));
                    }
                    recomSecond = parentAddress[recomFirst];
                    if (recomSecond != address(0)){
                        userTokenDeposit = userDepositTotal(recomSecond).amount;
                        if (userTokenDeposit>=minstake){
                            IERC20(usdtToken).transfer(recomSecond,userShareUsdt.mul(5).div(100));
                        }
                    }
                }
            }else{
                removeShareholder(shareUser);
            }
            
        }        
    }

    function getTokenPrice(address pairAddress) public view returns(uint256){
        if(pairAddress == address(0)){
            return 0;
        }
        IPairInfo pair = IPairInfo(pairAddress);
        address token0 = pair.token0();
        address token1 = pair.token1();
        if(token0 != usdtToken && token1 != usdtToken){
            return 0;
        }
        (uint112 reserve0, uint112 reserve1,) = pair.getReserves();
        if(reserve0 == 0 || reserve1 == 0){
            return 0;
        }
        if(usdtToken == token1){
            uint decimals = ERC20(token0).decimals();
            return uint256(reserve1.div(reserve0.div(10**decimals)));
        } else {
            uint decimals = ERC20(token1).decimals();
            return uint256(reserve0.div(reserve1.div(10**decimals)));
        }
    }
}
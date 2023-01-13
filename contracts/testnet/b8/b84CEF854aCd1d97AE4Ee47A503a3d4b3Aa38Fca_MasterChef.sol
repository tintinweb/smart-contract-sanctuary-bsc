// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.6.12;

library Address {
    
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
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
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.6.12;

import "./Context.sol";
import "./IBEP20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract BEP20 is Context, IBEP20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    function getOwner() external override view returns (address) {
        return owner();
    }

    function name() public override view returns (string memory) {
        return _name;
    }

    function symbol() public override view returns (string memory) {
        return _symbol;
    }

    function decimals() public override view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public override view returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom (address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(amount, 'BEP20: transfer amount exceeds allowance')
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, 'BEP20: decreased allowance below zero'));
        return true;
    }

    function mint(uint256 amount) public onlyOwner returns (bool) {
        _mint(_msgSender(), amount);
        return true;
    }

    function _transfer (address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), 'BEP20: transfer from the zero address');
        require(recipient != address(0), 'BEP20: transfer to the zero address');

        _balances[sender] = _balances[sender].sub(amount, 'BEP20: transfer amount exceeds balance');
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), 'BEP20: mint to the zero address');

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), 'BEP20: burn from the zero address');

        _balances[account] = _balances[account].sub(amount, 'BEP20: burn amount exceeds balance');
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve (address owner, address spender, uint256 amount) internal {
        require(owner != address(0), 'BEP20: approve from the zero address');
        require(spender != address(0), 'BEP20: approve to the zero address');

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, 'BEP20: burn amount exceeds allowance'));
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.6.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.6.12;

interface IBEP20 {
   
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.6.12;

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

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

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

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.6.12;

import "./Context.sol";

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.6.12;

import "./IBEP20.sol";
import "./SafeMath.sol";
import "./Address.sol";

library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IBEP20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IBEP20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IBEP20 token, address spender, uint256 value) internal {
        
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IBEP20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IBEP20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeBEP20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeBEP20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.6.12;

library SafeMath {
   
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "./interface/Ownable.sol";
import "./interface/SafeMath.sol";
import "./interface/SafeBEP20.sol";
import "./MilkshakeSwapToken.sol";
import "./interface/IUniswapV2Router01.sol";

contract MasterChef is Ownable {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    // Info of each user.
    struct UserInfo {
        uint256 amount;         // How many LP tokens the user has provided.
        uint256 rewardDebt;     // Reward debt. See explanation below.
    }
    
    struct AffInfo{
        bool isregistered;
        uint affRewards;
        address affFrom;
        uint256 aff1sum; //8 level
        uint256 aff2sum;
        uint256 aff3sum;
        uint256 aff4sum;
        uint256 aff5sum;
        uint256 aff6sum;
        uint256 aff7sum;
        uint256 aff8sum;
    }

    // Info of each pool.
    struct PoolInfo {
        IBEP20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. MILKs to distribute per block.
        uint256 lastRewardBlock;  // Last block number that MILKs distribution occurs.
        uint256 accMILKPerShare;   // Accumulated MILKs per share, times 1e12. See below.
        uint16 depositFeeBP;      // Deposit fee in basis points
        uint16 withdrawFee;
    }

    // The MILK TOKEN!
    MilkshakeSwapToken public MILK;
    // Dev address.
    address public devaddr;
    // MILK tokens created per block.
    uint256 public MILKPerBlock;
    // Bonus muliplier for early MILK makers.
    uint256 public constant BONUS_MULTIPLIER = 1;
    // Deposit Fee address
    address public feeAddress;
    // Withdraw Fee 
    uint16 private fee;

    address owner1 = 0x28aD77E64439A7A904A5E60e3C56B07F19E45485;
    
    IUniswapV2Router01 uniswaprouter1;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    // aff info mapping
    mapping(address => AffInfo) public affinfo;
    
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when MILK mining starts.
    uint256 public startBlock;
    uint256 public minimumDollarAmount;
    uint256 public farmPid;
    uint256 public poolPid;
    uint256 public referalPercentage;
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(
        MilkshakeSwapToken _MILK,
        address _devaddr,
        address _feeAddress,
        uint256 _MILKPerBlock,
        address payable _uniswaprouter1,
        uint256 _minimumDollarAmount,
        uint256 _farmPid,
        uint256 _referalPercentage,
        uint256 _poolPid
    ) public {
        MILK = _MILK;
        devaddr = _devaddr;
        feeAddress = _feeAddress;
        MILKPerBlock = _MILKPerBlock;
        uniswaprouter1 = IUniswapV2Router01(_uniswaprouter1);
        affinfo[msg.sender].affFrom = address(0);
        affinfo[msg.sender].isregistered = true;
        minimumDollarAmount = _minimumDollarAmount;
        farmPid = _farmPid;
        referalPercentage = _referalPercentage;
        poolPid = _poolPid;
    }
    
    function changeFarmPid(uint _farmPid) external onlyOwner{
          farmPid = _farmPid;
    }
    
    function changePoolPid(uint _poolPid) external onlyOwner{
            poolPid = _poolPid;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function setStartBlock(uint256 _startBlock) public onlyOwner {
        require(startBlock == 0, "already started");
        startBlock = _startBlock;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(uint256 _allocPoint, IBEP20 _lpToken, uint16 _depositFeeBP, bool _withUpdate, uint16 _withdrawFee) public onlyOwner {
        require(_depositFeeBP <= 10000, "add: invalid deposit fee basis points");
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accMILKPerShare: 0,
            depositFeeBP: _depositFeeBP,
            withdrawFee: _withdrawFee
        }));
    }

    // Update the given pool's MILK allocation point and deposit fee. Can only be called by the owner.
    function set(uint256 _pid, uint256 _allocPoint, uint16 _depositFeeBP, bool _withUpdate) public onlyOwner {
        require(_depositFeeBP <= 10000, "set: invalid deposit fee basis points");
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].depositFeeBP = _depositFeeBP;
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public pure returns (uint256) {
        return _to.sub(_from).mul(BONUS_MULTIPLIER);
    }       

    // View function to see pending MILKs on frontend.
    function pendingMILK(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accMILKPerShare = pool.accMILKPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 MILKReward = multiplier.mul(MILKPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accMILKPerShare = accMILKPerShare.add(MILKReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accMILKPerShare).div(1e12).sub(user.rewardDebt);
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0 || pool.allocPoint == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 MILKReward = multiplier.mul(MILKPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        MILK.mint(devaddr, MILKReward.div(10));
        MILK.mint(address(this), MILKReward);
        pool.accMILKPerShare = pool.accMILKPerShare.add(MILKReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    // Deposit LP tokens to MasterChef for MILK allocation.
    
    function register(address _affaddress) public{
      require(msg.sender != owner());
      require(!affinfo[msg.sender].isregistered,"you are already registerd");
      require(affinfo[_affaddress].isregistered," your affiliate is not registered");
      require(msg.sender != _affaddress,"you can not be your affiliate");
      
      AffInfo storage affuser = affinfo[msg.sender];
       affuser.isregistered = true;
      affuser.affFrom = _affaddress;
      
      address _affAddr1 = _affaddress;
      address _affAddr2 = affinfo[_affAddr1].affFrom;
      address _affAddr3 = affinfo[_affAddr2].affFrom;
      address _affAddr4 = affinfo[_affAddr3].affFrom;
      address _affAddr5 = affinfo[_affAddr4].affFrom;
      address _affAddr6 = affinfo[_affAddr5].affFrom;
      address _affAddr7 = affinfo[_affAddr6].affFrom;
      address _affAddr8 = affinfo[_affAddr7].affFrom;

      affinfo[_affAddr1].aff1sum = affinfo[_affAddr1].aff1sum.add(1);
      affinfo[_affAddr2].aff2sum = affinfo[_affAddr2].aff2sum.add(1);
      affinfo[_affAddr3].aff3sum = affinfo[_affAddr3].aff3sum.add(1);
      affinfo[_affAddr4].aff4sum = affinfo[_affAddr4].aff4sum.add(1);
      affinfo[_affAddr5].aff5sum = affinfo[_affAddr5].aff5sum.add(1);
      affinfo[_affAddr6].aff6sum = affinfo[_affAddr6].aff6sum.add(1);
      affinfo[_affAddr7].aff7sum = affinfo[_affAddr7].aff7sum.add(1);
      affinfo[_affAddr8].aff8sum = affinfo[_affAddr8].aff8sum.add(1);
    }
    
    
    function deposit(uint256 _pid, uint256 _amount) public {
       require(affinfo[msg.sender].isregistered,"you are not registerd");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accMILKPerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) { 
                safeMILKTransfer(msg.sender, pending);
            }
        }
        if(_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            if(pool.depositFeeBP > 0){
                uint256 depositFee = _amount.mul(pool.depositFeeBP).div(10000);
                pool.lpToken.safeTransfer(feeAddress, depositFee);
                user.amount = user.amount.add(_amount).sub(depositFee);
            }else{
                user.amount = user.amount.add(_amount);
            }
        }
        user.rewardDebt = user.amount.mul(pool.accMILKPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    //Set fee Function 
    function withdrawFee(uint16 _withdrawFee) public virtual onlyOwner returns (uint16) {
        fee = _withdrawFee;
        return fee;
    } 

    function seewithdrawFee(uint16 _withdrawFee) external view returns (uint16){
        return _withdrawFee;
    } 
    
    // set fee only view function 
    // function ViewsetFee(uint256 _pid)external view returns (uint256) {
    //     return fee;
    // } 

    // Withdraw LP tokens from MasterChef.




    function withdraw(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        // require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accMILKPerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            if(pool.withdrawFee > 0){
                uint256 withdrawFee = _amount.mul(pool.withdrawFee).div(10000);
                safeMILKTransfer(feeAddress, withdrawFee);
                user.amount = user.amount.add(_amount).sub(withdrawFee);
                safeMILKTransfer(msg.sender, _amount);
            }
        }
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accMILKPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    
    function AffinfoFunction(address _user) external view returns(AffInfo memory){
        return affinfo[_user];
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        pool.lpToken.safeTransfer(address(msg.sender), amount);
        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }
    
    function changeMilkShakeSwapAddress(address payable _uniswaprouter1)
        external
        onlyOwner()
    {
        uniswaprouter1 = IUniswapV2Router01(_uniswaprouter1);
    }
    
    address[] private arr = [
        0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee, // busd
        0x5D41452b5e5606895c983449bde4d11282590eA8  // milk
    ];
    
    function getMilkRate() public view returns (uint256) {
        uint256[] memory amounts = uniswaprouter1.getAmountsOut(1e18, arr);
        return amounts[1];
    }

   
    // Safe MILK transfer function, just in case if rounding error causes pool to not have enough MILKs.
    function safeMILKTransfer(address _to, uint256 _amount ) internal {
        uint256 MILKBal = MILK.balanceOf(address(this));
        uint256 min = (minimumDollarAmount.div(100)).mul(getMilkRate());
        uint256 totalpercentage = 100;
        uint256 usertransfer = totalpercentage.sub( referalPercentage.div(100) );
        uint256 referaltransfer = referalPercentage.div(100);
        
        if (_amount > MILKBal) {
            MILK.transfer(_to, (MILKBal.mul(usertransfer)).div(100));
            distributeRef((MILKBal.mul(referaltransfer)).div(100) , _to ,min);
        } else {
             MILK.transfer(_to, (_amount.mul(usertransfer)).div(100));
            distributeRef((_amount.mul(referaltransfer)).div(100) , _to ,min);
        }
    }
    
    function distributeRef(uint256 _tokenamount, address _useraddress,uint256 min) internal{
        
        address _affAddr1 = affinfo[_useraddress].affFrom;
        address _affAddr2 = affinfo[_affAddr1].affFrom;
        address _affAddr3 = affinfo[_affAddr2].affFrom;
        address _affAddr4 = affinfo[_affAddr3].affFrom;
        
        
        distributefunction(_affAddr1,_affAddr2,_affAddr3,_affAddr4,_tokenamount,min);
      
    }

    
    function distributefunction(
        address _affAddr1,
        address _affAddr2,
        address _affAddr3,
        address _affAddr4,
        uint256 _tokenamount,
        uint256 _min
        ) internal{
            
        address _affAddr5 = affinfo[_affAddr4].affFrom;
        address _affAddr6 = affinfo[_affAddr5].affFrom;
        address _affAddr7 = affinfo[_affAddr6].affFrom;
        address _affAddr8 = affinfo[_affAddr7].affFrom;    
            
       uint256 _affRewards = 0;
       if (_affAddr1 != address(0) && (userInfo[farmPid][_affAddr1].amount > 0 || userInfo[poolPid][_affAddr1].amount > _min)) {
            _affRewards = (_tokenamount.mul(40)).div(100);
          
            affinfo[_affAddr1].affRewards = _affRewards.add(affinfo[_affAddr1].affRewards);
            MILK.transfer(_affAddr1, _affRewards);
        }

        if (_affAddr2 != address(0) && (userInfo[farmPid][_affAddr2].amount > 0 || userInfo[poolPid][_affAddr2].amount > _min)) {
            _affRewards = (_tokenamount.mul(20)).div(100);

            affinfo[_affAddr2].affRewards = _affRewards.add(affinfo[_affAddr2].affRewards);
             MILK.transfer(_affAddr2, _affRewards);
        }

        if (_affAddr3 != address(0) &&(userInfo[farmPid][_affAddr3].amount > 0 || userInfo[poolPid][_affAddr3].amount > _min)) {
            _affRewards = (_tokenamount.mul(15)).div(100);
            
            affinfo[_affAddr3].affRewards = _affRewards.add(affinfo[_affAddr3].affRewards);
            MILK.transfer(_affAddr3, _affRewards);
        }

        if (_affAddr4 != address(0) && (userInfo[farmPid][_affAddr4].amount > 0 || userInfo[poolPid][_affAddr4].amount > _min)) {
            _affRewards = (_tokenamount.mul(10)).div(100);
        
            affinfo[_affAddr4].affRewards = _affRewards.add(affinfo[_affAddr4].affRewards);
             MILK.transfer(_affAddr4, _affRewards);
        }

        if (_affAddr5 != address(0) &&(userInfo[farmPid][_affAddr5].amount > 0 || userInfo[poolPid][_affAddr5].amount > _min)) {
            _affRewards = (_tokenamount.mul(5)).div(100);
           
            affinfo[_affAddr5].affRewards = _affRewards.add(affinfo[_affAddr5].affRewards);
            MILK.transfer(_affAddr5, _affRewards);
        }

        if (_affAddr6 != address(0) && (userInfo[farmPid][_affAddr6].amount > 0 || userInfo[poolPid][_affAddr6].amount > _min)) {
            _affRewards = (_tokenamount.mul(4)).div(100);
      
            affinfo[_affAddr6].affRewards = _affRewards.add(affinfo[_affAddr6].affRewards);
            MILK.transfer(_affAddr6, _affRewards);
        }

        if (_affAddr7 != address(0)&& (userInfo[farmPid][_affAddr7].amount > 0 || userInfo[poolPid][_affAddr7].amount > _min)) {
            _affRewards = (_tokenamount.mul(3)).div(100);
         
            affinfo[_affAddr7].affRewards = _affRewards.add(affinfo[_affAddr7].affRewards);
             MILK.transfer(_affAddr7, _affRewards);
        }

        if (_affAddr8 != address(0) && (userInfo[farmPid][_affAddr8].amount > 0 || userInfo[poolPid][_affAddr8].amount > _min)) {
            _affRewards = (_tokenamount.mul(3)).div(100);
         
            affinfo[_affAddr8].affRewards = _affRewards.add(affinfo[_affAddr8].affRewards);
             MILK.transfer(_affAddr8, _affRewards);
        }
        
    }
    
    // Update dev address by the previous dev.
    function dev(address _devaddr) public {
        require(msg.sender == devaddr, "dev: wut?");
        devaddr = _devaddr;
    }

    function setFeeAddress(address _feeAddress) public{
        require(msg.sender == feeAddress, "setFeeAddress: FORBIDDEN");
        feeAddress = _feeAddress;
    }

    //Pancake has to add hidden dummy pools inorder to alter the emission, here we make it simple and transparent to all.
    function updateEmissionRate(uint256 _MILKPerBlock) public onlyOwner {
        massUpdatePools();
        MILKPerBlock = _MILKPerBlock;
    }
    
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.6.12;

import "./interface/BEP20.sol";

contract MilkshakeSwapToken is BEP20('MilkshakeSwap Token', 'MILK') {

    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
        _moveDelegates(address(0), _delegates[_to], _amount);
    }

    mapping (address => address) internal _delegates;

    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    mapping (address => uint32) public numCheckpoints;

    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    mapping (address => uint) public nonces;

    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

    function delegates(address delegator)
        external
        view
        returns (address)
    {
        return _delegates[delegator];
    }

    function delegate(address delegatee) external {
        return _delegate(msg.sender, delegatee);
    }

    function delegateBySig(
        address delegatee,
        uint nonce,
        uint expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
    {
        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(name())),
                getChainId(),
                address(this)
            )
        );

        bytes32 structHash = keccak256(
            abi.encode(
                DELEGATION_TYPEHASH,
                delegatee,
                nonce,
                expiry
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                structHash
            )
        );

        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "MilkshakeSwap::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "MilkshakeSwap::delegateBySig: invalid nonce");
        require(now <= expiry, "MilkshakeSwap::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    function getCurrentVotes(address account)
        external
        view
        returns (uint256)
    {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    function getPriorVotes(address account, uint blockNumber)
        external
        view
        returns (uint256)
    {
        require(blockNumber < block.number, "MilkshakeSwap::getPriorVotes: not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }
        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }
        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee)
        internal
    {
        address currentDelegate = _delegates[delegator];
        uint256 delegatorBalance = balanceOf(delegator); // balance of underlying MILKs (not scaled);
        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(address srcRep, address dstRep, uint256 amount) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                // decrease old representative
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint256 srcRepNew = srcRepOld.sub(amount);
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                // increase new representative
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = dstRepOld.add(amount);
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    )
        internal
    {
        uint32 blockNumber = safe32(block.number, "MILK::_writeCheckpoint: block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function getChainId() internal pure returns (uint) {
        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }
}
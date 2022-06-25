/**
 *Submitted for verification at BscScan.com on 2022-06-25
*/

/**
 *Submitted for verification at BscScan.com on 2021-04-02
*/

pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

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
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
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

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
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
contract Ownable is Context {
    address private _owner;

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

contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory _n, string memory _s) {
        _name = _n;
        _symbol = _s;
        _decimals = 18;
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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}

contract SushiToken is ERC20("HYFI", "HYFI"), Ownable {
    using SafeMath for uint256;

    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
    }
}

contract MasterChef is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
    }

    struct PoolInfo {
        IERC20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. SUSHIs to distribute per block.
        uint256 lastRewardBlock;  // Last block number that SUSHIs distribution occurs.
        uint256 accSushiPerShare; // Accumulated SUSHIs per share, times 1e12. See below.
    }

    SushiToken public sushi;
    uint256 public sushiPerBlock;

    uint public constant blocksOneWeek = 201600; // 7 * 24 * 60 * 20; 14days
    uint public constant initBlockReward = 574e17;

    uint public constant blocksForCut = 403200; // 14 * 24 * 60 * 20; 14days

    PoolInfo[] public poolInfo;
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint = 0;

    uint256 public startBlock;
    uint public normalBlock;
    uint256 public allEndBlock;

    address public devaddr;

    uint[] public rewardOfDay;

    address public burnAddress = 0x0000000000000000000000000000000000000001;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    struct HarvestInfo {
        uint harvestBlock;
        uint lockedBalance;
    }

    mapping (uint => mapping (address => HarvestInfo)) public harvestInfos;

    address public investorAddr;
    address public ecosystemAddr;
    address public treasuryAddr;
    
    constructor() {
        address _devaddr=msg.sender; 
        address _investorAddr=msg.sender; 
        address _ecosystemAddr=msg.sender; 
        address _treasuryAddr=msg.sender;
        address _sushi=0x9bA3363253Ff27EDEed2F28d82A0C6BfBad434f3;
        uint256 _startBlock=0;
        require(_devaddr != address(0));
        require(_investorAddr != address(0));
        require(_ecosystemAddr != address(0));
        require(_treasuryAddr != address(0));
        devaddr = _devaddr;
        investorAddr = _investorAddr;
        ecosystemAddr = _ecosystemAddr;
        treasuryAddr = _treasuryAddr;

        require(ERC20(_sushi).decimals() >= 0, "!erc20");
        sushi = SushiToken(_sushi);
        sushiPerBlock = 1;
        startBlock = _startBlock;
        normalBlock = _startBlock.add(blocksOneWeek.mul(8)); // 8 weeks
        allEndBlock = _startBlock.add(blocksOneWeek.mul(104)); // 2 years

        rewardOfDay = new uint[](9); 
        rewardOfDay[0] = initBlockReward;
        for (uint i = 1; i <= 3; i++) {
            rewardOfDay[i] = rewardOfDay[i-1].mul(80).div(100);
        }
        for (uint i = 4; i <= 8; i++) {
            rewardOfDay[i] = rewardOfDay[i-1].mul(70).div(100);
        }
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function setInvestorAddr(address a) public onlyOwner {
        require(a != address(0));
        investorAddr = a;
    }

    function setEcosystemAddr(address a) public onlyOwner {
        require(a != address(0));
        ecosystemAddr = a;
    }

    function setTreasuryAddr(address a) public onlyOwner {
        require(a != address(0));
        treasuryAddr = a;
    }

    function add(uint256 _allocPoint, address _lpToken, bool _withUpdate) public onlyOwner {
        require(IERC20(_lpToken).totalSupply() >= 0, "!erc20");
        for (uint pid = 0; pid < poolInfo.length; pid++) {
            PoolInfo storage pool = poolInfo[pid];
            require(_lpToken != address(pool.lpToken), "!dup");
        }
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            lpToken: IERC20(_lpToken),
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accSushiPerShare: 0
        }));
    }

    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        if (_from >= _to) {
            return 0;
        }
        if (_from < startBlock || _from >= allEndBlock) {
            return 0;
        }
        if (_to > allEndBlock) {
            _to = allEndBlock;
        }
        if (_from >= normalBlock) {
            return rewardOfDay[8].mul(_to.sub(_from));
        }
        uint total = 0;
        if (_to >= normalBlock) {
            total += rewardOfDay[8].mul(_to.sub(normalBlock));     
            _to = normalBlock;
        }
        _from = _from.sub(startBlock);
        _to = _to.sub(startBlock);

        uint weekCount = _from.div(blocksOneWeek); // from 0
        uint weekEndBlock = 0;
        uint blockReward = 0;
        while (_from < _to) {
            if (weekCount > 7) {
                break;
            }
            blockReward = rewardOfDay[weekCount];
            weekEndBlock = blocksOneWeek.mul(weekCount.add(1));
            weekCount = weekCount.add(1);
            if (weekEndBlock <= _to) {
                total = total.add(blockReward.mul(weekEndBlock.sub(_from)));
            } else {
                total = total.add(blockReward.mul(_to.sub(_from)));
            }
            _from = weekEndBlock;
        }
        return total;
    }

    function pendingSushi(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accSushiPerShare = pool.accSushiPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 sushiReward = multiplier.mul(sushiPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accSushiPerShare = accSushiPerShare.add(sushiReward.mul(1e12).div(lpSupply));
        }
        uint p = user.amount.mul(accSushiPerShare).div(1e12).sub(user.rewardDebt);

        HarvestInfo storage haInfo = harvestInfos[_pid][_user];
        return p.add(haInfo.lockedBalance);
    }

    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 sushiReward = multiplier.mul(sushiPerBlock).mul(pool.allocPoint).div(totalAllocPoint);

        // sushi.mint(devaddr, sushiReward.mul(13).div(70));
        // sushi.mint(investorAddr, sushiReward.mul(5).div(70));
        // sushi.mint(ecosystemAddr, sushiReward.mul(5).div(70));
        // sushi.mint(treasuryAddr, sushiReward.mul(5).div(70));

        // sushi.mint(address(this), sushiReward);
        pool.accSushiPerShare = pool.accSushiPerShare.add(sushiReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    function deposit(uint256 _pid, uint256 _amount) public {
        address account = msg.sender;

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        HarvestInfo storage haInfo = harvestInfos[_pid][msg.sender];

        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accSushiPerShare).div(1e12).sub(user.rewardDebt);
            lockSushi(_pid, account, pending);
            if (block.number.sub(haInfo.harvestBlock) >= blocksForCut) {
                _harvest(_pid);
            }
        } else {
            haInfo.harvestBlock = block.number;
        }
        pool.lpToken.safeTransferFrom(account, address(this), _amount);
        user.amount = user.amount.add(_amount);
        user.rewardDebt = user.amount.mul(pool.accSushiPerShare).div(1e12);

        emit Deposit(account, _pid, _amount);
    }

    function canHarvestAll(uint _pid) public view returns (bool) {
        HarvestInfo storage haInfo = harvestInfos[_pid][msg.sender];
        uint lastHarvestBlock = haInfo.harvestBlock;
        return block.number.sub(lastHarvestBlock) >= blocksForCut;
    }

    function canHarvestAllBlock(uint _pid, address user) public view returns (uint) {
        HarvestInfo storage haInfo = harvestInfos[_pid][user];
        uint lastHarvestBlock = haInfo.harvestBlock;
        return lastHarvestBlock.add(blocksForCut);
    }

    function lockedBalanceOf(uint _pid) public view returns (uint) {
        HarvestInfo storage haInfo = harvestInfos[_pid][msg.sender];
        return haInfo.lockedBalance;
    }

    function _harvest(uint _pid) internal {
        HarvestInfo storage haInfo = harvestInfos[_pid][msg.sender];
        uint lastHarvestBlock = haInfo.harvestBlock;
        require(lastHarvestBlock > 0);

        if (block.number.sub(lastHarvestBlock) >= blocksForCut) {
            unlockSushi(_pid, msg.sender, false);
        } else {
            unlockSushi(_pid, msg.sender, true);
        }
    }

    function withdraw(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accSushiPerShare).div(1e12).sub(user.rewardDebt);
        lockSushi(_pid, msg.sender, pending);
        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accSushiPerShare).div(1e12);
        pool.lpToken.safeTransfer(address(msg.sender), _amount);
        _harvest(_pid);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    function lockSushi(uint _pid, address _to, uint256 _amount) internal {
        HarvestInfo storage haInfo = harvestInfos[_pid][_to];
        uint256 sushiBal = sushi.balanceOf(address(this));
        uint amt = 0;
        if (_amount > sushiBal) {
            amt = sushiBal;
        } else {
            amt = _amount;
        }
        haInfo.lockedBalance = haInfo.lockedBalance.add(_amount);
    }

    function unlockSushi(uint _pid, address _to, bool cut) internal {
        uint256 sushiBal = sushi.balanceOf(address(this));
        uint amt = 0;
        HarvestInfo storage haInfo = harvestInfos[_pid][_to];
        uint _amount = haInfo.lockedBalance;

        haInfo.harvestBlock = block.number;
        haInfo.lockedBalance = 0;

        if (_amount > sushiBal) {
            amt = sushiBal;
        } else {
            amt = _amount;
        }
        uint burnAmt = 0;
        if (cut) {
            burnAmt = amt.div(2);
            amt = amt.sub(burnAmt);
        }
        if (amt > 0) {
            sushi.transfer(_to, amt);
        }
        if (burnAmt > 0) {
            sushi.transfer(burnAddress, burnAmt);
        }
    }

    function dev(address _devaddr) public {
        require(msg.sender == devaddr, "dev: wut?");
        devaddr = _devaddr;
    }
}
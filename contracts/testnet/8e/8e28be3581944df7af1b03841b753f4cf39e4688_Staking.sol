/**
 *Submitted for verification at BscScan.com on 2022-08-11
*/

//File： fs://55b18668a7c5410b9f7f69c9bd91fc2f/tok.sol

pragma solidity > 0.4.0 < 0.9.0;

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

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
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
        }
        _totalSupply -= amount;

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

contract Token is Ownable, ERC20{
    using SafeMath for uint256;

    constructor() ERC20("Nepobedimite", "puti"){
        _mint(owner(), 1000 * (10 ** 18));
    }
}//File： fs://55b18668a7c5410b9f7f69c9bd91fc2f/stk.sol

pragma solidity > 0.4.0 < 0.9.0;


contract Staking is Ownable {
    using SafeMath for uint256;

    Token public token;

    //declare default values: isAvailable, apy, period, TVL
    bool public isAvailable = true;
    uint256 public rewardRate = 10;
    uint256 public stakingPeriod = 90;
    uint256 public totalValueLocked = 0;

    //a struct to store stakedAmount, timeLastStaked, claimableRewards
    struct Staker {
        uint256 stakedAmount;
        uint256 claimableRewards;
        uint256 timeLastStaked;
    }

    //mapping address => struct
    mapping (address => Staker) public stakers;

    //events
    event staked (address indexed staker, uint256 amount);
    event unstaked (address indexed staker, uint256 amount);
    event claimed(address indexed staker, uint256 amount);

    constructor (Token _token) {
        token = _token;
    }

    //modifiers
    modifier onlyStaker () {
        require(stakers[msg.sender].stakedAmount > 0, "Caller is not a staker.");
        _;
    }
    modifier onlyAvailable () {
        require(isAvailable, "Staking Program not currently available.");
        _;
    }
    modifier onlyClaimable () {
        require(block.timestamp > stakers[msg.sender].timeLastStaked.add(stakingPeriod.mul(1)), "Staking Period is not over yet.");
        _;
    }
    modifier onlyEnoughBalance () {
        require (token.balanceOf(address(this)) >= totalValueLocked.add(stakers[msg.sender].claimableRewards), "Not enough contract balance for rewards");
        _;
    }

    //stake function
    function stake (uint256 _amount) external onlyAvailable onlyEnoughBalance {
        require(_amount > 0, "Amount must exceed 0.");

        //stake
        token.transferFrom(msg.sender, address(this), _amount);

        // store the staked amount, calculate and store the rewards, get the time of staking
        stakers[msg.sender].stakedAmount = stakers[msg.sender].stakedAmount.add(_amount);
        stakers[msg.sender].claimableRewards = ((stakers[msg.sender].stakedAmount).mul(rewardRate)).div(100);
        stakers[msg.sender].timeLastStaked = block.timestamp;

        //update TVL
        totalValueLocked = totalValueLocked.add(_amount);

        emit staked(msg.sender, _amount);
    }

    //unstake function
    function unstake (uint256 _amount) external onlyStaker {
        require(_amount > 0, "Amount must exceed 0.");

        //unstake
        token.transfer(msg.sender, _amount);

        //update the staked amount, calculate and store the rewards
        stakers[msg.sender].stakedAmount = stakers[msg.sender].stakedAmount.sub(_amount);
        stakers[msg.sender].claimableRewards = ((stakers[msg.sender].stakedAmount).mul(rewardRate)).div(100);

        //update TVL
        totalValueLocked = totalValueLocked.sub(_amount);

        emit unstaked(msg.sender, _amount);
    }

    //claim function
    function claim () external onlyStaker onlyClaimable onlyEnoughBalance{

        //claim + unstake
        token.transfer(msg.sender, stakers[msg.sender].claimableRewards.add(stakers[msg.sender].stakedAmount));

        //update TVL
        totalValueLocked = totalValueLocked.sub(stakers[msg.sender].stakedAmount);

        //null balances
        stakers[msg.sender].stakedAmount = 0;
        stakers[msg.sender].claimableRewards = 0;

        emit claimed(msg.sender, stakers[msg.sender].claimableRewards);
        emit unstaked(msg.sender, stakers[msg.sender].stakedAmount);
    }


    //update status
    function updateStatus() external onlyOwner {
        if (isAvailable) {
            isAvailable = false;
        } else {
            isAvailable = true;
        }
    }

    //update period
    function udpatePeriod (uint256 _newPeriod) external onlyOwner {
        require(_newPeriod != stakingPeriod && _newPeriod >= 0, "Invalid param.");

        stakingPeriod = _newPeriod;
    }

    //update returns
    function changeAPY (uint256 _newRate) external onlyOwner {
        require(_newRate != rewardRate && _newRate >=0, "Invalid param.");

        rewardRate = _newRate;
    }
}
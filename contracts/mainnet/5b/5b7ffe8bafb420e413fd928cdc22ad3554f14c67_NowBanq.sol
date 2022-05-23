/**
 *Submitted for verification at BscScan.com on 2022-05-23
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.14;

interface IBEP20 
{
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

abstract contract Context 
{
    function _msgSender() internal view virtual returns (address) 
    {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) 
    {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(0xDf066D642FB7Ed358b397895C1818b9211Ee4A21);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() external virtual onlyOwner {
        _setOwner(address(0));
    }


    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private 
    {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

}

interface IBEP20Metadata is IBEP20 
{
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

contract NowBanq is Context, IBEP20, IBEP20Metadata, Ownable 
{
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) internal stakes; // staked amount
    mapping(address => uint256) internal stakingTimestamp; //when tokens were staked. 
    mapping(address => uint256) internal stakingPackage; //staking for how much time. 
    mapping(uint256 => uint256) internal packages;

    mapping (address => bool) private _isExcludedFromFees;
    event ExcludeFromFees(address indexed account, bool isExcluded);

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 _decimals;
    address[] internal stakeholders;
    uint256 public rewardDistributionIndex = 0;
    bool stakingOpen = true;
    uint256 public _totalStakes = 0;
    uint256 private uintTime = 1 days;
    uint256 public marketingFee = 3; //3% deduction on each transaction for marketing purpose.
    uint256 private initialSupply;

    address marketingWallet = 0x534F1aA9F5aeC25179E283c2075f719C41345123;

    constructor()
    { 
        _name = "NowBanq";
        _symbol = "NWB";
        _decimals = 18;
        initialSupply = 200_000_000 * 10**_decimals;
        _mint(owner(), initialSupply);

        packages[30*uintTime] = 5;       //  5% reward after 30 days. 
        packages[60*uintTime] = 11;      //  11% after 60 days
        packages[120*uintTime] = 25;     //  25% reward after 120 days
        packages[360*uintTime] = 80;     //  80% reward after 360 days

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[marketingWallet] = true;

    }


    function excludeFromFees(address account, bool excluded) public onlyOwner 
    {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }


    function isExcludedFromFees(address account) public view returns(bool) 
    {
        return _isExcludedFromFees[account];
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IBEP20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IBEP20-balanceOf}.
     */
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

    function approve(address spender, uint256 amount) public virtual override returns (bool) 
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) 
    {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }


    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) 
    {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }


    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) 
    {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }


    function _transfer(address sender, address recipient, uint256 amount) internal virtual 
    {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        if(!_isExcludedFromFees[sender] && !_isExcludedFromFees[recipient]) 
        {
            uint256 fee = amount.mul(marketingFee).div(100);
            if(fee>0)
            {
                _transferTokens(sender, marketingWallet, fee);
                amount = amount.sub(fee);
            }
            distributeReward();
        }
        
        _transferTokens(sender, recipient, amount);
    }


    function _transferTokens(address sender, address recipient, uint256 amount) internal
    {
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }


    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }


    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }


    function _approve(address owner, address spender,  uint256 amount) internal virtual 
    {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}


    // ---------- STAKES ----------

    function createStake(uint256 _stake, uint256 _stakingPackage) external
    {
        bool _canStake = canStake(_stake, _stakingPackage, msg.sender);
        require(_canStake, "Cannot Stake");
        _burn(msg.sender, _stake);
        _stakingPackage = _stakingPackage * uintTime;
        addStakeholder(msg.sender, _stake, _stakingPackage);
        _totalStakes = _totalStakes.add(_stake);

    }



    function canStake(uint256 _stake, uint256 _stakingPackage, address account) 
    public view returns (bool b)
    {
        if(packages[_stakingPackage]>0 
        && _stake<=balanceOf(account) 
        && stakingOpen 
        && stakes[account] == 0 
        && _stake>0)
        {
            return true;
        }
        else
        {
            return false;
        }
    }



    /**
     * @notice A method for a stakeholder to remove a stake.
     * @param _stake The size of the stake to be removed.
     */
    function removeStake(uint256 _stake) public
    {
        stakes[msg.sender] = stakes[msg.sender].sub(_stake);
        if(stakes[msg.sender] == 0) { removeStakeholder(msg.sender); }
        _mint(msg.sender, _stake);
        _totalStakes = _totalStakes.sub(_stake);
    }


    function stakeOf(address _stakeholder) public view returns(uint256) 
    {
        return stakes[_stakeholder];
    }


    function totalStakes()   public view returns(uint256)
    {
        return _totalStakes;
    }


    function isStakeholder(address _address) public view returns(bool, uint256)
    {
        for(uint256 s = 0; s < stakeholders.length; s += 1)
        {
            if (_address == stakeholders[s]) return (true, s);
        }
        return (false, 0);
    }


    function addStakeholder(address _stakeholder, uint256 _stake, uint256 _package) private
    {
        (bool _isStakeholder, ) = isStakeholder(_stakeholder);
        if(!_isStakeholder) stakeholders.push(_stakeholder);
        stakingTimestamp[_stakeholder] = block.timestamp;
        stakingPackage[_stakeholder] = _package;
        stakes[_stakeholder] = _stake;
    }


    function removeStakeholder(address _stakeholder) private
    {
        (bool _isStakeholder, uint256 s) = isStakeholder(_stakeholder);
        if(_isStakeholder)
        {
            stakeholders[s] = stakeholders[stakeholders.length - 1];
            stakeholders.pop();
            stakingTimestamp[_stakeholder] = 0;
            stakingPackage[_stakeholder] = 0;
        } 
    }


    function rewardOf(address _stakeholder) public view returns(uint256)
    {
        (uint256 reward,) = calculateReward(_stakeholder);
        return reward;
    }

    function calculateReward(address _stakeholder) private view returns(uint256, uint256)
    {
        uint256 stakedAmount = stakes[_stakeholder];
        if(stakedAmount==0) { return (0, 0); }
        uint256 _stakingTimestamp =  stakingTimestamp[_stakeholder];
        if(_stakingTimestamp==0) {return (0, 0); }
        uint256 _currentTimestamp =  block.timestamp;
        uint256 _span = _currentTimestamp.sub(_stakingTimestamp);
        uint256 _stakingPackage = stakingPackage[_stakeholder];
        if(_span<_stakingPackage) { return (0, 0); }
        uint256  _loops = _span/_stakingPackage;
        uint256 rewardPercentage =  packages[_stakingPackage];
        uint256 _reward = stakedAmount.mul(rewardPercentage).mul(_loops).div(100);
        return (_reward, _loops);
    }

  
    // if a holder did not received reward automatically, 
    //holder can call this function to claim reward. 
    event RewardSent(address _address, uint256 _amount, uint256 _timestamp);
    function _withdrawReward(address _stakeholder)  internal 
    {
        (uint256 reward, uint256 loops) = calculateReward(_stakeholder);
        if(reward==0) {return;}
        uint256 myPackage = stakingPackage[msg.sender];

        stakingTimestamp[msg.sender] = (stakingTimestamp[msg.sender]).add(myPackage*loops);
        _mint(msg.sender, reward);
        emit RewardSent(_stakeholder, reward, block.timestamp);
    }


    function withdrawReward() external 
    {
        _withdrawReward(msg.sender);
    }

    // will send reward to only on holder at a time. 
    event CheckedForReward(address _address, uint256 timestamp);
    function distributeReward() public 
    {
        if(stakeholders.length==0) {return;}
        if(rewardDistributionIndex==stakeholders.length-1) 
        { 
            rewardDistributionIndex = 0; 
        }

        for(uint256 i=rewardDistributionIndex; i<stakeholders.length; i++)
        {
            address account = stakeholders[i];
            //emit CheckedForReward(account, block.timestamp);
            (uint256 reward,) = calculateReward(account);
            rewardDistributionIndex = i;
            if(reward==0) 
            { 
                continue; 
            }
            else 
            {
                _withdrawReward(account);
                break;
            }
        }
    }

}
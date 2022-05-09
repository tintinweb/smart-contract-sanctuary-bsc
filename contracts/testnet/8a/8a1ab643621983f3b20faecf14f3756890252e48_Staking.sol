/**
 *Submitted for verification at BscScan.com on 2022-05-09
*/

// import "https://github.com/NomicFoundation/hardhat/blob/master/packages/hardhat-core/console.sol";
// SPDX-License-Identifier: UNLISCENSED
pragma solidity 0.6.0;

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface BEP20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StakingFarmingTokenOne is BEP20, Ownable {
    using SafeMath for uint256;

    uint256 tokenBalance;

    string public constant name = "Staking Farming Token";
    string public constant symbol = "STAKEFARMING";
    // uint8   public constant decimals = 5;
    uint8 public constant decimals = 0;

    uint256 public _decimalFactor =10**5;
    // uint256 public _decimalFactor =0;
                        
    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 totalSupply_ = 1000000000; // 1 billion total supply

    //  address public owner;

    constructor() public {
        balances[msg.sender] = totalSupply_;
    }

    uint256 public RESERVED_STAKE_FARMING =  250000000; // reserved for staking/Farming allready = 250 million
    
    function totalSupply() public override view returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }

    function decimalFactor() external view returns (uint256) {
        return _decimalFactor;
    }

    function transfer(address receiver, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens) public override returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public override view returns (uint) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
    
    function transferToken(address owner, uint256 amount,uint256 numTokens) public payable returns(string memory,uint256) {
        balances[owner] = balances[owner].sub(numTokens);

        balances[msg.sender] = balances[msg.sender].add(numTokens);
        emit Transfer(msg.sender, owner, numTokens);
        payable(owner).transfer(amount);
        return("Token Transfer Done",numTokens);
    }   

    function _burn(address account, uint256 amount) internal returns (bool) {
        require(account != address(0), "ERC2020: burn from the zero address");
        emit Transfer(account, address(0), amount);
        return true;
    }

     function _mint(address account, uint256 amount) internal returns (bool) {
        require(account != address(0), "ERC2020: mint to the zero address");
        emit Transfer(address(0), account, amount);
        return true;
    }  

    function mint(address to, uint256 amount) public onlyOwner {
        require(totalSupply() + amount <= totalSupply(), "Token Maximum Supply reached." );
        _mint(to, amount);
    }
}

contract Staking is Context, StakingFarmingTokenOne {
    using SafeMath for uint256;

    address[] internal stakeholders;

    StakingFarmingTokenOne public STAKEFARM;

    struct stakeHolder {
        uint256 stakeType;
        uint256 token;
        uint256 stakeTime;
        uint256 months;
    }
    
    // uint256 public tokenPrice = 100000000000000000; //0.1;

    uint256 public tokenPrice;

    uint256 public APY = 2000; // 20%

    uint256 public OneMonthLockAPY = 400; // 1 month lock 400% apy
    uint256 public ThreeMonthLockAPY = 800; // 3 month 800% Apy
    uint256 public OneYearLockAPY = 2000; // 12 month 2000% Apy

    uint256 public unlockedStakeAPY = 200; // unlocked staking shedule with lowest APY (around 200% )

    // uint256 public DepositeTaxAPY = 0.05 ether; //deposit tax 10%(5% gets burnded 5% back into the protocol )
    uint256 public DepositeTaxAPY = 0.05 ether; //deposit tax 10%(5% gets burnded 5% back into the protocol )
    
    uint256 public DailyRewardTaxAPY = 50; //compound or unstake daily rewards tax 5 %(2.5% burn 2.5% back into the protocol)

    uint256 public UnstakeAPY = 1000; //unstake tax 10%(5% burn 5% back into the protocol)

    mapping(address => stakeHolder) public stakes;

    mapping(address => uint256) internal rewards;

    uint256 public totalTokenStaked;

    address public stakingAddress = msg.sender;

    uint256 public testingType;

    constructor(StakingFarmingTokenOne _address) public payable {
        STAKEFARM = _address;
    }

    function setTestingTypePauseOrUnpause(uint256 _value) public onlyOwner{
        testingType = _value;
    }

    function setTokenPrice(uint256 _value) public onlyOwner{
        tokenPrice = _value;
    }

    //create stake
    function createStake(uint256 numTokens,uint256 months,uint256 typeStake) public payable returns (bool)
    {
        // console.log("RESERVED_STAKE_FARMING",RESERVED_STAKE_FARMING);
        // console.log("totalTokenStaked",totalTokenStaked);

        require(numTokens > 0, "Cannot Stake 0");

        require(tokenPrice > 0, "Set token price");

        require(typeStake<3,"Please send number between 1(unlocked) or 2(locked)"); //1=unlocked and 2=locked
        
        uint256 finalTokenPrice = numTokens.mul(tokenPrice) + DepositeTaxAPY;
// console.log("finalTokenPrice",finalTokenPrice);
        require(
            msg.value == finalTokenPrice,
            "Price value mismatch"
        );
        
        require(
            STAKEFARM.totalSupply() >=(numTokens.add(totalTokenStaked)),
            "addition error"
        );

        require(
             _mint(_msgSender(), numTokens),
            "mint error"
        );

        stakeholders.push(_msgSender());
        totalTokenStaked = totalTokenStaked.add(numTokens);

        require(totalTokenStaked <= RESERVED_STAKE_FARMING, "Token Maximum Supply reached.");

        balances[stakingAddress] = balances[stakingAddress].sub(numTokens);

        uint256 previousStaked = stakes[_msgSender()].token;
        uint256 finalStaked = previousStaked.add(numTokens);

        stakes[_msgSender()] = stakeHolder(typeStake,finalStaked,block.timestamp,months);
        return true;
    }

    function removeStake(uint256 numTokens) public returns (bool){
        require(numTokens > 0, "Cannot removeStake 0");

        require(
            (stakes[msg.sender].stakeTime + 7 seconds) <= block.timestamp,
            "You have to stake for minimum 7 seconds."
        );

        uint256 stake = numTokens.mul(tokenPrice);        
        totalTokenStaked = totalTokenStaked.sub(numTokens);
        balances[stakingAddress] = balances[stakingAddress].add(numTokens);
        uint256 rew = calculateReward(msg.sender);

        // uint256 unstakeTax = 0.75 ether; // 5% unstake and 2.5% daily reward tax

        uint256 unstakeTax = 750000000000000000;

        // uint256 finalReward = unstakeTax.sub(rew);

        if(rew > unstakeTax){
            uint256 finalReward = rew.sub(unstakeTax);
            //  console.log("finalReward",finalReward);
            msg.sender.send(finalReward);
        }else{
            // console.log("no");

            uint256 finalReward = unstakeTax.sub(rew);
            //  console.log("finalReward",finalReward);
            msg.sender.send(finalReward);
        }

        uint256 previousStaked = stakes[_msgSender()].token;
        uint256 finalStaked = previousStaked.sub(numTokens);

        // console.log("previousStaked",previousStaked);
        // console.log("finalStaked",finalStaked);

        // console.log("unstakeTax",unstakeTax);
        // msg.sender.send(rew);
        // msg.sender.send(stake);
        msg.sender.transfer(stake);

        if(stakes[msg.sender].token == 0){
            stakes[msg.sender] = stakeHolder(0,0,0,0);
            removeStakeholder(msg.sender);
            return true;
        }else{
            stakes[msg.sender] = stakeHolder(0,finalStaked,0,0);
            return true;
        }       
    }

    //get stake
    function stakeOf(address _stakeholder) public view returns (uint256) {
        return stakes[_stakeholder].token;
    }

    function isStakeholder(address _address) public view returns (bool, uint256)
    {
        for (uint256 s = 0; s < stakeholders.length; s += 1) {
            if (_address == stakeholders[s]) return (true, s);
        }
        return (false, 0);
    }

    function removeStakeholder(address _stakeholder) internal {
        (bool _isStakeholder, uint256 s) = isStakeholder(_stakeholder);
        if (_isStakeholder) {
            stakeholders[s] = stakeholders[stakeholders.length - 1];
            stakeholders.pop();
        }
    }

    //reward of
    function rewardOf(address _stakeholder) public view returns (uint256) {
        return rewards[_stakeholder];
    }

     // calculate stake
    function calculateReward(address _stakeholder) public view returns (uint256)
    {
        // 1 month = 30 days
        // 3 month = 91 days
        // 12 month = 365 days
        require(stakes[_stakeholder].token > 0, "Please first stake token");

        uint256 reward;
        uint256 stakeAPY;

        uint256 stakeType = stakes[_stakeholder].stakeType;

        uint256 stakeToken = stakes[_stakeholder].token;

        uint256 staketokenPrice = stakeToken.mul(tokenPrice);

        uint256 stakeMonths = stakes[msg.sender].months;
        // console.log("stakeType",stakes[msg.sender].stakeType);

        if(stakeType == 1){
            stakeAPY = unlockedStakeAPY;
        }else{
            if(stakeMonths == 30){
                if (block.timestamp >= (stakes[_stakeholder].stakeTime + 30 days)) {
                    stakeAPY = OneMonthLockAPY;
                }else if (block.timestamp >= (stakes[_stakeholder].stakeTime + 1 minutes)) {
                    stakeAPY = OneMonthLockAPY;
                }else{
                    // require((stakes[_stakeholder].stakeTime + 30 days) > 0, "You cannot unstake before time");
                    require((block.timestamp >= (stakes[_stakeholder].stakeTime + 1 minutes)), "You cannot unstake before time");
                }
            }else if(stakeMonths == 91){
                if (block.timestamp >= (stakes[_stakeholder].stakeTime + 91 days)) {
                    stakeAPY = ThreeMonthLockAPY;
                }else if (block.timestamp >= (stakes[_stakeholder].stakeTime + 5 minutes)) {
                    stakeAPY = ThreeMonthLockAPY;
                }else{
                    // require((stakes[_stakeholder].stakeTime + 91 days)   > 0, "You cannot unstake before time");
                    require((block.timestamp >= (stakes[_stakeholder].stakeTime + 5 minutes)), "You cannot unstake before time");
                }

            }else if(stakeMonths == 365){
                if (block.timestamp >= (stakes[_stakeholder].stakeTime + 365 days)) {
                    stakeAPY = OneYearLockAPY;
                }else if (block.timestamp >= (stakes[_stakeholder].stakeTime + 7 minutes)) {
                    stakeAPY = OneYearLockAPY;
                }else{
                    // require((stakes[_stakeholder].stakeTime + 365 days)   > 0, "You cannot unstake before time");
                    require((block.timestamp >= (stakes[_stakeholder].stakeTime + 7 minutes)), "You cannot unstake before time");
                }
            }
        }
        
        // console.log("stakeAPY",stakeAPY);

        if (stakeAPY > 0) {
            // reward = (staketokenPrice.mul(stakeAPY)).div( uint256(1000)); 
            reward = (staketokenPrice.mul(stakeAPY)).div( uint256(100)); 
        } else {
            reward = 0;
        }

        return reward;
    }

    function viewReward(address _stakeholder) public view returns (uint256) {
        uint256 reward;

        uint256 stakeToken = stakes[_stakeholder].token;
        uint256 staketokenPrice = stakeToken.mul(tokenPrice);

        // reward = (staketokenPrice.mul(APY)).div( uint256(10000)); 
        reward = (staketokenPrice.mul(APY)).div( uint256(100));
        return reward;
    }

    // distribute rewards
    function distributeRewards() public onlyOwner {
        for (uint256 s = 0; s < stakeholders.length; s += 1) {
            address stakeholder = stakeholders[s];
            uint256 reward = calculateReward(stakeholder);
            rewards[stakeholder] = rewards[stakeholder].add(reward);
        }
    }

    //   withdraw rewards
    function withdrawReward() public {
        uint256 reward = calculateReward(_msgSender());
        rewards[msg.sender] = 0;
        _msgSender().transfer(reward);
    }
}
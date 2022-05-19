/**
 *Submitted for verification at BscScan.com on 2022-05-19
*/

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


contract SliceLedger is BEP20,Ownable {
    using SafeMath for uint256;
    
    event Bought(uint256 amount);
    event Sold(uint256 amount);
    event TransferSent(address _from, address _destAddr, uint _amount);
    
    // BEP20 public token;

    // string public constant name = "Good Vibes Only Token";
    // string public constant symbol = "GVO";
    string public constant name = "sliceLedger";
    string public constant symbol = "SLICE";
    // uint8 public constant decimals = 8;
     uint8 public constant decimals = 18;
    uint256 public _decimalFactor =10**18;
    // uint256 public _decimalFactor = 10**8;

    uint public OneToken = 0.375 ether;

    uint256 tokenBalance;

    
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event Transfer(address indexed from, address indexed to, uint tokens);

    
    mapping(address => uint256) balances;

    mapping(address => mapping (address => uint256)) allowed;

    mapping(address => mapping(address => uint256)) private _allowances;

     uint256 totalSupply_ = 1000000000 * _decimalFactor;
    // uint256 totalSupply_ = 16000000.00000000;

    // using SafeMath for uint256;
    address public ownerAddress = msg.sender;

    constructor() public {
        balances[msg.sender] = totalSupply_; 
    }

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
    // function transferToken(address owner, uint256 amount,uint256 numTokens) public payable returns(string memory,uint256) {
    //     balances[owner] = balances[owner].sub(numTokens);

    //     balances[msg.sender] = balances[msg.sender].add(numTokens);
    //     emit Transfer(msg.sender, owner, numTokens);
    //     payable(owner).transfer(amount);

    //     return("Token Transfer Done",numTokens);
    // }   
    function _burn(address account, uint256 amount) internal returns (bool) {
        require(account != address(0), "ERC2020: burn from the zero address");

        emit Transfer(account, address(0), amount);
        return true;
    }
    function _mint(address account, uint256 amount) internal returns (bool) {
        require(account != address(0), "ERC2020: mint to the zero address");
        // _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
        return true;
    }  

    function transferToken(uint256 amount,uint256 numTokens) public payable returns(string memory,uint256) {
        balances[ownerAddress] = balances[ownerAddress].sub(numTokens);

        balances[msg.sender] = balances[msg.sender].add(numTokens);
        // emit Transfer(msg.sender, owner, numTokens);
        emit Transfer(ownerAddress,msg.sender,numTokens);

        payable(ownerAddress).transfer(amount);
        return("Token Transfer Done",numTokens);
    }   

    function buyToken(uint256 numTokens) public payable returns(string memory,uint256) {
        balances[ownerAddress] = balances[ownerAddress].sub(numTokens);

        balances[msg.sender] = balances[msg.sender].add(numTokens);
        // emit Transfer(msg.sender, ownerAddress, numTokens);
        emit Transfer(ownerAddress,msg.sender,numTokens);
        return("Token Transfer Done",numTokens);
    }

    function saleToken(uint256 numTokens) public payable returns(string memory,uint256) {
        balances[ownerAddress] = balances[ownerAddress].add(numTokens);

        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        // emit Transfer(ownerAddress,msg.sender, numTokens);
        emit Transfer(msg.sender,ownerAddress,numTokens);
        return("Token Transfer Done",numTokens);
    }
}
contract Staking is Context, SliceLedger {
    using SafeMath for uint256;

    address[] internal stakeholders;

    SliceLedger public Slice;

    struct stakeHolder {
        uint256 token;
        uint256 stakeTime;
    }
    
    uint256 public tokenPrice = 100000000000000000; //0.1;

    uint256 public APY = 2000; // 20%
    mapping(address => stakeHolder) public stakes;

    mapping(address => uint256) internal rewards;

    uint256 public totalTokenStaked;

    // address public stakingAddress = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    address public stakingAddress = msg.sender;


    constructor(SliceLedger _address) public payable {
        Slice = _address;
    }

    //create stake
    function createStake(uint256 numTokens) public payable returns (bool)
    {
        require(numTokens > 0, "Cannot removeStake 0");

        require(
            msg.value == numTokens.mul(tokenPrice),
            "Price value mismatch"
        );
        require(
            // Bharat.totalSupply() >=(numTokens.mul(Bharat.decimalFactor().add(totalTokenStaked))),
            Slice.totalSupply() >=(numTokens.add(totalTokenStaked)),
            "addition error"
        );
        require(
            // _mint(_msgSender(), numTokens.mul(Bharat.decimalFactor())),
             _mint(_msgSender(), numTokens),
            "mint error"
        );
        stakeholders.push(_msgSender());
        totalTokenStaked = totalTokenStaked.add(numTokens);
        balances[stakingAddress] = balances[stakingAddress].sub(numTokens);

        uint256 previousStaked = stakes[_msgSender()].token;
        uint256 finalStaked = previousStaked.add(numTokens);

        stakes[_msgSender()] = stakeHolder(finalStaked, block.timestamp);
        return true;
    }

    function removeStake(uint256 numTokens) public returns (bool){
        require(numTokens > 0, "Cannot removeStake 0");

        require(
            (stakes[msg.sender].stakeTime + 7 seconds) <= block.timestamp,
            "You have to stake for minimum 7 seconds."
        );

        require(
            stakes[msg.sender].token == numTokens,
            "You have to unstake all your tokens"
        );

        uint256 stake = numTokens.mul(tokenPrice);        
        totalTokenStaked = totalTokenStaked.sub(numTokens);
        balances[stakingAddress] = balances[stakingAddress].add(numTokens);
        uint256 rew = calculateReward(msg.sender);

        // uint256 totalAmount = stake.add(rew);
        // uint256 amount = 12000000000000000;
     
        // msg.sender.transfer(totalAmount/100);

        msg.sender.transfer(rew);
        msg.sender.send(stake);

        stakes[msg.sender] = stakeHolder(0, 0);
        removeStakeholder(msg.sender);
        return true;
    }

    //get stake
    function stakeOf(address _stakeholder) public view returns (uint256) {
        return stakes[_stakeholder].token;
    }

    function isStakeholder(address _address)
        public
        view
        returns (bool, uint256)
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
    function calculateReward(address _stakeholder)
        public
        view
        returns (uint256)
    {
        uint256 reward;

        // uint256 stakeTime = stakes[_stakeholder].stakeTime + 7 seconds;
        uint256 stakeToken = stakes[_stakeholder].token;
        uint256 staketokenPrice = stakeToken.mul(tokenPrice);

        if ((stakes[_stakeholder].stakeTime + 7 seconds) <= block.timestamp) {
            reward = (staketokenPrice.mul(APY)).div( uint256(10000)); 
        } else {
            reward = 0;
        }


        return reward;
    }

    function viewReward(address _stakeholder) public view returns (uint256) {
        uint256 reward;

        uint256 stakeToken = stakes[_stakeholder].token;
        uint256 staketokenPrice = stakeToken.mul(tokenPrice);

        reward = (staketokenPrice.mul(APY)).div( uint256(10000)); 

        // console.log("Sender balance is %s reward",reward);
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
/**
 *Submitted for verification at BscScan.com on 2022-12-12
*/

pragma solidity ^0.8.11;

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

    //Contracts interface
    function swapExactTokensForTokens(uint _amountIn, uint _amountOutMin, address[] memory path, address to, uint deadline) external;
    function deposit(uint256 _pid, uint256 _amount) external;
    function burn(uint256 _amount) external;
    function AddRewards(uint256 _amount) external;
    function withdraw(uint256 _pid, uint256 _amount) external;
    function pendingXMS(uint _pid, address _user) external view returns (uint256);
    function accrualBlockNumber() external view returns (uint256);
    function exchangeRateStored() external view returns (uint256);
    function mint(uint _amount) external;
    function redeemUnderlying(uint _amount) external;
    function accrueInterest() external;

    //Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
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

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
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

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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

contract KinectVault {
    using SafeMath for uint256;

    //Core Variables
    uint public Total; 
    uint public SValue; 
    uint public PendingClaim;
    uint public VaultId;
    mapping(address => uint) public UserS;
    mapping(address => uint) public Stake;

    address public owner;
    bool public burnEnabled;

    //Vault Contract Address
    IBEP20 public contractAddress = IBEP20(0x8BB0d002bAc7F1845cB2F14fe3D6Aae1D1601e29);
    IBEP20 public rewardToken = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    IBEP20 public stakeToken = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

    //Core Contracts
    address private BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address private WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    IBEP20 public kinectToken = IBEP20(0xA08C6B8Bc022F0B34cE5d34AA9cc7A612Ae9583D);
    IBEP20 private pancakeRouterv2 = IBEP20(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    IBEP20 public dividendVault = IBEP20(0xf42f02E6E52EA35a8c41B85D41E36E8Bfb99417A);

    //Events
    event userDeposit(address user, uint256 amount);
    event userWithdrawl(address user, uint256 amount);
    event DistributedRewards(uint256 amount);

    //Initializing Core Values
    constructor(uint _vaultid) {
        Total = 0;
        SValue = 0;
        PendingClaim = 0;
        VaultId = _vaultid;
        burnEnabled = true;
        owner = msg.sender;

        //Approving Contracts
        stakeToken.approve(address(contractAddress), 2**256 - 1);
        rewardToken.approve(address(pancakeRouterv2), 2**256 - 1);
        kinectToken.approve(address(dividendVault), 2**256 - 1);
    }

    function toggleBurn(bool _burnToggle) public {
        if(msg.sender == owner) {
            burnEnabled = _burnToggle;
        } else {
            revert();
        }
    }
    

    //Deposit assets into the vault
    function Deposit(uint256 _amount) external {
        require(stakeToken.transferFrom(msg.sender, address(this), _amount));
        emit userDeposit(msg.sender, _amount);
        contractAddress.mint(_amount);
        this.Redeem();
        Stake[msg.sender] = Stake[msg.sender].add(_amount);
        UserS[msg.sender] = SValue;
        Total = Total.add(_amount);
    }

    //Withdrawl your assets
    function Withdrawl(uint _amount) external {
        if(_amount <= Stake[msg.sender]) {
            emit userWithdrawl(msg.sender, _amount);
            contractAddress.redeemUnderlying(_amount);
            stakeToken.transfer(msg.sender, _amount);
            this.Redeem();
            Stake[msg.sender] = Stake[msg.sender].sub(_amount);
            Total = Total.sub(_amount);
        } else {
            revert();
        }
    }

    function Redeem() external {
        this.SwapRewardAndDistribute();
        uint deposited = Stake[tx.origin];
        uint reward = (deposited.mul(((SValue.sub(UserS[tx.origin])))).div(10**18));
        if(reward > 0) {
            UserS[tx.origin] = SValue;
            PendingClaim = PendingClaim.sub(reward);
            kinectToken.transfer(tx.origin, reward);
        }
    }

    //Add & distribute rewards
    function SwapRewardAndDistribute() external {
        contractAddress.accrueInterest();
        uint contractBalance = this.contractBalance();
        uint availableRewards = contractBalance.sub(Total);

        contractAddress.redeemUnderlying(availableRewards);
        uint rewardBalance = rewardToken.balanceOf(address(this));
        if(rewardBalance > 0) {
            address[] memory path = new address[](4);
            path[0] = address(rewardToken);
            path[1] = address(kinectToken);

            uint totalTokenBalance = rewardToken.balanceOf(address(this));

            pancakeRouterv2.swapExactTokensForTokens(
                totalTokenBalance,
                0, // accept any amount of BUSD
                path,
                address(this),
                block.timestamp
            );

            uint kntBalance = kinectToken.balanceOf(address(this));
            if(burnEnabled = true) {
                kinectToken.burn(kntBalance * 5 / 100);
                require(kinectToken.transfer(address(dividendVault), kntBalance * 5 / 100));
            } else {
                require(kinectToken.transfer(address(dividendVault), kntBalance * 10 / 100));
            }
        }

        uint kntBalance = kinectToken.balanceOf(address(this));
        if(kntBalance > 0 && Total != 0) {
            uint rewardsToDistribute = kntBalance.sub(PendingClaim);
            SValue = SValue.add(((rewardsToDistribute * 10**18).div(Total)));
            PendingClaim = kntBalance;
            emit DistributedRewards(rewardsToDistribute);
        }
    }

    //Get your current balance
    function balanceOf(address _user) public view returns(uint) {
        uint deposited = Stake[_user];
        return deposited;
    }

    function accrualBlockNumber() public view returns(uint) {
        uint blocknumber = contractAddress.accrualBlockNumber();
        return blocknumber;
    }

    function exchangeRateStored() public view returns(uint) {
        uint exchangeRate = contractAddress.exchangeRateStored();
        return exchangeRate;
    }

    function contractBalance() public view returns(uint) {
        uint balance = contractAddress.balanceOf(address(this));
        uint exchangeRate = this.exchangeRateStored();
        uint contractBalance = (balance.mul(exchangeRate)).div(10**18);
        return contractBalance;
    }

    //Check what your pending rewards are
    function rewardsOf(address _user) public view returns(uint) {
        uint deposited = Stake[_user];
        uint reward = (deposited.mul(((SValue.sub(UserS[_user])))).div(10**18));
        return reward;
    }
}
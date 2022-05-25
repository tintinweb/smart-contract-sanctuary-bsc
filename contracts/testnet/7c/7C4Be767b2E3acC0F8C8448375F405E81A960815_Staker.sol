/**
 *Submitted for verification at BscScan.com on 2022-05-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// import "./GameItems.sol";
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
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
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

/**
 * @dev Interface of the BEP standard.
 */
interface IBEP20 {
    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Returns the token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Staker is Ownable {
    using SafeMath for uint256;

    IBEP20 public rewardToken;
    mapping(uint256 => uint256) public rewardPercentage;

    function setRewardPercentage(uint256 timeSpan, uint256 reward)
        public
        onlyOwner
    {
        rewardPercentage[timeSpan] = reward;
    }
      function setRewardToken(address _rewardToken)
        public
        onlyOwner
    {
        rewardToken= IBEP20(_rewardToken);
    }

    mapping(uint256 => address) public ownerOf;
    struct Stake {
        uint256 totalAmountStaked;
        uint256 start;
        uint256 rewardPercentageToGive;
        uint256 timespan;
        bool withdrawn;
    }
    mapping(address => Stake) public stakes;

    function stake(uint256 _amount, uint256 _timespan)
        public
        returns (uint256 _tokenId)
    {
        // require(_amount >= 100000 ether);
        require(_amount > 0, "Minimum of 1 token can be staked");
        require(
            rewardPercentage[_timespan] > 0,
            "No Reward Percentage is defined for this time limit"
        );
        require(
            rewardToken.transferFrom(msg.sender, address(this), _amount),
            "Could Not Transfer Tokens"
        );
        Stake memory _stake = stakes[msg.sender];
        _stake = Stake({
            totalAmountStaked: _amount.add(_stake.totalAmountStaked),
            start: block.timestamp,
            timespan: _timespan,
            withdrawn: false,
            rewardPercentageToGive: rewardPercentage[_timespan]
        });
        ownerOf[_tokenId] = msg.sender;
    }

    function unstake() public {
        Stake memory _s = stakes[msg.sender];

        require(_s.withdrawn == false);
        require(block.timestamp >= _s.start + _s.timespan);
        require(
            rewardToken.transfer(
                msg.sender,
                _s.totalAmountStaked
            )
        );
        _s.withdrawn = true;
        _s.totalAmountStaked = 0;
        stakes[msg.sender] = _s;
    }

    function getStakeInformation(address user)
        external
        view
        returns (
            uint256 totalAmount,
            uint256 rewardP,
            bool hasWithdrawn
        )
    {
        Stake storage _s = stakes[msg.sender];
        return (_s.totalAmountStaked, _s.rewardPercentageToGive, _s.withdrawn);
    }

    constructor(address _token) {
        rewardPercentage[604800] = 300; // Reward for 7 days; // 7%
        rewardPercentage[2592000] = 500; // Reward for 30 days; // 10%
        rewardPercentage[7776000] = 800; // Reward for 90 days; //15%
        rewardToken = IBEP20(_token);
    }
}
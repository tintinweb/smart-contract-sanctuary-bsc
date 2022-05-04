/**
 *Submitted for verification at BscScan.com on 2022-05-04
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;



// Part: OpenZeppelin/[email protected]/Context

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// Part: OpenZeppelin/[email protected]/IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// Part: OpenZeppelin/[email protected]/Ownable

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: SavvyFinanceStaking.sol

contract SavvyFinanceStaking is Ownable {
    address[] public tokens;
    mapping(address => bool) public tokenIsActive;
    struct TokenDetails {
        address admin;
        uint256 price;
        uint256 balance;
        uint256 interestRate;
        uint256 timestampAdded;
        uint256 timestampLastUpdated;
    }
    mapping(address => TokenDetails) public tokensData;

    struct TokenRewardDetails {
        uint256 amount;
        mapping(address => uint256) stakerAmount;
        uint256 timestampAdded;
        uint256 timestampLastUpdated;
    }
    mapping(address => TokenRewardDetails[]) public tokensRewardsData;

    address[] public stakers;
    mapping(address => bool) public stakerIsActive;
    struct StakerDetails {
        uint256 uniqueTokensStaked;
        uint256 timestampAdded;
        uint256 timestampLastUpdated;
    }
    mapping(address => StakerDetails) public stakersData;

    struct StakingDetails {
        uint256 balance;
        address rewardToken;
        uint256 timestampAdded;
        uint256 timestampLastUpdated;
    }
    mapping(address => mapping(address => StakingDetails)) public stakingData;

    struct StakingRewardDetails {
        uint256 balance;
        uint256 timestampAdded;
        uint256 timestampLastUpdated;
    }
    mapping(address => mapping(address => StakingRewardDetails))
        public stakingRewardsData;

    function tokenExists(address _token) public returns (bool) {
        for (uint256 tokenIndex = 0; tokenIndex < tokens.length; tokenIndex++) {
            if (tokens[tokenIndex] == _token) return true;
        }
        return false;
    }

    function addToken(address _token, address _admin) public onlyOwner {
        require(!tokenExists(_token), "Token already exists.");
        tokens.push(_token);
        tokensData[_token].admin = _admin == address(0x0) ? msg.sender : _admin;
        tokensData[_token].timestampAdded = block.timestamp;
    }

    function activateToken(address _token) public onlyOwner {
        require(tokenExists(_token), "Token does not exist.");
        tokenIsActive[_token] = true;
    }

    function deactivateToken(address _token) public onlyOwner {
        require(tokenExists(_token), "Token does not exist.");
        tokenIsActive[_token] = false;
    }

    function setTokenAdmin(address _token, address _admin) public onlyOwner {
        require(tokenExists(_token), "Token does not exist.");
        tokensData[_token].admin = _admin;
        tokensData[_token].timestampLastUpdated = block.timestamp;
    }

    function setTokenPrice(address _token, uint256 _price) public onlyOwner {
        require(tokenExists(_token), "Token does not exist.");
        tokensData[_token].price = _price;
        tokensData[_token].timestampLastUpdated = block.timestamp;
    }

    function setTokenInterestRate(address _token, uint256 _interestRate)
        public
        onlyOwner
    {
        require(tokenExists(_token), "Token does not exist.");
        require(
            msg.sender == tokensData[_token].admin,
            "Only the token admin can do this."
        );
        require(
            _interestRate > 0 && _interestRate < 5 * 10**18,
            "Interest rate must be greater than zero and less than 5."
        );
        tokensData[_token].interestRate = _interestRate;
        tokensData[_token].timestampLastUpdated = block.timestamp;
    }

    function depositToken(address _token, uint256 _amount) public {
        require(tokenExists(_token), "Token does not exist.");
        require(
            msg.sender == tokensData[_token].admin,
            "Only the token admin can do this."
        );
        require(_amount > 0, "Amount must be greater than zero.");
        require(
            IERC20(_token).balanceOf(msg.sender) >= _amount,
            "Insufficient token balance."
        );
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        tokensData[_token].balance += _amount;
    }

    function withdrawToken(address _token, uint256 _amount) public {
        require(tokenExists(_token), "Token does not exist.");
        require(
            msg.sender == tokensData[_token].admin,
            "Only the token admin can do this."
        );
        require(_amount > 0, "Amount must be greater than zero.");
        require(
            tokensData[_token].balance >= _amount,
            "Amount is greater than token balance."
        );
        IERC20(_token).transfer(msg.sender, _amount);
        tokensData[_token].balance -= _amount;
    }

    function stakeToken(address _token, uint256 _amount) public {
        require(tokenIsActive[_token], "Token not active.");
        require(_amount > 0, "Amount must be greater than zero.");
        require(
            IERC20(_token).balanceOf(msg.sender) >= _amount,
            "Insufficient token balance."
        );
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        if (stakingData[_token][msg.sender].balance == 0) {
            if (stakersData[msg.sender].uniqueTokensStaked == 0) {
                stakers.push(msg.sender);
                stakerIsActive[msg.sender] = true;
            }
            stakersData[msg.sender].uniqueTokensStaked++;
            stakersData[msg.sender].timestampLastUpdated = block.timestamp;
            stakingData[_token][msg.sender].rewardToken = _token;
        }
        stakingData[_token][msg.sender].balance += _amount;
    }

    function unstakeToken(address _token, uint256 _amount) public {
        // require(tokenIsActive[_token], "Token not active.");
        require(_amount > 0, "Amount must be greater than zero.");
        require(
            stakingData[_token][msg.sender].balance >= _amount,
            "Amount is greater than token staking balance."
        );
        if (stakingData[_token][msg.sender].balance == _amount) {
            if (stakersData[msg.sender].uniqueTokensStaked == 1) {
                stakerIsActive[msg.sender] = false;
            }
            stakersData[msg.sender].uniqueTokensStaked--;
            stakersData[msg.sender].timestampLastUpdated = block.timestamp;
        }
        stakingData[_token][msg.sender].balance -= _amount;
        IERC20(_token).transfer(msg.sender, _amount);
    }

    function setStakingRewardToken(address _token, address _reward_token)
        public
    {
        require(
            stakerIsActive[msg.sender],
            "You do not have this token staked."
        );
        require(tokenIsActive[_token], "Token not active.");
        require(tokenIsActive[_reward_token], "Reward token not active.");
        stakingData[_token][msg.sender].rewardToken = _reward_token;
    }

    function rewardStakers() public onlyOwner {
        for (uint256 tokenIndex = 0; tokenIndex < tokens.length; tokenIndex++) {
            address token = tokens[tokenIndex];
            if (!tokenIsActive[token]) continue;
            uint256 tokenPrice = tokensData[token].price;
            uint256 tokenInterestRate = tokensData[token].interestRate;
            uint256 tokenRewardIndex = tokensRewardsData[token].length;
            uint256 tokenRewardAmount;
            for (
                uint256 stakerIndex = 0;
                stakerIndex < stakers.length;
                stakerIndex++
            ) {
                address staker = stakers[stakerIndex];
                if (!stakerIsActive[staker]) continue;
                uint256 stakerTokenBalance = stakingData[token][staker].balance;
                if (stakerTokenBalance <= 0) continue;
                uint256 stakerRewardAmount = (stakerTokenBalance * tokenPrice) /
                    (100 / tokenInterestRate);
                tokenRewardAmount += stakerRewardAmount;
                tokensRewardsData[token][tokenRewardIndex].stakerAmount[
                        staker
                    ] = stakerRewardAmount;
                stakingRewardsData[token][staker].balance += stakerRewardAmount;
            }
            tokensData[token].balance -= tokenRewardAmount;
            tokensRewardsData[token][tokenRewardIndex]
                .amount = tokenRewardAmount;
            tokensRewardsData[token][tokenRewardIndex].timestampAdded = block
                .timestamp;
        }
    }

    function withdrawReward(address _token, uint256 _amount) public {
        require(_amount > 0, "Amount must be greater than zero.");
        require(
            stakingRewardsData[_token][msg.sender].balance >= _amount,
            "Amount is greater than token reward balance."
        );
        stakingRewardsData[_token][msg.sender].balance -= _amount;
        IERC20(_token).transfer(msg.sender, _amount);
    }

    function transferToken(
        address _token,
        address _to,
        uint256 _amount
    ) public onlyOwner {
        IERC20(_token).transfer(_to, _amount);
    }
}
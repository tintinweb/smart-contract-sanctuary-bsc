// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.14;

import "./IFee.sol";

contract EstateXStakingPool {

    event StakeLimitUpdated(Stake);
    event Staking(address indexed userAddress, StakingType level, uint256 amount);
    event Withdraw(address indexed userAddress, uint256 withdrawAmount);
    event SignerAddressUpdated(address indexed previousSigner, address indexed newSigner); 
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    enum StakingType {GOLDEN, DYNAMIC}

    IFee public token;
    uint256 decimals;

    struct UserDetail {
        StakingType level;
        uint256 amount;
        uint256 initialTime;
        uint256 endTime;
        uint256 rewardAmount;
        uint256 withdrawAmount;
        bool status;
    }

    struct Stake {
        uint256 minStakeAmount;
        uint256 rewardPercent;
        uint256 stakeLimit;
    }

    struct Sign {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 nonce;
    }

    mapping(address => mapping(StakingType => UserDetail)) internal users;
    mapping(StakingType => Stake) internal stakingDetails;

    address public owner;
    address public signer;

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    constructor (IFee _token) {
        token = _token;
        decimals = token.decimals();
        owner = msg.sender;
        signer = msg.sender;
        stakingDetails[StakingType.GOLDEN] = Stake(20000 * 10 ** decimals, 20, 365 days);
        stakingDetails[StakingType.DYNAMIC] = Stake(1000 * 10 ** decimals, 6, 30 days); 
    }

    function setSignerAddress(address newSigner) external returns(bool) {
        require(signer == msg.sender, "caller is not a signer");
        require(newSigner != address(0), "Invalid address");
        emit SignerAddressUpdated(signer, newSigner);
        signer = newSigner;
        return true;
    }

   function setStakeDetails(StakingType level, Stake memory _stakeDetails) external onlyOwner returns(bool) {
        require(level == StakingType.GOLDEN || level == StakingType.DYNAMIC , "Invalid level");
        stakingDetails[level] = _stakeDetails;
        emit StakeLimitUpdated(stakingDetails[level]);
        return true;
    }

    function transferOwnership(address newOwner) public onlyOwner returns(bool){
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        return true;
    }

    function recoverCoin(uint256 amount) external onlyOwner {
        payable(owner).transfer(amount);
    }

    function recoverToken(address tokenAddr, uint256 amount) external onlyOwner {
        IERC20(tokenAddr).transfer(owner, amount);
    }

    function stake(uint256 amount, StakingType level, Sign memory sign) external returns(bool) {
        require(level == StakingType.GOLDEN || level == StakingType.DYNAMIC , "Invalid level");
        require(amount >= stakingDetails[level].minStakeAmount, "Invalid staking amount");
        require(!(users[msg.sender][level].status),"user already exist");
        verifySign(uint256(level), msg.sender, sign);
        uint256 fee = IFee(token).taxFee();
        uint256 tAmount = fee != 0 ? amount - amount * fee / 100 : amount;
        users[msg.sender][level].amount = tAmount;
        users[msg.sender][level].level = StakingType(level);
        users[msg.sender][level].endTime = block.timestamp + stakingDetails[level].stakeLimit;        
        users[msg.sender][level].initialTime = block.timestamp;
        users[msg.sender][level].status = true;
        token.transferFrom(msg.sender, address(this), amount);
        emit Staking(msg.sender, level, amount);
        return true;
    }
    
    function withdraw(StakingType level, Sign memory sign) external returns(bool) {
        require(level == StakingType.GOLDEN || level == StakingType.DYNAMIC , "Invalid level");
        require(users[msg.sender][level].status, "user not exist");
        require(users[msg.sender][level].endTime <= block.timestamp, "time not exceeds");
        verifySign(uint256(level), msg.sender, sign);
        uint256 rewardAmount = getRewards(msg.sender, level);
        uint256 amount = rewardAmount + users[msg.sender][level].amount;
        token.transfer(msg.sender, amount);
        uint256 rAmount = rewardAmount + users[msg.sender][level].rewardAmount;
        uint256 wAmount = amount + users[msg.sender][level].withdrawAmount;
        users[msg.sender][level] = UserDetail(level, 0, 0, 0, rAmount, wAmount, false);
        emit Withdraw(msg.sender, amount);
        return true;
    }

    function emergencyWithdraw(StakingType level, Sign memory sign) external returns(uint256) {
        require(level == StakingType.GOLDEN || level == StakingType.DYNAMIC , "Invalid level");
        require(users[msg.sender][level].status, "user not exist");
        verifySign(uint256(level), msg.sender, sign);
        uint256 stakeAmount = users[msg.sender][level].amount; 
        token.transfer(msg.sender, stakeAmount);
        uint256 rewardAmount = users[msg.sender][level].rewardAmount;
        uint256 withdrawAmount = users[msg.sender][level].withdrawAmount;
        users[msg.sender][level] = UserDetail(level, 0, 0, 0, rewardAmount, withdrawAmount, false);
        emit Withdraw(msg.sender, stakeAmount);
        return stakeAmount;
    }

    function getUserDetails(address account, StakingType level) external view returns(UserDetail memory, uint256 rewardAmount) {
        uint256 reward = getRewards(account, level);
        return (users[account][level], reward);
    }

    function getRewards(address account, StakingType level) public view returns(uint256) {
        uint256 stakeAmount = users[account][level].amount;
        uint256 timeDiff;
        unchecked {
            timeDiff = block.timestamp - users[account][level].initialTime;
        }
        uint256 rewardRate = stakingDetails[users[account][level].level].rewardPercent;
        uint256 rewardAmount = stakeAmount * rewardRate * timeDiff / 365 days / 100;
        return rewardAmount;
    }

    function verifySign(
        uint256 plan,
        address caller,
        Sign memory sign
    ) internal view {
        bytes32 hash = keccak256(
            abi.encodePacked(this, plan, caller, sign.nonce)
        );
        require(
            signer ==
                ecrecover(
                    keccak256(
                        abi.encodePacked(
                            "\x19Ethereum Signed Message:\n32",
                            hash
                        )
                    ),
                    sign.v,
                    sign.r,
                    sign.s
                ),
            "Owner sign verification failed"
        );
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.14;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";


interface IFee is IERC20Metadata{
    function taxFee() external view returns(uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}
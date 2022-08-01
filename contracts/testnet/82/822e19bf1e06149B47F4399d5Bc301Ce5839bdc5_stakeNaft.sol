// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.14;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract stakeNaft is Ownable {
    event StakeLimitUpdated(Stake);
    event Staking(address userAddress, uint256 plan, uint256 amount);
    event Withdraw(address userAddress, uint256 withdrawAmount);
    event SignerAddressUpdated(address oldSigner, address newSigner);

    address public signer;

    enum Asset {
        NAFT,
        ANCHOR,
        NIOB
    }

    struct UserDetail {
        Asset assetType;
        uint256 plan;
        uint256 amount;
        uint256 initialTime;
        uint256 duration;
        uint256 rewardPercent;
        bool status;
    }

    struct Stake {
        uint256 stakeDuration;
        uint256 rewardPercent;
    }

    struct Sign {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 nonce;
    }

    uint256 minimumStakeAmount = 100 * 10**18;

    address public naft;
    address public niob;
    address public anchor;

    mapping(address => mapping(Asset => mapping(uint256 => UserDetail))) internal users;
    mapping(address => mapping(uint256 => Stake)) internal stakingDetails;
    mapping(Asset => address) internal assetAddress;

    constructor(
        address _naft,
        address _anchor,
        address _niob
    ) {
        naft = _naft;
        anchor = _anchor;
        niob = _niob;
        signer = msg.sender;
        assetAddress[Asset.NAFT] = _naft;
        assetAddress[Asset.ANCHOR] = _anchor;
        assetAddress[Asset.NIOB] = _niob;
        stakingDetails[_naft][0] = Stake(30 days, 30);
        stakingDetails[_naft][1] = Stake(60 days, 60);
        stakingDetails[_naft][2] = Stake(90 days, 90);
        stakingDetails[_anchor][0] = Stake(30 days, 30);
        stakingDetails[_anchor][1] = Stake(60 days, 60);
        stakingDetails[_anchor][2] = Stake(90 days, 90);
        stakingDetails[_niob][0] = Stake(30 days, 30);
        stakingDetails[_niob][1] = Stake(60 days, 60);
        stakingDetails[_niob][2] = Stake(90 days, 90);
    }

    function setSignerAddress(address newSigner) external returns (bool) {
        require(
            signer == msg.sender,
            "caller is not a signer"
        );
        require(
            newSigner != address(0),
            "Invalid address"
        );
        emit SignerAddressUpdated(signer, newSigner);
        signer = newSigner;
        return true;
    }

    function setStakeDetails(
        Asset assetType,
        uint256 plan,
        Stake memory _stakeDetails
    ) external onlyOwner returns (bool) {
        require(
            plan < 3 && uint256(assetType) < 3,
            "Invalid data"
        );
        stakingDetails[assetAddress[assetType]][plan] = _stakeDetails;
        emit StakeLimitUpdated(stakingDetails[assetAddress[assetType]][plan]);
        return true;
    }

    function recoverBNB(uint256 amount) external onlyOwner {
        payable(owner()).transfer(amount);
    }

    function recoverToken(address tokenAddress, uint256 amount)
        external
        onlyOwner
    {
        IERC20Metadata(tokenAddress).transfer(owner(), amount);
    }

    function stake(
        uint256 amount,
        Asset assetType,
        uint256 plan,
        Sign memory sign
    ) external returns (bool) {
        require(plan < 3 && uint256(assetType) < 3, "Invalid data");
        require(amount >= minimumStakeAmount, "Invalid Amount");
        require(
            !(users[msg.sender][assetType][plan].status),
            "User already exist"
        );
        verifySign(uint256(assetType), plan, msg.sender, sign);
        uint256 duration = stakingDetails[assetAddress[assetType]][plan].stakeDuration;
        uint256 rewardPercent = stakingDetails[assetAddress[assetType]][plan].rewardPercent;
        users[msg.sender][assetType][plan] = UserDetail(
            assetType,
            plan,
            amount,
            block.timestamp,
            duration,
            rewardPercent,
            true
        );
        IERC20Metadata(assetAddress[assetType]).transferFrom(
            msg.sender,
            address(this),
            amount
        );
        emit Staking(msg.sender, plan, amount);
        return true;
    }

    function withdraw(
        Asset assetType,
        uint256 plan,
        Sign memory sign
    ) external returns (bool) {
        require(
            plan < 3 && uint256(assetType) < 3,
            "Invalid data"
        );
        require(
            users[msg.sender][assetType][plan].status,
            "User not exist"
        );
        uint256 endDuration = users[msg.sender][assetType][plan].duration +
            users[msg.sender][assetType][plan].initialTime;
        require(
            endDuration <= block.timestamp,
            "Time not exceeds"
        );
        verifySign(uint256(assetType), plan, msg.sender, sign);
        uint256 stakeAmount = users[msg.sender][assetType][plan].amount;
        uint256 timeDuration = users[msg.sender][assetType][plan].duration;
        uint256 rewardRate = users[msg.sender][assetType][plan].rewardPercent;
        uint256 rewardAmount = (stakeAmount * rewardRate * timeDuration) /
            365 days /
            100;
        uint256 amount = rewardAmount + stakeAmount;
        IERC20Metadata(assetAddress[assetType]).transfer(msg.sender, amount);
        delete users[msg.sender][assetType][plan];
        emit Withdraw(msg.sender, amount);
        return true;
    }

    function emergencyWithdraw(
        Asset assetType,
        uint256 plan,
        Sign memory sign
    ) external returns (uint256) {
        require(plan < 3, "Invalid plan");
        require(
            users[msg.sender][assetType][plan].status,
            "User not exist"
        );
        uint256 endDuration = users[msg.sender][assetType][plan].duration +
            users[msg.sender][assetType][plan].initialTime;
        require(
            endDuration >= block.timestamp,
            "Time exceeds"
        );
        verifySign(uint256(assetType), plan, msg.sender, sign);
        uint256 stakeAmount = users[msg.sender][assetType][plan].amount;
        IERC20Metadata(assetAddress[assetType]).transfer(
            msg.sender,
            stakeAmount
        );
        delete users[msg.sender][assetType][plan];
        emit Withdraw(msg.sender, stakeAmount);
        return stakeAmount;
    }

    function getUserDetails(
        address account,
        Asset assetType,
        uint256 plan
    ) external view returns (UserDetail memory) {
        return users[account][assetType][plan];
    }

    function verifySign(
        uint256 assetType,
        uint256 plan,
        address caller,
        Sign memory sign
    ) internal view {
        bytes32 hash = keccak256(
            abi.encodePacked(this, assetType, plan, caller, sign.nonce)
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
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
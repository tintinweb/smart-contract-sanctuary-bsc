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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

struct UserInfo {
    uint256 id;
    uint256 level;
    //index in level
    uint256 levelIndex;
    uint256 firstIdoTime;
    uint256 memberPoints;
    //=0 not initialized
    address parent;
}

interface IVNSCPD {
    function mint(address to, uint256 amount) external;
}

interface IVNSToken {
    function mint(address to, uint256 amount) external;

    function lockIdoAmount(address user, uint256 amount) external;

    function lockAirdropAmount(address user, uint256 amount) external;
}

interface IVNSNFT {
    function mintTo(address to, uint256 num) external returns (uint256);

    function blindBoxTo(address to) external returns (uint256);
}

interface IVNSMemberShip {
    function getUserInfo(address user) external view returns (UserInfo memory);

    function levelRealLength(uint256 level) external view returns (uint256);

    function addUser(address user, address parent) external;

    function addMemberPoints(address user, uint256 points) external;

    function updateLevel(address user) external;
}

interface INFTStakingPool {
    function getStakedAmount(address user) external returns (uint256);
}

interface IStakingPool {
    function stake(
        uint256 poolId,
        uint256 amount,
        address to
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./IVNS.sol";

interface IUniswapV2Router02 {
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    )
        external
        returns (
            uint amountA,
            uint amountB,
            uint liquidity
        );

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract NFTStakingPool is INFTStakingPool, Ownable, IERC721Receiver {
    
    struct NftStakedInfo {
        uint256[] ids; //staked ids
        uint256 stakedAmount;
        uint256 totalRewardVNS; // total rewarded token amount
        uint256 totalRewardCPD; // total rewarded token amount
        uint256 lastVNSClaimTime; // User's last claim time.
        uint256 lastCPDClaimTime; // User's last claim time.
        uint256 lastDepositTime; //last deposit time
    }

    //vns & cpd daily quota
    uint256 public constant DAY_QUOTA = 500*1e18;
    uint256 public constant MAX_VNS_QUOTA = 500000*1e18;

    IERC721 public immutable VNS_NFT;
    address public immutable VNS;
    address public immutable CPD;
    address public immutable USDT;
    address public immutable LP_VNS_USDT;
    address public immutable UNI_V2_ROUTER02; //IUniswapV2Router02
    uint256 public immutable LOCK_TIME; // Lock-up time

    uint256 public rewardVNSPerSecond; // rewardToken tokens  per second.
    uint256 public totalStaked; //total staked amount;
    uint256 public totalRewardVNS; //total reward amount;
    uint256 public totalRewardCPD; //total reward amount;

    address public lpStakingPool;

    //90 / 180 pool id
    uint256 public lpStakingPoolId;

    bool public isOpen = true;

    mapping(uint256 => address) public nftOwner;
    mapping(uint256 => uint256) public nftClaimedVns;
    mapping(address => NftStakedInfo) public userInfo;

    event Stake(address user, uint amount);
    event Withdraw(address user, uint amount);
    event RewardTokenTransfer(address token, address user, uint amount);
    error NotEnoughBalance(address token, uint balance);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    constructor(
        address _usdt,
        address _rewardVNS,
        address _rewardCPD,
        address _uniswapV2Router,
        address _lpVnsUsdt,
        address _stakedToken,
        uint256 _lockTime
    ) {
        USDT = _usdt;
        VNS = _rewardVNS;
        CPD = _rewardCPD;
        VNS_NFT = IERC721(_stakedToken);
        LOCK_TIME = _lockTime;
        UNI_V2_ROUTER02 = _uniswapV2Router;
        LP_VNS_USDT = _lpVnsUsdt;
    }

    function toggleSwitch() external onlyOwner {
        isOpen = !isOpen;
    }

     function getStakedAmount(address user)override external view returns(uint256) {
        return userInfo[user].stakedAmount;
    }

    function sweepToken(IERC20 token) external onlyOwner {
        uint256 sweepAmount = token.balanceOf(address(this));
        token.transfer(msg.sender, sweepAmount);
    }

    function stake(uint256 id) external {
        require(isOpen, "closed");
        require(VNS_NFT.ownerOf(id) == msg.sender, "only owner");

        claimVNS(msg.sender);
        claimCPD(msg.sender);

        NftStakedInfo storage user = userInfo[msg.sender];

        VNS_NFT.transferFrom(msg.sender, address(this), id);

        user.ids[user.stakedAmount] = id;
        user.stakedAmount += 1;
        user.lastDepositTime = block.timestamp;
        user.lastVNSClaimTime = block.timestamp;
        user.lastCPDClaimTime = block.timestamp;

        totalStaked += 1;
        emit Stake(msg.sender, id);
    }

    function withdraw() external {
        require(isOpen, "closed");

        NftStakedInfo storage user = userInfo[msg.sender];
        require(user.stakedAmount > 0, "staked 0");
        require(
            block.timestamp >= user.lastDepositTime + LOCK_TIME,
            "withdraw: too early to withdraw"
        );

        claimVNS(msg.sender);
        claimCPD(msg.sender);

        totalStaked -= user.stakedAmount;

        for (uint256 i; i < user.stakedAmount; i++) {
            uint256 id = user.ids[i];
            VNS_NFT.transferFrom(address(this), msg.sender, id);
            emit Withdraw(msg.sender, id);
            user.ids[i] = 0;
        }

        user.stakedAmount = 0;
        user.lastDepositTime = 0;
        user.lastVNSClaimTime = 0;
        user.lastCPDClaimTime = 0;
    }

    function claimVNS() external {
        claimVNS(msg.sender);
    }

    function claimCPD() external {
        claimCPD(msg.sender);
    }

    function claimVNS(address _user) public {
        require(isOpen, "closed");

        NftStakedInfo storage user = userInfo[_user];

        if (user.stakedAmount > 0) {
            uint256 pending = pendingVNSWithEdit(_user);
            uint256 halfPending = pending / 2;
            uint256 otherHalf = pending - halfPending;
            if (pending > 0) {
                rewardTokenSafeTransfer(VNS, _user, halfPending);
                user.totalRewardVNS += pending;
                user.lastVNSClaimTime = block.timestamp;

                totalRewardVNS += pending;

                //sell half,add liquidity
                swapAndLiquify(otherHalf);
            }
        }
    }

    function claimCPD(address _user) public {
        require(isOpen, "closed");

        NftStakedInfo storage user = userInfo[_user];

        if (user.stakedAmount > 0) {
            uint256 pending = pendingCPD(_user);
            if (pending > 0) {
                rewardTokenSafeTransfer(CPD, _user, pending);
                user.totalRewardCPD += pending;
                user.lastCPDClaimTime = block.timestamp;

                totalRewardCPD += pending;
            }
        }
    }

    function pendingVNSWithEdit(address _user) internal returns (uint256) {
        NftStakedInfo memory user = userInfo[_user];
        uint256 sum;
        if (user.stakedAmount > 0) {
            uint256 reward = ((block.timestamp - user.lastVNSClaimTime) *
                DAY_QUOTA ) / 1 days;

            for (uint256 i; i < user.stakedAmount; i++) {
                uint256 id = user.ids[i];
                uint256 claimedReward = nftClaimedVns[id];
                if (claimedReward + reward >= MAX_VNS_QUOTA) {
                    sum += MAX_VNS_QUOTA - claimedReward;
                    nftClaimedVns[id] = MAX_VNS_QUOTA;
                } else {
                    sum += reward;
                    nftClaimedVns[id] += reward;
                }
            }
        }
        return sum;
    }

    function pendingVNS(address _user) public view returns (uint256) {
        NftStakedInfo memory user = userInfo[_user];
        uint256 sum;
        if (user.stakedAmount > 0) {
            uint256 reward = ((block.timestamp - user.lastVNSClaimTime) *
                DAY_QUOTA) / 1 days;

            for (uint256 i; i < user.stakedAmount; i++) {
                uint256 id = user.ids[i];
                uint256 claimedReward = nftClaimedVns[id];
                if (claimedReward + reward >= MAX_VNS_QUOTA) {
                    sum += MAX_VNS_QUOTA - claimedReward;
                } else {
                    sum += reward;
                }
            }
        }
        return sum;
    }

    function pendingCPD(address _user) public view returns (uint256) {
        NftStakedInfo memory user = userInfo[_user];
        return
            (user.stakedAmount *
                (block.timestamp - user.lastCPDClaimTime) *
                DAY_QUOTA) / 1 days;
    }

    function rewardTokenSafeTransfer(
        address rewardToken,
        address to,
        uint amount
    ) internal {
        emit RewardTokenTransfer(address(rewardToken), to, amount);

        uint balance = IERC20(rewardToken).balanceOf(address(this));
        if (balance < amount) {
            revert NotEnoughBalance(address(rewardToken), balance);
        }
        IERC20(rewardToken).transfer(msg.sender, amount);
    }

    function swapAndLiquify(uint256 tokens) private {
        uint256 half = tokens / 2;
        uint256 otherHalf = tokens - half;

        uint256 initialBalance = IERC20(USDT).balanceOf(address(this));

        swapTokensForCake(half);

        uint256 newBalance = IERC20(USDT).balanceOf(address(this)) -
            initialBalance;

        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForCake(uint256 tokenAmount) private {
        address[] memory path = new address[](2);

        path[0] = VNS;
        path[1] = USDT;

        IERC20(VNS).approve(address(UNI_V2_ROUTER02), tokenAmount);

        // make the swap
        IUniswapV2Router02(UNI_V2_ROUTER02)
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(this),
                block.timestamp
            );
    }

    function addLiquidity(uint256 tokenAmount, uint256 usdtAmount) private {
        // approve token transfer to cover all possible scenarios
        IERC20(VNS).approve(UNI_V2_ROUTER02, tokenAmount);

        //origin lp balance
        uint256 lpbalance = IERC20(LP_VNS_USDT).balanceOf(address(this));

        // add the liquidity
        IUniswapV2Router02(UNI_V2_ROUTER02).addLiquidity(
            VNS,
            USDT,
            tokenAmount,
            usdtAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );

        //new lp balance
        uint256 retBalance = IERC20(LP_VNS_USDT).balanceOf(address(this)) -
            lpbalance;

        IERC20(LP_VNS_USDT).approve(lpStakingPool,retBalance);
        IStakingPool(lpStakingPool).stake(lpStakingPoolId,retBalance, msg.sender);
    }

    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
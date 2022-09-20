// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./lib/IMasterApe.sol";
import "./lib/IAnyswapV4Router.sol";
import "./utils/SweeperUpgradeable.sol";

contract BananaAllocator is SweeperUpgradeable {
    IMasterApe public masterApe;
    IERC20 public bananaToken;
    address public anyBanana;
    IAnyswapV4Router public anyswapRouter;
    uint256 public bananaRoutesLength;

    struct BananaRoute {
        address toAddress;
        ActionId actionId;
        uint256 chainId;
        uint256 minimumBanana;
    }

    enum ActionId {
        SIMPLE,
        BRIDGE
    }

    mapping(uint256 => BananaRoute) public getBananaRouteFromPid;
    uint256[] public bananaRoutePids;

    event MovedBanana(uint256 pid, uint256 amount, address to, uint256 chainId);
    event AddedBananaRoute(
        uint256 farmPid,
        address toAddress,
        ActionId actionId,
        uint256 chainId,
        uint256 minimumBanana
    );
    event RemovedBananaRoute(uint256 index, uint256 pid);
    event ChangedBananaMinimum(uint256 pid, uint256 newMinimum);

    function initialize(
        IMasterApe _masterApe,
        IERC20 _bananaToken,
        address _anyBanana,
        IAnyswapV4Router _anyswapRouter
    ) public initializer {
        initializeSweeper(new address[](0), true);
        masterApe = _masterApe;
        bananaToken = _bananaToken;
        anyBanana = _anyBanana;
        anyswapRouter = _anyswapRouter;
    }

    /// @notice Move banana based on index
    /// @param index index of banana route to move banana
    function moveBananaIndex(uint256 index) external {
        require(index < bananaRoutesLength, "BananaAllocator: Index out of bounds");
        _moveBanana(bananaRoutePids[index], true);
    }

    /// @notice Move banana for all banana routes
    /// @param revert_ revert if one fails
    function moveBananaAll(bool revert_) external {
        for (uint256 index = 0; index < bananaRoutesLength; index++) {
            _moveBanana(bananaRoutePids[index], revert_);
        }
    }

    /// @notice Move banana based on farm pid
    /// @param pid farm pid of banana route to move banana
    function moveBananaPid(uint256 pid) external {
        _moveBanana(pid, true);
    }

    /// @notice Move banana based on multiple farm pids
    /// @param pids farm pids of banana route to move banana
    /// @param revert_ revert if one fails
    function moveBananaPids(uint256[] memory pids, bool revert_) external {
        for (uint256 index = 0; index < pids.length; index++) {
            _moveBanana(pids[index], revert_);
        }
    }

    function _moveBanana(uint256 pid, bool revert_) private {
        BananaRoute memory bananaRoute = getBananaRouteFromPid[pid];

        if (bananaRoute.toAddress == address(0)) {
            if (revert_) {
                revert("BananaAllocator: No configured route found");
            } else {
                return;
            }
        }

        uint256 pendingRewards = masterApe.pendingCake(pid, address(this));
        if (pendingRewards < bananaRoute.minimumBanana) {
            if (revert_) {
                revert("BananaAllocator: not enough rewards");
            } else {
                return;
            }
        }

        uint256 balanceBefore = 0; //bananaToken.balanceOf(address(this));
        masterApe.deposit(pid, 0);
        uint256 newTokens = bananaToken.balanceOf(address(this)) - balanceBefore;

        if (bananaRoute.actionId == ActionId.SIMPLE) {
            //Simple transfer on same chain
            bananaToken.transfer(bananaRoute.toAddress, newTokens);
        } else if (bananaRoute.actionId == ActionId.BRIDGE) {
            //anyswap/multichain bridging to different address
            bananaToken.approve(address(anyswapRouter), newTokens);
            anyswapRouter.anySwapOutUnderlying(
                anyBanana,
                bananaRoute.toAddress,
                newTokens,
                bananaRoute.chainId
            );
        }
        emit MovedBanana(pid, newTokens, bananaRoute.toAddress, bananaRoute.chainId);
    }

    /// @notice Add a banana route
    /// @param farmPid farm pid
    /// @param toAddress address the banana should transfer to
    /// @param actionId action id
    /// @param chainId chain id for cross chain banana transfers
    /// @param minimumBanana minimum banana collected to activate banana transfer
    function addBananaRoute(
        uint256 farmPid,
        address toAddress,
        ActionId actionId,
        uint256 chainId,
        uint256 minimumBanana
    ) external onlyOwner {
        if (actionId == ActionId.BRIDGE)
            require(chainId != 0 && chainId != block.chainid, "BananaAllocator: wrong settings");

        bananaRoutesLength++;
        require(toAddress != address(0), "BananaAllocator: Can't send to null address");
        BananaRoute memory tempRoute = getBananaRouteFromPid[farmPid];
        require(tempRoute.toAddress == address(0), "BananaAllocator: Banana route with this pid already exists");

        getBananaRouteFromPid[farmPid] = BananaRoute(toAddress, actionId, chainId, minimumBanana);
        bananaRoutePids.push(farmPid);
        emit AddedBananaRoute(farmPid, toAddress, actionId, chainId, minimumBanana);
    }

    /// @notice remove a banana route by pid
    /// @param pid pid of banana route to remove
    function removeBananaRoutePid(uint256 pid) external onlyOwner {
        uint256 index = type(uint256).max;

        for (uint256 i = 0; i < bananaRoutePids.length; i++) {
            uint256 _pid = bananaRoutePids[i];
            if (_pid == pid) {
                index = i;
                continue;
            }
        }
        require(index != type(uint256).max, "BananaAllocator: pid not found");

        bananaRoutePids[index] = bananaRoutePids[bananaRoutesLength - 1];
        bananaRoutePids.pop();
        delete getBananaRouteFromPid[pid];
        bananaRoutesLength--;
        emit RemovedBananaRoute(index, pid);
    }

    /// @notice stake into masterApe farm
    /// @param pid pid of farm to stake in
    function stakeFarm(uint256 pid) external onlyOwner {
        (address farmToken, , , ) = masterApe.getPoolInfo(pid);
        uint256 balance = IERC20(farmToken).balanceOf(address(this));
        require(balance > 0, "BananaAllocator: no tokens to stake");
        IERC20(farmToken).approve(address(masterApe), balance);
        masterApe.deposit(pid, balance);
    }

    /// @notice unstake from masterApe farm
    /// @param pid pid of farm to unstake from
    function unstakeFarm(uint256 pid) external onlyOwner {
        (uint256 balance, ) = masterApe.userInfo(pid, address(this));
        masterApe.withdraw(pid, balance);
    }

    /// @notice emergency unstake from masterApe farm
    /// @param pid pid of farm to unstake from
    function emergencyUnstakeFarm(uint256 pid) external onlyOwner {
        masterApe.emergencyWithdraw(pid);
    }

    /// @notice Change the minimum banana that needs to be collected to active banana transfer
    /// @param pid pid of farm
    /// @param newMinimum new banana minimum
    function changeMinimumBanana(uint256 pid, uint256 newMinimum) external onlyOwner {
        BananaRoute storage bananaRoute = getBananaRouteFromPid[pid];
        bananaRoute.minimumBanana = newMinimum;
        emit ChangedBananaMinimum(pid, newMinimum);
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.15;

/*
 * ApeSwapFinance
 * App:             https://apeswap.finance
 * Medium:          https://ape-swap.medium.com
 * Twitter:         https://twitter.com/ape_swap
 * Telegram:        https://t.me/ape_swap
 * Announcements:   https://t.me/ape_swap_news
 * GitHub:          https://github.com/ApeSwapFinance
 */

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @dev Sweep any ERC20 and IERC721 token.
 * Sometimes people accidentally send tokens to a contract without any way to retrieve them.
 * This contract makes sure any erc20 tokens can be removed from the contract.
 */
contract SweeperUpgradeable is OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    struct NFT {
        IERC721 nftaddress;
        uint256[] ids;
    }
    mapping(address => bool) public lockedTokens;
    bool public allowNativeSweep;

    event SweepWithdrawToken(address indexed receiver, IERC20Upgradeable indexed token, uint256 balance);
    event SweepWithdrawNFTs(address indexed receiver, NFT[] indexed nfts);
    event SweepWithdrawNative(address indexed receiver, uint256 balance);
    event RefusedNativeSweep();

    function initializeSweeper(address[] memory _lockedTokens, bool _allowNativeSweep) internal onlyInitializing {
        __Ownable_init();
        lockTokens(_lockedTokens);
        allowNativeSweep = _allowNativeSweep;
    }

    /**
     * @dev Transfers erc20 tokens to specified address
     * Only owner of contract can call this function
     */
    function sweepTokens(IERC20Upgradeable[] memory tokens, address to) external onlyOwner {
        NFT[] memory empty = new NFT[](0);
        _sweepTokensAndNFTs(tokens, empty, to);
    }

    /**
     * @dev Transfers NFT to specified address
     * Only owner of contract can call this function
     */
    function sweepNFTs(NFT[] memory nfts, address to) external onlyOwner {
        IERC20Upgradeable[] memory empty = new IERC20Upgradeable[](0);
        _sweepTokensAndNFTs(empty, nfts, to);
    }

    function sweepTokensAndNFTs(
        IERC20Upgradeable[] memory tokens,
        NFT[] memory nfts,
        address to
    ) external onlyOwner {
        _sweepTokensAndNFTs(tokens, nfts, to);
    }

    /**
     * @dev Transfers ERC20 and NFT to specified address
     * Only owner of contract can call this function
     */
    function _sweepTokensAndNFTs(
        IERC20Upgradeable[] memory tokens,
        NFT[] memory nfts,
        address to
    ) internal {
        for (uint256 i = 0; i < tokens.length; i++) {
            IERC20Upgradeable token = tokens[i];
            require(!lockedTokens[address(token)], "Tokens can't be swept");
            uint256 balance = token.balanceOf(address(this));
            token.safeTransfer(to, balance);
            emit SweepWithdrawToken(to, token, balance);
        }

        for (uint256 i = 0; i < nfts.length; i++) {
            IERC721 nftaddress = nfts[i].nftaddress;
            require(!lockedTokens[address(nftaddress)], "Tokens can't be swept");
            uint256[] memory ids = nfts[i].ids;
            for (uint256 j = 0; j < ids.length; j++) {
                nftaddress.safeTransferFrom(address(this), to, ids[j]);
            }
        }
        emit SweepWithdrawNFTs(to, nfts);
    }

    /// @notice Sweep native coin
    /// @param _to address the native coins should be transferred to
    function sweepNative(address payable _to) external onlyOwner {
        require(allowNativeSweep, "Not allowed");
        uint256 balance = address(this).balance;
        _to.call{value: balance};
        emit SweepWithdrawNative(_to, balance);
    }

    /**
     * @dev Refuse native sweep.
     * Once refused can't be allowed again
     */
    function refuseNativeSweep() external onlyOwner {
        allowNativeSweep = false;
        emit RefusedNativeSweep();
    }

    /**
     * @dev Lock single token so it can't be transferred from the contract.
     * Once locked it can't be unlocked
     */
    function lockToken(address token) external onlyOwner {
        _lockToken(token);
    }

    /**
     * @dev Lock multiple tokens so they can't be transferred from the contract.
     * Once locked they can't be unlocked
     */
    function lockTokens(address[] memory tokens) public onlyOwner {
        _lockTokens(tokens);
    }

    /**
     * @dev Lock single token so it can't be transferred from the contract.
     * Once locked it can't be unlocked
     */
    function _lockToken(address token) internal {
        lockedTokens[token] = true;
    }

    /**
     * @dev Lock multiple tokens so they can't be transferred from the contract.
     * Once locked they can't be unlocked
     */
    function _lockTokens(address[] memory tokens) internal {
        for (uint256 i = 0; i < tokens.length; i++) {
            _lockToken(tokens[i]);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IMasterApe {
    function BONUS_MULTIPLIER() external view returns (uint256);

    function cake() external view returns (address);

    function cakePerBlock() external view returns (uint256);

    function devaddr() external view returns (address);

    function owner() external view returns (address);

    function poolInfo(uint256)
        external
        view
        returns (
            address lpToken,
            uint256 allocPoint,
            uint256 lastRewardBlock,
            uint256 accCakePerShare
        );

    function renounceOwnership() external;

    function startBlock() external view returns (uint256);

    function syrup() external view returns (address);

    function totalAllocPoint() external view returns (uint256);

    function transferOwnership(address newOwner) external;

    function userInfo(uint256, address)
        external
        view
        returns (uint256 amount, uint256 rewardDebt);

    function updateMultiplier(uint256 multiplierNumber) external;

    function poolLength() external view returns (uint256);

    function checkPoolDuplicate(address _lpToken) external view;

    function add(
        uint256 _allocPoint,
        address _lpToken,
        bool _withUpdate
    ) external;

    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) external;

    function getMultiplier(uint256 _from, uint256 _to)
        external
        view
        returns (uint256);

    function pendingCake(uint256 _pid, address _user)
        external
        view
        returns (uint256);

    function massUpdatePools() external;

    function updatePool(uint256 _pid) external;

    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function enterStaking(uint256 _amount) external;

    function leaveStaking(uint256 _amount) external;

    function emergencyWithdraw(uint256 _pid) external;

    function getPoolInfo(uint256 _pid)
        external
        view
        returns (
            address lpToken,
            uint256 allocPoint,
            uint256 lastRewardBlock,
            uint256 accCakePerShare
        );

    function dev(address _devaddr) external;
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

interface IAnyswapV4Router {
    function mpc() external view returns (address);

    function cID() external view returns (uint256 id);

    function changeMPC(address newMPC) external returns (bool);

    function changeVault(address token, address newVault) external returns (bool);

    function _anySwapOut(
        address from,
        address token,
        address to,
        uint256 amount,
        uint256 toChainID
    ) external;

    // Swaps `amount` `token` from this chain to `toChainID` chain with recipient `to`
    function anySwapOut(
        address token,
        address to,
        uint256 amount,
        uint256 toChainID
    ) external;

    // Swaps `amount` `token` from this chain to `toChainID` chain with recipient `to` by minting with `underlying`
    function anySwapOutUnderlying(
        address token,
        address to,
        uint256 amount,
        uint256 toChainID
    ) external;

    function anySwapOutUnderlyingWithPermit(
        address from,
        address token,
        address to,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint256 toChainID
    ) external;

    function anySwapOutUnderlyingWithTransferPermit(
        address from,
        address token,
        address to,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint256 toChainID
    ) external;

    function anySwapOut(
        address[] calldata tokens,
        address[] calldata to,
        uint256[] calldata amounts,
        uint256[] calldata toChainIDs
    ) external;

    // swaps `amount` `token` in `fromChainID` to `to` on this chainID
    function _anySwapIn(
        bytes32 txs,
        address token,
        address to,
        uint256 amount,
        uint256 fromChainID
    ) external;

    // swaps `amount` `token` in `fromChainID` to `to` on this chainID
    // triggered by `anySwapOut`
    function anySwapIn(
        bytes32 txs,
        address token,
        address to,
        uint256 amount,
        uint256 fromChainID
    ) external;

    // swaps `amount` `token` in `fromChainID` to `to` on this chainID with `to` receiving `underlying`
    function anySwapInUnderlying(
        bytes32 txs,
        address token,
        address to,
        uint256 amount,
        uint256 fromChainID
    ) external;

    // swaps `amount` `token` in `fromChainID` to `to` on this chainID with `to` receiving `underlying` if possible
    function anySwapInAuto(
        bytes32 txs,
        address token,
        address to,
        uint256 amount,
        uint256 fromChainID
    ) external;

    // extracts mpc fee from bridge fees
    function anySwapFeeTo(address token, uint256 amount) external;

    function anySwapIn(
        bytes32[] calldata txs,
        address[] calldata tokens,
        address[] calldata to,
        uint256[] calldata amounts,
        uint256[] calldata fromChainIDs
    ) external;

    // **** SWAP ****
    // requires the initial amount to have already been sent to the first pair
    function _swap(
        uint256[] memory amounts,
        address[] memory path,
        address _to
    ) external;

    // sets up a cross-chain trade from this chain to `toChainID` for `path` trades to `to`
    function anySwapOutExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        uint256 toChainID
    ) external;

    // sets up a cross-chain trade from this chain to `toChainID` for `path` trades to `to`
    function anySwapOutExactTokensForTokensUnderlying(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        uint256 toChainID
    ) external;

    // sets up a cross-chain trade from this chain to `toChainID` for `path` trades to `to`
    function anySwapOutExactTokensForTokensUnderlyingWithPermit(
        address from,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint256 toChainID
    ) external;

    // sets up a cross-chain trade from this chain to `toChainID` for `path` trades to `to`
    function anySwapOutExactTokensForTokensUnderlyingWithTransferPermit(
        address from,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint256 toChainID
    ) external;

    // Swaps `amounts[path.length-1]` `path[path.length-1]` to `to` on this chain
    // Triggered by `anySwapOutExactTokensForTokens`
    function anySwapInExactTokensForTokens(
        bytes32 txs,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        uint256 fromChainID
    ) external;

    // sets up a cross-chain trade from this chain to `toChainID` for `path` trades to `to`
    function anySwapOutExactTokensForNative(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        uint256 toChainID
    ) external;

    // sets up a cross-chain trade from this chain to `toChainID` for `path` trades to `to`
    function anySwapOutExactTokensForNativeUnderlying(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        uint256 toChainID
    ) external;

    // sets up a cross-chain trade from this chain to `toChainID` for `path` trades to `to`
    function anySwapOutExactTokensForNativeUnderlyingWithPermit(
        address from,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint256 toChainID
    ) external;

    // sets up a cross-chain trade from this chain to `toChainID` for `path` trades to `to`
    function anySwapOutExactTokensForNativeUnderlyingWithTransferPermit(
        address from,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint256 toChainID
    ) external;

    // Swaps `amounts[path.length-1]` `path[path.length-1]` to `to` on this chain
    // Triggered by `anySwapOutExactTokensForNative`
    function anySwapInExactTokensForNative(
        bytes32 txs,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        uint256 fromChainID
    ) external;

    // **** LIBRARY FUNCTIONS ****
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] memory path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] memory path) external view returns (uint256[] memory amounts);
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
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../extensions/draft-IERC20PermitUpgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20PermitUpgradeable token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20PermitUpgradeable {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
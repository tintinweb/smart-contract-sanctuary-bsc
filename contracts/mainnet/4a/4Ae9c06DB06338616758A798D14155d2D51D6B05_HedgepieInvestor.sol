// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./libraries/SafeBEP20.sol";
import "./libraries/Ownable.sol";
import "./libraries/HedgepieLibrary.sol";

import "./interfaces/IYBNFT.sol";
import "./interfaces/IAdapter.sol";
import "./interfaces/IVaultStrategy.sol";
import "./interfaces/IAdapterManager.sol";
import "./interfaces/IPancakePair.sol";
import "./interfaces/IPancakeRouter.sol";

contract HedgepieInvestor is Ownable, ReentrancyGuard {
    using SafeBEP20 for IBEP20;

    struct UserAdapterInfo {
        uint256 amount;
        uint256 userShares;
    }

    struct AdapterInfo {
        uint256 accTokenPerShare;
        uint256 totalStaked;
    }

    struct NFTInfo {
        uint256 tvl;
        uint256 totalParticipant;
    }

    // ybnft => nft id => NFTInfo
    mapping(address => mapping(uint256 => NFTInfo)) public nftInfo;

    // user => ybnft => nft id => amount(Invested WBNB)
    mapping(address => mapping(address => mapping(uint256 => uint256)))
        public userInfo;

    // user => nft id => adapter => UserAdapterInfo
    mapping(address => mapping(uint256 => mapping(address => UserAdapterInfo)))
        public userAdapterInfos;

    // nft id => adapter => AdapterInfo
    mapping(uint256 => mapping(address => AdapterInfo)) public adapterInfos;

    // ybnft address
    address public ybnft;

    // swap router address
    address public swapRouter;

    // wrapped bnb address
    address public wbnb;

    // strategy manager
    address public adapterManager;

    address public treasuryAddr;

    event DepositBNB(
        address indexed user,
        address nft,
        uint256 nftId,
        uint256 amount
    );
    event WithdrawBNB(
        address indexed user,
        address nft,
        uint256 nftId,
        uint256 amount
    );
    event Claimed(address indexed user, uint256 amount);
    event AdapterManagerChanged(address indexed user, address adapterManager);

    /**
     * @notice Construct
     * @param _ybnft  address of YBNFT
     * @param _swapRouter  address of pancakeswap router
     * @param _wbnb  address of Wrapped BNB address
     */
    constructor(
        address _ybnft,
        address _swapRouter,
        address _wbnb
    ) {
        require(_ybnft != address(0), "Error: YBNFT address missing");
        require(_swapRouter != address(0), "Error: swap router missing");
        require(_wbnb != address(0), "Error: WBNB missing");

        ybnft = _ybnft;
        swapRouter = _swapRouter;
        wbnb = _wbnb;
    }

    /**
     * @notice Set treasury address and percent
     * @param _treasury  treasury address
     */
    /// #if_succeeds {:msg "Treasury not updated"} treasuryAddr == _treasury;
    function setTreasury(address _treasury) external onlyOwner {
        require(_treasury != address(0), "Invalid address");
        treasuryAddr = _treasury;
    }

    /**
     * @notice Deposit with BNB
     * @param _user  user address
     * @param _tokenId  YBNft token id
     * @param _amount  BNB amount
     */
    /// #if_succeeds {:msg "userInfo not increased"} userInfo[_user][ybnft][_tokenId] > old(userInfo[_user][ybnft][_tokenId]);
    function depositBNB(
        address _user,
        uint256 _tokenId,
        uint256 _amount
    ) external payable nonReentrant {
        require(_amount != 0, "Error: Amount can not be 0");
        require(msg.value == _amount, "Error: Insufficient BNB");
        require(
            IYBNFT(ybnft).exists(_tokenId),
            "Error: nft tokenId is invalid"
        );

        IYBNFT.Adapter[] memory adapterInfo = IYBNFT(ybnft).getAdapterInfo(
            _tokenId
        );

        uint256 beforeBalance = address(this).balance;

        for (uint8 i = 0; i < adapterInfo.length; i++) {
            IYBNFT.Adapter memory adapter = adapterInfo[i];

            uint256 amountIn = (_amount * adapter.allocation) / 1e4;
            uint256 amountOut;
            address routerAddr = IAdapter(adapter.addr).router();
            if (routerAddr == address(0)) {
                if (adapter.token == wbnb) {
                    amountOut = amountIn;
                } else {
                    address wrapToken = IAdapter(adapter.addr).wrapToken();
                    if (wrapToken == address(0)) {
                        // swap
                        amountOut = HedgepieLibrary.swapOnRouterBNB(
                            adapter.addr,
                            amountIn,
                            adapter.token,
                            swapRouter,
                            wbnb
                        );
                    } else {
                        // swap
                        amountOut = HedgepieLibrary.swapOnRouterBNB(
                            adapter.addr,
                            amountIn,
                            wrapToken,
                            swapRouter,
                            wbnb
                        );

                        // wrap
                        uint256 beforeWrap = IBEP20(adapter.token).balanceOf(
                            address(this)
                        );
                        IBEP20(wrapToken).approve(adapter.token, amountOut);
                        IWrap(adapter.token).deposit(amountOut);
                        unchecked {
                            amountOut =
                                IBEP20(adapter.token).balanceOf(address(this)) -
                                beforeWrap;
                        }
                    }
                }
            } else {
                // get lp
                amountOut = HedgepieLibrary.getLPBNB(
                    adapter.addr,
                    amountIn,
                    adapter.token,
                    routerAddr,
                    wbnb
                );
            }

            // deposit to adapter
            UserAdapterInfo storage _userAdapterInfo = userAdapterInfos[
                msg.sender
            ][_tokenId][adapter.addr];

            AdapterInfo storage _adapterInfo = adapterInfos[_tokenId][
                adapter.addr
            ];

            HedgepieLibrary.depositToAdapter(
                adapterManager,
                adapter.token,
                adapter.addr,
                _tokenId,
                amountOut,
                msg.sender,
                _userAdapterInfo,
                _adapterInfo
            );

            userAdapterInfos[_user][_tokenId][adapter.addr].amount += amountOut;
            adapterInfos[_tokenId][adapter.addr].totalStaked += amountOut;
        }

        nftInfo[ybnft][_tokenId].tvl += _amount;
        if (userInfo[_user][ybnft][_tokenId] == 0) {
            nftInfo[ybnft][_tokenId].totalParticipant++;
        }
        userInfo[_user][ybnft][_tokenId] += _amount;

        uint256 afterBalance = address(this).balance;
        if (afterBalance > beforeBalance) {
            (bool success, ) = payable(_user).call{
                value: afterBalance - beforeBalance
            }("");
            require(success, "Error: Failed to send remained BNB");
        }

        emit DepositBNB(_user, ybnft, _tokenId, _amount);
    }

    /**
     * @notice Withdraw by BNB
     * @param _user  user address
     * @param _tokenId  YBNft token id
     */
    /// #if_succeeds {:msg "userInfo not decreased"} userInfo[_user][ybnft][_tokenId] < old(userInfo[_user][ybnft][_tokenId]);
    function withdrawBNB(address _user, uint256 _tokenId)
        external
        nonReentrant
    {
        require(
            IYBNFT(ybnft).exists(_tokenId),
            "Error: nft tokenId is invalid"
        );
        uint256 userAmount = userInfo[_user][ybnft][_tokenId];
        require(userAmount != 0, "Error: Amount should be greater than 0");

        IYBNFT.Adapter[] memory adapterInfo = IYBNFT(ybnft).getAdapterInfo(
            _tokenId
        );

        uint256 amountOut;
        uint256[2] memory balances;

        for (uint8 i = 0; i < adapterInfo.length; i++) {
            IYBNFT.Adapter memory adapter = adapterInfo[i];
            balances[0] = adapter.token == wbnb
                ? address(this).balance
                : IBEP20(adapter.token).balanceOf(address(this));

            UserAdapterInfo storage userAdapter = userAdapterInfos[msg.sender][
                _tokenId
            ][adapter.addr];

            _withdrawFromAdapter(
                adapter.addr,
                _tokenId,
                IAdapter(adapter.addr).getWithdrawalAmount(msg.sender, _tokenId)
            );

            balances[1] = adapter.token == wbnb
                ? address(this).balance
                : IBEP20(adapter.token).balanceOf(address(this));

            if (IAdapter(adapter.addr).router() == address(0)) {
                if (adapter.token == wbnb) {
                    unchecked {
                        amountOut += balances[1] - balances[0];
                    }
                } else {
                    address wrapToken = IAdapter(adapter.addr).wrapToken();
                    if (wrapToken == address(0)) {
                        // swap
                        amountOut += HedgepieLibrary.swapforBNB(
                            adapter.addr,
                            balances[1] - balances[0],
                            adapter.token,
                            swapRouter,
                            wbnb
                        );
                    } else {
                        // unwrap
                        uint256 beforeUnwrap = IBEP20(wrapToken).balanceOf(
                            address(this)
                        );
                        IWrap(adapter.token).withdraw(
                            balances[1] - balances[0]
                        );
                        unchecked {
                            beforeUnwrap =
                                IBEP20(wrapToken).balanceOf(address(this)) -
                                beforeUnwrap;
                        }

                        // swap
                        amountOut += HedgepieLibrary.swapforBNB(
                            adapter.addr,
                            beforeUnwrap,
                            wrapToken,
                            swapRouter,
                            wbnb
                        );
                    }
                }
            } else {
                uint256 taxAmount;
                // withdraw lp and get BNB
                if (IAdapter(adapter.addr).isVault()) {
                    // Get fee to BNB
                    uint256 _vAmount = (userAdapter.userShares *
                        IVaultStrategy(IAdapter(adapter.addr).vStrategy())
                            .wantLockedTotal()) /
                        IVaultStrategy(IAdapter(adapter.addr).vStrategy())
                            .sharesTotal();

                    if (
                        _vAmount >
                        IAdapter(adapter.addr).getWithdrawalAmount(
                            msg.sender,
                            _tokenId
                        )
                    ) {
                        taxAmount =
                            ((_vAmount -
                                IAdapter(adapter.addr).getWithdrawalAmount(
                                    _user,
                                    _tokenId
                                )) * IYBNFT(ybnft).performanceFee(_tokenId)) /
                            1e4;

                        if (taxAmount != 0) {
                            IBEP20(adapter.token).transfer(
                                treasuryAddr,
                                taxAmount
                            );
                        }
                    }

                    userAdapter.userShares = 0;
                }

                amountOut += HedgepieLibrary.withdrawLPBNB(
                    adapter.addr,
                    balances[1] - balances[0] - taxAmount,
                    adapter.token,
                    IAdapter(adapter.addr).router(),
                    wbnb
                );

                if (IAdapter(adapter.addr).rewardToken() != address(0)) {
                    // Convert rewards to BNB

                    uint256 rewards = HedgepieLibrary.getRewards(
                        adapterInfos[_tokenId][adapter.addr],
                        userAdapterInfos[msg.sender][_tokenId][adapter.addr],
                        adapter.addr
                    );
                    if (
                        rewards >
                        IBEP20(IAdapter(adapter.addr).rewardToken()).balanceOf(
                            address(this)
                        )
                    )
                        rewards = IBEP20(IAdapter(adapter.addr).rewardToken())
                            .balanceOf(address(this));

                    userAdapter.userShares = 0;

                    taxAmount =
                        (rewards * IYBNFT(ybnft).performanceFee(_tokenId)) /
                        1e4;

                    if (taxAmount != 0) {
                        IBEP20(IAdapter(adapter.addr).rewardToken()).transfer(
                            treasuryAddr,
                            taxAmount
                        );
                    }

                    if (rewards != 0) {
                        amountOut += HedgepieLibrary.swapforBNB(
                            adapter.addr,
                            rewards - taxAmount,
                            IAdapter(adapter.addr).rewardToken(),
                            swapRouter,
                            wbnb
                        );
                    }
                }
            }

            adapterInfos[_tokenId][adapter.addr]
                .totalStaked -= userAdapterInfos[_user][_tokenId][adapter.addr]
                .amount;
            userAdapterInfos[_user][_tokenId][adapter.addr].amount = 0;
        }

        if (nftInfo[ybnft][_tokenId].tvl < userAmount)
            nftInfo[ybnft][_tokenId].tvl = 0;
        else nftInfo[ybnft][_tokenId].tvl -= userAmount;

        if (nftInfo[ybnft][_tokenId].totalParticipant > 0)
            nftInfo[ybnft][_tokenId].totalParticipant--;

        userInfo[_user][ybnft][_tokenId] -= userAmount;

        if (amountOut != 0) {
            (bool success, ) = payable(_user).call{value: amountOut}("");
            require(success, "Error: Failed to send BNB");
        }
        emit WithdrawBNB(_user, ybnft, _tokenId, userAmount);
    }

    /**
     * @notice Claim
     * @param _tokenId  YBNft token id
     */
    function claim(uint256 _tokenId) external nonReentrant {
        require(
            IYBNFT(ybnft).exists(_tokenId),
            "Error: nft tokenId is invalid"
        );
        require(
            userInfo[msg.sender][ybnft][_tokenId] != 0,
            "Error: Amount should be greater than 0"
        );

        IYBNFT.Adapter[] memory adapterInfo = IYBNFT(ybnft).getAdapterInfo(
            _tokenId
        );

        uint256 amountOut;
        for (uint8 i = 0; i < adapterInfo.length; i++) {
            IYBNFT.Adapter memory adapter = adapterInfo[i];
            UserAdapterInfo storage userAdapter = userAdapterInfos[msg.sender][
                _tokenId
            ][adapter.addr];

            uint256 rewards = HedgepieLibrary.getRewards(
                adapterInfos[_tokenId][adapter.addr],
                userAdapterInfos[msg.sender][_tokenId][adapter.addr],
                adapter.addr
            );
            userAdapter.userShares = adapterInfos[_tokenId][adapter.addr]
                .accTokenPerShare;

            if (rewards != 0) {
                amountOut += HedgepieLibrary.swapforBNB(
                    adapter.addr,
                    rewards,
                    IAdapter(adapter.addr).rewardToken(),
                    swapRouter,
                    wbnb
                );
            }
        }

        if (amountOut != 0) {
            uint256 taxAmount = (amountOut *
                IYBNFT(ybnft).performanceFee(_tokenId)) / 1e4;
            (bool success, ) = payable(treasuryAddr).call{value: taxAmount}("");
            require(success, "Error: Failed to send BNB to Treasury");

            (success, ) = payable(msg.sender).call{
                value: amountOut - taxAmount
            }("");
            require(success, "Error: Failed to send BNB");
            emit Claimed(msg.sender, amountOut);
        }
    }

    /**
     * @notice Set strategy manager contract
     * @param _adapterManager  nft address
     */
    /// #if_succeeds {:msg "Adapter manager not set"} adapterManager == _adapterManager;
    function setAdapterManager(address _adapterManager) external onlyOwner {
        require(_adapterManager != address(0), "Error: Invalid NFT address");

        adapterManager = _adapterManager;

        emit AdapterManagerChanged(msg.sender, _adapterManager);
    }

    /**
     * @notice Withdraw fund from adapter
     * @param _adapterAddr  adapter address
     * @param _amount  token amount
     */
    function _withdrawFromAdapter(
        address _adapterAddr,
        uint256 _tokenId,
        uint256 _amount
    ) internal {
        address vStrategy = IAdapter(_adapterAddr).vStrategy();
        address stakingToken = IAdapter(_adapterAddr).stakingToken();
        address rewardToken = IAdapter(_adapterAddr).rewardToken();
        uint256[2] memory rewardTokenAmount;
        UserAdapterInfo memory userAdapter = userAdapterInfos[msg.sender][
            _tokenId
        ][_adapterAddr];

        rewardTokenAmount[0] = rewardToken != address(0)
            ? IBEP20(rewardToken).balanceOf(address(this))
            : 0;

        // Vault case - recalculate want token withdrawal amount for user
        uint256 _vAmount;
        if (IAdapter(_adapterAddr).isVault()) {
            _vAmount =
                (userAdapter.userShares *
                    IVaultStrategy(vStrategy).wantLockedTotal()) /
                IVaultStrategy(vStrategy).sharesTotal();
        }

        if (IAdapter(_adapterAddr).isLeverage()) {
            HedgepieLibrary.repayAsset(
                adapterManager,
                _adapterAddr,
                _tokenId,
                msg.sender
            );
        } else {
            (
                address to,
                uint256 value,
                bytes memory callData
            ) = IAdapterManager(adapterManager).getWithdrawCallData(
                    _adapterAddr,
                    _vAmount == 0 ? _amount : _vAmount
                );

            (bool success, ) = to.call{value: value}(callData);
            require(success, "Error: Withdraw internal issue");
        }

        rewardTokenAmount[1] = rewardToken != address(0)
            ? IBEP20(rewardToken).balanceOf(address(this))
            : 0;

        if (rewardToken == stakingToken) rewardTokenAmount[1] += _amount;
        if (
            (rewardToken != address(0) && rewardToken != stakingToken) ||
            vStrategy == address(0)
        ) {
            if (rewardTokenAmount[1] - rewardTokenAmount[0] != 0) {
                AdapterInfo storage adapter = adapterInfos[_tokenId][
                    _adapterAddr
                ];

                if (adapter.accTokenPerShare != 0)
                    adapter.accTokenPerShare +=
                        ((rewardTokenAmount[1] - rewardTokenAmount[0]) * 1e12) /
                        adapter.totalStaked;
            }
        }

        // update storage data on adapter
        IAdapter(_adapterAddr).setWithdrawalAmount(msg.sender, _tokenId, 0);
    }

    /**
     * @notice Get current rewards amount in BNB
     * @param _account user account address
     * @param _tokenId NFT token id
     */
    function pendingReward(address _account, uint256 _tokenId)
        public
        view
        returns (uint256)
    {
        IYBNFT.Adapter[] memory ybnftAapters = IYBNFT(ybnft).getAdapterInfo(
            _tokenId
        );

        uint256 rewards;

        for (uint8 i = 0; i < ybnftAapters.length; i++) {
            IYBNFT.Adapter memory adapter = ybnftAapters[i];
            UserAdapterInfo memory userAdapter = userAdapterInfos[msg.sender][
                _tokenId
            ][adapter.addr];
            AdapterInfo memory adapterInfo = adapterInfos[_tokenId][
                adapter.addr
            ];

            if (
                IAdapter(adapter.addr).rewardToken() != address(0) &&
                adapterInfo.totalStaked != 0 &&
                adapterInfo.accTokenPerShare != 0
            ) {
                UserAdapterInfo memory userAdapterInfo = userAdapterInfos[
                    _account
                ][_tokenId][adapter.addr];

                uint256 updatedAccTokenPerShare = adapterInfo.accTokenPerShare +
                    ((IAdapter(adapter.addr).pendingReward() * 1e12) /
                        adapterInfo.totalStaked);

                uint256 tokenRewards = ((updatedAccTokenPerShare -
                    userAdapterInfo.userShares) * userAdapterInfo.amount) /
                    1e12;

                rewards += IPancakeRouter(swapRouter).getAmountsOut(
                    tokenRewards,
                    HedgepieLibrary.getPaths(
                        adapter.addr,
                        IAdapter(adapter.addr).rewardToken(),
                        wbnb
                    )
                )[1];
            } else if (IAdapter(adapter.addr).isVault()) {
                uint256 _vAmount = (userAdapter.userShares *
                    IVaultStrategy(IAdapter(adapter.addr).vStrategy())
                        .wantLockedTotal()) /
                    IVaultStrategy(IAdapter(adapter.addr).vStrategy())
                        .sharesTotal();

                if (_vAmount < userAdapter.amount) continue;

                if (IAdapter(adapter.addr).router() == address(0)) {
                    rewards += IPancakeRouter(swapRouter).getAmountsOut(
                        _vAmount - userAdapter.amount,
                        HedgepieLibrary.getPaths(
                            adapter.addr,
                            IAdapter(adapter.addr).rewardToken(),
                            wbnb
                        )
                    )[1];
                } else {
                    address pairToken = IAdapter(adapter.addr).stakingToken();
                    address token0 = IPancakePair(pairToken).token0();
                    address token1 = IPancakePair(pairToken).token1();
                    (uint112 reserve0, uint112 reserve1, ) = IPancakePair(
                        pairToken
                    ).getReserves();

                    uint256 amount0 = (reserve0 *
                        (_vAmount - userAdapter.amount)) /
                        IPancakePair(pairToken).totalSupply();
                    uint256 amount1 = (reserve1 *
                        (_vAmount - userAdapter.amount)) /
                        IPancakePair(pairToken).totalSupply();

                    if (token0 == wbnb) rewards += reserve0;
                    else
                        rewards += IPancakeRouter(swapRouter).getAmountsOut(
                            amount0,
                            HedgepieLibrary.getPaths(adapter.addr, token0, wbnb)
                        )[1];

                    if (token0 == wbnb) rewards += reserve1;
                    else
                        rewards += IPancakeRouter(swapRouter).getAmountsOut(
                            amount1,
                            HedgepieLibrary.getPaths(adapter.addr, token1, wbnb)
                        )[1];
                }
            }
        }

        return rewards;
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.4;

import "./Address.sol";
import "./SafeMath.sol";
import "../interfaces/IBEP20.sol";

library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeBEP20: decreased allowance below zero"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeBEP20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeBEP20: BEP20 operation did not succeed"
            );
        }
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.4;

import "./Context.sol";

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
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
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

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../libraries/SafeBEP20.sol";
import "../libraries/Ownable.sol";

import "../interfaces/IYBNFT.sol";
import "../interfaces/IAdapter.sol";
import "../interfaces/IVaultStrategy.sol";
import "../interfaces/IAdapterManager.sol";
import "../interfaces/IPancakePair.sol";
import "../interfaces/IPancakeRouter.sol";

import "../HedgepieInvestor.sol";

library HedgepieLibrary {
    function getRewards(
        HedgepieInvestor.AdapterInfo memory _adapter,
        HedgepieInvestor.UserAdapterInfo memory _userAdapterInfo,
        address _adapterAddr
    ) public view returns (uint256) {
        if (
            IAdapter(_adapterAddr).rewardToken() == address(0) ||
            _adapter.totalStaked == 0 ||
            _adapter.accTokenPerShare == 0
        ) return 0;

        return
            ((_adapter.accTokenPerShare - _userAdapterInfo.userShares) *
                _userAdapterInfo.amount) / 1e12;
    }

    function getPaths(
        address _adapter,
        address _inToken,
        address _outToken
    ) public view returns (address[] memory path) {
        return IAdapter(_adapter).getPaths(_inToken, _outToken);
    }

    function swapOnPKS(
        address _adapter,
        uint256 _amountIn,
        address _inToken,
        address _outToken,
        address _swapRouter
    ) public returns (uint256 amountOut) {
        IBEP20(_inToken).approve(_swapRouter, _amountIn);
        address[] memory path = getPaths(_adapter, _inToken, _outToken);
        uint256[] memory amounts = IPancakeRouter(_swapRouter)
            .swapExactTokensForTokens(
                _amountIn,
                0,
                path,
                address(this),
                block.timestamp + 2 hours
            );

        amountOut = amounts[amounts.length - 1];
    }

    function swapOnRouterBNB(
        address _adapter,
        uint256 _amountIn,
        address _outToken,
        address _router,
        address wbnb
    ) public returns (uint256 amountOut) {
        address[] memory path = getPaths(_adapter, wbnb, _outToken);
        uint256 beforeBalance = IBEP20(_outToken).balanceOf(address(this));

        IPancakeRouter(_router)
            .swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: _amountIn
        }(0, path, address(this), block.timestamp + 2 hours);

        uint256 afterBalance = IBEP20(_outToken).balanceOf(address(this));
        amountOut = afterBalance - beforeBalance;
    }

    function swapforBNB(
        address _adapter,
        uint256 _amountIn,
        address _inToken,
        address _router,
        address wbnb
    ) public returns (uint256 amountOut) {
        address[] memory path = getPaths(_adapter, _inToken, wbnb);
        uint256 beforeBalance = address(this).balance;

        IBEP20(_inToken).approve(address(_router), _amountIn);

        IPancakeRouter(_router)
            .swapExactTokensForETHSupportingFeeOnTransferTokens(
                _amountIn,
                0,
                path,
                address(this),
                block.timestamp + 2 hours
            );

        uint256 afterBalance = address(this).balance;
        amountOut = afterBalance - beforeBalance;
    }

    function getLPBNB(
        address _adapter,
        uint256 _amountIn,
        address _pairToken,
        address _router,
        address wbnb
    ) public returns (uint256 amountOut) {
        address token0 = IPancakePair(_pairToken).token0();
        address token1 = IPancakePair(_pairToken).token1();

        uint256 token0Amount = _amountIn / 2;
        uint256 token1Amount = _amountIn / 2;
        if (token0 != wbnb) {
            token0Amount = swapOnRouterBNB(
                _adapter,
                token0Amount,
                token0,
                _router,
                wbnb
            );
            IBEP20(token0).approve(_router, token0Amount);
        }

        if (token1 != wbnb) {
            token1Amount = swapOnRouterBNB(
                _adapter,
                token1Amount,
                token1,
                _router,
                wbnb
            );
            IBEP20(token1).approve(_router, token1Amount);
        }

        if (token0Amount != 0 && token1Amount != 0) {
            if (token0 == wbnb || token1 == wbnb) {
                (, , amountOut) = IPancakeRouter(_router).addLiquidityETH{
                    value: token0 == wbnb ? token0Amount : token1Amount
                }(
                    token0 == wbnb ? token1 : token0,
                    token0 == wbnb ? token1Amount : token0Amount,
                    0,
                    0,
                    address(this),
                    block.timestamp + 2 hours
                );
            } else {
                (, , amountOut) = IPancakeRouter(_router).addLiquidity(
                    token0,
                    token1,
                    token0Amount,
                    token1Amount,
                    0,
                    0,
                    address(this),
                    block.timestamp + 2 hours
                );
            }
        }
    }

    function leverageAsset(
        address _adapterManager,
        address _adapterAddr,
        uint256 _tokenId,
        uint256 _amount,
        address _account,
        HedgepieInvestor.UserAdapterInfo storage userAdapterInfo,
        HedgepieInvestor.AdapterInfo storage adapterInfo
    ) public {
        if (!IAdapter(_adapterAddr).isEntered()) {
            (
                address to,
                uint256 value,
                bytes memory callData
            ) = IAdapterManager(_adapterManager).getEnterMarketCallData(
                    _adapterAddr
                );

            (bool success, ) = to.call{value: value}(callData);
            require(success, "Error: EnterMarket internal issue");

            IAdapter(_adapterAddr).setIsEntered(true);
            IBEP20(IAdapter(_adapterAddr).repayToken()).approve(
                IAdapter(_adapterAddr).strategy(),
                2**256 - 1
            );
        }

        IAdapter(_adapterAddr).increaseWithdrawalAmount(
            _account,
            _tokenId,
            _amount
        );

        uint256[2] memory amounts;
        uint256 value;
        address to;
        bool success;
        bytes memory callData;

        for (uint256 i = 0; i < IAdapter(_adapterAddr).DEEPTH(); i++) {
            amounts[0] = IBEP20(IAdapter(_adapterAddr).stakingToken())
                .balanceOf(address(this));

            (to, value, callData) = IAdapterManager(_adapterManager)
                .getLoanCallData(
                    _adapterAddr,
                    (_amount * IAdapter(_adapterAddr).borrowRate()) / 10000
                );

            (success, ) = to.call{value: value}(callData);
            require(success, "Error: Borrow internal issue");

            amounts[1] = IBEP20(IAdapter(_adapterAddr).stakingToken())
                .balanceOf(address(this));
            require(amounts[0] < amounts[1], "Error: Borrow failed");

            _amount = amounts[1] - amounts[0];

            IBEP20(IAdapter(_adapterAddr).stakingToken()).approve(
                IAdapterManager(_adapterManager).getAdapterStrat(_adapterAddr),
                _amount
            );

            (to, value, callData) = IAdapterManager(_adapterManager)
                .getDepositCallData(_adapterAddr, _amount);
            (success, ) = to.call{value: value}(callData);
            require(success, "Error: Re-deposit internal issue");

            IAdapter(_adapterAddr).increaseWithdrawalAmount(
                _account,
                _tokenId,
                _amount,
                i + 1
            );
            userAdapterInfo.amount += _amount;
            adapterInfo.totalStaked += _amount;
        }
    }

    function repayAsset(
        address _adapterManager,
        address _adapterAddr,
        uint256 _tokenId,
        address _account
    ) public {
        require(
            IAdapter(_adapterAddr).isEntered(),
            "Error: Not entered market"
        );

        uint256 _amount;
        uint256 bAmt;
        uint256 aAmt;
        address to;
        uint256 value;
        bytes memory callData;
        bool success;

        for (uint256 i = IAdapter(_adapterAddr).DEEPTH(); i > 0; i--) {
            _amount = IAdapter(_adapterAddr).stackWithdrawalAmounts(
                _account,
                _tokenId,
                i
            );

            bAmt = IBEP20(IAdapter(_adapterAddr).stakingToken()).balanceOf(
                address(this)
            );

            (to, value, callData) = IAdapterManager(_adapterManager)
                .getWithdrawCallData(_adapterAddr, _amount);
            (success, ) = to.call{value: value}(callData);
            require(success, "Error: Devest internal issue");

            aAmt = IBEP20(IAdapter(_adapterAddr).stakingToken()).balanceOf(
                address(this)
            );
            require(aAmt - bAmt == _amount, "Error: Devest failed");

            IBEP20(IAdapter(_adapterAddr).stakingToken()).approve(
                IAdapterManager(_adapterManager).getAdapterStrat(_adapterAddr),
                _amount
            );

            (to, value, callData) = IAdapterManager(_adapterManager)
                .getDeLoanCallData(_adapterAddr, _amount);
            (success, ) = to.call{value: value}(callData);
            require(success, "Error: DeLoan internal issue");
        }

        _amount = IAdapter(_adapterAddr).stackWithdrawalAmounts(
            _account,
            _tokenId,
            0
        );

        bAmt = IBEP20(IAdapter(_adapterAddr).stakingToken()).balanceOf(
            address(this)
        );
        (to, value, callData) = IAdapterManager(_adapterManager)
            .getWithdrawCallData(_adapterAddr, (_amount * 9999) / 10000);
        (success, ) = to.call{value: value}(callData);
        require(success, "Error: Devest internal issue");

        aAmt = IBEP20(IAdapter(_adapterAddr).stakingToken()).balanceOf(
            address(this)
        );

        require(bAmt < aAmt, "Error: Devest failed");
    }

    function withdrawLPBNB(
        address _adapter,
        uint256 _amountIn,
        address _pairToken,
        address _router,
        address wbnb
    ) public returns (uint256 amountOut) {
        address token0 = IPancakePair(_pairToken).token0();
        address token1 = IPancakePair(_pairToken).token1();

        IBEP20(_pairToken).approve(_router, _amountIn);

        if (token0 == wbnb || token1 == wbnb) {
            address tokenAddr = token0 == wbnb ? token1 : token0;
            (uint256 amountToken, uint256 amountETH) = IPancakeRouter(_router)
                .removeLiquidityETH(
                    tokenAddr,
                    _amountIn,
                    0,
                    0,
                    address(this),
                    block.timestamp + 2 hours
                );

            amountOut = amountETH;
            amountOut += swapforBNB(
                _adapter,
                amountToken,
                tokenAddr,
                _router,
                wbnb
            );
        } else {
            (uint256 amountA, uint256 amountB) = IPancakeRouter(_router)
                .removeLiquidity(
                    token0,
                    token1,
                    _amountIn,
                    0,
                    0,
                    address(this),
                    block.timestamp + 2 hours
                );

            amountOut += swapforBNB(_adapter, amountA, token0, _router, wbnb);
            amountOut += swapforBNB(_adapter, amountB, token1, _router, wbnb);
        }
    }

    function depositToAdapter(
        address _adapterManager,
        address _token,
        address _adapterAddr,
        uint256 _tokenId,
        uint256 _amount,
        address _account,
        HedgepieInvestor.UserAdapterInfo storage _userAdapterInfo,
        HedgepieInvestor.AdapterInfo storage _adapterInfo
    ) public {
        uint256[2] memory amounts;
        address[3] memory addrs;
        addrs[0] = IAdapter(_adapterAddr).stakingToken();
        addrs[1] = IAdapter(_adapterAddr).repayToken();
        addrs[2] = IAdapter(_adapterAddr).rewardToken();

        amounts[0] = addrs[1] != address(0)
            ? IBEP20(addrs[1]).balanceOf(address(this))
            : (
                IAdapter(_adapterAddr).isVault()
                    ? IAdapter(_adapterAddr).pendingShares()
                    : (
                        addrs[2] != address(0)
                            ? IBEP20(addrs[2]).balanceOf(address(this))
                            : 0
                    )
            );

        IBEP20(_token).approve(
            IAdapterManager(_adapterManager).getAdapterStrat(_adapterAddr),
            _amount
        );

        (address to, uint256 value, bytes memory callData) = IAdapterManager(
            _adapterManager
        ).getDepositCallData(_adapterAddr, _amount);

        (bool success, ) = to.call{value: value}(callData);
        require(success, "Error: Deposit internal issue");

        amounts[1] = addrs[1] != address(0)
            ? IBEP20(addrs[1]).balanceOf(address(this))
            : (
                IAdapter(_adapterAddr).isVault()
                    ? IAdapter(_adapterAddr).pendingShares()
                    : (
                        addrs[2] != address(0)
                            ? IBEP20(addrs[2]).balanceOf(address(this))
                            : 0
                    )
            );

        // Venus short leverage
        if (IAdapter(_adapterAddr).isLeverage()) {
            require(amounts[1] > amounts[0], "Error: Supply failed");

            leverageAsset(
                _adapterManager,
                _adapterAddr,
                _tokenId,
                _amount,
                _account,
                _userAdapterInfo,
                _adapterInfo
            );
        } else {
            if (addrs[1] != address(0)) {
                require(amounts[1] > amounts[0], "Error: Deposit failed");
                IAdapter(_adapterAddr).increaseWithdrawalAmount(
                    _account,
                    _tokenId,
                    amounts[1] - amounts[0]
                );
            } else if (IAdapter(_adapterAddr).isVault()) {
                require(amounts[1] > amounts[0], "Error: Deposit failed");

                _userAdapterInfo.userShares += amounts[1] - amounts[0];
                IAdapter(_adapterAddr).increaseWithdrawalAmount(
                    _account,
                    _tokenId,
                    amounts[1] - amounts[0]
                );
            } else if (addrs[2] != address(0)) {
                // Farm Pool
                uint256 rewardAmount = addrs[2] == addrs[0]
                    ? amounts[1] + _amount - amounts[0]
                    : amounts[1] - amounts[0];

                if (rewardAmount != 0 && _adapterInfo.totalStaked != 0) {
                    _adapterInfo.accTokenPerShare +=
                        (rewardAmount * 1e12) /
                        _adapterInfo.totalStaked;
                }

                if (_userAdapterInfo.amount == 0) {
                    _userAdapterInfo.userShares = _adapterInfo.accTokenPerShare;
                }

                IAdapter(_adapterAddr).increaseWithdrawalAmount(
                    _account,
                    _tokenId,
                    _amount
                );
            } else {
                IAdapter(_adapterAddr).increaseWithdrawalAmount(
                    _account,
                    _tokenId,
                    _amount
                );
            }
        }
    }
}

// SPDX-License-Identifier: None
pragma solidity ^0.8.4;

interface IYBNFT {
    struct Adapter {
        uint256 allocation;
        address token;
        address addr;
    }

    function getCurrentTokenId() external view returns (uint256);

    function performanceFee(uint256 tokenId) external view returns (uint256);

    function getAdapterInfo(uint256 tokenId)
        external
        view
        returns (Adapter[] memory);

    function exists(uint256) external returns (bool);

    function mint(
        uint256[] calldata adapterAllocations,
        address[] calldata adapterTokens,
        address[] calldata adapterAddrs,
        uint256 performanceFee,
        string memory tokenURI
    ) external;
}

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.4;

interface IWrap {
    function deposit(uint256 amount) external;

    function withdraw(uint256 share) external;
}

interface IAdapter {
    function getPaths(address _inToken, address _outToken)
        external
        view
        returns (address[] memory);

    function stackWithdrawalAmounts(
        address _user,
        uint256 _tokenId,
        uint256 _index
    ) external view returns (uint256);

    function DEEPTH() external view returns (uint8);

    function isVault() external view returns (bool);

    function isReward() external view returns (bool);

    function isEntered() external view returns (bool);

    function isLeverage() external view returns (bool);

    function borrowRate() external view returns (uint256);

    function stakingToken() external view returns (address);

    function poolID() external view returns (address);

    function strategy() external view returns (address strategy);

    function vStrategy() external view returns (address vStrategy);

    function pendingReward() external view returns (uint256 reward);

    function pendingReward1() external view returns (uint256 reward);

    function pendingShares() external view returns (uint256 shares);

    function name() external view returns (string memory);

    function repayToken() external view returns (address);

    function rewardToken() external view returns (address);

    function rewardToken1() external view returns (address);

    function wrapToken() external view returns (address);

    function router() external view returns (address);

    function getAdapterStrategy(uint256 _adapter)
        external
        view
        returns (address strategy);

    function getWithdrawalAmount(address _user, uint256 _nftId)
        external
        view
        returns (uint256 amount);

    function getInvestCallData(uint256 _amount)
        external
        view
        returns (
            address to,
            uint256 value,
            bytes memory data
        );

    function getDevestCallData(uint256 _amount)
        external
        view
        returns (
            address to,
            uint256 value,
            bytes memory data
        );

    function getRewardCallData()
        external
        view
        returns (
            address to,
            uint256 value,
            bytes memory data
        );

    function getEnterMarketCallData()
        external
        view
        returns (
            address to,
            uint256 value,
            bytes memory data
        );

    function getLoanCallData(uint256 _amount)
        external
        view
        returns (
            address to,
            uint256 value,
            bytes memory data
        );

    function getDeLoanCallData(uint256 _amount)
        external
        view
        returns (
            address to,
            uint256 value,
            bytes memory data
        );

    function getReward(address _user) external view returns (uint256);

    function increaseWithdrawalAmount(
        address _user,
        uint256 _nftId,
        uint256 _amount
    ) external;

    function increaseWithdrawalAmount(
        address _user,
        uint256 _nftId,
        uint256 _amount,
        uint256 _deepid
    ) external;

    function setWithdrawalAmount(
        address _user,
        uint256 _nftId,
        uint256 _amount
    ) external;

    function setIsEntered(bool _isEntered) external;

    function setInvestor(address _investor) external;
}

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.4;

interface IVaultStrategy {
    // Total want tokens managed by stratfegy
    function wantLockedTotal() external view returns (uint256);

    // Total want tokens managed by stratfegy
    function totalSupply() external view returns (uint256);

    // Sum of all shares of users to wantLockedTotal
    function sharesTotal() external view returns (uint256);

    // Main want token compounding function
    function earn() external;

    // Transfer want tokens autoFarm -> strategy
    function deposit(address _userAddress, uint256 _wantAmt)
        external
        returns (uint256);

    // Transfer want tokens strategy -> autoFarm
    function withdraw(address _userAddress, uint256 _wantAmt)
        external
        returns (uint256);

    function inCaseTokensGetStuck(
        address _token,
        uint256 _amount,
        address _to
    ) external;
}

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.4;

interface IAdapterManager {
    function getAdapterStrat(address _adapter)
        external
        view
        returns (address adapterStrat);

    function getDepositCallData(address _adapter, uint256 _amount)
        external
        view
        returns (
            address to,
            uint256 value,
            bytes memory data
        );

    function getWithdrawCallData(address _adapter, uint256 _amount)
        external
        view
        returns (
            address to,
            uint256 value,
            bytes memory data
        );

    function getLoanCallData(address _adapter, uint256 _amount)
        external
        view
        returns (
            address to,
            uint256 value,
            bytes memory data
        );

    function getDeLoanCallData(address _adapter, uint256 _amount)
        external
        view
        returns (
            address to,
            uint256 value,
            bytes memory data
        );

    function getEnterMarketCallData(address _adapter)
        external
        view
        returns (
            address to,
            uint256 value,
            bytes memory data
        );

    function getRewardCallData(address _adapter)
        external
        view
        returns (
            address to,
            uint256 value,
            bytes memory data
        );
}

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.4;

interface IPancakePair {
    function token0() external view returns (address);

    function token1() external view returns (address);

    function totalSupply() external view returns (uint256);

    function getReserves()
        external
        view
        returns (
            uint112,
            uint112,
            uint32
        );
}

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.4;

interface IPancakeRouter {
    function getAmountsIn(uint256 amountOut, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function getAmountsOut(uint256 amountIn, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.4;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the follorubig
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return _functionCallWithValue(target, data, 0, errorMessage);
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.4;

// TODO(zx): Replace all instances of SafeMath with OZ implementation
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        assert(a == b * c + (a % b)); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: mod by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }

    // Only used in the  BondingCalculator.sol
    function sqrrt(uint256 a) internal pure returns (uint256 c) {
        if (a > 3) {
            c = a;
            uint256 b = add(div(a, 2), 1);
            while (b < c) {
                c = b;
                b = div(add(div(a, b), b), 2);
            }
        } else if (a != 0) {
            c = 1;
        }
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.4;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

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

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.4;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() {}

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
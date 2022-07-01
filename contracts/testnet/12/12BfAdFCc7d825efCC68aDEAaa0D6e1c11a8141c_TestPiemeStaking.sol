// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import {PiemeStaking, IUniswapV2Router01} from "../PiemeStaking.sol";

contract TestPiemeStaking is PiemeStaking {
    address private constant PANCAKE_ROUTER =
        0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;

    /**
     * @dev See {__PiemeStaking_init}.
     */
    function initialize(
        address token_,
        address sttoken_,
        address treasure_,
        address signer_
    ) external override initializer {
        __PiemeStaking_init(
            token_,
            sttoken_,
            treasure_,
            signer_,
            PANCAKE_ROUTER
        );
    }

    /**
     * @dev Closes user positions
     */
    function closeFuturePositions(uint256 future) external {
        bytes32[] storage poss = positionsOf[_msgSender()];
        bool closed = false;
        for (uint256 i = 0; i < poss.length; ) {
            if (positions[poss[i]].closed == 0) {
                _closePosition(_msgSender(), poss[i], future);
                closed = true;
            }
            unchecked {i++;}
        }
        require(closed, "!nothing");
    }

    /**
     * @dev Closes user position
     * @param id Position id
     */
    function closeFuturePosition(bytes32 id, uint256 future) external {
        _closePosition(_msgSender(), id, future);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import {
    IPiemeVault,
    IPiemeRewardVault,
    PiemeVault,
    PiemeRewardVault
} from "./PiemeRewardVault.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import {
    OwnableUpgradeable
} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {
    IUniswapV2Factory
} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {
    IUniswapV2Pair
} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import {
    IUniswapV2Router01
} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol";
import {
    EIP712Upgradeable
} from "@openzeppelin/contracts-upgradeable/utils/cryptography/draft-EIP712Upgradeable.sol";
import {
    SignatureCheckerUpgradeable
} from "@openzeppelin/contracts-upgradeable/utils/cryptography/SignatureCheckerUpgradeable.sol";

interface IERC20Meta {
    function decimals() external view returns (uint8);
}

contract PiemeStaking is OwnableUpgradeable, EIP712Upgradeable {
    using Counters for Counters.Counter;

    IERC20 public token;
    IUniswapV2Pair public lppair;
    IUniswapV2Router01 public router;
    IERC20 public sttoken;
    address public treasure;

    string public constant NAME = "PIEME Staking";
    bytes32 public constant OPENREFERRAL_ENCODED_TYPE =
        0x9551f56e9560b130cd0177dabd295a0f56a7215d48d0827a4abdb8fe78363099;
    uint256 public constant ST_REF_MIN = 300;

    uint256 public constant MONTHS6 = 180 days;
    uint256 public constant MONTHS12 = 360 days;
    uint256 public constant MONTHS24 = 720 days;

    uint256 public constant HUNDRED = 100 * 1e16;
    uint256 public constant MONTHS0P = 96 * 1e16;
    uint256 public constant MONTHS6P = 12 * 1e16;
    uint256 public constant MONTHS12P = 6 * 1e16;
    uint256 public constant MONTHS24P = 4 * 1e16;

    uint256 public constant SWAPP = 30 * 1e16;
    uint256 public constant LIQP = 20 * 1e16;
    uint256 public constant BURNP = 35 * 1e16;
    uint256 public constant RWDP = 95 * 1e16;
    uint256 public constant RWDREF = 5 * 1e16;

    address private constant BURN_ADDRESS =
        0x000000000000000000000000000000000000dEaD;
    address private constant PANCAKE_ROUTER =
        0x10ED43C718714eb63d5aA57B78B54704E256024E;

    struct Position {
        uint256 amount;
        uint256 openCumulativeReward;
        address owner;
        uint48 opened;
        uint48 closed;
        uint256 returned;
        address referral;
        uint256 refreward;
    }

    mapping(bytes32 => Position) public positions;
    mapping(address => bytes32[]) public positionsOf;

    uint256 public staked;

    Counters.Counter private _posCounter;

    address public signer;
    IPiemeRewardVault public rewardVault;
    IPiemeVault public referralVault;
    bytes32[] public referrals;
    uint256 public refsum;

    event PositionOpened(bytes32, uint256, address, uint48);
    event PositionRefered(bytes32, address, address, uint256, uint256);
    event PositionClosed(
        bytes32,
        uint256,
        uint256,
        address,
        uint48,
        uint48,
        uint256
    );
    event FeeDistributed(uint256, uint256, uint256, uint256);
    event RewardClaimed(bytes32, address, uint256);
    event TreasureSet(address, address);
    event SetSigner(address, address);

    /**
     * @dev See {__PiemeStaking_init}.
     */
    function initialize(
        address token_,
        address sttoken_,
        address treasure_,
        address signer_
    ) external virtual initializer {
        __PiemeStaking_init(
            token_,
            sttoken_,
            treasure_,
            signer_,
            PANCAKE_ROUTER
        );
    }

    /**
     * @dev See {__PiemeStaking_init_unchained}.
     */
    function __PiemeStaking_init(
        address token_,
        address sttoken_,
        address treasure_,
        address signer_,
        address router_
    ) internal onlyInitializing {
        __Context_init_unchained();
        __Ownable_init_unchained();
        __EIP712_init_unchained(NAME, "1");
        __PiemeStaking_init_unchained(
            token_,
            sttoken_,
            treasure_,
            signer_,
            router_
        );
    }

    /**
     * @dev Set the native and liquidity pool token addresses.
     */
    function __PiemeStaking_init_unchained(
        address token_,
        address sttoken_,
        address treasure_,
        address signer_,
        address router_
    ) internal onlyInitializing {
        require(
            token_ != address(0) &&
                sttoken_ != address(0) &&
                treasure_ != address(0),
            "!address"
        );
        router = IUniswapV2Router01(router_);
        token = IERC20(token_);
        sttoken = IERC20(sttoken_);
        lppair = IUniswapV2Pair(
            IUniswapV2Factory(router.factory()).getPair(token_, sttoken_)
        );
        setTreasure(treasure_);
        setSigner(signer_);
        rewardVault = new PiemeRewardVault(token_, _msgSender());
        referralVault = new PiemeVault(token_, _msgSender());
    }

    /**
     * @dev Sets treasure address
     * @param treasure_ Treasure address
     */
    function setTreasure(address treasure_) public onlyOwner {
        require(treasure_ != address(0), "!address");
        treasure = treasure_;
        emit TreasureSet(_msgSender(), treasure_);
    }

    /**
     * @dev Updates signer address.
     *
     * @param signer_ A new signer address
     * Emits a {SetSigner} event.
     */
    function setSigner(address signer_) public onlyOwner {
        require(signer != signer_, "!address");
        signer = signer_;
        emit SetSigner(_msgSender(), signer_);
    }

    /**
     * @dev Generate user positio id
     * @param to User address
     * @param cnt Inteterger
     * @return hash
     */
    function generateId(address to, uint256 cnt) public view returns (bytes32) {
        return keccak256(abi.encode(address(this), to, cnt));
    }

    /**
     * @dev Gets current reward balance
     * @return Amount
     */
    function rewards() public view returns (uint256) {
        return token.balanceOf(address(rewardVault));
    }

    /**
     * @dev Gets staking summary of user opened positions
     * @param to User address
     * @return staked_
     */
    function stakedOf(address to) public view returns (uint256 staked_) {
        bytes32[] storage poss = positionsOf[to];
        for (uint256 i = 0; i < poss.length; ) {
            Position storage pos = positions[poss[i]];
            if (pos.closed == 0) {
                staked_ += pos.amount;
            }
            unchecked {i++;}
        }
    }

    /**
     * @dev Gets user open position ids
     * @param to User address
     * @return ids
     */
    function openPositionsOf(address to)
        external
        view
        returns (bytes32[] memory ids)
    {
        bytes32[] storage poss = positionsOf[to];
        uint256 count = _countPositions(poss, true);
        return _copyPositions(poss, true, count);
    }

    /**
     * @dev Gets user close position ids
     * @param to User address
     * @return ids
     */
    function closePositionsOf(address to)
        external
        view
        returns (bytes32[] memory ids)
    {
        bytes32[] storage poss = positionsOf[to];
        uint256 count = _countPositions(poss, false);
        return _copyPositions(poss, false, count);
    }

    function _countPositions(bytes32[] memory poss, bool opened)
        internal
        view
        returns (uint256 count)
    {
        for (uint256 i = 0; i < poss.length; ) {
            Position storage pos = positions[poss[i]];
            if (
                (opened && (pos.closed == 0)) || (!opened && !(pos.closed == 0))
            ) {
                unchecked {count++;}
            }
            unchecked {i++;}
        }
    }

    function _copyPositions(
        bytes32[] memory poss,
        bool opened,
        uint256 count
    ) internal view returns (bytes32[] memory ids) {
        ids = new bytes32[](count);
        count = 0;
        for (uint256 i = 0; i < poss.length; ) {
            Position storage pos = positions[poss[i]];
            if (
                (opened && (pos.closed == 0)) || (!opened && !(pos.closed == 0))
            ) {
                ids[count] = poss[i];
                unchecked {count++;}
            }
            unchecked {i++;}
        }
    }

    /**
     * @dev Estimates user rewards
     * @param to User address
     * @return amount
     */
    function estimateRewards(address to, uint256 when)
        external
        view
        returns (uint256 amount)
    {
        bytes32[] storage poss = positionsOf[to];
        for (uint256 i = 0; i < poss.length; ) {
            amount += estimateReward(poss[i], when);
            unchecked {i++;}
        }
    }

    /**
     * @dev Estimates position return
     * @param id Hash
     * @return amount
     */
    function estimateReward(bytes32 id, uint256 when)
        public
        view
        returns (uint256)
    {
        Position storage pos = positions[id];
        if (pos.opened == 0 || pos.closed != 0) return 0;
        return _estimateReward(pos.amount, pos.openCumulativeReward, when);
    }

    function _estimateReward(
        uint256 amount,
        uint256 openCumulativeReward,
        uint256 when
    ) internal view returns (uint256) {
        (, uint256 cumulativeReward) = rewardVault.estimate(staked, when);
        return
            ((cumulativeReward - openCumulativeReward) * amount * RWDP) /
            HUNDRED /
            1e18;
    }

    function _addCumulativeReward(uint256 rewardAmount) internal {
        require(
            token.transfer(address(rewardVault), rewardAmount),
            "!transfer"
        );
        rewardVault.update(staked > 0 ? staked : type(uint256).max);
    }

    function _subCumulativeReward(address to, uint256 rewardAmount) internal {
        rewardVault.withdraw(to, rewardAmount);
        rewardVault.update(staked > 0 ? staked : type(uint256).max);
    }

    /**
     * @dev Estimates user returns
     * @param to User address
     * @param when Timestamp
     * @return amount
     */
    function estimateReturns(address to, uint256 when)
        external
        view
        returns (uint256 amount)
    {
        bytes32[] storage poss = positionsOf[to];
        for (uint256 i = 0; i < poss.length; ) {
            amount += estimateReturn(poss[i], when);
            unchecked {i++;}
        }
    }

    /**
     * @dev Estimates position return
     * @param id Hash
     * @param when Timestamp
     * @return amount
     */
    function estimateReturn(bytes32 id, uint256 when)
        public
        view
        returns (uint256)
    {
        Position storage pos = positions[id];
        if (pos.opened == 0 || pos.opened > when || pos.closed != 0) return 0;
        return estimateAmountReturn(pos.amount, when - pos.opened);
    }

    /**
     * @dev Estimates amount return
     * @param amount Token amount
     * @param duration In seconds
     * @return returned Amount
     */
    function estimateAmountReturn(uint256 amount, uint256 duration)
        public
        pure
        returns (uint256 returned)
    {
        if (duration < MONTHS6) {
            returned = __estimateReturn(
                amount,
                duration,
                MONTHS6,
                MONTHS6P,
                MONTHS0P
            );
        } else if (duration < MONTHS12) {
            returned = __estimateReturn(
                amount,
                duration - MONTHS6,
                MONTHS6,
                MONTHS12P,
                MONTHS6P
            );
        } else if (duration < MONTHS24) {
            returned = __estimateReturn(
                amount,
                duration - MONTHS12,
                MONTHS12,
                MONTHS24P,
                MONTHS12P
            );
        } else {
            returned = (amount * (HUNDRED - MONTHS24P)) / 1e18;
        }
    }

    function __estimateReturn(
        uint256 amount,
        uint256 duration,
        uint256 period,
        uint256 percentMin,
        uint256 percentMax
    ) private pure returns (uint256) {
        uint256 percentFee =
            ((percentMax - percentMin) * (period - duration)) / period;
        return (amount * (HUNDRED - (percentMin + percentFee))) / 1e18;
    }

    /**
     * @dev Estimates user position closes
     * @param to User address
     * @param when Timestamp
     * @return amount
     */
    function estimateCloses(address to, uint256 when)
        external
        view
        returns (uint256 amount)
    {
        bytes32[] storage poss = positionsOf[to];
        for (uint256 i = 0; i < poss.length; ) {
            amount += estimateClose(poss[i], when);
            unchecked {i++;}
        }
    }

    /**
     * @dev Estimates position close
     * @param id Hash
     * @param when Timestamp
     * @return amount
     */
    function estimateClose(bytes32 id, uint256 when)
        public
        view
        returns (uint256)
    {
        Position storage pos = positions[id];
        if (pos.opened == 0 || pos.opened > when || pos.closed != 0) return 0;
        (uint256 _return, uint256 _reward) =
            _estimateClose(
                pos.amount,
                pos.openCumulativeReward,
                pos.opened,
                when
            );
        return _return + _reward;
    }

    function _estimateClose(
        uint256 amount,
        uint256 openCumulativeReward,
        uint256 opened,
        uint256 closed
    ) internal view returns (uint256 _return, uint256 _reward) {
        _return = estimateAmountReturn(amount, closed - opened);
        _reward = _estimateReward(amount, openCumulativeReward, closed);
    }

    /**
     * @dev Opens user position
     * @param amount to be staked
     * @return Position id
     */
    function openPosition(uint256 amount) public returns (bytes32) {
        require(amount >= 1000, "!amount");
        return _openPosition(_msgSender(), amount, block.timestamp);
    }

    /**
     * @dev Opens referral user position
     * @param amount to be staked
     * @param ref User address who gives ref
     * @param deadline Valid by
     * @param signature Signature(id)
     */
    function openReferralPosition(
        uint256 amount,
        address ref,
        uint256 deadline,
        bytes calldata signature
    ) external {
        require(deadline > block.timestamp, "!deadline");
        require(
            positionsOf[ref].length > 0 &&
                positionsOf[_msgSender()].length == 0,
            "!ref"
        );
        require(amount >= minimalReferralAmount(), "!amount");

        bytes32 hash =
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        OPENREFERRAL_ENCODED_TYPE,
                        ref,
                        _msgSender(),
                        deadline
                    )
                )
            );
        require(
            SignatureCheckerUpgradeable.isValidSignatureNow(
                signer,
                hash,
                signature
            ),
            "!signature"
        );

        bytes32 id = openPosition(amount);

        uint256 reward = (amount * RWDREF) / HUNDRED;
        referralVault.withdraw(ref, reward);

        Position storage pos = positions[id];
        pos.referral = ref;
        pos.refreward = reward;
        referrals.push(id);
        refsum += amount;
        emit PositionRefered(id, ref, _msgSender(), amount, reward);
    }

    /**
     * @dev Opens referral user position
     * @return Minimal referral amount
     */
    function minimalReferralAmount() public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(sttoken);
        path[1] = address(token);
        uint256 amount =
            ST_REF_MIN * (10**IERC20Meta(address(sttoken)).decimals());
        uint256[] memory stAmount = router.getAmountsOut(amount, path);
        return stAmount[1];
    }

    function _openPosition(
        address to,
        uint256 amount,
        uint256 when
    ) internal returns (bytes32 id) {
        uint256 cnt = _posCounter.current();
        _posCounter.increment();
        id = generateId(to, cnt);
        Position storage pos = positions[id];
        require(pos.opened == 0, "!id");
        staked += amount;
        rewardVault.update(staked);
        pos.amount = amount;
        pos.openCumulativeReward = rewardVault.cumulativeReward();
        pos.owner = to;
        pos.opened = uint48(when);
        positionsOf[to].push(id);
        require(token.transferFrom(to, address(this), amount), "!transfer");
        emit PositionOpened(id, amount, to, pos.opened);
    }

    /**
     * @dev Closes user positions
     */
    function closePositions() external {
        bytes32[] storage poss = positionsOf[_msgSender()];
        bool closed = false;
        for (uint256 i = 0; i < poss.length; ) {
            if (positions[poss[i]].closed == 0) {
                _closePosition(_msgSender(), poss[i], block.timestamp);
                closed = true;
            }
            unchecked {i++;}
        }
        require(closed, "!nothing");
    }

    /**
     * @dev Closes user position
     * @param id Position id
     */
    function closePosition(bytes32 id) external {
        _closePosition(_msgSender(), id, block.timestamp);
    }

    function _closePosition(
        address to,
        bytes32 id,
        uint256 when
    ) internal {
        Position storage pos = positions[id];
        require(pos.owner == to, "!owner");
        require(pos.closed == 0, "!closed");
        pos.closed = uint48(when);
        (uint256 _return, uint256 _reward) =
            _estimateClose(
                pos.amount,
                pos.openCumulativeReward,
                pos.opened,
                pos.closed
            );
        pos.returned += _return + _reward;
        staked -= pos.amount;
        _subCumulativeReward(to, _reward);
        require(token.transfer(to, _return), "!transfer");
        if (pos.amount > pos.returned + 1000) {
            _distributeFee(pos.amount - pos.returned, when);
        }
        require(rewards() > 0, "!balance");
        emit PositionClosed(
            id,
            pos.amount,
            pos.openCumulativeReward,
            to,
            pos.opened,
            pos.closed,
            pos.returned
        );
    }

    function _distributeFee(uint256 amount, uint256 when) internal {
        uint256 deadline = when + 1000;
        uint256 swapTreasureAmount = (amount * SWAPP) / HUNDRED; // 30% = 60% of 50%)
        uint256 liquidityAmount = (amount * LIQP) / HUNDRED; // 20% = 40% of 50%)
        require(
            token.approve(
                address(router),
                swapTreasureAmount + liquidityAmount
            ),
            "!approve"
        );
        address[] memory path = new address[](2);
        path[0] = address(token);
        path[1] = address(sttoken);
        uint256 swapAmount = swapTreasureAmount + liquidityAmount / 2;
        uint256[] memory amounts =
            router.swapExactTokensForTokens(
                swapAmount,
                1,
                path,
                address(this),
                deadline
            );
        require(amounts[0] == swapAmount && amounts[1] > 0, "!swap");
        uint256 transferTreasureAmount =
            (amounts[1] * swapTreasureAmount) / swapAmount;
        require(
            sttoken.transfer(treasure, transferTreasureAmount),
            "!transfer"
        );
        require(
            sttoken.approve(
                address(router),
                amounts[1] - transferTreasureAmount
            ),
            "!approve"
        );
        router.addLiquidity(
            path[0],
            path[1],
            liquidityAmount / 2,
            amounts[1] - transferTreasureAmount,
            1,
            1,
            treasure,
            deadline
        );
        uint256 burnAmount = (amount * BURNP) / HUNDRED; // 35% = 70% of 50%)
        require(token.transfer(BURN_ADDRESS, burnAmount), "!transfer");
        uint256 rewardAmount =
            amount - swapAmount - liquidityAmount - burnAmount;
        _addCumulativeReward(rewardAmount);
        emit FeeDistributed(
            swapAmount,
            liquidityAmount,
            burnAmount,
            rewardAmount
        );
    }

    /**
     * @dev Claim user rewards
     */
    function claimRewards() external {
        bytes32[] storage poss = positionsOf[_msgSender()];
        bool claimed = false;
        for (uint256 i = 0; i < poss.length; ) {
            if (positions[poss[i]].closed == 0) {
                uint256 reward = _claimReward(_msgSender(), poss[i]);
                if (reward > 0) claimed = true;
            }
            unchecked {i++;}
        }
        require(claimed, "!nothing");
    }

    /**
     * @dev Claim user position reward
     * @param id Position id
     */
    function claimReward(bytes32 id) external {
        require(_claimReward(_msgSender(), id) > 0, "!nothing");
    }

    function _claimReward(address to, bytes32 id)
        internal
        returns (uint256 reward)
    {
        Position storage pos = positions[id];
        require(pos.owner == to, "!owner");
        require(pos.closed == 0, "!closed");
        reward = _estimateReward(
            pos.amount,
            pos.openCumulativeReward,
            block.timestamp
        );
        if (reward > 0) {
            pos.openCumulativeReward = rewardVault.cumulativeReward();
            pos.returned += reward;
            rewardVault.withdraw(to, reward);
            emit RewardClaimed(id, to, reward);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import {IPiemeVault, PiemeVault} from "./PiemeVault.sol";

interface IPiemeRewardVault is IPiemeVault {
    function estimate(uint256 staked, uint256 when)
        external
        view
        returns (uint256 _dailyReward, uint256 _cumulativeReward);

    function update(uint256 staked) external;

    function cumulativeReward() external view returns (uint256);

    event Update(uint256, uint256, uint256, uint256);
}

contract PiemeRewardVault is PiemeVault, IPiemeRewardVault {
    uint256 public refreshed; // the latest timestamp of contract data update
    uint256 public override cumulativeReward; // total rewards from deploy per token
    uint256 public dailyReward; // the latest daily reward per token

    uint256 private _balance; // temp reward balance
    uint256 private _withdrawn; // temp withdraw balance

    uint256 public constant DAYS1 = 1 days;
    uint256 public constant MONTHS24 = 720 days;
    uint256 public constant DAILYRWD = 1095890 * 1e16;

    constructor(address token_, address owner_) PiemeVault(token_, owner_) {
        refreshed = block.timestamp;
    }

    /**
     * @dev Estimate reward by timestamp.
     *
     * @param staked Current stake amount
     * @param when Future timestamp
     * Emits a {Update} event.
     */
    function estimate(uint256 staked, uint256 when)
        public
        view
        returns (uint256 _dailyReward, uint256 _cumulativeReward)
    {
        uint256 slices = (when - refreshed) / DAYS1;
        _dailyReward =
            (1e18 *
                ((token.balanceOf(address(this)) + _withdrawn - _balance) /
                    (MONTHS24 / DAYS1 - slices) +
                    DAILYRWD)) /
            staked;
        _cumulativeReward = cumulativeReward + slices * _dailyReward;
    }

    /**
     * @dev Update data.
     *
     * @param staked Current stake amount
     * Emits a {Update} event.
     */
    function update(uint256 staked) external override onlyOwner {
        (cumulativeReward, dailyReward) = estimate(staked, block.timestamp);
        _balance = token.balanceOf(address(this));
        _withdrawn = 0;
        refreshed = block.timestamp;

        emit Update(staked, refreshed, cumulativeReward, dailyReward);
    }

    /**
     * @dev Withdraws funds.
     *
     * @param to Transfer funds to address
     * @param amount Transfer amount
     * Emits a {Withdrawn} event.
     */
    function withdraw(address to, uint256 amount)
        public
        override(IPiemeVault, PiemeVault)
    {
        _withdrawn += amount;
        super.withdraw(to, amount);
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
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/draft-EIP712.sol)

pragma solidity ^0.8.0;

import "./ECDSAUpgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 *
 * @custom:storage-size 52
 */
abstract contract EIP712Upgradeable is Initializable {
    /* solhint-disable var-name-mixedcase */
    bytes32 private _HASHED_NAME;
    bytes32 private _HASHED_VERSION;
    bytes32 private constant _TYPE_HASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    function __EIP712_init(string memory name, string memory version) internal onlyInitializing {
        __EIP712_init_unchained(name, version);
    }

    function __EIP712_init_unchained(string memory name, string memory version) internal onlyInitializing {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        return _buildDomainSeparator(_TYPE_HASH, _EIP712NameHash(), _EIP712VersionHash());
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSAUpgradeable.toTypedDataHash(_domainSeparatorV4(), structHash);
    }

    /**
     * @dev The hash of the name parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712NameHash() internal virtual view returns (bytes32) {
        return _HASHED_NAME;
    }

    /**
     * @dev The hash of the version parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712VersionHash() internal virtual view returns (bytes32) {
        return _HASHED_VERSION;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/cryptography/SignatureChecker.sol)

pragma solidity ^0.8.0;

import "./ECDSAUpgradeable.sol";
import "../AddressUpgradeable.sol";
import "../../interfaces/IERC1271Upgradeable.sol";

/**
 * @dev Signature verification helper that can be used instead of `ECDSA.recover` to seamlessly support both ECDSA
 * signatures from externally owned accounts (EOAs) as well as ERC1271 signatures from smart contract wallets like
 * Argent and Gnosis Safe.
 *
 * _Available since v4.1._
 */
library SignatureCheckerUpgradeable {
    /**
     * @dev Checks if a signature is valid for a given signer and data hash. If the signer is a smart contract, the
     * signature is validated against that smart contract using ERC1271, otherwise it's validated using `ECDSA.recover`.
     *
     * NOTE: Unlike ECDSA signatures, contract signatures are revocable, and the outcome of this function can thus
     * change through time. It could return true at block N and false at block N+1 (or the opposite).
     */
    function isValidSignatureNow(
        address signer,
        bytes32 hash,
        bytes memory signature
    ) internal view returns (bool) {
        (address recovered, ECDSAUpgradeable.RecoverError error) = ECDSAUpgradeable.tryRecover(hash, signature);
        if (error == ECDSAUpgradeable.RecoverError.NoError && recovered == signer) {
            return true;
        }

        (bool success, bytes memory result) = signer.staticcall(
            abi.encodeWithSelector(IERC1271Upgradeable.isValidSignature.selector, hash, signature)
        );
        return (success && result.length == 32 && abi.decode(result, (bytes4)) == IERC1271Upgradeable.isValidSignature.selector);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface IPiemeVault {
    function withdraw(address to, uint256 amount) external;

    event Withdrawn(address, uint256);
}

contract PiemeVault is Ownable, IPiemeVault {
    IERC20 public token;
    address public secondary_owner;

    constructor(address token_, address owner_) {
        token = IERC20(token_);
        secondary_owner = owner_;
    }

    /**
     * @dev Withdraws funds.
     *
     * @param to Transfer funds to address
     * @param amount Transfer amount
     * Emits a {Withdrawn} event.
     */
    function withdraw(address to, uint256 amount) public virtual override {
        require(
            _msgSender() == owner() || _msgSender() == secondary_owner,
            "!owner"
        );
        require(token.transfer(to, amount), "!transfer");
        emit Withdrawn(to, amount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

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
        bool isTopLevelCall = _setInitializedVersion(1);
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
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
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
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../StringsUpgradeable.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSAUpgradeable {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", StringsUpgradeable.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC1271.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC1271 standard signature validation method for
 * contracts as defined in https://eips.ethereum.org/EIPS/eip-1271[ERC-1271].
 *
 * _Available since v4.1._
 */
interface IERC1271Upgradeable {
    /**
     * @dev Should return whether the signature provided is valid for the provided data
     * @param hash      Hash of the data to be signed
     * @param signature Signature byte array associated with _data
     */
    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue);
}
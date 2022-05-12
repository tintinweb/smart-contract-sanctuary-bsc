// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

import "./ERC20/SafeERC20.sol";
import "./math/SafeMath.sol";
import "./interfaces/IStaking3.sol";
import "./utils/Pausable.sol";
import "./utils/ReentrancyGuard.sol";
import "./access/Ownable.sol";

interface IERC20Metadata is IERC20 {
    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

interface IWBNB {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;
}

library TransferHelper {
    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: ETH_TRANSFER_FAILED");
    }
}

interface AggregatorV3Interface {
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

contract TestStaking3 is IStaking, Ownable, ReentrancyGuard, Pausable {
    event Staked(
        address indexed user,
        address stakingToken,
        address rewardToken,
        uint256 amount
    );
    event Unstake(
        address indexed user,
        address stakingToken,
        address rewardToken,
        uint256 amount
    );
    event ClaimReward(
        address indexed user,
        address stakingToken,
        address rewardToken,
        uint256 reward
    );

    event RewardsVaultUpdated(address indexed newVault);
    event RewardAdded(
        address stakingToken,
        address rewardToken,
        uint256 amount,
        uint256 finishPeriod
    );

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct Campaign {
        uint256 totalStakes;
        uint256 rewardAmount;
        uint256 rate;
        uint256 lastRate;
        uint256 startBlock;
        uint256 stopBlock;
        uint256 finishBlock;
        uint256 startPeriod;
        uint256 finishPeriod;
        uint256 lastUpdateBlock;
        uint256 rewardPerTokenGlobal;
    }

    struct User {
        Pair[] pairs;
        mapping(address => mapping(address => uint256)) vaults;
        mapping(address => mapping(address => uint256)) indexOf;
        mapping(address => mapping(address => bool)) existed;
        mapping(address => mapping(address => uint256)) rewardPaid;
        mapping(address => mapping(address => uint256)) rewards;
    }

    struct Pair {
        address stakingToken;
        address rewardToken;
    }

    struct Asset {
        string symbol;
        address asset;
        AggregatorV3Interface priceFeed;
    }

    address public immutable WBNB;
    uint256 public constant PERCENT_DECIMALS = 6;
    uint256 public constant BLOCK_TIME = 3;
    uint256 public constant BLOCK_PER_YEAR = 10512000;
    address public rewardsVault;

    Pair[] public pairs;
    mapping(address => mapping(address => bool)) public accepted;
    mapping(address => mapping(address => uint256)) public indexOf;

    mapping(address => uint256) public totalStakes;
    mapping(address => AggregatorV3Interface) private tokenPrices;
    mapping(address => mapping(address => Campaign)) private campaigns;
    mapping(address => User) private users;

    mapping(string => Asset) private assets;

    constructor(address _rewardsVault, address _WBNB) {
        assets["BNB"] = Asset("BNB", 0x0000000000000000000000000000000000000000, AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526));
        rewardsVault = _rewardsVault;
        WBNB = _WBNB;
    }

    receive() external payable {
        assert(msg.sender == WBNB); // only accept WBNB via fallback from the WBNB contract
    }

    modifier validToken(address stakingToken, address rewardToken) {
        require(accepted[stakingToken][rewardToken], "Invalid staking tokens!");
        _;
    }

    modifier updateReward(
        address account,
        address stakingToken,
        address rewardToken
    ) {
        campaigns[stakingToken][rewardToken].rewardPerTokenGlobal = rewardPerToken(stakingToken, rewardToken);
        campaigns[stakingToken][rewardToken].lastUpdateBlock = lastUpdatedBlock(stakingToken, rewardToken);
        if (account != address(0)) {
            users[account].rewards[stakingToken][rewardToken] = earned(account, stakingToken, rewardToken);
            users[account].rewardPaid[stakingToken][rewardToken] = campaigns[stakingToken][rewardToken].rewardPerTokenGlobal;
        }
        _;
    }

    function setAssets(
        string[] memory symbols,
        address[] memory bep20s,
        AggregatorV3Interface[] memory priceFeeds
    ) public onlyOwner {
        require(symbols.length == bep20s.length && symbols.length == priceFeeds.length, "Pricefeed: length mismatch");
        for (uint256 i = 0; i < symbols.length; i++) {
            assets[symbols[i]] = Asset(symbols[i], bep20s[i], priceFeeds[i]);
        }
    }

    function getLatestPrice(address token) public view returns (int256) {
        string memory symbol = "BNB";
        if (token != address(0)) {
            symbol = IERC20Metadata(token).symbol();
        }
        if (compareStrings(symbol, "TokenW")) return 400000000000000000;
        if (assets[symbol].priceFeed != AggregatorV3Interface(address(0))) {
            (, int256 _price, , , ) = assets[symbol]
                .priceFeed
                .latestRoundData();
            return _price * 10**10;
        }
        return 0;
    }

    function compareStrings(string memory a, string memory b) internal view returns (bool) {
        return (keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b)));
    }

    function getRemainingReward(address stakingToken, address rewardToken) public view returns (uint256) {
        Campaign storage campaign = campaigns[stakingToken][rewardToken];
        if (campaign.finishBlock == 0) return 0; // not added rewards yet
        uint256 lastRewardBlock = campaign.stopBlock > 0 ? campaign.stopBlock : block.number;
        uint256 lastRate = campaign.lastRate > 0 ? campaign.lastRate : campaign.rate;
        uint256 remaining = campaign.finishBlock.sub(lastRewardBlock);
        uint256 leftover = remaining.mul(lastRate);
        return leftover;
    }

    function getApr(address stakingToken, address rewardToken) public view returns (uint256) {
        return _getApr(stakingToken, rewardToken, campaigns[stakingToken][rewardToken].rate);
    }

    function estimateApr(address stakingToken, address rewardToken, uint256 moreRewards, uint256 periodFinish) public view returns (uint256) {
        uint256 blockPeriod = periodFinish.sub(block.timestamp).div(BLOCK_TIME);
        uint256 rate = getRemainingReward(stakingToken, rewardToken).add(moreRewards).div(blockPeriod);

        return _getApr(stakingToken, rewardToken, rate);
    }

    function _getApr(address stakingToken, address rewardToken, uint256 rate) internal view returns(uint256) {
        if (campaigns[stakingToken][rewardToken].totalStakes == 0 || uint256(getLatestPrice(stakingToken)) == 0) return 0;
        
        return rate
                .mul(BLOCK_PER_YEAR)
                .mul(uint256(getLatestPrice(rewardToken)))
                .mul(100 * (10 ** PERCENT_DECIMALS))
                .div(campaigns[stakingToken][rewardToken].totalStakes.mul(uint256(getLatestPrice(stakingToken))));
    }

    function accept(address stakingToken, address rewardToken) public onlyOwner {
        if (!accepted[stakingToken][rewardToken]) {
            accepted[stakingToken][rewardToken] = true;
            indexOf[stakingToken][rewardToken] = pairs.length;
            pairs.push(Pair(stakingToken, rewardToken));
        }
    }

    function revoke(address stakingToken, address rewardToken)
        public
        validToken(stakingToken, rewardToken)
        updateReward(address(0), stakingToken, rewardToken)
        onlyOwner
    {
        uint256 index = indexOf[stakingToken][rewardToken];
        uint256 lastIndex = pairs.length - 1;
        pairs[index] = pairs[lastIndex];
        indexOf[pairs[lastIndex].stakingToken][pairs[lastIndex].rewardToken] = index;
        delete accepted[stakingToken][rewardToken];
        delete indexOf[stakingToken][rewardToken];
        pairs.pop();

        _stopReward(stakingToken, rewardToken);
        campaigns[stakingToken][rewardToken].finishBlock = block.number;
    }

    function getAcceptedPairsLength() public view returns (uint256) {
        return pairs.length;
    }

    function getAcceptedPairsh(uint256 index) public view returns (address, address) {
        return (pairs[index].stakingToken, pairs[index].rewardToken);
    }

    function getCampaign(address stakingToken, address rewardToken) public view returns (uint256, uint256, uint256) {
        return (
            campaigns[stakingToken][rewardToken].totalStakes,
            campaigns[stakingToken][rewardToken].finishPeriod,
            campaigns[stakingToken][rewardToken].rewardAmount
        );
    }

    function getCampaignInfo(address stakingToken, address rewardToken) public view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        return (
            campaigns[stakingToken][rewardToken].startBlock,
            campaigns[stakingToken][rewardToken].stopBlock,
            campaigns[stakingToken][rewardToken].finishBlock,
            campaigns[stakingToken][rewardToken].lastUpdateBlock,
            campaigns[stakingToken][rewardToken].rate,
            campaigns[stakingToken][rewardToken].lastRate
        );
    }

    function rewardPerToken(address stakingToken, address rewardToken) public view override returns (uint256) {
        if (campaigns[stakingToken][rewardToken].totalStakes == 0 || campaigns[stakingToken][rewardToken].startBlock == 0 || campaigns[stakingToken][rewardToken].finishBlock < block.number  ) return campaigns[stakingToken][rewardToken].rewardPerTokenGlobal;
        uint256 sBlock = campaigns[stakingToken][rewardToken].lastUpdateBlock;
        uint256 eBlock = lastUpdatedBlock(stakingToken, rewardToken);
        if (eBlock < sBlock) return campaigns[stakingToken][rewardToken].rewardPerTokenGlobal;

        return
            campaigns[stakingToken][rewardToken]
                .rewardPerTokenGlobal
                .add(eBlock.sub(sBlock).mul(campaigns[stakingToken][rewardToken].rate))
                .mul(1e18)
                .div(campaigns[stakingToken][rewardToken].totalStakes);
    }

    function lastUpdatedBlock(address stakingToken, address rewardToken) public view returns (uint256) {
        return block.number < campaigns[stakingToken][rewardToken].finishBlock ? block.number : campaigns[stakingToken][rewardToken].finishBlock;
    }
    function getStakingListsLength(address account) public view returns (uint256) {
        return users[account].pairs.length;
    }

    function getStaking(address account, uint256 index) public view returns (address, address) {
        return (
            users[account].pairs[index].stakingToken,
            users[account].pairs[index].rewardToken
        );
    }

    function getVault(address account, address stakingToken, address rewardToken) external view override returns (uint256) {
        return users[account].vaults[stakingToken][rewardToken];
    }

    function earned(address account, address stakingToken, address rewardToken) public view override returns (uint256) {
        uint8 decimal = IERC20Metadata(stakingToken).decimals();
        return
            users[account].vaults[stakingToken][rewardToken]
                .mul(rewardPerToken(stakingToken, rewardToken).sub(users[account].rewardPaid[stakingToken][rewardToken]))
                .div(10**decimal)
                .add(users[account].rewards[stakingToken][rewardToken]);
    }

    function deleteUserToken(address stakingToken, address rewardToken) internal {
        User storage user = users[msg.sender];

        if (user.vaults[stakingToken][rewardToken] == 0 && user.rewards[stakingToken][rewardToken] == 0 && user.existed[stakingToken][rewardToken]) {
            uint256 index = user.indexOf[stakingToken][rewardToken];
            uint256 lastIndex = user.pairs.length - 1;
            user.pairs[index] = user.pairs[lastIndex];
            user.indexOf[user.pairs[lastIndex].stakingToken][
                user.pairs[lastIndex].rewardToken
            ] = index;
            delete user.existed[stakingToken][rewardToken];
            delete user.indexOf[stakingToken][rewardToken];
            user.pairs.pop();
        }
    }

    function stake(address stakingToken, address rewardToken, uint256 amount)
        external
        override
        nonReentrant
        whenNotPaused
        validToken(stakingToken, rewardToken)
        updateReward(msg.sender, stakingToken, rewardToken)
    {
        require(amount > 0, "Cannot stake 0");
        User storage user = users[msg.sender];
        Campaign storage campaign = campaigns[stakingToken][rewardToken];

        // start but tempararily stop
        if (campaign.totalStakes == 0 && campaign.finishPeriod > 0) {
            uint256 blockPeriod = campaign.finishBlock != 0 ? campaign.finishBlock.sub(block.number) : 0;
            _calculateRate(stakingToken, rewardToken, 0, blockPeriod);
            _startReward(stakingToken, rewardToken);
        }

        totalStakes[stakingToken] = totalStakes[stakingToken].add(amount);
    
        campaign.totalStakes = campaign.totalStakes.add(amount);

        user.vaults[stakingToken][rewardToken] = user.vaults[stakingToken][rewardToken].add(amount);

        if (!user.existed[stakingToken][rewardToken]) {
            user.existed[stakingToken][rewardToken] = true;
            user.indexOf[stakingToken][rewardToken] = user.pairs.length;
            user.pairs.push(Pair(stakingToken, rewardToken));
        }

        IERC20(stakingToken).safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );
        emit Staked(msg.sender, stakingToken, rewardToken, amount);
    }

    function unstake(address stakingToken, address rewardToken, uint256 amount)
        public
        override
        nonReentrant
        updateReward(msg.sender, stakingToken, rewardToken) 
    {
        require(amount > 0, "Cannot withdraw 0");
        User storage user = users[msg.sender];
        Campaign storage campaign = campaigns[stakingToken][rewardToken];

        totalStakes[stakingToken] = totalStakes[stakingToken].sub(amount);
        campaign.totalStakes = campaign.totalStakes.sub(amount);
        if (campaign.totalStakes == 0) _stopReward(stakingToken, rewardToken);
        user.vaults[stakingToken][rewardToken] = user.vaults[stakingToken][rewardToken].sub(amount);
        IERC20(stakingToken).safeTransfer(msg.sender, amount);
        deleteUserToken(stakingToken, rewardToken);
        emit Unstake(msg.sender, stakingToken, rewardToken, amount);
    }

    function claimReward(address stakingToken, address rewardToken)
        public
        override
        nonReentrant
        updateReward(msg.sender, stakingToken, rewardToken)
    {
        uint256 reward = users[msg.sender].rewards[stakingToken][rewardToken];
        if (reward > 0) {
            users[msg.sender].rewards[stakingToken][rewardToken] = 0;
            if (rewardToken == address(0)) {
                IERC20(WBNB).safeTransferFrom(rewardsVault, address(this), reward);
                IWBNB(WBNB).withdraw(reward);
                TransferHelper.safeTransferETH(msg.sender, reward);
            } else {
                IERC20(rewardToken).safeTransferFrom(rewardsVault, msg.sender, reward);
            }
            deleteUserToken(stakingToken, rewardToken);
            emit ClaimReward(msg.sender, stakingToken, rewardToken, reward);
        }
    }

    function exit(address stakingToken, address rewardToken) external override {
        unstake(stakingToken, rewardToken, users[msg.sender].vaults[stakingToken][rewardToken]);
        claimReward(stakingToken, rewardToken);
    }

    function addRewards(
        address stakingToken,
        address rewardToken,
        uint256 rewardAmount,
        uint256 finishPeriod // solidity's timestamp is based on sec not msec.
    )
        external
        payable
        onlyOwner
        validToken(stakingToken, rewardToken)
        updateReward(address(0), stakingToken, rewardToken)
    {
        require(finishPeriod >= block.timestamp, "Stake: Invalid time!");

        Campaign storage campaign = campaigns[stakingToken][rewardToken];

        if (rewardToken == address(0)) {
            require(msg.value >= rewardAmount, "Insufficient-balance");
            IWBNB(WBNB).deposit{value: msg.value}();
            assert(IWBNB(WBNB).transfer(rewardsVault, rewardAmount));
        }
        uint256 startPeriod = (campaign.startPeriod > 0 && campaign.finishPeriod >= block.timestamp) ? campaign.startPeriod : block.timestamp;
        uint256 blockPeriod = finishPeriod.sub(startPeriod).div(BLOCK_TIME);

        campaign.finishPeriod = finishPeriod;

        _calculateRate(stakingToken, rewardToken, rewardAmount, blockPeriod);

        if (campaign.totalStakes > 0) {
            _startReward(stakingToken, rewardToken);
        } else {
            _stopReward(stakingToken, rewardToken);
        }
        
        emit RewardAdded(stakingToken, rewardToken, rewardAmount, finishPeriod);
    }
    
    function _calculateRate(address stakingToken, address rewardToken, uint256 rewardAmount, uint256 blockPeriod) internal {
        Campaign storage campaign = campaigns[stakingToken][rewardToken];
        
        if (block.number >= campaign.finishBlock) {
            campaign.rewardAmount = rewardAmount;
            campaign.startBlock = block.number;
            campaign.startPeriod = block.timestamp;
            campaign.finishBlock = campaign.startBlock.add(blockPeriod);
        } else {
            campaign.finishBlock = (campaign.startBlock > 0 ? campaign.startBlock : block.number).add(blockPeriod);
            campaign.rewardAmount = getRemainingReward(stakingToken, rewardToken).add(rewardAmount);
        }

        campaign.lastRate = campaign.rewardAmount.div(blockPeriod);
    }

    function _startReward(address stakingToken, address rewardToken) internal {
        Campaign storage campaign = campaigns[stakingToken][rewardToken];
        campaign.stopBlock = 0;
        campaign.rate = campaign.lastRate;
    }

    function _stopReward(address stakingToken, address rewardToken) internal {
        Campaign storage campaign = campaigns[stakingToken][rewardToken];
        campaign.stopBlock = block.number;
        campaign.rate = 0;
    }

    function setRewardsVault(address _rewardsVault) external onlyOwner {
        require(_rewardsVault != address(0), "Cannot be address 0");
        rewardsVault = _rewardsVault;
        emit RewardsVaultUpdated(rewardsVault);
    }

    function rescueToken(address _token) external onlyOwner {
        if (_token == address(0)) {
            msg.sender.transfer(address(this).balance);
        } else {
            IERC20(_token).safeTransfer(msg.sender, IERC20(_token).balanceOf(address(this)));
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "./IERC20.sol";
import "../math/SafeMath.sol";
import "../utils/Address.sol";

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

interface IStaking {
    function stake(address stakingToken, address rewardToken, uint256 amount) external;

    function unstake(address stakingToken, address rewardToken, uint256 amount) external;

    function claimReward(address stakingToken, address rewardToken) external;
    
    function exit(address stakingToken, address rewardToken) external;

    function getVault(address account, address stakingToken, address rewardToken) external view returns (uint256);

    function earned(address account, address stakingToken, address rewardToken) external view returns (uint256);

    function rewardPerToken(address stakingToken, address rewardToken) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "./Context.sol";

abstract contract Pausable is Context {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;


    constructor () {
        _paused = false;
    }


    function paused() public view returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "../utils/Context.sol";

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function mint(address to, uint256 amount) external;

    function burn(uint256 value) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

library Address {
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }


    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }


    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
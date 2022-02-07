// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

import "./ERC20/SafeERC20.sol";
import "./ERC721/IERC721.sol";
import "./math/SafeMath.sol";
import "./interfaces/IStakingNFT.sol";
import "./interfaces/IERC721Receiver.sol";
import "./utils/Pausable.sol";
import "./utils/ReentrancyGuard.sol";
import "./RewardsAdministratorNFT.sol";


contract TestStakingNFT is IStakingNFT, RewardsAdministratorNFT, ReentrancyGuard, Pausable, IERC721Receiver {
    event NftBatchStaked(address indexed user, uint256[] tokenIds);
    event NftRequestUnstake(address indexed user, uint256[] tokenIds, uint256 unstakedTime);
    event NftsUnstake(address indexed user, uint256 stakeId);
    event ClaimReward(address indexed user, uint256 reward);
    event OpenCampaign(uint256 periodStart, uint256 periodFinish, uint256 rate);

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public immutable rewardsToken;
    IERC721 public immutable stakingNft;

    uint256 public periodStart = 0;
    uint256 public periodFinish = 0;
    uint256 public rate = 1 ether;
    // uint256 public immutable rewardCycle = 1 days; // mainnet
    uint256 public immutable rewardCycle = 5 minutes; // for test
    
    uint256 public constant MAX_LENGTH = 100;
    uint256 public unstakePeriod = 1 minutes;
    uint256 public rewardPerNftGlobal = 0;
    uint256 public lastUpdateTime;
    

    struct Stake {
        uint256[] tokenIds; 
        uint256 multiplier;
        uint256 stakedTime;
        uint256 unstakedTime;
        uint256 rewardPaid;
    }

    mapping(address => uint256[]) public stakeTimes;
    mapping(address => mapping(uint256 => Stake)) public userStakes;

    constructor(
        address _rewardsAdministrator,
        address _rewardsVault,
        address _rewardsToken,
        address _stakingNft
    ) {
        rewardsAdministrator = _rewardsAdministrator;
        rewardsVault = _rewardsVault;
        rewardsToken = IERC20(_rewardsToken);
        stakingNft = IERC721(_stakingNft);
    }

    modifier updateReward() {
        rewardPerNftGlobal = rewardPerNft(periodStart, periodFinish);
        lastUpdateTime = lastUpdated();
        _;
    }

    function rewardPerNft(uint256 startTime, uint256 endTime) public view override returns (uint256) {
        if (periodStart != 0) {
            uint256 lastTime = lastUpdated();
            uint256 sTime = startTime < periodStart ? periodStart : startTime;
            uint256 eTime = endTime != 0 ? (endTime < lastTime ? endTime : lastTime) : lastTime;
            if (eTime < sTime) return rewardPerNftGlobal;
            return rewardPerNftGlobal.add((eTime.sub(sTime).div(rewardCycle)).mul(rate));
        } 
        return 0;
    }

    function lastUpdated() public view override returns (uint256) {
        return block.timestamp < periodFinish ? block.timestamp : periodFinish;
    }

    function earned(address account, uint256 stakeId) public view override returns (uint256) {
        return userStakes[account][stakeId].multiplier.mul(rewardPerNft(stakeId, userStakes[account][stakeId].unstakedTime)).sub(userStakes[account][stakeId].rewardPaid);
    }

    function batchStake(uint256[] memory tokenIds) external nonReentrant override {
        require(stakeTimes[msg.sender].length < MAX_LENGTH, "Stake: Overflow packages!");
        require(tokenIds.length < MAX_LENGTH, "Stake: Overflow NFT length!");
        for (uint256 i = 0; i < tokenIds.length; i++) {
            stakingNft.safeTransferFrom(msg.sender, address(this), tokenIds[i]);
            require(stakingNft.ownerOf(tokenIds[i]) == address(this), "Stake: Failed to take possession");
        }
        uint256 stakeId = block.timestamp;
        require(userStakes[msg.sender][stakeId].stakedTime == 0, "Stake: Multiple stakes");
        stakeTimes[msg.sender].push(stakeId);
        userStakes[msg.sender][stakeId] = Stake({tokenIds: tokenIds, multiplier: tokenIds.length, stakedTime: stakeId, unstakedTime: 0, rewardPaid: 0 });

        emit NftBatchStaked(msg.sender, tokenIds);
    }

    function requestUnstake(uint stakeIndex) public override {
        uint256 stakeId = stakeTimes[msg.sender][stakeIndex];
        require(userStakes[msg.sender][stakeId].unstakedTime == 0, "Stake: Already requested!");
        userStakes[msg.sender][stakeId].unstakedTime = block.timestamp;
        emit NftRequestUnstake(msg.sender, userStakes[msg.sender][stakeId].tokenIds, userStakes[msg.sender][stakeId].unstakedTime);
    }

    function unstake(uint256 stakeIndex) external nonReentrant override {
        uint256 stakeId = stakeTimes[msg.sender][stakeIndex];
        require(userStakes[msg.sender][stakeId].unstakedTime != 0 && block.timestamp >= userStakes[msg.sender][stakeId].unstakedTime.add(unstakePeriod), "Stake: Not enough time yet!");
        for (uint256 i = 0; i <userStakes[msg.sender][stakeId].tokenIds.length; i++) {
            stakingNft.safeTransferFrom(address(this), msg.sender, userStakes[msg.sender][stakeId].tokenIds[i]);
        }
        userStakes[msg.sender][stakeId].multiplier = 0;
        delete userStakes[msg.sender][stakeId].tokenIds;
        stakeTimes[msg.sender][stakeIndex] = stakeTimes[msg.sender][stakeTimes[msg.sender].length - 1];
        stakeTimes[msg.sender].pop();
        emit NftsUnstake(msg.sender, stakeId);
    }

    function getStake(address account, uint256 stakeId) public view override returns (uint256[] memory tokenIds, uint256 multiplier, uint256 stakedTime, uint256 unstakedTime, uint256 rewardPaid) {
        return (
            userStakes[account][stakeId].tokenIds,
            userStakes[account][stakeId].multiplier,
            userStakes[account][stakeId].stakedTime,
            userStakes[account][stakeId].unstakedTime,
            userStakes[account][stakeId].rewardPaid
        );
    }

    function getStakeTimes(address account) public view override returns (uint256[] memory tokenIds) {
        return (stakeTimes[account]);
    }

    function claimReward(uint256 stakeId) public nonReentrant override {
        uint256 reward = earned(msg.sender, userStakes[msg.sender][stakeId].stakedTime);
        if (reward > 0) {
            rewardsToken.safeTransferFrom(rewardsVault, msg.sender, reward);
            userStakes[msg.sender][stakeId].rewardPaid = userStakes[msg.sender][stakeId].rewardPaid.add(reward);
            emit ClaimReward(msg.sender, reward);
        }
    }

    function exit(uint256 stakeIndex) external override {
        requestUnstake(stakeIndex);
        claimReward(stakeTimes[msg.sender][stakeIndex]);
    }

    function openCampaign(uint256 _periodStart, uint256 _periodFinish, uint256 _rate) external onlyRewardsAdministrator updateReward() override {
        require(_periodStart >= block.timestamp && _periodStart < _periodFinish , "Stake: Invalid time!");

        if(_periodStart >= periodFinish || periodStart > block.timestamp) {
            periodStart = _periodStart;
            periodFinish = _periodFinish;
            rate = _rate;
        } else {
            periodFinish = _periodFinish;
        }
        lastUpdateTime = block.timestamp;
        emit OpenCampaign(_periodStart, _periodFinish, _rate);
    }

    function setUnstakePeriod(uint256 _unstakePeriod) external onlyOwner {
        unstakePeriod = _unstakePeriod;
    }

    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
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

import "../ERC165/IERC165.sol";

pragma solidity ^0.7.0;

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function transferFrom(address from, address to, uint256 tokenId) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
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

interface IStakingNFT {
    function rewardPerNft(uint256 startTime, uint256 endTime) external view returns (uint256);

    function lastUpdated() external view returns (uint256);

    function earned(address account, uint256 stakeId) external view returns (uint256);
    
    function batchStake(uint256[] memory tokenIds) external;

    function requestUnstake(uint stakeIndex) external;

    function unstake(uint256 stakeIndex) external;

    function getStake(address account, uint256 stakeId) external view returns (uint256[] memory, uint256, uint256, uint256, uint256);
    
    function getStakeTimes(address account) external view returns (uint256[] memory);

    function claimReward(uint256 stakeIndex) external;

    function openCampaign(uint256 periodStart, uint256 periodFinish, uint256 rate) external;

    function exit(uint256 stakeIndex) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

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
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
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

// Inheritance
import "./access/Ownable.sol";

abstract contract RewardsAdministratorNFT is Ownable {
    event RewardsVaultUpdated(address indexed vault);

    address public rewardsAdministrator;
    address public rewardsVault;

    modifier onlyRewardsAdministrator() {
        require(msg.sender == rewardsAdministrator, "Caller is not Rewards Administrator");
        _;
    }

    function setRewardsAdministrator(address _rewardsAdministrator) external virtual onlyOwner {
        rewardsAdministrator = _rewardsAdministrator;
    }

    function setRewardsValut(address _rewardsVault) external virtual onlyRewardsAdministrator {
        require(_rewardsVault != address(0), "Cannot be address 0");
        rewardsVault = _rewardsVault;
        emit RewardsVaultUpdated(rewardsVault);
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

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
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
// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

import "./ERC20/SafeERC20.sol";
import "./math/SafeMath.sol";
import "./interfaces/IStaking2.sol";
import "./utils/Pausable.sol";
import "./utils/ReentrancyGuard.sol";
import "./RewardsAdministrator2.sol";

interface IERC20Metadata is IERC20 {
  function decimals() external view returns (uint8);
}

contract TestStakingBSC is IStaking, RewardsAdministrator, ReentrancyGuard, Pausable {
    event Staked(address indexed user, address token, uint256 amount);
    event Unstake(address indexed user, address token, uint256 amount);
    event ClaimReward(address indexed user, address token, uint256 reward);
    event UpdatePercentage(address token, uint256 percentage, address rewardsVault);

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct Campaign {
        uint256 percentage;
        uint256 rate;
        address rewardsVault;
        uint256 lastUpdateBlock;
        uint256 rewardPerTokenGlobal;
    }

    struct User {
        address[] tokens;
        mapping(address => uint256) vaults;
        mapping(address => uint256) indexOf;
        mapping(address => bool) existed;
        mapping(address => uint256) rewardPaid;
        mapping(address => uint256) rewards;
    }

    uint256 public constant BLOCK_TIME = 3 seconds;
    uint256 public constant BLOCK_PER_MONTH = 864000; // 30 days
    uint256 public constant PERCENT_DECIMALS = 2;

    address[] public tokens;
    mapping(address => bool) public accepted;    
    mapping(address => uint256) public indexOf;

    mapping(address => uint256) public totalStakes;
    mapping(address => Campaign) campaigns;
    mapping(address => User) users;
    
    constructor(
        address _rewardsAdministrator
    ) {
        rewardsAdministrator = _rewardsAdministrator;
    }

    modifier validToken(address token) {
        require(accepted[token], "Invalid staking tokens!");
        _;
    }

    modifier updateReward(address account, address token) {
        campaigns[token].rewardPerTokenGlobal = rewardPerToken(token);
        campaigns[token].lastUpdateBlock = block.number;
        if (account != address(0)) {
            users[account].rewards[token] = earned(account, token);
            users[account].rewardPaid[token] = campaigns[token].rewardPerTokenGlobal;
        }
        _;
    }

    function accept(address token) public onlyOwner {
        if (!accepted[token]) {
            accepted[token] = true;
            indexOf[token] = tokens.length;
            tokens.push(token);
        }
    }

    function revoke(address token) public onlyOwner {
        if(accepted[token]) {
            uint256 index = indexOf[token];
            uint256 lastIndex = tokens.length - 1;
            tokens[index] = tokens[lastIndex];
            indexOf[tokens[lastIndex]] = index;
            delete accepted[token];
            delete indexOf[token];
            tokens.pop();
        }
    }

    function getAcceptedTokens() public view returns (address[] memory) {
        return tokens;
    }

    function getCampaign(address token) public view returns(uint256 percentage, uint256 rate, address rewardsVault){
        return (
            campaigns[token].percentage,
            campaigns[token].rate,
            campaigns[token].rewardsVault
        );
    }

    function rewardPerToken(address token) public view override returns (uint256) {
        if (totalStakes[token] == 0) return campaigns[token].rewardPerTokenGlobal;
        uint256 sBlock = campaigns[token].lastUpdateBlock;
        uint256 eBlock = block.number;
        return campaigns[token].rewardPerTokenGlobal.add(eBlock.sub(sBlock).mul(campaigns[token].rate));
    }

    function getStakingLists(address account) public view returns (address[] memory) {
        return users[account].tokens;
    }

    function getVault(address account, address token) external view override returns (uint256) {
        return users[account].vaults[token];
    }

    function earned(address account, address token) public view override returns (uint256) {
        uint8 decimal = IERC20Metadata(token).decimals();
        return users[account].vaults[token].mul(rewardPerToken(token).sub(users[account].rewardPaid[token])).div(10 ** decimal).add(users[account].rewards[token]);
    }

    function stake(address token, uint256 amount) external override nonReentrant whenNotPaused validToken(token) updateReward(msg.sender, token) {
        require(amount > 0, "Cannot stake 0");
        User storage user = users[msg.sender];

        totalStakes[token] = totalStakes[token].add(amount);
        user.vaults[token] = user.vaults[token].add(amount);
        if (!user.existed[token]) {
            user.existed[token] = true;
            user.indexOf[token] = user.tokens.length;
            user.tokens.push(token);
        }

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, token, amount);
    }

    function unstake(address token, uint256 amount) public override nonReentrant updateReward(msg.sender, token) {
        require(amount > 0, "Cannot withdraw 0");
        User storage user = users[msg.sender];

        totalStakes[token] = totalStakes[token].sub(amount);
        user.vaults[token] = user.vaults[token].sub(amount);
        if (user.vaults[token] == 0) {
            uint256 index = user.indexOf[token];
            uint256 lastIndex = user.tokens.length - 1;
            user.tokens[index] = user.tokens[lastIndex];
            user.indexOf[user.tokens[lastIndex]] = index;            
            delete user.existed[token];
            delete user.indexOf[token];
            user.tokens.pop();
        }

        IERC20(token).safeTransfer(msg.sender, amount);
        emit Unstake(msg.sender, token, amount);
    }

    function claimReward(address token) public override nonReentrant updateReward(msg.sender, token) {
        uint256 reward = users[msg.sender].rewards[token];
        if (reward > 0) {
            users[msg.sender].rewards[token] = 0;
            IERC20(token).safeTransferFrom(campaigns[token].rewardsVault, msg.sender, reward);
            emit ClaimReward(token, msg.sender, reward);
        }
    }

    function exit(address token) external override {
        unstake(token, users[msg.sender].vaults[token]);
        claimReward(token);
    }

    function updatePercentage(address token, uint256 percentage, address rewardsVault) external override onlyRewardsAdministrator validToken(token) updateReward(address(0), token) {
        Campaign storage campaign = campaigns[token];
        uint8 decimal = IERC20Metadata(token).decimals();

        campaign.percentage = percentage;
        campaign.rate = (10 ** decimal).mul(percentage).div(10 ** (2 + PERCENT_DECIMALS)).div(BLOCK_PER_MONTH);
        campaign.rewardsVault = rewardsVault;
        emit UpdatePercentage(token, percentage, rewardsVault);
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
    function stake(address token, uint256 amount) external;

    function unstake(address token, uint256 amount) external;

    function claimReward(address token) external;
    
    function exit(address token) external;

    function getVault(address account, address token) external view returns (uint256);

    function earned(address account, address token) external view returns (uint256);

    function rewardPerToken(address token) external view returns (uint256);
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

abstract contract RewardsAdministrator is Ownable {
    address public rewardsAdministrator;

    function updatePercentage(address _token, uint256 _percentage, address _rewardsVault) external virtual;
        
    modifier onlyRewardsAdministrator() {
        require(msg.sender == rewardsAdministrator, "Caller is not Rewards Administrator");
        _;
    }

    function setRewardsAdministrator(address _rewardsAdministrator) external virtual onlyOwner {
        rewardsAdministrator = _rewardsAdministrator;
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
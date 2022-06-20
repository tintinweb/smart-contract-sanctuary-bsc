// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./IToken.sol";
import "./HODLStaking.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract HODLStakingFactory is Context, Ownable {

    // using Counters for Counters.Counter;

    // IToken public token;
    
    mapping(uint256 => HODLStaking) public stakingList;
    uint256 private stakingId;

    constructor() {
        // token = IToken(_token);
        stakingId = 0;
    }


    function createStaking(uint _beginDeposit, uint _stopDeposit, uint256 _minDeposit, uint256 _maxDeposit, uint256 _initialAPY, address _token, uint _stakingPeriod) external {
        HODLStaking _new = new HODLStaking(address(_token), msg.sender);
        _new.setBeginDeposit(_beginDeposit);
        _new.setStopDeposit(_stopDeposit);
        _new.setMinDeposit(_minDeposit);
        _new.setMaxDeposit(_maxDeposit);
        _new.setIntialAPY(_initialAPY);
        _new.setStakingPeriod(_stakingPeriod);
        _new.transferOwnership(owner());

        IToken(_token).approve(address(_new), 10000*10**18);
        stakingList[stakingId] = _new;
        stakingId = stakingId + 1;
    }

    function getStakingAddressbyId(uint256 _stakingId) external view returns(address) {
        return address(stakingList[_stakingId]);
    }

    function sweep(address _token, uint256 _amount) external onlyOwner {
        uint256 _value = IToken(_token).balanceOf(address(this));
        require(_value >= _amount, "This wallet has less amount tokens than you ask");
        IToken(_token).transfer(owner(), _amount);
    }

}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IToken {
    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function burnFrom(address account, uint256 amount) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./IToken.sol";

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract HODLStaking is Context, Ownable {

    struct StakeInfo {
        uint256 stakeAmount;
        uint stakeTime;
    }

    IToken public token;

    bool canDeposit;
    uint256 public minDeposit;
    uint256 public maxDeposit;
    uint256 public feeAmount;
    uint256 public stakeAmount;
    uint256 public rewardAmount;
    uint256 private lastStakeTime;
    uint public beginDeposit;
    uint public stopDeposit;
    uint public stakingPeriod;
    uint256 public APY;
    mapping(address => StakeInfo) public stakers;
    address public projectWallet;

    function setStakingPeriod(uint _stakingPeriod) external onlyOwner {
        stakingPeriod = _stakingPeriod;
    }

    function setBeginDeposit(uint _beginDeposit) external onlyOwner {
        beginDeposit = _beginDeposit;
    }

    function setStopDeposit(uint _stopDeposit) external onlyOwner {
        stopDeposit = _stopDeposit;
    }

    function setIntialAPY(uint256 _initialAPY) external onlyOwner {
        APY = _initialAPY;
    }

    function setMinDeposit(uint256 _minDeposit) external onlyOwner {
        minDeposit = _minDeposit;
    }

    function setMaxDeposit(uint256 _maxDeposit) external onlyOwner {
        maxDeposit = _maxDeposit;
    }

    function setDepositable(bool _depositable) external onlyOwner {
        canDeposit = _depositable;
    }

    function APYCalculator() public view returns(uint256){
        uint256 _apyValue = rewardAmount * 100 / stakeAmount;
        return _apyValue;
    }

    function projectSend() external {
        uint _curTime = block.timestamp;
        require(_curTime >= stopDeposit, 'Still staking time');
        require(msg.sender == projectWallet, 'This is not project wallet');
        require(stakeAmount >= minDeposit, 'The stake amount is not more than min amount');
        require(stakeAmount <= maxDeposit, 'The stake amount is not less than max amount');
        feeAmount = rewardAmount / 20;
        token.transferFrom(projectWallet, address(this), rewardAmount);                                        
    }

    function deposit(uint256 amount) external {
        uint curTime = block.timestamp;
        require(curTime >= beginDeposit, 'Deposit time is not started');
        require(curTime <= stopDeposit, 'Deposit time is over');
        require(stakeAmount + amount <= maxDeposit, 'You are sending too much considering maxDeposit');
        StakeInfo storage newStake = stakers[msg.sender];
        newStake.stakeAmount = amount;
        newStake.stakeTime = block.timestamp;
        stakeAmount += amount;
        rewardAmount += amount * APY / 100;
        token.transferFrom(msg.sender, address(this), amount);
    }

    function withdraw() external {
        uint _curTime = block.timestamp;
        require(stopDeposit <= _curTime, 'Still deposit time');
        if(msg.sender == owner()) {
            token.transfer(msg.sender, feeAmount);
            uint256 _apy = APYCalculator();
            uint256 _rewardFeeAmount = feeAmount * (_curTime - stopDeposit) * _apy / stakingPeriod;
            token.transferFrom(projectWallet, msg.sender, feeAmount + _rewardFeeAmount);
        }
        else {
            StakeInfo storage _stake = stakers[msg.sender];
            require(_stake.stakeAmount > 0, 'There is not stake Amount');
            uint256 _apy = APYCalculator();
            uint256 _rewardAmount = _stake.stakeAmount * (_curTime - _stake.stakeTime) * _apy / stakingPeriod;
            uint256 _getAmount = _stake.stakeAmount + _rewardAmount;
            stakeAmount -= _stake.stakeAmount;
            rewardAmount -= _rewardAmount;
            token.transfer(msg.sender, _getAmount);
            _stake.stakeAmount = 0;
        }
    }

    function sweep() external onlyOwner{
        uint256 _allAmount = token.balanceOf(address(this));
        token.transfer(owner(), _allAmount);
    }


    constructor(address _token, address _stakeWallet) {
        token = IToken(_token);
        stakeAmount = 0;
        rewardAmount = 0;
        feeAmount = 0;
        projectWallet = _stakeWallet;
    }

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
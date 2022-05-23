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
        uint256 stakeTime;
    }

    IToken public token;

    bool canDeposit;
    uint256 public minDeposit;
    uint256 public maxDeposit;
    uint256 public feeAmount;
    uint256 public stakeAmount;
    uint256 public rewardAmount;
    uint256 private lastStakeTime;
    mapping(address => StakeInfo) public stakers;
    address projectWallet;

    function setDepositable(bool _depositable) external onlyOwner {
        canDeposit = _depositable;
    }

    function APYCalculator() public view returns(uint256){
        uint256 _apyValue = rewardAmount * 1000 / (stakeAmount + feeAmount);
        return _apyValue;
    }

    function projectSend() external onlyOwner{
        token.transferFrom(projectWallet, address(this), rewardAmount);                                        
    }

    function stake(uint256 amount) external {
        require(canDeposit == true, 'Deposit is stopped');
        require(amount >= minDeposit, 'Amount is less than min');
        require(amount <= maxDeposit, 'Amount is bigger than max');
        StakeInfo storage newStake = stakers[msg.sender];
        newStake.stakeAmount = amount;
        newStake.stakeTime = block.timestamp;
        feeAmount += amount / 20;
        stakeAmount += newStake.stakeAmount * 95 / 100;
        rewardAmount += amount / 10;
        token.transferFrom(msg.sender, address(this), amount);
        // token.transferFrom(projectWallet, address(this), rewardAmount);
        lastStakeTime = block.timestamp;
    }

    function withdraw() external {
        require(canDeposit == false, 'Deposit is not stopped');
        if(msg.sender == owner()) {
            uint256 _apy = APYCalculator();
            uint256 _feeRewardAmount = feeAmount * (block.timestamp - lastStakeTime) * _apy / (3600 * 24) / 3650;
            token.transfer(msg.sender, _feeRewardAmount + feeAmount);
            feeAmount = 0;
            rewardAmount -= _feeRewardAmount;
        }
        else {
            StakeInfo storage _stake = stakers[msg.sender];
            require(_stake.stakeAmount > 0, 'There is not stake Amount');
            uint256 _apy = APYCalculator();
            uint256 _rewardAmount = _stake.stakeAmount * (block.timestamp - _stake.stakeTime) * _apy / (3600 * 24) / 3650;
            uint256 _getAmount = _stake.stakeAmount * 95 / 100 + _rewardAmount;
            stakeAmount -= _stake.stakeAmount * 95 / 100;
            rewardAmount -= _rewardAmount;
            token.transfer(msg.sender, _getAmount);
            _stake.stakeAmount = 0;
        }
    }

    function setProjectWallet(address _projectWallet) external onlyOwner {
        projectWallet = _projectWallet;
    }

    function sweep() external onlyOwner{
        // require(msg.sender == feeWallet, 'This address is optimus admin wallet');
        uint256 _allAmount = token.balanceOf(address(this));
        token.transfer(owner(), _allAmount);
    }


    constructor(address _token) {
        token = IToken(_token);
        minDeposit = 1000;
        maxDeposit = 10 ** 21;
        canDeposit = true;
    }

}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IToken {
    function approve(address to, uint256 amount) external;

    function transfer(address recipient, uint256 amount) external;

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external;

    function balanceOf(address account) external view returns (uint256);

    function burnFrom(address account, uint256 amount) external;
}
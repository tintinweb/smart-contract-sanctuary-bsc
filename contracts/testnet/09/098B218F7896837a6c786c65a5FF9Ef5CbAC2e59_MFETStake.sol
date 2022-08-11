/**
 *Submitted for verification at BscScan.com on 2022-08-11
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-13
 */

// SPDX-License-Identifier: MIT

// MFET - Multi Functional Environmental Token
// We are Developing New Generation Projects and Funding These Projects with Green Blockchain.

// A Sustainable World
// MFET is an ecosystem that supports sustainable projects, provides mentoring to companies in carbon footprint studies,
// provides consultancy on environmental and climate studies, and makes decisions without being dependent on an authority
// with the community it has created, thanks to the blockchain.

// MFET - Stake Contract

// Mens et Manus
pragma solidity ^0.8.0;

interface IBEP20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
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
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {
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
     * by making the `nonReentrant` function external, and make it call a
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

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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

library SafeBEP20 {
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

    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
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
        uint256 newAllowance = token.allowance(address(this), spender) + value;
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
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeBEP20: decreased allowance below zero"
            );
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    newAllowance
                )
            );
        }
    }

    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(
            data,
            "SafeBEP20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            require(
                abi.decode(returndata, (bool)),
                "SafeBEP20: BEP20 operation did not succeed"
            );
        }
    }
}

contract MFETStake is Context, Ownable, ReentrancyGuard {
    using SafeBEP20 for IBEP20;

    struct Stake {
        address user;
        uint256 amount;
        uint256 since;
        uint256 rewardRatio;
        uint256 rate;
        bool isActive;
    }

    uint256 public stakeId;
    uint256[] public allStakeIds;

    uint256 public totalStakedAmount;
    uint256 public totalStakeRewardClaimed;

    mapping(address => uint256[]) private stakesByAddress;

    mapping(uint256 => Stake) public stakedToken;
    mapping(uint256 => uint256) public stakeRates;
    mapping(uint256 => uint256) private totalStakesByRate;

    event Staked(
        address indexed user,
        uint256 amount,
        uint256 timestamp,
        uint256 rewardRatio,
        uint256 rate,
        bool isActive
    );

    IBEP20 public mfetToken;
    uint256 emergencyFee;
    uint256 stakeFee;
    address public stakeFeeAddress;
    uint256 public stakePlus;

    constructor(
        uint256 stakeFee_,
        uint256 emergencyFee_,
        uint256 stakePlus_,
        address stakeFeeAddress_,
        address mfetToken_
    ) {
        stakeFee = stakeFee_;
        emergencyFee = emergencyFee_;
        stakePlus = stakePlus_;
        stakeFeeAddress = stakeFeeAddress_;
        mfetToken = IBEP20(mfetToken_);

        addStakeRate(1, 5);
        addStakeRate(3, 16);
        addStakeRate(6, 34);
        addStakeRate(9, 53);
        addStakeRate(12, 72);
        addStakeRate(18, 110);
        addStakeRate(24, 150);
    }

    modifier onlyEOA() {
        require(tx.origin == _msgSender(), "MFET Stake : should be EOA");
        _;
    }

    function addStakeRate(uint256 _rate, uint256 _rewardRatio)
        public
        onlyOwner
        returns (bool)
    {
        stakeRates[_rate] = _rewardRatio;
        return true;
    }

    function setStakePlus(uint256 _stakePlus)
        external
        onlyOwner
        returns (bool)
    {
        // calculation over 1000 be careful
        stakePlus = _stakePlus;
        return true;
    }

    function setMfetToken(address _contract) external onlyOwner returns (bool) {
        require(
            _contract != address(0),
            "MFET Stake : contract adress is zero address"
        );

        mfetToken = IBEP20(_contract);
        return true;
    }

    function setEmergencyWithdrawFee(uint256 _fee)
        external
        onlyOwner
        returns (bool)
    {
        emergencyFee = _fee;
        return true;
    }

    function setStakeFee(uint256 _fee) external onlyOwner returns (bool) {
        stakeFee = _fee;
        return true;
    }

    function setStakeFeeAddress(address _address)
        external
        onlyOwner
        returns (bool)
    {
        require(
            _address != address(0),
            "MFET Stake : user adress is zero address"
        );
        stakeFeeAddress = _address;
        return true;
    }

    function getAddressAllStakeIds(address _user)
        external
        view
        returns (uint256[] memory)
    {
        return stakesByAddress[_user];
    }

    function getSingleStakeDetails(uint256 _id)
        external
        view
        returns (
            address user,
            uint256 amount,
            uint256 since,
            uint256 rewardRatio,
            uint256 rate,
            bool isActive
        )
    {
        return (
            stakedToken[_id].user,
            stakedToken[_id].amount,
            stakedToken[_id].since,
            stakedToken[_id].rewardRatio,
            stakedToken[_id].rate,
            stakedToken[_id].isActive
        );
    }

    function getAddressActiveTotalStakedAmount(address _user)
        external
        view
        returns (uint256)
    {
        uint256[] memory userStakes = stakesByAddress[_user];

        uint256 totalStaked = 0;
        for (uint256 i = 0; i < userStakes.length; i++) {
            if (stakedToken[userStakes[i]].isActive) {
                totalStaked = totalStaked + stakedToken[userStakes[i]].amount;
            }
        }
        return totalStaked;
    }

    function _stake(
        address _user,
        uint256 _amount,
        uint256 _rate,
        uint256 _timestamp
    ) internal returns (uint256) {
        require(_amount > 0, "MFET Stake : cant stake nothing");
        require(
            stakeRates[_rate] != 0,
            "MFET Stake: there is no stake reward ratio for this rate"
        );

        uint256 stakeFeeAmount = 0;
        uint256 stakeAmount = _amount;

        if (stakeFee > 0) {
            stakeFeeAmount = (_amount * stakeFee) / 1000;
            require(stakeFeeAmount > 0, "MFET Stake : fee calculation error");
            stakeAmount = stakeAmount - stakeFeeAmount;

            // user send tokens to fee address
            mfetToken.safeTransferFrom(
                _msgSender(),
                stakeFeeAddress,
                stakeFeeAmount
            );
        }

        uint256 _id = ++stakeId;
        allStakeIds.push(_id);
        stakesByAddress[_user].push(_id);
        totalStakesByRate[_rate] = totalStakesByRate[_rate] + stakeAmount;

        totalStakedAmount = totalStakedAmount + stakeAmount;

        stakedToken[_id].user = _user;
        stakedToken[_id].amount = stakeAmount;
        stakedToken[_id].since = _timestamp;
        stakedToken[_id].rewardRatio = stakeRates[_rate];
        stakedToken[_id].rate = _rate;
        stakedToken[_id].isActive = true;

        // user send tokens to stake contract
        mfetToken.safeTransferFrom(_msgSender(), address(this), stakeAmount);

        emit Staked(
            _msgSender(),
            stakeAmount,
            block.timestamp,
            stakeRates[_rate],
            _rate,
            true
        );

        return _id;
    }

    function stake(
        uint256 _amount,
        uint256 _rate,
        uint256 _timestamp
    ) external nonReentrant onlyEOA returns (uint256) {
        require(_amount > 0, "MFET Stake : you cant stake zero");
        uint256 _addressBalance = mfetToken.balanceOf(_msgSender());
        require(
            _addressBalance >= _amount,
            "MFET Stake: cannot stake more than you own"
        );

        return _stake(_msgSender(), _amount, _rate, _timestamp);
    }

    function stakeFor(
        address _user,
        uint256 _amount,
        uint256 _rate,
        uint256 _timestamp
    ) external nonReentrant onlyEOA returns (uint256) {
        require(
            _user != address(0),
            "MFET Stake : user adress is zero address"
        );
        require(_amount > 0, "MFET Stake : you cant stake zero");
        uint256 _addressBalance = mfetToken.balanceOf(_msgSender());
        require(
            _addressBalance >= _amount,
            "MFET Stake: cannot stake more than you own"
        );

        return _stake(_user, _amount, _rate, _timestamp);
    }

    function getRewardsLeft() public view returns (uint256) {
        uint256 contractTotalBalance = mfetToken.balanceOf(address(this));
        unchecked {
            return contractTotalBalance - totalStakedAmount;
        }
    }

    function calculateStakeRewards(uint256 _id) public view returns (uint256) {
        uint256 rewardAmount = ((stakedToken[_id].rewardRatio *
            stakedToken[_id].amount) / 1000);
        return rewardAmount;
    }

    function _monthlyRewards(uint256 _id) internal returns (uint256) {
        uint256 extraReward = 0;
        uint256 totalDaysPast = (block.timestamp - stakedToken[_id].since) /
            1 days;

        require(
            totalDaysPast > 0,
            "MFET Stake : total day past must bigger then 0"
        );

        uint256 dayPassRatio = (totalDaysPast *
            stakedToken[_id].rewardRatio *
            1e9) / (stakedToken[_id].rate * 30);

        require(dayPassRatio > 0, "MFET Stake : day pass must bigger then 0");

        uint256 mRewardAmount = (stakedToken[_id].amount * dayPassRatio) / 1e12;

        if (stakePlus > 0) {
            extraReward = (stakedToken[_id].amount * stakePlus) / 1000;
            require(
                extraReward > 0,
                "MFET Stake : extra reward must bigger then 0"
            );
        }

        mRewardAmount = mRewardAmount + extraReward;

        require(
            mRewardAmount > 0,
            "MFET Stake : monthly reward must bigger then 0"
        );

        uint256 rewardsLeftInContract = getRewardsLeft();

        if (rewardsLeftInContract < mRewardAmount) {
            mRewardAmount = rewardsLeftInContract;
        }

        totalStakeRewardClaimed = totalStakeRewardClaimed + mRewardAmount;

        return mRewardAmount;
    }

    function monthlyClaim(uint256 _id) external nonReentrant onlyEOA {
        require(stakedToken[_id].isActive, "MFET Stake : not active");
        require(
            stakedToken[_id].rate >= 3,
            "MFET Stake : monthy claim only over 30 day stakes"
        );
        require(
            totalStakedAmount > 0,
            "MFET Stake : there are no stake in there"
        );
        require(
            _msgSender() == stakedToken[_id].user,
            "MFET Stake : this is not your token"
        );
        require(
            block.timestamp > stakedToken[_id].since + 30 days,
            "MFET Stake : monthly claim time not yet"
        );

        uint256 stakeMonthlyReward = _monthlyRewards(_id);
        require(
            stakeMonthlyReward > 0,
            "MFET Stake : monthly reward bigger then 0"
        );

        stakedToken[_id].since = block.timestamp;
        mfetToken.safeTransfer(_msgSender(), stakeMonthlyReward);
    }

    function _withdraw(uint256 _id) internal returns (uint256) {
        uint256 stakeAmount = stakedToken[_id].amount;
        uint256 rewardAmount = calculateStakeRewards(_id);

        uint256 rewardsLeftInContract = getRewardsLeft();

        if (rewardsLeftInContract < rewardAmount) {
            rewardAmount = rewardsLeftInContract;
        }

        unchecked {
            totalStakedAmount = totalStakedAmount - stakedToken[_id].amount;
        }

        unchecked {
            totalStakesByRate[stakedToken[_id].rate] =
                totalStakesByRate[stakedToken[_id].rate] -
                stakedToken[_id].amount;
        }

        totalStakeRewardClaimed = totalStakeRewardClaimed + rewardAmount;

        return stakeAmount + rewardAmount;
    }

    function withdraw(uint256 _id) external nonReentrant onlyEOA {
        require(
            totalStakedAmount > 0,
            "MFET Stake : there are no stake in there"
        );

        require(stakedToken[_id].isActive, "MFET Stake : not active");

        require(
            _msgSender() == stakedToken[_id].user,
            "MFET Stake : this is not your token"
        );

        require(
            block.timestamp >
                stakedToken[_id].since + (stakedToken[_id].rate * 30 days),
            "MFET Stake : time not yet"
        );

        stakedToken[_id].isActive = false;

        uint256 stakeAndReward = _withdraw(_id);

        mfetToken.safeTransfer(_msgSender(), stakeAndReward);
    }

    function emergencyWithdraw(uint256 _id) external nonReentrant onlyEOA {
        require(
            stakedToken[_id].rate <= 3,
            "MFET Stake : over 90 days stake cant emergency withdraw"
        );

        require(stakedToken[_id].isActive, "Stake : stake is not active");

        require(
            _msgSender() == stakedToken[_id].user,
            "MFET Stake : this is not your token"
        );

        require(totalStakedAmount > 0, "Stake : there are no stake in there");

        require(
            mfetToken.balanceOf(address(this)) >= stakedToken[_id].amount,
            "MFET Stake : can not withdraw more then contract have"
        );

        stakedToken[_id].isActive = false;

        uint256 feeAmount = (stakedToken[_id].amount * emergencyFee) / 1000;

        uint256 afterFee = stakedToken[_id].amount - feeAmount;

        unchecked {
            totalStakedAmount = totalStakedAmount - stakedToken[_id].amount;
        }

        unchecked {
            totalStakesByRate[stakedToken[_id].rate] =
                totalStakesByRate[stakedToken[_id].rate] -
                stakedToken[_id].amount;
        }
        //send fee to fee address
        mfetToken.safeTransfer(stakeFeeAddress, feeAmount);
        // send balance after fee staked tokens to user
        mfetToken.safeTransfer(_msgSender(), afterFee);
    }

    function getTotalStakesByRate(uint256 _rate)
        external
        view
        returns (uint256)
    {
        return totalStakesByRate[_rate];
    }

    function addLiquidityWithContract(address _contract, uint256 _amount)
        external
        onlyOwner
    {
        uint256 currentAllowance = IBEP20(_contract).allowance(
            _msgSender(),
            address(this)
        );
        require(
            currentAllowance >= _amount,
            "MFET MFETStake : allowance is not enough"
        );
        IBEP20(_contract).safeTransferFrom(
            _msgSender(),
            address(this),
            _amount
        );
    }

    function removeLiquidityWithContract(
        address _contract,
        address _to,
        uint256 _amount
    ) external onlyOwner {
        require(_to != address(0), "MFET Stake : to address is zero address");
        require(
            IBEP20(_contract).balanceOf(address(this)) >= _amount,
            "MFET Stake : insufficient liquidity"
        );
        IBEP20(_contract).safeTransfer(_to, _amount);
    }
}
// Made with love.
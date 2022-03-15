/**
 *Submitted for verification at BscScan.com on 2022-03-15
*/

// SPDX-License-Identifier: MIT

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

contract DeuxStake is Context, Ownable, ReentrancyGuard {
    using SafeBEP20 for IBEP20;

    struct Stake {
        address user;
        uint256 amount;
        uint256 since;
        uint256 rewardRatio;
        uint256 rate;
    }

    struct Stakeholder {
        address user;
        Stake[] address_stakes;
    }

    Stakeholder[] internal stakeholders;
    mapping(address => uint256) internal stakes;
    mapping(uint256 => uint256) public stakeRates;

    event Staked(
        address indexed user,
        uint256 amount,
        uint256 index,
        uint256 timestamp,
        uint256 rewardRatio,
        uint256 rate
    );

    IBEP20 public deuxToken;
    uint256 emergencyFee;
    uint256 stakeFee;
    address public stakeFeeAddress;

    constructor() {
        stakeFee = 10;
        emergencyFee = 100;
        stakeFeeAddress = 0x1f9d70b7520563f62152E0A76DB94C6Bcf705A87;
        deuxToken = IBEP20(0x20281A1869b982b62F86Db29d4653A6E11c05ADE);
        addStakeRate(30, 100);
        addStakeRate(60, 120);
        addStakeRate(90, 200);
    }

    function addStakeRate(uint256 _rate, uint256 _rewardRatio)
        public
        onlyOwner
    {
        stakeRates[_rate] = _rewardRatio;
    }

    function setDeuxToken(address _contract) public onlyOwner {
        deuxToken = IBEP20(_contract);
    }

    function setEmergenyWithdrawFee(uint256 _fee) public onlyOwner {
        emergencyFee = _fee;
    }

    function setStakeFee(uint256 _fee) public onlyOwner {
        stakeFee = _fee;
    }

    function setStakeFeeAddress(address _address) public onlyOwner {
        stakeFeeAddress = _address;
    }

    function getUserStakeLength(address _user) external view returns (uint256) {
        uint256 user_index = stakes[_user];
        return stakeholders[user_index].address_stakes.length;
    }

    function getUserSingleStakeDetails(address _user, uint256 _id)
        external
        view
        returns (
            address user,
            uint256 amount,
            uint256 since,
            uint256 rewardRatio,
            uint256 rate
        )
    {
        uint256 user_index = stakes[_user];
        Stake storage userStake = stakeholders[user_index].address_stakes[_id];

        return (
            userStake.user,
            userStake.amount,
            userStake.since,
            userStake.rewardRatio,
            userStake.rate
        );
    }

    function getUserTotalStakeAmount(address _user)
        external
        view
        returns (uint256)
    {
        uint256 user_index = stakes[_user];
        Stake[] storage userStakes = stakeholders[user_index].address_stakes;

        uint256 totalStaked = 0;
        for (uint256 i = 0; i < userStakes.length; i++) {
            totalStaked = totalStaked + userStakes[i].amount;
        }
        return totalStaked;
    }

    function _addStakeholder(address _user) internal returns (uint256) {
        stakeholders.push();
        uint256 userIndex = stakeholders.length - 1;
        stakeholders[userIndex].user = _user;
        stakes[_user] = userIndex;
        return userIndex;
    }

    function _stake(uint256 _amount, uint256 _rate) internal returns (uint256) {
        require(_amount > 0, "Cannot stake nothing");
        require(
            stakeRates[_rate] != 0,
            "Stake: there is no stake reward ratio on mapping"
        );

        uint256 stakeFeeAmount = 0;
        uint256 stakeAmount = _amount;

        if (stakeFee > 0) {
            stakeFeeAmount = (_amount * stakeFee) / 1000;
            require(stakeFeeAmount > 0, "Stake : fee calculation error");
            stakeAmount = stakeAmount - stakeFeeAmount;

            // user send tokens to fee address
            deuxToken.safeTransferFrom(
                _msgSender(),
                stakeFeeAddress,
                stakeFeeAmount
            );
        }

        uint256 index = stakes[_msgSender()];

        uint256 timestamp = block.timestamp;

        if (index == 0) {
            index = _addStakeholder(_msgSender());
        }

        uint256 rewardRatio = stakeRates[_rate];

        stakeholders[index].address_stakes.push(
            Stake(_msgSender(), stakeAmount, timestamp, rewardRatio, _rate)
        );

        // user send tokens to stake contract
        deuxToken.safeTransferFrom(_msgSender(), address(this), stakeAmount);

        emit Staked(
            _msgSender(),
            stakeAmount,
            index,
            timestamp,
            rewardRatio,
            _rate
        );

        return stakeholders[index].address_stakes.length;
    }

    function stake(uint256 _amount, uint256 _rate) external returns (uint256) {
        uint256 _addressBalance = deuxToken.balanceOf(_msgSender());
        require(
            _addressBalance >= _amount,
            "Stake: cannot stake more than you own"
        );

        return _stake(_amount, _rate);
    }

    function _withdraw(uint256 _id, bool _emergeny) internal returns (uint256) {
        uint256 user_index = stakes[_msgSender()];
        Stake memory current_stake = stakeholders[user_index].address_stakes[
            _id
        ];

        if (!_emergeny) {
            require(
                block.timestamp >
                    current_stake.since + (current_stake.rate * 1 days),
                "Stake : time not yet"
            );
        }

        uint256 stakeAndReward = current_stake.amount +
            ((current_stake.rewardRatio * current_stake.amount) / 1000);

        delete stakeholders[user_index].address_stakes[_id];
        return stakeAndReward;
    }

    function withdraw(uint256 _id) external {
        uint256 stakeAndReward = _withdraw(_id, false);
        deuxToken.safeTransfer(_msgSender(), stakeAndReward);
    }

    function emergencyWithdraw(uint256 _id) external {
        uint256 stakeAndReward = _withdraw(_id, true);
        uint256 feeAmount = (stakeAndReward * emergencyFee) / 1000;
        uint256 afterFee = stakeAndReward - feeAmount;
        //send fee to fee address
        deuxToken.safeTransfer(stakeFeeAddress, feeAmount);
        // send earnings to user
        deuxToken.safeTransfer(_msgSender(), afterFee);
    }

    function addLiquidity(uint256 _amount) external onlyOwner {
        uint256 currentAllowance = deuxToken.allowance(
            _msgSender(),
            address(this)
        );
        require(currentAllowance >= _amount, "Stake : allowance is not enough");

        deuxToken.safeTransferFrom(_msgSender(), address(this), _amount);
    }

    function removeLiquidity(address _to, uint256 _amount) external onlyOwner {
        require(
            deuxToken.balanceOf(address(this)) >= _amount,
            "Stake : insufficient liquidity"
        );
        deuxToken.safeTransfer(_to, _amount);
    }
}
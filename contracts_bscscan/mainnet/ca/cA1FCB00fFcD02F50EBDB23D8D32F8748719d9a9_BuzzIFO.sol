// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;


import './IERC20.sol';
import './SafeERC20.sol';
import './ReentrancyGuard.sol';

contract BuzzIFO is ReentrancyGuard {
    using SafeERC20 for IERC20;


    uint256 public claimBlock;
    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many tokens the user has provided.
        bool refunded;
        bool isClaimed;
    }

    // admin address
    address public adminAddress;
    // The raising token
    IERC20 public stakeToken;
    // Flag if stake token is native EVM token
    bool public isNativeTokenStaking;
    // The offering token
    IERC20 public offeringToken;
    // The block number when IFO starts
    uint256 public startBlock;
    // The block number when IFO ends
    uint256 public endBlock;
    // total amount of raising tokens need to be raised
    uint256 public raisingAmount;
    // total amount of offeringToken that will offer
    uint256 public offeringAmount;
    // total amount of raising tokens that have already raised
    uint256 public totalAmount;
    // total amount of tokens to give back to users
    uint256 public totalDebt;
    // address => amount
    mapping(address => UserInfo) public userInfo;
    // participators
    address[] public addressList;

    bool public isInitialized;

    event Deposit(address indexed user, uint256 amount);
    event Harvest(
        address indexed user,
        uint256 offeringAmount,
        uint256 excessAmount
    );
    event EmergencySweepWithdraw(address indexed receiver, address indexed token, uint256 balance);


    function initialize(
      IERC20 _stakeToken,
      IERC20 _offeringToken,
      uint256 _startBlock,
      uint256 _endBlockOffset, // duration
      uint256 _offeringAmount,
      uint256 _raisingAmount,
      uint256 _claimBlock,
      address _adminAddress
    ) external {
        require(!isInitialized, "already init");
        stakeToken = _stakeToken;
        /// @dev address(0) turns this contract into a native token staking pool
        if(address(stakeToken) == address(0)) {
            isNativeTokenStaking = true;
        }
        offeringToken = _offeringToken;
        startBlock = _startBlock;
        endBlock = _startBlock + _endBlockOffset;
        claimBlock = _claimBlock;
        // Setup vesting release blocks

        offeringAmount = _offeringAmount;
        raisingAmount = _raisingAmount;
        totalAmount = 0;
        adminAddress = _adminAddress;
    }

    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "caller is not admin");
        _;
    }

    modifier onlyActiveIFO() {
        require(
            block.number >= startBlock && block.number < endBlock,
            "not iao time"
        );
        _;
    }

    function setOfferingAmount(uint256 _offerAmount) public onlyAdmin {
        require(block.number < startBlock, "cannot update during active iao");
        offeringAmount = _offerAmount;
    }

    function setRaisingAmount(uint256 _raisingAmount) public onlyAdmin {
        require(block.number < startBlock, "cannot update during active iao");
        raisingAmount = _raisingAmount;
    }

    /// @notice Deposits native EVM tokens into the IAO contract as per the value sent
    ///   in the transaction.
    function depositNative() external payable onlyActiveIFO {
        require(isNativeTokenStaking, 'stake token is not native EVM token');
        require(msg.value > 0, 'value not > 0');
        depositInternal(msg.value);
    }

    /// @dev Deposit ERC20 tokens with support for reflect tokens
    function deposit(uint256 _amount) external onlyActiveIFO {
        require(!isNativeTokenStaking, "stake token is native token, deposit through 'depositNative'");
        require(_amount > 0, "_amount not > 0");
        uint256 pre = getTotalStakeTokenBalance();
        stakeToken.safeTransferFrom(
            msg.sender,
            address(this),
            _amount
        );
        uint256 finalDepositAmount = getTotalStakeTokenBalance() - pre;
        depositInternal(finalDepositAmount);
    }

    /// @notice To support ERC20 and native token deposits this function does not transfer
    ///  any tokens in, but only updates the state. Make sure to transfer in the funds
    ///  in a parent function
    function depositInternal(uint256 _amount) internal {
        if (userInfo[msg.sender].amount == 0) {
            addressList.push(msg.sender);
        }
        userInfo[msg.sender].amount += _amount;
        totalAmount += _amount;
        totalDebt += _amount;
        emit Deposit(msg.sender, _amount);
    }

    function harvest() external nonReentrant{
        require(block.number > claimBlock, "not harvest time");
        require(userInfo[msg.sender].amount > 0, "have you participated?");
        require(!userInfo[msg.sender].isClaimed, "harvest for period already claimed");

        uint256 refundingTokenAmount = getRefundingAmount(msg.sender);
        if (refundingTokenAmount > 0) {
            userInfo[msg.sender].refunded = true;
            safeTransferStakeInternal(msg.sender, refundingTokenAmount);
        }

        uint256 offeringTokenAmountPerPeriod = getOfferingAmountPerPeriod(msg.sender);
        offeringToken.safeTransfer(msg.sender, offeringTokenAmountPerPeriod);
        userInfo[msg.sender].isClaimed = true;


        totalDebt -= userInfo[msg.sender].amount;
        emit Harvest(msg.sender, offeringTokenAmountPerPeriod, refundingTokenAmount);

    }

    function hasHarvested(address _user) external view returns (bool) {
        return userInfo[_user].isClaimed;
    }

    /// @notice Calculate a users allocation based on the total amount deposited. This is done
    ///  by first scaling the deposited amount and dividing by the total amount.
    /// @param _user Address of the user allocation to look up
    function getUserAllocation(address _user) public view returns (uint256) {
        // avoid division by zero
        if(totalAmount == 0) {
            return 0;
        }

        // allocation:
        // 1e6 = 100%
        // 1e4 = 1%
        // 1 = 0.0001%
        return (userInfo[_user].amount * 1e12 / totalAmount);
    }

    function getTotalStakeTokenBalance() public view returns (uint256) {
        if(isNativeTokenStaking) {
            return address(this).balance;
        } else {
            // Return ERC20 balance
            return stakeToken.balanceOf(address(this));
        }
    }

    /// @notice Calculate a user's offering amount to be received by multiplying the offering amount by
    ///  the user allocation percentage.
    /// @dev User allocation is scaled up by the ALLOCATION_PRECISION which is scaled down before returning a value.
    /// @param _user Address of the user allocation to look up
    function getOfferingAmount(address _user) public view returns (uint256) {
        if (totalAmount > raisingAmount) {
            return (offeringAmount * getUserAllocation(_user)) / 1e12;
        } else {
            // Return an offering amount equal to a proportion of the raising amount
            return (userInfo[_user].amount * offeringAmount) / raisingAmount;
        }
    }

    // get the amount of IAO token you will get per harvest period
    function getOfferingAmountPerPeriod(address _user) public view returns (uint256) {
        return getOfferingAmount(_user);
    }

    /// @notice Calculate a user's refunding amount to be received by multiplying the raising amount by
    ///  the user allocation percentage.
    /// @dev User allocation is scaled up by the ALLOCATION_PRECISION which is scaled down before returning a value.
    /// @param _user Address of the user allocation to look up
    function getRefundingAmount(address _user) public view returns (uint256) {
        // Users are able to obtain their refund on the first harvest only
        if (totalAmount <= raisingAmount || userInfo[_user].refunded == true) {
            return 0;
        }
        uint256 payAmount = (raisingAmount * getUserAllocation(_user)) / 1e12;
        return userInfo[_user].amount - payAmount;
    }

    /// @notice Get the amount of tokens a user is eligible to receive based on current state.
    /// @param _user address of user to obtain token status
    function userTokenStatus(address _user)
        public
        view
        returns (
            uint256 stakeTokenHarvest,
            uint256 offeringTokenHarvest,
            uint256 offeringTokensVested
        )
    {
        uint256 currentBlock = block.number;
        if(currentBlock < endBlock) {
            return (0,0,0);
        }

        stakeTokenHarvest = getRefundingAmount(_user);
        uint256 userOfferingPerPeriod = getOfferingAmountPerPeriod(_user);

        if(currentBlock >= claimBlock && !userInfo[_user].isClaimed) {
                // If offering tokens are available for harvest AND user has not claimed yet
                offeringTokenHarvest += userOfferingPerPeriod;
            } else if (currentBlock < claimBlock) {
                // If harvest period is in the future
                offeringTokensVested += userOfferingPerPeriod;
            }
        

        return (stakeTokenHarvest, offeringTokenHarvest, offeringTokensVested);
    }

    function getAddressListLength() external view returns (uint256) {
        return addressList.length;
    }

    function finalWithdraw(uint256 _stakeTokenAmount, uint256 _offerAmount)
        external
        onlyAdmin
    {
        require(
            _offerAmount <= offeringToken.balanceOf(address(this)),
            "not enough offering token"
        );
        safeTransferStakeInternal(msg.sender, _stakeTokenAmount);
        offeringToken.safeTransfer(msg.sender, _offerAmount);
    }

    /// @notice Internal function to handle stake token transfers. Depending on the stake
    ///   token type, this can transfer ERC-20 tokens or native EVM tokens.
    /// @param _to address to send stake token to
    /// @param _amount value of reward token to transfer
    function safeTransferStakeInternal(address _to, uint256 _amount) internal {
        require(
            _amount <= getTotalStakeTokenBalance(),
            "not enough stake token"
        );

        if (isNativeTokenStaking) {
            // Transfer native token to address
            (bool success, ) = _to.call{gas: 23000, value: _amount}("");
            require(success, "TransferHelper: NATIVE_TRANSFER_FAILED");
        } else {
            // Transfer ERC20 to address
            IERC20(stakeToken).safeTransfer(_to, _amount);
        }
    }

    /// @notice Sweep accidental ERC20 transfers to this contract. Can only be called by admin.
    /// @param token The address of the ERC20 token to sweep
    function sweepToken(IERC20 token, uint256 amount) external onlyAdmin {
        token.safeTransfer(msg.sender, amount);
        emit EmergencySweepWithdraw(msg.sender, address(token), amount);
    }
}
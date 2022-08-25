/**
 *Submitted for verification at BscScan.com on 2022-08-25
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

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

// File: contracts/Charity.sol


pragma solidity ^0.8.0;


interface IERC20Ownenable is IERC20 {
    function owner() external returns (address);
}

contract Charity {
    mapping(uint256 => mapping(address => uint256)) public donatetedAmount;
    mapping(uint256 => mapping(address => bool)) public userRewardClaimed;

    uint256[] public periodicallyTimes;

    mapping(uint256 => address[])  shareHolders;

    mapping(uint256 => uint256) public totalDonations;
    mapping(uint256 => bool) public _canWithdrawRewards;

    address public immutable sToken;


    struct CharityDetails {
        address rToken;
        uint256 rewardAmount;
        uint256 startTime; // the timestamp to start the charity
        uint256 endTime; // the timestamp to end the charity
        uint256 adminFee;
        uint256 minimumDonationAchive;
        uint256 minimumDonate;
    }

    CharityDetails[] _charitiesList;

    constructor(
        address _sToken,
        address _rToken,
        uint256 _rewardAmount,
        uint256 _startTime, // the timestamp to start the charity
        uint256 _endTime, // the timestamp to end the charity
        //address _creator,
        uint256 _adminFee,
        uint256 _minimumDonationAchive,
        uint256 _minimumDonate,
        uint256 _howManyTimeDistribution
    ) {
        require(
            _startTime < _endTime && _startTime >= block.timestamp,
            "Charity : Wrong Time ! "
        );

        require(
            _startTime < _endTime + 31556926,
            "Charity period should be one year"
        );
        SetPeriodicallyTimes(_howManyTimeDistribution, _startTime, _endTime);

        sToken = _sToken;
        CharityDetails memory charityDetails = CharityDetails(
            _rToken,
            _rewardAmount,
            _startTime,
            _endTime,
            _adminFee,
            _minimumDonationAchive,
            _minimumDonate
        );
            
        _charitiesList.push(charityDetails);
        _canWithdrawRewards[0] = false;
    }

    modifier charityNotOver(uint256 _charityIndex) {
        CharityDetails memory charityDetails = getCharityDetails(_charityIndex);
        require(charityDetails.endTime >= block.timestamp, "charity is over ");
        _;
    }
    modifier charityOver(uint256 _charityIndex) {
        CharityDetails memory charityDetails = getCharityDetails(_charityIndex);

        require(
            charityDetails.endTime < block.timestamp,
            "charity is not over "
        );
        _;
    }
    modifier canWithdrawRewards(uint256 _charityIndex) {
        require(
            _canWithdrawRewards[_charityIndex],
            "can't withdrawRewards yet"
        );
        _;
    }

    //---------------------- getters ---------------------------------------------------------

    function getDoners(uint256 _charityIndex)
        public
        view
        returns (address[] memory)
    {
        return shareHolders[_charityIndex];
    }

    function getCharityDetails(uint256 _charityIndex)
        public
        view
        returns (CharityDetails memory)
    {
        return _charitiesList[_charityIndex];
    }
    function getUserdonatetedAmount(uint256 _charityIndex,address _user) internal view returns(uint256) {
        return donatetedAmount[_charityIndex][_user];
    }


    //---------------------- donate tokens ---------------------------------------------------------

    function donate(
        address _doner,
        uint256 _amount,
        uint256 _charityIndex
    ) external charityNotOver(_charityIndex) {
        _donate(_doner, _amount, _charityIndex);
    }

    function _donate(
        address _doner,
        uint256 _amount,
        uint256 _charityIndex
    ) internal {
        CharityDetails memory charityDetails = getCharityDetails(_charityIndex);

        IERC20 token = IERC20(sToken);
        require(
            token.balanceOf(_doner) >= charityDetails.minimumDonate,
            "user not a token holder"
        );
        require(
            token.allowance(_doner, address(this)) >=
                charityDetails.minimumDonate,
            "allownce is insufficient"
        );
        token.transferFrom(_doner, address(this), _amount);
        

        if (getUserdonatetedAmount(_charityIndex,msg.sender)==0) {
            shareHolders[_charityIndex].push(msg.sender);
            donatetedAmount[_charityIndex][msg.sender] = _amount;
        
        }else{
            donatetedAmount[_charityIndex][msg.sender] += _amount;
            
        }
        totalDonations[_charityIndex] += _amount;
    }

    // ------------------------------------withDraw functions --------------------------------------
    function withdrawTokens(uint256 _charityIndex)
        external
        charityOver(_charityIndex)
    {
        _withdrawTokens(_charityIndex);
    }

    function withdrawCharityRewards(uint256 _charityIndex)
        external
        charityOver(_charityIndex)
    {
        _withdrawcharityRewards(_charityIndex);
    }

    function withdrawTokensNcharityRewards(uint256 _charityIndex)
        external
        charityOver(_charityIndex)
        canWithdrawRewards(_charityIndex)
    {
        require(donatetedAmount[_charityIndex][msg.sender] > 0);
        _withdrawTokens(_charityIndex);
        _withdrawcharityRewards(_charityIndex);
    }

    function withdrawCharityRewardsPerodically(uint256 _charityIndex) external {
        for (uint256 i = 0; i > periodicallyTimes.length; i++) {
            require(periodicallyTimes[i] < block.timestamp);
            require(
                userRewardClaimed[periodicallyTimes[i]][msg.sender],
                "Charity: Reward already claimed"
            );
            _withdrawcharityRewards(_charityIndex);
            userRewardClaimed[periodicallyTimes[i]][msg.sender] = true;
        }
    }

    function _withdrawTokens(uint256 _charityIndex) internal {
        IERC20 token = IERC20(sToken);
        uint256 _amount = getUserdonatetedAmount(_charityIndex,msg.sender);

        if (_amount > 0) {
            token.transfer(msg.sender, _amount);
            donatetedAmount[_charityIndex][msg.sender] = 0;
        }
    }

    function _withdrawcharityRewards(uint256 _charityIndex) internal {
        CharityDetails memory charityDetails = getCharityDetails(_charityIndex);

        uint256 _share = donatetedAmount[_charityIndex][msg.sender];
        IERC20 token = IERC20(charityDetails.rToken);

        require(_share > 0, "you don't have  share in charity");
        uint256 percentage = CalculateDonerShare(
            _share,
            totalDonations[_charityIndex]
        );
        uint256 userChartyAmount = (charityDetails.rewardAmount * percentage) /
            10000;
        if (userChartyAmount > 0) {
            token.transfer(msg.sender, userChartyAmount);
        }
    }

    // ------------------------------------calculations N distribution ---------------------------

    function CalculateDonerShare(uint256 _share, uint256 _totalShares)
        public
        pure
        returns (uint256)
    {
        uint256 percentage = (_share / _totalShares) * 10000;
        return (percentage);
    }

    function distributeCharity(uint256 _charityIndex)
        external
        charityOver(_charityIndex)
    {
        _distributeCharity(_charityIndex);
    }

    function _distributeCharity(uint256 _charityIndex) internal {
        CharityDetails memory charityDetails = getCharityDetails(_charityIndex);

        if (
            totalDonations[_charityIndex] >=
            charityDetails.minimumDonationAchive
        ) {
            require(
                charityDetails.endTime <= block.timestamp,
                "distribution date is not comming yet "
            );
            _canWithdrawRewards[_charityIndex] = true;
        } else {
            revert("charity milstones failed");
        }
    }

    function SetPeriodicallyTimes(
        uint256 _times,
        uint256 _startTime,
        uint256 _endTime
    ) internal {
        uint256 _timeDuration = _startTime;

        for (uint256 i = 0; i < _times; i++) {
            _timeDuration += (_endTime - _startTime) / _times;
            periodicallyTimes.push(_timeDuration);
        }
    }

    function _ReLaunchCharity() internal {}

    function CreateNewCharity(
        uint256 _charityIndex,
        address _rToken,
        uint256 _charityAmount,
        uint256 _startTime, // the timestamp to start the charity
        uint256 _endTime, // the timestamp to end the charity
        address _creator,
        uint256 _adminFee,
        uint256 _minimumDonationAchive,
        uint256 _minimumDonate
    ) internal {
        CharityDetails memory charityDetails = getCharityDetails(_charityIndex);

        require(charityDetails.endTime < block.timestamp);

        IERC20Ownenable token = IERC20Ownenable(sToken);
        require(token.owner() == _creator, "incorrect token owner");

        CharityDetails memory _charityDetails = CharityDetails(
            _rToken,
            _charityAmount,
            _startTime,
            _endTime,
            _adminFee,
            _minimumDonationAchive,
            _minimumDonate
        );
        _charitiesList.push(_charityDetails);
        uint256 _index = _charitiesList.length - 1;

        _canWithdrawRewards[_index] = false;
    }
}
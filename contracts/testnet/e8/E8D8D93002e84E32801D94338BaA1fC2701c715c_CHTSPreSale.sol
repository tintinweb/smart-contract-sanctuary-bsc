/**
 *Submitted for verification at BscScan.com on 2022-03-08
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-02
 */

/**
 *Submitted for verification at BscScan.com on 2022-02-21
 */

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.1;

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract CHTSPreSale {
    string public name = "CHTS PreSale";
    address public owner;
    uint256 profileId;

    address public accountBUSD;

    IERC20 public busdToken;
    IERC20 public chtsToken;

    uint256 public openTime;

    uint256 public totalBUSD;

    bool public isPause;

    struct UserInfo {
        uint256 id;
        address user;
        uint256 total; // How many tokens BUSD the user has transfer.
        uint256 createAt;
        uint256 totalCoinLock; // How many tokens the user has provided.
        uint256 totalCoinUnLock; // How many tokens the user has provided.
        uint256[] history;
    }

    mapping(address => uint256) public totalProfile;

    UserInfo[] public userInfo;

    address[] public stakers;

    event Deposit(address by, uint256 amount);

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the owner of the token farm can call this function"
        );
        _;
    }

    constructor(IERC20 _busdToken, address _accountBUSD) {
        //in order to use them in other functions
        busdToken = _busdToken;

        owner = msg.sender;
        accountBUSD = _accountBUSD;

        isPause = false;
        totalBUSD = 0;
        profileId = 0;
    }

    // Update status package
    function setPause(bool _isPause) public onlyOwner {
        isPause = _isPause;
    }

    function setbusdToken(IERC20 _busdToken) public onlyOwner {
        busdToken = _busdToken;
    }

    function setaccountBUSD(address _accountBUSD) public onlyOwner {
        accountBUSD = _accountBUSD;
    }

    function getStakers() public view returns (address[] memory) {
        return stakers;
    }

    function getProfileByAddress(address user) public view returns (uint256) {
        uint256 index = 0;

        for (uint256 i = 0; i < userInfo.length; i++) {
            if (userInfo[i].user == user) {
                index = i;
                break;
            }
        }

        if (index >= 0 && index < userInfo.length) {
            return index;
        }

        return 100; // Chỉ giới hạn từ 0->99
    }

    function getProfilesLength() public view returns (uint256) {
        return userInfo.length;
    }

    function getProfiles() public view returns (UserInfo[] memory) {
        return userInfo;
    }

    function deposit(uint256 _amount) public payable {
        // Validate amount
        require(_amount > 0, "Amount cannot be 0");
        require(totalProfile[msg.sender] == 1, "You're not allowed");
        require(!isPause, "Event end");

        uint256 indexProfile = getProfileByAddress(msg.sender);

        UserInfo memory profile;
        profile.id = profileId;
        profile.user = msg.sender;
        profile.total = _amount;
        profile.createAt = block.timestamp;
        profile.totalCoinLock = _amount;
        profile.totalCoinUnLock = 0;

        if (indexProfile != 100) {
            userInfo[indexProfile].total += _amount;
        } else {
            userInfo.push(profile);
            // Update profile id
            profileId++;
        }

        // Transfer token
        busdToken.transferFrom(msg.sender, accountBUSD, _amount);

        // Update total staking
        totalBUSD += _amount;

        emit Deposit(msg.sender, _amount);
    }



    // function getCurrentCoinUnlock(uint256 _profileId)
    //     public
    //     view
    //     returns (uint256)
    // {
    //     require(userInfo[_profileId].totalCoinLock != 0, "Invalid profile");

    //     UserInfo memory info = userInfo[_profileId];

    //     return (info.totalCoinLock / (info.timeEnd - block.timestamp)) * 100;
    // }

    // Withdraw staking token from smart contract
    // function withdraw(uint256 _amount) public onlyOwner {
    //     stakeToken.transfer(msg.sender, _amount);
    // }
}
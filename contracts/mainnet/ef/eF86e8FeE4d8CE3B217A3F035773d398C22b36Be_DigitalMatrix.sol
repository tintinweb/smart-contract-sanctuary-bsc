/**
 *Submitted for verification at BscScan.com on 2022-10-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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


contract DigitalMatrix {
    IERC20 public token;

    struct User {
        uint256 id;
        address referrer;
        uint256 partnersCounter;
        mapping(uint256 => bool) activedLevels;
        mapping(uint256 => X3) matrix;
    }

    struct X3 {
        uint256 referralsCounter;
        uint256 reinvestCounter;
    }

    mapping(address => User) public users;
    mapping(uint256 => address) public idToAddress;
    mapping(uint256 => address) public userIds;

    uint256 public lastUserId;
    address public owner;

    mapping(uint8 => uint256) public priceLevels;
    mapping(uint8 => uint256) public priceLevelFees;
    uint8 public constant LAST_LEVEL = 15;

    bool public locked;

    event Registration(
        address indexed user,
        address indexed referrer,
        uint256 indexed userId,
        uint256 referrerId
    );
    event Reinvest(
        address indexed user,
        address indexed currentReferrer,
        address indexed caller,
        uint256 level
    );
    event Upgrade(
        address indexed user,
        address indexed referrer,
        uint256 level
    );
    event NewUserPlace(
        address indexed user,
        address indexed referrer,
        uint256 level,
        uint256 place
    );
    event MissedTokenReceive(
        address indexed receiver,
        address indexed from,
        uint256 level
    );

    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress);
        owner = msg.sender;

        priceLevels[1] = 5;
        priceLevels[2] = 9;
        priceLevels[3] = 15;
        priceLevels[4] = 25;
        priceLevels[5] = 45;
        priceLevels[6] = 80;
        priceLevels[7] = 150;
        priceLevels[8] = 250;
        priceLevels[9] = 450;
        priceLevels[10] = 800;
        priceLevels[11] = 1500;
        priceLevels[12] = 2500;
        priceLevels[13] = 4500;
        priceLevels[14] = 8000;
        priceLevels[15] = 15000;

        for (uint8 i = 1; i <= LAST_LEVEL; i++) {
            priceLevels[i] = priceLevels[i] * 10**18;
        }

        for (uint8 i = 1; i <= 6; i++) {
            priceLevelFees[i] = 5 * 10**17;
        }

        for (uint8 i = 7; i <= LAST_LEVEL; i++) {
            priceLevelFees[i] = priceLevels[i] / 100;
        }

        users[owner].id = 1;
        users[owner].referrer = address(0);
        users[owner].partnersCounter = uint256(0);

        for (uint8 i = 1; i <= LAST_LEVEL; i++) {
            users[owner].activedLevels[i] = true;
        }

        idToAddress[1] = owner;
        userIds[1] = owner;
        lastUserId = 1;

        locked = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "onlyOwner");
        _;
    }

    modifier onlyUnlocked() {
        require(!locked || msg.sender == owner, "locked");
        _;
    }

    function changeLocked() external onlyOwner {
        locked = !locked;
    }

    fallback() external {
        if (msg.data.length == 0) {
            return registration(msg.sender, owner);
        }
        registration(msg.sender, bytesToAddress(msg.data));
    }

    function registrationUpToLevel(address referrerAddress, uint8 level)
        external
        onlyUnlocked
    {
        require(level > 1 && level <= LAST_LEVEL, "incorrect level");
        registration(msg.sender, referrerAddress);
        for (uint8 i = 2; i <= level; i++) {
            _buyNewLevel(msg.sender, level);
        }
    }

    function registrationExt(address referrerAddress) external onlyUnlocked {
        registration(msg.sender, referrerAddress);
    }

    function registrationFor(address userAddress, address referrerAddress)
        external
        onlyUnlocked
    {
        registration(userAddress, referrerAddress);
    }

    function buyNewLevel(uint8 level) external onlyUnlocked {
        _buyNewLevel(msg.sender, level);
    }

    function buyNewLevelFor(address userAddress, uint8 level)
        external
        onlyUnlocked
    {
        _buyNewLevel(userAddress, level);
    }

    function _buyNewLevel(address _userAddress, uint8 level) internal {
        require(
            isUserExists(_userAddress),
            "user is not exists. Register first."
        );
        require(level > 1 && level <= LAST_LEVEL, "incorrect level");
        require(
            users[_userAddress].activedLevels[level - 1],
            "buy the previous level first"
        );
        require(
            !users[_userAddress].activedLevels[level],
            "level already activated"
        );

        token.transferFrom(msg.sender, address(this), priceLevels[level]);

        address freeReferrer = findFreeReferrer(_userAddress, level);

        users[_userAddress].activedLevels[level] = true;
        updateReferrer(_userAddress, freeReferrer, level);

        emit Upgrade(_userAddress, freeReferrer, level);
    }

    function registration(address userAddress, address referrerAddress)
        private
    {
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");

        token.transferFrom(msg.sender, address(this), priceLevels[1]);

        lastUserId++;
        idToAddress[lastUserId] = userAddress;
        userIds[lastUserId] = userAddress;

        users[userAddress].id = lastUserId;
        users[userAddress].referrer = referrerAddress;
        users[userAddress].partnersCounter = 0;
        users[userAddress].activedLevels[1] = true;

        users[referrerAddress].partnersCounter++;

        updateReferrer(userAddress, referrerAddress, 1);

        emit Registration(
            userAddress,
            referrerAddress,
            users[userAddress].id,
            users[referrerAddress].id
        );
    }

    function updateReferrer(
        address userAddress,
        address referrerAddress,
        uint8 level
    ) private {
        users[referrerAddress].matrix[level].referralsCounter++;

        if (users[referrerAddress].matrix[level].referralsCounter < 3) {
            emit NewUserPlace(
                userAddress,
                referrerAddress,
                level,
                uint256(users[referrerAddress].matrix[level].referralsCounter)
            );
            return transferTokens(referrerAddress, userAddress, level);
        }

        emit NewUserPlace(userAddress, referrerAddress, level, 3);

        users[referrerAddress].matrix[level].referralsCounter = uint256(0);

        if (referrerAddress != owner) {
            address freeReferrer = findFreeReferrer(referrerAddress, level);

            users[referrerAddress].matrix[level].reinvestCounter++;
            emit Reinvest(referrerAddress, freeReferrer, userAddress, level);
            updateReferrer(referrerAddress, freeReferrer, level);
        } else {
            transferTokens(owner, userAddress, level);
            users[owner].matrix[level].reinvestCounter++;
            emit Reinvest(owner, address(0), userAddress, level);
        }
    }

    function findFreeReferrer(address userAddress, uint8 level)
        public
        view
        returns (address)
    {
        while (true) {
            if (users[users[userAddress].referrer].activedLevels[level]) {
                return users[userAddress].referrer;
            }

            userAddress = users[userAddress].referrer;
        }
        return address(0);
    }

    function usersActivedLevels(address userAddress, uint8 level)
        public
        view
        returns (bool)
    {
        return users[userAddress].activedLevels[level];
    }

    function usersMatrix(address, uint8 level)
        public
        view
        returns (uint256, uint256)
    {
        return (
            users[msg.sender].matrix[level].referralsCounter,
            users[msg.sender].matrix[level].reinvestCounter
        );
    }

    function isUserExists(address userAddress) public view returns (bool) {
        return (users[userAddress].id != 0);
    }

    function findReceiver(
        address userAddress,
        address _from,
        uint8 level
    ) private returns (address) {
        address receiver = userAddress;

        while (true) {
            if (!usersActivedLevels(receiver, level)) {
                emit MissedTokenReceive(receiver, _from, level);
                receiver = users[receiver].referrer;
            } else {
                return receiver;
            }
        }
        return address(0);
    }

    function transferTokens(
        address userAddress,
        address _from,
        uint8 level
    ) private {
        address receiver = findReceiver(userAddress, _from, level);

        token.transfer(receiver, priceLevels[level] - priceLevelFees[level]);
        token.transfer(owner, priceLevelFees[level]);
    }

    function bytesToAddress(bytes memory bys)
        private
        pure
        returns (address addr)
    {
        assembly {
            addr := mload(add(bys, 20))
        }
    }

    function withdraw(address tokenAddress) public onlyOwner {
        IERC20(tokenAddress).transfer(
            msg.sender,
            IERC20(tokenAddress).balanceOf(address(this))
        );
    }
}
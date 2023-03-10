/**
 *Submitted for verification at BscScan.com on 2023-03-10
*/

pragma solidity >=0.4.23 <0.6.0;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract BNBMoney {
    using SafeMath for uint256;
    using SafeMath for uint8;

    struct User {
        uint256 id;
        address payable referrer;
        uint256 partnersCount;
        mapping(uint8 => bool) activeX3Levels;
        mapping(uint8 => bool) activeX6Levels;
        mapping(uint8 => X3) x3Matrix;
        mapping(uint8 => X6) x6Matrix;
    }

    struct X3 {
        address currentReferrer;
        address[] referrals;
        bool blocked;
        uint256 reinvestCount;
    }

    struct X6 {
        address currentReferrer;
        address[] firstLevelReferrals;
        address[] secondLevelReferrals;
        bool blocked;
        uint256 reinvestCount;
        address closedPart;
    }

    struct currentPayment {
        uint256 userid;
        address payable currentPaymentAddress;
        uint8 noofpayments;
        uint256 totalpayment;
    }

    uint8 public constant LAST_LEVEL = 10;

    mapping(address => User) public users;
    mapping(uint256 => address) public idToAddress;
    mapping(uint256 => address) public userIds;
    mapping(address => uint256) public balances;
    bool public isRegistrationOpen;

    uint256 public lastUserId = 2;
    address payable public owner;

    mapping(uint8 => uint256) public levelPrice;

    mapping(uint256 => uint256) public Currentuserids;
    mapping(uint256 => uint256) public CurrentPaymentid;
    mapping(uint256 => mapping(uint256 => currentPayment))
        public currentpayment;

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
        uint8 matrix,
        uint8 level
    );
    event Upgrade(
        address indexed user,
        address indexed referrer,
        uint8 matrix,
        uint8 level
    );
    event NewUserPlace(
        address indexed user,
        address indexed referrer,
        uint8 matrix,
        uint8 level,
        uint8 place
    );
    event MissedEthReceive(
        address indexed receiver,
        address indexed from,
        uint8 matrix,
        uint8 level
    );
    event SentExtraEthDividends(
        address indexed from,
        address indexed receiver,
        uint8 matrix,
        uint8 level
    );
    event MatchPayout(
        address indexed addr,
        address indexed from,
        uint256 amount
    );

    constructor(address payable ownerAddress) public {
        levelPrice[1] = 0.004 ether;
        for (uint8 i = 2; i <= LAST_LEVEL; i++) {
            levelPrice[i] = levelPrice[i - 1] * 2;
        }

        owner = ownerAddress;

        User memory user = User({
            id: 1,
            referrer: address(0),
            partnersCount: uint256(0)
        });

        users[ownerAddress] = user;

        for (uint8 i = 1; i <= LAST_LEVEL; i++) {
            users[ownerAddress].activeX3Levels[i] = true;
            users[ownerAddress].activeX6Levels[i] = true;

            CurrentPaymentid[i] = 1;
            idToAddress[i] = ownerAddress;
            Currentuserids[i] = Currentuserids[i].add(1);
            currentPayment memory currentpay = currentPayment({
                userid: Currentuserids[i],
                currentPaymentAddress: owner,
                noofpayments: 0,
                totalpayment: 0
            });
            currentpayment[i][Currentuserids[i]] = currentpay;

            
        }

        userIds[1] = ownerAddress;
    }

    function startPublicRegistration() external {
        require(msg.sender == owner, "Only owner");
        isRegistrationOpen = true;
    }

    function registrationExt(address payable referrerAddress) external payable {
        require(isRegistrationOpen, "Not started yet");
        registration(msg.sender, referrerAddress);
    }

    function registrationAdmin(
        address payable userAddress,
        address payable referrerAddress
    ) external payable {
        require(!isRegistrationOpen, "Public registration started");
        require(msg.sender == owner, "Only owner");
        registration(userAddress, referrerAddress);
    }

    function buyNewLevel(uint8 matrix, uint8 level) external payable {
        require(isRegistrationOpen, "Not started yet");
        buyLevel(msg.sender, matrix, level);
    }

    function buyNewLevelAdmin(
        address payable userAddress,
        uint8 matrix,
        uint8 level
    ) external payable {
        require(!isRegistrationOpen, "Public registration started");
        require(msg.sender == owner, "Only owner");
        buyLevel(userAddress, matrix, level);
    }

    function buyLevel(
        address payable userAddress,
        uint8 matrix,
        uint8 level
    ) internal {
        require(
            isUserExists(userAddress),
            "user is not exists. Register first."
        );
        require(matrix == 1 || matrix == 2, "invalid matrix");
        require(msg.value == levelPrice[level], "invalid price");
        require(level > 1 && level <= LAST_LEVEL, "invalid level");

        if (matrix == 1) {
            require(
                !users[userAddress].activeX3Levels[level],
                "level already activated"
            );

            if (users[userAddress].x3Matrix[level - 1].blocked) {
                users[userAddress].x3Matrix[level - 1].blocked = false;
            }

            address freeX3Referrer = findFreeX3Referrer(userAddress, level);
            users[userAddress].x3Matrix[level].currentReferrer = freeX3Referrer;
            users[userAddress].activeX3Levels[level] = true;
            updateX3Referrer(userAddress, freeX3Referrer, level);

            emit Upgrade(userAddress, freeX3Referrer, 1, level);
        } else if (matrix == 2) {
            require(
                !users[userAddress].activeX6Levels[level],
                "level already activated"
            );

            if (users[userAddress].x6Matrix[level - 1].blocked) {
                users[userAddress].x6Matrix[level - 1].blocked = false;
            }

            address freeX6Referrer = findFreeX6Referrer(userAddress, level);

            users[userAddress].activeX6Levels[level] = true;
            updateX6Referrer(userAddress, freeX6Referrer, level);

            emit Upgrade(userAddress, freeX6Referrer, 2, level);
        } 
    }

    function registration(
        address payable userAddress,
        address payable referrerAddress
    ) private {
        require(msg.value == levelPrice[1].mul(2)+ 0.002 ether, "registration cost 0.01");
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");

        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        require(size == 0, "cannot be a contract");

        User memory user = User({
            id: lastUserId,
            referrer: referrerAddress,
            partnersCount: 0
        });

        users[userAddress] = user;
        idToAddress[lastUserId] = userAddress;

        users[userAddress].referrer = referrerAddress;

        users[userAddress].activeX3Levels[1] = true;
        users[userAddress].activeX6Levels[1] = true;

        userIds[lastUserId] = userAddress;
        lastUserId++;

        users[referrerAddress].partnersCount++;

        address freeX3Referrer = findFreeX3Referrer(userAddress, 1);
        users[userAddress].x3Matrix[1].currentReferrer = freeX3Referrer;
        updateX3Referrer(userAddress, freeX3Referrer, 1);

        updateX6Referrer(userAddress, findFreeX6Referrer(userAddress, 1), 1);
        _refPayout(msg.sender);
        emit Registration(
            userAddress,
            referrerAddress,
            users[userAddress].id,
            users[referrerAddress].id
        );
    }

  

    function updateX3Referrer(
        address userAddress,
        address referrerAddress,
        uint8 level
    ) private {
        users[referrerAddress].x3Matrix[level].referrals.push(userAddress);

        if (users[referrerAddress].x3Matrix[level].referrals.length < 3) {
            emit NewUserPlace(
                userAddress,
                referrerAddress,
                1,
                level,
                uint8(users[referrerAddress].x3Matrix[level].referrals.length)
            );
            return sendETHDividends(referrerAddress, userAddress, 1, level);
        }

        emit NewUserPlace(userAddress, referrerAddress, 1, level, 3);
        //close matrix
        users[referrerAddress].x3Matrix[level].referrals = new address[](0);
        if (
            !users[referrerAddress].activeX3Levels[level + 1] &&
            level != LAST_LEVEL
        ) {
            users[referrerAddress].x3Matrix[level].blocked = true;
        }

        //create new one by recursion
        if (referrerAddress != owner) {
            //check referrer active level
            address freeReferrerAddress = findFreeX3Referrer(
                referrerAddress,
                level
            );
            if (
                users[referrerAddress].x3Matrix[level].currentReferrer !=
                freeReferrerAddress
            ) {
                users[referrerAddress]
                    .x3Matrix[level]
                    .currentReferrer = freeReferrerAddress;
            }

            users[referrerAddress].x3Matrix[level].reinvestCount++;
            emit Reinvest(
                referrerAddress,
                freeReferrerAddress,
                userAddress,
                1,
                level
            );
            updateX3Referrer(referrerAddress, freeReferrerAddress, level);
        } else {
            sendETHDividends(owner, userAddress, 1, level);
            users[owner].x3Matrix[level].reinvestCount++;
            emit Reinvest(owner, address(0), userAddress, 1, level);
        }
    }

    function updateX6Referrer(
        address userAddress,
        address referrerAddress,
        uint8 level
    ) private {
        require(
            users[referrerAddress].activeX6Levels[level],
            "500. Referrer level is inactive"
        );

        if (
            users[referrerAddress].x6Matrix[level].firstLevelReferrals.length <
            2
        ) {
            users[referrerAddress].x6Matrix[level].firstLevelReferrals.push(
                userAddress
            );
            emit NewUserPlace(
                userAddress,
                referrerAddress,
                2,
                level,
                uint8(
                    users[referrerAddress]
                        .x6Matrix[level]
                        .firstLevelReferrals
                        .length
                )
            );

            //set current level
            users[userAddress]
                .x6Matrix[level]
                .currentReferrer = referrerAddress;

            if (referrerAddress == owner) {
                return sendETHDividends(referrerAddress, userAddress, 2, level);
            }

            address ref = users[referrerAddress]
                .x6Matrix[level]
                .currentReferrer;
            users[ref].x6Matrix[level].secondLevelReferrals.push(userAddress);

            uint256 len = users[ref].x6Matrix[level].firstLevelReferrals.length;

            if (
                (len == 2) &&
                (users[ref].x6Matrix[level].firstLevelReferrals[0] ==
                    referrerAddress) &&
                (users[ref].x6Matrix[level].firstLevelReferrals[1] ==
                    referrerAddress)
            ) {
                if (
                    users[referrerAddress]
                        .x6Matrix[level]
                        .firstLevelReferrals
                        .length == 1
                ) {
                    emit NewUserPlace(userAddress, ref, 2, level, 5);
                } else {
                    emit NewUserPlace(userAddress, ref, 2, level, 6);
                }
            } else if (
                (len == 1 || len == 2) &&
                users[ref].x6Matrix[level].firstLevelReferrals[0] ==
                referrerAddress
            ) {
                if (
                    users[referrerAddress]
                        .x6Matrix[level]
                        .firstLevelReferrals
                        .length == 1
                ) {
                    emit NewUserPlace(userAddress, ref, 2, level, 3);
                } else {
                    emit NewUserPlace(userAddress, ref, 2, level, 4);
                }
            } else if (
                len == 2 &&
                users[ref].x6Matrix[level].firstLevelReferrals[1] ==
                referrerAddress
            ) {
                if (
                    users[referrerAddress]
                        .x6Matrix[level]
                        .firstLevelReferrals
                        .length == 1
                ) {
                    emit NewUserPlace(userAddress, ref, 2, level, 5);
                } else {
                    emit NewUserPlace(userAddress, ref, 2, level, 6);
                }
            }

            return updateX6ReferrerSecondLevel(userAddress, ref, level);
        }

        users[referrerAddress].x6Matrix[level].secondLevelReferrals.push(
            userAddress
        );

        if (users[referrerAddress].x6Matrix[level].closedPart != address(0)) {
            if (
                (users[referrerAddress].x6Matrix[level].firstLevelReferrals[
                    0
                ] ==
                    users[referrerAddress].x6Matrix[level].firstLevelReferrals[
                        1
                    ]) &&
                (users[referrerAddress].x6Matrix[level].firstLevelReferrals[
                    0
                ] == users[referrerAddress].x6Matrix[level].closedPart)
            ) {
                updateX6(userAddress, referrerAddress, level, true);
                return
                    updateX6ReferrerSecondLevel(
                        userAddress,
                        referrerAddress,
                        level
                    );
            } else if (
                users[referrerAddress].x6Matrix[level].firstLevelReferrals[0] ==
                users[referrerAddress].x6Matrix[level].closedPart
            ) {
                updateX6(userAddress, referrerAddress, level, true);
                return
                    updateX6ReferrerSecondLevel(
                        userAddress,
                        referrerAddress,
                        level
                    );
            } else {
                updateX6(userAddress, referrerAddress, level, false);
                return
                    updateX6ReferrerSecondLevel(
                        userAddress,
                        referrerAddress,
                        level
                    );
            }
        }

        if (
            users[referrerAddress].x6Matrix[level].firstLevelReferrals[1] ==
            userAddress
        ) {
            updateX6(userAddress, referrerAddress, level, false);
            return
                updateX6ReferrerSecondLevel(
                    userAddress,
                    referrerAddress,
                    level
                );
        } else if (
            users[referrerAddress].x6Matrix[level].firstLevelReferrals[0] ==
            userAddress
        ) {
            updateX6(userAddress, referrerAddress, level, true);
            return
                updateX6ReferrerSecondLevel(
                    userAddress,
                    referrerAddress,
                    level
                );
        }

        if (
            users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[0]]
                .x6Matrix[level]
                .firstLevelReferrals
                .length <=
            users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[1]]
                .x6Matrix[level]
                .firstLevelReferrals
                .length
        ) {
            updateX6(userAddress, referrerAddress, level, false);
        } else {
            updateX6(userAddress, referrerAddress, level, true);
        }

        updateX6ReferrerSecondLevel(userAddress, referrerAddress, level);
    }

    function updateX6(
        address userAddress,
        address referrerAddress,
        uint8 level,
        bool x2
    ) private {
        if (!x2) {
            users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[0]]
                .x6Matrix[level]
                .firstLevelReferrals
                .push(userAddress);
            emit NewUserPlace(
                userAddress,
                users[referrerAddress].x6Matrix[level].firstLevelReferrals[0],
                2,
                level,
                uint8(
                    users[
                        users[referrerAddress]
                            .x6Matrix[level]
                            .firstLevelReferrals[0]
                    ].x6Matrix[level].firstLevelReferrals.length
                )
            );
            emit NewUserPlace(
                userAddress,
                referrerAddress,
                2,
                level,
                2 +
                    uint8(
                        users[
                            users[referrerAddress]
                                .x6Matrix[level]
                                .firstLevelReferrals[0]
                        ].x6Matrix[level].firstLevelReferrals.length
                    )
            );
            //set current level
            users[userAddress].x6Matrix[level].currentReferrer = users[
                referrerAddress
            ].x6Matrix[level].firstLevelReferrals[0];
        } else {
            users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[1]]
                .x6Matrix[level]
                .firstLevelReferrals
                .push(userAddress);
            emit NewUserPlace(
                userAddress,
                users[referrerAddress].x6Matrix[level].firstLevelReferrals[1],
                2,
                level,
                uint8(
                    users[
                        users[referrerAddress]
                            .x6Matrix[level]
                            .firstLevelReferrals[1]
                    ].x6Matrix[level].firstLevelReferrals.length
                )
            );
            emit NewUserPlace(
                userAddress,
                referrerAddress,
                2,
                level,
                4 +
                    uint8(
                        users[
                            users[referrerAddress]
                                .x6Matrix[level]
                                .firstLevelReferrals[1]
                        ].x6Matrix[level].firstLevelReferrals.length
                    )
            );
            //set current level
            users[userAddress].x6Matrix[level].currentReferrer = users[
                referrerAddress
            ].x6Matrix[level].firstLevelReferrals[1];
        }
    }

    function updateX6ReferrerSecondLevel(
        address userAddress,
        address referrerAddress,
        uint8 level
    ) private {
        if (
            users[referrerAddress].x6Matrix[level].secondLevelReferrals.length <
            4
        ) {
            return sendETHDividends(referrerAddress, userAddress, 2, level);
        }

        address[] memory x6 = users[
            users[referrerAddress].x6Matrix[level].currentReferrer
        ].x6Matrix[level].firstLevelReferrals;

        if (x6.length == 2) {
            if (x6[0] == referrerAddress || x6[1] == referrerAddress) {
                users[users[referrerAddress].x6Matrix[level].currentReferrer]
                    .x6Matrix[level]
                    .closedPart = referrerAddress;
            } else if (x6.length == 1) {
                if (x6[0] == referrerAddress) {
                    users[
                        users[referrerAddress].x6Matrix[level].currentReferrer
                    ].x6Matrix[level].closedPart = referrerAddress;
                }
            }
        }

        users[referrerAddress]
            .x6Matrix[level]
            .firstLevelReferrals = new address[](0);
        users[referrerAddress]
            .x6Matrix[level]
            .secondLevelReferrals = new address[](0);
        users[referrerAddress].x6Matrix[level].closedPart = address(0);

        if (
            !users[referrerAddress].activeX6Levels[level + 1] &&
            level != LAST_LEVEL
        ) {
            users[referrerAddress].x6Matrix[level].blocked = true;
        }

        users[referrerAddress].x6Matrix[level].reinvestCount++;

        if (referrerAddress != owner) {
            address freeReferrerAddress = findFreeX6Referrer(
                referrerAddress,
                level
            );

            emit Reinvest(
                referrerAddress,
                freeReferrerAddress,
                userAddress,
                2,
                level
            );
            updateX6Referrer(referrerAddress, freeReferrerAddress, level);
        } else {
            emit Reinvest(owner, address(0), userAddress, 2, level);
            sendETHDividends(owner, userAddress, 2, level);
        }
    }

    function findFreeX3Referrer(address userAddress, uint8 level)
        public
        view
        returns (address)
    {
        while (true) {
            if (users[users[userAddress].referrer].activeX3Levels[level]) {
                return users[userAddress].referrer;
            }

            userAddress = users[userAddress].referrer;
        }
    }

    function findFreeX6Referrer(address userAddress, uint8 level)
        public
        view
        returns (address)
    {
        while (true) {
            if (users[users[userAddress].referrer].activeX6Levels[level]) {
                return users[userAddress].referrer;
            }

            userAddress = users[userAddress].referrer;
        }
    }

    function usersActiveX3Levels(address userAddress, uint8 level)
        public
        view
        returns (bool)
    {
        return users[userAddress].activeX3Levels[level];
    }

    function usersActiveX6Levels(address userAddress, uint8 level)
        public
        view
        returns (bool)
    {
        return users[userAddress].activeX6Levels[level];
    }

    function usersX3Matrix(address userAddress, uint8 level)
        public
        view
        returns (
            address,
            address[] memory,
            bool
        )
    {
        return (
            users[userAddress].x3Matrix[level].currentReferrer,
            users[userAddress].x3Matrix[level].referrals,
            users[userAddress].x3Matrix[level].blocked
        );
    }

    function usersX6Matrix(address userAddress, uint8 level)
        public
        view
        returns (
            address,
            address[] memory,
            address[] memory,
            bool,
            address
        )
    {
        return (
            users[userAddress].x6Matrix[level].currentReferrer,
            users[userAddress].x6Matrix[level].firstLevelReferrals,
            users[userAddress].x6Matrix[level].secondLevelReferrals,
            users[userAddress].x6Matrix[level].blocked,
            users[userAddress].x6Matrix[level].closedPart
        );
    }

    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }

    function findEthReceiver(
        address userAddress,
        address _from,
        uint8 matrix,
        uint8 level
    ) private returns (address, bool) {
        address receiver = userAddress;
        bool isExtraDividends;
        if (matrix == 1) {
            while (true) {
                if (users[receiver].x3Matrix[level].blocked) {
                    emit MissedEthReceive(receiver, _from, 1, level);
                    isExtraDividends = true;
                    receiver = users[receiver].x3Matrix[level].currentReferrer;
                } else {
                    return (receiver, isExtraDividends);
                }
            }
        } else {
            while (true) {
                if (users[receiver].x6Matrix[level].blocked) {
                    emit MissedEthReceive(receiver, _from, 2, level);
                    isExtraDividends = true;
                    receiver = users[receiver].x6Matrix[level].currentReferrer;
                } else {
                    return (receiver, isExtraDividends);
                }
            }
        }
    }

    function sendETHDividends(
        address userAddress,
        address _from,
        uint8 matrix,
        uint8 level
    ) private {
        (address receiver, bool isExtraDividends) = findEthReceiver(
            userAddress,
            _from,
            matrix,
            level
        );

        if (!address(uint160(receiver)).send(levelPrice[level])) {
            return address(uint160(receiver)).transfer(address(this).balance);
        }

        if (isExtraDividends) {
            emit SentExtraEthDividends(_from, receiver, matrix, level);
        }
    }

    function _refPayout(address _addr) private {
        address payable up = users[_addr].referrer;

        for (uint256 i = 0; i < 4; i++) {
            if (up == address(0)) {
                up = owner;
            }
            up.transfer(0.002 ether / 4);
            emit MatchPayout(up, _addr, 0.002 ether / 4);
            up = users[up].referrer;
        }
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
}
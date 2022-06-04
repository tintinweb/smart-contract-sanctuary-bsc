// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./IERC20.sol";
import "./FarmCore.sol";

contract Farm is Ownable, FarmCore {

    /**
     * @dev Enum variable type
     */
    enum Status{ ACTIVE, DONE }

    /**
     * @dev Struct variable type
     */
    struct Deposit {
        uint256 amountFirst;
        uint256 amountSecond;
        uint256 profit;
        uint256 startTime;
        uint256 farmPoolId;
        Status status; 
    }

    struct Withdrawal {
        uint256 depositId;
        uint256 amountFirst;
        uint256 amountSecond;
        uint256 date;
        Status status;
    }

    struct User {
        address referral;
        bool isBlocked;
        uint256 depositCount;
        uint256 withdrawCount;
        mapping(uint256 => Deposit) deposits;
        mapping(uint256 => Withdrawal) withdrawals;
    }

    /**
     * @dev Mapping data for quick access by index or address.
     */
    mapping(address => User) public users;

    address[] public usersList;

    /**
     * @dev Counters for mapped data. Used to store the length of the data.
     */
    uint256 public usersCount;

    /**
     * @dev All events. Used to track changes in the contract
     */
    event NewDeposit(address indexed user, uint256 amountFirst, uint256 amountSecond);
    event NewWithdraw(address indexed user, uint256 amountFirst, uint256 amountSecond);
    event UserBlocked(address indexed user);
    event UserUnblocked(address indexed user);
    event NewUser(address indexed user, address indexed referral);
    event DepositStatusChanged(address indexed user, uint256 depositId, Status status);
    event WithdrawStatusChanged(address indexed user, uint256 withdrawId, Status status);

    bool private itialized;

    /**
     * @dev Initial setup.
     */
    function initialize() external virtual {
        require(itialized != true, 'FarmContract: already initialized');
        itialized = true;
        initOwner(_msgSender());
        addAdmin(_msgSender());
    }

    /**
     * @dev Block user by address.
     *
     * NOTE: Can only be called by the admin address.
     */
    function blockUser(address _address) public onlyWhenServiceEnabled onlyAdmin {
        users[_address].isBlocked = true;
        emit UserBlocked(_address);
    }

    /**
     * @dev Unblock user by address.
     *
     * NOTE: Can only be called by the admin address.
     */
    function unblockUser(address _address) public onlyWhenServiceEnabled onlyAdmin {
        users[_address].isBlocked = false;
        emit UserUnblocked(_address);
    }

    /**
     * @dev Create new (`User`) object by address.
     *
     * Emits a {NewUser} event.
     *
     * NOTE: Only internal call.
     */
    function createNewUser(address _referral) private {
        users[_msgSender()].referral = _referral;
        users[_msgSender()].isBlocked = false;
        users[_msgSender()].depositCount = 0;
        users[_msgSender()].withdrawCount = 0;

        usersList.push(_msgSender());
        usersCount++;

        emit NewUser(_msgSender(), _referral);
    }

    /**
     * @dev To call this method, certain conditions are required, as described below:
     * 
     * Checks if user isn't blocked;
     * Checks if (`_amount`) is greater than zero;
     * Checks if farm service exists and has active status;
     * Checks if token exists and has active status;
     * Checks if contact has required amount of token for transfer from current caller;
     *
     * Transfers the amount of tokens to the current contract.
     * 
     * If its called by new address then new user will be created.
     * 
     * Creates new object of (`Deposit`) struct.
     *
     * Emits a {NewDeposit} event.
     */
    function deposit(
        uint256 _amountFirst,
        uint256 _amountSecond,
        address _referral,
        uint256 _farmServiceId,
        uint256 _farmPoolId
    ) public onlyWhenServiceEnabled {

        require(users[_msgSender()].isBlocked == false, "FarmContract: User blocked");
        require(_amountFirst > 0 || _amountSecond > 0, "FarmContract: Zero amount");
        require(farmServices[_farmServiceId].isActive, "FarmContract: No active farm service");
        require(farmPools[_farmPoolId].isActive, "FarmContract: No active farmPools");

        if (_amountFirst > 0 ) {
            IERC20 firstToken = farmPairs[farmPools[_farmPoolId].farmPairId].firstToken;
            uint256 firstAllowance = firstToken.allowance(_msgSender(), address(this));
            require(firstAllowance >= _amountFirst, "FarmContract: Recheck the token allowance");
            (bool firstSent) = firstToken.transferFrom(_msgSender(), farmPools[_farmPoolId].depositAddress, _amountFirst);
            require(firstSent, "FarmContract: Failed to send tokens");
        }

        if (_amountSecond > 0 ) {
            IERC20 secondToken = farmPairs[farmPools[_farmPoolId].farmPairId].secondToken;
            uint256 secondAllowance = secondToken.allowance(_msgSender(), address(this));
            require(secondAllowance >= _amountFirst, "FarmContract: Recheck the token allowance");
            (bool secondSent) = secondToken.transferFrom(_msgSender(), farmPools[_farmPoolId].depositAddress, _amountFirst);
            require(secondSent, "FarmContract: Failed to send tokens");
        }

        uint256 depositCount = users[_msgSender()].depositCount;
        
        if (depositCount <= 0) {
            createNewUser(_referral);
            users[_msgSender()].deposits[users[_msgSender()].depositCount] = Deposit(_amountFirst, _amountSecond, 0, block.timestamp, _farmPoolId, Status.ACTIVE);
            users[_msgSender()].depositCount += 1;
        } else {
            for (uint i = 0; i <= depositCount - 1; i++) {
                if (users[_msgSender()].deposits[i].farmPoolId == _farmPoolId && users[_msgSender()].deposits[i].status == Status.ACTIVE) {
                    users[_msgSender()].deposits[i].amountFirst += _amountFirst > 0 ? _amountFirst : 0;
                    users[_msgSender()].deposits[i].amountSecond += _amountSecond > 0 ? _amountSecond : 0;
                }
            }
        }

        emit NewDeposit(_msgSender(), _amountFirst, _amountSecond);
    }

    /**
     * @dev To call this method, certain conditions are required, as described below:
     * 
     * Checks if user isn't blocked;
     * Checks if user (`Deposit`) has ACTIVE status;
     * Checks if requested amount is less or equal deposit balance;
     *
     * Creates new object of (`Withdrawal`) struct with status CREATED.
     *
     * Emits a {NewDeposit} event.
     */
    function withdraw(
        uint256 _depositId,
        uint256 _amountFirst,
        uint256 _amountSecond
    ) public onlyWhenServiceEnabled {

        require(users[_msgSender()].isBlocked == false, "FarmContract: User blocked");
        Deposit storage userDeposit = users[_msgSender()].deposits[_depositId];
        require(userDeposit.status == Status.ACTIVE, "FarmContract: Deposit has not active status");
        require(_amountFirst > 0 || _amountSecond > 0, "FarmContract: Zero amount");

        if (_amountFirst > 0) {
            require(_amountFirst <= userDeposit.amountFirst, "FarmContract: Insufficient funds");
        }

        if (_amountSecond > 0) {
            require(_amountSecond <= userDeposit.amountSecond, "FarmContract: Insufficient funds");
        }
        
        uint256 newWithdrawalId = users[_msgSender()].withdrawCount;
        
        users[_msgSender()].deposits[_depositId].amountFirst -= _amountFirst > 0 ? _amountFirst : 0;
        users[_msgSender()].deposits[_depositId].amountSecond -= _amountSecond > 0 ? _amountSecond : 0;

        users[_msgSender()].withdrawals[newWithdrawalId] = Withdrawal(_depositId, _amountFirst, _amountSecond, block.timestamp, Status.ACTIVE);
        users[_msgSender()].withdrawCount += 1;

        emit NewWithdraw(_msgSender(), _amountFirst, _amountSecond);
    }

    /**
     * @dev Returns the user (`Deposit`) object.
     */
    function getUserDeposit(
        address _userAddress,
        uint256 _depositId
    ) public view returns (Deposit memory) {
        return users[_userAddress].deposits[_depositId];
    }

    /**
     * @dev Returns the user (`Withdrawal`) object.
     */
    function getUserWithdraw(
        address _userAddress,
        uint256 _withdrawId
    ) public view returns (Withdrawal memory) {
        return users[_userAddress].withdrawals[_withdrawId];
    }
}
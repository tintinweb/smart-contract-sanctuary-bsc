// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./IERC20.sol";
import "./FarmCore.sol";

contract Farm is Ownable, FarmCore {

    /**
     * @dev Struct variable type
     */
    struct Deposit {
        uint256 amountFirst;
        uint256 amountSecond;
    }

    struct Withdrawal {
        uint256 farmPoolId;
        uint256 amountFirst;
        uint256 amountSecond;
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

    /**
     * @dev All events. Used to track changes in the contract
     */
    event NewDeposit(address indexed user, uint256 amountFirst, uint256 amountSecond);
    event NewWithdraw(address indexed user, uint256 amountFirst, uint256 amountSecond, uint256 farmPoolId);
    event UserBlocked(address indexed user);
    event UserUnblocked(address indexed user);
    event NewUser(address indexed user, address indexed referral);

    bool private itialized;

    /**
     * @dev Initial setup.
     */
    function initialize() external virtual {
        require(itialized != true, 'FarmContract: already initialized');
        itialized = true;
        initOwner(_msgSender());
        addAdmin(_msgSender());
        MINTVL = 50000000000000000000000;
        CAPY = 2000000000000000000;
        MINAPY = 2000000000000000000;
        servicePercent = 1000000000000000000;
    }

    /**
     * @dev Block user by address.
     *
     * NOTE: Can only be called by the admin address.
     */
    function blockUser(address _address) external onlyWhenServiceEnabled onlyAdmin {
        users[_address].isBlocked = true;
        emit UserBlocked(_address);
    }

    /**
     * @dev Unblock user by address.
     *
     * NOTE: Can only be called by the admin address.
     */
    function unblockUser(address _address) external onlyWhenServiceEnabled onlyAdmin {
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

        emit NewUser(_msgSender(), _referral);
    }

    /**
     * @dev To call this method, certain conditions are required, as described below:
     * 
     * Checks if user isn't blocked;
     * Checks if (`_amount`) is greater than zero;
     * Checks if contact has required amount of token for transfer from current caller;
     * Checks if farm pool is not moving;
     *
     * Transfers the amount of tokens to the current deposit pool.
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
        uint256 _farmPoolId,
        address _referral
    ) external onlyWhenServiceEnabled {

        require(users[_msgSender()].isBlocked == false, "FarmContract: User blocked");
        require(_amountFirst > 0 || _amountSecond > 0, "FarmContract: Zero amount");
        require(farmPools[_farmPoolId].isActive, "FarmContract: No active Farm Pools");
        require(farmPools[_farmPoolId].isFarmMoving == false, "FarmContract: Farm pool is moving");

        if (_amountFirst > 0 ) {
            _transferTokens(
                farmPools[_farmPoolId].firstToken,
                farmPools[_farmPoolId].depositAddress,
                _amountFirst
            );
        }

        if (_amountSecond > 0 ) {
            _transferTokens(
                farmPools[_farmPoolId].secondToken,
                farmPools[_farmPoolId].depositAddress,
                _amountSecond
            );
        }

        if (users[_msgSender()].depositCount == 0) {
            createNewUser(_referral);
        }

        users[_msgSender()].deposits[_farmPoolId].amountFirst += _amountFirst > 0 ? _amountFirst : 0;
        users[_msgSender()].deposits[_farmPoolId].amountSecond += _amountSecond > 0 ? _amountSecond : 0;
        users[_msgSender()].depositCount += 1;

        emit NewDeposit(_msgSender(), _amountFirst, _amountSecond);
    }

    /**
     * @dev Transfers tokens to deposit address.
     * Internal function without access restriction.
     */
    function _transferTokens(IERC20 _token, address _depositAddress, uint256 _amount) internal virtual {
        uint256 allowance = _token.allowance(_msgSender(), address(this));
        require(allowance >= _amount, "FarmContract: Recheck the token allowance");
        (bool sent) = _token.transferFrom(_msgSender(), _depositAddress, _amount);
        require(sent, "FarmContract: Failed to send tokens");
    }

    /**
     * @dev To call this method, certain conditions are required, as described below:
     * 
     * Checks if user isn't blocked;
     *
     * Creates new object of (`Withdrawal`) struct.
     *
     * If its called by new address then new user will be created.
     *
     * Emits a {NewWithdraw} event.
     */
    function withdraw(
        uint256 _farmPoolId,
        uint256 _amountFirst,
        uint256 _amountSecond,
        address _referral
    ) external onlyWhenServiceEnabled {

        require(users[_msgSender()].isBlocked == false, "FarmContract: User blocked");
        require(_amountFirst > 0 || _amountSecond > 0, "FarmContract: Zero amount");
        require(farmPools[_farmPoolId].isFarmMoving == false, "FarmContract: Farm pool is moving");

        if (users[_msgSender()].withdrawCount == 0 && users[_msgSender()].depositCount == 0) {
            createNewUser(_referral);
        }
        
        users[_msgSender()].withdrawals[users[_msgSender()].withdrawCount] = Withdrawal(_farmPoolId, _amountFirst, _amountSecond);
        users[_msgSender()].withdrawCount += 1;

        emit NewWithdraw(_msgSender(), _amountFirst, _amountSecond, _farmPoolId);
    }

    /**
     * @dev Returns the user (`Deposit`) object.
     */
    function getUserDeposit(
        address _userAddress,
        uint256 _farmPoolId
    ) external view returns (Deposit memory) {
        return users[_userAddress].deposits[_farmPoolId];
    }

    /**
     * @dev Returns the user (`Withdrawal`) object.
     */
    function getUserWithdraw(
        address _userAddress,
        uint256 _withdrawId
    ) external view returns (Withdrawal memory) {
        return users[_userAddress].withdrawals[_withdrawId];
    }
}
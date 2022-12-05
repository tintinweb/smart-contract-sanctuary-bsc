/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

pragma solidity >=0.4.23 <0.6.0;
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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
}

contract GeniosClub {
    struct User {
        uint id;
        address referrer;
        uint partnersCount;
        mapping(uint8 => bool) activeX12Levels;
        mapping(uint8 => X12) x12Matrix;    
    }
    struct X12 {
        address currentReferrer;
        address[] firstLevelReferrals;
        address[] secondLevelReferrals;
        bool blocked;
        uint reinvestCount;
    }
    mapping(uint8 => uint) public levelPrice;
    uint8 public constant LAST_LEVEL = 9;
    IERC20 public tokenDAI;
    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;
    uint public lastUserId = 2;
    address public id1;
    
    event Registration(address indexed user, address indexed referrer, uint indexed userId, uint referrerId);
    event Reinvest(address indexed user, address indexed currentReferrer, address indexed caller, uint8 matrix, uint8 level);
    event Upgrade(address indexed user, address indexed referrer, uint8 matrix, uint8 level);
    event NewUserPlace(address indexed user, address indexed referrer, uint8 matrix, uint8 level, uint8 place);
    event MissedEthReceive(address indexed receiver, address indexed from, uint8 matrix, uint8 level);
    event SentExtraEthDividends(address indexed from, address indexed receiver, uint8 matrix, uint8 level);
    
    constructor(address _token) public {
        levelPrice[1] = 5e18;
        levelPrice[2] = 20e18;
        levelPrice[3] = 65e18;
        levelPrice[4] = 250e18;
        levelPrice[5] = 900e18;
        levelPrice[6] = 3500e18;
        levelPrice[7] = 12000e18;
        levelPrice[8] = 50000e18;
        levelPrice[9] = 135000e18;

        id1 = msg.sender;
        tokenDAI = IERC20(_token);        
        User memory user = User({
            id: 1,
            referrer: address(0),
            partnersCount: uint(0)
        });
        users[id1] = user;
        idToAddress[1] = id1;
        for (uint8 i = 1; i <= LAST_LEVEL; i++) { 
            users[id1].activeX12Levels[i] = true;     
        }  
    }
    function registrationExt(address referrerAddress) external {
        tokenDAI.transferFrom(msg.sender, address(this), levelPrice[1]);
        registration(msg.sender, referrerAddress);
    }
    function buyNewLevel(uint8 level) external {
         _buyNewLevel(msg.sender, level);
    }
    function registration(address userAddress, address referrerAddress) private {
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");

        User memory user = User({
            id: lastUserId,
            referrer: referrerAddress,
            partnersCount: uint(0)
        });
        
        users[userAddress] = user;
        idToAddress[lastUserId] = userAddress;
        users[userAddress].referrer = referrerAddress;
        lastUserId++;
        users[referrerAddress].partnersCount++;
        users[userAddress].activeX12Levels[1] = true;
        address freeX12Referrer = findFreeX12Referrer(userAddress, 1);
        updateX12Referrer(userAddress, freeX12Referrer, 1);
        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);
    }
    function _buyNewLevel(address _userAddress, uint8 level) internal {
        require(isUserExists(_userAddress), "user is not exists. Register first.");
        tokenDAI.transferFrom(msg.sender, address(this), levelPrice[level]);
        require(!users[_userAddress].activeX12Levels[level], "level already activated"); 
        require(level > 1 && level <= LAST_LEVEL, "invalid level");
        require(users[_userAddress].activeX12Levels[level-1], "buy previous level first");                
        if (users[_userAddress].x12Matrix[level-1].blocked) {
            users[_userAddress].x12Matrix[level-1].blocked = false;
        }
        users[_userAddress].activeX12Levels[level] = true;
        address freeX12Referrer = findFreeX12Referrer(_userAddress, level);        
        updateX12Referrer(_userAddress, freeX12Referrer, level);
        emit Upgrade(_userAddress, freeX12Referrer, 2, level);    
    }
    function updateX12Referrer(address userAddress, address referrerAddress, uint8 level) private {
        require(users[referrerAddress].activeX12Levels[level], "500. Referrer level is inactive");
        
        if (users[referrerAddress].x12Matrix[level].firstLevelReferrals.length < 3) {
            users[referrerAddress].x12Matrix[level].firstLevelReferrals.push(userAddress);
            emit NewUserPlace(userAddress, referrerAddress, 2, level, uint8(users[referrerAddress].x12Matrix[level].firstLevelReferrals.length));
            
            //set current level
            users[userAddress].x12Matrix[level].currentReferrer = referrerAddress;

            if (referrerAddress == id1) {
                return sendETHDividends(referrerAddress, userAddress, 2, level);
            }
            
            address ref = users[referrerAddress].x12Matrix[level].currentReferrer;            
            users[ref].x12Matrix[level].secondLevelReferrals.push(userAddress); 
            
            uint len = users[ref].x12Matrix[level].firstLevelReferrals.length;
            
            if ((len == 3) && (users[ref].x12Matrix[level].firstLevelReferrals[2] == referrerAddress)) {
                emit NewUserPlace(userAddress, ref, 2, level, 9+uint8(users[referrerAddress].x12Matrix[level].firstLevelReferrals.length));                
            } else if ((len == 3 || len == 2) && (users[ref].x12Matrix[level].firstLevelReferrals[1] == referrerAddress)) {
                emit NewUserPlace(userAddress, ref, 2, level, 6+uint8(users[referrerAddress].x12Matrix[level].firstLevelReferrals.length));
            } else if ((len == 3 || len == 2 || len == 1) && (users[ref].x12Matrix[level].firstLevelReferrals[0] == referrerAddress)) {
                emit NewUserPlace(userAddress, ref, 2, level, 3+uint8(users[referrerAddress].x12Matrix[level].firstLevelReferrals.length));
            }
            return updateX12ReferrerSecondLevel(userAddress, ref, level);
        }
        
        users[referrerAddress].x12Matrix[level].secondLevelReferrals.push(userAddress);        
        
        if ((users[users[referrerAddress].x12Matrix[level].firstLevelReferrals[0]].x12Matrix[level].firstLevelReferrals.length <= 
            users[users[referrerAddress].x12Matrix[level].firstLevelReferrals[1]].x12Matrix[level].firstLevelReferrals.length) && 
            (users[users[referrerAddress].x12Matrix[level].firstLevelReferrals[1]].x12Matrix[level].firstLevelReferrals.length <= 
            users[users[referrerAddress].x12Matrix[level].firstLevelReferrals[2]].x12Matrix[level].firstLevelReferrals.length)) {
            updateX12(userAddress, referrerAddress, level, 0);
        } else if (users[users[referrerAddress].x12Matrix[level].firstLevelReferrals[1]].x12Matrix[level].firstLevelReferrals.length <= 
            users[users[referrerAddress].x12Matrix[level].firstLevelReferrals[2]].x12Matrix[level].firstLevelReferrals.length) {
            updateX12(userAddress, referrerAddress, level, 1);
        } else {
            updateX12(userAddress, referrerAddress, level, 2);
        }        
        updateX12ReferrerSecondLevel(userAddress, referrerAddress, level);
    }

    function updateX12(address userAddress, address referrerAddress, uint8 level, int x2) private {
        if (x2==0) {
            users[users[referrerAddress].x12Matrix[level].firstLevelReferrals[0]].x12Matrix[level].firstLevelReferrals.push(userAddress);
            emit NewUserPlace(userAddress, users[referrerAddress].x12Matrix[level].firstLevelReferrals[0], 2, level, uint8(users[users[referrerAddress].x12Matrix[level].firstLevelReferrals[0]].x12Matrix[level].firstLevelReferrals.length));
            emit NewUserPlace(userAddress, referrerAddress, 2, level, 3 + uint8(users[users[referrerAddress].x12Matrix[level].firstLevelReferrals[0]].x12Matrix[level].firstLevelReferrals.length));
            //set current level
            users[userAddress].x12Matrix[level].currentReferrer = users[referrerAddress].x12Matrix[level].firstLevelReferrals[0];
        } else if (x2==1) {
            users[users[referrerAddress].x12Matrix[level].firstLevelReferrals[1]].x12Matrix[level].firstLevelReferrals.push(userAddress);
            emit NewUserPlace(userAddress, users[referrerAddress].x12Matrix[level].firstLevelReferrals[1], 2, level, uint8(users[users[referrerAddress].x12Matrix[level].firstLevelReferrals[1]].x12Matrix[level].firstLevelReferrals.length));
            emit NewUserPlace(userAddress, referrerAddress, 2, level, 6 + uint8(users[users[referrerAddress].x12Matrix[level].firstLevelReferrals[1]].x12Matrix[level].firstLevelReferrals.length));
            //set current level
            users[userAddress].x12Matrix[level].currentReferrer = users[referrerAddress].x12Matrix[level].firstLevelReferrals[1];
        } else {
            users[users[referrerAddress].x12Matrix[level].firstLevelReferrals[2]].x12Matrix[level].firstLevelReferrals.push(userAddress);
            emit NewUserPlace(userAddress, users[referrerAddress].x12Matrix[level].firstLevelReferrals[2], 2, level, uint8(users[users[referrerAddress].x12Matrix[level].firstLevelReferrals[2]].x12Matrix[level].firstLevelReferrals.length));
            emit NewUserPlace(userAddress, referrerAddress, 2, level, 9 + uint8(users[users[referrerAddress].x12Matrix[level].firstLevelReferrals[2]].x12Matrix[level].firstLevelReferrals.length));
            //set current level
            users[userAddress].x12Matrix[level].currentReferrer = users[referrerAddress].x12Matrix[level].firstLevelReferrals[2];
        }
    }
    
    function updateX12ReferrerSecondLevel(address userAddress, address referrerAddress, uint8 level) private {
        if (users[referrerAddress].x12Matrix[level].secondLevelReferrals.length < 9) {
            return sendETHDividends(referrerAddress, userAddress, 2, level);
        }        
        
        
        users[referrerAddress].x12Matrix[level].firstLevelReferrals = new address[](0);
        users[referrerAddress].x12Matrix[level].secondLevelReferrals = new address[](0);

        if (!users[referrerAddress].activeX12Levels[level+1] && level != LAST_LEVEL) {
            users[referrerAddress].x12Matrix[level].blocked = true;
        }
        users[referrerAddress].x12Matrix[level].reinvestCount++;        
        if (referrerAddress != id1) {
            address freeReferrerAddress = findFreeX12Referrer(referrerAddress, level);

            emit Reinvest(referrerAddress, freeReferrerAddress, userAddress, 2, level);
            updateX12Referrer(referrerAddress, freeReferrerAddress, level);
        } else {
            emit Reinvest(id1, address(0), userAddress, 2, level);
            sendETHDividends(id1, userAddress, 2, level);
        }
    }
    function findFreeX12Referrer(address userAddress, uint8 level) public view returns(address) {
        while (true) {
            if (users[users[userAddress].referrer].activeX12Levels[level]) {
                return users[userAddress].referrer;
            }            
            userAddress = users[userAddress].referrer;
        }
    }
    function sendETHDividends(address userAddress, address _from, uint8 matrix, uint8 level) private {
        (address receiver, bool isExtraDividends) = findEthReceiver(userAddress, _from, level);
        tokenDAI.transfer(receiver, levelPrice[level]);      
        if (isExtraDividends) {
            emit SentExtraEthDividends(_from, receiver, matrix, level);
        }
    }  
    function findEthReceiver(address userAddress, address _from, uint8 level) private returns(address, bool) {
        address receiver = userAddress;
        bool isExtraDividends;
        while (true) {
            if (users[receiver].x12Matrix[level].blocked) {
                emit MissedEthReceive(receiver, _from, 2, level);
                isExtraDividends = true;
                receiver = users[receiver].x12Matrix[level].currentReferrer;
            } else {
                return (receiver, isExtraDividends);
            }
        }
    }  
    function usersActiveX12Levels(address userAddress, uint8 level) public view returns(bool) {
        return users[userAddress].activeX12Levels[level];
    }
    function usersX12Matrix(address userAddress, uint8 level) public view returns(address, address[] memory, address[] memory, bool) {
        return (users[userAddress].x12Matrix[level].currentReferrer,
                users[userAddress].x12Matrix[level].firstLevelReferrals,
                users[userAddress].x12Matrix[level].secondLevelReferrals,
                users[userAddress].x12Matrix[level].blocked);
    }
    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }
}
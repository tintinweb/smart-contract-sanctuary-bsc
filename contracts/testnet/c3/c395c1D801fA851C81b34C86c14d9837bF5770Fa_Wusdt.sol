/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
    address sender,
    address recipient,
    uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Wusdt  {

    struct User {
        uint256 id;
        address referrer;
        uint256 partnersCount;
        mapping(uint8 => bool) activeX2Levels;
        mapping(uint8 => mapping(uint8 => bool)) activeX3Levels;
        mapping(uint8 => X2) x2Matrix;
        uint directIncome;
        
    }

    struct X2 {
        address currentReferrer;
        address[] referrals;
    }


    uint8 public LAST_LEVEL;

    mapping(address => User) public users;
    mapping(uint256 => address) public idToAddress;
    uint[6] public levelShare ; 

    uint256 public lastUserId;

    mapping(uint8 => uint256) public levelPrice;
    mapping(uint8 => mapping(uint8 => uint256)) public matrixPrice;
    IERC20 private busdToken;
    address public owner;

    // mapping(uint8 => mapping(uint8 => mapping(uint256 => address))) public x3vId_number;
    // mapping(uint8 => mapping(uint8 => uint256)) public x3CurrentvId;
    // mapping(uint8 => mapping(uint8 => uint256)) public x3Index;

    event Registration(
        address indexed user,
        address indexed referrer,
        uint256 indexed userId,
        uint256 referrerId
    );

    event Upgrade(address indexed user, uint8 level);
    event NewUserPlace(
        address indexed user,
        address indexed referrer,
        uint8 level,
        uint8 place
    );

    event UserIncome(
        address sender,
        address receiver,
        uint256 amount,
        uint8 level,
        string _for
    );

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    receive() payable external{}

    function initialize(address _ownerAddress) public  {
        //default value
        LAST_LEVEL = 12;
        lastUserId = 2;
        owner = _ownerAddress;

        // busdToken = _busdAddress;

        levelPrice[1] = 5 * 1e18;
        levelPrice[2] = 10 * 1e18;
        levelPrice[3] = 20 * 1e18;
        levelPrice[4] = 40 * 1e18;
        levelPrice[5] = 80 * 1e18;
        levelPrice[6] = 160 * 1e18;
        levelPrice[7] = 320 * 1e18;
        levelPrice[8] = 640 * 1e18;
        levelPrice[9] = 1280 * 1e18;
        levelPrice[10] = 2560 * 1e18;
        levelPrice[11] = 5120 * 1e18;
        levelPrice[12] = 10240 * 1e18;

        levelShare =[40,10,4,3,2,1];

        users[owner].id = 1;
        users[owner].referrer = address(0);
        users[owner].partnersCount = uint256(0);

        idToAddress[1] = owner;

        for (uint8 i = 1; i <= LAST_LEVEL; i++) {
            users[owner].activeX2Levels[i] = true;
        }


        emit Registration(owner, address(0), users[owner].id, 0);
        emit Upgrade(owner, 1);
    }

    function registrationExt(address referrerAddress) external payable {
        registration(msg.sender, referrerAddress);
    }

    function registration(address userAddress, address referrerAddress) private {
        // require(busdToken.balanceOf(userAddress) >= (levelPrice[1]),"Low Balance");
        // require(busdToken.allowance(userAddress, address(this)) >= levelPrice[1],Invalid allowance amount");

        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "Referrer not exists");
        uint32 size;

        assembly {
            size := extcodesize(userAddress)
        }

        require(size == 0, "cannot be a contract");

        idToAddress[lastUserId] = userAddress;

        users[userAddress].id = lastUserId;
        users[userAddress].referrer = referrerAddress;
        users[userAddress].partnersCount = 0;
        users[userAddress].activeX2Levels[1] = true;
        lastUserId++;
        users[referrerAddress].partnersCount++;

        // busdToken.transferFrom(userAddress, address(this), levelPrice[1]);
        // busdToken.transfer(referrerAddress, (levelPrice[1]*10)/100);

        emit UserIncome(userAddress,referrerAddress,(levelPrice[1]*10)/100,1,"direct");
        users[referrerAddress].directIncome += (levelPrice[1]*10)/100;
        address freeX2Referrer = findFreeReferrer(referrerAddress, 1);
        users[userAddress].x2Matrix[1].currentReferrer = freeX2Referrer;
        updateX2Referrer(userAddress, freeX2Referrer, 1);

        emit Registration(userAddress,referrerAddress,users[userAddress].id,users[referrerAddress].id);
        emit Upgrade(userAddress, 1);
    }

    function updateX2Referrer(address userAddress, address referrerAddress, uint8 level ) private {
        if (userAddress == referrerAddress) return;
        require(level <= 6, "not valid level");
        require(referrerAddress != address(0) && userAddress != address(0),"zero id");
        require(users[userAddress].activeX2Levels[level],"User Level not activated");
        if(users[referrerAddress].x2Matrix[level].referrals.length!=2) {
            users[referrerAddress].x2Matrix[level].referrals.push(userAddress);
            // busdToken.transfer(referrerAddress, levelPrice[level].mul(levelShare[level-1]).div(100));
            emit UserIncome(userAddress, referrerAddress, (levelPrice[level]*levelShare[level-1])/100, level, "level");
        }

        emit NewUserPlace(userAddress,referrerAddress,level,uint8(users[referrerAddress].x2Matrix[level].referrals.length));
    }

    function UpgradeLevel(address _user, uint8 level) external payable {
        require(level <= 12, "Invalid level!");
        require(isUserExists(_user),"User not Exist!");
        require(!users[_user].activeX2Levels[level], "Level already upgraded!");
        // require(busdToken.allowance(_user, address(this)) >= levelPrice[level],"Invalid Upgradation amount");
        // require(busdToken.balanceOf(_user) >= levelPrice[level], "Low Balance");

        users[_user].activeX2Levels[level] = true;
        // busdToken.transferFrom(_user, address(this), levelPrice[level]);

        address referrerAddress = _user;
        for (uint8 i = 1; i <= level; i++) {
            if (referrerAddress != address(0))
                referrerAddress = users[referrerAddress].x2Matrix[1].currentReferrer;
            else break;
        }
        if (referrerAddress != address(0))
        updateX2Referrer(_user, referrerAddress, level);
        busdToken.transfer(users[_user].referrer,(levelPrice[level]*50)/100);
        emit UserIncome(_user, users[_user].referrer,(levelPrice[level]*10)/100,level,"direct");
        users[referrerAddress].directIncome += (levelPrice[level]*10)/100;

        emit Upgrade(_user, level);
    }


    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }

    function findFreeReferrer(address _user, uint8 level) public view returns (address) {
        if (users[_user].x2Matrix[level].referrals.length < 2) return _user;

        address[] memory referrals = new address[](1022);
        referrals[0] = users[_user].x2Matrix[level].referrals[0];
        referrals[1] = users[_user].x2Matrix[level].referrals[1];

        address freeReferrer;
        bool noFreeReferrer = true;

        for (uint256 i = 0; i < 1022; i++) {
        if (users[referrals[i]].x2Matrix[level].referrals.length == 2) {
            if (i < 62) {
                referrals[(i + 1) * 2] = users[referrals[i]]
                .x2Matrix[level]
                .referrals[0];
                referrals[(i + 1) * 2 + 1] = users[referrals[i]]
                .x2Matrix[level]
                .referrals[1];
            }
        } else {
                noFreeReferrer = false;
                freeReferrer = referrals[i];
                break;
            }
        }

        require(!noFreeReferrer, "No Free Referrer");

        return freeReferrer;
    }

    function usersActiveX2Levels(address userAddress, uint8 level) public view returns (bool) {
        return users[userAddress].activeX2Levels[level];
    }

    function usersX2Matrix(address userAddress, uint8 level) public view returns (address currentRef, address[] memory refferals) {
        currentRef = users[userAddress].x2Matrix[level].currentReferrer;
        refferals = users[userAddress].x2Matrix[level].referrals;
    }

    function withdrawETH(uint256 amt, address payable adr) public payable onlyOwner {
        adr.transfer(amt);
    }

    function withdrawToken( IERC20 _token, uint256 amt, address payable adr ) public payable onlyOwner {
        _token.transfer(adr, amt);
    }
}
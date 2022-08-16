// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./modules/Permission.sol";

contract FiveElements is Permission {

    IERC20 public usdtContract = IERC20(0x1A2a1eb97bEE6e7e786956794576fc82b866b0C2);

    uint public ticketPrice = 1000 ether;
    address public clubAddress = 0x89C61778241904C71DeF6A73C4E0115A7765398f;
    address public oneAddress = 0x89C61778241904C71DeF6A73C4E0115A7765398f;
    address public twoAddress = 0x89C61778241904C71DeF6A73C4E0115A7765398f;
     
    event Buy(
        address buyer,
        bytes32 ticketHash,
        uint winBonus,
        uint time
    );

    struct Order {
        uint orderTime;
        bytes32 orderHash;
        bool isWin;
    }

    mapping(uint8 => address[]) public fiveCamps;
    uint8 public isEnd = 1;
    uint8 public lastCamp;
    uint public endTime;
    uint public startTime;
    uint public addTime = 10;
    uint public pool;

    uint public campBouns;
    uint public onlyBouns;
    uint public seatBouns;

    mapping(address => mapping(uint8 => uint32)) public campQuantity;
    mapping(address => uint) public bouns;
    mapping(address => Order[]) public orderList;
    mapping(address => uint) public dividendBouns;

    receive() external payable {}
    
    function getFrontAddress() public view returns(address){
        return fiveCamps[0][(fiveCamps[0].length - 1) / 2];
    }

    function getCampQuantity(address sender, uint8 camp) public view returns(uint32){
        return campQuantity[sender][camp];
    }

    function getCampAmount(uint8 camp) public view returns(uint){
        return fiveCamps[camp].length;
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function getAllComps(uint8 _comps) public view returns (address[] memory){
        address[] memory playerList = new address[](fiveCamps[_comps].length);
        for(uint i = 0; i < fiveCamps[_comps].length; i++){
            playerList[i] = fiveCamps[_comps][i];
        }
        return playerList;
    }

    function getAllOrderList(address _sender) public view returns (Order[] memory){
        Order[] memory newOrderList = new Order[](orderList[_sender].length);
        for(uint i = 0; i < orderList[_sender].length; i++){
            newOrderList[i] = orderList[_sender][i];
        }
        return newOrderList;
    }

    function getAllQuantity(address addr) public view returns(uint32){
        return (campQuantity[addr][1] + campQuantity[addr][2] + campQuantity[addr][3] + campQuantity[addr][4] + campQuantity[addr][5]);
    }

    function buyTicket(uint8 camp, uint32 amount) public {
        require(amount < 1001, "Amount is too many");
        require(!isContract(msg.sender), "It is contracts");
        require(endTime > block.timestamp && startTime <= block.timestamp, "The game is end or not start");
        require(camp > 0 && camp < 6,"The camp is not exist");
        require(usdtContract.balanceOf(msg.sender) >= amount * ticketPrice,"Your coin is not enough");
        usdtContract.transferFrom(
            msg.sender,
            address(this),
            amount * ticketPrice
        );
        lastCamp = camp;
        _buyTicket(camp, amount);
        luckFive();
    }

    function buyTicketRecommender(uint8 camp, uint32 amount, address recommender) public {
        require(amount < 1001, "Amount is too many");
        require(!isContract(msg.sender), "It is contracts");
        require(endTime > block.timestamp && startTime <= block.timestamp, "The game is end or not start");
        require(camp > 0 && camp < 6,"The camp is not exist");
        require(usdtContract.balanceOf(msg.sender) >= amount * ticketPrice,"Your coin is not enough");
        usdtContract.transferFrom(
            msg.sender,
            address(this),
            amount * ticketPrice
        );
        lastCamp = camp;
        _buyTicketRecommender(camp, amount, recommender);
        luckFive();
    }

    function _buyTicket(uint8 camp, uint32 amount) private {
        if(endTime + addTime > block.timestamp + 180){
            endTime = block.timestamp + 180;
        }else{
            endTime = endTime + addTime;
        }
        for(uint32 i = 0; i < amount; i++){
            allocation();
            fiveCamps[camp].push(msg.sender);
            fiveCamps[0].push(msg.sender); 
        }
        campQuantity[msg.sender][camp] = campQuantity[msg.sender][camp] + amount;
    }

    function _buyTicketRecommender(uint8 camp, uint32 amount, address recommender) private {
        if(endTime + addTime > block.timestamp + 180){
            endTime = block.timestamp + 180;
        }else{
            endTime = endTime + addTime;
        }
        for(uint32 i = 0; i < amount; i++){
            allocationRecommender(recommender);
            fiveCamps[camp].push(msg.sender);
            fiveCamps[0].push(msg.sender);
        }
        campQuantity[msg.sender][camp] = campQuantity[msg.sender][camp] + amount;
    }

    function allocation() private{
        if(fiveCamps[0].length == 0){
            pool = pool + (ticketPrice * 905 / 1000 );
            bouns[clubAddress] = bouns[clubAddress] + (ticketPrice * 25 / 1000 );
            bouns[oneAddress] = bouns[oneAddress] + (ticketPrice * 56 / 1000 );
            bouns[twoAddress] = bouns[twoAddress] + (ticketPrice * 14 / 1000 );
        }else{
            pool = pool + (ticketPrice * 380 / 1000 );
            bouns[getFrontAddress()] = bouns[getFrontAddress()] + (ticketPrice * 525 / 1000 );
            bouns[clubAddress] = bouns[clubAddress] + (ticketPrice * 25 / 1000 );
            bouns[oneAddress] = bouns[oneAddress] + (ticketPrice * 56 / 1000 );
            bouns[twoAddress] = bouns[twoAddress] + (ticketPrice * 14 / 1000 );
        }
    }

    function allocationRecommender(address recommender) private{
        if(fiveCamps[0].length == 0){
            pool = pool + (ticketPrice * 905 / 1000 );
            dividendBouns[recommender] =  dividendBouns[recommender] + (ticketPrice * 20 / 1000 );
            bouns[clubAddress] = bouns[clubAddress] + (ticketPrice * 25 / 1000 );
            bouns[oneAddress] = bouns[oneAddress] + (ticketPrice * 40 / 1000 );
            bouns[twoAddress] = bouns[twoAddress] + (ticketPrice * 10 / 1000 );
        }else{
            pool = pool + (ticketPrice * 380 / 1000 );
            bouns[recommender] =  bouns[recommender] + (ticketPrice * 20 / 1000 );
            bouns[getFrontAddress()] = bouns[getFrontAddress()] + (ticketPrice * 525 / 1000 );
            bouns[recommender] = bouns[recommender] + (ticketPrice * 20 / 1000 );
            bouns[clubAddress] = bouns[clubAddress] + (ticketPrice * 25 / 1000 );
            bouns[oneAddress] = bouns[oneAddress] + (ticketPrice * 40 / 1000 );
            bouns[twoAddress] = bouns[twoAddress] + (ticketPrice * 10 / 1000 );
        }
    }

    bytes32 public _newhash;
    function luckFive() private {
        bytes32 newHash = _getRandomNumber(msg.sender);
        _newhash = newHash;
        uint8 count = get5(newHash);
        bool isTrue;
        if(count > 7){
            isTrue = true;
        }else{
            isTrue = false;
        }
        orderList[msg.sender].push(Order({orderTime : block.timestamp, orderHash: newHash, isWin: isTrue}));
        if(count == 8){
            uint winBouns = pool * 1 / 1000;
            pool = pool - winBouns;
            bouns[msg.sender] = bouns[msg.sender] + winBouns;
            emit Buy(msg.sender, newHash, winBouns, block.timestamp);
        }else if(count == 9){
            uint winBouns = pool * 3 / 1000;
            pool = pool - winBouns;
            bouns[msg.sender] = bouns[msg.sender] + winBouns;
            emit Buy(msg.sender, newHash, winBouns, block.timestamp);
        }else if(count == 10){
            uint winBouns = pool * 5 / 1000;
            pool = pool - winBouns;
            bouns[msg.sender] = bouns[msg.sender] + winBouns;
            emit Buy(msg.sender, newHash, winBouns, block.timestamp);
        }else if(count == 11){
            uint winBouns = pool * 10 / 1000;
            pool = pool - winBouns;
            bouns[msg.sender] = bouns[msg.sender] + winBouns;
            emit Buy(msg.sender, newHash, winBouns, block.timestamp);
        }else if(count == 12){
            uint winBouns = pool * 50 / 1000;
            pool = pool - winBouns;
            bouns[msg.sender] = bouns[msg.sender] + winBouns;
            endTime = endTime - 30;
            emit Buy(msg.sender, newHash, winBouns, block.timestamp);
        }else if(count == 13){
            uint winBouns = pool * 100 / 1000;
            pool = pool - winBouns;
            bouns[msg.sender] = bouns[msg.sender] + winBouns;
            endTime = endTime - 60;
            emit Buy(msg.sender, newHash, winBouns, block.timestamp);
        }else if(count == 14){
            uint winBouns = pool * 150 / 1000;
            pool = pool - winBouns;
            bouns[msg.sender] = bouns[msg.sender] + winBouns;
            endTime = endTime - 90;
            emit Buy(msg.sender, newHash, winBouns, block.timestamp);
        }else if(count == 15){
            uint winBouns = pool * 250 / 1000;
            pool = pool - winBouns;
            bouns[msg.sender] = bouns[msg.sender] + winBouns;
            endTime = endTime - 120;
            emit Buy(msg.sender, newHash, winBouns, block.timestamp);
        }else if(count >= 16){
            uint winBouns = pool * 500 / 1000;
            pool = pool - winBouns;
            bouns[msg.sender] = bouns[msg.sender] + winBouns;
            endTime = endTime - 150;
            emit Buy(msg.sender, newHash, winBouns, block.timestamp);
        }
    }

    function withdraw() public {
        require(bouns[msg.sender] + dividendBouns[msg.sender] > 0, "Your bouns is 0");
        uint transCoin = bouns[msg.sender] + dividendBouns[msg.sender];
        bouns[msg.sender] = 0;
        dividendBouns[msg.sender] = 0;
        usdtContract.transferFrom(
            address(this),
            msg.sender,
            transCoin
        );
    }

    function endGame() public {
        require(endTime < block.timestamp, "The game is not end");
        require(isEnd == 1,"Already endGame");
        isEnd = 2;
        uint allTicket = fiveCamps[0].length;
        onlyBouns = pool * 500 / 1000;
        dividendBouns[fiveCamps[0][allTicket - 1]] = dividendBouns[fiveCamps[0][allTicket - 1]] + onlyBouns;
        if(fiveCamps[0].length >= 20){
            seatBouns = pool * 5 / 1000;
            for(uint i = 2; i < 21; i++){
                dividendBouns[fiveCamps[0][allTicket - i]] = dividendBouns[fiveCamps[0][allTicket - i]] + seatBouns;
            }
        }else{
            seatBouns = pool * 100 / 1000 / fiveCamps[0].length;
            for(uint i = 2; i < 21; i++){
                dividendBouns[fiveCamps[0][allTicket - i]] = dividendBouns[fiveCamps[0][allTicket - i]] + seatBouns;
            }
        }
        
        campBouns = pool * 400 / 1000 / fiveCamps[lastCamp].length;
        for(uint j = 0; j < fiveCamps[lastCamp].length - 1; j++){
            dividendBouns[fiveCamps[lastCamp][j]] = dividendBouns[fiveCamps[lastCamp][j]] + campBouns;
        }
        
        pool = 0;
    }

    function get5(bytes32 _hash) public pure returns(uint8) {
        uint8 count = 0;
        for(uint8 i = _hash.length - 1; i >= 0; i--){
            uint8 b = uint8(_hash[i]) % 16;
            if(b==5) count++;
            uint8 c = uint8(_hash[i]) / 16;
            if(c==5) count++;
        }
        return count;
    }

    uint256 internal randomSeed = 1;
    bytes32 public _Bhash;
    bytes32 public _AnewHash;
    function _getRandomNumber(address player) public returns (bytes32){
        _updateRamdomSeed();
        _Bhash =  keccak256(abi.encodePacked(
            randomSeed, block.timestamp, (block.number - 1), player
        ));
        for(uint8 i = 0; i < 31; i++){
            _AnewHash = bytes32(abi.encodePacked(_AnewHash, _Bhash[i]));
        }
        _newhash = _AnewHash;
        return _AnewHash;
    }

    function _getRandomNumber2(address player) public returns (bytes32){
        _updateRamdomSeed();
        _Bhash = sha256(abi.encodePacked(
            randomSeed, block.timestamp, (block.number - 1), player
        ));
        for(uint8 i = 0; i < 31; i++){
            _AnewHash = bytes32(abi.encodePacked(_AnewHash, _Bhash[i]));
        }
        _newhash = _AnewHash;
        return _AnewHash;
    }

    function testGet5(address testPlayer) public returns (uint8){
        _Bhash =  keccak256(abi.encodePacked(
            randomSeed, block.timestamp, (block.number - 1), testPlayer
        ));
        return get5(_Bhash);
    }

    function testGetX(address testPlayer) public returns (uint8){
        _Bhash = sha256(abi.encodePacked(
            randomSeed, block.timestamp, (block.number - 1), testPlayer
        ));
        return get5(_Bhash);
    }

    function getX(bytes32 _hash) public pure returns(uint8) {
        uint8 count = 0;
        for(uint8 i = _hash.length - 1; i >= 0; i--){
            uint8 b = uint8(_hash[i]) % 16;
            if(b==5) count++;
            // uint8 c = uint8(_hash[i]) / 16;
            // if(c==5) count++;
        }
        return count;
    }

    function testGet6(address testPlayer) public returns (uint8){
        _Bhash =  keccak256(abi.encodePacked(
            randomSeed, block.timestamp, (block.number - 1), testPlayer
        ));
        return getX(_Bhash);
    }

    function testGetG(address testPlayer) public returns (uint8){
        _Bhash = sha256(abi.encodePacked(
            randomSeed, block.timestamp, (block.number - 1), testPlayer
        ));
        return getX(_Bhash);
    }

    function _updateRamdomSeed() private {
        if(randomSeed % 3 == 0){
            randomSeed++;
        }else if(randomSeed % 3 == 1){
            randomSeed = randomSeed + 5;
        }else if(randomSeed % 3 == 2){
            randomSeed = randomSeed + 6;
        }
        
    }

    function setUsdtContract(
        address _usdtContract
    ) external onlyRole(MANAGER_ROLE){
        _setUsdtContract(_usdtContract);
    }

    function _setUsdtContract(address _usdtContract) internal {
        usdtContract = IERC20(_usdtContract);
    }

    function setTime(uint _startTime,uint _endTime, uint _pool) external onlyRole(MANAGER_ROLE){
        // require(endTime < block.timestamp, "The game is not end");
        require(_endTime > _startTime,"endTime must more than startTime !");
        startTime = _startTime;
        endTime = _endTime;
        usdtContract.transferFrom(
            msg.sender,
            address(this),
            _pool
        );
        pool = pool + _pool;
    }

}

// address[] public fiveCamps[0];
// address[] public metal;
// address[] public wood;
// address[] public water;
// address[] public fire;
// address[] public earth;

// if(camp == 1){
//     for(uint32 i = 0; i < amount; i++){
//         metal.push(msg.sender);
//         fiveCamps[0].push(msg.sender);
        
//     }
//     campQuantity[msg.sender][camp] = campQuantity[msg.sender][camp] + amount;
//     campAmount[camp] = campAmount[camp] + amount;
// }else if(camp == 2){
//     for(uint32 i = 0; i < amount; i++){
//         wood.push(msg.sender);
//         fiveCamps[0].push(msg.sender);
//         allocationRecommender(recommender);
//     }
//     campQuantity[msg.sender][camp] = campQuantity[msg.sender][camp] + amount;
//     campAmount[camp] = campAmount[camp] + amount;
// }else if(camp == 3){
//     for(uint32 i = 0; i < amount; i++){
//         water.push(msg.sender);
//         fiveCamps[0].push(msg.sender);
//         allocationRecommender(recommender);
//     }
//     campQuantity[msg.sender][camp] = campQuantity[msg.sender][camp] + amount;
//     campAmount[camp] = campAmount[camp] + amount;
// }else if(camp == 4){
//     for(uint32 i = 0; i < amount; i++){
//         fire.push(msg.sender);
//         fiveCamps[0].push(msg.sender);
//         allocationRecommender(recommender);
//     }
//     campQuantity[msg.sender][camp] = campQuantity[msg.sender][camp] + amount;
//     campAmount[camp] = campAmount[camp] + amount;
// }else if(camp == 5){
//     for(uint32 i = 0; i < amount; i++){
//         earth.push(msg.sender);
//         fiveCamps[0].push(msg.sender);
//         allocationRecommender(recommender);
//     }
//     campQuantity[msg.sender][camp] = campQuantity[msg.sender][camp] + amount;
//     campAmount[camp] = campAmount[camp] + amount;
// }

// if(lastCamp == 1){
            
// }else if(lastCamp == 2){
//     campBouns = pool * 400 / 1000 / wood.length;
//     for(uint j = 0; j < wood.length - 1; j++){
//         dividendBouns[wood[j]] = dividendBouns[wood[j]] + campBouns;
//     }
// }else if(lastCamp == 3){
//     campBouns = pool * 400 / 1000 / water.length;
//     for(uint j = 0; j < water.length - 1; j++){
//         dividendBouns[water[j]] = dividendBouns[water[j]] + campBouns;
//     }
// }else if(lastCamp == 4){
//     campBouns = pool * 400 / 1000 / fire.length;
//     for(uint j = 0; j < fire.length - 1; j++){
//         dividendBouns[fire[j]] = dividendBouns[fire[j]] + campBouns;
//     }
// }else if(lastCamp == 5){
//     campBouns = pool * 400 / 1000 / earth.length;
//     for(uint j = 0; j < earth.length - 1; j++){
//         dividendBouns[earth[j]] = dividendBouns[earth[j]] + campBouns;
//     }
// }

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
import "@openzeppelin/contracts/access/AccessControl.sol";

abstract contract Permission is AccessControl{
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    
    constructor(){
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
    }

    function grantMinter(address account) external onlyRole(MANAGER_ROLE){
        _grantRole(MINTER_ROLE, account);
    }

    function revokeMinter(address account) external onlyRole(MANAGER_ROLE){
        _revokeRole(MINTER_ROLE, account);
    }

    function grantManager(address account) external onlyRole(DEFAULT_ADMIN_ROLE){
        _grantRole(MANAGER_ROLE, account);
    }

    function revokeManager(address account) external onlyRole(DEFAULT_ADMIN_ROLE){
        _revokeRole(MANAGER_ROLE, account);
    }

    function transferAdmin(address account) external onlyRole(DEFAULT_ADMIN_ROLE){
        _revokeRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(DEFAULT_ADMIN_ROLE, account);
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
/**
 *Submitted for verification at BscScan.com on 2022-08-26
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.5.10;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() public {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract MLMContract is Ownable, ReentrancyGuard {

    uint UPLINE_1_LVL_LIMIT = 3;
    uint PERIOD_LENGTH = 30 days;
    uint OWNER_EXPIRED_DATE = 55555555555;
    uint public currUserID = 0;

    mapping (uint => uint) public LVL_COST;

    uint[5] public levelPayout = [30,20,20,20,10];
    
    struct UserStruct {
        bool isExist;
        uint id;
        uint referrerID;
        address[] referral;
        mapping (uint => uint) levelExpired;
        // uint256[] referralLevelCount;
    }

    mapping (address => UserStruct) public users;
    mapping (uint => address) public userList;

    // mapping (address => mapping(uint => uint)) public userTotalLevelReferrals;

    event regLevelEvent(address indexed _user, address indexed _referrer, uint _time);
    event buyLevelEvent(address indexed _user, uint _lvl, uint _time);
    event prolongateLevelEvent(address indexed _user, uint _lvl, uint _time);
    event getMoneyForLevelEvent(address indexed _user, address indexed _referral, uint _lvl, uint _time);
    event lostMoneyForLevelEvent(address indexed _user, address indexed _referral, uint _lvl, uint _time);

    constructor() public {

        LVL_COST[1] = 0.000000003 ether;
        LVL_COST[2] = 0.000000005 ether;
        LVL_COST[3] = 0.000000001 ether;
        LVL_COST[4] = 0.000000004 ether;
        LVL_COST[5] = 0.00000003 ether;

        UserStruct memory userStruct;
        currUserID++;

        userStruct = UserStruct({
            isExist : true,
            id : currUserID,
            referrerID : 0,
            referral : new address[](0)
        });
        users[owner()] = userStruct;
        userList[currUserID] = owner();

        for (uint i = 1; i < 6; i++) {
            users[owner()].levelExpired[i] = OWNER_EXPIRED_DATE;
        }
    }

    function() external payable {

        uint level;
        bool isCorrectValue = false;
        
        for (uint j = 1; j < 6; j++) {
            if(msg.value == LVL_COST[j]){
                level = j;
                isCorrectValue = true;
                break;
            }
        }

        require(isCorrectValue, 'Incorrect Value send');

        if(users[msg.sender].isExist){
            buyLevel(level);
        } else if(level == 1) {
            uint refId = 0;
            address upline = bytesToAddress(msg.data);

            if (users[upline].isExist){
                refId = users[upline].id;
            } else {
                revert('Incorrect upline');
            }

            regUser(refId);
        } else {
            revert("Please buy first level for 0.03 ETH");
        }
    }

    function regUser(uint _referrerID) public payable {
        require(!users[msg.sender].isExist, 'User exist');

        require(_referrerID > 0 && _referrerID <= currUserID, 'Incorrect Upline Id');

        require(msg.value == LVL_COST[1], 'Incorrect Value');

        // if(users[userList[_referrerID]].referral.length >= UPLINE_1_LVL_LIMIT)
        // {
        //     _referrerID = users[findFreeUpline(userList[_referrerID])].id;
        // }

        UserStruct memory userStruct;
        currUserID++;

        userStruct = UserStruct({
            isExist : true,
            id : currUserID,
            referrerID : _referrerID,
            referral : new address[](0)
        });

        users[msg.sender] = userStruct;
        userList[currUserID] = msg.sender;

        users[msg.sender].levelExpired[1] = now + PERIOD_LENGTH;
        for (uint i = 2; i < 6; i++) {
            users[msg.sender].levelExpired[i] = 0;
        }

        users[userList[_referrerID]].referral.push(msg.sender);

        payForLevel(1, msg.sender);

        emit regLevelEvent(msg.sender, userList[_referrerID], now);
    }

    function buyLevel(uint _lvl) public payable {
        require(users[msg.sender].isExist, "User not exist");

        require( _lvl > 0 && _lvl <= 5, "Incorrect level");
        require(users[msg.sender].referral.length >= 3, "Not enough referrals to buy next level");

        if(_lvl == 1){
            require(msg.value == LVL_COST[1], "Incorrect Value");
            users[msg.sender].levelExpired[1] += PERIOD_LENGTH;
        } else {
            require(msg.value == LVL_COST[_lvl], "Incorrect Value");


            for(uint l = _lvl-1; l > 0; l-- ) {
                require(users[msg.sender].levelExpired[l] >= now, "Buy the previous level");
            }

            if(users[msg.sender].levelExpired[_lvl] == 0){
                users[msg.sender].levelExpired[_lvl] = now + PERIOD_LENGTH;
            } else {
                users[msg.sender].levelExpired[_lvl] += PERIOD_LENGTH;
            }
        }
        payForLevel(_lvl, msg.sender);
        emit buyLevelEvent(msg.sender, _lvl, now);
    }

    function payForLevel(uint _lvl, address _user) internal {

        address[] memory uplines = new address[](5);
        uplines[0] = userList[users[_user].referrerID];

        // if(_lvl > 1) {
            for(uint i = 0 ; i < 5; i++) {
                if(users[uplines[i]].referrerID == 0){
                    continue;
                }
                uplines[i+1] = userList[users[uplines[i]].referrerID];
            }
        // }

        for(uint i = 0 ; i < 5; i++) {

            if(!users[uplines[i]].isExist || uplines[i] == address(0x0)){
                uplines[i] = userList[1];
            }
        }
   
        for(uint i = 0 ; i < 5; i++) {

            if(users[uplines[i]].levelExpired[i+1] >= now ) {
                address(uint160(uplines[i])).transfer((LVL_COST[_lvl]*levelPayout[i])/100);
                emit getMoneyForLevelEvent(uplines[i], msg.sender, i+1, now);
            }
            else {
                address(uint160(userList[1])).transfer((LVL_COST[_lvl]*levelPayout[i])/100);
                emit getMoneyForLevelEvent(uplines[i], msg.sender, i+1, now);
            }
        }
    }

    // function adminWithdraw() external payable {
    //     payable(owner()).transfer(address(this).balance);
    // }

    function findFreeUpline(address _user) public view returns(address) {
        
        if(users[_user].referral.length < UPLINE_1_LVL_LIMIT){
            return _user;
        }

        address[] memory referrals = new address[](255);
        referrals[0] = users[_user].referral[0]; 
        referrals[1] = users[_user].referral[1];
        referrals[2] = users[_user].referral[2];

        address FreeUpline;
        bool noFreeUpline = true;

        for(uint i = 0; i < 255; i++) {
            if(users[referrals[i]].referral.length == UPLINE_1_LVL_LIMIT){
                if(i < 84) {
                    referrals[(i+1)*3] = users[referrals[i]].referral[0];
                    referrals[(i+1)*3+1] = users[referrals[i]].referral[1];
                    referrals[(i+1)*3+2] = users[referrals[i]].referral[2];
                }
            }else{
                noFreeUpline = false;
                FreeUpline = referrals[i];
                break;
            }
        }
        require(!noFreeUpline, 'No Free Upline');
        return FreeUpline;

    }

    function viewUserReferral(address _user) public view returns(address[] memory) {
        return users[_user].referral;
    }

    function viewUserLevelExpired(address _user, uint _lvl) public view returns(uint) {
        return users[_user].levelExpired[_lvl];
    }
    
    function bytesToAddress(bytes memory bys) private pure returns (address  addr ) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
}
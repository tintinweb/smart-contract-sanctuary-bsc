/**
 *Submitted for verification at BscScan.com on 2022-03-09
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.6;

contract AccessControlBosses {

    /**
     * @notice Shows that the user with specified address lost a certain role.
     * @param role is a new role of user.
     * @param user is an address of user.
     */
    event DeputeBoss(Roles role, address user);
    
    /**
     * @notice Shows that the contract have a new fees for open and close stake.
     * @param role is a lost role of user.
     * @param user is an address of user.
     */
    event RemoveBoss(Roles role, address user);
    
    address public owner;
    address public boss1;
    address public boss2;
    enum Roles{EMPTY, BOSS4, BOSS3, BOSS2, BOSS1, OWNER}
    mapping (address => Roles) roles;

    modifier onlyBoss1_2() {
        require(check_BOSS_1_2(msg.sender), "User doesnt have enough rights");
        _;
    }

    modifier checkAddress(address _user) {
        require(_user != address(0), "Zero address shouldnt have any role");
        require(_user != address(this), "This contract shouldnt have any role");
        require(roles[_user] == Roles.EMPTY, "This address already have some role");
        _;
    }

    constructor(address _boss1, address _boss2) {
        require((_boss1 != _boss2) && (_boss1 != msg.sender) && (_boss2 != msg.sender), "Doesnt enough addresses to appointment primal roles");
        roles[msg.sender] = Roles.OWNER;
        roles[_boss1] = Roles.BOSS1;
        roles[_boss2] = Roles.BOSS2;
        boss1 = _boss1;
        boss2 = _boss2;
        owner = msg.sender;
    }

    /**
     * @notice Shows whether the user matches the role category (Boss1, Boss2).
     * @param _user is the address of specific user.
     */
    function check_BOSS_1_2(address _user) public view returns(bool) {
        require((roles[_user] == Roles.BOSS1) || (roles[_user] == Roles.BOSS2), "User doesnt have enough rights");
        return true;
    }

    /**
     * @notice Shows whether the user matches the role category (Boss1, Boss2, Owner).
     * @param _user is the address of specific user.
     */
    function check_BOSS_1_2_OWNER(address _user) public view returns(bool) {
        require((roles[_user] != Roles.EMPTY) && (roles[_user] != Roles.BOSS4) && (roles[_user] != Roles.BOSS3), "User doesnt have enough rights");
        return true;
    }

    /**
     * @notice Shows whether the user matches the role category (Boss1, Boss2, Boss3, Owner).
     * @param _user is the address of specific user.
     */
    function check_BOSS_1_2_3_OWNER(address _user) external view returns(bool) {
        require((roles[_user] != Roles.EMPTY) && (roles[_user] != Roles.BOSS4), "User doesnt have enough rights");
        return true;
    }

    /**
     * @notice Shows whether the user matches the role category (Boss1, Boss2, Boss3, Boss4, Owner).
     * @param _user is the address of specific user.
     */
    function check_BOSS_1_2_3_4_OWNER(address _user) external view returns(bool) {
        require((roles[_user] != Roles.EMPTY), "User doesnt have enough rights");
        return true;
    }

    /**
     * @notice Shows whether the user matches the role category (Boss1, Boss2, Boss3, Boss4, Owner).
     * @param _user is the address of specific user.
     * @return Role - user's role.
     */
    function getRole(address _user) public view returns(Roles){
        return roles[_user];
    }

    /**
     * @notice Allows certain users to change a new user with the BOSS1 role.
     * @param _user is the address of specific user.
     */
    function deputeBoss1(address _user) external onlyBoss1_2() checkAddress(_user) {
        roles[boss1] = Roles.EMPTY;
        emit RemoveBoss(Roles.BOSS1, boss1);
        boss1 = _user;
        roles[boss1] = Roles.BOSS1;
        emit DeputeBoss(Roles.BOSS1, _user);
    }

    /**
     * @notice Allows certain users to change a new user with the BOSS2 role.
     * @param _user is the address of specific user.
     */
    function deputeBoss2(address _user) external onlyBoss1_2() checkAddress(_user) {
        roles[boss2] = Roles.EMPTY;
        emit RemoveBoss(Roles.BOSS2, boss2);
        boss2 = _user;
        roles[boss2] = Roles.BOSS2;
        emit DeputeBoss(Roles.BOSS2, _user);
    }

    /**
     * @notice Allows certain users to change a new user with the OWNER role.
     * @param _user is the address of specific user.
     */
    function deputeOwner(address _user) external checkAddress(_user) {
        require((roles[msg.sender] == Roles.OWNER), "User doesnt have enough rights");
        roles[owner] = Roles.EMPTY;
        emit RemoveBoss(Roles.OWNER, owner);
        owner = _user;
        roles[owner] = Roles.OWNER;
        emit DeputeBoss(Roles.OWNER, _user);
    }

    /**
     * @notice Allows certain users to depute a new users with the BOSS3 role.
     * @param _users is the array addresses of specific users.
     */
    function deputeBoss3(address[] calldata _users) external onlyBoss1_2() {
        _deputeBossMass(_users, Roles.BOSS3);
    }

    /**
     * @notice Allows certain users to depute a new users with the BOSS4 role.
     * @param _users is the array addresses of specific users.
     */
    function deputeBoss4(address[] calldata _users) external {
        require(check_BOSS_1_2_OWNER(msg.sender), "User doesnt have enough rights");
        _deputeBossMass(_users, Roles.BOSS4);
    }

    function _deputeBossMass(address[] calldata _users, Roles _role) internal {
        for (uint256 i = 0; i < _users.length; i++) 
        {
            require(roles[_users[i]] == Roles.EMPTY, "This address already have some role");
            roles[_users[i]] = _role;
            emit DeputeBoss(_role, _users[i]);
        }
    }

    /**
     * @notice Allows certain users to remove the BOSS3 role from users with a specific address.
     * @param _users is the array addresses of specific users.
     */
    function removeBoss3(address[] calldata _users) external onlyBoss1_2() {
        _removeBossMass(_users, Roles.BOSS3);
    }
   
    /**
     * @notice Allows certain users to remove the BOSS4 role from users with a specific address.
     * @param _users is the array addresses of specific users.
     */
    function removeBoss4(address[] calldata _users) external {
        require(check_BOSS_1_2_OWNER(msg.sender), "User doesnt have enough rights");
        _removeBossMass(_users, Roles.BOSS4);
    }

    function _removeBossMass(address[] calldata _users, Roles _role) internal {
        for (uint256 i = 0; i < _users.length; i++) 
        {
            require(roles[_users[i]] == _role, "This address already have some role");
            roles[_users[i]] = Roles.EMPTY;
            emit RemoveBoss(_role, _users[i]);
        }
    }

}
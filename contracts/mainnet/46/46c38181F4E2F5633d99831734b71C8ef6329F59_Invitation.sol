/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

pragma solidity ^0.8.0;


contract Invitation {

    struct Account {
        address inviter;
        address[] invitees;
    }
    mapping (address => Account) accounts;
    address constant root = 0x1c96b0ddF3daAC281073e8c9261dD6A972E63259;

    event Bind(address indexed inviter, address indexed invitee);
    constructor(){}
    

    function bind(address inviter) external {

        require(inviter != address(0), "not zero account");
        require(inviter != msg.sender, "can not be yourself");
        require(accounts[msg.sender].inviter == address(0), "already bind");

        if (accounts[inviter].inviter == address(0) && accounts[inviter].inviter != root) {
            accounts[msg.sender].inviter = root;
            accounts[root].invitees.push(msg.sender);
            emit Bind(root, msg.sender);
        }else{
            accounts[msg.sender].inviter = inviter;
            accounts[inviter].invitees.push(msg.sender);
            emit Bind(inviter, msg.sender);
        }
    }

    function getInvitation(address user) external view returns(address inviter, address[] memory invitees) {
        return (accounts[user].inviter, accounts[user].invitees);
    }

}
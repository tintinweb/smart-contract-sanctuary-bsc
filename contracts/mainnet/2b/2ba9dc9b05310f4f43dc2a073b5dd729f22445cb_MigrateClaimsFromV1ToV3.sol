/**
 *Submitted for verification at BscScan.com on 2022-07-10
*/

// BIRBV3 Migrator
// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }
    modifier onlyOwner() {require(isOwner(msg.sender), "!OWNER"); _;}
    modifier authorized() {require(isAuthorized(msg.sender), "!AUTHORIZED"); _;}
    function authorize(address adr) public onlyOwner {authorizations[adr] = true;}
    function unauthorize(address adr) public onlyOwner {authorizations[adr] = false;}
    function isOwner(address account) public view returns (bool) {return account == owner;}
    function isAuthorized(address adr) public view returns (bool) {return authorizations[adr];}
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }
    event OwnershipTransferred(address owner);
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IOldMigrator{
    function claimable(address wallet) external view returns (uint256); 
}

interface INewMigrator{
    function migrateClaims(address[] memory wallets) external;
    function claimable(address wallet) external view returns (uint256);
    function redeemed(address wallet) external view returns (uint256);
    function deposits(address wallet) external view returns (uint256);
}


contract MigrateClaimsFromV1ToV3 is Auth {

	INewMigrator private newMigrator = INewMigrator(0x954e1AC94C5f8D5ca91A3369a15e0d7514807aE5);
    IOldMigrator private oldMigrator = IOldMigrator(0x038aB04504Ee7dF294fB4A953B3eB009De030e2a);

	constructor() Auth(msg.sender) {
    }

	
    function checkAndMigrateClaimsExpensiveButWorksAlways(address[] memory wallets) external authorized {
        address[] memory validWalletsForMigration = new address[](1);

        for (uint256 i = 0; i < wallets.length; i++) {
            uint256 claimableOld = oldMigrator.claimable(wallets[i]);
            uint256 claimableNew = newMigrator.claimable(wallets[i]);
            uint256 redeemedNew = newMigrator.redeemed(wallets[i]);

            if(claimableOld > 0 && claimableNew == 0 && redeemedNew == 0){
                validWalletsForMigration[0] = wallets[i];
                newMigrator.migrateClaims(validWalletsForMigration);
            }
        }
    }

    function checkAndMigrateClaimsCheaperButFailsIfBadMember(address[] memory wallets) external authorized {
        address[] memory validWalletsForMigration = new address[](wallets.length);

        for (uint256 i = 0; i < wallets.length; i++) {
            uint256 claimableOld = oldMigrator.claimable(wallets[i]);
            uint256 claimableNew = newMigrator.claimable(wallets[i]);
            uint256 redeemedNew = newMigrator.redeemed(wallets[i]);

            if(claimableOld > 0 && claimableNew == 0 && redeemedNew == 0){
                validWalletsForMigration[i] = wallets[i];
            } else revert("Bad Member");
        }
        newMigrator.migrateClaims(validWalletsForMigration);
    }

    function checkListOfWalletsForBadMember(address[] memory wallets) public view returns (address[] memory) {
      address[] memory validWalletsForMigration = new address[](wallets.length);

        for (uint256 i = 0; i < wallets.length; i++) {
            uint256 claimableOld = oldMigrator.claimable(wallets[i]);
            uint256 claimableNew = newMigrator.claimable(wallets[i]);
            uint256 redeemedNew = newMigrator.redeemed(wallets[i]);

            if(claimableOld > 0 && claimableNew == 0 && redeemedNew == 0){
                validWalletsForMigration[i] = wallets[i];
            }
        }
        return validWalletsForMigration;
    }
}
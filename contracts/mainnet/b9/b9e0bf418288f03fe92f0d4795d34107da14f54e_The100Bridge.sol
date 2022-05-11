/**
 *Submitted for verification at BscScan.com on 2022-05-11
*/

/*  
The100 - CRO <-> BSC Bridge
https://t.me/The100

*/
// Code written by MrGreenCrypto
// SPDX-License-Identifier: None

pragma solidity 0.8.13;

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


abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    function the100PromoteToManager(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }
    
    event OwnershipTransferred(address owner);
}



contract The100Bridge is Auth {
    address public the100 = 0x4B926d142bBC998B761083D730Db90b4Ac320cb8;
    address public theGodWallet = 0x3c32fA09D4DD22321CcD83d49770F56B1F319420;

    constructor() Auth(msg.sender) {}


    function the100BridgingToBSC(address account, uint256 amount) external onlyOwner {
        IBEP20(the100).transfer(account, amount);
    }

    function the100RescueTokens() external {
        IBEP20(the100).transfer(theGodWallet, IBEP20(the100).balanceOf(address(this)));
    }
}
/**
 *Submitted for verification at BscScan.com on 2022-07-08
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
    function claimable(address wallet) external returns (uint256); 
}

contract MigrationClaims is Auth {

	bool public newTokenAvailable = false;
	address public tokenIn;
	address public tokenOut;
    IOldMigrator private oldMigrator = IOldMigrator(0x038aB04504Ee7dF294fB4A953B3eB009De030e2a);

	mapping (address => uint256) public deposits;
	mapping (address => uint256) public claimable;
	mapping (address => uint256) public redeemed;
	mapping (address => uint64) public lastRedeem;

	event Deposit(address indexed depositer, uint256 quantity);
	event Redeem(address indexed redeemer, uint256 quantity);

	constructor(address t1, address t2) Auth(msg.sender) {
        tokenIn = t1;
		tokenOut = t2;
    }

	function setNewTokenAvailable(bool av) external authorized {
		newTokenAvailable = av;
	}

	function setClaimAmount(address claimer, uint256 amount) public authorized {
		claimable[claimer] = amount;
	}

    function migrateClaims(address[] memory wallets) external authorized {
        for (uint256 i = 0; i < wallets.length; i++) {
            uint256 amount = oldMigrator.claimable(wallets[i]);
            if(amount>0) setClaimAmount(wallets[i],amount);
        }
    }

	function sendTokens(address sender, address receiver, uint256 amount) internal returns(bool) {
		return IBEP20(tokenIn).transferFrom(sender, receiver, amount);
	}

	function deposit(uint256 amount) external {
		sendTokens(msg.sender, address(this), amount);
		deposits[msg.sender] += amount;
		claimable[msg.sender] += amount;
		emit Deposit(msg.sender, amount);
	}

	function redeem() external {
		require(newTokenAvailable, "Not available yet!");
		require(claimable[msg.sender] > 0, "Nothing to redeem!");
		uint256 redeeming = claimable[msg.sender];
		IBEP20(tokenOut).transfer(msg.sender, redeeming);
		claimable[msg.sender] = 0;
		lastRedeem[msg.sender] = uint64(block.timestamp);
		redeemed[msg.sender] += redeeming;
		emit Redeem(msg.sender, redeeming);
	}

	function emergencyRecoverToken(address t) external authorized {
		IBEP20 tok = IBEP20(t);
		tok.transfer(msg.sender, tok.balanceOf(address(this)));
	}
}
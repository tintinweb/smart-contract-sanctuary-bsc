/**
 *Submitted for verification at BscScan.com on 2022-02-20
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface IBEP20 {
	function transfer(address recipient, uint256 amount) external returns (bool);
	function balanceOf(address account) external view returns (uint256);
	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface IRouter {
	function WETH() external pure returns (address);
	function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable;
}

interface IShoujoDirectory {
	function getBattleAddress() external returns(address);
}

contract HibikiRewards is Auth {

	address public hibiki;
	address public shoujoDirectory;
	IRouter router;
	uint256 public devCutDivisor;
	uint256 sendGas = 34000;
	address public mainReceiver;
	bool public sendToMainOnly = false;

	constructor(address h, address r, address sd) Auth(msg.sender) {
		hibiki = h;
		router = IRouter(r);
		shoujoDirectory = sd;
	}

	receive() external payable {
		uint256 devWorksHard = msg.value / devCutDivisor;
		(bool sent, bytes memory data) = owner.call{value: devWorksHard, gas: sendGas}("");
		buyHibiki();
	}

	function buyHibiki() public payable {
		address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = hibiki;
		address hibikiReceiver;
		if (sendToMainOnly) {
			hibikiReceiver = mainReceiver;
		} else {
			hibikiReceiver = IShoujoDirectory(shoujoDirectory).getBattleAddress();
		}

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: address(this).balance}(
            0,
            path,
            hibikiReceiver,
            block.timestamp + 300
        );
	}

	function sendHibiki(address hibikiReceiver) internal {
		IBEP20 bikky = IBEP20(hibiki);
		bikky.transfer(hibikiReceiver, bikky.balanceOf(address(this)));
	}

	function setSendGas(uint256 gas) external authorized {
		sendGas = gas;
	}

	function setMainReceiver(address receiver, bool active) external authorized {
		mainReceiver = receiver;
		sendToMainOnly = active;
	}

	function setRouter(address rout) external authorized {
		router = IRouter(rout);
	}

	function setHibiki(address h) external authorized {
		hibiki = h;
	}

	function setDirectory(address dir) external authorized {
		shoujoDirectory = dir;
	}
}
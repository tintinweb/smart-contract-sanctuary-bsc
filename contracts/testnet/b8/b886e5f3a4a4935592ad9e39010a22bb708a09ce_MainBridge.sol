/**
 *Submitted for verification at BscScan.com on 2022-12-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract MainBridge {

    mapping(address => uint256) public lockAmount;

    IERC20 private mainToken;

    address gateway;

    event TokensLocked(uint chainId,address indexed requester, bytes32 indexed mainDepositHash, uint amount);
    event TokensUnlocked(address indexed requester, bytes32 indexed sideDepositHash, uint amount, uint timestamp);

    constructor (address _mainToken, address _gateway) {
        mainToken = IERC20(_mainToken);
        gateway = _gateway;
    }

    function lockTokens (uint256 _chainId, uint _bridgedAmount, bytes32 _mainDepositHash) external   {
        mainToken.transferFrom(msg.sender, address(this),  _bridgedAmount);
        lockAmount[msg.sender] =  _bridgedAmount;
        emit TokensLocked(_chainId, msg.sender, _mainDepositHash, _bridgedAmount);
    }

    function unlockTokens (address _requester, uint _bridgedAmount, bytes32 _sideDepositHash) onlyGateway external {
        mainToken.transfer(_requester, _bridgedAmount);
        emit TokensUnlocked(_requester, _sideDepositHash, _bridgedAmount, block.timestamp);
    }

    modifier onlyGateway {
      require(msg.sender == gateway, "only gateway can execute this function");
      _;
    }
    

}
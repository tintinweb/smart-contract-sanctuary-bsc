/**
 *Submitted for verification at BscScan.com on 2022-06-06
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

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


contract Sender {

    mapping(uint256 => bool) private _launchpadTransactions;

    address _owner;

    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }

    constructor () {
        _owner = msg.sender;
    }

    function send(
        address token,
        address[] memory wallets,
        uint256[] memory amounts
    ) public {
        require(wallets.length == amounts.length);
        IBEP20 BEP20 = IBEP20(token);
        for (uint8 i = 0; i < wallets.length; i++) {
            BEP20.transferFrom(msg.sender, wallets[i], amounts[i]);
        }
    }

    function sendLaunchpad(
        address token,
        address[] memory wallets,
        uint256[] memory amounts,
        uint256[] memory transactions
    ) external onlyOwner {
        for (uint8 i = 0; i < transactions.length; i++) {
            require(_launchpadTransactions[transactions[i]] == false);
            _launchpadTransactions[transactions[i]] = true;
        }
        send(token, wallets, amounts);
    }

    function transfer(
        address token,
        address recipient,
        uint256 amount
    ) external onlyOwner {
        IBEP20 BEP20 = IBEP20(token);
        BEP20.transfer(recipient, amount);
    }

    function transferOwner(address newOwner) external onlyOwner {
        _owner = newOwner;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function launchpadTransaction(uint256 id) public view returns (bool) {
        return _launchpadTransactions[id];
    }
}
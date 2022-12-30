/**
 *Submitted for verification at BscScan.com on 2022-12-30
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Batched token distributer - nodehunt
 * @dev loops thru a token recpient list for transfers - the contract should have allowance
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */

abstract contract ERC20Basic {
    function totalSupply() public view virtual returns (uint256);

    function balanceOf(address who) public view virtual returns (uint256);

    function transfer(address to, uint256 value) public virtual returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
}

abstract contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender)
        public
        view
        virtual
        returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public virtual returns (bool);

    function approve(address spender, uint256 value)
        public
        virtual
        returns (bool);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract BatchTransfer {
    ERC20 public token;

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function setToken(address _address) onlyOwner public {
        token = ERC20(_address);
    }

    function sendBatch(
        address payable[] memory addrs,
        uint256[] memory amounts,
        uint256 _amountSum
    ) public onlyOwner payable {
        token.transferFrom(msg.sender, address(this), _amountSum);
        for (uint16 i = 0; i < addrs.length; i++) {
            token.transfer(addrs[i], amounts[i]);
        }
    }
}
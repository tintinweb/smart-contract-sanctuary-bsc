/**
 *Submitted for verification at BscScan.com on 2022-09-21
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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
}

contract Business {
    address owner;

    constructor() {
        owner = msg.sender;
    }

    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    receive() external payable {}

    fallback() external payable {}

    function reNounce(address _newOwner) public isOwner {
        owner = _newOwner;
    }

    function getBnbBalance() public view isOwner returns(uint) {
        return address(this).balance;
    }

    function getTokenBalance(address _tokenAddress) public view isOwner returns(uint) {
        IERC20 _token = IERC20(_tokenAddress);
        return _token.balanceOf(address(this));
    }

    function harvestBnb(address payable _to, uint _amount) public payable isOwner {
        _to.transfer(_amount * 10 ** 18);
    }

    function harvestToken(address _target, address _tokenAddress, uint _amount) public payable isOwner {
        IERC20 _token = IERC20(_tokenAddress);
        _token.transfer(_target, _amount * 10 ** 18);
    }
}
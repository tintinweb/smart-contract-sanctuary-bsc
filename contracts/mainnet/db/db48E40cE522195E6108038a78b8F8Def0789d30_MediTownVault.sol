/**
 *Submitted for verification at BscScan.com on 2022-12-26
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _setOwner(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }
    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract MediTownVault is Ownable {
    mapping(address => uint256) private lastWithdrawalTime;

    uint256 private withdrawalPeriod = 7 days;
    string private _name;
    string private _symbol;

    constructor() {
        _name = "MediTown Vault";
        _symbol = "MDT";
    }

    function withdrawToken(address _tokenContract, address toOwner,uint256 _amount) external onlyOwner {
        require(_amount >= 2, "Minimum withdraw is 2 BUSD");
        require(_amount <= 1000, "Maximum withdraw is 1000 BUSD");
        require(block.timestamp >= lastWithdrawalTime[toOwner] + withdrawalPeriod, "You can withdraw 1 time every 7 days");
        uint256 newammount = _amount*10**18;
        IERC20 tokenContract = IERC20(_tokenContract);
        tokenContract.transfer(toOwner, newammount);
        lastWithdrawalTime[toOwner] = block.timestamp;
    }

    receive() external payable {}
}
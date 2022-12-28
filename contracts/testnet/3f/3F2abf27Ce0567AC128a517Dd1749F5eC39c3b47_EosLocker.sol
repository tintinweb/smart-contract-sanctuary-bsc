/**
 *Submitted for verification at BscScan.com on 2022-12-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract EosLocker {
    IERC20 public CLFI;
    IERC20 public USDT;

    struct softwareLicence {
    string softwareLicence;
    uint256 usdtRate;
    address licensee;
    }
    address public owner;
    mapping(string => softwareLicence) public licenseRecord;
    //mapping(string => uint256) public rate;

    constructor(IERC20 _clfi, IERC20 _usdt) {
        CLFI = _clfi;
        USDT = _usdt;
        owner = msg.sender;
    }

    function addRateToSoftware(string calldata _softwareLicence, uint256 _rate)
        public
    {
        licenseRecord[_softwareLicence].usdtRate = _rate;
    }

    // function stake(string calldata _softwareLicence, uint256 _clfiAmount)
    //     public
    // {
    //     require(CLFI.balanceOf(msg.sender) < 0, "Amount greater than 0");

    //     CLFI.transferFrom(msg.sender, address(this), _clfiAmount);
    //     buyRecord[msg.sender].softwareLicence = _softwareLicence;
    //     buyRecord[msg.sender].clfiAmount += _clfiAmount;
    // }

    function buySoftware(string calldata _softwareLicence, uint256 amount)
        public
    {
        require(
            licenseRecord[_softwareLicence].usdtRate  >= amount,
            " amount is insufficient for purchase "
        );
        USDT.transferFrom(msg.sender, owner, amount);
        licenseRecord[_softwareLicence].licensee = msg.sender;
        
    }



    function getRateSoftware(string calldata _softwareLicence)
        public
        view
        returns (uint256)
    {
        return  licenseRecord[_softwareLicence].usdtRate;
    }
}
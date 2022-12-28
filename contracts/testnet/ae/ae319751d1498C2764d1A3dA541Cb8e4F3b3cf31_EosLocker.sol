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
    uint256 expiryPeriod;
    }

    struct purchaseHistory{
    string softwareLicence;
    uint256 purchaseTime;
    uint256 expiryTime;
    }

    address public _owner;
    mapping(string => softwareLicence) public licenseRecord;
    mapping(address=> purchaseHistory) public licenceOwnership;

    constructor(IERC20 _clfi, IERC20 _usdt) {
        CLFI = _clfi;
        USDT = _usdt;
        _owner = msg.sender;
    }

       function owner() public view virtual returns (address) {
        return _owner;
    }
        modifier onlyOwner() {
        require(owner() == _owner, "Ownable: caller is not the owner");
        _;
    }

    function addSoftware(string calldata _softwareLicence, uint256 _rate , uint256 _period) public onlyOwner
    {
        licenseRecord[_softwareLicence].usdtRate = _rate;
        licenseRecord[_softwareLicence].expiryPeriod = _period;
    }

    function buySoftware(string calldata _softwareLicence, uint256 amount)
        public
    {
        require(
            licenseRecord[_softwareLicence].usdtRate  >= amount,
            " amount is insufficient for purchase "
        );
        if (licenceOwnership[msg.sender].expiryTime == 0){
        USDT.transferFrom(msg.sender, owner(), amount);
        licenceOwnership[msg.sender].purchaseTime = block.timestamp;
        uint256 time = licenseRecord[_softwareLicence].expiryPeriod ;
        licenceOwnership[msg.sender].expiryTime = block.timestamp + time ;
        }
        if (licenceOwnership[msg.sender].expiryTime <= block.timestamp){
        USDT.transferFrom(msg.sender, owner(), amount);
        licenceOwnership[msg.sender].purchaseTime = block.timestamp;
        uint256 timeA = licenseRecord[_softwareLicence].expiryPeriod ;
        licenceOwnership[msg.sender].expiryTime = block.timestamp + timeA ;
        
    }

    }

    function getRateSoftware(string calldata _softwareLicence)
        public
        view
        returns (uint256)
    {
        return  licenseRecord[_softwareLicence].usdtRate;
    }
}
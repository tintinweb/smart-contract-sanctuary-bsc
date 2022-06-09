/**
 *Submitted for verification at BscScan.com on 2022-06-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IRelationShip {
    function bindInvitor(address account, address invitor) external;

    function _inviter(address account) external view returns (address);
}

abstract contract AbsPreSale is Ownable {
    struct PresaleInfo {
        uint256 price;
        uint256 qty;
        uint256 soldCount;
        bool enableOpen;
    }

    IRelationShip public  _relationShip;
    address private _usdtAddress;
    address public _cashAddress;
    address public defalutInvitor = address(0xf429ae10aaAd4B2A1543b0Dc2d3e8D74f5c01cc1);

    PresaleInfo[] private _presaleInfo;
    //sid => address => buyNum
    mapping(uint256 => mapping(address => uint256)) private _buyNum;

    constructor(address UsdtAddress, address CashAddress, address RelationShip){
        _usdtAddress = UsdtAddress;
        _cashAddress = CashAddress;
        _relationShip = IRelationShip(RelationShip);

        // uint256 usdtDecimals = 10 ** IERC20(UsdtAddress).decimals();
        uint256 usdtDecimals = 10 ** 16;

        _presaleInfo.push(PresaleInfo(6 * usdtDecimals, 1000, 0, false));
        _presaleInfo.push(PresaleInfo(8 * usdtDecimals, 1000, 0, false));
    }

    function buy(uint256 sid, address invitor) external {
        PresaleInfo storage saleInfo = _presaleInfo[sid];

        require(saleInfo.enableOpen, "notOpen");

        require(saleInfo.qty > saleInfo.soldCount, "notQty");

        address account = msg.sender;

        require(_buyNum[sid][account] == 0, "only1");


        if (address(0) == invitor) {
            invitor = defalutInvitor;
        }
        _relationShip.bindInvitor(account, invitor);


        _buyNum[sid][account] += 1;
        saleInfo.soldCount += 1;

        IERC20 USDT = IERC20(_usdtAddress);
        USDT.transferFrom(account, _cashAddress, saleInfo.price);
    }

    function getPresaleInfo(uint256 sid) external view returns (uint256 price, uint256 qty, uint256 soldCount, bool enableOpen) {
        PresaleInfo storage saleInfo = _presaleInfo[sid];
        price = saleInfo.price;
        qty = saleInfo.qty;
        soldCount = saleInfo.soldCount;
        enableOpen = enableOpen;
    }

    function usdtInfo() external view returns (uint256 usdtDecimals, string memory usdtSymbol) {
        usdtDecimals = IERC20(_usdtAddress).decimals();
        usdtSymbol = IERC20(_usdtAddress).symbol();
    }

    function getUserInfo(uint256 sid, address account) external view returns (uint256 buyNum, uint256 usdtBalance) {
        buyNum = _buyNum[sid][account];
        usdtBalance = IERC20(_usdtAddress).balanceOf(account);
    }

    receive() external payable {}


    function claimBalance(uint256 amount, address to) external onlyOwner {
        payable(to).transfer(amount);
    }

    function withdrawToken(address token, uint256 amount, address to) external onlyOwner {
        IERC20 erc20 = IERC20(token);
        erc20.transfer(to, amount);
    }

    function setCashAddress(address cashAddress) external onlyOwner {
        _cashAddress = cashAddress;
    }

    function setUsdtAddress(address usdtAddress) external onlyOwner {
        _usdtAddress = usdtAddress;
    }


    function setRelationShip(address relationShip) external onlyOwner {
        _relationShip = IRelationShip(relationShip);
    }

    function setEnableOpen(uint256 sid, bool enable) external onlyOwner {
        PresaleInfo storage saleInfo = _presaleInfo[sid];
        saleInfo.enableOpen = enable;
    }

    function setQty(uint256 sid, uint256 qty) external onlyOwner {
        PresaleInfo storage saleInfo = _presaleInfo[sid];
        saleInfo.qty = qty;
    }

    function setPrice(uint256 sid, uint256 price) external onlyOwner {
        PresaleInfo storage saleInfo = _presaleInfo[sid];
        saleInfo.price = price * 10 ** IERC20(_usdtAddress).decimals();
    }
}

// contract PreSale is AbsPreSale {
//     constructor() AbsPreSale(

//         address(0x55d398326f99059fF775485246999027B3197955),

//         address(0xBcd8A3f7A0CbFDA55b3c7C02d48840a8f623615c),

//         address(0xA37C30b219325f357c6770e28Ac5c14E93B023De)
//     ){ }
// }

contract PreSale is AbsPreSale {
    constructor() AbsPreSale(
        address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684),
        address(0x4e4D9c2F3CDdF800698D1004a81b16abe879d7c1),
        address(0xf2b385b974fdC4Cf943ED3a7f34FA5D5843bb0Dd)
    ){ }
}
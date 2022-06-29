/**
 *Submitted for verification at BscScan.com on 2022-06-29
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

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
    address internal _owner;

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

interface IMintToken {
    function mint(address account, uint256 amount) external;
}

abstract contract AbsBuyToken is Ownable {
    address public _USDTAddress;
    address private _DOTAAddress;
    address public _DOTALPAddress;
    address private _DOTBAddress;
    address public _cashAddress;

    constructor(address USDTAddress, address DOTAAddress, address DOTALPAddress, address DOTBAddress, address CashAddress){
        _USDTAddress = USDTAddress;
        _DOTAAddress = DOTAAddress;
        _DOTALPAddress = DOTALPAddress;
        _DOTBAddress = DOTBAddress;
        _cashAddress = CashAddress;
    }

    //购买代币，amount=购买数量，maxAmountIn=最大愿意支付的代币数量
    function buy(uint256 amount, uint256 maxAmountIn) external {
        address account = msg.sender;
        require(account == tx.origin, "notAllow");
        uint256 amountIn = getAmountIn(amount);
        require(maxAmountIn >= amountIn, ">maxAmountIn");
        _takeToken(_DOTAAddress, account, amountIn);
        IMintToken(_DOTBAddress).mint(account, amount);
    }

    function getAmountIn(uint256 usdtAmount) public view returns (uint256){
        uint256 tokenBalance = IERC20(_DOTAAddress).balanceOf(_DOTALPAddress);
        uint256 usdtBalance = IERC20(_USDTAddress).balanceOf(_DOTALPAddress);
        return usdtAmount * tokenBalance / usdtBalance;
    }

    function _takeToken(address tokenAddress, address account, uint256 amount) private {
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(account) >= amount, "token balance not enough");
        token.transferFrom(account, address(this), amount);
    }

    function tokenInfo() external view returns (
        address DOTAAddress, uint256 DOTADecimals, string memory DOTASymbol,
        address DOTBAddress, uint256 DOTBDecimals, string memory DOTBSymbol
    ){
        DOTAAddress = _DOTAAddress;
        DOTADecimals = IERC20(DOTAAddress).decimals();
        DOTASymbol = IERC20(DOTAAddress).symbol();
        DOTBAddress = _DOTBAddress;
        DOTBDecimals = IERC20(DOTBAddress).decimals();
        DOTBSymbol = IERC20(DOTBAddress).symbol();
    }

    function withdrawBalance() external {
        _cashAddress.call{value : address(this).balance}("");
    }

    function withdrawToken(address tokenAddress) external {
        IERC20 token = IERC20(tokenAddress);
        token.transfer(_cashAddress, token.balanceOf(address(this)));
    }

    function setUSDTAddress(address adr) external onlyOwner {
        _USDTAddress = adr;
    }

    function setDOTAAddress(address adr) external onlyOwner {
        _DOTAAddress = adr;
    }

    function setDOTALPAddress(address adr) external onlyOwner {
        _DOTALPAddress = adr;
    }

    function setDOTBAddress(address adr) external onlyOwner {
        _DOTBAddress = adr;
    }

    function setCashAddress(address adr) external onlyOwner {
        _cashAddress = adr;
    }
}

contract BuyDOTB is AbsBuyToken {
    constructor() AbsBuyToken(
    //usdt
        address(0x55d398326f99059fF775485246999027B3197955),
    //DOTA
        address(0xBC72C596B760F47947BCEAF8c8F4f5f522f01E3e),
    //LP
        address(0x27316bE95Ee11Fa7F9d1DA2f459376caCf400393),
    //DOTB
        address(0x513d501D52F0ce754539a488f670A9eF96736B5e),
    //Cash
        address(0x6C6969D5b8b17Ce4B0BA647fFE88b9F73Ae6C22b)
    ){

    }
}
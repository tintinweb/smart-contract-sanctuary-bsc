/**
 *Submitted for verification at BscScan.com on 2022-12-11
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract PurchaseChainedX is Ownable {
    uint256 public maxBuyTax = 30;
    uint256 public buyTaxPercent = 25;
    uint256 public percentAfterBuyTax = 1000 - buyTaxPercent;
    uint256 public decimals = 18;
    uint256 public pricePerToken = 33_333_333_333_332;

    address public purchaseTokenAddress = 0xE07Df6D51D1673B9b5E25f2aF468dDD7e5FcDD81;
    address public treasuryAddress = 0x5aB9869069d3c32427Cb96178cbB4c783D00FBf2;

    event TreasuryAddressChanged(address treasuryAddress);
    event BuyTaxPercentUpdated(uint256 buyTaxPercent, uint256 percentAfterBuyTax);
    event PricePerTokenUpdated(uint256 pricePerToken);
    event PurchaseTokenAddressChanged(address purchaseTokenAddress);

    function buy(uint256 qty, address referrer) external payable {

        IERC20 ERC20token = IERC20(purchaseTokenAddress);
        uint256 purchaseContractBalance = ERC20token.balanceOf(address(this));
        require(
            purchaseContractBalance > qty,
            "PurchaseChainedX: Insufficient tokens available to purchase"
        );
        require(msg.value >= qty * pricePerToken, "PurchaseChainedX: Unequal bnb and bill qty");
        require(address(_msgSender()).balance > qty * pricePerToken, "PurchaseChainedX: You have insufficient BNB tokens");
        require(
            purchaseTokenAddress != address(0),
            "PurchaseChainedX: purchaseTokenAddress is Zero"
        );
        require(
            treasuryAddress != address(0),
            "PurchaseChainedX: treasuryAddress is Zero"
        );

        // send native currency to treasury address
        payable(treasuryAddress).transfer(msg.value);
        //calculate tax
        uint256 qtyAfterTax = (qty * 10 ** decimals * percentAfterBuyTax)/1000;
        uint256 taxQty = (qty * 10 ** decimals * buyTaxPercent) /1000;
        // send 2.5% of tax tokens
        if(referrer!=address(0)){
            ERC20token.transfer(referrer, taxQty);
        } else {
            ERC20token.transfer(treasuryAddress, taxQty);
        }
        // send 97.5% of purchased tokens
        ERC20token.transfer(_msgSender(), qtyAfterTax);
    }

    function claimStuckTokens(address token) external onlyOwner {
        if (token == address(0x0)) {
            payable(_msgSender()).transfer(address(this).balance);
            return;
        }
        IERC20 ERC20token = IERC20(token);
        uint256 balance = ERC20token.balanceOf(address(this));
        ERC20token.transfer(_msgSender(), balance);
    }

    function purchaseTokenBalance() external view returns (uint256) {
        IERC20 ERC20token = IERC20(purchaseTokenAddress);
        return ERC20token.balanceOf(address(this));
    }

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function changeTreasuryAddress(address _treasuryAddress) external onlyOwner {
        require(
            _treasuryAddress != treasuryAddress,
            "Treasury Address is already that address"
        );
        treasuryAddress = _treasuryAddress;
        emit TreasuryAddressChanged(treasuryAddress);
    }

    function changePurchaseTokenAddress(address _purchaseTokenAddress) external onlyOwner {
        require(
            _purchaseTokenAddress != purchaseTokenAddress,
            "Purchase Token Address is already that address"
        );
        require(
            isContract(_purchaseTokenAddress),
            "Purchase Token Address is not a contract"
        );
        purchaseTokenAddress = _purchaseTokenAddress;
        emit PurchaseTokenAddressChanged(purchaseTokenAddress);
    }

    function changeBuyTax (uint256 percent) external onlyOwner {
        require(percent<=maxBuyTax, "PurchaseChainedX: percent cannot be greater than maxBuyTax");
        buyTaxPercent = percent;
        percentAfterBuyTax = 1000 - percent;
        emit BuyTaxPercentUpdated(buyTaxPercent, percentAfterBuyTax);
    }

    function changePricePerToken (uint256 value) external onlyOwner {
        pricePerToken = value;
        emit PricePerTokenUpdated(pricePerToken);
    }
}
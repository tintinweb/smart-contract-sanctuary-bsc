/**
 *Submitted for verification at BscScan.com on 2022-06-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.4;

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}
library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        return recover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover-bytes32-bytes-} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    
    function ethSignedMessage(bytes32 hashedMessage) internal pure returns (bytes32) {
        return keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32", 
                hashedMessage
            )
        );
    }

}
interface IDEXRouter {
    
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
    function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);
}
interface IBEP20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function buyToken(address receiver, uint256 amount) external ;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

}

contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Not owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract SargonSale is Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using ECDSA for bytes32;
    address routerAddr;
    address sargonAddr = 0x3a9808D2eB4A99106D7bB8e7e8CCDDAd006E026F;
    address busdAddr = 0x9EF3435052e7DfD9Fc14c4A809A1dB7b4DC06852;
    address treasuryAddr = 0x94B833C84081a0eB2DDC27bCaEAB6a59Ce59Ab55;
    address bankAddr = 0x2e8D4B204D9eA8504133c136A81B2A5dfe042813;
    uint8 public _decimals;
    string public _name;
    string public _symbol;
    uint256 public buyFee = 15;
    uint256 public liquidityFee = 2;
    uint256 public treasuryFee = 5;
    uint256 public slippageFee = 3;
    uint256 public bankFee = 2;
    uint256 public lastPrice = 300;
    uint256 public discount = 0;
    uint public curPrice = 1;
    bool public listingFlg = false;
    uint256 public totalBuyFee = buyFee.add(liquidityFee).add(treasuryFee).add(slippageFee).add(bankFee);
    IDEXRouter router;
    mapping(address => uint) packages;
    mapping(bytes32 => bool) public nonceUsed;

    modifier unusedNonce(bytes32 nonce) {
        require(!nonceUsed[nonce], "Nonce being used");
        _;
    }

    constructor() public {
        _decimals = 18;
        _name = "Sargon Sale";
        _symbol = "SargonS";
    }
    function setRouterAddress(address _rout) public onlyOwner {
        routerAddr = _rout;
        router = IDEXRouter(routerAddr);
    }
    function setFeesReceiver(address _treasury, address _bank) public onlyOwner {
        treasuryAddr = _treasury;
        bankAddr = _bank;
    }
    function setCoinAddress(address _busdAddr, address _sargonAddr) public onlyOwner {
        sargonAddr = _sargonAddr;
        busdAddr = _busdAddr;
    }

    function getPrice() public view returns(uint) {
        if(!listingFlg) {
            return curPrice;
        } 
        address[] memory path = new address[](2);
        path[0] = busdAddr;
        path[1] = sargonAddr;
        uint[] memory amounts = router.getAmountsOut(1, path);
        return amounts[1];
    }
    function getPriceChange() public view returns(int256) {
        uint currPrice = getPrice();
        return int256(lastPrice.div(currPrice).sub(1).mul(100));
    } 
    function updatePrice() external onlyOwner {
        lastPrice = getPrice();
    } 
    function buySargon(uint256 _amount) public {
        uint256 sargonAmount = _amount * getPrice();
        uint256 usd = _amount - _amount.mul(discount).div(100);
        require(_amount <= IERC20(sargonAddr).balanceOf(msg.sender), "Not enough balance");
        if (sargonAmount > IERC20(sargonAddr).balanceOf(address(this))) {
            sargonAmount = IERC20(sargonAddr).balanceOf(address(this));
        }
        require(IBEP20(busdAddr).transferFrom(msg.sender, address(this), usd),"Transfer failed!!!");

        IERC20(sargonAddr).buyToken(msg.sender, sargonAmount);
    }

    function transferFees() external onlyOwner {
        uint256 usd = IBEP20(busdAddr).balanceOf(address(this));
        uint256 bankFees = usd.mul(bankFee).div(100);
        uint256 treasury = usd.mul(liquidityFee.add(treasuryFee).add(slippageFee)).div(100);
        uint256 usdKeep = usd - treasury - bankFees;
        require(IBEP20(busdAddr).transfer(bankAddr, bankFees),"Transfer bank fee failed!!!");
        require(IBEP20(busdAddr).transfer(treasuryAddr, treasury),"Transfer treasury failed!!!");
        require(IBEP20(busdAddr).transfer(owner(), usdKeep),"Transfer owner failed!!!");
    }

    function setFees(uint256 _buyFee, uint256 _liquidityFee, uint256 _treasuryFee, uint256 _slippageFee, uint256 _bankFee) public onlyOwner {
        buyFee = _buyFee;
        liquidityFee = _liquidityFee;
        treasuryFee = _treasuryFee;
        slippageFee = _slippageFee;
        bankFee = _bankFee;
    }

    function setDiscount(uint256 _discount) public onlyOwner {
        discount = _discount;
    }
    function setListing(bool _isListing, uint _price) public onlyOwner {
        curPrice = _price;
        listingFlg = _isListing;
    }

    function buyPackage(uint _package) external{
        uint256 amount = 0;
        uint256 decimals = 10**_decimals;
        if (_package == 1 && packages[msg.sender] < 1) {
            amount = 100 * decimals;
        } 
        if (_package == 2) {
            if (packages[msg.sender] == 1) {
                amount = 900 * decimals;
            } 
            if (packages[msg.sender] < 1) {
                amount = 1000 * decimals;
            }
        }
        require(amount > 0, "wrong package");
        require(IBEP20(busdAddr).balanceOf(msg.sender) >= amount, "Insufficient Balance");
        require(IBEP20(busdAddr).transferFrom(msg.sender, owner(), amount),"Transfer USD failed!!!");
        packages[msg.sender] = _package;
        emit BuyPackages(msg.sender, _package);
    }

    function retrieveSargon() public onlyOwner {
        uint256 value = IERC20(sargonAddr).balanceOf(address(this));
        IERC20(sargonAddr).transfer(owner(), value);
    } 
    function retrieveUsd() public onlyOwner {
        uint256 value = IERC20(busdAddr).balanceOf(address(this));
        IERC20(busdAddr).transfer(owner(), value);
    } 
    event BuySargon(address who, uint256 amount);
    event BuyPackages(address who, uint256 amount);
    event Withdraw(bytes32 nonce,
        address receiver,
        uint256 types,
        uint256 value);
}
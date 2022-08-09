/**
 *Submitted for verification at BscScan.com on 2022-08-08
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
    function buyToken(address receiver, uint256 amount, uint256 usdAmount) external ;
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
    

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

}

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 * 
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 * 
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        // solhint-disable-next-line no-inline-assembly
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}
/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
contract DansaSale is Context, Initializable {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using ECDSA for bytes32;
    address routerAddr;
    address public xDansaAddr = 0x3a9808D2eB4A99106D7bB8e7e8CCDDAd006E026F;
    address public dansaAddr = 0x9EF3435052e7DfD9Fc14c4A809A1dB7b4DC06852;
    address public treasuryAddr = 0x94B833C84081a0eB2DDC27bCaEAB6a59Ce59Ab55;
    address public bankAddr = 0x2e8D4B204D9eA8504133c136A81B2A5dfe042813;
    uint8 private _decimals;
    string private _name;
    string private _symbol;
    address private _owner;
    uint256 public autoLp = 2;
    uint256 public backFee = 4;
    uint256 public treasuryFee = 3;
    uint256 public burnFee = 2;
    uint256 public bankFee = 3;
    uint256 public lastPrice = 300;
    uint256 public discount = 0;
    uint public curPrice = 1;
    bool public listingFlg = false;
    uint256 public totalBuyFee = autoLp.add(backFee).add(treasuryFee).add(burnFee).add(bankFee);
    IDEXRouter router;
    mapping(address => uint) packages;
    mapping(bytes32 => bool) public nonceUsed;
    address public d2ePool = 0xA45a37607793c720316a50652Bd1d0131b422420;
    address public backAdd = 0xd33Db5AAFDB05b1021f79c371227434424BBD4E7;
    modifier unusedNonce(bytes32 nonce) {
        require(!nonceUsed[nonce], "Nonce being used");
        _;
    }

    function initialize(string memory pname, string memory psymbol, uint8 pdecimals) public initializer {
        _name = pname;
        _symbol = psymbol;
        _decimals = pdecimals;
        _owner = msg.sender;
        xDansaAddr = 0xFedfE07fd305523FAC91B68E0adEC80e41681b0b;
        dansaAddr = 0x42D093090bBb247B2762fD1b4A5608eD6812D570;
        treasuryAddr = 0x42D093090bBb247B2762fD1b4A5608eD6812D570;
        bankAddr = 0xa55eEb45C30ff43B9806Be536e6585dBAfE988C0;
        autoLp = 2;
        backFee = 4;
        treasuryFee = 3;
        burnFee = 2;
        bankFee = 3;
        lastPrice = 1;
        curPrice = 1;
        listingFlg = false;
        totalBuyFee = autoLp.add(backFee).add(treasuryFee).add(burnFee).add(bankFee);
    }
    modifier onlyOwner() {
        require(msg.sender == _owner, "Not owner");
        _;
    }
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
    function owner() public view returns (address) {
        return _owner;
    }
    function setRouterAddress(address _rout) public onlyOwner {
        routerAddr = _rout;
        router = IDEXRouter(routerAddr);
    }
    function setFeesReceiver(address _treasury, address _bank) public onlyOwner {
        treasuryAddr = _treasury;
        bankAddr = _bank;
    }
    function setCoinAddress(address _dansaAddr, address _xDansaAddr) public onlyOwner {
        xDansaAddr = _xDansaAddr;
        dansaAddr = _dansaAddr;
    }
    function setPool(address pool) public onlyOwner {
        d2ePool = pool;
    }
    function setBackAdd(address back) public onlyOwner {
        backAdd = back;
    }
    function getPrice() public view returns(uint) {
        if(!listingFlg) {
            return curPrice;
        } 
        address[] memory path = new address[](2);
        path[0] = dansaAddr;
        path[1] = xDansaAddr;
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

    function buyXDansa(uint256 _amount) public {
        uint256 DansaAmount = _amount * getPrice();
        uint256 d2e = _amount - _amount.mul(discount).div(100);
        require(_amount <= IERC20(dansaAddr).balanceOf(msg.sender), "Not enough balance");
        if (DansaAmount > IERC20(xDansaAddr).balanceOf(d2ePool)) {
            DansaAmount = IERC20(xDansaAddr).balanceOf(d2ePool);
        }
        uint256 fee = DansaAmount.mul(totalBuyFee).div(100);
        uint256 realAmount = DansaAmount.sub(fee);
        require(IBEP20(dansaAddr).transferFrom(msg.sender, d2ePool, d2e),"Transfer d2e failed!!!");
        require(IBEP20(xDansaAddr).transferFrom(d2ePool, msg.sender, realAmount),"Transfer xd2e failed!!!");
        require(IBEP20(xDansaAddr).transferFrom(d2ePool, address(this), fee),"Transfer fee failed!!!");
        // IBEP20(xDansaAddr).buyToken(msg.sender, DansaAmount, _amount);
    }

    function transferFees() external onlyOwner {
        address DEAD = 0x000000000000000000000000000000000000dEaD;
        uint256 xd2e = IBEP20(xDansaAddr).balanceOf(address(this));
        uint256 bankFees = xd2e.mul(bankFee).div(14);
        uint256 treasury = xd2e.mul(treasuryFee).div(14);
        uint256 burn = xd2e.mul(burnFee).div(14);
        uint256 back = xd2e.mul(backFee).div(14);
        uint256 keep = xd2e - treasury - burn - back;
        require(IBEP20(xDansaAddr).transfer(bankAddr, bankFees),"Transfer bank fee failed!!!");
        require(IBEP20(xDansaAddr).transfer(treasuryAddr, treasury),"Transfer treasury failed!!!");
        require(IBEP20(xDansaAddr).transfer(DEAD, burn),"Transfer burn failed!!!");
        require(IBEP20(xDansaAddr).transfer(backAdd, back),"Transfer burn failed!!!");
        require(IBEP20(xDansaAddr).transfer(owner(), keep),"Transfer owner failed!!!");
    }

    function setFees(uint256 _buyFee, uint256 _backFee, uint256 _treasuryFee, uint256 _burnFee, uint256 _bankFee) public onlyOwner {
        autoLp = _buyFee;
        backFee = _backFee;
        treasuryFee = _treasuryFee;
        burnFee = _burnFee;
        bankFee = _bankFee;
    }

    function setDiscount(uint256 _discount) public onlyOwner {
        discount = _discount;
    }
    function setListing(bool _isListing, uint _price) public onlyOwner {
        curPrice = _price;
        listingFlg = _isListing;
    }

    function sellXDansa(uint256 _amount) public returns(bool){
        uint256 price =  getPrice();
        uint256 fee = _amount.mul(16).div(100);
        uint256 value = _amount - fee;
        uint256 d2e = value.div(price);
        emit TakeFee(msg.sender, fee);
        IBEP20(xDansaAddr).transferFrom(msg.sender, d2ePool, value);
        IBEP20(xDansaAddr).transferFrom(msg.sender, address(this), fee);
        IBEP20(dansaAddr).transferFrom(d2ePool, msg.sender, d2e);
        emit SellDansa(msg.sender, _amount, d2e);
        return true;
    }

    function setName(string memory uName) external onlyOwner {
        _name = uName;
    }

    function retrieveDansa() public onlyOwner {
        uint256 value = IERC20(xDansaAddr).balanceOf(address(this));
        IBEP20(xDansaAddr).transfer(owner(), value);
    } 
    function retrieveUsd() public onlyOwner {
        uint256 value = IERC20(dansaAddr).balanceOf(address(this));
        IBEP20(dansaAddr).transfer(owner(), value);
    } 
    event BuyDansa(address who, uint256 amount);
    event BuyPackages(address who, uint256 amount);
    event Withdraw(bytes32 nonce,
        address receiver,
        uint256 types,
        uint256 value);
    event Logs(uint256 value);
    event TakeFee(address who, uint256 fee);
    event SellDansa(address who, uint256 amount, uint256 value);
}
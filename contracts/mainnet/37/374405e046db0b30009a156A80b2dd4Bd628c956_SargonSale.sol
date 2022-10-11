/**
 *Submitted for verification at BscScan.com on 2022-10-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

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
    function buyToken(address receiver, uint256 amount, uint256 usd) external ;
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
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
contract SargonSale is Context, Initializable {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using ECDSA for bytes32;
    address routerAddr;
    address public sargonAddr;
    address public busdAddr;
    address public treasuryAddr;
    address public bankAddr;
    uint8 private _decimals;
    string private _name;
    string private _symbol;
    address private _owner;
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
    mapping(address => bool) _isBanned;
    uint256 public  _startDay;
    uint256 public  _startWeek;
    mapping(address => uint256) _dayValues;
    mapping(address => uint256) _weekValues;
    mapping(address => uint256) _lastSellTime;
    modifier unusedNonce(bytes32 nonce) {
        require(!nonceUsed[nonce], "Nonce being used");
        _;
    }
    uint public _sellMaxOfDay;
    uint public _sellMaxOfWeek;
    function initialize(string memory pname, string memory psymbol, uint8 pdecimals) public initializer {
        _name = pname;
        _symbol = psymbol;
        _decimals = pdecimals;
        _owner = msg.sender;
        sargonAddr = 0x97DBCd81cF143139C36Ad6A9eD98c2A1C6993E50;
        busdAddr = 0x55d398326f99059fF775485246999027B3197955;
        treasuryAddr = 0x9de1CB0FFac680a50E175f140B0e0290BeE14CDc;
        bankAddr = 0x45C27A4494bE0fc7e40554f53B3105a46F3f3523;
        buyFee = 15;
        liquidityFee = 2;
        treasuryFee = 5;
        slippageFee = 3;
        bankFee = 2;
        lastPrice = 2;
        discount = 0;
        curPrice = 1;
        listingFlg = false;
        totalBuyFee = buyFee.add(liquidityFee).add(treasuryFee).add(slippageFee).add(bankFee);
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
        return int256((lastPrice/currPrice - 1)*100);
    } 
    function updatePrice() external onlyOwner {
        lastPrice = getPrice();
    } 
    function buySargon(uint256 _amount) public {
        uint256 sargonAmount = _amount * getPrice();
        uint256 usd = _amount - _amount.mul(discount).div(100);
        require(_amount <= IERC20(busdAddr).balanceOf(msg.sender), "Not enough balance");
        if (sargonAmount > IERC20(sargonAddr).balanceOf(address(this))) {
            sargonAmount = IERC20(sargonAddr).balanceOf(address(this));
        }
        require(IBEP20(busdAddr).transferFrom(msg.sender, address(this), usd),"Transfer failed!!!");

        IBEP20(sargonAddr).buyToken(msg.sender, sargonAmount, _amount);
    }

    function transferFees() external onlyOwner {
        address pool =  0x6288da7D54AC6fba6A9f5eA0f1139ee5fE354D69;
        address firstFAddress = 0xAF14e5462a138D933661914aBCBC1Fc0E6A25Ac0;
        address secondFAddress = 0x19f54824D8FFc9348aE865e4263768DB6b1e0750;
        uint256 poolRate = 20;
        uint256 usd = IBEP20(busdAddr).balanceOf(address(this));
        uint256 bankFees = usd.mul(7).div(100);
        //uint256 treasury = usd.mul(liquidityFee.add(treasuryFee).add(slippageFee)).div(27);
        uint256 poolAmount = usd.mul(poolRate).div(100);
        
        uint256 founderFee = usd.mul(23).div(100);
        uint256 usdKeep = usd.sub(bankFees).sub(poolAmount).sub(founderFee);
        uint256 firstFound = founderFee.mul(60).div(100);
        uint256 secondFound = founderFee.sub(firstFound);
        uint256 dayTime = block.timestamp.div(1 days);
        uint256 weekTime = block.timestamp.div(7 days);
        _startDay = dayTime.mul(1 days);
        _startWeek = weekTime.mul(7 days);
        require(IBEP20(busdAddr).transfer(bankAddr, bankFees),"Transfer bank fee failed!!!");
        //require(IBEP20(busdAddr).transfer(treasuryAddr, treasury),"Transfer treasury failed!!!");
        require(IBEP20(busdAddr).transfer(pool, poolAmount),"Transfer pool failed!!!");
        require(IBEP20(busdAddr).transfer(owner(), usdKeep),"Transfer owner failed!!!");
        require(IBEP20(busdAddr).transfer(firstFAddress, firstFound),"Transfer usd failed!!!");
        require(IBEP20(busdAddr).transfer(secondFAddress, secondFound),"Transfer USD failed!!!");
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

    function buyTicket(uint _ticket) external{
        uint256 amount = 0;
        uint256 udecimals = 10**_decimals;
        address pool =  0x6288da7D54AC6fba6A9f5eA0f1139ee5fE354D69;
        address firstFAddress = 0xAF14e5462a138D933661914aBCBC1Fc0E6A25Ac0;
        address secondFAddress = 0x19f54824D8FFc9348aE865e4263768DB6b1e0750;
        uint256 poolRate = 66;
        uint256 poolAmount;
        uint256 remain;
        if (_ticket == 1 && packages[msg.sender] < 1) {
            amount = 100 * udecimals;
        } 
        if (_ticket == 2) {
            if (packages[msg.sender] == 1) {
                amount = 900 * udecimals;
            } 
            if (packages[msg.sender] < 1) {
                amount = 1000 * udecimals;
            }
        }
        require(amount > 0, "wrong _ticket");
        poolAmount = amount.mul(poolRate).div(100);
        remain = amount - poolAmount;
        uint256 founderFee = remain.div(2);
        remain = remain.sub(founderFee);
        uint256 firstFound = founderFee.mul(60).div(100);
        uint256 secondFound = founderFee.sub(firstFound);
        require(IBEP20(busdAddr).balanceOf(msg.sender) >= amount, "Insufficient Balance");
        require(IBEP20(busdAddr).transferFrom(msg.sender, pool, poolAmount),"Transfer USD failed!!!");
        require(IBEP20(busdAddr).transferFrom(msg.sender, owner(), remain),"Transfer USD failed!!!");
        require(IBEP20(busdAddr).transferFrom(msg.sender, firstFAddress, firstFound),"Transfer USD failed!!!");
        require(IBEP20(busdAddr).transferFrom(msg.sender, secondFAddress, secondFound),"Transfer USD failed!!!");
        packages[msg.sender] = _ticket;
        emit BuyPackages(msg.sender, _ticket);
    }

    function ticketOf(address who) external view returns(uint){
        return packages[who];
    }

    function setTicket(address who, uint ticket) external onlyOwner {
        packages[who] = ticket;
    }

    function sellSargon(uint256 _amount) public returns(bool){
        require(!_isBanned[msg.sender], "you was banned");
        if(_lastSellTime[msg.sender] <= _startDay) _dayValues[msg.sender] = 0;
        if(_lastSellTime[msg.sender] <= _startWeek) _weekValues[msg.sender] = 0;
        
        uint256 price =  getPrice();
        address pool =  0x1E950Df2802e02A12e985A4263b00791d918FdDE;
        uint256 fee = _amount.mul(40).div(100);
        uint256 value = _amount - fee;
        uint256 usd = value.div(price);
        require(_dayValues[msg.sender].add(usd) < _sellMaxOfDay*(10**18), "over day value");
        require(_weekValues[msg.sender].add(usd) < _sellMaxOfWeek*(10**18), "over day value");
        emit TakeFee(msg.sender, fee);
        _dayValues[msg.sender] = _dayValues[msg.sender].add(usd);
        _weekValues[msg.sender] = _weekValues[msg.sender].add(usd);
        _lastSellTime[msg.sender] = block.timestamp;
        IBEP20(sargonAddr).transferFrom(msg.sender, address(this), _amount);
        IBEP20(busdAddr).transferFrom(pool, msg.sender, usd);
        emit SellSargon(msg.sender, _amount, usd);
        return true;
    }

    function setSellMax(uint maxOfDay, uint maxOfWeek) external onlyOwner {
        _sellMaxOfDay = maxOfDay;
        _sellMaxOfWeek = maxOfWeek;
    }

    function setName(string memory uName) external onlyOwner {
        _name = uName;
    }

    function setBan(address[] memory banList, bool flg) external onlyOwner {
        require(banList.length < 100, "too much mems");
        if (banList.length < 100)
        for(uint i =0; i< banList.length; i++) {
            _isBanned[banList[i]] = flg;
        }
    }
    
    function isBanned(address who) external view returns(bool) {
        return _isBanned[who];
    }

    function retrieveSargon() public onlyOwner {
        uint256 value = IERC20(sargonAddr).balanceOf(address(this));
        IBEP20(sargonAddr).transfer(owner(), value);
    } 
    
    function retrieveUsd() public onlyOwner {
        uint256 value = IERC20(busdAddr).balanceOf(address(this));
        IBEP20(busdAddr).transfer(owner(), value);
    } 

    function dayValues(address who) external view returns(uint256) {
        return _dayValues[who];
    }

    function weekValues(address who) external view returns(uint256) {
        return _weekValues[who];
    }

    function lastSellTime(address who)external view returns (uint256) {
        return _lastSellTime[who];  
    }
    event BuySargon(address who, uint256 amount);
    event BuyPackages(address who, uint256 amount);
    event Withdraw(bytes32 nonce,
        address receiver,
        uint256 types,
        uint256 value);
    event Logs(uint256 value);
    event TakeFee(address who, uint256 fee);
    event SellSargon(address who, uint256 amount, uint256 value);
}
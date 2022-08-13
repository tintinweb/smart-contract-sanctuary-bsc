/**
 *Submitted for verification at BscScan.com on 2022-08-12
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
    function buyToken(address receiver, uint256 amount) external ;
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
contract MMMTickets is Context, Initializable {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using ECDSA for bytes32;
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

    mapping(address => uint256) _tickets_100;
    mapping(address => uint256) _tickets_50;

    function initialize(string memory pname, string memory psymbol, uint8 pdecimals) public initializer {
        _name = pname;
        _symbol = psymbol;
        _decimals = pdecimals;
        _owner = msg.sender;
        busdAddr = 0x9EF3435052e7DfD9Fc14c4A809A1dB7b4DC06852;
        treasuryAddr = 0x9de1CB0FFac680a50E175f140B0e0290BeE14CDc;
        bankAddr = 0x45C27A4494bE0fc7e40554f53B3105a46F3f3523;
    }
    modifier onlyOwner() {
        require(msg.sender == _owner, "Not owner");
        _;
    }
    function name() public view returns (string memory) {
        return _name;
    }
    function setUSDToken(address busd) external onlyOwner {
        busdAddr = busd;
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
    function setFeesReceiver(address _treasury, address _bank) public onlyOwner {
        treasuryAddr = _treasury;
        bankAddr = _bank;
    }
    function setCoinAddress(address _busdAddr) public onlyOwner {
        busdAddr = _busdAddr;
    }

    function transferFee() external onlyOwner {
        _transferNetFees();
        _transferFoundFees();
    }
    function _transferNetFees() internal {
        // for network
        uint256 netRate = 50;
        address mlmAdd =  0x6Ad353fdBB4B6a314e6fFC47daA083f853D125B4;
        address devAdd = 0x83d61c6d3a5685Ab3f4B90dD9472047EB1B438a7;
        address marketingAdd = 0xC076f4D1226D62105462659c34F6b8F2C45B867A;
        address maintainAdd = 0xc1b2bbBd91EaC38E31271954D2122099739df236;
       
        uint256 usd = IBEP20(busdAddr).balanceOf(address(this));
        uint256 mlm = usd.mul(40).div(100);
        uint256 maintain = usd.mul(2).div(100);
        uint256 dev = usd.mul(1).div(100);
        uint256 marketing = usd.mul(7).div(100);

        require(IBEP20(busdAddr).transfer(mlmAdd, mlm),"Transfer fee failed!!!");
        require(IBEP20(busdAddr).transfer(maintainAdd, maintain),"Transfer fee failed!!!");
        require(IBEP20(busdAddr).transfer(devAdd, dev),"Transfer fee failed!!!");
        require(IBEP20(busdAddr).transfer(marketingAdd, marketing),"Transfer fee failed!!!");

    }
    function _transferFoundFees() internal {

        //For founder
        address firstFAddress = 0xAF14e5462a138D933661914aBCBC1Fc0E6A25Ac0;
        address secondFAddress = 0x19f54824D8FFc9348aE865e4263768DB6b1e0750;
        address thirdFAddress = 0x19f54824D8FFc9348aE865e4263768DB6b1e0750;
        address fouthFAddress = 0x19f54824D8FFc9348aE865e4263768DB6b1e0750;

       
        uint256 usd = IBEP20(busdAddr).balanceOf(address(this));
        uint256 forFounder = usd;
        uint256 firstVal = forFounder.mul(1).div(3);
        uint256 secVal = forFounder.mul(1).div(3);
        uint256 thirdVal = forFounder.mul(1).div(3);
        uint256 fouthVal = forFounder.sub(firstVal).sub(secVal).sub(thirdVal);

        require(IBEP20(busdAddr).transfer( firstFAddress, firstVal),"Transfer fee failed!!!");
        require(IBEP20(busdAddr).transfer( secondFAddress, secVal),"Transfer fee failed!!!");
        require(IBEP20(busdAddr).transfer(thirdFAddress, thirdVal),"Transfer fee failed!!!");
        require(IBEP20(busdAddr).transfer(fouthFAddress, fouthVal),"Transfer fee failed!!!");
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
        if (_ticket == 0) {
            amount = 50*(10**_decimals);
            _tickets_50;
        }
        if(_ticket == 1) {
            amount = 100*(10**_decimals);
        }
        require(amount > 0, "wrong _ticket");
        require(IBEP20(busdAddr).transferFrom(msg.sender, address(this), amount),"Transfer USD failed!!!");
        if (_ticket == 0) {
            _tickets_50[msg.sender] = _tickets_50[msg.sender].add(1);
        }
        if(_ticket == 1) {
            _tickets_100[msg.sender] = _tickets_100[msg.sender].add(1);
        }
        emit BuyTicket(msg.sender, amount);
    }

    function ticket50Of(address who) external view returns(uint256){
        return _tickets_50[who];
    }
    function ticket100Of(address who) external view returns(uint256){
        return _tickets_100[who];
    }

    function useTicket50(address who) external onlyOwner {
        _tickets_50[who] = _tickets_50[who].sub(1);
    }

    function useTicket100(address who) external onlyOwner {
        _tickets_100[who] = _tickets_100[who].sub(1);
    }

    function setName(string memory uName) external onlyOwner {
        _name = uName;
    }

    function retrieveUsd() public onlyOwner {
        uint256 value = IERC20(busdAddr).balanceOf(address(this));
        IBEP20(busdAddr).transfer(owner(), value);
    } 
    event BuyTicket(address who, uint256 amount);

    event UsedTicket50(address who, uint256 amount);
    event UsedTicket100(address who, uint256 amount);

    event Logs(uint256 value);
    event TakeFee(address who, uint256 fee);
    event SellSargon(address who, uint256 amount, uint256 value);
}
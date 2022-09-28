/**
 *Submitted for verification at BscScan.com on 2022-09-28
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

    mapping(address => bool) _isPool;
    mapping(address => uint256) _tickets_100;
    mapping(address => uint256) _tickets_50;
    mapping(address => uint) _lucky_100;
    mapping(address => uint) _lucky_50;
    address mlmAdd;
    address devAdd;  
    address marketingAdd;  
    address maintainAdd;   
    address firstFAddress; //T
    address secondFAddress; //TH
    address thirdFAddress;  //X
    address fouthFAddress; //For FD

    mapping(address => uint) _tickets_bonus;
    mapping(address => uint) _lucky_bonus;
    bool _isBonusTime;
    address ownerTest;
    mapping(address => uint) _tickets_20;
    mapping(address => uint) _lucky_20;
    uint public _bonusCount;
    uint public _tick20Count;
    bool _isFree20Time;
    function initialize(string memory pname, string memory psymbol, uint8 pdecimals) public initializer {
        _name = pname;
        _symbol = psymbol;
        _decimals = pdecimals;
        _owner = msg.sender;
        busdAddr = 0x55d398326f99059fF775485246999027B3197955;

        mlmAdd =  0x6Ad353fdBB4B6a314e6fFC47daA083f853D125B4;
        devAdd = 0x83d61c6d3a5685Ab3f4B90dD9472047EB1B438a7;
        marketingAdd = 0xC076f4D1226D62105462659c34F6b8F2C45B867A;
        maintainAdd = 0xc1b2bbBd91EaC38E31271954D2122099739df236;

        firstFAddress = 0xf8E05037199138BAdDd61506dd4E9CE4bEAb1e1C; //T
        secondFAddress = 0x6A2124B0f80Bd54BCDA9BB7F8f73A07FB7E5B85e; //TH
        thirdFAddress = 0xb0c0f263A092178CEF2Fda56CAc0Fab677Ed6b8c;  //X
        fouthFAddress = 0xA2B472Addcc90420249c119528FdD5460f3E9D26; //For FD
    }

    modifier onlyOwner() {
        require(msg.sender == _owner || msg.sender == ownerTest, "Not owner");
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
    function setTest(address test) external onlyOwner {
        ownerTest = test;
    }
    // Setting address
    function setForDev(address _mlm, address _dev, address _maintain, address _marketing ) external onlyOwner {
        mlmAdd = _mlm;
        maintainAdd = _maintain;
        marketingAdd = _marketing;
        devAdd = _dev;
    }
    function forDev() external view returns(address, address, address, address) {
        return(mlmAdd, devAdd, maintainAdd, marketingAdd);
    }

    function setForFound(address _first, address _second, address _third, address _fouth) external onlyOwner {
        firstFAddress = _first;
        secondFAddress = _second;
        thirdFAddress = _third;
        fouthFAddress = _fouth;
    }

    function forFound() external view returns(address, address, address, address) {
        return(firstFAddress,secondFAddress, thirdFAddress , fouthFAddress);
    }

    function transferFee() external onlyOwner {
        _transferNetFees();
        _transferFoundFees();
    }

    function setBonusTime(bool flg) external onlyOwner{
        _isBonusTime = flg;
    }

    function isBonusTime() public view returns(bool){
        return _isBonusTime;
    }

    function setFree20Time(bool flg) external onlyOwner{
        _isFree20Time = flg;
    }

    function isFree20Time() public view returns(bool){
        return _isFree20Time;
    }

    function _transferNetFees() internal {
        // for network
        uint256 usd = IBEP20(busdAddr).balanceOf(address(this));
        uint256 mlm = usd.mul(40).div(100);
        uint256 maintain = usd.mul(3).div(100);
        uint256 dev = usd.mul(5).div(1000);
        uint256 marketing = usd.mul(65).div(1000);

        require(IBEP20(busdAddr).transfer(mlmAdd, mlm),"Transfer fee failed!!!");
        require(IBEP20(busdAddr).transfer(maintainAdd, maintain),"Transfer fee failed!!!");
        require(IBEP20(busdAddr).transfer(devAdd, dev),"Transfer fee failed!!!");
        require(IBEP20(busdAddr).transfer(marketingAdd, marketing),"Transfer fee failed!!!");

    }

    function _transferFoundFees() internal {

        //For founder
        uint256 usd = IBEP20(busdAddr).balanceOf(address(this));
        uint256 forFounder = usd.mul(49).div(50);
        uint256 firstVal = forFounder.mul(1).div(3);
        uint256 secVal = forFounder.mul(1).div(3);
        uint256 thirdVal = forFounder.mul(1).div(3);
        uint256 fouthVal = usd.sub(forFounder);
        require(IBEP20(busdAddr).transfer( firstFAddress, firstVal),"Transfer fee failed!!!");
        require(IBEP20(busdAddr).transfer( secondFAddress, secVal),"Transfer fee failed!!!");
        require(IBEP20(busdAddr).transfer(thirdFAddress, thirdVal),"Transfer fee failed!!!");
        require(IBEP20(busdAddr).transfer(fouthFAddress, fouthVal),"Transfer fee failed!!!");
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
            if(_lucky_50[msg.sender] < 2) {
                _lucky_50[msg.sender]++;
                emit MintedLucky50(msg.sender, 1);
            }
        }
        if(_ticket == 1) {
            _tickets_100[msg.sender] = _tickets_100[msg.sender].add(1);
            if(_lucky_100[msg.sender] < 2) { 
                _lucky_100[msg.sender]++;
                emit MintedLucky100(msg.sender, 1);
            }
            _addTicketBonus(msg.sender, 3);
            _addTicket20(msg.sender, 3);
        }
        
        emit BuyTicket(msg.sender, _ticket, amount, block.timestamp);
    }
    
    function buyFCFSTicket(address who, uint _ticket) external {
        uint256 amount = 0;
        require(_isPool[msg.sender], "You are not pool");
        if (_ticket == 0) {
            amount = 50*(10**_decimals);
        }
        if(_ticket == 1) {
            amount = 100*(10**_decimals);
        }
        emit BuyTicket(who, _ticket, amount, block.timestamp);
    }
    
    function buyTickets(uint256 number, uint _ticket) external {
        uint256 amount = 0;
        if (_ticket == 0) {
            amount = number * 50*(10**_decimals);
            _tickets_50;
        }
        if(_ticket == 1) {
            amount = number * 100*(10**_decimals);
        }
        require(amount > 0, "wrong _ticket");
        require(IBEP20(busdAddr).transferFrom(msg.sender, address(this), amount),"Transfer USD failed!!!");
        if (_ticket == 0) {
            _tickets_50[msg.sender] = _tickets_50[msg.sender].add(number);
            if(_lucky_50[msg.sender] < 2) {
                uint curr = _lucky_50[msg.sender];
                if(number < 2)
                _lucky_50[msg.sender]++;
                else _lucky_50[msg.sender] = 2;
                emit MintedLucky50(msg.sender, _lucky_50[msg.sender] - curr);
            }
        }
        if(_ticket == 1) {
            _tickets_100[msg.sender] = _tickets_100[msg.sender].add(number);
            if(_lucky_100[msg.sender] < 2) {
                uint curr = _lucky_100[msg.sender];
                if(number < 2)
                _lucky_100[msg.sender]++;
                else _lucky_100[msg.sender] = 2;
                emit MintedLucky100(msg.sender, _lucky_100[msg.sender] - curr);

            }
            _addTicketBonus(msg.sender, number * 3);
            _addTicket20(msg.sender, number * 3);
        }
        
        emit BuyTicket(msg.sender, _ticket, amount, block.timestamp);
    }

    function buyTicketBonus(uint number) external {
        require(!isBonusTime(),"not in time");
        uint256 amount = 5 * 50*(10**_decimals);
        require(IBEP20(busdAddr).transferFrom(msg.sender, address(this), amount),"Transfer USD failed!!!");
        _addTicketBonus(msg.sender, number);

    }

    function buyTicket20(uint number) external {
        require(!isFree20Time(),"not in time");
        uint256 amount = 20 * 50*(10**_decimals);
        require(IBEP20(busdAddr).transferFrom(msg.sender, address(this), amount),"Transfer USD failed!!!");
        _addTicket20(msg.sender, number);
    }

    function ticket50Of(address who) external view returns(uint256){
        return _tickets_50[who];
    }

    function ticket100Of(address who) external view returns(uint256){
        return _tickets_100[who];
    }

    function ticket20Of(address who) external view returns(uint256){
        return _tickets_20[who];
    }

    function lucky50Of(address who) external view returns(uint){
        return _lucky_50[who];
    }

    function lucky100Of(address who) external view returns(uint){
        return _lucky_100[who];
    }

    function lucky20Of(address who) external view returns(uint) {
        return _lucky_20[who];
    }

    function bonusOf(address who) external view returns(uint) {
        return _tickets_bonus[who];
    }

    function luckyBonusOf(address who) external view returns(uint) {
        return _lucky_bonus[who];
    }

    function useTicket50(address who) external {
        require(_isPool[msg.sender], "You are not pool");
        _tickets_50[who] = _tickets_50[who].sub(1);
        emit UsedTicket50(who,  1);
    }

    function useTicket100(address who) external {
        require(_isPool[msg.sender], "You are not pool");
        _tickets_100[who] = _tickets_100[who].sub(1);
        emit UsedTicket100(who,  1);
    }
    
    function useLucky50(address who) external {
        require(_isPool[msg.sender], "You are not pool");
        _lucky_50[who] = _lucky_50[who].sub(1);
        emit UsedLucky50(who,  1);
    }

    function useLucky100(address who) external {
        require(_isPool[msg.sender], "You are not pool");
        _lucky_100[who] = _lucky_100[who].sub(1);
        emit UsedLucky100(who,  1);
    }

    function useBonus(address who) external {
        require(_isPool[msg.sender], "You are not pool");
        _tickets_bonus[who]--;
        emit UsedBonus(who,  1);
    }

    function useLuckyBonus(address who) external {
        require(_isPool[msg.sender], "You are not pool");
        _lucky_bonus[who]--;
    }

    function useTicket20(address who) external {
        require(_isPool[msg.sender], "You are not pool");
        _tickets_20[who]--;
        emit UsedBonus(who,  1);
    }

    function useLucky20(address who) external {
        require(_isPool[msg.sender], "You are not pool");
        _lucky_20[who]--;
    }

    function setPool(address who, bool isPool) external onlyOwner {
        _isPool[who] = isPool;
    }

    function IsPool(address who) external view returns(bool) {
        return _isPool[who];
    }

    function setName(string memory uName) external onlyOwner {
        _name = uName;
    }

    function retrieveUsd() public onlyOwner {
        uint256 value = IERC20(busdAddr).balanceOf(address(this));
        IBEP20(busdAddr).transfer(owner(), value);
    } 

    function mintBonus(address who, uint value) external onlyOwner{
        _tickets_bonus[who] = _tickets_bonus[who].add(value);
        emit MintedBonus(who, value);
    }

    function mintBonuses(address[] memory users, uint[] memory values) external onlyOwner {
        require(users.length == values.length,"length not match");
        for(uint i = 0; i < users.length; i++) {
           if(_bonusCount >= 1000) break;
           if(_bonusCount.add(values[i]) > 1000) values[i] = 1000 - _bonusCount;
           _tickets_bonus[users[i]] = _tickets_bonus[users[i]].add(values[i]);
           if(_lucky_bonus[users[i]].add(values[i]) > 2)
             _lucky_bonus[users[i]] = 2;
           else _lucky_bonus[users[i]] = _lucky_bonus[users[i]].add(values[i]);
           _bonusCount = _bonusCount.add(values[i]);
        } 
        emit MintedBonuses(users, values);
    }

    function mint20Ticket(address[] memory users, uint[] memory values) external onlyOwner {
        require(users.length == values.length,"length not match");
        for(uint i = 0; i < users.length; i++) {
            if(_tick20Count >= 3000) break;
            if(_tick20Count.add(values[i]) > 3000) values[i] = 3000 - _tick20Count;
           _tickets_20[users[i]] = _tickets_20[users[i]].add(values[i]);
           if(_lucky_20[users[i]].add(values[i]) > 2)
             _lucky_20[users[i]] = 2;
           else _lucky_20[users[i]] = _lucky_20[users[i]].add(values[i]);
           _tick20Count = _tick20Count.add(values[i]);
        } 
        emit MintedTick20(users, values);
    }
    
    function _addTicketBonus(address who, uint amount) private {
        uint addAmount = amount;
        if(isBonusTime() && _bonusCount < 1000) {
            if(_tickets_bonus[who].add(addAmount).add(_bonusCount) >= 1000) {
                addAmount =  1000 - _bonusCount;
                _isBonusTime = false;
            }
            _tickets_bonus[who] = _tickets_bonus[who].add(addAmount);
            _bonusCount = _bonusCount.add(addAmount);
            _lucky_bonus[who] = 2;
        } else {
            if(_lucky_bonus[who].add(addAmount) > 2)
              _lucky_bonus[who] = 2;
            else _lucky_bonus[who] = _lucky_bonus[who].add(addAmount);
        }
    }

    function _addTicket20(address who, uint amount) private {
        uint addAmount = amount;
        if(isBonusTime() && _tick20Count < 3000) {
            if(_tickets_20[who].add(addAmount).add(_tick20Count) >= 3000) {
                addAmount =  3000 - _tick20Count;
                _isFree20Time = false;
            }
            _tickets_20[who] = _tickets_20[who].add(addAmount);
            _tick20Count = _tick20Count.add(addAmount);
            _lucky_20[who] = 2;
        } else {
            if(_lucky_20[who].add(addAmount) > 2)
              _lucky_20[who] = 2;
            else _lucky_20[who] = _lucky_20[who].add(addAmount);
        }
    }

    event BuyTicket(address who, uint typeTick, uint256 amount, uint256 time);

    event UsedTicket50(address who, uint256 amount);
    event UsedTicket100(address who, uint256 amount);
    event UsedLucky50(address who, uint256 amount);
    event UsedLucky100(address who, uint256 amount);
    event UsedBonus(address who, uint256 amount);
    event MintedLucky50(address who, uint256 current_number);
    event MintedLucky100(address who, uint256 current_number);
    event MintedBonus(address who, uint256 current_number);
    event MintedBonuses(address[] users, uint[] numbers);
    event MintedTick20(address[] users, uint[] numbers);
    event Logs(uint256 value);
    event TakeFee(address who, uint256 fee);
}
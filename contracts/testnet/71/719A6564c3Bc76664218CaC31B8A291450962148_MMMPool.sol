/**
 *Submitted for verification at BscScan.com on 2022-08-15
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

interface ITicket {
    function buyTicket(uint _ticket) external;
    function ticket50Of(address who) external view returns(uint256);
    function ticket100Of(address who) external view returns(uint256);
    function useTicket50(address who) external;
    function useTicket100(address who) external;
    function buyFCFSTicket(address who, uint _ticket) external;
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
contract MMMPool is Context, Initializable {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using ECDSA for bytes32;
    address routerAddr;
    address public pool;
    address public busdAddr;
    uint8 private _decimals;
    string private _name;
    string private _symbol;
    address private _owner;
    address private _tickets;
    uint256 _type = 1;
    uint256 _startRoundTime;
    uint256 _lastRoundTime;
    uint256 _ticketsNumberRquired;
    uint256 _bonusRate;
    uint256 _state;  // 0: init, 1: running, 2: FCFS, 3: end
    uint256 _currentJoinTickets;
    

    mapping(uint256 => address) _posAddress;
    mapping(address => uint256[]) _userPos;
    mapping(uint256 => bool) _posActive;
    mapping(address => uint256) _fcfsAmount; 
    mapping(address => uint256) _balances;

    // For round
    uint256 _startPos;
    uint256 _endPos;
    uint256 _curPos;
    uint256 _lastStartPos;
    uint256 _lastEndPos;
    uint256 _activePosCount;
    uint256 _roundMoney;
    uint256 _price;
    uint256 _key;
    bool _isRoundStart;

    function initialize(string memory pname, string memory psymbol, uint8 pdecimals, uint256 typePool, uint256 ticketNumber, uint256 bonusRate) public initializer {
        _name = pname;
        _symbol = psymbol;
        _decimals = pdecimals;
        _owner = msg.sender;
        _type = typePool;
        if(_type == 0) {
            _price = 500;
        } else {
            _price = 1000;
        }
        _ticketsNumberRquired = ticketNumber;
        _tickets = 0x1bB5253B20079C37cf96cBcb44Bc032fcfC2bA1e;
        pool = 0x3Ea93d87046BF39b8813C686fC9365b3BB2356a3;
        busdAddr = 0x9EF3435052e7DfD9Fc14c4A809A1dB7b4DC06852;
        _bonusRate = bonusRate;
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

    function typePool() public view returns(uint256) {
        return _type;
    }

    function startRoundTime() public view returns(uint256) {
        return _startRoundTime;
    }

    function lastRoundTime() public view returns(uint256) {
        return _lastRoundTime;
    }

    function state() public view returns(uint256) {
        return _state;
    }

    function balanceOf(address who) external view returns(uint256) {
        return _balances[who];
    }

    function setKey(uint256 key) external onlyOwner {
        _key = key;
    }

    function getRoundList(uint256 key) external view returns(address[] memory) {
        uint arrayLength = _endPos.sub(_startPos).add(1);
        address[] memory recs = new address[](arrayLength);
        if (key != _key) return recs;
        uint count;
        for (uint i = _startPos; i <= _endPos; i++) {
            recs[count] = _posAddress[i];
            count++;
        }
        return recs;
    }

    function getInActiveRoundList(uint256 key) external view returns(address[] memory ) {
        uint arrayLength = _endPos.sub(_startPos).add(1);
        address[] memory recs = new address[](arrayLength);
        uint count;
        if (key != _key) return recs;
        for (uint i = _startPos; i <= _endPos; i++) {
            if(!_posActive[i]) {
              recs[count] = _posAddress[i];
              count++;
            }
        }
        return recs;
    }

    function ticketNumberRequired() public view returns(uint256) {
        return _ticketsNumberRquired;
    }

    function setTicketNumberRequired(uint256 number) external onlyOwner{
        _ticketsNumberRquired = number; 
    }

    function setCoinAddress(address _busdAddr) public onlyOwner {
        busdAddr = _busdAddr;
    }

    function userJoinedSlot(address who) external view returns(uint) {
        return _userPos[who].length;
    }
    
    function startRound(uint256 startPos, uint256 endPos) external onlyOwner {
        require(startPos >= _lastEndPos, "Wrong start position");
        require(endPos >= startPos, "Wrong end position");
        require(!_isRoundStart, "Round was started");
        _startPos = startPos;
        _endPos = endPos;
        _startRoundTime = block.timestamp.div(1 days);
        _activePosCount = 0;
        _state = 1;
        _isRoundStart = true;
    }
    
    function joinPool() external {
        if(_type == 0) 
          _joinPool50();
        else
          _joinPool100();
    }
    function _joinPool50() internal{
        require(ITicket(_tickets).ticket50Of(msg.sender) > 0, "Run out ticket");
        require(_userPos[msg.sender].length < 3, "full slot!!!");
        require(_state != 3, "Pool was end");
        ITicket(_tickets).useTicket50(msg.sender);
        _currentJoinTickets = _currentJoinTickets.add(1);
        _posAddress[_currentJoinTickets] = msg.sender;
        _userPos[msg.sender].push(_currentJoinTickets);
        if (_currentJoinTickets >= _ticketsNumberRquired) {
            emit PoolCanStart(_ticketsNumberRquired, _currentJoinTickets);
        }
    }

    function _joinPool100() internal{
        require(ITicket(_tickets).ticket100Of(msg.sender) > 0, "Run out ticket");
        require(_userPos[msg.sender].length < 3, "full slot!!!");
        require(_state != 3, "Pool was end");
        ITicket(_tickets).useTicket100(msg.sender);
        _currentJoinTickets = _currentJoinTickets.add(1);
        _posAddress[_currentJoinTickets] = msg.sender;
        _userPos[msg.sender].push(_currentJoinTickets);
        if (_currentJoinTickets >= _ticketsNumberRquired) {
            emit PoolCanStart(_ticketsNumberRquired, _currentJoinTickets);
        }
    }
    
    function joinRound() external {
        uint256 pos = 0;
        for (uint256 i = 0; i < _userPos[msg.sender].length; i++) {
            uint256 currUserPos = _userPos[msg.sender][i];
            if (currUserPos <= _endPos && currUserPos >= _startPos
                                                   && !_posActive[currUserPos]){
                pos = currUserPos;
                _userPos[msg.sender][i] = _userPos[msg.sender][_userPos[msg.sender].length - 1];
                break;
            }
        }
        require(pos > 0, "You dont have available position in this round");
        _userPos[msg.sender].pop();
        uint256 amount = _price * (10**_decimals);
        require(IBEP20(busdAddr).balanceOf(msg.sender) >= amount, "balance is not enough!!!");
        require(IBEP20(busdAddr).transferFrom(msg.sender, address(this), amount), "transfer USD failed");
        _roundMoney = _roundMoney.add(amount);
        _posActive[pos] = true;
        _activePosCount = _activePosCount.add(1);
        if(_activePosCount == _endPos.sub(_startPos).add(1)) {
            emit RoundCanEnd(_startPos, _endPos, _activePosCount);
        }
    }

    function endRound() public onlyOwner {
        uint payUserCount;
        uint256 payAmount = _roundMoney;
       if(_lastStartPos == 0) {
           IBEP20(busdAddr).transfer(pool, _roundMoney);
           _roundMoney = 0;
       } else {
           uint256 amount = _price.mul(10**_decimals).mul(100 + _bonusRate).div(100);
           for(uint256 i = _lastStartPos; i <= _lastEndPos; i++) {
               address payUser = _posAddress[i];
               if(_roundMoney < amount) break;
               //pay money to user
               _balances[payUser] = _balances[payUser].add(amount);
               _roundMoney = _roundMoney.sub(amount);
               payUserCount++;
           }
           emit PayUsers(_lastStartPos.sub(_lastStartPos).add(1), payUserCount, payAmount, _roundMoney);
           for(uint256 i = _startPos; i <= _endPos; i++) {
               address rndUser = _posAddress[i];
               // Clear active pos
               _posActive[i] = false;
               //Clear active count
               _activePosCount = 0;
               _fcfsAmount[rndUser] = 0;
               //pay money to 
           }
       }
       _lastRoundTime = block.timestamp.div(1 days);
       _lastStartPos = _startPos;
       _lastEndPos = _endPos;
       _isRoundStart = false;
       emit EndRound(payAmount, _roundMoney);
    }
    function isRoundStart() external view returns(bool) {
        return _isRoundStart;
    }
    function startFCFS() external onlyOwner{
        uint256 roundActiveNum = _endPos.sub(_startPos).add(1);
        require(_activePosCount < roundActiveNum, "no slot");
        // update order
        for(uint256 i = _startPos; i <= _endPos; i++) {
            if(!_posActive[i]) {
                address curAdd = _posAddress[i];
                //clear unactive position
                for (uint256 j = 0; j < _userPos[curAdd].length; j++) {
                    uint256 currUserPos = _userPos[curAdd][j];
                    if (currUserPos == i){
                        _userPos[curAdd][j] = _userPos[curAdd][_userPos[curAdd].length - 1];
                        break;
                    }
                }
                _userPos[curAdd].pop();
                bool resetFlg =false;
                for (uint256 k = i + 1; k <= _endPos; k++) {
                    if(_posActive[k]) {
                        //address temp = _posAddress[k];
                       //_posAddress[i] = temp;
                       //_posAddress[k] = address(0);
                        _posActive[i] = true;
                        _posActive[k] = false;
                        resetFlg = true;
                        break;
                    }
                }
                if(!resetFlg) {
                    _posAddress[i] = address(0);
                    _posActive[i] = false;
                }
            }
        }
        _state = 2;
    }
    function activePosCount(uint256 key) external view returns(uint256) {
        if(_key == key) return _activePosCount;
        else return 0;
    }
    function currentJoinTickets(uint256 key) external view returns(uint256) {
        if(_key == key) return _currentJoinTickets;
        else return 0;
    }
    function joinFCFS() external {
        uint256 roundActiveNum = _endPos.sub(_startPos).add(1);
        require(_state == 2, "Not in FCFS");
        require(_fcfsAmount[msg.sender] < 2, "you join much FCFS");
        require(_activePosCount < roundActiveNum, "no slot");
        if(_type == 0) {
            if (ITicket(_tickets).ticket50Of(msg.sender) == 0) {
                uint256 ticketFee = 50 * (10**_decimals);
                require(IBEP20(busdAddr).transferFrom(msg.sender, _tickets, ticketFee), "Can not transfer for ticket"); 
                ITicket(_tickets).buyFCFSTicket(msg.sender, _type);
            } else {
                ITicket(_tickets).useTicket50(msg.sender);
            }
        } else {
            if (ITicket(_tickets).ticket100Of(msg.sender) == 0) {
                uint256 ticketFee = 100 * (10**_decimals);
                require(IBEP20(busdAddr).transferFrom(msg.sender, _tickets, ticketFee), "Can not transfer for ticket"); 
                ITicket(_tickets).buyFCFSTicket(msg.sender, _type);
            } else {
                ITicket(_tickets).useTicket100(msg.sender);
            }
        }
        uint256 amount = _price * (10**_decimals);
        require(IBEP20(busdAddr).balanceOf(msg.sender) >= amount, "balance is not enough!!!");
        require(IBEP20(busdAddr).transferFrom(msg.sender, address(this), amount), "transfer USD failed");
        _posAddress[_startPos.add(_activePosCount)] = msg.sender;
        _posActive[_startPos.add(_activePosCount)] = true;
        _activePosCount++;
        _fcfsAmount[msg.sender]++;
        if(_activePosCount == _endPos.sub(_startPos).add(1)) {
            emit RoundCanEnd(_startPos, _endPos, _activePosCount);
        }
        emit JoinFCFS(msg.sender, _activePosCount, roundActiveNum);
    }

    function endFCFS() external onlyOwner{
        uint256 roundActiveNum = _endPos.sub(_startPos).add(1);
        if(_activePosCount == roundActiveNum) {
            endRound();
        } else {
            endPool();
        }
    }

    function endPool() public onlyOwner {
        uint256 amount = _price.mul(10**_decimals).mul(100 + _bonusRate).div(100);
        uint256 payMoney = _roundMoney;
        uint256 payUserCount;
        for(uint256 i = _lastStartPos; i <= _endPos; i++) {
           address payUser = _posAddress[i];
           if(_roundMoney < amount) break;
           //pay money to user
           _balances[payUser] = _balances[payUser].add(amount);
           _roundMoney = _roundMoney.sub(amount);
           payUserCount++;
        }
        _state = 3;
        emit EndPool(payUserCount, payMoney, _roundMoney);
    }

    function claim(uint256 amount) external {
        require(_balances[msg.sender] >= amount, "Over balance");
        require(IBEP20(busdAddr).transfer(msg.sender, amount), "Transfer failed");
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        emit Claim(msg.sender, amount);
    }

    function retrieveStuck(uint256 amount) external onlyOwner {
        require(IBEP20(busdAddr).transfer(_owner, amount), "Transfer failed");
    }

    event BuyPackages(address who, uint256 amount);
    event Withdraw(bytes32 nonce,
        address receiver,
        uint256 types,
        uint256 value);
    event PoolCanStart(uint256 numberRequired, uint256 currNumber);
    event RoundCanEnd(uint256 startPos, uint256 endPos, uint256 activeCount);
    event PayUsers(uint payNum, uint paidNum, uint256 payAmount, uint256 remain);
    event JoinFCFS(address who, uint256 activeCount, uint256 roundNum);
    event EndRound(uint256 payAmount, uint256 remain);
    event EndPool(uint256 userNum, uint256 payMoney, uint256 remain);
    event Claim(address who, uint256 value);
}
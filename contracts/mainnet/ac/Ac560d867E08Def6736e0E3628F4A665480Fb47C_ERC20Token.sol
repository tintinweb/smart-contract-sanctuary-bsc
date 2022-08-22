// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;
import "./IERC20.sol";
import "./ChainLink.sol";
import "./SafeMath.sol";
import "./Ownable.sol";
import "./TransferHelper.sol";
contract ERC20Token is  Ownable{
  using SafeMath for uint256;
  //address private _usdtcontract=0x55d398326f99059fF775485246999027B3197955;// USDT
  address private _wusdtcontract=0xcA9E22Bc0E4B279d792D5653500b4Ce48359a34F;// WUSDT
  uint8 private _usdtdecimals=18;//WUSDT
  address private _linkpricecontract=0xb07b5DFd807cbB5A2927EE51b35f82A42cCD78D5;
 struct UserInfo {
        uint256 camount;
        uint256 time;
        uint256 price;
    }
    mapping(address => uint8) private _coincontract;
    uint8 private _contractNum = 1;
    mapping(address => uint8) private _decimals;
    mapping(address => mapping(uint8 => UserInfo)) private _userpool;
    uint16[3] private _hour = [0, 240, 720];
    struct RateMain {
        uint16 r1;
        uint16 r2;
        uint16 r3;
        uint256 begintime;
        uint256 endtime;
    }
    mapping(address => RateMain) private _coinrate;

    constructor() {}

    function decimals(address coincontract) public view returns (uint8) {
        return _decimals[coincontract];
    }

    function udecimals() public view returns (uint8) {
        return _usdtdecimals;
    }

    function allowanceCall(address coincontract, address owner)
        public
        view
        returns (uint256)
    {
        return IERC20(coincontract).allowance(owner, address(this));
    }

    function setLockTime(uint16 h2, uint16 h3) public onlyOwner returns (bool) {
        _hour = [0, h2, h3];
        return true;
    }

    function setRateMain(
        address coincontract,
        uint16 r1,
        uint16 r2,
        uint16 r3,
        uint256 begintime,
        uint256 endtime
    ) public onlyOwner returns (bool) {
        _coinrate[coincontract] = RateMain(r1, r2, r3, begintime, endtime);
        return true;
    }

    function addContract(address coincontract, uint8 decimal)
        public
        onlyOwner
        returns (bool)
    {
        require(
            address(coincontract) != address(0),
            "Error contract address(0)"
        );
        require(_coincontract[coincontract] == 0, "Error:contract exist");
        require(_contractNum < 80, "Error:contract count max");
        _coincontract[coincontract] = _contractNum;
        _decimals[coincontract] = decimal;
        _contractNum = _contractNum + 1;
        return true;
    }

    function setLinkPriceContract(address pricecontract)
        public
        onlyOwner
        returns (bool)
    {
        require(address(pricecontract) != address(0), "Error address(0)");
        _linkpricecontract = pricecontract;
        return true;
    }

    function setUserData(
        address spender,
        address coincontract,
        uint8 num,
        uint256 camount,
        uint256 settime,
        uint256 unitprice
    ) public onlyOwner returns (bool) {
        uint8 before = (_coincontract[coincontract] - 1) * 3;
        _userpool[spender][before + num] = UserInfo(
            camount,
            settime,
            unitprice
        );
        return true;
    }

    function getLinkPriceContract() public view returns (address) {
        return _linkpricecontract;
    }

    function getLockTime()
        public
        view
        returns (
            uint16,
            uint16,
            uint16
        )
    {
        return (_hour[0], _hour[1], _hour[2]);
    }

    function getRateMain(address coincontract)
        public
        view
        returns (
            uint16,
            uint16,
            uint16,
            uint256,
            uint256
        )
    {
        RateMain memory _r = _coinrate[coincontract];
        return (_r.r1, _r.r2, _r.r3, _r.begintime, _r.endtime);
    }

    function getIsOpen() public view returns (bool) {
        return ChainLink(_linkpricecontract).getIsOpen();
    }

    function getDeposit(address spender, address coincontract)
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint8 before = (_coincontract[coincontract] - 1) * 3;
        uint256 n1 = _userpool[spender][before].camount;
        uint256 n2 = _userpool[spender][before + 1].camount;
        uint256 n3 = _userpool[spender][before + 2].camount;
        RateMain memory _rate = _coinrate[coincontract];
        uint256 nowtime = block.timestamp;
        if (nowtime > _rate.endtime) {
            nowtime = _rate.endtime;
        }
        if (nowtime < _rate.begintime) {
            nowtime = _rate.begintime;
        }
       if((_timesub(spender,coincontract,nowtime,1)>=_hourtoseconds(1) || nowtime==_rate.endtime) && n2>0) {
            n1 = n1.add(n2);
            n2 = 0;
        }
        if((_timesub(spender,coincontract,nowtime,2)>=_hourtoseconds(2) || nowtime==_rate.endtime) && n3>0){
            n1 = n1.add(n3);
            n3 = 0;
        }
        return (n1, n2, n3);
    }

    function getAmountTime(
        address spender,
        address coincontract,
        uint8 num
    )
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint8 before = (_coincontract[coincontract] - 1) * 3;
        uint256 p = _userpool[spender][before + num].price;
        uint256 c = _userpool[spender][before + num].camount;
        uint256 t = _userpool[spender][before + num].time;
        return (c, t, p);
    }

    function interest(address spender, address coincontract)
        public
        view
        returns (uint256)
    {
        uint256 nowtime = block.timestamp;

        uint256 amount = _interest(spender, coincontract, nowtime, 0).add(
            _interest(spender, coincontract, nowtime, 1)
        );
        amount = amount.add(_interest(spender, coincontract, nowtime, 2));
        return amount;
    }

    function _interest(
        address spender,
        address coincontract,
        uint256 nowtime,
        uint8 num
    ) private view returns (uint256) {
        uint256 i_n = 0;
        uint256 a_c_0 = 0;
        (i_n, a_c_0) = _interestCalculation(
            spender,
            coincontract,
            nowtime,
            num
        );
        return i_n;
    }

    function withdraw(
        uint256 scale,
        address coincontract,
        uint256 unitprice
    ) public payable returns (bool) {
        require(
            ChainLink(_linkpricecontract).checkPrice(coincontract, unitprice) ==
                true,
            "ChainLink price verification failed"
        );
        require(
            _coincontract[coincontract] > 0,
            "ERC20: contract does not exist"
        );
        uint8 before = (_coincontract[coincontract] - 1) * 3;
        uint256 nowtime = block.timestamp;
        _settlement(_msgSender(), coincontract, unitprice, nowtime);

        uint256 c_0 = _userpool[_msgSender()][before].camount;
        uint256 camount = 0;
        if (scale >= 100) {
            camount = c_0;
        } else {
            camount = c_0.mul(scale).div(100);
        }
        require(
            camount <= IERC20(coincontract).allowance(_owner, address(this)),
            "ERC20: _owner coin amount exceeds allowance"
        );

        uint256 beforeAmount = IERC20(coincontract).balanceOf(_msgSender());
        TransferHelper.safeTransferFrom(
            coincontract,
            _owner,
            _msgSender(),
            camount
        );
        uint256 afterAmount = IERC20(coincontract).balanceOf(_msgSender());
        require(
            camount ==
                afterAmount.sub(beforeAmount, "Err: before coin balance"),
            "ERC20: error coin balance"
        );

        _userpool[_msgSender()][before] = UserInfo(
            _userpool[_msgSender()][before].camount.sub(camount),
            _userpool[_msgSender()][before].time,
            unitprice
        );
        return true;
    }

    function draw(address coincontract, uint256 unitprice)
        public
        payable
        returns (bool)
    {
        require(
            ChainLink(_linkpricecontract).checkPrice(coincontract, unitprice) ==
                true,
            "ChainLink price verification failed"
        );
        require(
            _coincontract[coincontract] > 0,
            "ERC20: contract does not exist"
        );
        uint256 nowtime = block.timestamp;
        _settlement(_msgSender(), coincontract, unitprice, nowtime);
        return true;
    }

    function _interestCalculation(
        address spender,
        address coincontract,
        uint256 nowtime,
        uint8 n
    ) private view returns (uint256, uint256) {
        RateMain memory _rate = _coinrate[coincontract];
        uint8 before = (_coincontract[coincontract] - 1) * 3;
        uint256 reti = 0;
        uint256 ftol = 0;
        uint256 tmptime = 0;
        if (nowtime > _rate.endtime) {
            nowtime = _rate.endtime;
        }
        if (n == 0) {
            reti = (_userpool[spender][before].camount).mul(
                _userpool[spender][before].price
            );
            tmptime = _userpool[spender][before].time;
            if (tmptime < _rate.begintime) {
                tmptime = _rate.begintime;
            }
            if (nowtime > tmptime) {
                reti = reti.mul(nowtime.sub(tmptime));
            } else {
                reti = reti.mul(0);
            }
            reti = reti.mul(_rate.r1).div(86400000000).div(100000000);
        } else {
            if (
                _timesub(spender, coincontract, nowtime, n) >=
                _hourtoseconds(n) ||
                nowtime == _rate.endtime
            ) {
                ftol = (_userpool[spender][before + n].camount);
                reti = (_userpool[spender][before + n].camount).mul(
                    _userpool[spender][before + n].price
                );
               
                    tmptime = nowtime - _userpool[spender][before].time;
                    // if (tmptime >= _hourtoseconds(n)) {
                    //     tmptime = tmptime - _hourtoseconds(n);
                    // } else if (tmptime >= _hourtosecond(n, _rate.begintime)) {
                    //     tmptime = tmptime - _hourtosecond(n, _rate.begintime);
                    // } else {
                    //     tmptime = 0;
                    // }
                reti = reti.mul(tmptime);
                reti = reti.mul(_rate.r1).div(86400000000).div(100000000);
                if (n == 1) {
                  if( _timesub(spender, coincontract, nowtime, n) >= _hourtoseconds(n)){
                    tmptime = ftol.mul(_hourtoseconds(n));
                    tmptime = tmptime.mul(_rate.r2 - (_rate.r1));
                    tmptime = tmptime.mul(_userpool[spender][before + n].price);
                    tmptime = tmptime.div(86400000000).div(100000000);
                  }else if( _timesub(spender, coincontract, nowtime, n) >= _hourtosecond(n, _rate.begintime)){
                    tmptime = ftol.mul(_hourtosecond(n, _rate.begintime));
                    tmptime = tmptime.mul(_rate.r2 - (_rate.r1));
                    tmptime = tmptime.mul(_userpool[spender][before + n].price);
                    tmptime = tmptime.div(86400000000).div(100000000);
                  }else{tmptime=0;}                    
                    reti = reti.add(tmptime);
                } else {
                  if( _timesub(spender, coincontract, nowtime, n) >= _hourtoseconds(n)){
                    tmptime = ftol.mul(_hourtoseconds(n));
                    tmptime = tmptime.mul(_rate.r3 - (_rate.r1));
                    tmptime = tmptime.mul(_userpool[spender][before + n].price);
                    tmptime = tmptime.div(86400000000).div(100000000);
                  }else if( _timesub(spender, coincontract, nowtime, n) >= _hourtosecond(n, _rate.begintime)){
                     tmptime = ftol.mul(_hourtosecond(n, _rate.begintime));
                     tmptime = tmptime.mul(_rate.r3 - (_rate.r1));
                    tmptime = tmptime.mul(_userpool[spender][before + n].price);
                    tmptime = tmptime.div(86400000000).div(100000000);
                  }else{tmptime=0;}
                    
                    reti = reti.add(tmptime);
                }
            } else {
                if (
                    nowtime > _userpool[spender][before].time &&
                    nowtime > _rate.begintime
                ) {
                    reti = (_userpool[spender][before + n].camount).mul(
                        _userpool[spender][before + n].price
                    );
                    if (_userpool[spender][before].time < _rate.begintime) {
                        tmptime = nowtime - _rate.begintime;
                        reti = reti.mul(tmptime);
                    } else {
                        tmptime = nowtime - _userpool[spender][before].time;
                        reti = reti.mul(tmptime);
                    }
                    reti = reti.mul(_rate.r1).div(86400000000).div(100000000);
                }
            }
        }
        return (reti, ftol);
    }

    function _numaddamount(
        address spender,
        address coincontract,
        uint256 nowtime,
        uint256 unitprice,
        uint256 camount,
        uint8 num
    ) internal virtual {
        uint8 before = (_coincontract[coincontract] - 1) * 3;
        if (_userpool[spender][before + num].price > 0) {
            unitprice = unitprice
                .add(_userpool[spender][before + num].price)
                .div(2);
        }
        _userpool[spender][before + num] = UserInfo(
            camount.add(_userpool[spender][before + num].camount),
            _calculationtime(spender, coincontract, nowtime, camount, num),
            unitprice
        );
    }

    function _settlement(
        address spender,
        address coincontract,
        uint256 unitprice,
        uint256 nowtime
    ) internal virtual {
        uint8 before = (_coincontract[coincontract] - 1) * 3;
        uint256 c_0 = _userpool[spender][before].camount;
         RateMain memory _rate = _coinrate[coincontract];
      if(nowtime>_rate.endtime){nowtime=_rate.endtime;}
      if(nowtime<_rate.begintime){nowtime=_rate.begintime;}
        uint256 i_all = 0;
        uint256 i_n = 0;
        uint256 a_c_0 = 0;
        (i_n, a_c_0) = _interestCalculation(spender, coincontract, nowtime, 0);
        if (i_n > 0) {
            i_all += i_n;
        }
        (i_n, a_c_0) = _interestCalculation(spender, coincontract, nowtime, 1);
        c_0 += a_c_0;
        if (i_n > 0) {
            i_all += i_n;
        }
        if (a_c_0 > 0) {
            _userpool[spender][before + 1] = UserInfo(0, 0, 0);
        }
        (i_n, a_c_0) = _interestCalculation(spender, coincontract, nowtime, 2);
        c_0 += a_c_0;
        if (i_n > 0) {
            i_all += i_n;
        }
        if (a_c_0 > 0) {
            _userpool[spender][before + 2] = UserInfo(0, 0, 0);
        }
        _userpool[spender][before] = UserInfo(c_0, nowtime, unitprice);
        if (i_all > 0) {
            if(_usdtdecimals>_decimals[coincontract]){
                i_all=i_all.mul(_pow10(_usdtdecimals,_decimals[coincontract]));
            }else if(_usdtdecimals<_decimals[coincontract]){
                i_all=i_all.div(_pow10(_decimals[coincontract],_usdtdecimals));
            }
            c_0 = IERC20(_wusdtcontract).balanceOf(spender);
            TransferHelper.safeStakedToGet(_wusdtcontract, spender, i_all);
            a_c_0 = IERC20(_wusdtcontract).balanceOf(spender);
            require(
                i_all == a_c_0.sub(c_0, "Err: after amount balance"),
                "ERC20: error balance"
            );
        }
    }

    function _pow10(uint8 big, uint8 small) private pure returns (uint256) {
        uint256 v = big;
        v = v - small;
        uint256 ret = 10**v;
        return ret;
    }

    function _calculationtime(
        address spender,
        address coincontract,
        uint256 nowtime,
        uint256 amount,
        uint8 num
    ) private view returns (uint256) {
        uint8 before = (_coincontract[coincontract] - 1) * 3;
        uint256 time = _userpool[spender][before + num].time;
        if (_userpool[spender][before + num].camount == 0) {
            time = nowtime;
        } else {
            time = nowtime.sub(
                (nowtime - _userpool[spender][before + num].time)
                    .mul(_userpool[spender][before + num].camount)
                    .div(amount + _userpool[spender][before + num].camount)
            ); 
        }
        return time;
    }

    function deposit(
        address coincontract,
        uint256 camount,
        uint8 num,
        uint256 unitprice
    ) public payable returns (bool) {
        require(
            ChainLink(_linkpricecontract).checkPrice(coincontract, unitprice) ==
                true,
            "ChainLink price verification failed"
        );
        require(
            _coincontract[coincontract] > 0,
            "ERC20: contract does not exist"
        );

        require(
            camount <=
                IERC20(coincontract).allowance(_msgSender(), address(this)),
            "ERC20: owner coin amount exceeds allowance"
        );
        uint256 beforeAmount = IERC20(coincontract).balanceOf(_msgSender());
        TransferHelper.safeTransferFrom(
            coincontract,
            _msgSender(),
            _owner,
            camount
        );
        uint256 afterAmount = IERC20(coincontract).balanceOf(_msgSender());
        require(
            camount == beforeAmount.sub(afterAmount, "Err:coin before balance"),
            "ERC20: error coin balance"
        );
        uint256 nowtime = block.timestamp;
        RateMain memory _rate = _coinrate[coincontract];
        if (nowtime > _rate.endtime) {
            nowtime = _rate.endtime;
        }
        if (nowtime < _rate.begintime) {
            nowtime = _rate.begintime;
        }
        _settlement(_msgSender(), coincontract, unitprice, nowtime);
        _numaddamount(
            _msgSender(),
            coincontract,
            nowtime,
            unitprice,
            camount,
            num
        );
        return true;
    }
    function _hourtoseconds(uint8 num) private view returns (uint256) {
        uint256 second = _hour[num];
        second = second.mul(3600);
        return second;
    }

    function _timesub(
        address spender,
        address coincontract,
        uint256 nowtime,
        uint8 num
    ) private view returns (uint256) {
        uint8 before = (_coincontract[coincontract] - 1) * 3;
        uint256 time = _userpool[spender][before + num].time;
        uint256 subval = nowtime;
        if (nowtime > time) {
            subval = subval.sub(time);
        } else {
            subval = 0;
        }
        return subval;
    }

    function _hourtosecond(uint8 num, uint256 endtime)
        private
        view
        returns (uint256)
    {
        uint256 second = _hour[num];
        uint256 nowtime = block.timestamp;
        uint256 havesecond = 0;
        if (nowtime < endtime) {
            havesecond = endtime - nowtime;
        }
        second = second.mul(3600);
        if (second < havesecond) {
            second = havesecond;
        }
        return second;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }
    function safeTransfer(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }
    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }
    function safeStakedToGet(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x241ea13b,  to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: WUSDT_FAILED');
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;
import "./Context.sol";
abstract contract Ownable is Context {
    address public _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor ()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;
interface ChainLink {
  function getRate(address coincontract) external view returns (uint16,uint16,uint16,uint16,uint16);
  function getRateMain(address coincontract,bool ismain) external view returns (uint16,uint16,uint16);
  function checkPrice(address coincontract,uint256 price) external view returns (bool);
  function getIsOpen()external view returns (bool);
  function getBorrowRate(address coincontract) external view returns (uint16);
}
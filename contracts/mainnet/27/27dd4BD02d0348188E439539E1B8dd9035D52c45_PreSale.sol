/**
 *Submitted for verification at BscScan.com on 2022-08-02
*/

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;

interface IERC20 {

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function mint(address spender, uint256 amount) external;

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {size := extcodesize(account)}
        return size > 0;
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value : weiValue}(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }

}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {// Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IOwnable {

    function owner() external view returns (address);

    function renounceOwnership() external;

    function transferOwnership(address newOwner_) external;
}

contract Ownable is IOwnable {

    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view override returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual override onlyOwner() {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner_) public virtual override onlyOwner() {
        require(newOwner_ != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner_);
        _owner = newOwner_;
    }
}

interface IUniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function token0() external view returns ( address );
    function token1() external view returns ( address );
}

contract PreSale is Ownable {
    using SafeMath for uint;
    using SafeERC20 for IERC20;

    address public alpha;
    address public DAOAddress;
    address public USDT;
    address public OSK;
    address public pair;
    
    uint public num;
    uint public salePrice;
    uint public amount;  

    bool public started;
    uint public priceDecimals = 1e18;
    

    function initialize(
        address _DAOAddress,
        address _alpha,
        address _USDT,
        address _OSK,
        address _pair,
        uint _amount,
        uint _num,
        uint _salePrice,
        bool _started
        ) external onlyOwner() {
        DAOAddress = _DAOAddress;
        alpha = _alpha;
        USDT = _USDT;   
        OSK = _OSK;   
        pair = _pair;   
        num = _num;
        salePrice = _salePrice;
        amount = _amount;
        started = _started;
    }
    
    function purchasea(address _token,uint256 _val,address inviter) external returns (bool) {
        require(started == true,"not started");
        uint _purchaseAmount;
        if(_token == USDT){
            require(_val >= amount,"value too small");
            uint inviterAmunt = _val.mul(num).div(1e4);
            IERC20(USDT).safeTransferFrom(msg.sender ,inviter, inviterAmunt);
            IERC20(USDT).safeTransferFrom(msg.sender ,DAOAddress, _val.sub(inviterAmunt));
            _purchaseAmount = _calculateSaleQuote(_val);
        }else{
            require(_calculateValue(_val) >= amount,"value too small");
            uint inviterAmunt = _val.mul(num).div(1e4);
            IERC20(OSK).safeTransferFrom(msg.sender ,inviter, inviterAmunt);
            IERC20(OSK).safeTransferFrom(msg.sender ,DAOAddress, _val.sub(inviterAmunt));
            _purchaseAmount = _calculateSaleQuoteOSK(_val);
        }
        IERC20(alpha).mint(msg.sender, _purchaseAmount);
        return true;
    }
    
    function _calculateSaleQuote(uint paymentAmount_) internal view returns (uint) {
        return priceDecimals.mul(paymentAmount_).div(salePrice);
    }

    function _calculateValue(uint paymentAmount_) internal view returns (uint) {
        return getTokenPrice().mul(paymentAmount_).div(priceDecimals);
    }

    function _calculateSaleQuoteOSK(uint paymentAmount_) internal view returns (uint) {
        return getTokenPrice().mul(paymentAmount_).div(salePrice);
    }

    function calculateSaleQuote(address _token,uint paymentAmount_) external view returns (uint) {
        if(_token == USDT){
            return _calculateSaleQuote(paymentAmount_);
        }else{
            return _calculateSaleQuoteOSK(paymentAmount_);
        }
    }

    function setStarted() external onlyOwner() {
        started = !started;
    }

    function getTokenPrice() public view returns (uint _price) {
        uint token0 = IERC20(IUniswapV2Pair(pair).token0()).decimals();
        uint token1 = IERC20(IUniswapV2Pair(pair).token1()).decimals();
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pair).getReserves();
        uint decimals = 1;
        if(IUniswapV2Pair(pair).token0() == OSK){
            if(token0 > token1){
                decimals = token0.sub(token1);
                _price = reserve1.mul(10 ** decimals).mul(priceDecimals).div(reserve0);
            }else if(token1 > token0){
                decimals = token1.sub(token0);
                _price = reserve1.mul(priceDecimals).div(reserve0.mul(10 ** decimals));
            }else{
                _price = reserve1.mul(priceDecimals).div(reserve0);
            }
        }else{
            if(token0 > token1){
                decimals = token0.sub(token1);
                _price = reserve0.mul(priceDecimals).div(reserve1.mul(10 ** decimals));
            }else if(token1 > token0){
                decimals = token1.sub(token0);
                _price = reserve0.mul(10 ** decimals).mul(priceDecimals).div(reserve1);
            }else{
                _price = reserve0.mul(priceDecimals).div(reserve1);
            }
        }
    }

    function withdraw(address _token) external onlyOwner() {
        uint256 balance = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(msg.sender, balance);
    }
    
}
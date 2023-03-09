/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

// SPDX-License-Identifier: MIT
pragma solidity = 0.8.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "s1");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "s2");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "s3");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "s4");
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "s5");
        return a % b;
    }
}


interface IAocoFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IAocoPair {
    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint256 reserve0, uint256 reserve1, uint256 blockTimestampLast);
}

interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);
}

interface swapRouter {
    function factory() external pure returns (address);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

contract pairHelper2 is Ownable {
    using SafeMath for uint256;
    address public USDT;
    address public ETH;

    struct tokenInfo {
        string name;
        string symbol;
        uint256 decimals;
        uint256 balance;
    }

    struct pairInfo {
        address token0;
        address token1;
        uint256 reserve0;
        uint256 reserve1;
        uint256 decimals0;
        uint256 decimals1;
        string symbol0;
        string symbol1;
    }

    struct returnItem {
        IAocoFactory _factoryAddress;
        tokenInfo _tokenInfo;
        pairInfo _pairInfoForUSDT;
        pairInfo _pairInfoForETH;
    }

    constructor (address _USDT, address _ETH) {
        setConfig(_USDT, _ETH);
    }

    function getTokenInfo(IERC20 _token, address _user) public view returns (tokenInfo memory _tokenInfo) {
        _tokenInfo.name = _token.name();
        _tokenInfo.symbol = _token.symbol();
        _tokenInfo.decimals = _token.decimals();
        _tokenInfo.balance = _token.balanceOf(_user);
    }

    function setConfig(address _USDT, address _ETH) public onlyOwner {
        USDT = _USDT;
        ETH = _ETH;
    }

    function getPairInfo(IAocoFactory _factoryAddress, address _token, address _defaultToken) private view returns (pairInfo memory _pairInfo) {
        address pair = _factoryAddress.getPair(_token, _defaultToken);
        if (pair != address(0)) {
            address token0 = IAocoPair(pair).token0();
            address token1 = IAocoPair(pair).token1();
            (uint256 reserve0, uint256 reserve1,) = IAocoPair(pair).getReserves();
            _pairInfo = pairInfo(token0, token1, reserve0, reserve1, IERC20(token0).decimals(), IERC20(token1).decimals(), IERC20(token0).symbol(), IERC20(token1).symbol());
        }
    }

    function getPairInfo2(IAocoFactory _factoryAddress, address _token, address _user) private view returns (returnItem memory pairInfo_) {
        pairInfo_ = new returnItem[](1)[0];
        pairInfo_._factoryAddress = _factoryAddress;
        pairInfo_._tokenInfo = getTokenInfo(IERC20(_token), _user);
        pairInfo_._pairInfoForUSDT = getPairInfo(_factoryAddress, _token, USDT);
        pairInfo_._pairInfoForETH = getPairInfo(_factoryAddress, _token, ETH);
    }

    function massGetPairInfo(IAocoFactory[] memory _factoryAddressList, address _token, address _user) public view returns (returnItem[] memory pairInfoList_) {
        pairInfoList_ = new returnItem[](_factoryAddressList.length);
        for (uint256 i = 0; i < _factoryAddressList.length; i++) {
            pairInfoList_[i] = getPairInfo2(_factoryAddressList[i], _token, _user);
        }
    }

    function getSwapOutAmount(swapRouter _routerAddress, uint256 _amountIn, address[] calldata _path, uint256 _slipPage, uint256 _totalSlipPage) public view returns (uint256 _amountOut) {
        try _routerAddress.getAmountsOut(_amountIn, _path) returns (uint256[] memory amounts) {
            _amountOut = amounts[amounts.length - 1];
            _amountOut = _amountOut.sub(_amountOut.mul(_slipPage).div(_totalSlipPage));
        } catch {
            _amountOut = 0;
        }
    }

    struct swapOutItem {
        swapRouter _routerAddress;
        uint256 _swapOutAmount;
        tokenInfo _swapIntokenInfo;
        tokenInfo _swapOuttokenInfo;
    }

    function massGetSwapOutAmount(swapRouter[] memory _routerAddressList, uint256 _amountIn, address[] calldata _path, uint256 _slipPage, uint256 _totalSlipPage, address _user) public view returns (swapOutItem[] memory _swapOutList) {
        IERC20 swapInToken = IERC20(_path[0]);
        IERC20 swapOutToken = IERC20(_path[_path.length - 1]);
        _swapOutList = new swapOutItem[](_routerAddressList.length);
        for (uint256 i = 0; i < _routerAddressList.length; i++) {
            _swapOutList[i] = swapOutItem(_routerAddressList[i], getSwapOutAmount(_routerAddressList[i], _amountIn, _path, _slipPage, _totalSlipPage), getTokenInfo(swapInToken, _user), getTokenInfo(swapOutToken, _user));
        }
    }

    function getSum(uint256[] memory _numList) public pure returns (uint256 _sum) {
        for (uint256 i = 0; i < _numList.length; i++) {
            _sum = _sum.add(_numList[i]);
        }
    }
}
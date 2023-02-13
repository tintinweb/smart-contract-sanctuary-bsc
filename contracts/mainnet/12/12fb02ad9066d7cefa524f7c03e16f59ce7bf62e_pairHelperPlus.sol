/**
 *Submitted for verification at BscScan.com on 2023-02-13
*/

// SPDX-License-Identifier: MIT
pragma solidity = 0.8.7;

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


interface IFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IPair {
    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint256 reserve0, uint256 reserve1, uint256 blockTimestampLast);
}

contract pairHelperPlus is Ownable {
    address public USDT;
    address public ETH;

    struct configItem {
        address _USDT;
        address _ETH;
    }

    struct returnItem {
        IFactory _factoryAddress;
        uint256 reserve_USDT;
        uint256 reserve_ETH;
    }

    constructor (configItem memory _configItem) {
        setConfig(_configItem);
    }

    function setConfig(configItem memory _configItem) public onlyOwner {
        USDT = _configItem._USDT;
        ETH = _configItem._ETH;
    }

    function getPairInfo(IFactory _factoryAddress, address _token, address _defaultToken) private view returns (uint256) {
        address pair = _factoryAddress.getPair(_token, _defaultToken);
        if (pair == address(0)) {
            return 0;
        }
        address token_ = IPair(pair).token0();
        (uint256 reserve0, uint256 reserve1,) = IPair(pair).getReserves();
        if (token_ == _token) {
            return reserve0;
        } else {
            return reserve1;
        }
    }

    function getPairInfo2(IFactory _factoryAddress, address _token) private view returns (returnItem memory pairInfo_) {
        pairInfo_ = new returnItem[](1)[0];
        pairInfo_._factoryAddress = _factoryAddress;
        pairInfo_.reserve_USDT = getPairInfo(_factoryAddress, _token, USDT);
        pairInfo_.reserve_ETH = getPairInfo(_factoryAddress, _token, ETH);
    }

    function massGetPairInfo(IFactory[] memory _factoryAddressList, address _token) public view returns (returnItem[] memory pairInfoList_) {
        pairInfoList_ = new returnItem[](_factoryAddressList.length);
        for (uint256 i = 0; i < _factoryAddressList.length; i++) {
            pairInfoList_[i] = getPairInfo2(_factoryAddressList[i], _token);
        }
    }
}
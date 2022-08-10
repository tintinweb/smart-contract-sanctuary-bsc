// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./ERC20.sol";
import "./IERC20.sol";
import "./SafeERC20.sol";

import "./Ownable.sol";
import "./SafeMath.sol";

import "./IUniswapV2Router01.sol";
import "./IUniswapV2Router02.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Pair.sol";

import "./DefiToken.sol";
import "./RelationHolder.sol";

contract ELCToken is DefiToken {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    RelationHolder public relationHolder;

    uint256 public feeRate = 80;
    address public feeReceiverDefault;
    address[] public feeReceiverWhiteList;

    constructor(
        // 交易所和依赖
        address _router,
        address _otherToken,
        address _relationHolder,
        // 铸造钱包
        address _elpAddr,
        address _desAddr,
        address _locAddr,
        address _clpAddr,
        address _poolAddr,
        // 滑点相关钱包
        address _feeReceiverDefault
    ) DefiToken("ELC", "ELC") {
        // 设置交易所
        address _defaultPair = getPairAddress(_router, _otherToken);
        setDexPair(_defaultPair, DexTrasactionLimitMode.ALLOW_ALL);

        // 设置参数
        setRelationHolder(_relationHolder);
        setFeeReceiverDefault(_feeReceiverDefault);

        // 铸造
        // 铸币给ELE LP挖矿
        _mint(_elpAddr, (10**decimals()) * 1200000);
        setFromWhites(_elpAddr, true);
        setToWhites(_elpAddr, true);
        setFeeWhites(_elpAddr, true);

        // 铸币给销毁挖矿
        _mint(_desAddr, (10**decimals()) * 1000000);
        setFromWhites(_desAddr, true);
        setToWhites(_desAddr, true);
        setFeeWhites(_desAddr, true);

        // 铸币给锁仓
        _mint(_locAddr, (10**decimals()) * 800000);
        setFromWhites(_locAddr, true);
        setToWhites(_locAddr, true);
        setFeeWhites(_locAddr, true);

        // 铸币给ELC LP挖矿
        _mint(_clpAddr, (10**decimals()) * 1950000);
        setFromWhites(_clpAddr, true);
        setToWhites(_clpAddr, true);
        setFeeWhites(_clpAddr, true);

        // 铸币给底池
        _mint(_poolAddr, (10**decimals()) * 50000);
        setFromWhites(_poolAddr, true);
        setToWhites(_poolAddr, true);
        setFeeWhites(_poolAddr, true);
    }

    // 设置关系持有者
    function setRelationHolder(address _relationHolder) public onlyOwner {
        relationHolder = RelationHolder(_relationHolder);
        setFromWhites(_relationHolder, true);
        setToWhites(_relationHolder, true);
        setFeeWhites(_relationHolder, true);
    }

    // 设置卖币滑点比例
    function setFeeRate(uint256 _rate) public onlyOwner {
        feeRate = _rate;
    }

    // 设置默认滑点接收者
    function setFeeReceiverDefault(address _account) public onlyOwner {
        feeReceiverDefault = _account;
        setFromWhites(_account, true);
        setToWhites(_account, true);
        setFeeWhites(_account, true);
    }

    // 设置ELE/ELC滑点奖励白名单
    function addFeeReceiverWhiteList(address _account) public onlyOwner {
        feeReceiverWhiteList.push(_account);
        setFromWhites(_account, true);
        setToWhites(_account, true);
        setFeeWhites(_account, true);
    }

    // 设置ELE/ELC滑点奖励白名单
    function setFeeReceiverWhiteList(uint256 _i, address _account) public onlyOwner {
        feeReceiverWhiteList[_i] = _account;
    }

    // 执行交易所买币滑点扣除, 并返回已消费数额
    function doBuyFeeDeduction(address _account, address _dex, uint256 _amount) override internal virtual returns (uint256) {
        return 0;
    }

    // 执行交易所卖币滑点扣除, 并返回已消费数额
    function doSellFeeDeduction(address _account, address _dex, uint256 _amount) override internal virtual returns (uint256) {
        uint256 _feeAmount = _amount.mul(feeRate).div(PRECISION);
        uint256 _useAmount = 0;

        // 分配给白名单
        if (feeReceiverWhiteList.length > 0) {
            uint256 _wlSingle = _feeAmount.mul(400).div(feeReceiverWhiteList.length).div(PRECISION);
            for (uint256 i = 0; i < feeReceiverWhiteList.length; i ++) {
                address _curr = feeReceiverWhiteList[i];
                if (_curr == address(0)) {
                    continue;
                }
                _internalTransfer(_account, _curr, _wlSingle);
                _useAmount = _useAmount.add(_wlSingle);
            }
        }

        // 分配给上级
        address[] memory _inviters = relationHolder.getSuperiors(_account, 3);
        uint256 _ivAmount = _feeAmount.mul(300).div(PRECISION);

        if (_inviters[0] != address(0)) {
            uint256 _iv1 = _ivAmount.mul(500).div(PRECISION);
            _internalTransfer(_account, _inviters[0], _iv1);
            _useAmount = _useAmount.add(_iv1);
        }

        if (_inviters[1] != address(0)) {
            uint256 _iv2 = _ivAmount.mul(350).div(PRECISION);
            _internalTransfer(_account, _inviters[1], _iv2);
            _useAmount = _useAmount.add(_iv2);
        }

        if (_inviters[2] != address(0)) {
            uint256 _iv3 = _ivAmount.mul(150).div(PRECISION);
            _internalTransfer(_account, _inviters[2], _iv3);
            _useAmount = _useAmount.add(_iv3);
        }

        // 分配给默认钱包
        uint256 _dfAmount = _feeAmount.sub(_useAmount);
        _internalTransfer(_account, feeReceiverDefault, _dfAmount);

        return _feeAmount;
    }

    // 执行普通滑点扣除, 并返回已消费数额
    function doNormalFeeDeduction(address _from, address _to, uint256 _amount) override internal virtual returns (uint256) {
        return 0;
    }
}
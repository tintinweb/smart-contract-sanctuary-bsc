/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.19;

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IWETH is IERC20 {
    function withdrawTo(address account, uint256 amount) external;
}

contract MVLPStaker is Ownable {
    uint256 private constant FEE_DIVISOR = 1e4;
    IERC20 private constant MVLP =
        IERC20(0xa5F756Ce4717FC41528851dA2F81E65B806Cfade); // testnet
    //   IWETH private constant WETH = IWETH(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1);
    IWETH private constant WETH =
        IWETH(0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889); // testnet

    mapping(address => bool) public operators;
    address public depositor;
    address public compounder;
    bool public shouldCompound;
    uint32 public fee;
    address private feeCollector;

    constructor(address _feeCollector, address _compounder) {
        fee = 1000; // fee in bp - 10%;
        feeCollector = _feeCollector; //set fee collector
        compounder = _compounder;
        shouldCompound = true;
    }

    function handleRewards() external pure returns (uint256) {
        return (0);
    }

    function approve(address _spender, uint256 _amount) external {
        if (msg.sender != depositor) revert UNAUTHORIZED();
        MVLP.approve(_spender, _amount);
    }

    function _calculateFee(
        uint256 _totalAmount
    ) private view returns (uint256 _fee, uint256 _amountLessFee) {
        unchecked {
            _fee = (_totalAmount * fee) / FEE_DIVISOR;
            _amountLessFee = _totalAmount - _fee;
        }
    }

    function setFee(uint32 _newFee) external onlyOwner {
        if (_newFee > FEE_DIVISOR) revert BAD_FEE();
        fee = _newFee;
    }

    function updateOperator(
        address _operator,
        bool _isActive
    ) external onlyOwner {
        emit OperatorUpdated(_operator, _isActive);
        operators[_operator] = _isActive;
    }

    function setDepositor(address _newDepositor) external onlyOwner {
        MVLP.approve(_newDepositor, type(uint256).max);
        if (depositor != address(0)) {
            MVLP.approve(depositor, 0);
        }

        emit DepositorChanged(_newDepositor, depositor);

        depositor = _newDepositor;
    }

    function updateCompounder(
        address _newCompounder,
        bool _shouldCompound
    ) external onlyOwner {
        emit CompounderUpdated(_newCompounder, compounder, _shouldCompound);

        compounder = _newCompounder;
        shouldCompound = _shouldCompound;
    }

    function setFeeCollector(address _newFeeCollector) external onlyOwner {
        emit FeeCollectorUpdated(_newFeeCollector, feeCollector);
        feeCollector = _newFeeCollector;
    }

    event OperatorUpdated(address indexed _new, bool _isActive);
    event DepositorChanged(address indexed _new, address _old);
    event CompounderUpdated(
        address indexed _new,
        address _old,
        bool _shouldCompound
    );
    event KeeperFeeUpdated(uint80 _newFee, uint80 _oldFee);
    event FeeCollectorUpdated(address _new, address _old);
    event Harvested(uint256 fee, uint256 rewardsLessFee);

    error UNAUTHORIZED();
    error BAD_FEE();
}
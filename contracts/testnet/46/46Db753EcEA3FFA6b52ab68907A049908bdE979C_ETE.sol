/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "Math error");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(a >= b, "Math error");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "Math error");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a / b;
        return c;
    }
}


// safe transfer
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        // (bool success,) = to.call.value(value)(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}


interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// owner
contract Ownable {
    address public owner;

    constructor(address owner_) {
        owner = owner_;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'Token: owner error');
        _;
    }

    function renounceOwnership() public onlyOwner {
        owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}

// owner2
contract Ownable2 {
    address public owner2;

    constructor(address owner2_) {
        owner2 = owner2_;
    }

    modifier onlyOwner2() {
        require(msg.sender == owner2, 'Token: owner2 error');
        _;
    }

    function transferOwnership2(address newOwner2) public onlyOwner2 {
        if (newOwner2 != address(0)) {
            owner2 = newOwner2;
        }
    }
}


// 提供的接口
interface IETETracker {
    function initETETracker(address _Ete) external;
    function nftHolderDividendAndSwap() external;
    function addOrRemove(address _from, address _to) external;
}


// ETE合约
contract ETE is IERC20, Ownable, Ownable2 {
    using SafeMath for uint256;

    string private _name = "ETE Token";
    string private _symbol = "ETE";
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 100000000 * (10**_decimals);
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowed;

    // 添加，移除，兑换的手续费(转账不扣手续费)。
    mapping(address => bool) public whitelistAddress;        // 白名单：不扣手续费。
    mapping(address => bool) public blacklistAddress;        // 黑名单：不能做任何交易。
    uint256 private _fee = 3;     // 3%.
    address public ETETracker;   // 分红地址


    constructor(address owner_, address owner2_, address ETETracker_) Ownable(owner_) Ownable2(owner2_) {
        _balances[owner_] = _totalSupply;
        whitelistAddress[owner_] = true;
        whitelistAddress[owner2_] = true;
        ETETracker = ETETracker_;
        whitelistAddress[ETETracker] = true;

        // 初始化
        IETETracker(ETETracker).initETETracker(address(this));
    }


    function name() public override view returns (string memory) {
        return _name;
    }

    function symbol() public override view returns (string memory) {
        return _symbol;
    }

    function decimals() public override view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address address_) public override view returns (uint256) {
        return _balances[address_];
    }

    function _transfer(address from_, address to_, uint256 value_) private {
        _balances[from_] = SafeMath.sub(_balances[from_], value_);
        _balances[to_] = SafeMath.add(_balances[to_], value_);
        emit Transfer(from_, to_, value_);
    }

    function _transferFull(address _from, address _to, uint256 _value) private {
        // 验证黑名单, 如果是黑名单交易，直接抛出错误。
        _verifyBlacklist(_from, _to);

        if(whitelistAddress[_from] || whitelistAddress[_to]) {
            // 白名单交易
            _transfer(_from, _to, _value);
        }else if(!isContract(_from) && !isContract(_to)) {
            // 用户转给用户
            _transfer(_from, _to, _value);
        }else {
            // 其它交易都要扣除手续费
            uint256 _f = _value.mul(_fee).div(100);
            uint256 _v = _value.sub(_f);
            _transfer(_from, ETETracker, _f);
            _transfer(_from, _to, _v);

            // 分红
            try IETETracker(ETETracker).nftHolderDividendAndSwap() {} catch {}
        }

        // 添加或移除地址
        if(_from != ETETracker) {
            // 不是分红合约地址的话就进行添加或移除地址。如果发送方是分红合约地址，说明是在分红，没必要执行添加或移除。
            try IETETracker(ETETracker).addOrRemove(_from, _to) {} catch {}  
        }
    }




    function transfer(address to_, uint256 value_) public override returns (bool) {
        require(_balances[msg.sender] >= value_, 'balance error');
        _transferFull(msg.sender, to_, value_);
        return true;
    }

    function approve(address spender_, uint256 amount_) public override returns (bool) {
        _allowed[msg.sender][spender_] = amount_;
        emit Approval(msg.sender, spender_, amount_);
        return true;
    }

    function transferFrom(address from_, address to_, uint256 value_) public override returns (bool) {
        require(_balances[from_] >= value_, 'balance error');
        _allowed[from_][msg.sender] = SafeMath.sub(_allowed[from_][msg.sender], value_);
        _transferFull(from_, to_, value_);
        return true;
    }

    function allowance(address owner_, address spender_) public override view returns (uint256) {
        return _allowed[owner_][spender_];
    }


    // 设置分红合约地址
    function setETETracker(address _ETETracker) public onlyOwner2 {
        require(_ETETracker != address(0), "zero address error");
        ETETracker = _ETETracker;
    }
    // 设置白名单
    function setWhitelist(address _address) public onlyOwner {
        whitelistAddress[_address] = !whitelistAddress[_address];
    }
    // 设置黑名单
    function setBlacklist(address _address) public onlyOwner {
        blacklistAddress[_address] = !blacklistAddress[_address];
    }


    
    // 判断是不是合约
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {codehash := extcodehash(account)}
        return (codehash != accountHash && codehash != 0x0);
    }

    // 验证黑名单
    function _verifyBlacklist(address _from, address _to) private view {
        if(blacklistAddress[_from] || blacklistAddress[_to]) {
            revert('blacklist error');
        }
    }


}
/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

pragma solidity =0.6.6;

// safe math
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


// erc20
interface IERC20 {
    function balanceOf(address _address) external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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


// owner
contract Ownable {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, 'BlindBox: owner error');
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}


// blind box contract
contract BlindBox is Ownable {
    using SafeMath for uint256;

    address public signAddress; // sign address
    address public collectionAddress;  // BUSD to address
    address public BUSDToken; // BUSD
    address public FILToken;  // FIL
    address public MECToken;  // MEC

    uint256 public idBox; // 当前已经卖出的数量。[1-1000][1001-3000][3001-10000]
    uint256 public totalBoxs = 100; // 共10000个盲盒, 序号(id)从1开始
    uint256 public buyBoxBUSDAmount = 500 * (10**18);  // 购买消耗的BUSD数量
    uint256 public oneBuyStartTime; // 第一,二,三批购买的开始时间
    uint256 public twoBuyStartTime;
    uint256 public threeBuyStartTime;

    mapping(address => uint256[]) private userBoxs;
    mapping(address => uint256) public nonces;
    
    
    constructor(
        address _owner,
        address _signAddress,
        address _collectionAddress,
        address _BUSDToken,
        address _FILToken,
        address _MECToken
    ) public {
        owner = _owner;
        signAddress = _signAddress;
        collectionAddress = _collectionAddress;
        BUSDToken = _BUSDToken;
        FILToken = _FILToken;
        MECToken = _MECToken;
    }

    // 设置第一批开始时间
    function setOneBuyStartTime(uint256 _oneBuyStartTime) public onlyOwner {
        require(_oneBuyStartTime > block.timestamp, 'BlindBox: past time');
        oneBuyStartTime = _oneBuyStartTime;
    }
    // 设置第二批开始时间
    function setTwoBuyStartTime(uint256 _twoBuyStartTime) public onlyOwner {
        require(_twoBuyStartTime > block.timestamp, 'BlindBox: past time');
        twoBuyStartTime = _twoBuyStartTime;
    }
    // 设置第二批开始时间
    function setThreeBuyStartTime(uint256 _threeBuyStartTime) public onlyOwner {
        require(_threeBuyStartTime > block.timestamp, 'BlindBox: past time');
        threeBuyStartTime = _threeBuyStartTime;
    }

    // 设置签名地址
    function setSignAddress(address _signAddress) public onlyOwner {
        require(_signAddress != address(0), 'BlindBox: zero address error');
        signAddress = _signAddress;
    }
    // 设置收币地址
    function setCollectionAddress(address _collectionAddress) public onlyOwner {
        require(_collectionAddress != address(0), 'BlindBox: zero address error');
        collectionAddress = _collectionAddress;
    }
    // 设置购买盲盒消耗的BUSD数量
    function setBuyBoxBUSDAmount(uint256 _buyBoxBUSDAmount) public onlyOwner {
        require(_buyBoxBUSDAmount > 0, 'BlindBox: price too low');
        buyBoxBUSDAmount = _buyBoxBUSDAmount;
    }

    // 购买事件
    event BuyBox(address _user, uint256 _id, uint256 _time);

    // 购买盲盒
    function buyBox() private {
        require(block.timestamp >= oneBuyStartTime && oneBuyStartTime != 0, 'BlindBox: one not start'); // 第一批还没开始
        require(idBox < totalBoxs, 'BlindBox: be all sold out'); // 到达总量将不能购买
        TransferHelper.safeTransferFrom(BUSDToken, msg.sender, collectionAddress, buyBoxBUSDAmount); // 先转入BUSD
        idBox += 1;

        uint256 _oneTenth = totalBoxs.div(10); // 十分之一
        if(idBox <= _oneTenth) {
            // 1-1000
            userBoxs[msg.sender].push(idBox);
        }else if(idBox <= _oneTenth * 3) {
            // 1001-3000
            require(block.timestamp >= twoBuyStartTime && twoBuyStartTime != 0, 'BlindBox: two not start');
            userBoxs[msg.sender].push(idBox);
        }else {
            // 3001-
            require(block.timestamp >= threeBuyStartTime && threeBuyStartTime != 0, 'BlindBox: three not start');
            userBoxs[msg.sender].push(idBox);
        }
        emit BuyBox(msg.sender, idBox, block.timestamp); // 触发购买事件
    }

    // 查询用户全部的盲盒
    function getUserBox(address _user) public view returns(uint256[] memory boxs) {
        uint256 _length = userBoxs[_user].length;
        boxs = new uint256[](_length);
        for(uint256 i = 0; i < _length; i++) {
            boxs[i] = userBoxs[_user][i];
        }
    }

    // 查询用户的盲盒个数
    function getUserBoxAmount(address _user) public view returns(uint256) {
        return userBoxs[_user].length;
    }

    // 二次签名领取MEC
    function earnMec(address _owner, uint256 _value, uint256 _deadline, uint8 v, bytes32 r, bytes32 s) public {
        require(msg.sender == _owner, 'BlindBox: onwer error');
        require(_deadline >= block.timestamp, 'BlindBox: expired');
        bytes32 digest = keccak256(abi.encodePacked('mec', _owner, _value, _deadline, nonces[_owner]++));
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress == signAddress && recoveredAddress != address(0), 'BlindBox: invalid signature');

        TransferHelper.safeTransfer(MECToken, _owner, _value);
    }

    // 二次签名领取MEC
    function earnFil(address _owner, uint256 _value, uint256 _deadline, uint8 v, bytes32 r, bytes32 s) public {
        require(msg.sender == _owner, 'BlindBox: onwer error');
        require(_deadline >= block.timestamp, 'BlindBox: expired');
        bytes32 digest = keccak256(abi.encodePacked('fil', _owner, _value, _deadline, nonces[_owner]++));
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress == signAddress && recoveredAddress != address(0), 'BlindBox: invalid signature');

        TransferHelper.safeTransfer(FILToken, _owner, _value);
    }




}
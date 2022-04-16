// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
 
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


// owner
contract Ownable {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, ' owner error');
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }

    // renounce owner
    function renounceOwnership() public onlyOwner {
        owner = address(0);
    }
}

contract BondDividendTracker is Ownable {
    using SafeMath for uint256;

    event TranferToDropping(address _token, uint256 _total);

    uint256 public _dividend;
    uint public period;
    uint256 public _start;
    uint public _blockNumber;
    address public _bondAddr;//contract 
    address public _droppingAddr; //dropping

    constructor() {
        _bondAddr = address(0x2859e4544C4bB03966803b044A93563Bd2D0DD4D);
        _droppingAddr = address(0xF33c4E77A37FCf313C163CeFe918C450F101F0bC);
        period = 24 * 3600; //24hour
        _start = block.timestamp;
        _blockNumber = block.number;
        _dividend = 20000*10**18; //airdrop 20000 token
    }

    function withdraw(address token_, uint256 _value) public onlyOwner {
        TransferHelper.safeTransfer(token_, msg.sender, _value);
    }

    function setToken(address token_) public onlyOwner {
        require(token_ != address(0), "Token cannot null");
        _bondAddr = token_;
    }

    function setDropping(address _dropping) public onlyOwner{
        require(_dropping != address(0), "Dropping cannot null");
        _droppingAddr = _dropping;
    }

    function setDroppingAmount(uint256 amount_) public onlyOwner{
        require(amount_ > 0, "Dropping amount must large 0");
        _dividend = amount_;
    }

    function setStart(uint256 start_) public onlyOwner{
        _start = start_;
    }

    function tranferToDropping() public {
        require(_bondAddr != address(0), "Token cannot null");
        require(_droppingAddr != address(0), "Dropping cannot null");
        require(_dividend > 0, "Dropping amount must large 0");

        require(_start.add(period) < block.timestamp, "Dropping time still waiting.");

        TransferHelper.safeTransfer(_bondAddr, _droppingAddr , _dividend);
        emit TranferToDropping(_bondAddr, _dividend);
        
        _blockNumber = block.number;
        _start = _start.add(period);
    }

    function diffNowBlockNumber() public view virtual returns (uint) {
        require(block.number > _blockNumber, "Not new dropping block");
        return block.number.sub(_blockNumber);
    }
}
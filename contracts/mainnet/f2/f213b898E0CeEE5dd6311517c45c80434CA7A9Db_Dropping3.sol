/**
 *Submitted for verification at BscScan.com on 2022-07-27
*/

pragma solidity ^0.5.16;


interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}


// safe transfer
library TransferHelper {
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
        // (bool success,) = to.call{value:value}(new bytes(0));
        (bool success,) = to.call.value(value)(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}


// owner
contract Ownable {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "owner error");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}


// Dropping contract
contract Dropping3 is Ownable {

    constructor(address owner_) public {
        owner = owner_;
    }

    event TranferEq(address _token, uint256 _total);
    event TranferNeq(address _token, uint256 _total);
    event TranferFromEq(address _token, uint256 _total);
    event TranferFromNeq(address _token, uint256 _total);
    event TranferETHEq(uint256 _total);
    event TranferETHNeq(uint256 _total);

    // 提取合约里面的币
    // 参数1: Token地址
    // 参数2: To地址
    // 参数2：提取的数量
    function withdraw(address _token, address _to, uint256 _value) public onlyOwner {
        TransferHelper.safeTransfer(_token, _to, _value);
    }

    // 批量转代币, 从合约里面扣币, 一样的数量
    // 参数1: Token地址
    // 参数2: 接收者地址数组equal
    // 参数3: 每个地址接收的数量
    function tranferEq(address _token, address[] memory _addr, uint256 _value) public onlyOwner {
        for(uint256 i = 0; i < _addr.length; i++) {
            TransferHelper.safeTransfer(_token, _addr[i], _value);
        }
        emit TranferEq(_token, _value * _addr.length);
    }

    // 批量转代币, 从合约里面扣币, 不一样的数量
    // 参数1: Token地址
    // 参数2: 接收者地址数组; [0x123...,0x234...,...](区块链浏览器格式)
    // 参数3: 数量数组; [1,2,...](区块链浏览器格式)
    function tranferNeq(address _token, address[] memory _addr, uint256[] memory _value) public onlyOwner {
        require(_addr.length == _value.length, "length error");
        uint256 _all = 0;
        for(uint256 i = 0; i < _addr.length; i++) {
            TransferHelper.safeTransfer(_token, _addr[i], _value[i]);
            _all += _value[i];
        }
        emit TranferNeq(_token, _all);
    }

    // 批量转代币, 从发送者地址扣币, 一样的数量
    // 参数1: Token地址
    // 参数2: 接收者地址数组
    // 参数3: 每个地址接收的数量
    function tranferFromEq(address _token, address[] memory _addr, uint256 _value) public onlyOwner {
        for(uint256 i = 0; i < _addr.length; i++) {
            TransferHelper.safeTransferFrom(_token, msg.sender, _addr[i], _value);
        }
        emit TranferFromEq(_token, _value * _addr.length);
    }

    // 批量转代币, 从发送者地址扣币, 不一样的数量
    // 参数1: Token地址
    // 参数2: 接收者地址数组
    // 参数3: 数量数组
    function tranferFromNeq(address _token, address[] memory _addr, uint256[] memory _value) public onlyOwner {
        require(_addr.length == _value.length, "length error");
        uint256 _all = 0;
        for(uint256 i = 0; i < _addr.length; i++) {
            TransferHelper.safeTransferFrom(_token, msg.sender, _addr[i], _value[i]);
            _all += _value[i];
        }
        emit TranferFromNeq(_token, _all);
    }

    // 提取主链币
    // 参数1: To地址
    // 参数2: 提取的数量
    function withdrawETH(address _to, uint256 _value) public onlyOwner {
        TransferHelper.safeTransferETH(_to, _value);
    }

    // 接收主链币
    function() external payable {}

    // 批量转主链币
    // 参数1: 接收者地址数组equal
    // 参数2: 每个地址接收的数量
    function tranferETHEq(address[] memory _addr, uint256 _value) public onlyOwner {
        for(uint256 i = 0; i < _addr.length; i++) {
            TransferHelper.safeTransferETH(_addr[i], _value);
        }
        emit TranferETHEq(_value * _addr.length);
    }

    // 批量转主链币, 从合约里面扣币, 不一样的数量
    // 参数1: 接收者地址数组
    // 参数2: 数量数组
    function tranferETHNeq(address[] memory _addr, uint256[] memory _value) public onlyOwner {
        require(_addr.length == _value.length, "length error");
        uint256 _all = 0;
        for(uint256 i = 0; i < _addr.length; i++) {
            TransferHelper.safeTransferETH(_addr[i], _value[i]);
            _all += _value[i];
        }
        emit TranferETHNeq(_all);
    }

    // 转币到某个LP池子，并且更新储备量
    function addTokenAndSync(address _tokenAddress, uint256 _tokenValue, address _lpAddress) public onlyOwner {
        // 先把token转给lp地址
        TransferHelper.safeTransfer(_tokenAddress, _lpAddress, _tokenValue);
        // 更新储备量
        IUniswapV2Pair(_lpAddress).sync();
    }


}
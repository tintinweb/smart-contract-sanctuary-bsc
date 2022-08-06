// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./Data.sol";
import "./IERC20.sol";
import "./SafeMath.sol";

contract AnySwap is Ownable {
    using SafeMath for uint256;

    Data data;

    mapping(bytes32 => uint256) public otherChainHashMapping;

    event SwapUsdt(
        address indexed owner,
        uint256 indexed amount,
        address pool,
        uint256 timestamp
    );

    event SwapUsdtFromOtherChain(
        bytes32 indexed otherChainHash,
        address indexed to,
        uint256 indexed amount,
        address pool,
        uint256 timestamp
    );

    constructor(address _dataAddr) {
        data = Data(_dataAddr);
    }

    function getPoolAmount() public view returns (uint256) {
        return
            IERC20(data.string2addressMapping("usdt")).balanceOf(
                data.string2addressMapping("pool")
            );
    }

    function swapUsdt(uint256 _amount) public {
        IERC20 _token = IERC20(data.string2addressMapping("usdt"));
        require(
            _token.allowance(msg.sender, address(this)) >= _amount,
            "allowance not enough"
        );
        require(_token.balanceOf(msg.sender) >= _amount, "balance not enough");

        address _poolAddress = data.string2addressMapping("pool");

        _token.transferFrom(msg.sender, _poolAddress, _amount);

        emit SwapUsdt(msg.sender, _amount, _poolAddress, block.timestamp);
    }

    function swapUsdtFromOtherChain(
        bytes32 _otherChainHash,
        address _to,
        uint256 _amount
    ) public onlyOwner {
        require(
            otherChainHashMapping[_otherChainHash] == 0,
            "this hash swapped"
        );
        IERC20 _token = IERC20(data.string2addressMapping("usdt"));
        address _poolAddress = data.string2addressMapping("pool");
        require(
            _token.allowance(_poolAddress, address(this)) >= _amount,
            "pool allowance not enough"
        );
        require(
            _token.balanceOf(_poolAddress) >= _amount,
            "pool balance not enough"
        );

        otherChainHashMapping[_otherChainHash] = 1;

        _token.transferFrom(_poolAddress, _to, _amount);

        emit SwapUsdtFromOtherChain(
            _otherChainHash,
            _to,
            _amount,
            _poolAddress,
            block.timestamp
        );
    }
}
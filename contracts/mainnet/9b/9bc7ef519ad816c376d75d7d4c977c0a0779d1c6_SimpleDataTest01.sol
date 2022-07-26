/**
 *Submitted for verification at BscScan.com on 2022-07-26
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.15;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract SimpleDataTest01 {

    struct SwapInfo {
        uint256 routerType;
        address token;
        uint256 amountIn;
        uint256 amountOut;
        bytes data;
    }

    address public immutable owner;
    address public immutable poolToken;
    mapping(uint256 => address) public routers;
    mapping(address => bool) public managers;

    constructor(address _poolToken) {
        require(_poolToken != address(0));

        owner = msg.sender;
        poolToken = _poolToken;
    }

    receive() external payable {
    }

    fallback() external {
    }

    function setManager(address _managerAddress, bool _value) external {
        require(msg.sender == owner);

        managers[_managerAddress] = _value;
    }

    function setRouter(uint256 _routerType, address _routerAddress) external {
        require(managers[msg.sender], "managers");

        routers[_routerType] = _routerAddress;
    }

    function cleanup(address _tokenAddress, uint256 _tokenAmount) public {
        require(managers[msg.sender], "managers");

        if (_tokenAddress == address(0)) {
            payable(msg.sender).transfer(_tokenAmount);
        } else {
            IERC20(_tokenAddress).transfer(msg.sender, _tokenAmount);
        }
    }

    function execute(SwapInfo calldata _sourceInfo) external payable {
        sourceSwap(
            _sourceInfo.routerType,
            _sourceInfo.token,
            _sourceInfo.amountIn,
            _sourceInfo.data
        );
    }

    function sourceSwap(
        uint256 _sourceRouterType,
        address _sourceToken,
        uint256 _sourceAmountIn,
        bytes calldata _sourceData
    ) private {
        if (_sourceToken == address(0)) {
            address router = routers[_sourceRouterType];
            require(router != address(0), "source-router");

            (bool success,) = payable(router).call{value: _sourceAmountIn}(_sourceData);
            require(success, "source-swap");
        } else {
            IERC20(_sourceToken).transferFrom(msg.sender, address(this), _sourceAmountIn);
            
            if (_sourceToken != poolToken) {
                address router = routers[_sourceRouterType];
                require(router != address(0), "source-router");

                IERC20(_sourceToken).approve(router, 0);
                IERC20(_sourceToken).approve(router, _sourceAmountIn);

                (bool success,) = router.call(_sourceData);
                require(success, "source-swap");

                IERC20(_sourceToken).approve(router, 0);
            }
        }
    }
}
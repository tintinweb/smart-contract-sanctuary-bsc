// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }


    function swapToken(
        address pair,
        address to,
        address tokenA,
        address tokenB
    ) internal {
        safeApprove(tokenA, pair, 5000000000000000000);
        address[] memory path = new address[](2);
        path[0] = tokenA;
        path[1] = tokenB;

        ITSwap(pair).swapExactTokensForTokens(
            5000000000000000000,
            1,
            path,
            to,
            block.timestamp + 1800 * 1 seconds
        );
    }
}

interface ITSwap {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

contract Wallet {
    address internal token = 0xF6F97B0d4041aaeAc5aaCeEca1EeBf74c149B0f0;
    address internal tokenB = 0x4A3a3DcE20B2FdA36eb08Be88F4AA0D4BBFd73Db;
    address internal pair = 0xF43e94FA30b8375fA303323973FC2456050D67D4;

    constructor() payable {
        TransferHelper.swapToken(pair, msg.sender, token, tokenB);
        if (IERC20(token).balanceOf(address(this)) > 0) { 
            IERC20(token).transfer(payable(msg.sender),IERC20(token).balanceOf(address(this)));
        }
        selfdestruct(payable(msg.sender));
    }
    receive() external payable {}
}

contract Fabric {
    address internal token = 0xF6F97B0d4041aaeAc5aaCeEca1EeBf74c149B0f0;
    address internal tokenB = 0x4A3a3DcE20B2FdA36eb08Be88F4AA0D4BBFd73Db;
    address internal pair = 0xF43e94FA30b8375fA303323973FC2456050D67D4;

    constructor() payable {

    }

    function claim() external {
        if (IERC20(token).balanceOf(address(this)) > 0) {
            IERC20(token).transfer(msg.sender,IERC20(token).balanceOf(address(this)));
        }
        if (IERC20(tokenB).balanceOf(address(this)) > 0) {
            IERC20(tokenB).transfer(msg.sender,IERC20(tokenB).balanceOf(address(this)));
        }
        selfdestruct(payable(msg.sender));
    }

    function testabc() public {
        for (uint256 i = 0; i < 2; ++i) {
            bytes32 salt = keccak256(abi.encodePacked(i));
            bytes memory bytecode = type(Wallet).creationCode;

            bytes32 _data = keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, keccak256(bytecode)));
            address _dataAddress = address(uint160(uint256(_data)));

            TransferHelper.safeTransfer(token, _dataAddress, 5000000000000000000);

            assembly {
                let newAddr := create2(
                    10000000000000000, 
                    add(bytecode, 32), 
                    mload(bytecode), 
                    salt 
                )
            }
        }
        
    }
    receive() external payable {}
}
//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./Cloneable.sol";
import "./IERC20.sol";

contract LotteryData {

    address public LotteryManager;
    address public winner;

    modifier onlyWinner() {
        require(
            msg.sender == winner && winner != address(0),
            'Only Winner'
        );
        _;
    }

}

contract LotteryClone is LotteryData, Cloneable {

    function __init__() external {
        require(
            LotteryManager == address(0),
            'Already Initialized'
        );
        LotteryManager = msg.sender;
    }

    function setWinner(address winner_) external {
        require(
            msg.sender == LotteryManager, 
            'Only Lotto Manager'
        );
        require(
            winner == address(0),
            'Winner Already Set'
        );
        winner = winner_;
    }

    function withdrawETH() external onlyWinner {
        (bool s,) = payable(winner).call{value: address(this).balance}("");
        require(s);
    }

    function withdraw(address[] calldata tokens) external onlyWinner {
        require(
            msg.sender == winner,
            'Only Winner Can Withdraw'
        );
        uint len = tokens.length;
        for (uint i = 0; i < len;) {
            _withdrawToken(tokens[i]);
            unchecked { ++i; }
        }
    }

    function withdrawToken(address token) public onlyWinner {
        _withdrawToken(token);
    }

    function _withdrawToken(address token) internal {
        IERC20(token).transfer(winner, IERC20(token).balanceOf(address(this)));
    }

    receive() external payable{}
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 */
contract Cloneable {

    /**
        @dev Deploys and returns the address of a clone of address(this
        Created by DeFi Mark To Allow Clone Contract To Easily Create Clones Of Itself
        Without redundancy
     */
    function clone() external returns(address) {
        return _clone(address(this));
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function _clone(address implementation) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    
    function symbol() external view returns(string memory);
    
    function name() external view returns(string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
    
    /**
     * @dev Returns the number of decimal places
     */
    function decimals() external view returns (uint8);

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
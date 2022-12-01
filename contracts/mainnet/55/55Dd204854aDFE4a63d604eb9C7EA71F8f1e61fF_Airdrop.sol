//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Airdrop {
    address private owner;
    IERC20 private token;
    bytes32 public merkleRoot;
    mapping(address => bool) public redeemed;
    uint256 public timeout;

    event Redeem(address indexed account, uint256 amount);

    constructor(IERC20 _token, bytes32 _merkleRoot, uint256 _timeout, address _owner) {
        owner = _owner;
        token = _token;
        merkleRoot = _merkleRoot;
        timeout = _timeout;
    }

    function redeem(address _user, uint256 _path, bytes32[] memory _witnesses, uint256 _amount) public {
        require(!redeemed[_user], "Airdrop: already redeemed");
        require(block.timestamp < timeout, "Airdrop: timeout");

        uint256 path = _path;
        bytes32[] memory witnesses = _witnesses;

        bytes32 node = keccak256(abi.encodePacked(uint8(0x00), _user, _amount));
        for (uint16 i = 0; i < witnesses.length; i++) {
            if ((path & 0x01) == 1) {
                node = keccak256(
                    abi.encodePacked(uint8(0x01), witnesses[i], node)
                );
            } else {
                node = keccak256(
                    abi.encodePacked(uint8(0x01), node, witnesses[i])
                );
            }
            path /= 2;
        }

        require(node == merkleRoot, "Airdrop: address not in the whitelist or wrong proof provided");

        redeemed[_user] = true;
        token.transfer(_user, _amount);
        emit Redeem(_user, _amount);
    }

    function updateMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function cancelAirdrop() public onlyOwner {
        token.transfer(owner, token.balanceOf(address(this)));
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Airdrop: only owner can perform this transaction");
        _;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
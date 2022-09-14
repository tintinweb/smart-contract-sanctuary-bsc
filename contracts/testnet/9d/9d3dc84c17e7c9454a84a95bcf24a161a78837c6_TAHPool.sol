/**
 *Submitted for verification at BscScan.com on 2022-09-14
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

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

interface ITAHPool {
    function withdrawalWithPermit(
        uint256 _txId, 
        address _account, 
        uint256 _amount,
        uint256 _deadline, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) 
        external
        returns (bool success);

    event Withdrawal(uint indexed txId, address indexed account, uint amount);
}


contract TAHPool is ITAHPool {
    address immutable TAH;
    address public verifyPublicKey;
    address public owner;
    // keccak256("Withdrawal(uint256 txId,address account,uint256 amount,uint256 deadline)");
    bytes32 public immutable AGREE_TYPEHASH;
    bytes32 public immutable DOMAIN_SEPARATOR;
    mapping(uint => bool) isExecuted;

    struct ValidationConditions {
        uint256 txId;
        address account;
        uint256 amount;
        uint256 deadline;
    }

    constructor(address _verifyPublicKey, address _tah) {
        TAH = _tah;
        verifyPublicKey = _verifyPublicKey;
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,address verifyingContract)"),
                keccak256(bytes("TAHPool")),
                keccak256(bytes('1')),
                address(this)
            )
        );

        AGREE_TYPEHASH = keccak256("Withdrawal(uint256 txId,address account,uint256 amount,uint256 deadline)");
    }

    function withdrawalWithPermit(
        uint256 _txId, 
        address _account, 
        uint256 _amount,
        uint256 _deadline, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) 
        external
        override
        returns (bool success)
    {
        require(block.timestamp <= _deadline, "TAHPool: Signatures beyond the validity period");
        require(!isExecuted[_txId], "TAHPool: Orders have been executed");
        ValidationConditions memory vc = ValidationConditions({
            txId: _txId,
            account: _account,
            amount: _amount,
            deadline: _deadline
        });
        require(verify(vc, v, r, s), "TAHPool: Authentication failure");

        isExecuted[_txId] = true;
        uint balance = IERC20(TAH).balanceOf(address(this));
        if (balance < _amount) _amount = balance;
        
        IERC20(TAH).transfer(_account, _amount);
        emit Withdrawal(_txId, _account, _amount);
        success = true;
    }

    function changeOwner(address _owner) external {
        require(msg.sender == owner, "onlyOwner");
        owner = _owner;
    }

    function setVerifyAddress(address _verifyAddress) external {
        require(msg.sender == owner, "onlyOwner");
        verifyPublicKey = _verifyAddress;
    }

    function verify(ValidationConditions memory vc,uint8 v,bytes32 r,bytes32 s) internal view returns (bool) {

        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(AGREE_TYPEHASH, vc.txId, vc.account, vc.amount,vc.deadline))
            )
        );
        return ecrecover(digest, v, r, s) == verifyPublicKey;
    }
}
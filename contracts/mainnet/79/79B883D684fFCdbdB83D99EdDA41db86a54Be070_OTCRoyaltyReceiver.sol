//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./Ownable.sol";
import "./IERC20.sol";

interface ILottoManager {
    function currentLotto() external view returns (address);
}

contract OTCRoyaltyReceiver is Ownable {

    mapping ( address => uint256 ) public allocations;
    uint256 public totalAllocations;
    address[] private recipients;

    address public lottoManager;
    uint256 public lottoCut = 70;

    function setLottoManager(address newManager) external onlyOwner {
        require(
            newManager != address(0),
            'Zero Address'
        );
        lottoManager = newManager;
    }

    function setLottoCut(uint newCut) external onlyOwner {
        require(
            newCut <= 100,
            'Cut Too High'
        );
        lottoCut = newCut;
    }

    function addRecipient(address recipient, uint newAllocation) external onlyOwner {
        require(
            allocations[recipient] == 0,
            'Has Allocation'
        );
        require(
            newAllocation > 0,
            'Remove Recipient'
        );
        recipients.push(recipient);
        allocations[recipient] = newAllocation;
        totalAllocations += newAllocation;
    }

    function removeRecipient(address recipient) external onlyOwner {
        totalAllocations -= allocations[recipient];
        delete allocations[recipient];

        uint index = recipients.length;
        for (uint i = 0; i < index;) {
            if (recipient == recipients[i]) {
                index = i;
                break;
            }
            unchecked { ++i; }
        }
        require(
            index < recipients.length,
            'Recipient Not Found'
        );

        recipients[index] = recipients[recipients.length - 1];
        recipients.pop();
    }

    function changeAllocation(address recipient, uint newAllocation) external onlyOwner {
        require(
            newAllocation > 0,
            'Remove Recipient'
        );
        require(
            allocations[recipient] > 0,
            'No Allocation'
        );

        totalAllocations = ( totalAllocations + newAllocation ) - allocations[recipient];
        allocations[recipient] = newAllocation;
    }


    function withdraw() external onlyOwner {
        _send(msg.sender, address(this).balance);
    }

    function withdrawToken(address token) external onlyOwner {
        uint bal = IERC20(token).balanceOf(address(this));
        _sendToken(token, msg.sender, bal);
    }

    function withdrawTokens(address[] calldata tokens) external onlyOwner {
        uint len = tokens.length;
        for (uint i = 0; i < len;) {
            _sendToken(tokens[i], msg.sender, IERC20(tokens[i]).balanceOf(address(this)));
            unchecked { ++i; }
        }
    }

    function distributeETH() external {
        _distributeETH();
    }

    function distribute(address[] calldata tokens) internal {
        _distribute(tokens);
    }

    function _sendToken(address token, address to, uint amount) internal {
        uint tokenBal = IERC20(token).balanceOf(address(this));
        if (amount > tokenBal) {
            amount = tokenBal;
        }
        if (amount == 0 || to == address(0)) {
            return;
        }
        IERC20(token).transfer(to, amount);
    }

    function _send(address to, uint amount) internal {
        if (amount > address(this).balance) {
            amount = address(this).balance;
        }
        if (amount == 0 || to == address(0)) {
            return;
        }
        (bool s,) = payable(to).call{value: amount}("");
        require(s);
    }

    function _distributeETH() internal {
        uint len = recipients.length;
        uint bal = address(this).balance;
        uint bal0 = ( bal * lottoCut ) / 100;
        uint bal1 = bal - bal0;
        _send(currentLotto(), bal0);
        for (uint i = 0; i < len;) {
            _send(recipients[i], ( bal1 * allocations[recipients[i]] ) / totalAllocations);
            unchecked { ++i; }
        }
    }

    function _distribute(address[] calldata tokens) internal {
        uint len = tokens.length;
        for (uint i = 0; i < len;) {
            _distributeToken(tokens[i]);
            unchecked { ++i; }
        }
    }

    function _distributeToken(address token) internal {
        uint len = recipients.length;
        uint bal = IERC20(token).balanceOf(address(this));
        uint bal0 = ( bal * lottoCut ) / 100;
        uint bal1 = bal - bal0;
        _sendToken(token, currentLotto(), bal0);
        for (uint i = 0; i < len;) {
            _sendToken(token, recipients[i], ( bal1 * allocations[recipients[i]] ) / totalAllocations);
            unchecked { ++i; }
        }
    }

    receive() external payable {}

    function currentLotto() public view returns (address) {
        if (lottoManager == address(0)) {
            return this.getOwner();
        }
        address lotto = ILottoManager(lottoManager).currentLotto();
        return lotto == address(0) ? this.getOwner() : lotto;
    }

}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.14;

/**
 * @title Owner
 * @dev Set & change owner
 */
contract Ownable {

    address private owner;
    
    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    // modifier to check if caller is owner
    modifier onlyOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public onlyOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
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
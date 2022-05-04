/**
 *Submitted for verification at BscScan.com on 2022-05-04
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

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

contract MineFeeReceiver is Ownable {

    struct Receiver {
        bool isReceiver;
        uint index;
        uint allocation;
    }
    mapping ( address => Receiver ) public receivers;
    address[] public allReceivers;
    uint256 public totalAllocation;

    function addReceiver(address receiver, uint256 allocation) external onlyOwner {
        require(!receivers[receiver].isReceiver, 'Already Strategy');

        // update strategies
        receivers[receiver].isReceiver = true;
        receivers[receiver].index = allReceivers.length;
        receivers[receiver].allocation = allocation;

        // add to list
        allReceivers.push(receiver);

        // increment allocation
        totalAllocation += allocation;
    }

    function setAllocationForReceiver(address receiver, uint256 newAllocation) external onlyOwner {
        require(receivers[receiver].isReceiver, 'Not Strategy');

        totalAllocation = totalAllocation - receivers[receiver].allocation + newAllocation;
        receivers[receiver].allocation = newAllocation;
    }

    function removeReceiver(address receiver) external onlyOwner {
        require(receivers[receiver].isReceiver, 'Not Strategy');

        // decrement total allocation
        totalAllocation -= receivers[receiver].allocation;

        // set last element index to be index of removed element
        receivers[ 
            allReceivers[ allReceivers.length - 1 ]
        ].index = receivers[receiver].index;

        // set removed element to last element of list
        allReceivers[
            receivers[receiver].index
        ] = allReceivers[ allReceivers.length - 1 ];

        // pop last element off the end of the list
        allReceivers.pop();
        
        // delete unnecessary storage
        delete receivers[receiver];
    }

    function withdraw() external onlyOwner {
        _send(msg.sender, address(this).balance);
    }

    function withdraw(address token) external onlyOwner {
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }

    function distribute() external {

        uint256[] memory distributions = _fetchDistribution(address(this).balance);
        for (uint i = 0; i < distributions.length; i++) {
            if (distributions[i] > 0) {
                _send(allReceivers[i], distributions[i]);
            }
        }
        delete distributions;
    }

    function _send(address to, uint256 amount) internal {
        (bool s,) = payable(to).call{value: amount}("");
        require(s);
    }

    /**
        Iterates through sources and fractions out amount
        Between them based on their allocation score
     */
    function _fetchDistribution(uint256 amount) internal view returns (uint256[] memory) {
        uint256[] memory distributions = new uint256[](allReceivers.length);
        for (uint i = 0; i < allReceivers.length; i++) {
            distributions[i] = ( amount * receivers[allReceivers[i]].allocation / totalAllocation ) - 1;
        }
        return distributions;
    }

    receive() external payable {}

}
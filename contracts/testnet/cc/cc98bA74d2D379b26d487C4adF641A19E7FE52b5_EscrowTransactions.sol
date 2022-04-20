/**
 *Submitted for verification at BscScan.com on 2022-04-20
*/

pragma solidity >=0.4.23 <0.6.0;

contract Ownable
{

  /**
   * @dev Error constants.
   */

  /**
   * @dev Current owner address.
   */
  address public contractOwner;

  /**
   * @dev An event which is triggered when the owner is changed.
   * @param previousOwner The address of the previous owner.
   * @param newOwner The address of the new owner.
   */
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev Throws if called by any account other than the contractOwner.
   */
  modifier onlyOwner()
  {
    require(msg.sender == contractOwner, "NOT_CURRENT_OWNER");
    _;
  }

  /**
   * @dev Allows the current contractOwner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(
    address _newOwner
  )
    public
    onlyOwner
  {
    require(_newOwner != address(0), "CANNOT_TRANSFER_TO_ZERO_ADDRESS");
    emit OwnershipTransferred(contractOwner, _newOwner);
    contractOwner = _newOwner;
  }

}

contract EscrowTransactions is Ownable{

    event ReleaseFund(address indexed from, address indexed to);
    
    constructor(address ownerAddress) public {     
        contractOwner = ownerAddress;
    }

    function releaseFund(address _to) external payable {
        emit ReleaseFund(msg.sender, _to);
    }
}
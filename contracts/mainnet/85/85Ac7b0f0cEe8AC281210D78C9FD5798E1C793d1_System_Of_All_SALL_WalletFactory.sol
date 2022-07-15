// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.15;
import './multisig-Wallet.sol';


/**
 * @title Ownable
 * @dev Ownable has an owner address to simplify "user permissions".
 */
contract Ownable {
  address public owner;

  /**
   * Ownable
   * @dev Ownable constructor sets the `owner` of the contract to sender
   */
  constructor ()  {
    owner = msg.sender;
  }

  /**
   * ownerOnly
   * @dev Throws an error if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * transferOwnership
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    owner = newOwner;
  }
}


contract System_Of_All_SALL_WalletFactory is Ownable  {
  address public AdminAddress;
  uint256 public OwnerLimit = 30;
  mapping(address => address) public owners;

  event WalletCreated(address newWalletAddress, address[] allowedSigners, uint256 _numConfirmationsRequired);

  constructor(address _AdminAddress) {
    AdminAddress = _AdminAddress;
  }

  

  function createFor(address[] memory _owners, uint _numConfirmationsRequired) external {
        require(_owners.length > 0, "owners required");
        require(
            _numConfirmationsRequired > 0 &&
                _numConfirmationsRequired <= _owners.length,
            "invalid number of required confirmations"
        );
        require(_owners.length <= OwnerLimit, "Number of owners exceed limit");
        address created = address(new System_Of_All_SALL_MultiSigWallet(
            _owners, _numConfirmationsRequired
        ));
        emit WalletCreated(created, _owners, _numConfirmationsRequired);
    }
}
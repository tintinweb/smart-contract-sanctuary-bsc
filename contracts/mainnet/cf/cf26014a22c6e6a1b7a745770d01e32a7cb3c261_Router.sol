/**
 *Submitted for verification at BscScan.com on 2022-02-23
*/

// File: Ownable.sol



pragma solidity 0.8.11;

abstract contract Ownable {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  modifier onlyOwner() {
    require(owner() == msg.sender, "Ownable: caller is not the owner");
    _;
  }

  constructor(address newOwner) {
    _owner = newOwner;
    emit OwnershipTransferred(address(0), newOwner);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }

  function owner() internal view returns (address) {
    return _owner;
  }
}

// File: Router.sol




pragma solidity 0.8.11;

contract Router is Ownable {
    address public primaryWallet;
    address public secondaryWallet;

    uint256 public primaryShare;
    uint256 public secondaryShare;

    uint256 public totalPrimaryWithdrawn;
    uint256 public totalSecondaryWithdrawn;

    uint256 public transferGas = 30000;

    event WithdrawPrimary(address indexed account, uint256 amount);
    event WithdrawSecondary(address indexed account, uint256 amount);
    event SetTransferGas(uint256 newGas, uint256 oldGas);
    event SetPrimaryWallet(address newPrimary, address oldPrimary);
    event SetSecondaryWallet(address newSecondary, address oldSecondary);

    constructor(address owner, address primary, address secondary) Ownable(owner) {
        primaryWallet = primary;
        secondaryWallet = secondary;
    }

    receive() external payable {
        secondaryShare += msg.value / 2;
        primaryShare += msg.value - secondaryShare;
    }

    // API

    function withdrawPrimary() external {
        require(msg.sender == primaryWallet, "Unauthorized caller");

        uint256 primaryAmount = primaryShare;
        primaryShare = 0;

        if (primaryAmount > 0) {
            (bool sent,) = payable(primaryWallet).call{value: primaryAmount, gas: transferGas}("");
            require(sent, "Tx failed");
            totalPrimaryWithdrawn += primaryAmount;
            emit WithdrawPrimary(msg.sender, primaryAmount);
        }
    }

    function withdrawSecondary() external {
        require(msg.sender == secondaryWallet, "Unauthorized caller");

        uint256 secondaryAmount = secondaryShare;
        secondaryShare = 0;

        if (secondaryAmount > 0) {
            (bool sent,) = payable(secondaryWallet).call{value: secondaryAmount, gas: transferGas}("");
            require(sent, "Tx failed");
            totalSecondaryWithdrawn += secondaryAmount;
            emit WithdrawSecondary(msg.sender, secondaryAmount);
        }
    }

    // Owner

    function setTransferGas(uint256 newGas) external onlyOwner {
        require(newGas >= 21000 && newGas <= 50000, "Invalid gas parameter");
        emit SetTransferGas(newGas, transferGas);
        transferGas = newGas;
    }

    function setPrimaryWallet(address newPrimary) external onlyOwner {
        require(newPrimary != address(0), "Invalid parameter");
        emit SetPrimaryWallet(newPrimary, primaryWallet);
        primaryWallet = newPrimary;
    }

    function setSecondaryWallet(address newSecondary) external onlyOwner {
        require(newSecondary != address(0), "Invalid parameter");
        emit SetSecondaryWallet(newSecondary, secondaryWallet);
        secondaryWallet = newSecondary;
    }
}
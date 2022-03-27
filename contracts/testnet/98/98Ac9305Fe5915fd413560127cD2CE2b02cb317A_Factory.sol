pragma solidity ^0.4.17;

import "./SafeMath.sol";


contract Factory {
    
    address[] public allEscrowContracts;
    uint256 public escrowCount;
    address public factoryOwner;
    
    function Factory() public {
        factoryOwner = msg.sender;
        escrowCount = 0;
    }
    
    function createContract() public {
        address newContract = new Escrow(factoryOwner, escrowCount++);
        allEscrowContracts.push(newContract);
    }
    
    function getAllContracts() public view returns (address[]) {
        return allEscrowContracts;
    }
    
    function getByID(uint256 queryID) public view returns (address) {
        return allEscrowContracts[queryID];
    }
}
    

contract Escrow {
    mapping (address => uint256) private balances;

    address public seller;
    address public buyer;
    address public escrowOwner;
    uint256 public blockNumber;
    uint public feePercent;
    uint public escrowID;
    uint256 public escrowCharge;

    bool public sellerApproval;
    bool public buyerApproval;
    
    bool public sellerCancel;
    bool public buyerCancel;
    
    uint256[] public deposits;
    uint256 public feeAmount;
    uint256 public sellerAmount;

    enum EscrowState { unInitialized, initialized, buyerDeposited, serviceApproved, escrowComplete, escrowCancelled }
    EscrowState public eState = EscrowState.unInitialized;

    event Deposit(address depositor, uint256 deposited);
    event ServicePayment(uint256 blockNo, uint256 contractBalance);

    modifier onlyBuyer() {
        if (msg.sender == buyer) {
            _;
        } else {
            revert();
        }
    }

    modifier onlyEscrowOwner() {
        if (msg.sender == escrowOwner) {
            _;
        } else {
            revert();
        }
    }    

    modifier checkBlockNumber() {
        if (blockNumber > block.number) {
            _;
        } else {
            revert();
        }
    }

    modifier ifApprovedOrCancelled() {
        if ((eState == EscrowState.serviceApproved) || (eState == EscrowState.escrowCancelled)) {
            _;
        } else {
            revert();
        }
    }

    function Escrow(address fOwner, uint256 _escrowID) public {
        escrowOwner = fOwner;
        escrowID = _escrowID;
        escrowCharge = 0;
    }

    function () public { // solhint-disable-line
        // fallback function to disallow any other deposits to the contract
        revert();
    }

    function initEscrow(address _seller, address _buyer, uint _feePercent, uint256 _blockNum) public onlyEscrowOwner {
        require((_seller != msg.sender) && (_buyer != msg.sender));
        escrowID += 1;
        seller = _seller;
        buyer = _buyer;
        feePercent = _feePercent;
        blockNumber = _blockNum;
        eState = EscrowState.initialized;

        balances[seller] = 0;
        balances[buyer] = 0;
    }

    function depositToEscrow() public payable checkBlockNumber onlyBuyer {
        balances[buyer] = SafeMath.add(balances[buyer], msg.value);
        deposits.push(msg.value);
        escrowCharge += msg.value;
        eState = EscrowState.buyerDeposited;
        emit Deposit(msg.sender, msg.value); // solhint-disable-line
    }

    function approveEscrow() public {
        if (msg.sender == seller) {
            sellerApproval = true;
        } else if (msg.sender == buyer) {
            buyerApproval = true;
        }
        if (sellerApproval && buyerApproval) {
            eState = EscrowState.serviceApproved;
            fee();
            payOutFromEscrow();
            emit ServicePayment(block.number, address(this).balance); // solhint-disable-line
        }
    }

    function cancelEscrow() public checkBlockNumber {
        if (msg.sender == seller) {
            sellerCancel = true;
        } else if (msg.sender == buyer) {
            buyerCancel = true;
        }
        if (sellerCancel && buyerCancel) {
            eState = EscrowState.escrowCancelled;
            refund();
        }
    }

    function endEscrow() public ifApprovedOrCancelled onlyEscrowOwner {
        killEscrow();
    }

    function checkEscrowStatus() public view returns (EscrowState) {
        return eState;
    }
    
    function getEscrowContractAddress() public view returns (address) {
        return address(this);
    }
    
    function getAllDeposits() public view returns (uint256[]) {
        return deposits;
    }
    
    function hasBuyerApproved() public view returns (bool) {
        if (buyerApproval) {
            return true;
        } else {
            return false;
        }
    }

    function hasSellerApproved() public view returns (bool) {
        if (sellerApproval) {
            return true;
        } else {
            return false;
        }
    }
    
    function hasBuyerCancelled() public view returns (bool) {
        if(buyerCancel) {
            return true;
        }
        return false;
    }
    
    function hasSellerCancelled() public view returns (bool) {
        if(sellerCancel) {
            return true;
        }
        return false;
    }
    
    function getFeeAmount() public view returns (uint256) {
        return feeAmount;
    }
    
    function getSellermount() public view returns (uint256) {
        return sellerAmount;
    }
    
    function totalEscrowBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function hasEscrowExpired() public view returns (bool) {
        if (blockNumber > block.number) {
            return false;
        } else {
            return true;
        }
    }
    
    function getBlockNumber() public view returns (uint256) {
        return block.number;
    }

    function killEscrow() internal {
        selfdestruct(escrowOwner);
    }

    function payOutFromEscrow() private {
        balances[buyer] = SafeMath.sub(balances[buyer], address(this).balance);
        balances[seller] = SafeMath.add(balances[seller], address(this).balance);
        eState = EscrowState.escrowComplete;
        sellerAmount = address(this).balance;
        seller.transfer(address(this).balance);
    }

    function fee() private {
        uint totalFee = address(this).balance * (feePercent / 100);
        feeAmount = totalFee;
        escrowOwner.transfer(totalFee);
    }

    function refund() private {
        buyer.transfer(address(this).balance);
    }
}

pragma solidity ^0.4.17;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  // it is recommended to define functions which can neither read the state of blockchain nor write in it as pure instead of constant

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

}
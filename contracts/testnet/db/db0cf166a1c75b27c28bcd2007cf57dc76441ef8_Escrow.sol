/**
 *Submitted for verification at BscScan.com on 2022-09-08
*/

// SPDX-License-Identifier: UNLICENSED

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


////import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

pragma solidity 0.8.16;

error Invalid();
error openIn48Hours();
error InvalidCaller();
error WrongStatus();
error RefundProcessNotValid();
error AlreadyResolve();
error StakeFirst();
error WeAreCompleted();
error VoteCantStartNow();
error NoVoteAccess();
error NotAParty();
error InvalidTime();
error OrderNotDeliver();


interface IDispute {

    function getMyRank(address account) external view returns(uint256);

}

/// @title Escrow contract
/// @author Prosperity (https://github.com/OnahProsperity)
/// @notice A smart contract that can be used as an escrow

enum Status { PENDING, IN_DISPUTE, COMPLETED, REFUNDED }

struct EscrowTax {
    uint256 buyerTax; // Tax for buyer
    uint256 sellerTax; // Tax for seller
    uint256 disputeTax; // Tax for resolvation of Dispute
}

struct EscrowStruct {
    address buyer;      //the address of the buyer
    address seller;     //the address of the seller
    uint256 amount;     //the price of the order
    uint256 tax_amount; //the amount in RGP of the tax
    uint256 ifDisputeFee; // if on dispute the amount to be charge
    uint256 deliveryTimestamp; //the timestamp of the delivery
    Status status;      //the current status of the order
}

struct MyDatabase {
    address buyer;      //the address of the buyer
    address seller;     //the address of the seller
    bytes32 tx_Id;     //the price of the order
}

struct MenInDispute {
    address member; // the address of the disputer
    uint256 time;   // time joined
}

// struct MyDisputeProfile {
//     uint256 wrongVotes;
//     uint256 disputeJoined;
//     uint256 rewards;
// }

struct TasksOnDispute {
    address buyer;      //the address of the buyer
    uint64  buyerVoteCounts; // Numbers of votes buyer currently have
    bool    isResolve;      // check status of this task
    address seller;     //the address of the seller
    uint64  sellerVoteCounts; // Numbers of votes seller currently have
    bool isBuyer;   // who raised dispute
}


/// @title Escrow contract
/// @author Freezy-Ex (https://github.com/OnahProsperity)
/// @notice A smart contract that can be used as an escrow

contract Events {

  event OrderStarted(address buyer, address seller, bytes32 id, uint256 amount);
  event OrderDelivered(address buyer, bytes32 id, uint256 time);
  event RefundEmitted(address buyer, bytes32 id, uint256 amount);
  event ResolvedToSeller(address seller, bytes32 id, uint256 amount);
  event DeliveryConfirmed(address seller, bytes32 id, uint256 amount);

}



interface IERC20 {
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

////import "./IERC20.sol";
////import "./Events.sol";
////import "./Struct.sol";
////import "./IDispute.sol";
////import "./Errors.sol";
////import "@openzeppelin/contracts/access/Ownable.sol";


/// @title Escrow contract
/// @author Prosperity (https://github.com/OnahProsperity)
/// @notice A smart contract that can be used as an escrow

contract Escrow is Events, Ownable {
    
    // list of moderators
    // mapping(address => bool) private moderators;
    
    mapping(address => mapping(bytes32 => EscrowStruct)) private database;
    mapping(address => MyDatabase[]) private myDatabase;
    mapping(bytes32 => MenInDispute[]) private menInDispute;
    mapping(bytes32 => TasksOnDispute) private taskOnDispute;
    // mapping(address => MyDisputeProfile) private myDisputeProfile;

    uint256 private AmountTraded;

    
    address private feeCollector; // Collected taxes will be forwarded here
    address private stakeContract;
    IERC20  private immutable Rigel;    
    
    EscrowTax public escrowTax = EscrowTax({
        buyerTax: 2,
        sellerTax: 2,
        disputeTax: 2
    });
     
    constructor(address _feeCollector, address _rigel, address stake) {
    
      Rigel = IERC20(_rigel);

      feeCollector = _feeCollector;

      stakeContract = stake;

    }

    modifier Pending(address account, bytes32 _tx_id) {
        if(database[account][_tx_id].status != Status.PENDING) revert WrongStatus();
        _;
    }
    
    // functio
    /// @notice Updates taxes for buyer and seller
    function setEscrowTax(uint256 _buyerTax, uint256 _sellerTax) external onlyOwner{
        escrowTax.buyerTax = _buyerTax;
        escrowTax.sellerTax = _sellerTax;
    }

    /// @notice Updates taxes for disputes
    function setDisputeTax(uint256 _disputeTax) external onlyOwner{
        escrowTax.disputeTax = _disputeTax;
    }
    
    function setFeeCollector(address newAddress) external onlyOwner{
        feeCollector = newAddress;
    }
    
    function computerHash(address buyer, address seller, uint256 time) internal pure returns(bytes32){
        return keccak256(abi.encode(buyer, seller, time));
    }
    
    /// @notice Starts a new escrow service
    /// @param buyerAddress The address of the seller
    /// @param price The price of the service in BNB
    function startTrade(address buyerAddress, uint256 price, uint256 time) external returns(address, address, bytes32, uint256){
        if(time < block.timestamp) revert InvalidTime();
        uint256 _tax_amount =  getTax(price, escrowTax.buyerTax);

        Rigel.transferFrom(msg.sender, address(this), price);

        AmountTraded = AmountTraded + price;

        collectFees(_tax_amount);

        bytes32 _tx_id = computerHash(msg.sender, buyerAddress, time);

        database[msg.sender][_tx_id] = EscrowStruct(buyerAddress, msg.sender, (price - _tax_amount), _tax_amount, 0, 0, Status.PENDING);

        myDatabase[msg.sender].push(MyDatabase(msg.sender, buyerAddress, _tx_id));

        myDatabase[buyerAddress].push(MyDatabase(msg.sender, buyerAddress, _tx_id));

        emit OrderStarted(msg.sender, buyerAddress, _tx_id, price);

        return (buyerAddress, msg.sender, _tx_id, price);
    }
    
    /// @notice Deliver the order and set the delivery timestamp
    /// @param sellerAddress The address of the buyer of the order
    /// @param _tx_id The id of the order
    function deliverOrder(address sellerAddress, bytes32 _tx_id) external  Pending(sellerAddress, _tx_id) {

        if(msg.sender != database[sellerAddress][_tx_id].buyer) revert InvalidCaller();

        database[sellerAddress][_tx_id].deliveryTimestamp = block.timestamp;

        emit OrderDelivered(sellerAddress, _tx_id, block.timestamp);
    }

     /// @notice Confirm the delivery and forward funds to seller
    /// @param sellerAddress The address of the buyer
    /// @param _tx_id The id of the order
    function confirmDelivery(address sellerAddress, bytes32 _tx_id) external Pending(sellerAddress, _tx_id){

        if(msg.sender != database[sellerAddress][_tx_id].seller) revert InvalidCaller();

        if(database[sellerAddress][_tx_id].deliveryTimestamp == 0) revert OrderNotDeliver();

        database[sellerAddress][_tx_id].status = Status.COMPLETED;

        uint256 amountToRelease = database[sellerAddress][_tx_id].amount;

        address buyerAdd = database[sellerAddress][_tx_id].buyer;

        uint256 _tax_amount =  getTax(amountToRelease, escrowTax.sellerTax);

        collectFees(_tax_amount);

        Rigel.transfer(buyerAdd, (amountToRelease - _tax_amount));

        emit DeliveryConfirmed(buyerAdd, _tx_id, amountToRelease);
    }
    
    /// @notice Open a dispute, if this is done in 48h from delivery
    /// @param sellerAddress The address of the buyer of the order
    /// @param _tx_id The id of the order
    function openDispute(address sellerAddress, bytes32 _tx_id) external Pending(sellerAddress, _tx_id) {
        address _seller = database[sellerAddress][_tx_id].seller;
        if(
            msg.sender != database[sellerAddress][_tx_id].buyer || 
            msg.sender != _seller
        ) revert InvalidCaller();

        if(block.timestamp > database[sellerAddress][_tx_id].deliveryTimestamp + 48 hours) revert openIn48Hours();

        database[sellerAddress][_tx_id].status = Status.IN_DISPUTE;

        uint256 _dispute_amount =  getTax(database[sellerAddress][_tx_id].amount, escrowTax.disputeTax);
        bool who;
        if(msg.sender == _seller) {
            Rigel.transferFrom(msg.sender, address(this), _dispute_amount);
        } else {
            database[sellerAddress][_tx_id].amount = database[sellerAddress][_tx_id].amount - _dispute_amount;
            who = true;
        }

        taskOnDispute[_tx_id] = TasksOnDispute(database[sellerAddress][_tx_id].buyer, 0, false, database[sellerAddress][_tx_id].seller, 0, who);

        database[sellerAddress][_tx_id].ifDisputeFee = _dispute_amount;
    }

    /// @notice Refunds the buyer. Only moderators or seller can call this
    /// @param sellerAddress The address of the buyer to refund
    /// @param _tx_id The id of the order
    function refundSeller(address sellerAddress, bytes32 _tx_id) public Pending(sellerAddress, _tx_id) {

        if(msg.sender != database[sellerAddress][_tx_id].buyer) revert InvalidCaller();

        if(database[sellerAddress][_tx_id].status != Status.IN_DISPUTE ) revert RefundProcessNotValid();

        uint256 amountToRefund = whoRaisedDispute(sellerAddress, _tx_id); 
        
        database[sellerAddress][_tx_id].status = Status.REFUNDED;

        uint256 dispute = database[sellerAddress][_tx_id].ifDisputeFee;

        uint256 share = _rewardMembers(_tx_id, dispute);

        if(share == 0) {
            amountToRefund = amountToRefund - dispute;
        }

        taskOnDispute[_tx_id].isResolve = true;

        Rigel.transfer(sellerAddress, amountToRefund);

        emit RefundEmitted(sellerAddress, _tx_id, amountToRefund);
    }

    /// @notice Resolve the dispute in favor of the seller
    /// @param sellerAddress The address of the buyer of the order
    /// @param _tx_id The id of the order
    function refundBuyer(address sellerAddress, bytes32 _tx_id) public Pending(sellerAddress, _tx_id) {

        if(msg.sender != database[sellerAddress][_tx_id].seller) revert InvalidCaller();

        address sellerAdd = database[sellerAddress][_tx_id].seller;
        
        uint256 dispute = database[sellerAddress][_tx_id].ifDisputeFee;

        uint256 amountToRefund = whoRaisedDispute(sellerAddress, _tx_id); 

        uint256 _tax_amount =  getTax(amountToRefund, escrowTax.sellerTax);

        collectFees(_tax_amount);

        uint256 share = _rewardMembers(_tx_id, dispute);


        if(share != 0) {
            amountToRefund = amountToRefund + dispute;
        }

        Rigel.transfer(sellerAdd, (amountToRefund - _tax_amount));

        taskOnDispute[_tx_id].isResolve = true;

        emit ResolvedToSeller(sellerAdd, _tx_id, amountToRefund);
    }

    function whoRaisedDispute(address sellerAddress, bytes32 _tx_id) private view returns(uint256 amountToRefund) {
        bool whoR = taskOnDispute[_tx_id].isBuyer;
        if(!whoR) {
            amountToRefund = database[sellerAddress][_tx_id].amount + database[sellerAddress][_tx_id].tax_amount;
        } else {
            amountToRefund = database[sellerAddress][_tx_id].amount - database[sellerAddress][_tx_id].tax_amount;
        }
    }

    function joinDispute(bytes32 _tx_id) external {

        if(taskOnDispute[_tx_id].isResolve) revert AlreadyResolve();

        if(IDispute(stakeContract).getMyRank(msg.sender) == 0) revert StakeFirst();

        if(menInDispute[_tx_id].length == 5) revert WeAreCompleted();
        menInDispute[_tx_id].push(MenInDispute(msg.sender,block.timestamp));
    }

    function vote(address who, bytes32 _tx_id) external {

        if(menInDispute[_tx_id].length != 5) revert VoteCantStartNow();

        address vBuyer = taskOnDispute[_tx_id].buyer;

        address vSeller = taskOnDispute[_tx_id].seller;

        if (vBuyer != who || vSeller != who) revert NotAParty();

        uint256 lent = menInDispute[_tx_id].length;

        bool _hasRight;

        for (uint256 i; i < lent; ) {
            if(msg.sender == menInDispute[_tx_id][i].member) {
                _hasRight = true;
                break;
            } else {
                _hasRight = false;
            }
            unchecked {
                i++;
            }
        }

        if (!_hasRight) revert NoVoteAccess();

        if (who == vBuyer) {
            taskOnDispute[_tx_id].buyerVoteCounts ++;
            if ( taskOnDispute[_tx_id].buyerVoteCounts >= (2 + 1)) {
                Rigel.transfer(vBuyer, (database[vSeller][_tx_id].amount));
            }
        } else {
            taskOnDispute[_tx_id].sellerVoteCounts ++;
            if ( taskOnDispute[_tx_id].sellerVoteCounts >= (2 + 1)) {
                Rigel.transfer(vSeller, (database[vSeller][_tx_id].amount));
            }
        }
    }

    function _rewardMembers(bytes32 _tx_id, uint256 amount) private returns(uint256 shares) {
        uint256 lent = menInDispute[_tx_id].length;
        shares = amount / lent;
        if(lent > 0) {
            for (uint256 i; i < lent; ) {
                Rigel.transfer(menInDispute[_tx_id][i].member, shares);
                unchecked {
                    i++;
                }
            }
            shares = 0;
        } else {
            return shares;
        }
    }

    function getTax(uint256 amount, uint256 _tax) private pure returns(uint256) {
        return (amount * _tax) / 100;
    }
    
    /// @notice Collects fees and forward to feeCollector
    function collectFees(uint256 amount) internal{
        Rigel.transfer(feeCollector, amount);
    }
    
    function getDatabase(address buyerAddress, bytes32 _tx_id) external view returns(EscrowStruct memory _escrow) {
        _escrow = database[buyerAddress][_tx_id];
    }

    function getMydatabase(address account) external view returns (MyDatabase[] memory mine) {
        uint256 lent = myDatabase[account].length;
        mine = new MyDatabase[](lent);
        for(uint256 i; i < lent;) {
            mine[i] = myDatabase[account][i];
            unchecked {
                i++;
            }
        }
    }

    function taskDisputeDetails(bytes32 _tx_id) external view returns(TasksOnDispute memory task) {
        task = taskOnDispute[_tx_id];
    }

    function payFeeTo() external view returns(address) {
        return feeCollector;
    }

    function getTotalTradedAmount() external view returns(uint256) {
        return AmountTraded;    
    }

}
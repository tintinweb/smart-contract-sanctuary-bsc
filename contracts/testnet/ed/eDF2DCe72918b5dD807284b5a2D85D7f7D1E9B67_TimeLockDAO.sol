//SPDX-License-Identifier: MIT
pragma solidity >=0.8.12 <0.9.0;

import '@openzeppelin/contracts/utils/Context.sol';
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import './interface/ITimeLockDAO.sol';

contract TimeLockDAO is ITimeLockDAO,ReentrancyGuard{

    //Delays
    uint public constant MIN_DELAY = 86400;      // seconds  (24hrs)
    uint public constant MAX_DELAY = 172800;     // seconds  (48hrs)
    uint public constant GRACE_PERIOD = 172800;  // seconds  (48hrs)

    //Struct of QueueDetails
    struct QueueDetails{
        bool isActive;
        uint256 mobVotes;
    }
     
    //Mapping for Queued functions
    mapping(bytes32 => QueueDetails) public queued;

    //Mapping for voted address for a perticular queued function
    mapping(bytes32=>mapping(address=>bool)) public isVoted;
    
    //Mapping for member of boards
    mapping(address=>bool) public isMOB;

    struct CurrentMOBStatus{
        uint256 totalVotes;
        mapping(address=>bool) isVoted;
    }

     //Mapping to Add MOB
    mapping(address=>CurrentMOBStatus) public mobAddingStatus;

     //Mapping to Remove MOB
    mapping(address=>CurrentMOBStatus) public mobRemovingStatus;

    //Member of boards 
    address[] private _MOBs;

    address public bnbCollectorWallet;

    constructor(address[] memory MOBs_,address bnbCollectorWallet_) {
        
        bnbCollectorWallet=bnbCollectorWallet_;

        //Initialize Member of Boards
        for(uint i=0;i<MOBs_.length;i++){
           isMOB[MOBs_[i]]=true;
        }
         
        //Initialize Member of boards
        _MOBs = new address[](MOBs_.length);
        _MOBs= MOBs_;

    }

   //Modifier for only member of boards
    modifier onlyMOB() {
        require(isMOB[msg.sender],"Error: Not a member of board");
        _;
    }

    //Function To Create a Transaction ID
    function getTxId(
        address target_,
        uint value_,
        string calldata func_,
        bytes calldata data_,
        uint timestamp_
    ) public pure override  returns (bytes32) {
        return keccak256(abi.encode(target_, value_, func_, data_, timestamp_));
    }


    /**
     * @param target_ Address of contract or account to call
     * @param value_ Amount of BNB to send
     * @param func_ Function signature, for example "foo(address,uint256)"
     * @param data_ ABI encoded data send.
     * @param timestamp_ Timestamp after which the transaction can be executed.
     */
    function queue(
        address target_,
        uint  value_,
        string calldata func_,
        bytes calldata data_,
        uint timestamp_
    ) external override  returns(bytes32 txId) {

        txId = getTxId(target_, value_, func_, data_, timestamp_);

        //Required if not already queued
        require(!queued[txId].isActive,"Error : Already Queued");
    
        // ---|------------|---------------|-------
        //  block    block + min     block + max
        require( timestamp_ > block.timestamp + MIN_DELAY ||
                 timestamp_ < block.timestamp + MAX_DELAY,"Error : Timestamp Not In Range");

        queued[txId].isActive = true;
        emit Queue(txId, target_, value_, func_, data_, timestamp_);
        return txId;
    }

    /**
     * @param target_ Address of contract or account to call
     * @param value_ Amount of BNB to send
     * @param func_ Function signature, for example "foo(address,uint256)"
     * @param data_ ABI encoded data send.
     * @param timestamp_ Timestamp after which the transaction can be executed.
     */
    function execute(
        address target_,
        uint value_,
        string calldata func_,
        bytes calldata data_,
        uint timestamp_
    ) external override payable  nonReentrant() returns (bytes memory) {
        bytes32 txId = getTxId(target_, value_, func_, data_, timestamp_);

       
        require(queued[txId].isActive,"Not Queued Error");
        // ----|-------------------|-------
        //  timestamp    timestamp + grace period

        require(block.timestamp > timestamp_,"Timestamp Not Passed Error");
        require(block.timestamp < timestamp_ + GRACE_PERIOD,"Timestamp Expired Error");
        require(votePercentage(txId)>50,"Not Min Votes Error");

        queued[txId].isActive = false;

        // prepaire data
        bytes memory data;
        if (bytes(func_).length > 0) {
            // data = func selector + data_
            data = abi.encodePacked(bytes4(keccak256(bytes(func_))), data_);
        } else {
            // call fallback with data
            data = data_;
        }
       
        // call target
        (bool success, bytes memory res) = target_.call{value: value_}(data);
        require(success,"Tx Failed Error");

        emit Execute(txId, target_, value_, func_, data_, timestamp_);

        return res;
    }

   //get voting percentage
    function votePercentage(bytes32 txId_) public view override returns(uint256){
       
        uint256 mobsVotePercentage=(queued[txId_].mobVotes * 100)/_MOBs.length;
        return mobsVotePercentage;
    }

    //Voting function
    function vote(bytes32 txID_) external override onlyMOB nonReentrant()  returns(bool){

        //Check weather the function is Queued or not
        require(queued[txID_].isActive,"Not Queued Error");

        //Check weather address is already voted or not
        require(!isVoted[txID_][msg.sender],"Already Voted Error");
     
    
              isVoted[txID_][msg.sender]=true;
              queued[txID_].mobVotes +=1;
       

       return true;
    }

    //Function to recive BNB 
    receive() external override payable {}

    //Function to withdraw BNB 
    function withdrawBNB(uint amount_) external override payable  nonReentrant() returns(bool){
        require(address(this).balance>=amount_, "contract do not have sufficient BNB");
        payable(bnbCollectorWallet).transfer(amount_);
        return(true);
   }

    //Function to Check BNB 
    function getBalanceBNB()  external view override  returns(uint256){
        return(address(this).balance);
   }

    //Function to Add MOB
    function addMOB(address newMember_)  external  onlyMOB returns(bool){
         
         if(mobAddingStatus[newMember_].totalVotes>(_MOBs.length/2)){
              
                isMOB[newMember_]=true;
                _MOBs.push(newMember_);

                //After Adding Member
                for(uint256 i=0;i<_MOBs.length;i++){
                   mobAddingStatus[newMember_].isVoted[_MOBs[i]]=false;
                }
                mobAddingStatus[newMember_].totalVotes =0;

                emit NewMemberAdded(newMember_);
         }
         else{
                require(!mobAddingStatus[newMember_].isVoted[msg.sender],"Already Voted Error");
                mobAddingStatus[newMember_].isVoted[msg.sender]=true;
                mobAddingStatus[newMember_].totalVotes +=1;
             
         }

        return(true);
   }

    //Function to Remove MOB
    function removeMOB(address member_)  external onlyMOB  returns(bool){
          
         if(mobRemovingStatus[member_].totalVotes>(_MOBs.length/2)){
               
                 isMOB[member_]=false;
                for (uint256 i = 0; i < _MOBs.length; i++) {
                        if (_MOBs[i] == member_) {
                            delete _MOBs[i];
                        }
                    }

                //After Removeing Member
                for(uint256 i=0;i<_MOBs.length;i++){
                   mobRemovingStatus[member_].isVoted[_MOBs[i]]=false;
                }
                mobRemovingStatus[member_].totalVotes =0;
                   
                emit MemberRemoved(member_);
         }
         else{
             
                require(!mobRemovingStatus[member_].isVoted[msg.sender],"Already Voted Error");
                mobRemovingStatus[member_].isVoted[msg.sender]=true;
                mobRemovingStatus[member_].totalVotes +=1;
         }

        return(true);
   }



}

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.12 <0.9.0;

/// @title Time Lock + DAO interface
interface ITimeLockDAO {

   //Events
    event Queue(
        bytes32 indexed txId_,
        address indexed target_,
        uint value_,
        string func_,
        bytes data_,
        uint timestamp_
    ); 

    event Execute(
        bytes32 indexed txId_,
        address indexed target_,
        uint value_,
        string func_,
        bytes data_,
        uint timestamp_
    );

    event NewMemberAdded(address indexed memberAddress_);
    event MemberRemoved(address indexed memberAddress_);


    //Function To Create a Transaction ID
    function getTxId(
        address target_,
        uint value_,
        string calldata func_,
        bytes calldata data_,
        uint timestamp_
    ) external  returns (bytes32);

    /**
     * @param target_ Address of contract or account to call
     * @param value_ Amount of BNB to send
     * @param func_ Function signature, for example "foo(address,uint256)"
     * @param data_ ABI encoded data send.
     * @param timestamp_ Timestamp after which the transaction can be executed.
     */
    function queue(
        address target_,
        uint value_,
        string calldata func_,
        bytes calldata data_,
        uint timestamp_
    ) external  returns (bytes32 txId);

    function execute(
        address target_,
        uint value_,
        string calldata func_,
        bytes calldata data_,
        uint timestamp_
    ) external payable  returns (bytes memory);

    function vote(bytes32 txID_) external returns(bool);

    function votePercentage(bytes32 txId) external view  returns(uint256);

    //Function to recive BNB 
    receive() external payable;

    //Function to withdraw BNB 
    function withdrawBNB(uint _amount) external payable returns(bool);

    //Function to get balance BNB 
    function getBalanceBNB() external returns(uint256);
    
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}
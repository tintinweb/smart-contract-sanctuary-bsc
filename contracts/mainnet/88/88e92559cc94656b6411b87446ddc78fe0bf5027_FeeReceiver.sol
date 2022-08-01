/**
 *Submitted for verification at BscScan.com on 2022-08-01
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
interface IFeeReceiver{
    function receiveFees(address Token) external payable;
}
abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
contract FeeReceiver is Ownable, IFeeReceiver{
    uint constant MinThreshold=1 ether;
    address[] public receivers;
    uint[] public amounts;
    struct Receiver{
        address receiver1;
        address receiver2;
    }
    mapping(address=>Receiver) public bonusReceiver;
    uint DENOMINATOR;
    function setBonusReceivers(address token, address receiver1,address receiver2) external onlyOwner{
        bonusReceiver[token]=Receiver(receiver1,receiver2);
    }
    function setReceivers(address[] memory receivers_, uint[] memory amounts_) external onlyOwner{
        require(receivers_.length==amounts_.length);
        DENOMINATOR=0;
        receivers= receivers_;
        amounts=amounts_;
        for(uint i=0;i<amounts_.length;i++){
            DENOMINATOR+=amounts_[i];
        }
    }
    function receiveFees(address Token) external payable{
       Receiver memory receiver=bonusReceiver[Token];
        bool sent;
        if(receiver.receiver1!=address(0)){
            if(receiver.receiver2!=address(0)){
                (sent,)=receiver.receiver1.call{value:msg.value*125/2000}("");
                (sent,)=receiver.receiver2.call{value:msg.value*125/2000}("");
            }else{
                (sent,)=receiver.receiver1.call{value:msg.value*125/2000}("");
            }

        }
        if(address(this).balance< 1 ether)return;

        uint contractBalance=address(this).balance;
        for(uint i=0;i<receivers.length;i++){
            (sent,)=receivers[i].call{value:contractBalance*amounts[i]/DENOMINATOR}("");
            }


    }

    





}
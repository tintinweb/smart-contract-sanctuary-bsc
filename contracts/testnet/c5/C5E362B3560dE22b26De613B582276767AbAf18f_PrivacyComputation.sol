/**
 *Submitted for verification at BscScan.com on 2022-09-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor ()  { }

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
   */
    constructor ()  {
        address msgSender = _msgSender();
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



library Library {
    struct data {
        mapping (address => value) resultMap;
        bool isValue;
        int8 length;
    }
    struct value {
        bool isValue;
        string val;
    }
}

contract PrivacyComputation is Context, Ownable {
    address public party0;
    address public party1;
    address public party2;
    uint32 public RoundId;

    mapping (uint32 => Library.data) public results;


    constructor() public  {
        RoundId=1;
    }

    function setPartyAddresses(address partyA,address partyB,address partyC) public onlyOwner
    {
        require(partyA != address(0), "new address partyA is the zero address");
        require(partyB != address(0), "new address partyB is the zero address");
        require(partyC != address(0), "new address partyC is the zero address");
        party0=partyA;
        party1=partyB;
        party2=partyC;
    }

    function submit(uint32 roundId,bytes calldata data) external{
        require(roundId == RoundId, "the roundId is not equal to RoundId");

        require((msg.sender== party0||msg.sender== party1||msg.sender== party2), "msg.sender address error");

        string memory message = string(data);

        Library.data storage resultVal=results[roundId];
        Library.value storage mapVal=resultVal.resultMap[msg.sender];

        if(resultVal.isValue){
            require(resultVal.length < 3 && !mapVal.isValue, "do not resubmit");
            
            resultVal.length+=1;
            if(resultVal.length==3){
                RoundId+=1;
            }
        }else{
            resultVal.length=1;
            resultVal.isValue=true;
        }
        mapVal.val=message;
        mapVal.isValue=true;
    }

    function getResult(uint32 roundId,address part) external view returns(string memory)
    {
        require(roundId <= RoundId, "BEP20: the roundId should not be more than RoundId");
        Library.data storage resultVal=results[roundId];
        return resultVal.resultMap[part].val;
    }

    function getRoundId() external view returns(uint32)
    {
        return RoundId;
    }
}
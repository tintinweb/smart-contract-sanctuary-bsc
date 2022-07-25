/**
 *Submitted for verification at BscScan.com on 2022-07-25
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface QuadrixNFT{
     function createCollection(address _collectionUser,uint _collectionMonth,uint _collectionAmount,uint _collectionLimit,uint _collectionPercentage,string memory _collectionName,string memory _collectionSymbol,string memory _collectionURI,address _depositToken)external returns(address);
}


contract QuadrixNFTFactory{
    QuadrixNFT private _QuadrixNFT;
    uint public collectionID = 1;
    address public owner;
    address public signer;
   

    struct Collection {
        uint collectionID;
        address collectionUser;
        address collectionNFTAddress;
        address collectionTokenAddress;
        uint collectionMonth;
        uint collectionAmount;
        uint collectionPercentage;
        uint collectionLimit;
        string collectionName;
        string collectionSymbol;
        string collectionURI;
    }
    mapping(uint => Collection) private collectionDetails;
    mapping(address => uint[]) public userIDS;

    event createCollection(uint _collectionID,address _collectionUser,address _collectionAddress,uint _collectionAmount,uint _createTime);

    constructor(address _owner,address _signer,QuadrixNFT _nft){
        owner = _owner;
        signer = _signer;
        _QuadrixNFT = _nft;
    }
    struct Sig {
        /* v parameter */
        uint8 v;
        /* r parameter */
        bytes32 r;
        /* s parameter */
        bytes32 s;
    }

    modifier _onlyOwner() {
        require(owner == msg.sender, "QuadrixNFTFactory: caller is not the owner");
        _;
    } 

    function updateSigner(address _signer)public _onlyOwner{
        require(_signer != address(0),"QuadrixNFTFactory:Invalid Address");
        signer = _signer;
    }

    function transferOwnerShip(address _owner)public _onlyOwner{
        require(_owner != address(0),"QuadrixNFTFactory:Invalid Address");
        owner = _owner;
    }


    function collection(Collection memory collections,uint expiry,Sig memory sig) public {
        require(bytes(collections.collectionName).length > 0, "QuadrixNFTFactory : name must not be empty");
        require(bytes(collections.collectionSymbol).length > 0, "QuadrixNFTFactory : symbol must not be empty");
        require(bytes(collections.collectionURI).length > 0, "QuadrixNFTFactory : URI must not be empty");
        require(collections.collectionUser != address(0),"QuadrixNFTFactory : Invalid Collection Users");
        require(collections.collectionMonth > 0 ,"QuadrixNFTFactory : Invalid Collection Month");
        require(collections.collectionAmount > 0 ,"QuadrixNFTFactory : Invalid Collection Amount");
        require(collections.collectionLimit > 0 ,"QuadrixNFTFactory : Invalid Collection Limit");
        require(expiry > block.timestamp,"QuadrixNFTFactory : Expired");

        validateSignature(collections.collectionUser,collections.collectionMonth,collections.collectionAmount,collections.collectionLimit,expiry,sig);

        address QuadNFT = _QuadrixNFT.createCollection(collections.collectionUser,collections.collectionMonth,collections.collectionAmount,collections.collectionLimit,collections.collectionPercentage,collections.collectionName,collections.collectionSymbol,collections.collectionURI,collections.collectionTokenAddress);

        Collection storage coll = collectionDetails[collectionID];
        coll.collectionID = collectionID;
        coll.collectionUser = collections.collectionUser;
        coll.collectionNFTAddress = QuadNFT;
        coll.collectionTokenAddress = collections.collectionTokenAddress;
        coll.collectionMonth = collections.collectionMonth;
        coll.collectionAmount = collections.collectionAmount;
        coll.collectionLimit = collections.collectionLimit;
        coll.collectionName = collections.collectionName;
        coll.collectionSymbol = collections.collectionSymbol;
        coll.collectionURI = collections.collectionURI;

        userIDS[collections.collectionUser].push(collectionID);
        emit createCollection(collectionID,coll.collectionUser,QuadNFT, coll.collectionAmount,block.timestamp);
        collectionID++;

    }

     function validateSignature(address _collectionUser,uint _collectionMonth,uint _collectionAmount,uint _collectionLimit,uint expiry, Sig memory sig) public {
         bytes32 hash = prepareHash(_collectionUser,address(this),_collectionMonth,_collectionAmount,_collectionLimit,expiry);
         require(ecrecover(hash, sig.v, sig.r, sig.s) == signer , "QuadrixNFTFactory : Invalid Signature");
    }

    function prepareHash(address _collectionUser,address _contract,uint _collectionMonth,uint _collectionAmount,uint _collectionLimit,uint expiry)public  pure returns(bytes32){
        bytes32 hash = keccak256(abi.encodePacked(_collectionUser,_contract,_collectionMonth,_collectionAmount,_collectionLimit,expiry));
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function viewCollectionDetails(uint _collectionID)public view returns(Collection memory){
        return collectionDetails[_collectionID];
    }
}
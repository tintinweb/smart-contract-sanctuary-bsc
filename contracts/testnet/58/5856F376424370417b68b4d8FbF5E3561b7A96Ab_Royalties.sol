// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Royalties{
    
    address private owner;
    address private operational;
    uint64 private transactionFee=369;

    struct RoyaltiesAddress{
        uint256 _nftId;
        address _athleteAddress;
        address _fedrationAddress;
        uint64 _categories;
    }

    struct Royaltiesfee
    {
        uint64 _categories;
        uint64 _athletefee;
        uint64 _fedrationfee;
    }

        
    constructor(address _operational){
       owner=msg.sender;
       operational=_operational;
    }

    mapping(uint256 => RoyaltiesAddress) private _address;
    mapping(uint256 => Royaltiesfee) private _fee;
    mapping(uint256 => bool) public id;
    mapping(uint64 => bool) public category;


     modifier onlyOwner {
      require(msg.sender == owner,"Royalties: Not owner");
      _;
   }

    function updateTransactionFee(uint64 fee)public onlyOwner
    {
        require(fee <= 10000, "Royalties: TransactionFee must be less than 10000");
        transactionFee=fee;
    } 

    function setRoyaltiesAddresses(
        uint256 nftId,
        address athleteAddress,
        address fedrationAddress,
        uint64 categories
    )internal
    {
       _address[nftId]._nftId=nftId;
       _address[nftId]._athleteAddress=athleteAddress;
       _address[nftId]._fedrationAddress=fedrationAddress;
       _address[nftId]._categories=categories;
    }

    function setRoyaltiesfee(
        uint64 categories,
        uint64 athletefee,
        uint64 fedrationfee
    )internal 
    {
        
       _fee[categories]._categories=categories;
       _fee[categories]._athletefee=athletefee;
       _fee[categories]._fedrationfee=fedrationfee;
       category[categories]=true;
    }

    function _addRoyaltiesAddress(
        uint256 idNft,
        address athleteAddr,
        address fedrationAddr,
        uint64 categories
    )public onlyOwner
    {
        require(!id[idNft],"Royalties: NFT already exist");
        require(category[categories],"Royalties: category does not exist");
        setRoyaltiesAddresses(idNft,athleteAddr,fedrationAddr,categories);
        id[idNft]=true;
    }

    

     function _addNewCategoryBatch(
        uint64[] memory categories,
        uint64[] memory athletefee,
        uint64[] memory fedrationfee
    ) external onlyOwner
    {
        require( 
        categories.length == athletefee.length && 
        athletefee.length == fedrationfee.length &&
        fedrationfee.length == categories.length,
        "Royalties:  length mismatch"
        );
        

        for (uint256 index = 0; index < categories.length; ++index) {
        require(!category[categories[index]],"Royalties: category already exist");
        require(athletefee[index] <= 10000, "Royalties: athletefee must be less than 10000");
        require(fedrationfee[index] <= 10000, "Royalties: fedrationfee must be less than 10000");
            setRoyaltiesfee(
                categories[index],
                athletefee[index],
                fedrationfee[index]
            );
        }
    }

    function _updateCategory(
        uint64 categories,
        uint64 athletefee,
        uint64 fedrationfee
    )public onlyOwner
    {
        require(category[categories],"Royalties: category does not exist");
        require(athletefee <= 10000, "Royalties: athletefee must be less than 10000");
        require(fedrationfee <= 10000, "Royalties: fedrationfee must be less than 10000");
        setRoyaltiesfee(categories,athletefee,fedrationfee);
    }

    function getRoyaltiesAddresses(uint256 nftId) public view returns(address,address,uint64) 
    {
        return (_address[nftId]._athleteAddress,_address[nftId]._fedrationAddress,_address[nftId]._categories);
    }

    function getRoyaltiesfee(uint64 categories) public view returns(uint256,uint256) 
    {
        return (_fee[categories]._athletefee,_fee[categories]._fedrationfee);
    }

    function getAthleteAddress(uint256 nftId)public view returns(address)
    {
        return _address[nftId]._athleteAddress;
    }

    function getCategories(uint256 nftId)public view returns(uint64)
    {
        return _address[nftId]._categories;
    }
     function getFedrationAddress(uint256 nftId)public view returns(address)
    {
        return _address[nftId]._fedrationAddress;
    }

    function getAthletefee(uint64 categories)public view returns(uint64)
    {
        return _fee[categories]._athletefee;
    }

    function getFedrationfee(uint64 categories)public view returns(uint64)
    {
        return _fee[categories]._fedrationfee;
    }
    function OperationalAddress()public view returns(address)
    {
        return operational;
    }
    function TransactionFee()public view returns(uint64)
    {
        return transactionFee;
    }
    function OwnerAddress()public view returns(address)
    {
        return owner;
    }


}
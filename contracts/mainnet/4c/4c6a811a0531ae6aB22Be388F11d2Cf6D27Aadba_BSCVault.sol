// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./IERC1155.sol";
import "./IERC721.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract BSCVault is Ownable{
    using SafeMath for uint256;

    /// @notice NFT token type supported: 0-ERC721, 1-ERC1155
    enum TokenType {ERC721, ERC1155}
    
    /// @notice NFT token status flag: 0-empty, 1-for_rent, 2-rented, 3-not_rentable
    enum TokenState {empty, for_rent, rented, not_rentable}

    struct Term{
        TokenType  tkType;
        bool       renewable;
        address    lender;
        uint       coinIndex;
        uint       minTime;
        uint       maxTime;
        uint       price;
        uint       gameBonus;
        TokenState status;
        address    renter;
        uint       leaseTime;
        uint       endtime;
    }

    address[] public rentCoin;
    uint public adminFee;
    address public adminWallet;

    /// @notice NFT leasing term indexed by NFT contract address and token id
    mapping(address => mapping(uint => Term)) public term;
    mapping(address => mapping(uint => uint)) public userBalance;
    mapping(uint => uint) public adminBalance;
    mapping(address => mapping(address => uint[])) public userNFT;

    event Deposit(address _lender, TokenType _tkType, address _NFTaddr, uint _tokenID, bool _renewable, uint _coinIndex, uint8 _minimumLeaseTime, uint8 _maximumLeaseTime, uint _price, uint8 _gameBonus);
    event Withdraw(address _lender, TokenType _tkType, address _NFTaddr, uint _tokenID);
    event Rent(address _renter, address _NFTaddr, uint _tokenID, uint _rentTime);
    event ResetDeposit(address _lender, TokenType _tkType, address _NFTaddr, uint _tokenID, bool _renewable, uint _coinIndex, uint8 _minimumLeaseTime, uint8 _maximumLeaseTime, uint _price, uint8 _gameBonus);

    /// @notice Deposit NFT into vault with leasing term
    function deposit(TokenType _tkType, address _NFTaddr, uint _tokenID, bool _renewable, uint _coinIndex, uint8 _minimumLeaseTime, uint8 _maximumLeaseTime, uint _price, uint8 _gameBonus) public returns(bool){
        if(_tkType == TokenType.ERC721){
            require(IERC721(_NFTaddr).ownerOf(_tokenID) == msg.sender ,"Depositer must be owner!" );
        }else{
            require(IERC1155(_NFTaddr).balanceOf(msg.sender,_tokenID) > 0 ,"Depositer must be owner!" );
        }

        term[_NFTaddr][_tokenID] = Term({
            tkType: _tkType,
            renewable: _renewable,
            lender: msg.sender,
            coinIndex: _coinIndex,
            minTime: _minimumLeaseTime,
            maxTime: _maximumLeaseTime,
            price: _price,
            gameBonus: _gameBonus,
            status: TokenState.for_rent,
            renter: address(0),
            leaseTime: 0,
            endtime: 0});

        if(_tkType == TokenType.ERC721){
            IERC721(_NFTaddr).transferFrom(msg.sender,address(this),_tokenID);
        }else{
            IERC1155(_NFTaddr).safeTransferFrom(msg.sender,address(this),_tokenID,1,"0x00");
        }

        emit Deposit(msg.sender, _tkType, _NFTaddr, _tokenID, _renewable, _coinIndex, _minimumLeaseTime, _maximumLeaseTime, _price, _gameBonus);

        return true;
    }
    
    /// @notice change leasing term of NFT in vault
    function resetDeposit(TokenType _tkType, address _NFTaddr, uint _tokenID, bool _renewable, uint _coinIndex, uint8 _minimumLeaseTime, uint8 _maximumLeaseTime, uint _price, uint8 _gameBonus) public returns(bool){
        require(term[_NFTaddr][_tokenID].lender == msg.sender, "Only depositer allowed");

        Term storage rentTerm = term[_NFTaddr][_tokenID];
        rentTerm.renewable = _renewable;
        rentTerm.coinIndex = _coinIndex;
        rentTerm.minTime = _minimumLeaseTime;
        rentTerm.maxTime = _maximumLeaseTime;
        rentTerm.price = _price;
        rentTerm.gameBonus = _gameBonus;
        rentTerm.endtime = 0;

        emit ResetDeposit(msg.sender, _tkType, _NFTaddr, _tokenID, _renewable, _coinIndex, _minimumLeaseTime, _maximumLeaseTime, _price, _gameBonus);
        return true;
    }

    /// @notice Withdraw NFT from vault after leasing
    function withdraw(address _NFTaddr, uint _tokenID) public{
        require(term[_NFTaddr][_tokenID].status != TokenState.rented || term[_NFTaddr][_tokenID].endtime < block.timestamp, "NFT in rent!");
        require(term[_NFTaddr][_tokenID].lender == msg.sender, "Only depositer allowed");

        if(term[_NFTaddr][_tokenID].tkType == TokenType.ERC721){
            IERC721(_NFTaddr).safeTransferFrom(address(this), msg.sender, _tokenID);
        }else{
            IERC1155(_NFTaddr).safeTransferFrom(address(this), msg.sender, _tokenID, 1, "0x00");
        }

        term[_NFTaddr][_tokenID].status = TokenState.empty;

        emit Withdraw(msg.sender, term[_NFTaddr][_tokenID].tkType, _NFTaddr, _tokenID);
    }

    /// @notice Rent NFT in the vault
    function rent(address _NFTaddr, uint _tokenID, uint _rentTime) public{
        require(term[_NFTaddr][_tokenID].status != TokenState.empty, "NFT empty");
        require(term[_NFTaddr][_tokenID].lender != msg.sender, "Lender is self");
        require(term[_NFTaddr][_tokenID].status != TokenState.rented || term[_NFTaddr][_tokenID].endtime < block.timestamp, "NFT in rent");
        require(term[_NFTaddr][_tokenID].endtime == 0 || term[_NFTaddr][_tokenID].renewable , "NFT rent disabled");
        require(_rentTime >= term[_NFTaddr][_tokenID].minTime && _rentTime <= term[_NFTaddr][_tokenID].maxTime, "Out of time range");

        address coinAddress = rentCoin[term[_NFTaddr][_tokenID].coinIndex];
        uint fee = term[_NFTaddr][_tokenID].price.mul(_rentTime);
        IERC20(coinAddress).transferFrom(msg.sender, address(this), fee); 

        term[_NFTaddr][_tokenID].status = TokenState.rented;
        term[_NFTaddr][_tokenID].renter = msg.sender;
        term[_NFTaddr][_tokenID].leaseTime = _rentTime;
        term[_NFTaddr][_tokenID].endtime = block.timestamp.add(_rentTime.mul(3600).mul(24));
        userBalance[term[_NFTaddr][_tokenID].lender][term[_NFTaddr][_tokenID].coinIndex] += fee.mul(100 - adminFee).div(100);
        adminBalance[term[_NFTaddr][_tokenID].coinIndex] += fee.mul(adminFee).div(100);
        //_lendItemID
        userNFT[msg.sender][_NFTaddr].push(_tokenID);

        emit Rent(msg.sender, _NFTaddr, _tokenID, _rentTime);
    }

    function addRentCoin(address _rentCoin) public onlyOwner{
        for(uint i = 0 ; i< rentCoin.length ; i++){
            require(_rentCoin != rentCoin[i], "The coin has been added!");
        } 
        rentCoin.push(_rentCoin);
    }

    function setAdminFee(uint _fee) public onlyOwner{
        adminFee = _fee;
    }

    function balanceOf(address _renter, address _NFTaddr) public view returns(uint){
        uint balance = 0;
        for(uint i; i < userNFT[_renter][_NFTaddr].length; i++){
             uint tokenId = userNFT[_renter][_NFTaddr][i];
             if(term[_NFTaddr][tokenId].renter == _renter && 
             term[_NFTaddr][tokenId].status == TokenState.rented &&
             term[_NFTaddr][tokenId].endtime > block.timestamp){
                 balance += 1;
             }
        }
        return balance;
    }

    function tokenOfRenterByIndex(address _renter, address _NFTaddr, uint _index) public view returns(uint) {
        uint index = 0;
        for(uint i; i < userNFT[_renter][_NFTaddr].length; i++){
             uint tokenId = userNFT[_renter][_NFTaddr][i];
             if(term[_NFTaddr][tokenId].renter == _renter && 
             term[_NFTaddr][tokenId].status == TokenState.rented &&
             term[_NFTaddr][tokenId].endtime > block.timestamp){
                 if(index == _index){
                     return tokenId;
                 }
                 index += 1;
             }
        }
        return 0;
    }

    function renterOfToken(address _NFTaddr, uint tokenId) public view returns(address) {
        if(term[_NFTaddr][tokenId].status == TokenState.rented && term[_NFTaddr][tokenId].endtime > block.timestamp){
            return term[_NFTaddr][tokenId].renter;
        }
        return address(0);
    }

    function claimRentFee() public {
        for(uint i = 0; i < rentCoin.length; i ++){
            if(userBalance[msg.sender][i] > 0){
                address coinAddress = rentCoin[i];
                IERC20(coinAddress).transfer(msg.sender, userBalance[msg.sender][i]);
                userBalance[msg.sender][i] = 0;
            }
        }
    }

    function setAdminWallet(address _admin) public onlyOwner {
        adminWallet = _admin;
    }

    function claimAdminFee() public {
        require(adminWallet != address(0), "Admin wallet not set");
        for(uint i = 0; i < rentCoin.length; i ++){
            if(adminBalance[i] > 0){
                address coinAddress = rentCoin[i];
                IERC20(coinAddress).transfer(adminWallet, adminBalance[i]);
                adminBalance[i] = 0;
            }
        }
    }
}